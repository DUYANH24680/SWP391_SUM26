package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.UUID;

import dao.PasswordResetTokenDAO;
import dao.CustomerDAO;
import model.Customer;
import service.EmailService;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private PasswordResetTokenDAO tokenDAO = new PasswordResetTokenDAO();
    private CustomerDAO customerDAO = new CustomerDAO();

    /**
     * GET - Display forgot password form
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
    }

    /**
     * POST - Handle forgot password request
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");

        // Validate input
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập email");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }

        email = email.trim();

        // Check if email exists
        Customer customer = customerDAO.findByUsernameOrEmail(email);
        if (customer == null) {
            // For security, don't reveal if email exists or not
            request.setAttribute("success", "Nếu email tồn tại, bạn sẽ nhận được link đặt lại mật khẩu");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }

        // Generate reset token
        String token = generateResetToken();
        long expiryMs = System.currentTimeMillis() + (1 * 60 * 60 * 1000); // 1 hour
        Timestamp expiryTime = new Timestamp(expiryMs);

        // Save token to database
        boolean tokenSaved = tokenDAO.createToken(email, token, expiryTime);
        if (!tokenSaved) {
            request.setAttribute("error", "Lỗi hệ thống, vui lòng thử lại sau");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }

        // Build reset link
        String resetLink = buildResetLink(request, token, email);

        // Send email
        boolean emailSent = EmailService.sendPasswordResetEmail(email, resetLink, customer.getFullname());
        if (!emailSent) {
            request.setAttribute("error", "Không thể gửi email, vui lòng thử lại sau");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }

        // Success message
        request.setAttribute("success", "Hướng dẫn đặt lại mật khẩu đã được gửi đến email của bạn");
        request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
    }

    /**
     * Generate unique reset token
     */
    private String generateResetToken() {
        return UUID.randomUUID().toString();
    }

    /**
     * Build password reset link
     */
    private String buildResetLink(HttpServletRequest request, String token, String email) {
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String contextPath = request.getContextPath();

        String port = (scheme.equals("http") && serverPort == 80) || (scheme.equals("https") && serverPort == 443)
                ? ""
                : ":" + serverPort;

        return scheme + "://" + serverName + port + contextPath + "/reset-password?token=" + token + "&email=" + encodeEmail(email);
    }

    /**
     * Simple email encoding for URL
     */
    private String encodeEmail(String email) {
        try {
            return java.net.URLEncoder.encode(email, "UTF-8");
        } catch (Exception e) {
            return email;
        }
    }
}
