package dao;

import model.Notification;
import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * NotificationDAO - Handles all DB operations for Notifications table.
 * DB Schema (actual): id, account_id, title, message, type, link, is_read, created_at
 */
public class NotificationDAO extends DbContext {

    /**
     * Insert a new notification.
     */
    public int insert(Notification notif) {
        String sql = "INSERT INTO Notifications (account_id, title, message, type, link, is_read, created_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, GETDATE())";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, notif.getUserId());
            ps.setString(2, notif.getTitle());
            ps.setString(3, notif.getContent());
            ps.setString(4, notif.getType());
            ps.setString(5, notif.getLink());
            ps.setBoolean(6, notif.isRead());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] Insert error: " + e.getMessage());
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Get notifications for a user.
     */
    public List<Notification> getByUserId(int userId, int limit) {
        List<Notification> list = new ArrayList<>();
        String sql;
        if (limit > 0) {
            sql = "SELECT TOP " + limit + " id, account_id, title, message, type, link, is_read, created_at "
                + "FROM Notifications WHERE account_id = ? ORDER BY created_at DESC";
        } else {
            sql = "SELECT id, account_id, title, message, type, link, is_read, created_at "
                + "FROM Notifications WHERE account_id = ? ORDER BY created_at DESC";
        }

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] getByUserId error: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get all notifications for a user (no limit).
     */
    public List<Notification> getAllByUserId(int userId) {
        return getByUserId(userId, 0);
    }

    /**
     * Get unread notification count for a user.
     */
    public int getUnreadCount(int userId) {
        String sql = "SELECT COUNT(*) FROM Notifications WHERE account_id = ? AND is_read = 0";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] getUnreadCount error: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Mark a notification as read.
     */
    public boolean markAsRead(int id) {
        String sql = "UPDATE Notifications SET is_read = 1 WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] markAsRead error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Mark all notifications as read for a user.
     */
    public int markAllAsRead(int userId) {
        String sql = "UPDATE Notifications SET is_read = 1 WHERE account_id = ? AND is_read = 0";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            return ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] markAllAsRead error: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Delete a notification by ID.
     */
    public boolean delete(int id) {
        String sql = "DELETE FROM Notifications WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] delete error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Delete old notifications (older than specified days).
     */
    public int deleteOld(int days) {
        String sql = "DELETE FROM Notifications WHERE created_at < DATEADD(day, -?, GETDATE())";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, days);
            return ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] deleteOld error: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Delete all notifications for a user.
     */
    public int deleteAllByUserId(int userId) {
        String sql = "DELETE FROM Notifications WHERE account_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            return ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] deleteAllByUserId error: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Find notification by ID.
     */
    public Notification findById(int id) {
        String sql = "SELECT id, account_id, title, message, type, link, is_read, created_at "
                   + "FROM Notifications WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] findById error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get total notification count for a user.
     */
    public int getTotalCount(int userId) {
        String sql = "SELECT COUNT(*) FROM Notifications WHERE account_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] getTotalCount error: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    private Notification mapRow(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setId(rs.getInt("id"));
        n.setUserId(rs.getInt("account_id"));
        n.setTitle(rs.getString("title"));
        n.setContent(rs.getString("message"));
        n.setType(rs.getString("type"));
        n.setLink(rs.getString("link"));
        n.setRead(rs.getBoolean("is_read"));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        return n;
    }
}
