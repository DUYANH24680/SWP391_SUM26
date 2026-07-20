package dao;

import Utils.DbContext;
import model.ShipperDetails;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * ShipperDetailsDAO - Xử lý các thao tác CRUD với bảng ShipperDetails.
 */
public class ShipperDetailsDAO extends DbContext {

    /**
     * Thêm thông tin chi tiết cho shipper mới.
     */
    public boolean addShipperDetails(int accountId, String shipperCode, Date birthdate, String cccd, 
                                     String vehicleType, String deliveryArea) {
        String sql = "INSERT INTO ShipperDetails (account_id, shipper_code, birthdate, cccd, vehicle_type, delivery_area) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setString(2, shipperCode);
            ps.setDate(3, birthdate);
            ps.setString(4, cccd);
            ps.setString(5, vehicleType);
            ps.setString(6, deliveryArea);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[ShipperDetailsDAO] addShipperDetails error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Lỗi thêm thông tin shipper: " + e.getMessage(), e);
        }
    }

    /**
     * Lấy thông tin chi tiết của shipper theo accountId.
     */
    public ShipperDetails getByAccountId(int accountId) {
        String sql = "SELECT id, account_id, shipper_code, birthdate, cccd, vehicle_type, delivery_area, created_at, updated_at "
                   + "FROM ShipperDetails WHERE account_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ShipperDetailsDAO] getByAccountId error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy thông tin chi tiết của shipper theo shipperCode.
     */
    public ShipperDetails getByShipperCode(String shipperCode) {
        String sql = "SELECT id, account_id, shipper_code, birthdate, cccd, vehicle_type, delivery_area, created_at, updated_at "
                   + "FROM ShipperDetails WHERE shipper_code = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, shipperCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ShipperDetailsDAO] getByShipperCode error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Cập nhật thông tin chi tiết của shipper.
     */
    public boolean updateShipperDetails(int accountId, String shipperCode, Date birthdate, String cccd,
                                        String vehicleType, String deliveryArea) {
        String sql = "UPDATE ShipperDetails SET shipper_code = ?, birthdate = ?, cccd = ?, vehicle_type = ?, "
                   + "delivery_area = ?, updated_at = GETDATE() WHERE account_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, shipperCode);
            ps.setDate(2, birthdate);
            ps.setString(3, cccd);
            ps.setString(4, vehicleType);
            ps.setString(5, deliveryArea);
            ps.setInt(6, accountId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[ShipperDetailsDAO] updateShipperDetails error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Lỗi cập nhật thông tin shipper: " + e.getMessage(), e);
        }
    }

    /**
     * Kiểm tra shipper_code đã tồn tại chưa (trừ account hiện tại).
     */
    public boolean isShipperCodeTaken(String shipperCode, int excludeAccountId) {
        String sql = "SELECT COUNT(1) FROM ShipperDetails WHERE shipper_code = ? AND account_id <> ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, shipperCode);
            ps.setInt(2, excludeAccountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("[ShipperDetailsDAO] isShipperCodeTaken error: " + e.getMessage());
        }
        return false;
    }

    /**
     * Kiểm tra shipper_code đã tồn tại chưa (cho thêm mới).
     */
    public boolean isShipperCodeExists(String shipperCode) {
        String sql = "SELECT COUNT(1) FROM ShipperDetails WHERE shipper_code = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, shipperCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("[ShipperDetailsDAO] isShipperCodeExists error: " + e.getMessage());
        }
        return false;
    }

    /**
     * Kiểm tra CCCD đã tồn tại chưa (trừ account hiện tại).
     */
    public boolean isCccdTaken(String cccd, int excludeAccountId) {
        String sql = "SELECT COUNT(1) FROM ShipperDetails WHERE cccd = ? AND account_id <> ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, cccd);
            ps.setInt(2, excludeAccountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("[ShipperDetailsDAO] isCccdTaken error: " + e.getMessage());
        }
        return false;
    }

    /**
     * Kiểm tra CCCD đã tồn tại chưa (cho thêm mới).
     */
    public boolean isCccdExists(String cccd) {
        String sql = "SELECT COUNT(1) FROM ShipperDetails WHERE cccd = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, cccd);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("[ShipperDetailsDAO] isCccdExists error: " + e.getMessage());
        }
        return false;
    }

    /**
     * Kiểm tra CCCD đã tồn tại trong bảng StaffDetails không.
     */
    public boolean isCccdExistsInStaffDetails(String cccd) {
        String sql = "SELECT COUNT(1) FROM StaffDetails WHERE cccd = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, cccd);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("[ShipperDetailsDAO] isCccdExistsInStaffDetails error: " + e.getMessage());
        }
        return false;
    }

    /**
     * Xóa thông tin chi tiết của shipper (khi xóa tài khoản).
     */
    public boolean deleteByAccountId(int accountId) {
        String sql = "DELETE FROM ShipperDetails WHERE account_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, accountId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[ShipperDetailsDAO] deleteByAccountId error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách tất cả shipper details.
     */
    public List<ShipperDetails> getAll() {
        List<ShipperDetails> list = new ArrayList<>();
        String sql = "SELECT id, account_id, shipper_code, birthdate, cccd, vehicle_type, delivery_area, created_at, updated_at "
                   + "FROM ShipperDetails ORDER BY created_at DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[ShipperDetailsDAO] getAll error: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Map ResultSet row to ShipperDetails object.
     */
    private ShipperDetails mapRow(ResultSet rs) throws SQLException {
        ShipperDetails sd = new ShipperDetails();
        sd.setId(rs.getInt("id"));
        sd.setAccountId(rs.getInt("account_id"));
        sd.setShipperCode(rs.getString("shipper_code"));
        sd.setBirthdate(rs.getDate("birthdate"));
        sd.setCccd(rs.getString("cccd"));
        sd.setVehicleType(rs.getString("vehicle_type"));
        sd.setDeliveryArea(rs.getString("delivery_area"));
        sd.setCreatedAt(rs.getDate("created_at"));
        sd.setUpdatedAt(rs.getDate("updated_at"));
        return sd;
    }
}
