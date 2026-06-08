package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.DeliveryAddress;
import service.UserService;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.Part;
import java.io.File;
import java.nio.file.Paths;
import java.util.UUID;

@WebServlet("/profile")
@MultipartConfig(fileSizeThreshold = 1024 * 1024,
  maxFileSize = 1024 * 1024 * 5, 
  maxRequestSize = 1024 * 1024 * 5 * 5)
public class ProfileServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        
        User sessionUser = (User) session.getAttribute("user");
        if (sessionUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // Always fetch the freshest user data from the DB for View Profile
        User freshUser = userService.getUserById(sessionUser.getId());
        if (freshUser == null) {
            // User might have been deleted or banned
            session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // Fetch addresses
        dao.DeliveryAddressDAO addressDAO = new dao.DeliveryAddressDAO();
        List<DeliveryAddress> addresses = addressDAO.findByCustomerId(sessionUser.getId());
        req.setAttribute("addresses", addresses);

        // Update the session with fresh data
        session.setAttribute("user", freshUser);

        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        User user = (User) session.getAttribute("user");

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

    private void handleUpdateProfile(HttpServletRequest req, HttpSession session, User user) {
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

        try {
            Part filePart = req.getPart("avatarFile");
            if (filePart != null && filePart.getSize() > 0) {
                // Check size: max 2MB
                if (filePart.getSize() > 1024 * 1024 * 2) {
                    session.setAttribute("error", "Kích thước ảnh đại diện không được vượt quá 2MB.");
                    return;
                }
                
                // Check MIME type
                String contentType = filePart.getContentType();
                if (contentType == null || !contentType.startsWith("image/")) {
                    session.setAttribute("error", "Định dạng file không hợp lệ. Chỉ chấp nhận các file ảnh.");
                    return;
                }

                String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                // Get extension
                String ext = "";
                int i = fileName.lastIndexOf('.');
                if (i > 0) {
                    ext = fileName.substring(i).toLowerCase();
                }
                
                if (!ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png") && !ext.equals(".gif") && !ext.equals(".webp")) {
                    session.setAttribute("error", "Định dạng ảnh không hỗ trợ. Chỉ chấp nhận JPG, JPEG, PNG, GIF, WEBP.");
                    return;
                }

                String newFileName = UUID.randomUUID().toString() + ext;
                
                String uploadPath = req.getServletContext().getRealPath("") + File.separator + "uploads";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdir();
                
                filePart.write(uploadPath + File.separator + newFileName);
                avatar = "uploads/" + newFileName; // Set avatar to the new uploaded local path
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Đã xảy ra lỗi trong quá trình tải ảnh lên.");
            return;
        }

        String error = userService.updateProfile(user.getId(), fullname, email, phone, address, gender, avatar);
        if (error != null) {
            session.setAttribute("error", error);
        } else {
            User updatedUser = userService.getUserById(user.getId());
            session.setAttribute("user", updatedUser);
            session.setAttribute("message", "Cập nhật hồ sơ thành công!");
        }
    }

    private void handleChangePassword(HttpServletRequest req, HttpSession session, User user) {
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
