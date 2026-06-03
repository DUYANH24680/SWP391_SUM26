package dao;

import model.Customer;
import java.sql.*;

/**
 * CustomerDAO - DB operations on Users table (MarketplaceSystem schema).
 */
public class CustomerDAO extends Utils.DbContext {

    private static final String USER_SELECT =
            "SELECT u.id, u.role_id, r.name AS role_name, u.fullname, u.username, u.password_hash, "
          + "u.email, u.phone, u.address, u.gender, u.avatar, u.status, u.created_at "
          + "FROM Users u "
          + "JOIN Roles r ON u.role_id = r.id ";

    public Customer findByUsernameOrEmail(String usernameOrEmail) {
        String sql = USER_SELECT + "WHERE (u.username = ? OR u.email = ?) AND u.status = 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, usernameOrEmail);
            ps.setString(2, usernameOrEmail);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("CustomerDAO.findByUsernameOrEmail error: " + e.getMessage(), e);
        }
        return null;
    }

    public Customer findById(int id) {
        String sql = USER_SELECT + "WHERE u.id = ? AND u.status = 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("CustomerDAO.findById error: " + e.getMessage(), e);
        }
        return null;
    }

    public boolean updateProfile(int id, String fullname, String email, String phone, String address, Boolean gender, String avatar) {
        String sql = "UPDATE Users SET fullname = ?, email = ?, phone = ?, address = ?, gender = ?, avatar = ? WHERE id = ?";
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
            throw new RuntimeException("CustomerDAO.updateProfile error: " + e.getMessage(), e);
        }
    }

    public boolean updatePassword(int id, String newPasswordHash) {
        String sql = "UPDATE Users SET password_hash = ? WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("CustomerDAO.updatePassword error: " + e.getMessage(), e);
        }
    }

    public boolean existsByEmail(String email) {
        String sql = "SELECT COUNT(1) FROM Users WHERE email = ? AND status = 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("CustomerDAO.existsByEmail error: " + e.getMessage(), e);
        }
        return false;
    }

    public boolean existsByUsername(String username) {
        String sql = "SELECT COUNT(1) FROM Users WHERE username = ? AND status = 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("CustomerDAO.existsByUsername error: " + e.getMessage(), e);
        }
        return false;
    }

    public boolean insertUser(int roleId, String fullname, String username, String passwordHash,
                              String email, String phone) {
        String sql = "INSERT INTO Users (role_id, fullname, username, password_hash, email, phone, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, 1)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            ps.setString(2, fullname);
            ps.setString(3, username);
            ps.setString(4, passwordHash);
            ps.setString(5, email);
            ps.setString(6, phone);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("CustomerDAO.insertUser error: " + e.getMessage(), e);
        }
    }

    public boolean isEmailTaken(String email, int excludeId) {
        String sql = "SELECT COUNT(1) FROM Users WHERE email = ? AND id <> ? AND status = 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("CustomerDAO.isEmailTaken error: " + e.getMessage(), e);
        }
        return false;
    }

    /** Resolve role id by name (e.g. "user"). Returns -1 if not found. */
    public int findRoleIdByName(String roleName) {
        String sql = "SELECT id FROM Roles WHERE name = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, roleName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("CustomerDAO.findRoleIdByName error: " + e.getMessage(), e);
        }
        return -1;
    }

    private Customer mapRow(ResultSet rs) throws SQLException {
        Customer c = new Customer();
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
