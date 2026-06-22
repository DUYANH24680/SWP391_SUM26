package dao;
import Utils.DbContext;
import java.sql.*;

public class PasswordResetTokenDAO extends DbContext {

    public boolean createToken(int accountId, String token, Timestamp expiryTime) {
        // First invalidate any existing tokens for this account
        String deleteSql = "UPDATE PasswordResetToken SET is_used = 1 WHERE account_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(deleteSql)) {
            ps.setInt(1, accountId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("PasswordResetTokenDAO.createToken clear error: " + e.getMessage(), e);
        }

        String sql = "INSERT INTO PasswordResetToken (account_id, token, expiry_time, is_used, created_at) VALUES (?, ?, ?, 0, GETDATE())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setString(2, token);
            ps.setTimestamp(3, expiryTime);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("PasswordResetTokenDAO.createToken insert error: " + e.getMessage(), e);
        }
    }

    public boolean validateToken(int accountId, String token) {
        String sql = "SELECT COUNT(1) FROM PasswordResetToken WHERE account_id = ? AND token = ? AND expiry_time > GETDATE() AND is_used = 0";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, accountId);
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
        String sql = "UPDATE PasswordResetToken SET is_used = 1 WHERE token = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, token);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("PasswordResetTokenDAO.markTokenAsUsed error: " + e.getMessage(), e);
        }
    }
}