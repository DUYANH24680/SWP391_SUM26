package dao;

import Utils.DbContext;
import model.Wishlist;
import model.WishlistItem;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class WishlistDAO extends DbContext {

    /**
     * Check if a product exists in user's wishlist.
     */
    public boolean exists(int customerId, int productId) {
        String sql = "SELECT 1 FROM Wishlists w WITH(NOLOCK) "
                   + "JOIN WishlistItems wi WITH(NOLOCK) ON wi.wishlist_id = w.id "
                   + "WHERE w.customer_id = ? AND wi.product_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            throw new RuntimeException("WishlistDAO.exists error: " + e.getMessage(), e);
        }
    }

    /**
     * Count items in user's wishlist.
     */
    public int getWishlistCount(int customerId) {
        String sql = "SELECT COUNT(wi.id) FROM Wishlists w WITH(NOLOCK) "
                   + "JOIN WishlistItems wi WITH(NOLOCK) ON wi.wishlist_id = w.id "
                   + "WHERE w.customer_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("WishlistDAO.getWishlistCount error: " + e.getMessage(), e);
        }
        return 0;
    }

    /**
     * Add product to wishlist.
     * Creates wishlist header if not exists, then adds the item.
     */
    public boolean addWishlist(int customerId, int productId) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            Integer wishlistId = findOrCreateWishlistId(conn, customerId);
            if (wishlistId == null) {
                conn.rollback();
                return false;
            }

            if (itemExists(conn, wishlistId, productId)) {
                conn.commit();
                return true;
            }

            String sqlInsert = "INSERT INTO WishlistItems (wishlist_id, product_id, created_at) VALUES (?, ?, GETDATE())";
            try (PreparedStatement psInsert = conn.prepareStatement(sqlInsert)) {
                psInsert.setInt(1, wishlistId);
                psInsert.setInt(2, productId);
                int rows = psInsert.executeUpdate();
                if (rows > 0) {
                    conn.commit();
                    return true;
                }
            }

            conn.rollback();
            return false;

        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            throw new RuntimeException("WishlistDAO.addWishlist error: " + e.getMessage(), e);
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ignored) {}
                try { conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    private Integer findOrCreateWishlistId(Connection conn, int customerId) throws SQLException {
        String sqlFind = "SELECT id FROM Wishlists WHERE customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlFind)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        }

        String sqlCreate = "INSERT INTO Wishlists (customer_id, created_at) VALUES (?, GETDATE())";
        try (PreparedStatement psCreate = conn.prepareStatement(sqlCreate, Statement.RETURN_GENERATED_KEYS)) {
            psCreate.setInt(1, customerId);
            int affected = psCreate.executeUpdate();
            if (affected == 0) {
                return null;
            }
            try (ResultSet rs = psCreate.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return null;
    }

    private boolean itemExists(Connection conn, int wishlistId, int productId) throws SQLException {
        String sql = "SELECT 1 FROM WishlistItems WHERE wishlist_id = ? AND product_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, wishlistId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Remove product from wishlist.
     */
    public boolean removeWishlist(int customerId, int productId) {
        String sql = "DELETE FROM WishlistItems "
                   + "WHERE wishlist_id IN (SELECT id FROM Wishlists WHERE customer_id = ?) "
                   + "AND product_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("WishlistDAO.removeWishlist error: " + e.getMessage(), e);
        }
    }

    /**
     * Get wishlist with all items for a customer.
     */
    public Wishlist getWishlistByUser(int customerId) {
        String sqlHeader = "SELECT id, customer_id, created_at FROM Wishlists WITH(NOLOCK) WHERE customer_id = ?";
        Connection conn = null;
        try {
            conn = getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sqlHeader)) {
                ps.setInt(1, customerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Wishlist w = new Wishlist();
                        int wishlistId = rs.getInt("id");
                        w.setId(wishlistId);
                        w.setCustomerId(rs.getInt("customer_id"));
                        w.setCreatedAt(rs.getTimestamp("created_at"));
                        w.setItems(getItemsByWishlistId(conn, wishlistId));
                        return w;
                    }
                }
            }
            return new Wishlist();
        } catch (SQLException e) {
            throw new RuntimeException("WishlistDAO.getWishlistByUser error: " + e.getMessage(), e);
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    }

    /**
     * Get items in a wishlist with product details.
     * Uses existing connection from parent transaction.
     */
    public List<WishlistItem> getItemsByWishlistId(Connection parentConn, int wishlistId) {
        String sql = "SELECT wi.id, wi.wishlist_id, wi.product_id, wi.created_at, "
                   + "p.shop_id AS product_shop_id, p.title AS product_title, p.image AS product_image, "
                   + "p.unit AS product_unit, p.stock_quantity, p.sale_price, p.original_price, p.status AS product_status, p.isDelete AS product_deleted "
                   + "FROM WishlistItems wi WITH(NOLOCK) "
                   + "LEFT JOIN Products p WITH(NOLOCK) ON wi.product_id = p.id "
                   + "WHERE wi.wishlist_id = ? ORDER BY wi.created_at DESC";
        try (PreparedStatement ps = parentConn.prepareStatement(sql)) {
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
            throw new RuntimeException("WishlistDAO.getItemsByWishlistId error: " + e.getMessage(), e);
        }
    }

    /**
     * Get items in a wishlist with product details (standalone, own connection).
     */
    public List<WishlistItem> getItemsByWishlistId(int wishlistId) {
        String sql = "SELECT wi.id, wi.wishlist_id, wi.product_id, wi.created_at, "
                   + "p.shop_id AS product_shop_id, p.title AS product_title, p.image AS product_image, "
                   + "p.unit AS product_unit, p.stock_quantity, p.sale_price, p.original_price, p.status AS product_status, p.isDelete AS product_deleted "
                   + "FROM WishlistItems wi WITH(NOLOCK) "
                   + "LEFT JOIN Products p WITH(NOLOCK) ON wi.product_id = p.id "
                   + "WHERE wi.wishlist_id = ? ORDER BY wi.created_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
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
            throw new RuntimeException("WishlistDAO.getItemsByWishlistId error: " + e.getMessage(), e);
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
     */
    public boolean moveToCart(int customerId, int productId) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

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
                return false;
            }

            // Security: verify ownership
            String sqlCheckOwnership = "SELECT 1 FROM WishlistItems WHERE wishlist_id = ? AND product_id = ?";
            boolean ownsItem = false;
            try (PreparedStatement psCheck = conn.prepareStatement(sqlCheckOwnership)) {
                psCheck.setInt(1, wishlistId);
                psCheck.setInt(2, productId);
                try (ResultSet rsCheck = psCheck.executeQuery()) {
                    ownsItem = rsCheck.next();
                }
            }
            if (!ownsItem) {
                conn.commit();
                return false;
            }

            String sqlProduct = "SELECT stock_quantity, sale_price, original_price, status, isDelete FROM Products WITH(NOLOCK) WHERE id = ?";
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
                    active = rs.getInt("status") == 1;
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

            Integer existingItemId = null;
            int existingQuantity = 0;
            String sqlCheckItem = "SELECT id, quantity FROM CartItems WITH(NOLOCK) WHERE cart_id = ? AND product_id = ? AND (size IS NULL OR size = '')";
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

            String sqlDeleteWishlistItem = "DELETE FROM WishlistItems WHERE wishlist_id = ? AND product_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlDeleteWishlistItem)) {
                ps.setInt(1, wishlistId);
                ps.setInt(2, productId);
                ps.executeUpdate();
            }

            String sqlRecalc = "UPDATE Carts SET total_items = ISNULL((SELECT SUM(quantity) FROM CartItems WHERE cart_id = ?), 0), "
                             + "total_amount = ISNULL((SELECT SUM(total_price) FROM CartItems WHERE cart_id = ?), 0), "
                             + "updated_at = GETDATE() WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlRecalc)) {
                ps.setInt(1, cartId);
                ps.setInt(2, cartId);
                ps.setInt(3, cartId);
                ps.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) {}
            throw new RuntimeException("WishlistDAO.moveToCart error: " + e.getMessage(), e);
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ignored) {}
                try { conn.close(); } catch (SQLException ignored) {}
            }
        }
    }
}
