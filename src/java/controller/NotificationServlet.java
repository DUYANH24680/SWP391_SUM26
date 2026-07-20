package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Notification;
import service.NotificationService;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * NotificationServlet - Handle notification operations via AJAX.
 */
@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {

    private NotificationService notifService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        HttpSession session = req.getSession(false);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        if (session == null || session.getAttribute("Account") == null) {
            out.print("{\"success\":false,\"message\":\"Chua dang nhap\"}");
            return;
        }

        Account user = (Account) session.getAttribute("Account");
        String action = req.getParameter("action");

        try {
            if ("count".equals(action)) {
                int count = notifService.getUnreadCount(user.getId());
                out.print("{\"success\":true,\"count\":" + count + "}");

            } else {
                // Default: get notification list
                int limit = 20;
                String limitParam = req.getParameter("limit");
                if (limitParam != null && !limitParam.isEmpty()) {
                    try {
                        limit = Integer.parseInt(limitParam);
                    } catch (NumberFormatException e) {
                        limit = 20;
                    }
                }

                List<Notification> notifications = notifService.getByUserId(user.getId(), limit);
                int unreadCount = notifService.getUnreadCount(user.getId());

                StringBuilder json = new StringBuilder();
                json.append("{\"success\":true,\"unreadCount\":").append(unreadCount).append(",\"notifications\":[");
                
                for (int i = 0; i < notifications.size(); i++) {
                    Notification n = notifications.get(i);
                    if (i > 0) json.append(",");
                    json.append("{");
                    json.append("\"id\":").append(n.getId()).append(",");
                    json.append("\"title\":\"").append(escapeJson(n.getTitle())).append("\",");
                    json.append("\"content\":\"").append(escapeJson(n.getContent())).append("\",");
                    json.append("\"type\":\"").append(n.getType()).append("\",");
                    json.append("\"relatedId\":").append(n.getLink() != null ? "\"" + escapeJson(n.getLink()) + "\"" : "null").append(",");
                    json.append("\"isRead\":").append(n.isRead()).append(",");
                    json.append("\"timeAgo\":\"").append(escapeJson(n.getTimeAgo())).append("\",");
                    json.append("\"typeIcon\":\"").append(n.getTypeIcon()).append("\",");
                    json.append("\"typeColor\":\"").append(n.getTypeColor()).append("\"");
                    json.append("}");
                }
                
                json.append("]}");
                out.print(json.toString());
            }

        } catch (Exception e) {
            System.err.println("[NotificationServlet] Error: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Lỗi: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        HttpSession session = req.getSession(false);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        if (session == null || session.getAttribute("Account") == null) {
            out.print("{\"success\":false,\"message\":\"Chua dang nhap\"}");
            return;
        }

        Account user = (Account) session.getAttribute("Account");
        String action = req.getParameter("action");

        try {
            if ("read".equals(action)) {
                String notifIdParam = req.getParameter("id");
                String markAll = req.getParameter("markAll");

                if ("true".equals(markAll)) {
                    int count = notifService.markAllAsRead(user.getId());
                    out.print("{\"success\":true,\"markedCount\":" + count + "}");
                } else if (notifIdParam != null && !notifIdParam.isEmpty()) {
                    int id = Integer.parseInt(notifIdParam);
                    boolean success = notifService.markAsRead(id);
                    // Update session count
                    int newCount = notifService.getUnreadCount(user.getId());
                    out.print("{\"success\":" + success + ",\"unreadCount\":" + newCount + "}");
                } else {
                    out.print("{\"success\":false,\"message\":\"Thieu tham so\"}");
                }

            } else if ("delete".equals(action)) {
                String notifIdParam = req.getParameter("id");
                if (notifIdParam == null || notifIdParam.isEmpty()) {
                    out.print("{\"success\":false,\"message\":\"Thieu tham so\"}");
                    return;
                }

                int id = Integer.parseInt(notifIdParam);
                boolean success = notifService.delete(id);
                int newCount = notifService.getUnreadCount(user.getId());
                out.print("{\"success\":" + success + ",\"unreadCount\":" + newCount + "}");

            } else if ("create".equals(action)) {
                String title = req.getParameter("title");
                String content = req.getParameter("content");
                String type = req.getParameter("type");
                String userIdParam = req.getParameter("userId");
                String relatedIdParam = req.getParameter("relatedId");

                if (title == null || content == null || type == null || userIdParam == null) {
                    out.print("{\"success\":false,\"message\":\"Thieu tham so bat buoc\"}");
                    return;
                }

                int userId = Integer.parseInt(userIdParam);
                String link = (relatedIdParam != null && !relatedIdParam.isEmpty()) ? relatedIdParam : null;

                Notification n = new Notification(userId, title, content, type, link);
                int id = notifService.create(n);
                out.print("{\"success\":" + (id > 0) + ",\"id\":" + id + "}");

            } else {
                out.print("{\"success\":false,\"message\":\"Hanh dong khong hop le\"}");
            }

        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"message\":\"Du lieu khong hop le\"}");
        } catch (Exception e) {
            System.err.println("[NotificationServlet] Error: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Lỗi: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }

    @Override
    public void destroy() {
        notifService.close();
    }
}
