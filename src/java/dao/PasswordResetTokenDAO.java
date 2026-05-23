package dao;

import java.sql.*;

public class PasswordResetTokenDAO extends DBContext {

    public boolean createToken(String email, String token, Timestamp expiryTime) {
        // First invalidate any existing tokens for this email
        String deleteSql = "UPDATE PasswordResetTokens SET is_used = 1 WHERE email = ?";
        try (PreparedStatement ps = connection.prepareStatement(deleteSql)) {
            ps.setString(1, email);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("PasswordResetTokenDAO.createToken clear error: " + e.getMessage(), e);
        }

        String sql = "INSERT INTO PasswordResetTokens (email, token, expiry_time, is_used) VALUES (?, ?, ?, 0)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, token);
            ps.setTimestamp(3, expiryTime);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("PasswordResetTokenDAO.createToken insert error: " + e.getMessage(), e);
        }
    }

    public boolean validateToken(String email, String token) {
        String sql = "SELECT COUNT(1) FROM PasswordResetTokens WHERE email = ? AND token = ? AND expiry_time > GETDATE() AND is_used = 0";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("PasswordResetTokenDAO.validateToken error: " + e.getMessage(), e);
        }
        return false;
    }

    public boolean markTokenAsUsed(String token) {
        String sql = "UPDATE PasswordResetTokens SET is_used = 1 WHERE token = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, token);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("PasswordResetTokenDAO.markTokenAsUsed error: " + e.getMessage(), e);
        }
    }
}
