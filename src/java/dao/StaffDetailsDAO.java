package dao;

import Utils.DbContext;
import model.StaffDetails;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * StaffDetailsDAO - Xử lý các thao tác CRUD với bảng StaffDetails.
 */
public class StaffDetailsDAO extends DbContext {

    /**
     * Thêm thông tin chi tiết cho nhân viên mới.
     */
    public boolean addStaffDetails(int accountId, String staffCode, String cccd, String managedArea) {
        String sql = "INSERT INTO StaffDetails (account_id, staff_code, cccd, managed_area) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setString(2, staffCode);
            ps.setString(3, cccd);
            ps.setString(4, managedArea);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[StaffDetailsDAO] addStaffDetails error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Lỗi thêm thông tin nhân viên: " + e.getMessage(), e);
        }
    }

    /**
     * Lấy thông tin chi tiết của nhân viên theo accountId.
     */
    public StaffDetails getByAccountId(int accountId) {
        String sql = "SELECT id, account_id, staff_code, cccd, managed_area, created_at, updated_at "
                   + "FROM StaffDetails WHERE account_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[StaffDetailsDAO] getByAccountId error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy thông tin chi tiết của nhân viên theo staffCode.
     */
    public StaffDetails getByStaffCode(String staffCode) {
        String sql = "SELECT id, account_id, staff_code, cccd, managed_area, created_at, updated_at "
                   + "FROM StaffDetails WHERE staff_code = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, staffCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[StaffDetailsDAO] getByStaffCode error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Cập nhật thông tin chi tiết của nhân viên.
     */
    public boolean updateStaffDetails(int accountId, String staffCode, String cccd, String managedArea) {
        String sql = "UPDATE StaffDetails SET staff_code = ?, cccd = ?, managed_area = ?, updated_at = GETDATE() WHERE account_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, staffCode);
            ps.setString(2, cccd);
            ps.setString(3, managedArea);
            ps.setInt(4, accountId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[StaffDetailsDAO] updateStaffDetails error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Lỗi cập nhật thông tin nhân viên: " + e.getMessage(), e);
        }
    }

    /**
     * Kiểm tra staff_code đã tồn tại chưa (trừ account hiện tại).
     */
    public boolean isStaffCodeTaken(String staffCode, int excludeAccountId) {
        String sql = "SELECT COUNT(1) FROM StaffDetails WHERE staff_code = ? AND account_id <> ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, staffCode);
            ps.setInt(2, excludeAccountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("[StaffDetailsDAO] isStaffCodeTaken error: " + e.getMessage());
        }
        return false;
    }

    /**
     * Kiểm tra staff_code đã tồn tại chưa (cho thêm mới).
     */
    public boolean isStaffCodeExists(String staffCode) {
        String sql = "SELECT COUNT(1) FROM StaffDetails WHERE staff_code = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, staffCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("[StaffDetailsDAO] isStaffCodeExists error: " + e.getMessage());
        }
        return false;
    }

    /**
     * Kiểm tra CCCD đã tồn tại chưa (trừ account hiện tại).
     */
    public boolean isCccdTaken(String cccd, int excludeAccountId) {
        String sql = "SELECT COUNT(1) FROM StaffDetails WHERE cccd = ? AND account_id <> ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, cccd);
            ps.setInt(2, excludeAccountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("[StaffDetailsDAO] isCccdTaken error: " + e.getMessage());
        }
        return false;
    }

    /**
     * Kiểm tra CCCD đã tồn tại chưa (cho thêm mới).
     */
    public boolean isCccdExists(String cccd) {
        String sql = "SELECT COUNT(1) FROM StaffDetails WHERE cccd = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, cccd);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("[StaffDetailsDAO] isCccdExists error: " + e.getMessage());
        }
        return false;
    }

    /**
     * Kiểm tra CCCD đã tồn tại trong bảng ShipperDetails không.
     */
    public boolean isCccdExistsInShipperDetails(String cccd) {
        String sql = "SELECT COUNT(1) FROM ShipperDetails WHERE cccd = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, cccd);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("[StaffDetailsDAO] isCccdExistsInShipperDetails error: " + e.getMessage());
        }
        return false;
    }

    /**
     * Xóa thông tin chi tiết của nhân viên (khi xóa tài khoản).
     */
    public boolean deleteByAccountId(int accountId) {
        String sql = "DELETE FROM StaffDetails WHERE account_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, accountId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[StaffDetailsDAO] deleteByAccountId error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách tất cả staff details.
     */
    public List<StaffDetails> getAll() {
        List<StaffDetails> list = new ArrayList<>();
        String sql = "SELECT id, account_id, staff_code, cccd, managed_area, created_at, updated_at "
                   + "FROM StaffDetails ORDER BY created_at DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[StaffDetailsDAO] getAll error: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Map ResultSet row to StaffDetails object.
     */
    private StaffDetails mapRow(ResultSet rs) throws SQLException {
        StaffDetails sd = new StaffDetails();
        sd.setId(rs.getInt("id"));
        sd.setAccountId(rs.getInt("account_id"));
        sd.setStaffCode(rs.getString("staff_code"));
        sd.setCccd(rs.getString("cccd"));
        sd.setManagedArea(rs.getString("managed_area"));
        sd.setCreatedAt(rs.getDate("created_at"));
        sd.setUpdatedAt(rs.getDate("updated_at"));
        return sd;
    }
}
