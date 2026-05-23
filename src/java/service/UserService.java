package service;

import dao.CustomerDAO;
import dao.DBContext;
import dao.StaffDAO;
import model.Customer;
import model.Staff;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

/**
 * UserService - All business logic for User authentication and profile management.
 * No request/response dependencies here.
 */
public class UserService {

    // ---- Authentication ----

    /**
     * Login validation. Returns the Customer if credentials match, null otherwise.
     * Also checks that account status = 1 (active) and not deleted.
     */
    public Customer login(String usernameOrEmail, String plainPassword) {
        CustomerDAO dao = new CustomerDAO();
        try {
            Customer c = dao.findByUsernameOrEmail(usernameOrEmail);
            if (c == null) return null;
            if (c.getStatus() != 1) return null;        // blocked / inactive
            if (!plainPassword.equals(c.getPasswordHash())) return null;
            return c;
        } finally {
            dao.close();
        }
    }

    /**
     * Staff Login validation. Returns the Staff if credentials match, null otherwise.
     * Also checks that account status = 1 (active) and not deleted.
     */
    public Staff loginStaff(String usernameOrEmail, String plainPassword) {
        StaffDAO dao = new StaffDAO();
        try {
            Staff s = dao.findByUsernameOrEmail(usernameOrEmail);
            if (s == null) return null;
            if (s.getStatus() != 1) return null;        // blocked / inactive
            if (!plainPassword.equals(s.getPasswordHash())) return null;
            return s;
        } finally {
            dao.close();
        }
    }

    // ---- Profile ----

    public String updateProfile(int customerId, String fullname, String email, String phone, String address, Boolean gender, String avatar) {
        if (fullname == null || fullname.trim().isEmpty()) {
            return "Họ và tên không được để trống.";
        }
        if (email == null || email.trim().isEmpty()) {
            return "Email không được để trống.";
        }
        if (!email.contains("@")) {
            return "Email không đúng định dạng.";
        }
        if (phone != null && !phone.isEmpty() && !phone.matches("^[0-9]{9,11}$")) {
            return "Số điện thoại không hợp lệ (9-11 chữ số).";
        }
        CustomerDAO dao = new CustomerDAO();
        try {
            if (dao.isEmailTaken(email.trim(), customerId)) {
                return "Email này đã được sử dụng bởi một tài khoản khác.";
            }
            boolean ok = dao.updateProfile(customerId, fullname.trim(), email.trim(), phone, address, gender, avatar);
            return ok ? null : "Cập nhật thất bại. Vui lòng thử lại.";
        } finally {
            dao.close();
        }
    }

    // ---- Change Password ----

    /**
     * Change password after verifying the current password.
     * Returns an error message or null on success.
     */
    public String changePassword(int customerId, String currentPassword, String newPassword, String confirmPassword) {
        if (newPassword == null || newPassword.length() < 6) {
            return "Mật khẩu mới phải có ít nhất 6 ký tự.";
        }
        if (!newPassword.equals(confirmPassword)) {
            return "Xác nhận mật khẩu không khớp.";
        }
        CustomerDAO dao = new CustomerDAO();
        try {
            Customer c = dao.findById(customerId);
            if (c == null) return "Không tìm thấy tài khoản.";
            if (!currentPassword.equals(c.getPasswordHash())) {
                return "Mật khẩu hiện tại không đúng.";
            }
            boolean ok = dao.updatePassword(customerId, newPassword);
            return ok ? null : "Đổi mật khẩu thất bại. Vui lòng thử lại.";
        } finally {
            dao.close();
        }
    }

    /**
     * Get a fresh customer object (for re-loading after update).
     */
    public Customer getCustomerById(int id) {
        CustomerDAO dao = new CustomerDAO();
        try {
            return dao.findById(id);
        } finally {
            dao.close();
        }
    }

    // ---- Password Hashing (SHA-256 + Hex) ----
    public static String hashPassword(String plain) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(plain.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 not available", e);
        }
    }
}
