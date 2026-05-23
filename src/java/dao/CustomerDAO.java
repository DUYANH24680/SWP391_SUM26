package dao;

import model.Customer;
import java.sql.*;

/**
 * CustomerDAO - Handles all DB operations for Customers table.
 */
public class CustomerDAO extends DBContext {

    /**
     * Find a customer by username or email (for login).
     */
    public Customer findByUsernameOrEmail(String usernameOrEmail) {
        String sql = "SELECT id, fullname, username, password_hash, email, phone, address, gender, avatar, status, isDelete, created_at "
                   + "FROM Customers WHERE (username = ? OR email = ?) AND isDelete = 0";
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

    /**
     * Find a customer by id.
     */
    public Customer findById(int id) {
        String sql = "SELECT id, fullname, username, password_hash, email, phone, address, gender, avatar, status, isDelete, created_at "
                   + "FROM Customers WHERE id = ? AND isDelete = 0";
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
        String sql = "UPDATE Customers SET fullname = ?, email = ?, phone = ?, address = ?, gender = ?, avatar = ? WHERE id = ?";
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

    /**
     * Update password hash.
     */
    public boolean updatePassword(int id, String newPasswordHash) {
        String sql = "UPDATE Customers SET password_hash = ? WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("CustomerDAO.updatePassword error: " + e.getMessage(), e);
        }
    }

    /**
     * Check if email is already used by another customer (for uniqueness validation).
     */
    public boolean isEmailTaken(String email, int excludeId) {
        String sql = "SELECT COUNT(1) FROM Customers WHERE email = ? AND id <> ? AND isDelete = 0";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("CustomerDAO.isEmailTaken error: " + e.getMessage(), e);
        }
        return false;
    }

    // ---- helper ----
    private Customer mapRow(ResultSet rs) throws SQLException {
        Customer c = new Customer();
        c.setId(rs.getInt("id"));
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
        c.setIsDelete(rs.getBoolean("isDelete"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        return c;
    }
}
