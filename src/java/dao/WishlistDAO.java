package dao;

import model.Product;
import model.Wishlist;
import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class WishlistDAO extends DbContext {

    private ProductDAO productDAO;

    public WishlistDAO() {
        super();
        this.productDAO = new ProductDAO();
    }

    // 1. Get all Wishlist Items for a Customer
    public List<Wishlist> getWishlistByCustomerId(int customerId) {
        List<Wishlist> list = new ArrayList<>();
        String sql = "SELECT wishlist_id, customer_id, product_id, added_at FROM Wishlist WHERE customer_id = ? ORDER BY added_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Wishlist w = new Wishlist();
                    w.setId(rs.getInt("wishlist_id"));
                    w.setCustomerId(rs.getInt("customer_id"));
                    w.setAddedAt(rs.getTimestamp("added_at"));
                    
                    // Fetch Product details
                    Product product = productDAO.getProductById(rs.getInt("product_id"));
                    w.setProduct(product);
                    
                    list.add(w);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Check if product is already in wishlist
    public boolean isProductInWishlist(int customerId, int productId) {
        String sql = "SELECT 1 FROM Wishlist WHERE customer_id = ? AND product_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 3. Add to Wishlist
    public boolean addToWishlist(int customerId, int productId) {
        if (isProductInWishlist(customerId, productId)) {
            return false; // Already in wishlist
        }
        String sql = "INSERT INTO Wishlist (customer_id, product_id, added_at) VALUES (?, ?, GETDATE())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 4. Remove from Wishlist
    public boolean removeFromWishlist(int customerId, int productId) {
        String sql = "DELETE FROM Wishlist WHERE customer_id = ? AND product_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
