package controller;

import dao.CustomerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Customer;
import service.UserService;

import java.io.IOException;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        
        Customer sessionUser = (Customer) session.getAttribute("user");
        if (sessionUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // Always fetch the freshest user data from the DB for View Profile
        Customer freshUser = userService.getCustomerById(sessionUser.getId());
        if (freshUser == null) {
            // User might have been deleted or banned
            session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // Update the session with fresh data
        session.setAttribute("user", freshUser);

        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        Customer user = (Customer) session.getAttribute("user");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        switch (action) {
            case "updateProfile":
                handleUpdateProfile(req, session, user);
                break;
            case "changePassword":
                handleChangePassword(req, session, user);
                break;
        }

        resp.sendRedirect(req.getContextPath() + "/profile");
    }

    private void handleUpdateProfile(HttpServletRequest req, HttpSession session, Customer user) {
        String fullname = req.getParameter("fullname");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String address = req.getParameter("address");
        String genderStr = req.getParameter("gender");
        String avatar = req.getParameter("avatar");

        Boolean gender = null;
        if (genderStr != null && !genderStr.isEmpty()) {
            gender = "1".equals(genderStr);
        }

        String error = userService.updateProfile(user.getId(), fullname, email, phone, address, gender, avatar);
        if (error != null) {
            session.setAttribute("error", error);
        } else {
            Customer updatedUser = userService.getCustomerById(user.getId());
            session.setAttribute("user", updatedUser);
            session.setAttribute("message", "Cập nhật hồ sơ thành công!");
        }
    }

    private void handleChangePassword(HttpServletRequest req, HttpSession session, Customer user) {
        String currentPassword = req.getParameter("currentPassword");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        String error = userService.changePassword(user.getId(), currentPassword, newPassword, confirmPassword);
        if (error != null) {
            session.setAttribute("error", error);
        } else {
            session.setAttribute("message", "Đổi mật khẩu thành công!");
        }
    }
}
