package dao;

import model.Staff;
import java.sql.*;

/**
 * StaffDAO - Handles DB operations for Staffs table.
 */
public class StaffDAO extends DBContext {

    /**
     * Find a staff by username or email (for login).
     */
    public Staff findByUsernameOrEmail(String usernameOrEmail) {
        String sql = "SELECT id, email, fullname, username, password_hash, gender, phone, address, role_id, seller_status, status, isDelete, created_at "
                + "FROM Staffs WHERE (username = ? OR email = ?) AND isDelete = 0";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, usernameOrEmail);
            ps.setString(2, usernameOrEmail);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("StaffDAO.findByUsernameOrEmail error: " + e.getMessage(), e);
        }
        return null;
    }

    /**
     * Update password hash for a staff.
     */
    public boolean updatePassword(int id, String newPasswordHash) {
        String sql = "UPDATE Staffs SET password_hash = ? WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("StaffDAO.updatePassword error: " + e.getMessage(), e);
        }
    }

    // ---- helper ----
    private Staff mapRow(ResultSet rs) throws SQLException {
        Staff s = new Staff();
        s.setId(rs.getInt("id"));
        s.setEmail(rs.getString("email"));
        s.setFullname(rs.getString("fullname"));
        s.setUsername(rs.getString("username"));
        s.setPasswordHash(rs.getString("password_hash"));
        boolean genderBit = rs.getBoolean("gender");
        s.setGender(rs.wasNull() ? false : genderBit);
        s.setPhone(rs.getString("phone"));
        s.setAddress(rs.getString("address"));
        s.setRoleId(rs.getInt("role_id"));
        s.setSellerStatus(rs.getInt("seller_status"));
        s.setStatus(rs.getInt("status"));
        s.setIsDelete(rs.getBoolean("isDelete"));
        s.setCreatedAt(rs.getTimestamp("created_at"));
        return s;
    }
}
