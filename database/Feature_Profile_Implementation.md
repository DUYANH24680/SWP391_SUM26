# 📌 QUY TRÌNH PHÁT TRIỂN TÍNH NĂNG THEO KIẾN TRÚC 3 LỚP (MỞ RỘNG)

---

## 🟢 GIAI ĐOẠN 1: IMPLEMENTATION PLAN (KẾ HOẠCH TRIỂN KHAI)

### 1. Phân tích Yêu cầu (Requirements)
- **Tên tính năng:** Xem và Chỉnh sửa Hồ sơ Cá nhân (View & Edit Profile), Đổi mật khẩu, Tải lên Ảnh đại diện.
- **Mô tả ngắn gọn:** Cho phép người dùng (đã đăng nhập) xem thông tin cá nhân của họ, thay đổi thông tin (họ tên, email, sđt, địa chỉ, giới tính, tải lên và xem trước avatar từ local hoặc URL) và cập nhật mật khẩu an toàn.
- **Các trường dữ liệu liên quan:** `fullname`, `email`, `phone`, `address`, `gender`, `avatar`, `password_hash`.

### 2. Thiết kế Luồng Dữ Liệu & Phân rã Kiến trúc (Architecture Mapping)

| Lớp (Layer) | Tên File / Class | Nhiệm vụ cụ thể trong Task này |
| :--- | :--- | :--- |
| **1. VIEW** | `profile.jsp` | Hiển thị giao diện người dùng, bao gồm thông tin hiển thị, Modal form chỉnh sửa thông tin (có tích hợp upload avatar từ local và preview), form đổi mật khẩu. |
| **2. CONTROLLER** | `ProfileServlet.java` | Lắng nghe `/profile`. Xử lý GET (trả về View) và POST (nhận action `updateProfile` hoặc `changePassword`). Hỗ trợ `@MultipartConfig` để xử lý file upload, chuyển tiếp Request sang Service. |
| **3. SERVICE** | `UserService.java` | Xử lý logic validate đầu vào (kiểm tra định dạng email, sđt, độ dài mật khẩu). Hash mật khẩu (SHA-256). Gọi đến DAO để thực thi. |
| **4. DAO / REPOSITORY**| `CustomerDAO.java` | Truy vấn và Update dữ liệu DB bảng `Accounts` bằng SQL thuần. Gồm các hàm: `findById`, `updateProfile`, `updatePassword`, `isEmailTaken`. |
| **5. MODEL / ENTITY** | `Customer.java` | Ánh xạ các trường dữ liệu của người dùng trong hệ thống (của bảng `Accounts`). |

### 3. Kế hoạch từng bước (Step-by-Step)
- [x] **Bước 1:** Xác nhận Model `Customer` đã có đủ các trường, cấu trúc Database đã chuẩn.
- [x] **Bước 2:** Viết các hàm `findById`, `updateProfile`, `updatePassword`, `isEmailTaken` ở `CustomerDAO.java`.
- [x] **Bước 3:** Viết hàm xử lý nghiệp vụ `updateProfile` và `changePassword` (bao gồm logic mã hóa mật khẩu) trong `UserService.java`.
- [x] **Bước 4:** Xử lý điều hướng tại `ProfileServlet.java`, hứng Session, cấu hình `@MultipartConfig` và xử lý upload file ảnh vào thư mục `uploads/`.
- [x] **Bước 5:** Xây dựng file `profile.jsp` hiển thị và nhận Input người dùng, thêm javascript để preview ảnh local.

---

## 🟡 GIAI ĐOẠN 2: THỰC THI & TUÂN THỦ KIẾN TRÚC (DEVELOPMENT)

Quá trình thực thi đã hoàn tất 100% mã nguồn và **đáp ứng nghiêm ngặt bộ quy tắc Sạch**:
- 100% tuân thủ Quy tắc Tháp Đổ (View -> Controller -> Service -> DAO).
- Không có câu SQL nào nằm ngoài tầng DAO.
- Tầng Service không dính dáng đến Request/Response của Servlet.

---

## 🔴 GIAI ĐOẠN 3: REVIEW & RETROSPECTIVE (ĐÁNH GIÁ & ĐÚC KẾT)

### 1. Xem xét lại hành động thực tế (Action Review)
Tính năng được thiết kế gọn nhẹ. Thực tế triển khai đã thêm một hàm logic `isEmailTaken` ở tầng DAO để tầng Service có thể validate tính duy nhất của Email ngay khi người dùng cập nhật hồ sơ, tránh bị lỗi Constraint từ SQL đập thẳng lên ứng dụng.

### 2. Nhật ký Quyết định (Decision Log)
* **Quyết định 1:** Hash mật khẩu bằng hàm SHA-256 (có viết tĩnh trong Service).
  * *Lý do:* Để bảo mật tối thiểu, không lưu plaintext trên Database.
* **Quyết định 2:** Dùng Modal thay vì chuyển trang khi chỉnh sửa thông tin.
  * *Lý do:* Nâng cao trải nghiệm người dùng (UX), thao tác nhanh gọn.

### 3. Checklist Tự Đánh Giá Kiến Trúc (Self-Architectural Audit)
- [x] **Đúng luồng:** Đã đảm bảo không có bất kỳ dòng code nào vi phạm quy tắc gọi vượt cấp.
- [x] **Tách biệt database:** Lớp Service hoàn toàn không chứa mã nguồn liên quan đến SQL/Query.
- [x] **Quản lý lỗi:** Các lỗi validate được trả về bằng Chuỗi từ Service, Controller hứng và ném sang JSP bằng `session.setAttribute("error", error)`.
- [x] **Dọn dẹp code:** Đã xóa bỏ các dòng code thừa, console.log.

### 4. Bài học kinh nghiệm (Lessons Learned)
- *Điểm tốt:* Cấu trúc tầng Service hoạt động như một bức tường bảo vệ tốt, Controller chỉ cần gọi hàm và nhận lỗi String trả về.
- *Điểm cần cải thiện cho lần sau:* Nếu có thêm các thư viện Validator chuyên dụng (như Hibernate Validator) thì tầng Service sẽ còn "sạch" hơn nữa thay vì viết các lệnh `if` kiểm tra thủ công.

---
**Chữ ký xác nhận hoàn thành Task:** AI Assistant | **Ngày hoàn thành:** 26/05/2026
