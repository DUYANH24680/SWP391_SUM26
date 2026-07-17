package dao;

import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.ProductReview;

public class ProductReviewDAO extends DbContext {

    // DuyAnhNgo- Hàm Lấy Bình Luận: Dùng lệnh JOIN để lấy nội dung bình luận (từ ProductReviews) kèm theo tên và avatar người dùng (từ Accounts)
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

    // DuyAnhNgo- Hàm Thêm Bình Luận Mới: Lưu số sao (rating) và nội dung (comment) vào Database
    public boolean addReview(int productId, int accountId, int rating, String comment) {
        String sql = "INSERT INTO ProductReviews (product_id, account_id, rating, comment) VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement st = conn.prepareStatement(sql)) {
            // DuyAnhNgo- Nhét ID sản phẩm vào dấu ? thứ 1
            st.setInt(1, productId);
            // DuyAnhNgo- Nhét ID người dùng vào dấu ? thứ 2
            st.setInt(2, accountId);
            // DuyAnhNgo- Nhét Số sao đánh giá vào dấu ? thứ 3
            st.setInt(3, rating);
            // DuyAnhNgo- Nhét Nội dung bình luận vào dấu ? thứ 4
            st.setString(4, comment);
            // DuyAnhNgo- Chạy lệnh INSERT để ghi xuống CSDL
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("addReview error: " + e.getMessage());
        }
        return false;
    }

    // DuyAnhNgo- Hàm Thống Kê Số Sao: Trả về một đối tượng Map chứa Tổng số bình luận, Điểm trung bình, và số lượng từng loại sao (5 sao có mấy người, 4 sao có mấy người...)
    public Map<String, Object> getRatingSummary(int productId) {
        Map<String, Object> map = new HashMap<>();
        map.put("total", 0);
        map.put("avg", 0.0);
        map.put("star5", 0);
        map.put("star4", 0);
        map.put("star3", 0);
        map.put("star2", 0);
        map.put("star1", 0);

        // DuyAnhNgo- Câu SQL dùng GROUP BY rating để gom nhóm và đếm số lượng (Ví dụ: đếm xem có bao nhiêu đánh giá 5 sao)
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

    // DuyAnhNgo- Hàm Cập Nhật Điểm Trung Bình: Lấy điểm trung bình mới tính được ở hàm trên để UPDATE thẳng vào cột average_rating của bảng Products
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

    /**
     * DuyAnhNgo- Kiểm tra xem account đã từng mua (và đơn hàng đã giao thành công) sản phẩm này chưa.
     * Chỉ cho phép bình luận khi có ít nhất 1 đơn hàng với status = 4 (Đã giao) chứa sản phẩm đó.
     */
    public boolean hasPurchasedProduct(int accountId, int productId) {
        String sql = "SELECT COUNT(*) FROM Orders o "
                   + "JOIN OrderDetails od ON o.id = od.order_id "
                   + "WHERE o.customer_id = ? AND od.product_id = ? AND o.status = 4";
        try (Connection conn = getConnection();
             PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, accountId);
            st.setInt(2, productId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("hasPurchasedProduct error: " + e.getMessage());
        }
        return false;
    }

    public void close() {
    }
}
