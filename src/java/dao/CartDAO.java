package dao;

import Utils.DbContext;
import model.Cart;
import model.CartItem;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDAO extends DbContext {

    public Cart getCartByCustomerId(int customerId) {
        String sql = "SELECT id, customer_id, total_items, total_amount, created_at, updated_at "
                   + "FROM Carts WHERE customer_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Cart cart = new Cart();
                    cart.setId(rs.getInt("id"));
                    cart.setCustomerId(rs.getInt("customer_id"));
                    cart.setTotalItems(rs.getInt("total_items"));
                    cart.setTotalAmount(rs.getDouble("total_amount"));
                    cart.setCreatedAt(rs.getTimestamp("created_at"));
                    cart.setUpdatedAt(rs.getTimestamp("updated_at"));
                    CartItemDAO itemDAO = new CartItemDAO();
                    try {
                        cart.setItems(itemDAO.getItemsByCartId(cart.getId()));
                    } finally {
                        itemDAO.close();
                    }
                    return cart;
                }
            }
        } catch (SQLException e) {
            System.err.println("[CartDAO] getCartByCustomerId error: " + e.getMessage());
            throw new RuntimeException("CartDAO.getCartByCustomerId error: " + e.getMessage(), e);
        }
        return null;
    }

    public int getOrCreateCartId(int customerId) {
        Cart cart = getCartByCustomerId(customerId);
        if (cart != null) {
            return cart.getId();
        }

        String sql = "INSERT INTO Carts (customer_id, total_items, total_amount, created_at, updated_at) "
                   + "VALUES (?, 0, 0, GETDATE(), GETDATE())";
        try (PreparedStatement ps = getConnection().prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, customerId);
            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new RuntimeException("Failed to create cart for customer " + customerId);
            }
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("[CartDAO] getOrCreateCartId error: " + e.getMessage());
            throw new RuntimeException("CartDAO.getOrCreateCartId error: " + e.getMessage(), e);
        }
        throw new RuntimeException("Cart ID was not generated for customer " + customerId);
    }

    public boolean updateCartTotals(int cartId, int totalItems, double totalAmount) {
        String sql = "UPDATE Carts SET total_items = ?, total_amount = ?, updated_at = GETDATE() WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, totalItems);
            ps.setDouble(2, totalAmount);
            ps.setInt(3, cartId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[CartDAO] updateCartTotals error: " + e.getMessage());
            throw new RuntimeException("CartDAO.updateCartTotals error: " + e.getMessage(), e);
        }
    }

    public boolean recalculateCartTotals(int cartId) {
        String sql = "UPDATE Carts SET "
                   + "total_items = ISNULL((SELECT SUM(quantity) FROM CartItems WHERE cart_id = ?), 0), "
                   + "total_amount = ISNULL((SELECT SUM(total_price) FROM CartItems WHERE cart_id = ?), 0), "
                   + "updated_at = GETDATE() "
                   + "WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, cartId);
            ps.setInt(2, cartId);
            ps.setInt(3, cartId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[CartDAO] recalculateCartTotals error: " + e.getMessage());
            throw new RuntimeException("CartDAO.recalculateCartTotals error: " + e.getMessage(), e);
        }
    }
}

