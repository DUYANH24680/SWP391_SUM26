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

import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.Part;
import Utils.FileUploadUtil;

import java.io.IOException;

@WebServlet("/profile")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 20 * 1024 * 1024
)
public class ProfileServlet extends HttpServlet {

    private final AccountService userService = new AccountService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        
        Account user = (Account) session.getAttribute("Account");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        Account user = (Account) session.getAttribute("Account");

        if (user == null) {
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
                handleUpdateProfile(req, session, user);
                break;
            case "changePassword":
                handleChangePassword(req, session, user);
                break;
        }

        resp.sendRedirect(req.getContextPath() + "/profile");
    }

    private void handleUpdateProfile(HttpServletRequest req, HttpSession session, Account user) {
        String fullname = req.getParameter("fullname");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String address = req.getParameter("address");
        String genderStr = req.getParameter("gender");
        String avatar = user.getAvatar(); // Giữ nguyên avatar cũ mặc định
        
        try {
            Part filePart = req.getPart("avatarFile");
            if (filePart != null && filePart.getSize() > 0) {
                // Validate avatar file type
                String contentType = filePart.getContentType();
                if (contentType == null || !contentType.startsWith("image/")) {
                    session.setAttribute("error", "File tải lên phải là hình ảnh.");
                    return;
                }
                String[] allowedTypes = {"image/jpeg", "image/jpg", "image/png", "image/webp"};
                boolean validType = false;
                for (String type : allowedTypes) {
                    if (type.equals(contentType)) {
                        validType = true;
                        break;
                    }
                }
                if (!validType) {
                    session.setAttribute("error", "Chỉ chấp nhận file ảnh (JPG, PNG, WEBP).");
                    return;
                }
                // Validate avatar file size (max 5MB)
                if (filePart.getSize() > 5 * 1024 * 1024) {
                    session.setAttribute("error", "Kích thước ảnh không được vượt quá 5MB.");
                    return;
                }
                avatar = FileUploadUtil.saveProductImage(filePart, "avatars", req.getServletContext());
            }
        } catch (Exception e) {
            session.setAttribute("error", "Lỗi tải ảnh: " + e.getMessage());
            return;
        }

        Boolean gender = null;
        if (genderStr != null && !genderStr.isEmpty()) {
            gender = "1".equals(genderStr);
        }

        String error = userService.updateProfile(user.getId(), fullname, email, phone, address, gender, avatar);
        if (error != null) {
            session.setAttribute("error", error);
        } else {
            Account updatedUser = userService.getUserById(user.getId());
            session.setAttribute("Account", updatedUser);
            session.setAttribute("user", updatedUser);
            session.setAttribute("message", "Cập nhật hồ sơ thành công!");
        }
    }

    private void handleChangePassword(HttpServletRequest req, HttpSession session, Account user) {
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
