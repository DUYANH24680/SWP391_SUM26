package dao;

import Utils.DbContext;
import model.CartItem;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartItemDAO extends DbContext {

    public CartItem getItemByProductId(int cartId, int productId) {
        String sql = "SELECT ci.id, ci.cart_id, ci.product_id, ci.quantity, ci.unit_price, "
                   + "ci.discount_amount, ci.total_price, ci.voucher_id, v.code AS voucher_code, ci.note, ci.is_selected, "
                   + "p.shop_id AS product_shop_id, p.title AS product_title, p.image AS product_image, p.unit AS product_unit, "
                   + "ci.created_at, ci.updated_at "
                   + "FROM CartItems ci "
                   + "LEFT JOIN Vouchers v ON ci.voucher_id = v.id "
                   + "LEFT JOIN Products p ON ci.product_id = p.id "
                   + "WHERE ci.cart_id = ? AND ci.product_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, cartId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[CartItemDAO] getItemByProductId error: " + e.getMessage());
            throw new RuntimeException("CartItemDAO.getItemByProductId error: " + e.getMessage(), e);
        }
        return null;
    }

    public List<CartItem> getItemsByCartId(int cartId) {
        String sql = "SELECT ci.id, ci.cart_id, ci.product_id, ci.quantity, ci.unit_price, "
                   + "ci.discount_amount, ci.total_price, ci.voucher_id, v.code AS voucher_code, ci.note, ci.is_selected, "
                   + "p.shop_id AS product_shop_id, p.title AS product_title, p.image AS product_image, p.unit AS product_unit, "
                   + "ci.created_at, ci.updated_at "
                   + "FROM CartItems ci "
                   + "LEFT JOIN Vouchers v ON ci.voucher_id = v.id "
                   + "LEFT JOIN Products p ON ci.product_id = p.id "
                   + "WHERE ci.cart_id = ? ORDER BY ci.created_at DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, cartId);
            try (ResultSet rs = ps.executeQuery()) {
                List<CartItem> items = new ArrayList<>();
                while (rs.next()) {
                    items.add(mapRow(rs));
                }
                return items;
            }
        } catch (SQLException e) {
            System.err.println("[CartItemDAO] getItemsByCartId error: " + e.getMessage());
            throw new RuntimeException("CartItemDAO.getItemsByCartId error: " + e.getMessage(), e);
        }
    }

    public boolean insertItem(CartItem item) {
        String sql = "INSERT INTO CartItems (cart_id, product_id, quantity, unit_price, discount_amount, total_price, voucher_id, note, is_selected, created_at, updated_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
        try (PreparedStatement ps = getConnection().prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, item.getCartId());
            ps.setInt(2, item.getProductId());
            ps.setInt(3, item.getQuantity());
            ps.setDouble(4, item.getUnitPrice());
            ps.setDouble(5, item.getDiscountAmount());
            ps.setDouble(6, item.getTotalPrice());
            if (item.getVoucherId() > 0) {
                ps.setInt(7, item.getVoucherId());
            } else {
                ps.setNull(7, Types.INTEGER);
            }
            ps.setString(8, item.getNote());
            ps.setBoolean(9, item.isSelected());
            int affected = ps.executeUpdate();
            if (affected == 0) {
                return false;
            }
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    item.setId(rs.getInt(1));
                }
            }
            return true;
        } catch (SQLException e) {
            System.err.println("[CartItemDAO] insertItem error: " + e.getMessage());
            throw new RuntimeException("CartItemDAO.insertItem error: " + e.getMessage(), e);
        }
    }

    public boolean updateItem(CartItem item) {
        String sql = "UPDATE CartItems SET quantity = ?, discount_amount = ?, total_price = ?, voucher_id = ?, note = ?, updated_at = GETDATE() "
                   + "WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, item.getQuantity());
            ps.setDouble(2, item.getDiscountAmount());
            ps.setDouble(3, item.getTotalPrice());
            if (item.getVoucherId() > 0) {
                ps.setInt(4, item.getVoucherId());
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            ps.setString(5, item.getNote());
            ps.setInt(6, item.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[CartItemDAO] updateItem error: " + e.getMessage());
            throw new RuntimeException("CartItemDAO.updateItem error: " + e.getMessage(), e);
        }
    }

    public boolean deleteItemByProductId(int cartId, int productId) {
        String sql = "DELETE FROM CartItems WHERE cart_id = ? AND product_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, cartId);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[CartItemDAO] deleteItemByProductId error: " + e.getMessage());
            throw new RuntimeException("CartItemDAO.deleteItemByProductId error: " + e.getMessage(), e);
        }
    }

    public boolean deleteItemsByCartId(int cartId) {
        String sql = "DELETE FROM CartItems WHERE cart_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, cartId);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("[CartItemDAO] deleteItemsByCartId error: " + e.getMessage());
            throw new RuntimeException("CartItemDAO.deleteItemsByCartId error: " + e.getMessage(), e);
        }
    }

    public boolean updateItemSelectionByProductId(int cartId, int productId, boolean selected) {
        String sql = "UPDATE CartItems SET is_selected = ? WHERE cart_id = ? AND product_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setBoolean(1, selected);
            ps.setInt(2, cartId);
            ps.setInt(3, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[CartItemDAO] updateItemSelectionByProductId error: " + e.getMessage());
            throw new RuntimeException("CartItemDAO.updateItemSelectionByProductId error: " + e.getMessage(), e);
        }
    }

    public boolean deleteItemsByProductIds(int cartId, List<Integer> productIds) {
        if (productIds == null || productIds.isEmpty()) return true;
        StringBuilder sql = new StringBuilder("DELETE FROM CartItems WHERE cart_id = ? AND product_id IN (");
        for (int i = 0; i < productIds.size(); i++) {
            sql.append(i > 0 ? ",?" : "?");
        }
        sql.append(")");
        try (PreparedStatement ps = getConnection().prepareStatement(sql.toString())) {
            ps.setInt(1, cartId);
            for (int i = 0; i < productIds.size(); i++) {
                ps.setInt(i + 2, productIds.get(i));
            }
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("[CartItemDAO] deleteItemsByProductIds error: " + e.getMessage());
            throw new RuntimeException("CartItemDAO.deleteItemsByProductIds error: " + e.getMessage(), e);
        }
    }

    private CartItem mapRow(ResultSet rs) throws SQLException {
        CartItem item = new CartItem();
        item.setId(rs.getInt("id"));
        item.setCartId(rs.getInt("cart_id"));
        item.setProductId(rs.getInt("product_id"));
        item.setQuantity(rs.getInt("quantity"));
        item.setUnitPrice(rs.getDouble("unit_price"));
        item.setDiscountAmount(rs.getDouble("discount_amount"));
        item.setTotalPrice(rs.getDouble("total_price"));
        item.setVoucherId(rs.getInt("voucher_id"));
        item.setDiscountCode(rs.getString("voucher_code"));
        item.setNote(rs.getString("note"));
        item.setSelected(rs.getBoolean("is_selected"));
        item.setShopId(rs.getInt("product_shop_id"));
        item.setTitle(rs.getString("product_title"));
        item.setImage(rs.getString("product_image"));
        item.setUnit(rs.getString("product_unit"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        item.setUpdatedAt(rs.getTimestamp("updated_at"));
        return item;
    }
}
