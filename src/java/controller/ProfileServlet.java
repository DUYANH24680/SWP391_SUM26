package controller;

import dao.CustomerDAO;
import dao.DeliveryAddressDAO;
import dao.PasswordResetTokenDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Customer;
import model.DeliveryAddress;
import service.UserService;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.List;
import java.util.UUID;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        
        // Auto-login if no user session exists (bypassing login page)
        if (session.getAttribute("user") == null) {
            CustomerDAO customerDAO = new CustomerDAO();
            try {
                Customer defaultCust = customerDAO.findById(1);
                if (defaultCust != null) {
                    session.setAttribute("user", defaultCust);
                    session.setAttribute("userId", defaultCust.getId());
                    session.setAttribute("role", "Customer");
                }
            } finally {
                customerDAO.close();
            }
        }

        Customer user = (Customer) session.getAttribute("user");
        if (user == null) {
            resp.getWriter().println("No customer found in the database. Please add sample data to Customers table first.");
            return;
        }

        // Handle GET actions for addresses (delete, set default)
        String action = req.getParameter("action");
        if (action != null) {
            DeliveryAddressDAO addressDAO = new DeliveryAddressDAO();
            try {
                if ("delete".equals(action)) {
                    String idStr = req.getParameter("id");
                    if (idStr != null) {
                        int id = Integer.parseInt(idStr);
                        addressDAO.delete(id, user.getId());
                        session.setAttribute("message", "Xóa địa chỉ thành công!");
                    }
                } else if ("setDefault".equals(action)) {
                    String idStr = req.getParameter("id");
                    if (idStr != null) {
                        int id = Integer.parseInt(idStr);
                        addressDAO.setDefault(id, user.getId());
                        session.setAttribute("message", "Đã đặt địa chỉ mặc định!");
                    }
                }
            } catch (Exception e) {
                session.setAttribute("error", "Lỗi thao tác địa chỉ: " + e.getMessage());
            } finally {
                addressDAO.close();
            }
            resp.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        // Fetch addresses for display
        DeliveryAddressDAO addressDAO = new DeliveryAddressDAO();
        try {
            List<DeliveryAddress> addresses = addressDAO.findByCustomerId(user.getId());
            req.setAttribute("addresses", addresses);
        } finally {
            addressDAO.close();
        }

        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        Customer user = (Customer) session.getAttribute("user");

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
            case "addAddress":
                handleAddAddress(req, session, user);
                break;
            case "editAddress":
                handleEditAddress(req, session, user);
                break;
            case "changePassword":
                handleChangePassword(req, session, user);
                break;
            case "forgotPassword":
                handleForgotPassword(req, session);
                break;
            case "resetPassword":
                handleResetPassword(req, session);
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

    private void handleAddAddress(HttpServletRequest req, HttpSession session, Customer user) {
        String name = req.getParameter("recipientName");
        String phone = req.getParameter("recipientPhone");
        String addressVal = req.getParameter("address");
        String note = req.getParameter("note");
        boolean isDefault = "1".equals(req.getParameter("isDefault"));

        if (name == null || name.trim().isEmpty() || phone == null || phone.trim().isEmpty() || addressVal == null || addressVal.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng nhập đầy đủ Tên, Số điện thoại và Địa chỉ.");
            return;
        }

        DeliveryAddress da = new DeliveryAddress();
        da.setCustomerId(user.getId());
        da.setRecipientName(name.trim());
        da.setRecipientPhone(phone.trim());
        da.setAddress(addressVal.trim());
        da.setNote(note != null ? note.trim() : "");
        da.setIsDefault(isDefault);

        DeliveryAddressDAO dao = new DeliveryAddressDAO();
        try {
            boolean ok = dao.insert(da);
            if (ok) {
                if (isDefault) {
                    // Get latest inserted address id for this customer to make default
                    List<DeliveryAddress> list = dao.findByCustomerId(user.getId());
                    if (!list.isEmpty()) {
                        dao.setDefault(list.get(0).getId(), user.getId());
                    }
                }
                session.setAttribute("message", "Thêm địa chỉ mới thành công!");
            } else {
                session.setAttribute("error", "Không thể thêm địa chỉ.");
            }
        } finally {
            dao.close();
        }
    }

    private void handleEditAddress(HttpServletRequest req, HttpSession session, Customer user) {
        String idStr = req.getParameter("id");
        String name = req.getParameter("recipientName");
        String phone = req.getParameter("recipientPhone");
        String addressVal = req.getParameter("address");
        String note = req.getParameter("note");
        boolean isDefault = "1".equals(req.getParameter("isDefault"));

        if (idStr == null || name == null || name.trim().isEmpty() || phone == null || phone.trim().isEmpty() || addressVal == null || addressVal.trim().isEmpty()) {
            session.setAttribute("error", "Thông tin sửa địa chỉ không hợp lệ.");
            return;
        }

        int id = Integer.parseInt(idStr);
        DeliveryAddressDAO dao = new DeliveryAddressDAO();
        try {
            DeliveryAddress da = dao.findByIdAndCustomer(id, user.getId());
            if (da == null) {
                session.setAttribute("error", "Không tìm thấy địa chỉ hợp lệ.");
                return;
            }
            da.setRecipientName(name.trim());
            da.setRecipientPhone(phone.trim());
            da.setAddress(addressVal.trim());
            da.setNote(note != null ? note.trim() : "");
            da.setIsDefault(isDefault);

            boolean ok = dao.update(da);
            if (ok) {
                if (isDefault) {
                    dao.setDefault(id, user.getId());
                }
                session.setAttribute("message", "Cập nhật địa chỉ thành công!");
            } else {
                session.setAttribute("error", "Cập nhật địa chỉ thất bại.");
            }
        } finally {
            dao.close();
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

    private void handleForgotPassword(HttpServletRequest req, HttpSession session) {
        String email = req.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng nhập Email.");
            return;
        }

        CustomerDAO customerDAO = new CustomerDAO();
        Customer customer = null;
        try {
            customer = customerDAO.findByUsernameOrEmail(email.trim());
        } finally {
            customerDAO.close();
        }

        if (customer == null) {
            session.setAttribute("error", "Email không tồn tại trong hệ thống.");
            return;
        }

        // Generate reset token
        String token = UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.MINUTE, 30); // 30 mins expiry
        Timestamp expiry = new Timestamp(cal.getTimeInMillis());

        PasswordResetTokenDAO tokenDAO = new PasswordResetTokenDAO();
        try {
            boolean ok = tokenDAO.createToken(customer.getEmail(), token, expiry);
            if (ok) {
                session.setAttribute("message", "Mã khôi phục đã được tạo thành công! Mã của bạn là: " + token + " (Hết hạn sau 30 phút)");
            } else {
                session.setAttribute("error", "Lỗi hệ thống khi tạo mã khôi phục.");
            }
        } finally {
            tokenDAO.close();
        }
    }

    private void handleResetPassword(HttpServletRequest req, HttpSession session) {
        String email = req.getParameter("email");
        String token = req.getParameter("token");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        if (email == null || email.trim().isEmpty() || token == null || token.trim().isEmpty() || newPassword == null || newPassword.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng nhập đầy đủ thông tin.");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            session.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            return;
        }

        PasswordResetTokenDAO tokenDAO = new PasswordResetTokenDAO();
        CustomerDAO customerDAO = new CustomerDAO();
        try {
            boolean isValid = tokenDAO.validateToken(email.trim(), token.trim());
            if (!isValid) {
                session.setAttribute("error", "Mã khôi phục không hợp lệ hoặc đã hết hạn.");
                return;
            }

            Customer c = customerDAO.findByUsernameOrEmail(email.trim());
            if (c != null) {
                customerDAO.updatePassword(c.getId(), newPassword);
                tokenDAO.markTokenAsUsed(token.trim());
                session.setAttribute("message", "Đặt lại mật khẩu thành công! Bạn có thể sử dụng mật khẩu mới.");
            } else {
                session.setAttribute("error", "Email không tồn tại.");
            }
        } finally {
            tokenDAO.close();
            customerDAO.close();
        }
    }
}
