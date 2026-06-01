package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Customer;
import model.Seller;
import service.UserService;

import java.io.IOException;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(true);

        if (session.getAttribute("user") == null && session.getAttribute("account") == null) {
            resp.getWriter().println("No account found. Please login first.");
            return;
        }

        Object user = session.getAttribute("user");
        if (user == null) {
            user = session.getAttribute("account");
        }
        if (user == null || (!(user instanceof Customer) && !(user instanceof Seller))) {
            resp.getWriter().println("No account found. Please login first.");
            return;
        }

        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        Object user = session.getAttribute("user");
        if (user == null) {
            user = session.getAttribute("account");
        }

        if (user == null || (!(user instanceof Customer) && !(user instanceof Seller))) {
            resp.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        int userId = 0;
        boolean isSeller = false;
        if (user instanceof Customer) {
            userId = ((Customer) user).getId();
            isSeller = false;
        } else if (user instanceof Seller) {
            userId = ((Seller) user).getId();
            isSeller = true;
        }

        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        switch (action) {
            case "updateProfile":
                handleUpdateProfile(req, session, userId, isSeller);
                break;
            case "changePassword":
                handleChangePassword(req, session, userId, user, isSeller);
                break;
        }

        resp.sendRedirect(req.getContextPath() + "/profile");
    }

    private void handleUpdateProfile(HttpServletRequest req, HttpSession session, int userId, boolean isSeller) {
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

        String err;
        if (isSeller) {
            err = userService.updateSellerProfile(userId, fullname, email, phone, address, gender, avatar);
            if (err == null) {
                session.setAttribute("account", userService.getSellerById(userId));
                session.setAttribute("message", "Cap nhat ho so thanh cong!");
            } else {
                session.setAttribute("error", err);
            }
        } else {
            err = userService.updateProfile(userId, fullname, email, phone, address, gender, avatar);
            if (err == null) {
                session.setAttribute("user", userService.getCustomerById(userId));
                session.setAttribute("message", "Cap nhat ho so thanh cong!");
            } else {
                session.setAttribute("error", err);
            }
        }
    }

    private void handleChangePassword(HttpServletRequest req, HttpSession session,
                                     int userId, Object user, boolean isSeller) {
        String currentPassword = req.getParameter("currentPassword");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        String passHash;
        if (user instanceof Customer) {
            passHash = ((Customer) user).getPasswordHash();
        } else if (user instanceof Seller) {
            passHash = ((Seller) user).getPasswordHash();
        } else {
            session.setAttribute("error", "Khong the xac minh mat khau.");
            return;
        }

        if (currentPassword == null || !currentPassword.equals(passHash)) {
            session.setAttribute("error", "Mat khau hien tai khong dung.");
            return;
        }

        String err;
        if (isSeller) {
            err = userService.changeSellerPassword(userId, currentPassword, newPassword, confirmPassword);
            if (err == null) {
                session.setAttribute("account", userService.getSellerById(userId));
                session.setAttribute("message", "Doi mat khau thanh cong!");
            } else {
                session.setAttribute("error", err);
            }
        } else {
            err = userService.changePassword(userId, currentPassword, newPassword, confirmPassword);
            if (err == null) {
                session.setAttribute("user", userService.getCustomerById(userId));
                session.setAttribute("message", "Doi mat khau thanh cong!");
            } else {
                session.setAttribute("error", err);
            }
        }
    }
}
