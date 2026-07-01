package dao;

import model.Account;
import Utils.DbContext;
import java.sql.*;

/**
 * AccountDAO - Handles all DB operations for Accounts table.
 */
public class AccountDAO extends Utils.DbContext {

    /**
     * Find an account by username or email (for login).
     */
    public Account findByUsernameOrEmail(String usernameOrEmail) {
        String sql = "SELECT u.id, u.role_id, r.name AS role_name, u.fullname, u.username, u.password_hash, u.email, u.phone, u.address, u.avatar, u.gender, u.status, u.created_at "
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
            throw new RuntimeException("AccountDAO.findByUsernameOrEmail error: " + e.getMessage(), e);
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
     * Find an account by id.
     */
    public Account findById(int id) {
        String sql = "SELECT u.id, u.role_id, r.name AS role_name, u.fullname, u.username, u.password_hash, u.email, u.phone, u.address, u.avatar, u.gender, u.status, u.created_at "
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
            throw new RuntimeException("AccountDAO.findById error: " + e.getMessage(), e);
        }
        return null;
    }

    /**
     * Update profile details including address and gender.
     */
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
            throw new RuntimeException("AccountDAO.updateProfile error: " + e.getMessage(), e);
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
            throw new RuntimeException("AccountDAO.updatePassword error: " + e.getMessage(), e);
        }
    }

    /**
     * Check if email is already taken by another account.
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
            throw new RuntimeException("AccountDAO.isEmailTaken error: " + e.getMessage(), e);
        }
        return false;
    }

    // ---- helper ----
    private Account mapRow(ResultSet rs) throws SQLException {
        Account u = new Account();
        u.setId(rs.getInt("id"));
        u.setRoleId(rs.getInt("role_id"));
        u.setRoleName(rs.getString("role_name"));
        u.setFullname(rs.getString("fullname"));
        u.setUsername(rs.getString("username"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setAddress(rs.getString("address"));
        u.setAvatar(rs.getString("avatar"));
        boolean genderVal = rs.getBoolean("gender");
        u.setGender(rs.wasNull() ? null : genderVal);
        u.setStatus(rs.getInt("status"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        return u;
    }
}
