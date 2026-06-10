# 🔐 Tính Năng Quên Mật Khẩu - Hướng Dẫn Hoàn Chỉnh

## 📌 Mục Đích

Cho phép người dùng đặt lại mật khẩu khi quên, thông qua xác minh email an toàn.

---

## 📁 Các File Được Tạo

### 1. Controllers (Servlet)
| File | Đường dẫn | Chức Năng |
|------|----------|---------|
| **ForgotPasswordServlet.java** | `src/java/controller/` | Xử lý form quên mật khẩu, gửi email reset |
| **ResetPasswordServlet.java** | `src/java/controller/` | Xử lý reset mật khẩu với token validation |

### 2. Services
| File | Đường dẫn | Chức Năng |
|------|----------|---------|
| **EmailService.java** | `src/java/service/` | Gửi email HTML với link reset |

### 3. Views (JSP Pages)
| File | Đường dẫn | Chức Năng |
|------|----------|---------|
| **forgot-password.jsp** | `web/` | Form nhập email để reset |
| **reset-password.jsp** | `web/` | Form nhập mật khẩu mới + validation |

### 4. Utilities
| File | Đường dẫn | Chức Năng |
|------|----------|---------|
| **PasswordHashUtil.java** | `src/java/Utils/` | Helper cho password hashing (tương lai) |

### 5. Database
| File | Đường dẫn | Chức Năng |
|------|----------|---------|
| **PasswordResetTokens_Setup.sql** | `database/` | SQL script tạo bảng token |

### 6. Documentation
| File | Đường dẫn | Chức Năng |
|------|----------|---------|
| **FORGOT_PASSWORD_SETUP.md** | `database/` | Hướng dẫn cấu hình chi tiết |
| **FORGOT_PASSWORD_SUMMARY.md** | `database/` | File tóm tắt này |

---

## 🔄 Quy Trình Hoạt Động

```
┌─────────────────────────────────────────────────────────┐
│ 1. User truy cập: login.jsp → Click "Quên mật khẩu?"  │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│ 2. ForgotPasswordServlet (GET)                          │
│    Hiển thị: forgot-password.jsp                        │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│ 3. User nhập email → Submit form                        │
│    ForgotPasswordServlet (POST)                         │
│    - Kiểm tra email tồn tại                            │
│    - Generate token (UUID)                             │
│    - Lưu token vào DB (expiry = +1 hour)               │
│    - Gửi email với link reset                          │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│ 4. User nhận email                                      │
│    Click link: /reset-password?token=XXX&email=YYY      │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│ 5. ResetPasswordServlet (GET)                           │
│    - Validate token (hợp lệ? hết hạn? dùng rồi?)      │
│    - Hiển thị: reset-password.jsp                      │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│ 6. User nhập mật khẩu mới → Submit                     │
│    ResetPasswordServlet (POST)                         │
│    - Validate input (min 6 ký tự, match nhau)         │
│    - Validate token lần nữa                           │
│    - Update password trong DB                         │
│    - Mark token: is_used = 1                          │
│    - Redirect: login.jsp (success message)            │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│ 7. User đăng nhập lại với mật khẩu mới                │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 Cài Đặt Nhanh (5 Bước)

### Bước 1: Chạy SQL Script
```bash
# Mở SQL Server Management Studio
# Mở file: database/PasswordResetTokens_Setup.sql
# Execute (F5)
```

### Bước 2: Cấu Hình Gmail
1. Bật 2-Factor Authentication: https://myaccount.google.com/security
2. Tạo App Password: https://myaccount.google.com/apppasswords
3. Copy App Password (16 ký tự)

### Bước 3: Cập Nhật Email Config
```java
// File: src/java/service/EmailService.java
private static final String EMAIL_FROM = "your-email@gmail.com";
private static final String EMAIL_PASSWORD = "xxxx xxxx xxxx xxxx";
```

### Bước 4: Thêm Jakarta Mail JAR
Tải từ: https://mvnrepository.com/artifact/jakarta.mail/jakarta.mail-api
```
WEB-INF/lib/
├── jakarta.mail-api-2.1.0.jar
└── jakarta.mail-2.0.1.jar
```

### Bước 5: Compile & Run
```bash
# Build project
# Deploy to Tomcat
# Test: http://localhost:8080/SenaFruit/login.jsp
```

---

## 🧪 Kiểm Thử

### Test Case 1: Email không tồn tại
```
1. Truy cập: /forgot-password
2. Nhập email: notexist@example.com
3. Kết quả: "Nếu email tồn tại, bạn sẽ nhận email..."
   (Không leak thông tin vì bảo mật)
```

### Test Case 2: Email hợp lệ
```
1. Truy cập: /forgot-password
2. Nhập email: user@example.com (đã tồn tại)
3. Kết quả: 
   ✅ Email được gửi
   ✅ Token được lưu DB
   ✅ Message "Email đã được gửi"
```

### Test Case 3: Link reset hợp lệ
```
1. Click link trong email
2. URL: /reset-password?token=XXX&email=YYY
3. Kết quả:
   ✅ Form reset được hiển thị
   ✅ Có thể nhập mật khẩu mới
```

### Test Case 4: Mật khẩu invalid
```
1. Nhập mật khẩu: "123" (< 6 ký tự)
2. Nhập xác nhận: "123"
3. Kết quả: Error "Mật khẩu phải có ít nhất 6 ký tự"
```

### Test Case 5: Mật khẩu không match
```
1. Nhập mật khẩu: "Password123"
2. Nhập xác nhận: "Password456"
3. Kết quả: Error "Mật khẩu xác nhận không trùng khớp"
```

### Test Case 6: Token hết hạn
```
1. Chờ > 1 giờ
2. Click link trong email
3. Kết quả: Error "Link đã hết hạn"
```

### Test Case 7: Token dùng 2 lần
```
1. Click link lần 1 → Reset password thành công
2. Click lại link → 
3. Kết quả: Error "Link đã hết hạn hoặc không tồn tại"
```

---

## 🔧 Cấu Trúc Database

### Bảng: PasswordResetTokens
```sql
┌─────────────────────────────────────────┐
│ Column Name    │ Type       │ Note      │
├────────────────┼────────────┼───────────┤
│ id             │ INT        │ PK, Auto  │
│ email          │ VARCHAR    │ User email│
│ token          │ VARCHAR    │ UNIQUE    │
│ expiry_time    │ DATETIME   │ 1 hour    │
│ is_used        │ BIT        │ 0/1       │
│ created_at     │ DATETIME   │ Auto now  │
└─────────────────────────────────────────┘

Indexes:
- idx_email_token (email, token)
- idx_expiry_time (expiry_time)
- idx_is_used (is_used)
```

---

## 🔐 Tính Năng Bảo Mật

| Tính Năng | Mô Tả | Độ Mạnh |
|-----------|-------|--------|
| **Token Unique** | UUID không đoán được | ⭐⭐⭐⭐⭐ |
| **Token Expiry** | 1 giờ tự hết hạn | ⭐⭐⭐⭐⭐ |
| **One-Time Use** | Mỗi token dùng 1 lần | ⭐⭐⭐⭐⭐ |
| **No Email Leak** | Không công khai email tồn tại | ⭐⭐⭐⭐ |
| **Password Length** | Min 6 ký tự | ⭐⭐ |
| **HTTPS Ready** | Sẵn sàng cho production | ⭐⭐⭐⭐ |
| **Logging** | Log mọi attempt (opt) | ⭐⭐⭐ |

**TODO (Tương lai):**
- [ ] Implement BCrypt password hashing
- [ ] Add rate limiting (5 req/hour per IP)
- [ ] Add email verification logging
- [ ] Implement HTTPS requirement

---

## 🔍 URL Mapping

```
HTTP Method │ URL                    │ Servlet               │ JSP
────────────┼────────────────────────┼──────────────────────┼─────────────────
GET         │ /forgot-password       │ ForgotPasswordServlet │ forgot-password.jsp
POST        │ /forgot-password       │ ForgotPasswordServlet │ forgot-password.jsp
GET         │ /reset-password        │ ResetPasswordServlet  │ reset-password.jsp
POST        │ /reset-password        │ ResetPasswordServlet  │ reset-password.jsp
```

---

## 📧 Email Template

Email được gửi dưới dạng HTML:

```html
┌─────────────────────────────────────┐
│ 🍎 SenaFruit Support                │
├─────────────────────────────────────┤
│                                     │
│ Đặt Lại Mật Khẩu                   │
│                                     │
│ Xin chào [Customer Name],           │
│                                     │
│ Chúng tôi nhận được yêu cầu...      │
│                                     │
│ [CLICK HERE - Reset Password Link]  │
│                                     │
│ Link có hiệu lực trong 1 giờ        │
│                                     │
│ Nếu không yêu cầu, bỏ qua email    │
│                                     │
│ Với kính trọng,                     │
│ Đội ngũ SenaFruit                  │
└─────────────────────────────────────┘
```

---

## ⚙️ Environment Setup Checklist

- [ ] SQL Server running với database `FruitShopSystem`
- [ ] Bảng `PasswordResetTokens` được tạo
- [ ] Bảng `Accounts` tồn tại (có cột: email, password_hash)
- [ ] Bảng `Roles` tồn tại
- [ ] Gmail account cấu hình
- [ ] App Password lấy được từ Gmail
- [ ] Jakarta Mail JAR thêm vào project
- [ ] EmailService.java cấu hình đúng
- [ ] Project compile thành công
- [ ] Tomcat/Jetty running
- [ ] Test cases passed ✅

---

## 🐛 Troubleshooting

| Vấn Đề | Nguyên Nhân | Giải Pháp |
|--------|-----------|----------|
| Email không gửi | Config email sai | Check EmailService credentials |
| Link không hoạt động | Path servlet sai | Check web.xml hoặc @WebServlet |
| Token hết hạn | Quá 1 tiếng | Yêu cầu reset lại |
| Database error | Table không tồn tại | Chạy PasswordResetTokens_Setup.sql |
| 404 error | URL không đúng | Dùng /forgot-password |
| Form không hiển thị | JSP syntax error | Check JSP file syntax |

---

## 📚 Tài Liệu Thêm

- **FORGOT_PASSWORD_SETUP.md** - Hướng dẫn chi tiết
- **PasswordResetTokens_Setup.sql** - SQL script
- **EmailService.java** - Email implementation
- **ForgotPasswordServlet.java** - Main logic
- **ResetPasswordServlet.java** - Reset logic

---

## 👤 Đội Ngũ Phát Triển

- **Feature:** Password Reset
- **Version:** 1.0
- **Date:** June 2024
- **Status:** ✅ Ready for Testing

---

## 📞 Hỗ Trợ

Nếu có vấn đề:
1. Check console log (Tomcat)
2. Check database logs
3. Xem FORGOT_PASSWORD_SETUP.md section "Troubleshooting"
4. Verify configuration đúng

---

**Happy Coding! 🚀**
