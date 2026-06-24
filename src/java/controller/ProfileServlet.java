package controller;

import dao.AccountDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import service.AccountService;

import java.io.IOException;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private final AccountService accountService = new AccountService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        
        // Auto-login if no Account session exists (bypassing login page)
        if (session.getAttribute("Account") == null) {
            AccountDAO accountDAO = new AccountDAO();
            try {
                Account defaultAccount = accountDAO.findById(1);
                if (defaultAccount != null) {
                    session.setAttribute("Account", defaultAccount);
                    session.setAttribute("userId", defaultAccount.getId());
                    session.setAttribute("role", defaultAccount.getRoleName());
                }
            } finally {
                accountDAO.close();
            }
        }

        Account Account = (Account) session.getAttribute("Account");
        if (Account == null) {
            resp.getWriter().println("No Account found in the database. Please add sample data to Accounts table first.");
            return;
        }

        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        Account Account = (Account) session.getAttribute("Account");

        if (Account == null) {
            resp.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        switch (action) {
            case "updateProfile":
                handleUpdateProfile(req, session, Account);
                break;
            case "changePassword":
                handleChangePassword(req, session, Account);
                break;
        }

        resp.sendRedirect(req.getContextPath() + "/profile");
    }

    private void handleUpdateProfile(HttpServletRequest req, HttpSession session, Account Account) {
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

        String error = accountService.updateProfile(Account.getId(), fullname, email, phone, address, gender, avatar);
        if (error != null) {
            session.setAttribute("error", error);
        } else {
            Account updatedUser = accountService.getAccountById(Account.getId());
            session.setAttribute("Account", updatedUser);
            session.setAttribute("message", "Cập nhật hồ sơ thành công!");
        }
    }

    private void handleChangePassword(HttpServletRequest req, HttpSession session, Account Account) {
        String currentPassword = req.getParameter("currentPassword");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        String error = accountService.changePassword(Account.getId(), currentPassword, newPassword, confirmPassword);
        if (error != null) {
            session.setAttribute("error", error);
        } else {
            session.setAttribute("message", "Đổi mật khẩu thành công!");
        }
    }
}

