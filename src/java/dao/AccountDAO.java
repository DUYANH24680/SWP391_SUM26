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
        String sql = "SELECT u.id, u.role_id, r.name AS role_name, u.fullname, u.username, u.password_hash, u.email, u.phone, u.address, u.avatar, u.gender, u.status, u.created_at "
                   + "FROM Accounts u "
                   + "JOIN Roles r ON u.role_id = r.id "
                   + "WHERE (u.username = ? OR u.email = ?) AND u.status = 1";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
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
        String sql = "SELECT u.id, u.role_id, r.name AS role_name, u.fullname, u.username, u.password_hash, u.email, u.phone, u.address, u.avatar, u.gender, u.status, u.created_at "
                   + "FROM Accounts u "
                   + "JOIN Roles r ON u.role_id = r.id "
                   + "WHERE u.id = ? AND u.status = 1";
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

    /**
     * Update profile details including address and gender.
     */
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
     * Check if email is already taken by another account.
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
    
        /**
     * Check if email already exists in the system (including inactive accounts).
     */
    public boolean isEmailExists(String email) {
        String sql = "SELECT COUNT(1) FROM Accounts WHERE email = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("AccountDAO.isEmailExists error: " + e.getMessage(), e);
        }
        return false;
    }

    /**
     * Check if username already exists in the system.
     */
    public boolean isUsernameTaken(String username) {
        String sql = "SELECT COUNT(1) FROM Accounts WHERE username = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("AccountDAO.isUsernameTaken error: " + e.getMessage(), e);
        }
        return false;
    }

    /**
     * Insert a new customer account.
     * roleId must be the id for 'Customer' role (typically 3).
     * Returns the generated account id, or -1 on failure.
     */
    public int register(String fullname, String username, String passwordHash, String email, String phone, int roleId) {
        String sql = "INSERT INTO Accounts (role_id, fullname, username, password_hash, email, phone, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, 1)";
        try (PreparedStatement ps = getConnection().prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, roleId);
            ps.setString(2, fullname.trim());
            ps.setString(3, username.trim());
            ps.setString(4, passwordHash);
            ps.setString(5, email.trim().toLowerCase());
            if (phone != null && !phone.trim().isEmpty()) {
                ps.setString(6, phone.trim());
            } else {
                ps.setNull(6, Types.VARCHAR);
            }
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int newId = rs.getInt(1);
                        System.out.println("[AccountDAO] register() success, new account id=" + newId);
                        return newId;
                    }
                }
            }
            return -1;
        } catch (SQLException e) {
            System.err.println("[AccountDAO] register() error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("AccountDAO.register error: " + e.getMessage(), e);
        }
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
