package dao;

import model.UserReport;
import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * UserReportDAO - Handles all DB operations for UserReports table.
 */
public class UserReportDAO extends DbContext {

    /**
     * DuyAnhNgo- Hàm lưu Báo cáo Cửa hàng (Shop): Khách hàng tố cáo chủ shop (scam, hàng giả...)
     * Lưu vào bảng UserReports. Trạng thái mặc định là 0 (Đang chờ xử lý).
     */
    public int insert(UserReport report) {
        String sql = "INSERT INTO UserReports "
                   + "(reporter_id, reported_shop_id, order_id, report_type, description, evidence_url, status, priority) "
                   + "VALUES (?, ?, ?, ?, ?, ?, 0, ?)";
        try (PreparedStatement ps = getConnection().prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, report.getReporterId());
            ps.setInt(2, report.getReportedShopId());
            if (report.getOrderId() != null) ps.setInt(3, report.getOrderId());
            else ps.setNull(3, Types.INTEGER);
            ps.setString(4, report.getReportType());
            ps.setString(5, report.getDescription());
            ps.setString(6, report.getEvidenceUrl());
            ps.setInt(7, report.getPriority() > 0 ? report.getPriority() : 2);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserReportDAO] insert error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("UserReportDAO.insert error: " + e.getMessage(), e);
        }
        return -1;
    }

    /**
     * DuyAnhNgo- Hàm kiểm tra trùng lặp: Ngăn không cho 1 khách hàng spam báo cáo cùng 1 cửa hàng nhiều lần khi đơn trước đó vẫn đang chờ xử lý (status = 0).
     */
    public boolean hasPendingReport(int reporterId, int shopId) {
        String sql = "SELECT COUNT(1) FROM UserReports WHERE reporter_id = ? AND reported_shop_id = ? AND status = 0";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, reporterId);
            ps.setInt(2, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("[UserReportDAO] hasPendingReport error: " + e.getMessage());
        }
        return false;
    }

    /**
     * DuyAnhNgo- Hàm lấy danh sách báo cáo (Cho Admin): Lấy toàn bộ hoặc lọc theo trạng thái (chờ xử lý, đã duyệt, từ chối).
     */
    public List<UserReport> getAll(String statusFilter) {
        List<UserReport> list = new ArrayList<>();
        String sql = buildSelectSql() + buildWhereSql(statusFilter) + " ORDER BY r.created_at DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            applyFilter(ps, statusFilter);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[UserReportDAO] getAll error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("UserReportDAO.getAll error: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * DuyAnhNgo- Lấy danh sách báo cáo của 1 Shop cụ thể: Admin dùng để xem "tiền án tiền sự" của 1 cửa hàng.
     */
    public List<UserReport> getByShopId(int shopId, String statusFilter) {
        List<UserReport> list = new ArrayList<>();
        String sql = buildSelectSql() + " WHERE r.reported_shop_id = ?"
                   + buildWhereSql(statusFilter).replace("WHERE", "AND")
                   + " ORDER BY r.created_at DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            applyFilterSkipFirst(ps, statusFilter);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[UserReportDAO] getByShopId error: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get pending report count for a shop.
     */
    public int countPendingByShopId(int shopId) {
        String sql = "SELECT COUNT(1) FROM UserReports WHERE reported_shop_id = ? AND status = 0";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[UserReportDAO] countPendingByShopId error: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Find by id.
     */
    public UserReport findById(int id) {
        String sql = buildSelectSql() + " WHERE r.id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[UserReportDAO] findById error: " + e.getMessage());
        }
        return null;
    }

    /**
     * Update status + admin note (resolve / dismiss / review).
     */
    public boolean updateStatus(int reportId, int status, String adminNote, Integer resolvedBy) {
        String sql = "UPDATE UserReports "
                   + "SET status = ?, admin_note = ?, resolved_by = ?, resolved_at = GETDATE() "
                   + "WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setString(2, adminNote);
            if (resolvedBy != null) ps.setInt(3, resolvedBy);
            else ps.setNull(3, Types.INTEGER);
            ps.setInt(4, reportId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UserReportDAO] updateStatus error: " + e.getMessage());
            throw new RuntimeException("UserReportDAO.updateStatus error: " + e.getMessage(), e);
        }
    }

    // ---- helpers ----
    private String buildSelectSql() {
        return "SELECT r.id, r.reporter_id, r.reported_shop_id, r.order_id, r.report_type, "
             + "       r.description, r.evidence_url, r.status, r.priority, "
             + "       r.admin_note, r.resolved_by, r.resolved_at, r.created_at, "
             + "       rep.fullname AS reporter_fullname, rep.email AS reporter_email, "
             + "       s.shop_name, a.fullname AS shop_owner_name, "
             + "       ad.fullname AS resolved_by_name "
             + "FROM UserReports r "
             + "JOIN Accounts rep ON r.reporter_id = rep.id "
             + "JOIN Shops s ON r.reported_shop_id = s.id "
             + "JOIN Accounts a ON s.owner_id = a.id "
             + "LEFT JOIN Accounts ad ON r.resolved_by = ad.id ";
    }

    private String buildWhereSql(String statusFilter) {
        if (statusFilter == null || statusFilter.isEmpty() || "all".equals(statusFilter)) {
            return "";
        }
        switch (statusFilter) {
            case "pending":   return " WHERE r.status = 0";
            case "reviewed":  return " WHERE r.status = 1";
            case "resolved":  return " WHERE r.status = 2";
            case "dismissed": return " WHERE r.status = 3";
            default:          return "";
        }
    }

    private void applyFilter(PreparedStatement ps, String statusFilter) throws SQLException {
        // no positional filter needed for "all"
    }

    private void applyFilterSkipFirst(PreparedStatement ps, String statusFilter) throws SQLException {
        applyFilter(ps, statusFilter);
    }

    private UserReport mapRow(ResultSet rs) throws SQLException {
        UserReport r = new UserReport();
        r.setId(rs.getInt("id"));
        r.setReporterId(rs.getInt("reporter_id"));
        r.setReportedShopId(rs.getInt("reported_shop_id"));
        int orderId = rs.getInt("order_id");
        r.setOrderId(rs.wasNull() ? null : orderId);
        r.setReportType(rs.getString("report_type"));
        r.setDescription(rs.getString("description"));
        r.setEvidenceUrl(rs.getString("evidence_url"));
        r.setStatus(rs.getInt("status"));
        r.setPriority(rs.getInt("priority"));
        r.setAdminNote(rs.getString("admin_note"));
        int resolvedBy = rs.getInt("resolved_by");
        r.setResolvedBy(rs.wasNull() ? null : resolvedBy);
        r.setResolvedAt(rs.getTimestamp("resolved_at"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setReporterFullname(rs.getString("reporter_fullname"));
        r.setReporterEmail(rs.getString("reporter_email"));
        r.setShopName(rs.getString("shop_name"));
        r.setShopOwnerName(rs.getString("shop_owner_name"));
        r.setResolvedByName(rs.getString("resolved_by_name"));
        return r;
    }
}
