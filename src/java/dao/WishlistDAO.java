package dao;

import Utils.DbContext;
import model.Wishlist;
import model.WishlistItem;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class WishlistDAO extends DbContext {

    public boolean exists(int customerId, int productId) {
        String sql = "SELECT 1 FROM Wishlists w JOIN WishlistItems wi ON wi.wishlist_id = w.id WHERE w.customer_id = ? AND wi.product_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("[WishlistDAO] exists error: " + e.getMessage());
            throw new RuntimeException(e);
        }
    }

    public boolean addWishlist(int customerId, int productId) {
        Connection conn = null;
        PreparedStatement psInsertWishlist = null;
        PreparedStatement psInsertItem = null;
        ResultSet rsKeys = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            // ensure wishlist header exists
            Integer wishlistId = null;
            String sqlSelect = "SELECT id FROM Wishlists WHERE customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlSelect)) {
                ps.setInt(1, customerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) wishlistId = rs.getInt("id");
                }
            }

            if (wishlistId == null) {
                String sqlCreate = "INSERT INTO Wishlists (customer_id, created_at) VALUES (?, GETDATE())";
                psInsertWishlist = conn.prepareStatement(sqlCreate, Statement.RETURN_GENERATED_KEYS);
                psInsertWishlist.setInt(1, customerId);
                int affected = psInsertWishlist.executeUpdate();
                if (affected == 0) {
                    conn.rollback();
                    return false;
                }
                rsKeys = psInsertWishlist.getGeneratedKeys();
                if (rsKeys.next()) wishlistId = rsKeys.getInt(1);
            }

            // check duplicate item
            String sqlCheck = "SELECT 1 FROM WishlistItems WHERE wishlist_id = ? AND product_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlCheck)) {
                ps.setInt(1, wishlistId);
                ps.setInt(2, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        conn.commit();
                        return true; // already exists
                    }
                }
            }

            String sqlInsert = "INSERT INTO WishlistItems (wishlist_id, product_id, created_at) VALUES (?, ?, GETDATE())";
            psInsertItem = conn.prepareStatement(sqlInsert);
            psInsertItem.setInt(1, wishlistId);
            psInsertItem.setInt(2, productId);
            psInsertItem.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException e) {
            System.err.println("[WishlistDAO] addWishlist error: " + e.getMessage());
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) {}
            throw new RuntimeException(e);
        } finally {
            try { if (rsKeys != null) rsKeys.close(); } catch (SQLException ignored) {}
            try { if (psInsertWishlist != null) psInsertWishlist.close(); } catch (SQLException ignored) {}
            try { if (psInsertItem != null) psInsertItem.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.setAutoCommit(true); } catch (SQLException ignored) {}
        }
    }

    public boolean removeWishlist(int customerId, int productId) {
        String sql = "DELETE wi FROM WishlistItems wi JOIN Wishlists w ON wi.wishlist_id = w.id WHERE w.customer_id = ? AND wi.product_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[WishlistDAO] removeWishlist error: " + e.getMessage());
            throw new RuntimeException(e);
        }
    }

    public Wishlist getWishlistByUser(int customerId) {
        String sqlHeader = "SELECT id, customer_id, created_at FROM Wishlists WHERE customer_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sqlHeader)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Wishlist w = new Wishlist();
                    int wishlistId = rs.getInt("id");
                    w.setId(wishlistId);
                    w.setCustomerId(rs.getInt("customer_id"));
                    w.setCreatedAt(rs.getTimestamp("created_at"));
                    w.setItems(getItemsByWishlistId(wishlistId));
                    return w;
                }
            }
        } catch (SQLException e) {
            System.err.println("[WishlistDAO] getWishlistByUser error: " + e.getMessage());
            throw new RuntimeException(e);
        }
        return new Wishlist();
    }

    public List<WishlistItem> getItemsByWishlistId(int wishlistId) {
        String sql = "SELECT wi.id, wi.wishlist_id, wi.product_id, wi.created_at, "
                   + "p.shop_id AS product_shop_id, p.title AS product_title, p.image AS product_image, p.unit AS product_unit, p.stock_quantity, p.sale_price, p.original_price "
                   + "FROM WishlistItems wi "
                   + "LEFT JOIN Products p ON wi.product_id = p.id "
                   + "WHERE wi.wishlist_id = ? ORDER BY wi.created_at DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, wishlistId);
            try (ResultSet rs = ps.executeQuery()) {
                List<WishlistItem> list = new ArrayList<>();
                while (rs.next()) {
                    WishlistItem it = mapRow(rs);
                    list.add(it);
                }
                return list;
            }
        } catch (SQLException e) {
            System.err.println("[WishlistDAO] getItemsByWishlistId error: " + e.getMessage());
            throw new RuntimeException(e);
        }
    }

    private WishlistItem mapRow(ResultSet rs) throws SQLException {
        WishlistItem it = new WishlistItem();
        it.setId(rs.getInt("id"));
        it.setWishlistId(rs.getInt("wishlist_id"));
        it.setProductId(rs.getInt("product_id"));
        it.setCreatedAt(rs.getTimestamp("created_at"));
        it.setShopId(rs.getInt("product_shop_id"));
        it.setTitle(rs.getString("product_title"));
        it.setImage(rs.getString("product_image"));
        it.setUnit(rs.getString("product_unit"));
        it.setStockQuantity(rs.getInt("stock_quantity"));
        double sale = rs.getDouble("sale_price");
        if (sale > 0) it.setUnitPrice(sale); else it.setUnitPrice(rs.getDouble("original_price"));
        return it;
    }

    /**
     * Move wishlist item to cart inside a single transaction.
     * Returns true when moved successfully.
     */
    public boolean moveToCart(int customerId, int productId) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            // find wishlist id
            Integer wishlistId = null;
            String sqlW = "SELECT id FROM Wishlists WHERE customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlW)) {
                ps.setInt(1, customerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) wishlistId = rs.getInt("id");
                }
            }
            if (wishlistId == null) {
                conn.commit();
                return false; // nothing to move
            }

            // validate product
            String sqlProduct = "SELECT id, stock_quantity, sale_price, original_price, status, isDelete FROM Products WHERE id = ?";
            int stock = 0; double unitPrice = 0; boolean active = false; boolean deleted = false;
            try (PreparedStatement ps = conn.prepareStatement(sqlProduct)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        throw new IllegalArgumentException("Sản phẩm không tồn tại.");
                    }
                    stock = rs.getInt("stock_quantity");
                    double sale = rs.getDouble("sale_price");
                    double orig = rs.getDouble("original_price");
                    unitPrice = sale > 0 ? sale : orig;
                    int status = rs.getInt("status");
                    active = status == 1; // assuming 1 means active
                    deleted = rs.getBoolean("isDelete");
                }
            }
            if (deleted || !active) {
                conn.rollback();
                throw new IllegalArgumentException("Sản phẩm không hoạt động hoặc đã bị xóa.");
            }
            if (stock <= 0) {
                conn.rollback();
                throw new IllegalArgumentException("Sản phẩm đã hết hàng.");
            }

            // get or create cart id
            Integer cartId = null;
            String sqlSelectCart = "SELECT id FROM Carts WHERE customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlSelectCart)) {
                ps.setInt(1, customerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) cartId = rs.getInt("id");
                }
            }
            if (cartId == null) {
                String sqlCreateCart = "INSERT INTO Carts (customer_id, total_items, total_amount, created_at, updated_at) VALUES (?, 0, 0, GETDATE(), GETDATE())";
                try (PreparedStatement ps = conn.prepareStatement(sqlCreateCart, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, customerId);
                    int affected = ps.executeUpdate();
                    if (affected == 0) { conn.rollback(); throw new RuntimeException("Failed to create cart"); }
                    try (ResultSet rs = ps.getGeneratedKeys()) { if (rs.next()) cartId = rs.getInt(1); }
                }
            }

            // check existing cart item (size NULL/empty)
            Integer existingItemId = null;
            int existingQuantity = 0;
            String sqlCheckItem = "SELECT id, quantity FROM CartItems WHERE cart_id = ? AND product_id = ? AND (size IS NULL OR size = '')";
            try (PreparedStatement ps = conn.prepareStatement(sqlCheckItem)) {
                ps.setInt(1, cartId);
                ps.setInt(2, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        existingItemId = rs.getInt("id");
                        existingQuantity = rs.getInt("quantity");
                    }
                }
            }

            if (existingItemId != null) {
                int newQty = existingQuantity + 1;
                if (newQty > stock) { conn.rollback(); throw new IllegalArgumentException("Số lượng trong giỏ hàng vượt quá tồn kho."); }
                double newTotal = unitPrice * newQty;
                String sqlUpdateItem = "UPDATE CartItems SET quantity = ?, total_price = ?, updated_at = GETDATE() WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlUpdateItem)) {
                    ps.setInt(1, newQty);
                    ps.setDouble(2, newTotal);
                    ps.setInt(3, existingItemId);
                    ps.executeUpdate();
                }
            } else {
                // insert new cart item with quantity 1
                String sqlInsertItem = "INSERT INTO CartItems (cart_id, product_id, size, quantity, unit_price, discount_amount, total_price, created_at, updated_at) VALUES (?, ?, ?, ?, ?, 0, ?, GETDATE(), GETDATE())";
                try (PreparedStatement ps = conn.prepareStatement(sqlInsertItem)) {
                    ps.setInt(1, cartId);
                    ps.setInt(2, productId);
                    ps.setNull(3, Types.VARCHAR);
                    ps.setInt(4, 1);
                    ps.setDouble(5, unitPrice);
                    ps.setDouble(6, unitPrice * 1);
                    ps.executeUpdate();
                }
            }

            // delete wishlist item(s) for this product
            String sqlDeleteWishlistItem = "DELETE wi FROM WishlistItems wi JOIN Wishlists w ON wi.wishlist_id = w.id WHERE w.customer_id = ? AND wi.product_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlDeleteWishlistItem)) {
                ps.setInt(1, customerId);
                ps.setInt(2, productId);
                ps.executeUpdate();
            }

            // recalculate cart totals
            String sqlRecalc = "UPDATE Carts SET total_items = ISNULL((SELECT SUM(quantity) FROM CartItems WHERE cart_id = ?), 0), total_amount = ISNULL((SELECT SUM(total_price) FROM CartItems WHERE cart_id = ?), 0), updated_at = GETDATE() WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlRecalc)) {
                ps.setInt(1, cartId);
                ps.setInt(2, cartId);
                ps.setInt(3, cartId);
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            System.err.println("[WishlistDAO] moveToCart SQL error: " + e.getMessage());
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) {}
            throw new RuntimeException(e);
        } finally {
            try { if (conn != null) conn.setAutoCommit(true); } catch (SQLException ignored) {}
        }
    }
}
