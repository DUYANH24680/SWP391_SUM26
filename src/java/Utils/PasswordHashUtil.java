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
 *    if (PasswordHashUtil.checkPassword(password, user.getPasswordHash())) {...}
 * 3. Thay đổi ResetPasswordServlet:
 *    userDAO.updatePassword(id, PasswordHashUtil.hashPassword(newPassword));
 */
public class PasswordHashUtil {
    
    public static String hashPassword(String password) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes(java.nio.charset.StandardCharsets.UTF_8));
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
            throw new RuntimeException("Error hashing password: " + e.getMessage(), e);
        }
    }
    
    /**
     * Verify password against hash
     * 
     * @param plainPassword Plain text password to verify
     * @param hashedPassword Stored hash from database
     * @return true if password matches, false otherwise
     */
    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        try {
            String hashedInput = hashPassword(plainPassword);
            return hashedInput.equals(hashedPassword);
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
