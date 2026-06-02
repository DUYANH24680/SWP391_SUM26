package service;

import dao.CustomerDAO;
import model.Customer;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * UserService - All business logic for User profile management.
 * No request/response dependencies here.
 */
public class UserService {

    // ---- Profile ----

    public String updateProfile(int customerId, String fullname, String email, String phone, String address, Boolean gender, String avatar) {
        if (fullname == null || fullname.trim().isEmpty()) {
            return "Họ và tên không được để trống.";
        }
        fullname = fullname.trim();
        if (fullname.length() < 2 || fullname.length() > 50) {
            return "Họ và tên phải từ 2 đến 50 ký tự.";
        }
        if (!fullname.matches("^[\\p{L}\\s]+$")) {
            return "Họ và tên chỉ được chứa chữ cái và khoảng trắng.";
        }

        if (email == null || email.trim().isEmpty()) {
            return "Email không được để trống.";
        }
        email = email.trim();
        if (email.length() > 100) {
            return "Email không được vượt quá 100 ký tự.";
        }
        if (!email.matches("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")) {
            return "Email không đúng định dạng.";
        }

        if (phone == null || phone.trim().isEmpty()) {
            return "Số điện thoại không được để trống.";
        }
        phone = phone.trim();
        if (!phone.matches("^0[35789][0-9]{8}$")) {
            return "Số điện thoại không hợp lệ (phải bắt đầu bằng 03, 05, 07, 08, 09 và gồm 10 chữ số).";
        }

        if (gender == null) {
            return "Vui lòng chọn giới tính.";
        }

        if (address == null || address.trim().isEmpty()) {
            return "Địa chỉ không được để trống.";
        }
        address = address.trim();
        if (address.length() > 200) {
            return "Địa chỉ không được vượt quá 200 ký tự.";
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
            if (!hashPassword(currentPassword).equals(c.getPasswordHash())) {
                return "Mật khẩu hiện tại không đúng.";
            }
            boolean ok = dao.updatePassword(customerId, hashPassword(newPassword));
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
