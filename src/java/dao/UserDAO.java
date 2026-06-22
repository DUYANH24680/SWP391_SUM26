package dao;

import model.User;
import Utils.DbContext;
import java.sql.*;

/**
 * UserDAO - Handles all DB operations for Accounts table.
 */
public class UserDAO extends Utils.DbContext {

    /**
     * Find a user by username or email (for login).
     */
    public User findByUsernameOrEmail(String usernameOrEmail) {
        String sql = "SELECT u.id, u.role_id, r.name AS role_name, u.fullname, u.username, u.password_hash, u.email, u.phone, u.avatar, u.status, u.created_at "
                   + "FROM Accounts u "
                   + "JOIN Roles r ON u.role_id = r.id "
                   + "WHERE (u.username = ? OR u.email = ?) AND u.status = 1";

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
        String sql = "SELECT u.id, u.role_id, r.name AS role_name, u.fullname, u.username, u.password_hash, u.email, u.phone, u.avatar, u.status, u.created_at "
                   + "FROM Accounts u "
                   + "JOIN Roles r ON u.role_id = r.id "
                   + "WHERE u.id = ? AND u.status = 1";
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
        String sql = "UPDATE Accounts SET fullname = ?, email = ?, phone = ?, avatar = ? WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, fullname);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, avatar);
            ps.setInt(5, id);
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
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setRoleId(rs.getInt("role_id"));
        u.setRoleName(rs.getString("role_name"));
        u.setFullname(rs.getString("fullname"));
        u.setUsername(rs.getString("username"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setAvatar(rs.getString("avatar"));
        u.setStatus(rs.getInt("status"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        return u;
    }
}