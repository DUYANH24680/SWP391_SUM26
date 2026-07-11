package dao;

import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.ProductReview;

public class ProductReviewDAO extends DbContext {

    public List<ProductReview> getReviewsByProductId(int productId) {
        List<ProductReview> list = new ArrayList<>();
        String sql = "SELECT r.*, a.username, a.fullname, a.avatar " +
                     "FROM ProductReviews r " +
                     "JOIN Accounts a ON r.account_id = a.id " +
                     "WHERE r.product_id = ? " +
                     "ORDER BY r.created_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, productId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    ProductReview pr = new ProductReview();
                    pr.setId(rs.getInt("id"));
                    pr.setProductId(rs.getInt("product_id"));
                    pr.setAccountId(rs.getInt("account_id"));
                    pr.setRating(rs.getInt("rating"));
                    pr.setComment(rs.getString("comment"));
                    pr.setCreatedAt(rs.getTimestamp("created_at"));
                    pr.setUsername(rs.getString("username"));
                    pr.setFullname(rs.getString("fullname"));
                    pr.setAvatar(rs.getString("avatar"));
                    list.add(pr);
                }
            }
        } catch (SQLException e) {
            System.err.println("getReviewsByProductId error: " + e.getMessage());
        }
        return list;
    }

    public boolean addReview(int productId, int accountId, int rating, String comment) {
        String sql = "INSERT INTO ProductReviews (product_id, account_id, rating, comment) VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, productId);
            st.setInt(2, accountId);
            st.setInt(3, rating);
            st.setString(4, comment);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("addReview error: " + e.getMessage());
        }
        return false;
    }

    public Map<String, Object> getRatingSummary(int productId) {
        Map<String, Object> map = new HashMap<>();
        map.put("total", 0);
        map.put("avg", 0.0);
        map.put("star5", 0);
        map.put("star4", 0);
        map.put("star3", 0);
        map.put("star2", 0);
        map.put("star1", 0);

        String sql = "SELECT rating, COUNT(*) as count FROM ProductReviews WHERE product_id = ? GROUP BY rating";
        try (Connection conn = getConnection();
             PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, productId);
            try (ResultSet rs = st.executeQuery()) {
                int total = 0;
                long sum = 0;
                while (rs.next()) {
                    int rating = rs.getInt("rating");
                    int count = rs.getInt("count");
                    total += count;
                    sum += rating * count;
                    map.put("star" + rating, count);
                }
                map.put("total", total);
                if (total > 0) {
                    map.put("avg", (double) sum / total);
                }
            }
        } catch (SQLException e) {
            System.err.println("getRatingSummary error: " + e.getMessage());
        }
        return map;
    }

    public void updateProductAverageRating(int productId) {
        Map<String, Object> summary = getRatingSummary(productId);
        double avg = (double) summary.get("avg");
        
        String sql = "UPDATE Products SET average_rating = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement st = conn.prepareStatement(sql)) {
            st.setDouble(1, avg);
            st.setInt(2, productId);
            st.executeUpdate();
        } catch (SQLException e) {
            System.err.println("updateProductAverageRating error: " + e.getMessage());
        }
    }

    public void close() {
    }
}
