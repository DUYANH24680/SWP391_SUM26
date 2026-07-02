package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.ChatMessage;
import model.ChatSession;
import Utils.DbContext;

public class ChatDAO extends DbContext {

    public int createSession(int reportId, int customerId, int sellerId, int adminId) {
        String sql = "INSERT INTO ChatSessions (report_id, customer_id, seller_id, admin_id, status) VALUES (?, ?, ?, ?, 'OPEN')";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, reportId);
            ps.setInt(2, customerId);
            ps.setInt(3, sellerId);
            ps.setInt(4, adminId);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public List<ChatSession> getSessionsByUser(int userId, String role) {
        List<ChatSession> list = new ArrayList<>();
        String sql = "SELECT cs.*, " +
                     "c.fullname as cName, c.avatar as cAvatar, " +
                     "s.fullname as sName, s.avatar as sAvatar, " +
                     "a.fullname as aName, a.avatar as aAvatar, " +
                     "p.name as pName, " +
                     "(SELECT TOP 1 message FROM ChatMessages cm WHERE cm.session_id = cs.id ORDER BY created_at DESC) as lastMessage, " +
                     "(SELECT TOP 1 created_at FROM ChatMessages cm WHERE cm.session_id = cs.id ORDER BY created_at DESC) as lastMessageTime " +
                     "FROM ChatSessions cs " +
                     "JOIN Accounts c ON cs.customer_id = c.id " +
                     "JOIN Accounts s ON cs.seller_id = s.id " +
                     "LEFT JOIN Accounts a ON cs.admin_id = a.id " +
                     "JOIN Reports r ON cs.report_id = r.id " +
                     "JOIN Products p ON r.product_id = p.id " +
                     "WHERE cs.customer_id = ? OR cs.seller_id = ? OR cs.admin_id = ? " +
                     "ORDER BY ISNULL(lastMessageTime, cs.created_at) DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChatSession cs = new ChatSession();
                    cs.setId(rs.getInt("id"));
                    cs.setReportId(rs.getInt("report_id"));
                    cs.setCustomerId(rs.getInt("customer_id"));
                    cs.setSellerId(rs.getInt("seller_id"));
                    cs.setAdminId(rs.getObject("admin_id") != null ? rs.getInt("admin_id") : null);
                    cs.setStatus(rs.getString("status"));
                    cs.setCreatedAt(rs.getTimestamp("created_at"));
                    cs.setCustomerName(rs.getString("cName"));
                    cs.setCustomerAvatar(rs.getString("cAvatar"));
                    cs.setSellerName(rs.getString("sName"));
                    cs.setSellerAvatar(rs.getString("sAvatar"));
                    cs.setAdminName(rs.getString("aName"));
                    cs.setAdminAvatar(rs.getString("aAvatar"));
                    cs.setProductName(rs.getString("pName"));
                    cs.setLastMessage(rs.getString("lastMessage"));
                    cs.setLastMessageTime(rs.getTimestamp("lastMessageTime"));
                    list.add(cs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<ChatMessage> getMessages(int sessionId) {
        List<ChatMessage> list = new ArrayList<>();
        String sql = "SELECT m.*, a.fullname as senderName, a.avatar as senderAvatar, a.role_id as roleId " +
                     "FROM ChatMessages m " +
                     "JOIN Accounts a ON m.sender_id = a.id " +
                     "WHERE m.session_id = ? ORDER BY m.created_at ASC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sessionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChatMessage m = new ChatMessage();
                    m.setId(rs.getInt("id"));
                    m.setSessionId(rs.getInt("session_id"));
                    m.setSenderId(rs.getInt("sender_id"));
                    m.setMessage(rs.getString("message"));
                    m.setCreatedAt(rs.getTimestamp("created_at"));
                    m.setSenderName(rs.getString("senderName"));
                    m.setSenderAvatar(rs.getString("senderAvatar"));
                    // Convert roleId to string
                    int roleId = rs.getInt("roleId");
                    String role = (roleId == 1) ? "customer" : (roleId == 2) ? "admin" : (roleId == 3) ? "seller" : "member";
                    m.setSenderRole(role);
                    list.add(m);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean sendMessage(int sessionId, int senderId, String message) {
        String sql = "INSERT INTO ChatMessages (session_id, sender_id, message) VALUES (?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sessionId);
            ps.setInt(2, senderId);
            ps.setString(3, message);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
