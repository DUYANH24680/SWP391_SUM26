package service;

import dao.AccountDAO;
import model.Account;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * AccountService - All business logic for Account profile management.
 */
public class AccountService {

    // ---- Profile ----

    public String updateProfile(int userId, String fullname, String email, String phone, String address, Boolean gender, String avatar) {
        if (fullname == null || fullname.trim().isEmpty()) {
            return "Họ và tên không được để trống.";
        }
        if (fullname.trim().length() < 2 || fullname.trim().length() > 50) {
            return "Họ và tên phải từ 2-50 ký tự.";
        }
        if (email == null || email.trim().isEmpty()) {
            return "Email không được để trống.";
        }
        if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            return "Email không đúng định dạng.";
        }
        if (phone != null && !phone.isEmpty() && !phone.matches("^[0-9]{9,11}$")) {
            return "Số điện thoại không hợp lệ (9-11 chữ số).";
        }
        if (address != null && address.length() > 200) {
            return "Địa chỉ không được vượt quá 200 ký tự.";
        }
        AccountDAO dao = new AccountDAO();
        try {
            if (dao.isEmailTaken(email.trim(), userId)) {
                return "Email này đã được sử dụng bởi một tài khoản khác.";
            }
            boolean ok = dao.updateProfile(userId, fullname.trim(), email.trim(), phone, address, gender, avatar);
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
    public String changePassword(int userId, String currentPassword, String newPassword, String confirmPassword) {
        if (newPassword == null || newPassword.length() < 6) {
            return "Mật khẩu mới phải có ít nhất 6 ký tự.";
        }
        if (!newPassword.equals(confirmPassword)) {
            return "Xác nhận mật khẩu không khớp.";
        }
        AccountDAO dao = new AccountDAO();
        try {
            Account c = dao.findById(userId);
            if (c == null) return "Không tìm thấy tài khoản.";
            if (!currentPassword.equals(c.getPasswordHash())) {
                return "Mật khẩu hiện tại không đúng.";
            }
            boolean ok = dao.updatePassword(userId, newPassword);
            return ok ? null : "Đổi mật khẩu thất bại. Vui lòng thử lại.";
        } finally {
            dao.close();
        }
    }

    /**
     * Get a fresh account object.
     */
    public Account getUserById(int id) {
        AccountDAO dao = new AccountDAO();
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
    
    public Account login(String username, String password) {
        // Validate basic
        if (username == null || username.trim().isEmpty()) {
            return null;
        }
        if (password == null || password.trim().isEmpty()) {
            return null;
        }

        // Lấy dữ liệu từ DB (DAO)
        AccountDAO dao = new AccountDAO();
        try {
            Account account = dao.findByUsernameOrEmail(username);
            
            // Kiểm tra (Logic)
            if (account != null && account.getPasswordHash().equals(password)) {
                return account;
            }
            
            return null;
        } finally {
            dao.close();
        }
    }
}
