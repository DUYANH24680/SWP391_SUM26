package dao;

import model.User;
import java.sql.*;

/**
 * UserDAO - Handles all DB operations for Users table.
 */
public class UserDAO extends Utils.DbContext {

    /**
     * Find a user by username or email (for login).
     */
    public User findByUsernameOrEmail(String usernameOrEmail) {
        String sql = "SELECT a.id, a.role_id, r.name AS role_name, a.fullname, a.username, a.password_hash, a.email, a.phone, a.address, a.gender, a.avatar, a.status, a.created_at "
                   + "FROM Accounts a "
                   + "JOIN Roles r ON a.role_id = r.id "
                   + "WHERE (a.username = ? OR a.email = ?) AND a.status = 1";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = createConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, usernameOrEmail);
            ps.setString(2, usernameOrEmail);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("UserDAO.findByUsernameOrEmail error: " + e.getMessage(), e);
        } finally {
            try {
                if (rs != null) rs.close();
            } catch (SQLException ignored) {
            }
            try {
                if (ps != null) ps.close();
            } catch (SQLException ignored) {
            }
            try {
                if (conn != null && !conn.isClosed()) conn.close();
            } catch (SQLException ignored) {
            }
        }
        return null;
    }

    /**
     * Find a user by id.
     */
    public User findById(int id) {
        String sql = "SELECT a.id, a.role_id, r.name AS role_name, a.fullname, a.username, a.password_hash, a.email, a.phone, a.address, a.gender, a.avatar, a.status, a.created_at "
                   + "FROM Accounts a "
                   + "JOIN Roles r ON a.role_id = r.id "
                   + "WHERE a.id = ? AND a.status = 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("UserDAO.findById error: " + e.getMessage(), e);
        }
        return null;
    }

    public boolean updateProfile(int id, String fullname, String email, String phone, String address, Boolean gender, String avatar) {
        String sql = "UPDATE Accounts SET fullname = ?, email = ?, phone = ?, address = ?, gender = ?, avatar = ? WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, fullname);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, address);
            if (gender != null) {
                ps.setBoolean(5, gender);
            } else {
                ps.setNull(5, Types.BIT);
            }
            ps.setString(6, avatar);
            ps.setInt(7, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("UserDAO.updateProfile error: " + e.getMessage(), e);
        }
    }

    /**
     * Update password hash.
     */
    public boolean updatePassword(int id, String newPasswordHash) {
        String sql = "UPDATE Accounts SET password_hash = ? WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("UserDAO.updatePassword error: " + e.getMessage(), e);
        }
    }

    /**
     * Check if email is already used by another user (for uniqueness validation).
     */
    public boolean isEmailTaken(String email, int excludeId) {
        String sql = "SELECT COUNT(1) FROM Accounts WHERE email = ? AND id <> ? AND status = 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("UserDAO.isEmailTaken error: " + e.getMessage(), e);
        }
        return false;
    }

    // ---- helper ----
    private User mapRow(ResultSet rs) throws SQLException {
        User c = new User();
        c.setId(rs.getInt("id"));
        c.setRoleId(rs.getInt("role_id"));
        c.setRoleName(rs.getString("role_name"));
        c.setFullname(rs.getString("fullname"));
        c.setUsername(rs.getString("username"));
        c.setPasswordHash(rs.getString("password_hash"));
        c.setEmail(rs.getString("email"));
        c.setPhone(rs.getString("phone"));
        c.setAddress(rs.getString("address"));
        boolean genderBit = rs.getBoolean("gender");
        c.setGender(rs.wasNull() ? null : genderBit);
        c.setAvatar(rs.getString("avatar"));
        c.setStatus(rs.getInt("status"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        return c;
    }
}
