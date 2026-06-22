package dao;

import model.Account;
import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * AccountDAO - Handles all DB operations for Accounts table.
 */
public class AccountDAO extends Utils.DbContext {

    /**
     * Find an account by username or email (for login).
     */
    public Account findByUsernameOrEmail(String usernameOrEmail) {
        String sql = "SELECT a.id, a.role_id, r.name AS role_name, a.fullname, a.username, a.password_hash, a.email, a.phone, a.address, a.gender, a.avatar, a.status, a.created_at "
                   + "FROM Accounts a "
                   + "JOIN Roles r ON a.role_id = r.id "
                   + "WHERE (a.username = ? OR a.email = ?) AND a.status = 1";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, usernameOrEmail);
            ps.setString(2, usernameOrEmail);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("AccountDAO.findByUsernameOrEmail error: " + e.getMessage(), e);
        }
        return null;
    }

    /**
     * Find an account by id.
     */
    public Account findById(int id) {
        String sql = "SELECT a.id, a.role_id, r.name AS role_name, a.fullname, a.username, a.password_hash, a.email, a.phone, a.address, a.gender, a.avatar, a.status, a.created_at "
                   + "FROM Accounts a "
                   + "JOIN Roles r ON a.role_id = r.id "
                   + "WHERE a.id = ? AND a.status = 1";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
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
     * Get all accounts by role name.
     */
    public List<Account> getAccountsByRole(String roleName) {
        List<Account> list = new ArrayList<>();
        String sql = "SELECT a.id, a.role_id, r.name AS role_name, a.fullname, a.username, a.password_hash, a.email, a.phone, a.address, a.gender, a.avatar, a.status, a.created_at "
                   + "FROM Accounts a "
                   + "JOIN Roles r ON a.role_id = r.id "
                   + "WHERE r.name = ? "
                   + "ORDER BY a.created_at DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, roleName);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("AccountDAO.getAccountsByRole error: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Search accounts by role with keyword matching (username, fullname, email, phone).
     */
    public List<Account> searchAccountsByRole(String roleName, String keyword) {
        List<Account> list = new ArrayList<>();
        String sql = "SELECT a.id, a.role_id, r.name AS role_name, a.fullname, a.username, a.password_hash, a.email, a.phone, a.address, a.gender, a.avatar, a.status, a.created_at "
                   + "FROM Accounts a "
                   + "JOIN Roles r ON a.role_id = r.id "
                   + "WHERE r.name = ? "
                   + "  AND (a.username LIKE ? OR a.fullname LIKE ? OR a.email LIKE ? OR a.phone LIKE ?) "
                   + "ORDER BY a.created_at DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, roleName);
            String kw = "%" + keyword.trim() + "%";
            ps.setString(2, kw);
            ps.setString(3, kw);
            ps.setString(4, kw);
            ps.setString(5, kw);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("AccountDAO.searchAccountsByRole error: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Get account by id (including blocked accounts).
     */
    public Account findByIdIncludeAll(int id) {
        String sql = "SELECT a.id, a.role_id, r.name AS role_name, a.fullname, a.username, a.password_hash, a.email, a.phone, a.address, a.gender, a.avatar, a.status, a.created_at "
                   + "FROM Accounts a "
                   + "JOIN Roles r ON a.role_id = r.id "
                   + "WHERE a.id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("AccountDAO.findByIdIncludeAll error: " + e.getMessage(), e);
        }
        return null;
    }

    /**
     * Block or unblock an account (set status = 0 for blocked, 1 for active).
     */
    public boolean updateAccountStatus(int id, int status) {
        String sql = "UPDATE Accounts SET status = ? WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("AccountDAO.updateAccountStatus error: " + e.getMessage(), e);
        }
    }

    public boolean updateProfile(int id, String fullname, String email, String phone, String address, Boolean gender, String avatar) {
        String sql = "UPDATE Accounts SET fullname = ?, email = ?, phone = ?, address = ?, gender = ?, avatar = ? WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
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
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("AccountDAO.updatePassword error: " + e.getMessage(), e);
        }
    }

    /**
     * Check if email is already used by another account (for uniqueness validation).
     */
    public boolean isEmailTaken(String email, int excludeId) {
        String sql = "SELECT COUNT(1) FROM Accounts WHERE email = ? AND id <> ? AND status = 1";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
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
        Account c = new Account();
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
