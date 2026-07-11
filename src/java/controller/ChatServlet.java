package controller;

import dao.ChatDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.text.SimpleDateFormat;
import model.Account;
import model.ChatMessage;
import model.ChatSession;

/**
 * Servlet xử lý các chức năng liên quan đến Hệ thống Chat Hỗ trợ
 * Xử lý cả việc hiển thị giao diện (render JSP) và các API gọi qua AJAX (Lấy tin nhắn, Gửi tin nhắn)
 */
@WebServlet(name = "ChatServlet", urlPatterns = {"/chat"})
public class ChatServlet extends HttpServlet {

    private final ChatDAO chatDAO = new ChatDAO();
    private final SimpleDateFormat sdf = new SimpleDateFormat("HH:mm dd/MM/yyyy");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra xem người dùng đã đăng nhập chưa
        HttpSession session = request.getSession(false);
        Account user = (session != null) ? (Account) session.getAttribute("user") : null;
        
        if (user == null) {
            // Chưa đăng nhập thì chuyển hướng về trang login
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        
        // --- API: Lấy danh sách các đoạn chat của người dùng ---
        if ("getSessions".equals(action)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            List<ChatSession> sessions = chatDAO.getSessionsByUser(user.getId(), user.getRoleName());
            
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < sessions.size(); i++) {
                ChatSession s = sessions.get(i);
                json.append("{")
                    .append("\"id\":").append(s.getId()).append(",")
                    .append("\"customerName\":\"").append(escapeJson(s.getCustomerName())).append("\",")
                    .append("\"customerAvatar\":\"").append(escapeJson(s.getCustomerAvatar())).append("\",")
                    .append("\"sellerName\":\"").append(escapeJson(s.getSellerName())).append("\",")
                    .append("\"sellerAvatar\":\"").append(escapeJson(s.getSellerAvatar())).append("\",")
                    .append("\"productName\":\"").append(escapeJson(s.getProductName())).append("\",")
                    .append("\"lastMessage\":\"").append(escapeJson(s.getLastMessage())).append("\"")
                    .append("}");
                if (i < sessions.size() - 1) json.append(",");
            }
            json.append("]");
            
            response.getWriter().write(json.toString());
            return;
        }
        
        // --- API: Lấy tất cả tin nhắn trong 1 phòng chat cụ thể ---
        if ("getMessages".equals(action)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            int sessionId = Integer.parseInt(request.getParameter("sessionId"));
            List<ChatMessage> messages = chatDAO.getMessages(sessionId);
            
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < messages.size(); i++) {
                ChatMessage m = messages.get(i);
                json.append("{")
                    .append("\"id\":").append(m.getId()).append(",")
                    .append("\"senderId\":").append(m.getSenderId()).append(",")
                    .append("\"senderName\":\"").append(escapeJson(m.getSenderName())).append("\",")
                    .append("\"senderRole\":\"").append(escapeJson(m.getSenderRole())).append("\",")
                    .append("\"senderAvatar\":\"").append(escapeJson(m.getSenderAvatar())).append("\",")
                    .append("\"message\":\"").append(escapeJson(m.getMessage())).append("\",")
                    .append("\"createdAt\":\"").append(m.getCreatedAt() != null ? sdf.format(m.getCreatedAt()) : "").append("\"")
                    .append("}");
                if (i < messages.size() - 1) json.append(",");
            }
            json.append("]");
            
            // Trả về JSON cho Javascript ở Frontend xử lý hiển thị
            response.getWriter().write(json.toString());
            return;
        }

        // --- MẶC ĐỊNH: Chuyển hướng tới giao diện Chat (chat.jsp) ---
        // Lấy danh sách phiên chat để hiển thị ở Sidebar bên trái của trang Chat
        List<ChatSession> sessions = chatDAO.getSessionsByUser(user.getId(), user.getRoleName());
        request.setAttribute("sessions", sessions);
        request.getRequestDispatcher("/chat.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra trạng thái đăng nhập
        HttpSession session = request.getSession(false);
        Account user = (session != null) ? (Account) session.getAttribute("user") : null;
        
        if (user == null) {
            // Trả về lỗi 401 Unauthorized nếu chưa đăng nhập
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String action = request.getParameter("action");
        
        // --- API: Gửi tin nhắn mới vào phòng chat ---
        if ("sendMessage".equals(action)) {
            int sessionId = Integer.parseInt(request.getParameter("sessionId"));
            String message = request.getParameter("message");
            
            // Lưu tin nhắn vào cơ sở dữ liệu
            boolean success = chatDAO.sendMessage(sessionId, user.getId(), message);
            
            // Trả về kết quả JSON báo thành công hay thất bại
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
        }
    }
    
    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
