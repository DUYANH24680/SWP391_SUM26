package service;

import java.util.Properties;
import java.io.UnsupportedEncodingException;
import jakarta.mail.*;
import jakarta.mail.internet.*;

/**
 * EmailService - Handles sending emails for password reset
 */
public class EmailService {
    
    // Gmail configuration
    private static final String EMAIL_FROM = "doanhche180633@fpt.edu.vn";
    private static final String EMAIL_PASSWORD = "fjlpswpvzfpgfouk"; // Use Gmail App Password
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    
    /**
     * Send password reset email
     */
    public static boolean sendPasswordResetEmail(String recipientEmail, String resetLink, String userName) {
        try {
            // Setup email properties
            Properties props = new Properties();
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.starttls.required", "true");
            
            // Create session with authentication
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(EMAIL_FROM, EMAIL_PASSWORD);
                }
            });
            
            // Create message
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(EMAIL_FROM, "SenaFruit"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject("Đặt lại mật khẩu tài khoản SenaFruit");
            
            // Email content
            String emailContent = buildEmailContent(userName, resetLink);
            message.setContent(emailContent, "text/html;charset=UTF-8");
            
            // Send email
            Transport.send(message);
            System.out.println("Email sent successfully to: " + recipientEmail);
            return true;
            
        } catch (MessagingException | UnsupportedEncodingException e) {
            System.err.println("Failed to send email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Build HTML email content
     */
    private static String buildEmailContent(String userName, String resetLink) {
        return "<html>" +
                "<body style='font-family: Arial, sans-serif; color: #333;'>" +
                "<div style='max-width: 600px; margin: 0 auto; border: 1px solid #ddd; padding: 20px;'>" +
                "<h2 style='color: #4CAF50;'>Đặt Lại Mật Khẩu</h2>" +
                "<p>Xin chào " + userName + ",</p>" +
                "<p>Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản SenaFruit của bạn.</p>" +
                "<p>Vui lòng click vào link dưới đây để đặt lại mật khẩu (link có hiệu lực trong 1 giờ):</p>" +
                "<p style='text-align: center;'>" +
                "<a href='" + resetLink + "' style='background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block;'>" +
                "Đặt Lại Mật Khẩu" +
                "</a>" +
                "</p>" +
                "<p>Hoặc copy link này vào trình duyệt:</p>" +
                "<p style='word-break: break-all; background-color: #f5f5f5; padding: 10px;'>" + resetLink + "</p>" +
                "<p><strong>Lưu ý:</strong> Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.</p>" +
                "<p>Với kính trọng,<br/>Đội ngũ SenaFruit</p>" +
                "</div>" +
                "</body>" +
                "</html>";
    }
}
