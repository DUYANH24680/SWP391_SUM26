# ✅ Checklist - Implement Forgot Password Feature

## 📋 Pre-Implementation

- [x] Phân tích yêu cầu
- [x] Design database schema
- [x] Code servlet controllers
- [x] Code email service
- [x] Create JSP views
- [x] Create documentation

## 🗄️ Database Setup

- [ ] **Step 1:** Mở SQL Server Management Studio
- [ ] **Step 2:** Connect tới server có database `FruitShopSystem`
- [ ] **Step 3:** Mở file: `database/PasswordResetTokens_Setup.sql`
- [ ] **Step 4:** Execute SQL script (F5)
- [ ] **Step 5:** Verify: Run `SELECT * FROM PasswordResetTokens` (kết quả: table trống)

✅ **DB Setup Complete**

---

## 📧 Email Configuration

### Gmail Setup
- [ ] **Step 1:** Truy cập: https://myaccount.google.com/security
- [ ] **Step 2:** Bật "2-Step Verification"
- [ ] **Step 3:** Truy cập: https://myaccount.google.com/apppasswords
- [ ] **Step 4:** Chọn "Mail" và "Windows Computer"
- [ ] **Step 5:** Copy App Password (16 ký tự)
  ```
  Example: abcd efgh ijkl mnop
  ```

### Project Configuration
- [ ] **Step 1:** Mở: `src/java/service/EmailService.java`
- [ ] **Step 2:** Cập nhật Email:
  ```java
  private static final String EMAIL_FROM = "your-email@gmail.com";
  ```
- [ ] **Step 3:** Cập nhật Password:
  ```java
  private static final String EMAIL_PASSWORD = "xxxx xxxx xxxx xxxx";
  ```
- [ ] **Step 4:** Save file

✅ **Email Configuration Complete**

---

## 📚 Add Dependencies

### Option 1: Download JAR Files Manually
- [ ] Download: `jakarta.mail-api-2.1.0.jar`
  - Source: https://mvnrepository.com/artifact/jakarta.mail/jakarta.mail-api
- [ ] Download: `jakarta.mail-2.0.1.jar`
  - Source: https://mvnrepository.com/artifact/com.sun.mail/jakarta.mail
- [ ] Download: `jakarta.activation-2.0.1.jar`
  - Source: https://mvnrepository.com/artifact/jakarta.activation/jakarta.activation
- [ ] Copy JAR files vào: `WEB-INF/lib/`

### Option 2: Use Maven (nếu project dùng Maven)
```xml
<!-- Add to pom.xml -->
<dependency>
    <groupId>jakarta.mail</groupId>
    <artifactId>jakarta.mail-api</artifactId>
    <version>2.1.0</version>
</dependency>
<dependency>
    <groupId>com.sun.mail</groupId>
    <artifactId>jakarta.mail</artifactId>
    <version>2.0.1</version>
</dependency>
```

✅ **Dependencies Added**

---

## 🔨 Build & Deploy

- [ ] **Step 1:** Clean project: `File → Clean`
- [ ] **Step 2:** Build project: `Build → Build`
- [ ] **Step 3:** Verify no compile errors (Console: "BUILD SUCCESS")
- [ ] **Step 4:** Start Tomcat server
- [ ] **Step 5:** Deploy application

✅ **Build & Deploy Complete**

---

## 🧪 Testing

### Test 1: Forgot Password Page Load
- [ ] URL: http://localhost:8080/SenaFruit/forgot-password
- [ ] Expected: Form "Quên Mật Khẩu" hiển thị
- [ ] Status: ✅ Pass / ❌ Fail

### Test 2: Invalid Email
- [ ] Input: "notexist@example.com"
- [ ] Click: "Gửi Hướng Dẫn Đặt Lại"
- [ ] Expected: "Nếu email tồn tại..." message (no leak)
- [ ] Status: ✅ Pass / ❌ Fail

### Test 3: Valid Email
- [ ] Input: "user@example.com" (existing account)
- [ ] Click: "Gửi Hướng Dẫn Đặt Lại"
- [ ] Check Gmail: Email received?
- [ ] Expected: Email with reset link
- [ ] Status: ✅ Pass / ❌ Fail

### Test 4: Click Email Link
- [ ] Click reset link từ email
- [ ] Expected: Reset password form + valid token message
- [ ] Status: ✅ Pass / ❌ Fail

### Test 5: Password Too Short
- [ ] Input: "123" (< 6 chars)
- [ ] Click: "Cập Nhật Mật Khẩu"
- [ ] Expected: Error "Mật khẩu phải có ít nhất 6 ký tự"
- [ ] Status: ✅ Pass / ❌ Fail

### Test 6: Password Mismatch
- [ ] Password: "NewPass123"
- [ ] Confirm: "NewPass456"
- [ ] Click: "Cập Nhật Mật Khẩu"
- [ ] Expected: Error "Mật khẩu xác nhận không trùng khớp"
- [ ] Status: ✅ Pass / ❌ Fail

### Test 7: Valid Password Reset
- [ ] Password: "NewPassword123"
- [ ] Confirm: "NewPassword123"
- [ ] Click: "Cập Nhật Mật Khẩu"
- [ ] Expected: Redirect to login with success message
- [ ] Status: ✅ Pass / ❌ Fail

### Test 8: Login with New Password
- [ ] Username: user account
- [ ] Password: "NewPassword123" (newly set)
- [ ] Click: "Đăng Nhập"
- [ ] Expected: Login success → home page
- [ ] Status: ✅ Pass / ❌ Fail

### Test 9: Token Expiry
- [ ] Wait > 1 hour
- [ ] Click old reset link
- [ ] Expected: Error "Link đã hết hạn"
- [ ] Status: ✅ Pass / ❌ Fail

### Test 10: Token One-Time Use
- [ ] Complete password reset (Test 7)
- [ ] Try to click same link again
- [ ] Expected: Error "Link đã hết hạn hoặc không tồn tại"
- [ ] Status: ✅ Pass / ❌ Fail

✅ **All Tests Passed** (if all checked)

---

## 📊 Database Verification

```sql
-- Run these queries to verify setup
SELECT COUNT(*) AS Total_Tokens FROM PasswordResetTokens;
SELECT * FROM PasswordResetTokens WHERE is_used = 0; -- Active tokens
SELECT * FROM PasswordResetTokens WHERE expiry_time < GETDATE(); -- Expired
```

Expected after testing:
- [ ] Table exists
- [ ] Tokens are created on forgot-password submit
- [ ] Tokens are marked as "used" after reset
- [ ] Expired tokens are identifiable

---

## 🎯 Final Verification

- [ ] All code files created without errors
- [ ] All JSP pages render correctly
- [ ] All email configurations done
- [ ] Database table created with proper schema
- [ ] All 10 test cases passed
- [ ] No compilation errors
- [ ] No runtime errors in console
- [ ] Password reset works end-to-end
- [ ] User can login with new password

✅ **Feature Ready for Production**

---

## 📝 Known Limitations (Current Version)

- ⚠️ Passwords stored in plain text (should use BCrypt)
- ⚠️ No rate limiting (could add IP-based throttling)
- ⚠️ No email verification logging
- ⚠️ No password complexity requirements
- ⚠️ Email config hardcoded (should use config file)

### Future Improvements
- [ ] Implement BCrypt hashing
- [ ] Add rate limiting
- [ ] Add email logging/audit trail
- [ ] Add password strength meter
- [ ] Externalize email config
- [ ] Add SMS option
- [ ] Add security questions

---

## 🎓 Learning Points

**Covered Concepts:**
- ✅ Jakarta Servlets (GET/POST)
- ✅ Session management
- ✅ Database DAO pattern
- ✅ Email SMTP with Gmail
- ✅ Token-based authentication
- ✅ HTML email templates
- ✅ Form validation
- ✅ Security best practices
- ✅ Error handling
- ✅ User experience flow

---

## 📞 Support Resources

**Files to Reference:**
1. `FORGOT_PASSWORD_SETUP.md` - Detailed configuration
2. `FORGOT_PASSWORD_SUMMARY.md` - Feature overview
3. Source code comments in each Java class
4. JSP file comments
5. SQL script comments

**External Resources:**
- Jakarta Mail API: https://eclipse-ee4j.github.io/mail/
- BCrypt for Java: https://www.mindrot.org/projects/jBCrypt/
- OWASP Password Guidelines: https://cheatsheetseries.owasp.org/

---

## ✨ Completion Status

- **Code Files:** ✅ 3 Servlets, 1 Service, 2 JSPs, 1 Utility
- **Documentation:** ✅ 3 MD files, 1 SQL script
- **Testing:** ⏳ Pending (follow checklist above)
- **Deployment:** ⏳ Pending
- **Production Ready:** ⏳ Pending (after improvements)

---

**Date Started:** June 2024  
**Date Completed:** [TO UPDATE]  
**Developer:** [YOUR NAME]  
**Status:** 🟡 In Testing Phase

---

**Good luck! Remember to test thoroughly before going live! 🚀**
