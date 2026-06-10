# Hướng Dẫn Tính Năng Quên Mật Khẩu (Forgot Password)

## 📋 Tổng Quan

Tính năng quên mật khẩu cho phép người dùng đặt lại mật khẩu thông qua email. Hệ thống gửi link reset có token an toàn với thời hạn 1 giờ.

## 🏗️ Cấu Trúc

### Controllers
- **ForgotPasswordServlet** (`/forgot-password`) - Xử lý yêu cầu quên mật khẩu
- **ResetPasswordServlet** (`/reset-password`) - Xử lý reset mật khẩu với token

### Services
- **EmailService** - Gửi email reset password

### Views
- **forgot-password.jsp** - Form nhập email
- **reset-password.jsp** - Form đặt lại mật khẩu

### Database
- **PasswordResetTokenDAO** - Quản lý token trong DB

## 🗄️ Cấu Hình Cơ Sở Dữ Liệu

### Tạo Bảng PasswordResetTokens

Chạy SQL command sau trong SQL Server:

```sql
CREATE TABLE PasswordResetTokens (
    id INT IDENTITY(1,1) PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    token VARCHAR(500) NOT NULL UNIQUE,
    expiry_time DATETIME NOT NULL,
    is_used BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE()
);

-- Tạo index để tìm kiếm nhanh
CREATE INDEX idx_email_token ON PasswordResetTokens(email, token);
CREATE INDEX idx_expiry_time ON PasswordResetTokens(expiry_time);
```

## 📧 Cấu Hình Email Service

### Bước 1: Chuẩn Bị Gmail

1. **Bật 2-Factor Authentication** trên tài khoản Gmail
2. Vào https://myaccount.google.com/apppasswords
3. Tạo **App Password** cho "Mail" trên "Windows Computer"
4. Copy mật khẩu ứng dụng (16 ký tự)

### Bước 2: Cập Nhật EmailService.java

Mở file `src/java/service/EmailService.java` và cập nhật:

```java
private static final String EMAIL_FROM = "your-email@gmail.com";  // Gmail của bạn
private static final String EMAIL_PASSWORD = "xxxx xxxx xxxx xxxx"; // App Password
```

**Ví dụ:**
```java
private static final String EMAIL_FROM = "sena.shop@gmail.com";
private static final String EMAIL_PASSWORD = "abcd efgh ijkl mnop";
```

### Bước 3: Thêm Thư Viện Email

Thêm Jakarta Mail JAR vào project:

```xml
<!-- Nếu dùng Maven, thêm vào pom.xml -->
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

**Hoặc copy JAR file vào WEB-INF/lib/:**
- jakarta.mail-2.0.1.jar
- jakarta.activation-2.0.1.jar

## 🔄 Luồng Hoạt Động

### 1. Quên Mật Khẩu (Forgot Password)

```
1. User truy cập: http://localhost:8080/SenaFruit/forgot-password
2. Nhập email đã đăng ký
3. System kiểm tra email có tồn tại
4. Tạo token unique (UUID)
5. Lưu token vào DB với expiry = now + 1 hour
6. Gửi email chứa link reset (kèm token & email)
7. Hiển thị message "Email đã được gửi"
```

**URL Email:**
```
http://localhost:8080/SenaFruit/reset-password?token=XXXXX&email=user@example.com
```

### 2. Đặt Lại Mật Khẩu (Reset Password)

```
1. User click link trong email
2. System validate token:
   - Token có tồn tại?
   - Token đã hết hạn?
   - Token đã được sử dụng?
3. Nếu hợp lệ: Hiển thị form nhập mật khẩu mới
4. User nhập mật khẩu mới (min 6 ký tự)
5. System update password trong DB
6. Mark token là "used"
7. Redirect user tới login page
```

## 🔐 Tính Năng Bảo Mật

- **Token Expiry**: 1 giờ (có thể thay đổi ở ForgotPasswordServlet.java line ~57)
- **Token One-Time Use**: Mỗi token chỉ dùng được 1 lần
- **No Email Leak**: Không công khai email có tồn tại hay không (vì bảo mật)
- **Password Validation**: Mật khẩu tối thiểu 6 ký tự
- **Secure Token**: Sử dụng UUID không đoán được

## 📝 Cách Sử Dụng

### Từ Frontend (HTML)

**Link Quên Mật Khẩu** (thêm vào login.jsp):
```html
<a href="forgot-password">Quên mật khẩu?</a>
```
✅ Đã cập nhật trong login.jsp

### API Endpoints

| Endpoint | Method | Mô Tả |
|----------|--------|-------|
| `/forgot-password` | GET | Hiển thị form quên mật khẩu |
| `/forgot-password` | POST | Gửi link reset qua email |
| `/reset-password` | GET | Hiển thị form reset (validate token) |
| `/reset-password` | POST | Cập nhật mật khẩu mới |

## ⚠️ Lưu Ý Quan Trọng

1. **Email Configuration**: Phải cấu hình đúng email & password mới gửi được
2. **Database**: Phải có bảng PasswordResetTokens
3. **SSL/HTTPS**: Trong production, nên dùng HTTPS để an toàn
4. **Password Hashing**: Hiện tại lưu plain text - nên dùng BCrypt trong production
5. **Email Timeout**: Nếu email không gửi được, check console log để debug

## 🧪 Thử Nghiệm

1. Chạy project trên server (Tomcat/Jetty)
2. Truy cập: http://localhost:8080/SenaFruit/login.jsp
3. Click "Quên mật khẩu?"
4. Nhập email có tài khoản
5. Kiểm tra email (Gmail)
6. Click link trong email
7. Nhập mật khẩu mới (min 6 ký tự)
8. Đăng nhập lại với mật khẩu mới

## 🔧 Troubleshooting

### Email không gửi được
```
Kiểm tra:
1. Gmail credentials đúng?
2. 2-Factor Authentication bật?
3. Thư viện Jakarta Mail thêm vào project?
4. Network có cho phép SMTP port 587?
5. Check console log để xem chi tiết lỗi
```

### Token hết hạn
```
Nếu user click link sau > 1 giờ, sẽ thấy "Link đã hết hạn"
- Để thay đổi expiry time: sửa line ~57 trong ForgotPasswordServlet.java
- Long expiryMs = System.currentTimeMillis() + (X * 60 * 60 * 1000); // X giờ
```

### Mật khẩu không update
```
Kiểm tra:
1. Bảng Accounts tồn tại & có cột password_hash?
2. User id được lấy đúng?
3. CustomerDAO.updatePassword() hoạt động bình thường?
```

## 📚 File Liên Quan

```
src/java/
├── controller/
│   ├── ForgotPasswordServlet.java ✅ (Mới)
│   └── ResetPasswordServlet.java ✅ (Mới)
├── service/
│   └── EmailService.java ✅ (Mới)
├── dao/
│   └── PasswordResetTokenDAO.java ✅ (Đã có)
│
web/
├── forgot-password.jsp ✅ (Mới)
├── reset-password.jsp ✅ (Mới)
└── login.jsp (Cập nhật link)
```

## 🎯 Mở Rộng (Advanced)

### 1. Thêm Validation Email Format
```java
if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
    request.setAttribute("error", "Email không hợp lệ");
    return;
}
```

### 2. Thêm Limit Retry
```java
// Giới hạn 5 lần request/hour per IP
```

### 3. Thêm Logging
```java
System.out.println("Reset password requested for email: " + email);
```

### 4. Dùng Password Hashing (BCrypt)
```java
// Thay vì: newPasswordHash = newPassword;
// Dùng: newPasswordHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());
```

---

**Ngày tạo:** 2024  
**Phiên bản:** 1.0  
**Tác giả:** Development Team
