package service;

import dao.AccountDAO;
import model.Account;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * AdminAccountService - Business logic for Admin account management (Staff/Shipper).
 */
public class AdminAccountService {
    
    // ==================== Staff Management ====================
    
    /**
     * Get all staff accounts.
     */
    public List<Account> getAllStaff() {
        AccountDAO dao = new AccountDAO();
        try {
            return dao.getAllStaff();
        } finally {
            dao.close();
        }
    }
    
    /**
     * Search staff by keyword.
     */
    public List<Account> searchStaff(String keyword) {
        AccountDAO dao = new AccountDAO();
        try {
            if (keyword == null || keyword.trim().isEmpty()) {
                return dao.getAllStaff();
            }
            return dao.searchStaff(keyword.trim());
        } finally {
            dao.close();
        }
    }
    
    /**
     * Get staff account by ID.
     */
    public Account getStaffById(int id) {
        AccountDAO dao = new AccountDAO();
        try {
            return dao.findByIdIncludeAll(id);
        } finally {
            dao.close();
        }
    }
    
    /**
     * Add a new staff account.
     * Returns error message or null on success.
     */
    public String addStaff(String fullname, String username, String password, String email, String phone, String address) {
        // Validate
        String error = validateAccountInput(fullname, username, password, email, phone);
        if (error != null) {
            return error;
        }
        
        AccountDAO dao = new AccountDAO();
        try {
            // Check username uniqueness
            if (dao.isUsernameTaken(username.trim())) {
                return "Tên đăng nhập đã tồn tại.";
            }
            
            // Check email uniqueness
            if (dao.isEmailExists(email.trim().toLowerCase())) {
                return "Email đã được sử dụng bởi tài khoản khác.";
            }
            
            // Hash password and create account
            String hashedPassword = hashPassword(password);
            int newId = dao.addStaff(
                fullname.trim(),
                username.trim(),
                hashedPassword,
                email.trim().toLowerCase(),
                phone != null ? phone.trim() : null,
                address
            );
            
            if (newId <= 0) {
                return "Không thể tạo tài khoản. Vui lòng thử lại.";
            }
            
            System.out.println("[AdminAccountService] Staff created: id=" + newId + ", username=" + username);
            return null;
            
        } finally {
            dao.close();
        }
    }

    /**
     * Add a new shipper account.
     * Returns error message or null on success.
     */
    public String addShipper(String fullname, String username, String password, String email, String phone, String address) {
        // Validate
        String error = validateAccountInput(fullname, username, password, email, phone);
        if (error != null) {
            return error;
        }
        
        AccountDAO dao = new AccountDAO();
        try {
            // Check username uniqueness
            if (dao.isUsernameTaken(username.trim())) {
                return "Tên đăng nhập đã tồn tại.";
            }
            
            // Check email uniqueness
            if (dao.isEmailExists(email.trim().toLowerCase())) {
                return "Email đã được sử dụng bởi tài khoản khác.";
            }
            
            // Hash password and create account
            String hashedPassword = hashPassword(password);
            int newId = dao.addShipper(
                fullname.trim(),
                username.trim(),
                hashedPassword,
                email.trim().toLowerCase(),
                phone != null ? phone.trim() : null,
                address
            );
            
            if (newId <= 0) {
                return "Không thể tạo tài khoản. Vui lòng thử lại.";
            }
            
            System.out.println("[AdminAccountService] Shipper created: id=" + newId + ", username=" + username);
            return null;
            
        } finally {
            dao.close();
        }
    }
    
    /**
     * Update staff account.
     */
    public String updateStaff(int id, String fullname, String email, String phone, String address, Boolean gender) {
        if (id <= 0) {
            return "ID tài khoản không hợp lệ.";
        }
        
        // Validate
        if (fullname == null || fullname.trim().isEmpty()) {
            return "Họ và tên không được để trống.";
        }
        if (fullname.trim().length() < 2 || fullname.trim().length() > 100) {
            return "Họ và tên phải từ 2 đến 100 ký tự.";
        }
        if (email == null || email.trim().isEmpty()) {
            return "Email không được để trống.";
        }
        if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            return "Email không đúng định dạng.";
        }
        if (phone != null && !phone.trim().isEmpty() && !phone.matches("^0[0-9]{9,10}$")) {
            return "Số điện thoại không hợp lệ.";
        }
        
        AccountDAO dao = new AccountDAO();
        try {
            Account existing = dao.findByIdIncludeAll(id);
            if (existing == null) {
                return "Tài khoản không tồn tại.";
            }
            if (!"staff".equalsIgnoreCase(existing.getRoleName())) {
                return "Tài khoản không phải là nhân viên.";
            }
            
            // Check email uniqueness (excluding current account)
            if (dao.isEmailTaken(email.trim().toLowerCase(), id)) {
                return "Email đã được sử dụng bởi tài khoản khác.";
            }
            
            boolean success = dao.updateStaff(
                id,
                fullname.trim(),
                email.trim().toLowerCase(),
                phone != null ? phone.trim() : null,
                address,
                gender
            );
            
            if (!success) {
                return "Cập nhật thất bại. Vui lòng thử lại.";
            }
            
            System.out.println("[AdminAccountService] Staff updated: id=" + id);
            return null;
            
        } finally {
            dao.close();
        }
    }
    
    /**
     * Lock staff account.
     */
    public boolean lockStaff(int id) {
        AccountDAO dao = new AccountDAO();
        try {
            return dao.lockAccount(id);
        } finally {
            dao.close();
        }
    }
    
    /**
     * Unlock staff account.
     */
    public boolean unlockStaff(int id) {
        AccountDAO dao = new AccountDAO();
        try {
            return dao.unlockAccount(id);
        } finally {
            dao.close();
        }
    }
    
    /**
     * Delete (deactivate) staff account.
     */
    public boolean deleteStaff(int id) {
        AccountDAO dao = new AccountDAO();
        try {
            return dao.deleteAccount(id);
        } finally {
            dao.close();
        }
    }

    /**
     * Hard delete staff account from database (permanent).
     */
    public boolean hardDeleteStaff(int id) {
        AccountDAO dao = new AccountDAO();
        try {
            return dao.hardDeleteAccount(id);
        } finally {
            dao.close();
        }
    }

    /**
     * Get error message for hard delete failure.
     */
    public String getHardDeleteErrorMessage(int id, Exception e) {
        AccountDAO dao = new AccountDAO();
        try {
            return dao.getHardDeleteErrorMessage(id, e);
        } finally {
            dao.close();
        }
    }
    
    // ==================== Shipper Management ====================
    
    /**
     * Get all shipper accounts.
     */
    public List<Account> getAllShippers() {
        AccountDAO dao = new AccountDAO();
        try {
            return dao.getAllShippers();
        } finally {
            dao.close();
        }
    }
    
    /**
     * Search shipper by keyword.
     */
    public List<Account> searchShippers(String keyword) {
        AccountDAO dao = new AccountDAO();
        try {
            if (keyword == null || keyword.trim().isEmpty()) {
                return dao.getAllShippers();
            }
            return dao.searchShippers(keyword.trim());
        } finally {
            dao.close();
        }
    }
    
    /**
     * Get available shippers (for assignment).
     */
    public List<Account> getAvailableShippers() {
        // Get all shippers and return as available
        return getAllShippers();
    }
    
    /**
     * Get shipper account by ID.
     */
    public Account getShipperById(int id) {
        AccountDAO dao = new AccountDAO();
        try {
            return dao.findByIdIncludeAll(id);
        } finally {
            dao.close();
        }
    }

    /**
     * Get shipper account by username.
     */
    public Account getShipperByUsername(String username) {
        AccountDAO dao = new AccountDAO();
        try {
            Account account = dao.findByUsername(username);
            if (account != null && "shipper".equalsIgnoreCase(account.getRoleName())) {
                return account;
            }
            return null;
        } finally {
            dao.close();
        }
    }

    /**
     * Get staff account by username.
     */
    public Account getStaffByUsername(String username) {
        AccountDAO dao = new AccountDAO();
        try {
            Account account = dao.findByUsername(username);
            if (account != null && "staff".equalsIgnoreCase(account.getRoleName())) {
                return account;
            }
            return null;
        } finally {
            dao.close();
        }
    }
    
    /**
     * Update shipper account.
     */
    public String updateShipper(int id, String fullname, String email, String phone, String address, Boolean gender) {
        if (id <= 0) {
            return "ID tài khoản không hợp lệ.";
        }
        
        // Validate
        if (fullname == null || fullname.trim().isEmpty()) {
            return "Họ và tên không được để trống.";
        }
        if (fullname.trim().length() < 2 || fullname.trim().length() > 100) {
            return "Họ và tên phải từ 2 đến 100 ký tự.";
        }
        if (email == null || email.trim().isEmpty()) {
            return "Email không được để trống.";
        }
        if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            return "Email không đúng định dạng.";
        }
        if (phone != null && !phone.trim().isEmpty() && !phone.matches("^0[0-9]{9,10}$")) {
            return "Số điện thoại không hợp lệ.";
        }
        
        AccountDAO dao = new AccountDAO();
        try {
            Account existing = dao.findByIdIncludeAll(id);
            if (existing == null) {
                return "Tài khoản không tồn tại.";
            }
            if (!"shipper".equalsIgnoreCase(existing.getRoleName())) {
                return "Tài khoản không phải là shipper.";
            }
            
            // Check email uniqueness (excluding current account)
            if (dao.isEmailTaken(email.trim().toLowerCase(), id)) {
                return "Email đã được sử dụng bởi tài khoản khác.";
            }
            
            boolean success = dao.updateShipper(
                id,
                fullname.trim(),
                email.trim().toLowerCase(),
                phone != null ? phone.trim() : null,
                address,
                gender
            );
            
            if (!success) {
                return "Cập nhật thất bại. Vui lòng thử lại.";
            }
            
            System.out.println("[AdminAccountService] Shipper updated: id=" + id);
            return null;
            
        } finally {
            dao.close();
        }
    }
    
    /**
     * Lock shipper account.
     */
    public boolean lockShipper(int id) {
        AccountDAO dao = new AccountDAO();
        try {
            return dao.lockAccount(id);
        } finally {
            dao.close();
        }
    }
    
    /**
     * Unlock shipper account.
     */
    public boolean unlockShipper(int id) {
        AccountDAO dao = new AccountDAO();
        try {
            return dao.unlockAccount(id);
        } finally {
            dao.close();
        }
    }
    
    /**
     * Delete (deactivate) shipper account.
     */
    public boolean deleteShipper(int id) {
        AccountDAO dao = new AccountDAO();
        try {
            return dao.deleteAccount(id);
        } finally {
            dao.close();
        }
    }

    /**
     * Hard delete shipper account from database (permanent).
     */
    public boolean hardDeleteShipper(int id) {
        AccountDAO dao = new AccountDAO();
        try {
            return dao.hardDeleteAccount(id);
        } finally {
            dao.close();
        }
    }

    /**
     * Get error message for hard delete failure.
     */
    public String getHardDeleteErrorMessageForShipper(int id, Exception e) {
        AccountDAO dao = new AccountDAO();
        try {
            return dao.getHardDeleteErrorMessage(id, e);
        } finally {
            dao.close();
        }
    }
    
    // ==================== Helper Methods ====================
    
    private String validateAccountInput(String fullname, String username, String password, String email, String phone) {
        if (fullname == null || fullname.trim().isEmpty()) {
            return "Họ và tên không được để trống.";
        }
        if (fullname.trim().length() < 2 || fullname.trim().length() > 100) {
            return "Họ và tên phải từ 2 đến 100 ký tự.";
        }
        if (username == null || username.trim().isEmpty()) {
            return "Tên đăng nhập không được để trống.";
        }
        if (username.trim().length() < 4 || username.trim().length() > 50) {
            return "Tên đăng nhập phải từ 4 đến 50 ký tự.";
        }
        if (!username.trim().matches("^[a-zA-Z0-9_]+$")) {
            return "Tên đăng nhập chỉ chứa chữ cái, số và dấu gạch dưới.";
        }
        if (email == null || email.trim().isEmpty()) {
            return "Email không được để trống.";
        }
        if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            return "Email không đúng định dạng.";
        }
        if (password == null || password.isEmpty()) {
            return "Mật khẩu không được để trống.";
        }
        if (password.length() < 6) {
            return "Mật khẩu phải có ít nhất 6 ký tự.";
        }
        if (phone != null && !phone.trim().isEmpty() && !phone.matches("^0[0-9]{9,10}$")) {
            return "Số điện thoại không hợp lệ (phải bắt đầu bằng 0, 10-11 chữ số).";
        }
        return null;
    }
    
    private String hashPassword(String plain) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(plain.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            throw new RuntimeException("Password hashing error", e);
        }
    }
}
