# 📋 AGENT DEVELOPMENT GUIDELINES (JAVA SERVLET / 3-LAYER)

Tài liệu này định nghĩa tập hợp các quy tắc bắt buộc mà Agent phải tuân thủ tuyệt đối trong suốt quá trình hỗ trợ, phát triển và tối ưu hóa mã nguồn cho dự án Web Java Servlet.

---

## 1. KIẾN TRÚC HỆ THỐNG (3-LAYER ARCHITECTURE)

Mọi chức năng hoặc tệp tin được tạo mới/chỉnh sửa phải tuân thủ nghiêm ngặt mô hình 3 lớp (3-Layer Architecture). Không trộn lẫn logic giữa các tầng.

* **Presentation Layer (Controller/View):**
    * Sử dụng Java Servlet (`jakarta.servlet` hoặc `javax.servlet` tùy cấu hình dự án) để tiếp nhận request và điều hướng response.
    * Chỉ làm nhiệm vụ: Kiểm tra session/authentication, đọc tham số từ request (`getParameter`), gọi tầng Service, và forward/redirect dữ liệu (`req.setAttribute`, `sendRedirect`).
* **Business Logic Layer (Service):**
    * Nơi xử lý toàn bộ logic nghiệp vụ (tính toán, kiểm tra điều kiện, validation phức tạp).
    * Đóng vai trò trung gian giao tiếp giữa Controller và DAO.
* **Data Access Layer (DAO):**
    * Nơi duy nhất chứa các câu lệnh SQL (`SELECT`, `INSERT`, `UPDATE`, `DELETE`) giao tiếp với Cơ sở dữ liệu.
    * Chỉ trả về các Model (DTO/Entity) hoặc kiểu dữ liệu nguyên thủy, không chứa logic nghiệp vụ.

---

## 2. TIÊU CHUẨN MÃ NGUỒN (CODE STYLE)

* **Đơn giản & Tối giản:** Viết code tường minh, dễ đọc, dễ bảo trì. Tránh lạm dụng các kỹ thuật thiết kế quá phức tạp (over-engineering) khi không cần thiết.
* **Tính nhất quán:** Tổ chức package theo cấu trúc hiện tại của dự án:
    * `controller` (chứa các Servlet như `AddressServlet`)
    * `service` (chứa các lớp xử lý nghiệp vụ)
    * `dao` (chứa các lớp truy vấn dữ liệu như `DeliveryAddressDAO`)
    * `model` (chứa các thực thể như `Account`, `DeliveryAddress`)
    * `utils` (chứa các hàm tiện ích bổ trợ)

---

## 3. QUY TRÌNH BA BƯỚC BẮT BUỘC (PLAN - PROCESS - REVIEW)

Mỗi khi nhận được yêu cầu xử lý một tác vụ lập trình, Agent **không được viết code ngay lập tức** mà phải thực hiện tuần tự qua 3 bước sau:

### 🛠️ Bước 1: Planning (Lập kế hoạch)
* Phân tích yêu cầu của người dùng.
* Xác định rõ các file cần tạo mới hoặc chỉnh sửa thuộc tầng nào (Controller, Service, DAO, hay Model).
* Trình bày giải pháp tổng quan một cách ngắn gọn để người dùng nắm rõ hướng đi trước khi thực thi.

### 💻 Bước 2: Processing (Triển khai code)
* Tiến hành viết code dựa trên kế hoạch đã thống nhất.
* Code phải rõ ràng, có chú thích (comment) ở những đoạn xử lý quan trọng.

### 🔎 Bước 3: Review (Kiểm tra lại)
* Rà soát lại mã nguồn vừa viết để đảm bảo:
    * Đúng cấu trúc 3 lớp chưa?
    * Đã bắt ngoại lệ (`try-catch`) và đóng kết nối (Connection, PreparedStatement) đầy đủ chưa?
    * Có xảy ra lỗi tiềm ẩn (như `NullPointerException`) không? (Ví dụ: Kiểm tra xem `user != null` trước khi gọi `user.getId()`).

---

## 4. NGUYÊN TẮC THÔNG TIN (ANTI-ASSUMPTION)

> ⚠️ **QUY TẮC TỐI CAO:** KHÔNG TỰ Ý ĐƯA RA QUYẾT ĐỊNH KHI THIẾU THÔNG TIN.

* Nếu yêu cầu của người dùng mơ hồ, thiếu các dữ kiện quan trọng (ví dụ: cấu trúc bảng DB, kiểu dữ liệu trả về, phiên bản thư viện, hoặc logic nghiệp vụ cụ thể), Agent **bắt buộc phải dừng lại và đặt câu hỏi làm rõ**.
* Tuyệt đối không tự suy diễn cấu trúc database hoặc logic ngầm định nếu không chắc chắn.