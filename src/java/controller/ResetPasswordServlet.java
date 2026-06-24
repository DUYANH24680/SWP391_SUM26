package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import dao.PasswordResetTokenDAO;
import dao.AccountDAO;
import model.Account;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    private PasswordResetTokenDAO tokenDAO = new PasswordResetTokenDAO();
    private AccountDAO accountDAO = new AccountDAO();

    /**
     * GET - Display reset password form with token validation
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");
        String email = request.getParameter("email");

        // Validate parameters
        if (token == null || token.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Link không hợp lệ");
            request.getRequestDispatcher("reset-password.jsp").forward(request, response);
            return;
        }

        token = token.trim();
        email = email.trim();

        // Get Account by email to obtain account_id
        Account account = accountDAO.findByUsernameOrEmail(email);
        if (account == null) {
            request.setAttribute("error", "Link không hợp lệ");
            request.getRequestDispatcher("reset-password.jsp").forward(request, response);
            return;
        }

        // Validate token (dùng account_id, không dùng email)
        boolean isValidToken = tokenDAO.validateToken(account.getId(), token);
        if (!isValidToken) {
            request.setAttribute("error", "Link đã hết hạn hoặc không tồn tại");
            request.getRequestDispatcher("reset-password.jsp").forward(request, response);
            return;
        }

        // Token is valid, pass it to the form
        request.setAttribute("token", token);
        request.setAttribute("email", email);
        request.getRequestDispatcher("reset-password.jsp").forward(request, response);
    }

    /**
     * POST - Handle password reset
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");
        String email = request.getParameter("email");
        String newPassword = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validate inputs
        if (token == null || token.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Link không hợp lệ");
            request.getRequestDispatcher("reset-password.jsp").forward(request, response);
            return;
        }

        if (newPassword == null || newPassword.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập mật khẩu mới");
            request.setAttribute("token", token);
            request.setAttribute("email", email);
            request.getRequestDispatcher("reset-password.jsp").forward(request, response);
            return;
        }

        if (newPassword.length() < 6) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự");
            request.setAttribute("token", token);
            request.setAttribute("email", email);
            request.getRequestDispatcher("reset-password.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không trùng khớp");
            request.setAttribute("token", token);
            request.setAttribute("email", email);
            request.getRequestDispatcher("reset-password.jsp").forward(request, response);
            return;
        }

        token = token.trim();
        email = email.trim();

        // Get Account by email to obtain account_id
        Account account = accountDAO.findByUsernameOrEmail(email);
        if (account == null) {
            request.setAttribute("error", "Email không tồn tại");
            request.getRequestDispatcher("reset-password.jsp").forward(request, response);
            return;
        }

        // Validate token again (dùng account_id, không dùng email)
        boolean isValidToken = tokenDAO.validateToken(account.getId(), token);
        if (!isValidToken) {
            request.setAttribute("error", "Link đã hết hạn hoặc không tồn tại");
            request.getRequestDispatcher("reset-password.jsp").forward(request, response);
            return;
        }

        // Update password (lưu plain text)
        boolean passwordUpdated = accountDAO.updatePassword(account.getId(), newPassword);
        if (!passwordUpdated) {
            request.setAttribute("error", "Lỗi hệ thống, vui lòng thử lại sau");
            request.setAttribute("token", token);
            request.setAttribute("email", email);
            request.getRequestDispatcher("reset-password.jsp").forward(request, response);
            return;
        }

        // Mark token as used
        tokenDAO.markTokenAsUsed(token);

        // Success - redirect to login
        request.setAttribute("success", "Mật khẩu đã được đặt lại thành công. Vui lòng đăng nhập.");
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}

