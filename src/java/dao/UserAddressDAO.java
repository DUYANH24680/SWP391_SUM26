package dao;

import Utils.DbContext;
import model.UserAddress;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * UserAddressDAO - Handles all DB operations for UserAddresses table.
 */
public class UserAddressDAO extends DbContext {

    /**
     * Get all addresses for a user.
     * @param userId
     * @return 
     */
    public List<UserAddress> findByCustomerId(int userId) {
        List<UserAddress> list = new ArrayList<>();
        String sql = "SELECT id, user_id, recipient_name, recipient_phone, province, district, ward, detail_address, is_default "
                   + "FROM UserAddresses WHERE user_id = ? ORDER BY is_default DESC, id DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("UserAddressDAO.findByCustomerId error: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Find a single address by id and user id (ownership check).
     * @param id
     * @param userId
     * @return 
     */
    public UserAddress findByIdAndCustomer(int id, int userId) {
        String sql = "SELECT id, user_id, recipient_name, recipient_phone, province, district, ward, detail_address, is_default "
                   + "FROM UserAddresses WHERE id = ? AND user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("UserAddressDAO.findByIdAndCustomer error: " + e.getMessage(), e);
        }
        return null;
    }

    /**
     * Insert a new address.
     * @param ua
     * @return 
     */
    public boolean insert(UserAddress ua) {
        String sql = "INSERT INTO UserAddresses (user_id, recipient_name, recipient_phone, province, district, ward, detail_address, is_default) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ua.getUserId());
            ps.setString(2, ua.getRecipientName());
            ps.setString(3, ua.getRecipientPhone());
            ps.setString(4, ua.getProvince() != null ? ua.getProvince() : "");
            ps.setString(5, ua.getDistrict() != null ? ua.getDistrict() : "");
            ps.setString(6, ua.getWard() != null ? ua.getWard() : "");
            ps.setString(7, ua.getDetailAddress() != null ? ua.getDetailAddress() : "");
            ps.setBoolean(8, ua.isIsDefault());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("UserAddressDAO.insert error: " + e.getMessage(), e);
        }
    }

    /**
     * Update an existing address.
     * @param ua
     * @return 
     */
    public boolean update(UserAddress ua) {
        String sql = "UPDATE UserAddresses SET recipient_name = ?, recipient_phone = ?, province = ?, district = ?, ward = ?, detail_address = ?, is_default = ? "
                   + "WHERE id = ? AND user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, ua.getRecipientName());
            ps.setString(2, ua.getRecipientPhone());
            ps.setString(3, ua.getProvince() != null ? ua.getProvince() : "");
            ps.setString(4, ua.getDistrict() != null ? ua.getDistrict() : "");
            ps.setString(5, ua.getWard() != null ? ua.getWard() : "");
            ps.setString(6, ua.getDetailAddress() != null ? ua.getDetailAddress() : "");
            ps.setBoolean(7, ua.isIsDefault());
            ps.setInt(8, ua.getId());
            ps.setInt(9, ua.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("UserAddressDAO.update error: " + e.getMessage(), e);
        }
    }

    /**
     * Delete an address.
     * @param id
     * @param userId
     * @return 
     */
    public boolean delete(int id, int userId) {
        String sql = "DELETE FROM UserAddresses WHERE id = ? AND user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("UserAddressDAO.delete error: " + e.getMessage(), e);
        }
    }

    /**
     * Unset all default addresses for a user, then set the given one as default.
     * @param id
     * @param userId
     * @return 
     */
    public boolean setDefault(int id, int userId) {
        // Bước 1: Bỏ mặc định tất cả địa chỉ của user
        String clearSql = "UPDATE UserAddresses SET is_default = 0 WHERE user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(clearSql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("UserAddressDAO.setDefault (clear) error: " + e.getMessage(), e);
        }

        // Bước 2: Set địa chỉ được chọn làm mặc định
        String setSql = "UPDATE UserAddresses SET is_default = 1 WHERE id = ? AND user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(setSql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("UserAddressDAO.setDefault (set) error: " + e.getMessage(), e);
        }
    }

    // ---- helper ----
    private UserAddress mapRow(ResultSet rs) throws SQLException {
        UserAddress ua = new UserAddress();
        ua.setId(rs.getInt("id"));
        ua.setUserId(rs.getInt("user_id"));
        ua.setRecipientName(rs.getString("recipient_name"));
        ua.setRecipientPhone(rs.getString("recipient_phone"));
        ua.setProvince(rs.getString("province"));
        ua.setDistrict(rs.getString("district"));
        ua.setWard(rs.getString("ward"));
        ua.setDetailAddress(rs.getString("detail_address"));
        ua.setIsDefault(rs.getBoolean("is_default"));
        return ua;
    }
}
