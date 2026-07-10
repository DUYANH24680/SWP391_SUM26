package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

import model.Account;
import service.AccountService;
import service.UserService;

/**
 * Handle user registration.
 * GET  → forward to login.jsp (form already lives there)
 * POST → validate + register + redirect to login with success message
 */
@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private final UserService service = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // The form lives on login.jsp; redirect there
        resp.sendRedirect(req.getContextPath() + "/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String fullname       = req.getParameter("fullname");
        String username       = req.getParameter("username");
        String email          = req.getParameter("email");
        String password       = req.getParameter("password");
        String confirmPwd     = req.getParameter("confirmPassword");
        String phone          = req.getParameter("phone");

        // Normalize inputs
        if (fullname   != null) fullname   = fullname.trim();
        if (username   != null) username   = username.trim();
        if (email      != null) email      = email.trim();
        if (phone      != null) phone      = phone.trim();

        AccountService.RegisterResult result = service.register(
                fullname, username, email, password, confirmPwd, phone);

        if (result.isSuccess()) {
            req.getSession().setAttribute("registerSuccess",
                    "Đăng ký thành công! Vui lòng đăng nhập.");
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
        } else {
            // Preserve entered values so user doesn't lose them
            req.setAttribute("registerError", result.error);
            req.setAttribute("val_fullname",  fullname);
            req.setAttribute("val_username",  username);
            req.setAttribute("val_email",     email);
            req.setAttribute("val_phone",     phone);
            // Activate the sign-up panel on login.jsp
            req.setAttribute("showRegister", true);
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }
}
