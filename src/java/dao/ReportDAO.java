package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Report;
import Utils.DbContext;

public class ReportDAO extends DbContext {

    // DuyAnhNgo- Lệnh lưu báo cáo: Chèn 1 dòng vào bảng Reports với trạng thái mặc định là PENDING (chờ duyệt)
    public boolean createReport(int customerId, int productId, String reason) {
        String sql = "INSERT INTO Reports (customer_id, product_id, reason, status) VALUES (?, ?, ?, 'PENDING')";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, productId);
            ps.setString(3, reason);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // DuyAnhNgo- Lấy danh sách chờ xử lý: Admin dùng hàm này để xem toàn bộ các đơn tố cáo có status = 'PENDING'
    public List<Report> getPendingReports() {
        List<Report> list = new ArrayList<>();
        // Gom dữ liệu từ 4 bảng: Reports, Accounts (Khách hàng), Products (Sản phẩm) và Shops (Người bán) để hiển thị chi tiết
        String sql = "SELECT r.*, a.fullname as customerName, p.title as productName, s.owner_id as sellerId " +
                     "FROM Reports r " +
                     "JOIN Accounts a ON r.customer_id = a.id " +
                     "JOIN Products p ON r.product_id = p.id " +
                     "JOIN Shops s ON p.shop_id = s.id " +
                     "WHERE r.status = 'PENDING' ORDER BY r.created_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Report r = new Report();
                r.setId(rs.getInt("id"));
                r.setCustomerId(rs.getInt("customer_id"));
                r.setProductId(rs.getInt("product_id"));
                r.setReason(rs.getString("reason"));
                r.setStatus(rs.getString("status"));
                r.setCreatedAt(rs.getTimestamp("created_at"));
                r.setCustomerName(rs.getString("customerName"));
                r.setProductName(rs.getString("productName"));
                r.setSellerId(rs.getInt("sellerId"));
                list.add(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // DuyAnhNgo- Chấp thuận báo cáo: Update trạng thái thành CONFIRMED
    public boolean confirmReport(int reportId) {
        String sql = "UPDATE Reports SET status = 'CONFIRMED' WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reportId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // DuyAnhNgo- Bác bỏ báo cáo: Update trạng thái thành REJECTED (Xóa bỏ khiếu nại không hợp lệ)
    public boolean rejectReport(int reportId) {
        String sql = "UPDATE Reports SET status = 'REJECTED' WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reportId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // DuyAnhNgo- Lấy chi tiết 1 đơn tố cáo: Hàm này được gọi khi Admin cần lấy thông tin chính xác của 1 đơn cụ thể (ví dụ khi bấm nút Xác nhận)
    // Dữ liệu trả về được trộn (JOIN) từ bảng Reports, tài khoản Khách (Accounts a), tên Sản phẩm (Products p) và ID của người Bán (Shops s)
    public Report getReportById(int id) {
        String sql = "SELECT r.*, a.fullname as customerName, p.title as productName, s.owner_id as sellerId " +
                     "FROM Reports r " +
                     "JOIN Accounts a ON r.customer_id = a.id " +
                     "JOIN Products p ON r.product_id = p.id " +
                     "JOIN Shops s ON p.shop_id = s.id " +
                     "WHERE r.id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Report r = new Report();
                    r.setId(rs.getInt("id"));
                    r.setCustomerId(rs.getInt("customer_id"));
                    r.setProductId(rs.getInt("product_id"));
                    r.setReason(rs.getString("reason"));
                    r.setStatus(rs.getString("status"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    r.setCustomerName(rs.getString("customerName"));
                    r.setProductName(rs.getString("productName"));
                    r.setSellerId(rs.getInt("sellerId"));
                    return r;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // DuyAnhNgo- Lấy danh sách sản phẩm đã mua: Dùng để thả vào menu xổ xuống (dropdown) khi Khách hàng muốn tố cáo.
    // Lệnh SQL kết nối bảng Đơn hàng (Orders), Chi tiết Đơn hàng (OrderDetails) và Sản phẩm (Products) để rút ra các món mà người này từng đặt mua.
    public List<model.Product> getPurchasedProducts(int customerId) {
        List<model.Product> list = new ArrayList<>();
        String sql = "SELECT DISTINCT p.id, p.title as name " +
                     "FROM OrderDetails od " +
                     "JOIN Orders o ON od.order_id = o.id " +
                     "JOIN Products p ON od.product_id = p.id " +
                     "WHERE o.customer_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    model.Product p = new model.Product();
                    p.setId(rs.getInt("id"));
                    p.setTitle(rs.getString("name"));
                    list.add(p);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
