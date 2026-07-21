package service;

import dao.AccountDAO;
import model.Account;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * AccountService - All business logic for Account profile management.
 */
public class AccountService {
    
    
        /**
     * Register result: {errorMessage, accountObject}
     */
    public static class RegisterResult {
        public final String error;
        public final Account account;
        public RegisterResult(String error, Account account) { this.error = error; this.account = account; }
        public boolean isSuccess() { return error == null && account != null; }
    }

    /**
     * Validate and register a new customer account.
     * Returns RegisterResult with error message or new Account object.
     */
    public RegisterResult register(String fullname, String username, String email, String password,
                                   String confirmPassword, String phone) {
        // ---- 1. Validate required fields ----
        if (fullname == null || fullname.trim().isEmpty()) {
            return new RegisterResult("Họ và tên không được để trống.", null);
        }
        if (fullname.trim().length() < 2 || fullname.trim().length() > 100) {
            return new RegisterResult("Họ và tên phải từ 2 đến 100 ký tự.", null);
        }
        if (username == null || username.trim().isEmpty()) {
            return new RegisterResult("Tên đăng nhập không được để trống.", null);
        }
        if (username.trim().length() < 4 || username.trim().length() > 50) {
            return new RegisterResult("Tên đăng nhập phải từ 4 đến 50 ký tự.", null);
        }
        if (!username.trim().matches("^[a-zA-Z0-9_]+$")) {
            return new RegisterResult("Tên đăng nhập chỉ chứa chữ cái, số và dấu gạch dưới.", null);
        }
        if (email == null || email.trim().isEmpty()) {
            return new RegisterResult("Email không được để trống.", null);
        }
        if (!email.trim().matches("^[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$")) {
            return new RegisterResult("Email không đúng định dạng.", null);
        }
        if (password == null || password.isEmpty()) {
            return new RegisterResult("Mật khẩu không được để trống.", null);
        }
        if (password.length() < 6) {
            return new RegisterResult("Mật khẩu phải có ít nhất 6 ký tự.", null);
        }
        if (!password.equals(confirmPassword)) {
            return new RegisterResult("Xác nhận mật khẩu không khớp,Vui lòng nhập lại.", null);
        }
        if (phone != null && !phone.trim().isEmpty() && !phone.trim().matches("^0[0-9]{9,10}$")) {
            return new RegisterResult("Số điện thoại không hợp lệ (phải bắt đầu bằng 0, 10-11 chữ số).", null);
        }

        AccountDAO dao = new AccountDAO();
        try {
            // ---- 2. Check email uniqueness ----
            if (dao.isEmailExists(email.trim().toLowerCase())) {
                return new RegisterResult("Email này đã được đăng ký. Vui lòng sử dụng email khác.", null);
            }

            // ---- 3. Check username uniqueness ----
            if (dao.isUsernameTaken(username.trim())) {
                return new RegisterResult("Tên đăng nhập đã tồn tại. Vui lòng chọn tên khác.", null);
            }

            // ---- 4. Insert plain text password ----
            int newId = dao.register(fullname.trim(), username.trim(), password,
                                      email.trim().toLowerCase(), phone, 3, null);

            if (newId <= 0) {
                return new RegisterResult("Đăng ký thất bại. Vui lòng thử lại sau.", null);
            }

            // ---- 5. Reload account ----
            Account newAccount = dao.findById(newId);
            if (newAccount == null) {
                return new RegisterResult("Đăng ký thành công nhưng không thể tải thông tin tài khoản.", null);
            }
            System.out.println("[UserService] register success: " + newAccount.getUsername());
            return new RegisterResult(null, newAccount);

        } finally {
            dao.close();
        }
    }

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
            String storedHash = c.getPasswordHash();
            if (!currentPassword.equals(storedHash) && !hashPassword(currentPassword).equals(storedHash)) {
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
            
            if (account == null) {
                return null;
            }
            
            String storedHash = account.getPasswordHash();
            
            // Thử so sánh plain text trước (cho tài khoản cũ)
            if (storedHash != null && storedHash.equals(password)) {
                return account;
            }
            
            // Thử so sánh SHA-256 hash (cho tài khoản mới)
            String hashedPassword = hashPassword(password);
            if (storedHash != null && storedHash.equals(hashedPassword)) {
                return account;
            }
            
            return null;
        } finally {
            dao.close();
        }
    }
}
