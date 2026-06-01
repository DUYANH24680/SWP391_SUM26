package Utils;

/**
 * PasswordHashUtil - Utility for password hashing and validation
 * 
 * IMPORTANT: Trong phiên bản hiện tại, project vẫn dùng plain text.
 * Để upgrade tính bảo mật, hãy sử dụng class này với BCrypt library.
 * 
 * Cách sử dụng:
 * 1. Thêm dependency: org.mindrot:jbcrypt:0.4
 * 2. Thay đổi LoginServlet: 
 *    if (PasswordHashUtil.checkPassword(password, customer.getPasswordHash())) {...}
 * 3. Thay đổi ResetPasswordServlet:
 *    customerDAO.updatePassword(id, PasswordHashUtil.hashPassword(newPassword));
 */
public class PasswordHashUtil {
    
    /**
     * Hash password using BCrypt
     * 
     * NOTE: Requires org.mindrot:jbcrypt dependency
     * 
     * @param password Plain text password
     * @return Hashed password (BCrypt hash)
     */
    public static String hashPassword(String password) {
        try {
            // Uncomment when BCrypt is added to project
            // return org.mindrot.jbcrypt.BCrypt.hashpw(password, org.mindrot.jbcrypt.BCrypt.gensalt());
            
            // For now, return plain text (INSECURE - only for development)
            System.out.println("WARNING: Using plain text passwords. Please implement proper hashing!");
            return password;
        } catch (Exception e) {
            throw new RuntimeException("Error hashing password: " + e.getMessage(), e);
        }
    }
    
    /**
     * Verify password against hash
     * 
     * NOTE: Requires org.mindrot:jbcrypt dependency
     * 
     * @param plainPassword Plain text password to verify
     * @param hashedPassword Stored hash from database
     * @return true if password matches, false otherwise
     */
    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        try {
            // Uncomment when BCrypt is added to project
            // return org.mindrot.jbcrypt.BCrypt.checkpw(plainPassword, hashedPassword);
            
            // For now, use direct comparison (INSECURE - only for development)
            return plainPassword.equals(hashedPassword);
        } catch (Exception e) {
            System.err.println("Error verifying password: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Validate password strength
     * @return true if password meets minimum requirements
     */
    public static boolean isStrongPassword(String password) {
        // Minimum requirements:
        // - At least 8 characters
        // - Contains uppercase letter
        // - Contains lowercase letter
        // - Contains digit
        // - Contains special character
        
        if (password == null || password.length() < 8) return false;
        
        boolean hasUpper = password.matches(".*[A-Z].*");
        boolean hasLower = password.matches(".*[a-z].*");
        boolean hasDigit = password.matches(".*\\d.*");
        boolean hasSpecial = password.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?].*");
        
        return hasUpper && hasLower && hasDigit && hasSpecial;
    }
    
    /**
     * Validate email format
     */
    public static boolean isValidEmail(String email) {
        String emailRegex = "^[A-Za-z0-9+_.-]+@(.+)$";
        return email != null && email.matches(emailRegex);
    }
}
