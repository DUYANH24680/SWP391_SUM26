# TÀI LIỆU MÔ TẢ CƠ SỞ DỮ LIỆU - HỆ THỐNG SENAFRUIT

* **Tên cơ sở dữ liệu:** `SENAFRUIT`
* **Phiên bản:** 2.1 *(Đã chuẩn hóa, loại bỏ hoàn toàn thuộc tính thừa `seller_id` ở bảng Sản phẩm và chuyển sang quản lý tập trung theo `shop_id`)*

---

## I. SƠ ĐỒ MỐI QUAN HỆ TỔNG QUAN (CONCEPTUAL COUPLING)

Hệ thống được chia thành các phân hệ chính:
1. **Phân hệ Người dùng & Cửa hàng:** `Roles`, `Accounts`, `Shops`, `ShopRequests`.
2. **Phân hệ Sản phẩm:** `Categories`, `Products`, `ProductImages`.
3. **Phân hệ Đơn hàng & Vận chuyển:** `Orders`, `OrderDetails`, `DeliveryOrders`, `Vouchers`.
4. **Phân hệ Tương tác & Tiện ích:** `Feedbacks`, `Blogs`, `Notifications`.

---

## II. CHI TIẾT CÁC BẢNG DỮ LIỆU

### 1. Phân hệ Người dùng & Cửa hàng

#### Bảng `Roles` (Vai trò người dùng)
Lưu trữ các quyền/vai trò trong hệ thống như: `admin`, `seller`, `customer`, `delivery`.

| Tên trường | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `id` | INT | PK | IDENTITY(1,1) | Mã định danh vai trò |
| `name` | VARCHAR(20) | | NOT NULL, UNIQUE | Tên vai trò (`admin`, `seller`, `customer`, `delivery`) |
| `created_at` | DATETIME | | DEFAULT GETDATE() | Thời gian tạo |

#### Bảng `Accounts` (Tài khoản người dùng)
Quản lý toàn bộ thông tin đăng nhập và thông tin cá nhân của các đối tượng tham gia hệ thống.

| Tên trường | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `id` | INT | PK | IDENTITY(1,1) | Mã định danh tài khoản |
| `role_id` | INT | FK | NOT NULL | Liên kết với bảng `Roles` |
| `fullname` | NVARCHAR(100) | | NOT NULL | Họ và tên người dùng |
| `username` | VARCHAR(50) | | NOT NULL, UNIQUE | Tên đăng nhập |
| `password_hash`| VARCHAR(255) | | NOT NULL | Mật khẩu đã mã hóa |
| `email` | VARCHAR(255) | | NOT NULL, UNIQUE | Địa chỉ email |
| `phone` | VARCHAR(15) | | | Số điện thoại |
| `address` | NVARCHAR(255) | | | Địa chỉ mặc định |
| `avatar` | NVARCHAR(255) | | | Đường dẫn ảnh đại diện |
| `gender` | BIT | | | Giới tính (1: Nam, 0: Nữ) |
| `status` | TINYINT | | DEFAULT 1 | Trạng thái tài khoản (0: Blocked, 1: Active) |
| `created_at` | DATETIME | | DEFAULT GETDATE() | Ngày tạo tài khoản |

#### Bảng `Shops` (Thông tin cửa hàng)
Cửa hàng kinh doanh của các tài khoản có vai trò là `seller`.

| Tên trường | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `id` | INT | PK | IDENTITY(1,1) | Mã định danh cửa hàng |
| `owner_id` | INT | FK | NOT NULL | Chủ cửa hàng, liên kết với `Accounts` |
| `shop_name` | NVARCHAR(255) | | NOT NULL | Tên cửa hàng |
| `logo` | NVARCHAR(255) | | | Đường dẫn ảnh Logo |
| `description` | NVARCHAR(MAX) | | | Mô tả chi tiết về shop |
| `address` | NVARCHAR(255) | | | Địa chỉ cửa hàng |
| `status` | TINYINT | | DEFAULT 0 | 0: Pending, 1: Approved, 2: Rejected, 3: Blocked |
| `created_at` | DATETIME | | DEFAULT GETDATE() | Ngày đăng ký mở shop |

#### Bảng `ShopRequests` (Yêu cầu mở cửa hàng)
Nơi lưu trữ các đơn đăng ký mở shop từ phía người dùng để Admin phê duyệt.

| Tên trường | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `id` | INT | PK | IDENTITY(1,1) | Mã định danh yêu cầu |
| `account_id` | INT | FK | NOT NULL | Tài khoản gửi yêu cầu (`Accounts`) |
| `shop_name` | NVARCHAR(255) | | NOT NULL | Tên shop muốn đặt |
| `description` | NVARCHAR(MAX) | | | Mô tả shop |
| `address` | NVARCHAR(255) | | | Địa chỉ shop |
| `status` | TINYINT | | DEFAULT 0 | Trạng thái duyệt (0: Pending, 1: Approved, 2: Rejected) |
| `created_at` | DATETIME | | DEFAULT GETDATE() | Thời gian gửi yêu cầu |

---

### 2. Phân hệ Sản phẩm (Products)

#### Bảng `Categories` (Danh mục trái cây)

| Tên trường | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `id` | INT | PK | IDENTITY(1,1) | Mã định danh danh mục |
| `name` | NVARCHAR(100) | | NOT NULL, UNIQUE | Tên danh mục (Ví dụ: Trái cây nhập khẩu) |
| `image` | NVARCHAR(255) | | | Ảnh minh họa danh mục |
| `isDelete` | BIT | | DEFAULT 0 | Đánh dấu xóa mềm (1: Đã xóa, 0: Chưa xóa) |

#### Bảng `Products` (Sản phẩm trái cây)
Lưu trữ thông tin chi tiết của từng mặt hàng trái cây thuộc một Shop cụ thể.

| Tên trường | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `id` | INT | PK | IDENTITY(1,1) | Mã định danh sản phẩm |
| `category_id` | INT | FK | NOT NULL | Thuộc danh mục nào (`Categories`) |
| `shop_id` | INT | FK | NOT NULL | Thuộc cửa hàng nào (`Shops`) |
| `title` | NVARCHAR(255) | | NOT NULL | Tên sản phẩm trái cây |
| `image` | NVARCHAR(255) | | | Ảnh đại diện sản phẩm |
| `description` | NVARCHAR(MAX) | | | Bài viết mô tả sản phẩm |
| `unit` | NVARCHAR(20) | | | Đơn vị tính (Ví dụ: kg, thùng, hộp) |
| `stock_quantity`| INT | | DEFAULT 0 | Số lượng còn lại trong kho |
| `sold_quantity` | INT | | DEFAULT 0 | Số lượng đã bán thành công |
| `original_price`| DECIMAL(18,2) | | NOT NULL | Giá gốc ban đầu |
| `sale_price` | DECIMAL(18,2) | | | Giá khuyến mãi (nếu có) |
| `expired_date` | DATE | | | Ngày hết hạn/Hạn sử dụng |
| `average_rating`| DECIMAL(3,2) | | DEFAULT 0 | Điểm đánh giá trung bình (từ 1-5) |
| `is_featured` | BIT | | DEFAULT 0 | Sản phẩm nổi bật (1: Có, 0: Không) |
| `status` | TINYINT | | DEFAULT 0 | Trạng thái sản phẩm (0: Pending, 1: Active, 2: Hidden) |
| `isDelete` | BIT | | DEFAULT 0 | Đánh dấu xóa mềm (1: Đã xóa, 0: Chưa xóa) |
| `created_at` | DATETIME | | DEFAULT GETDATE() | Ngày đăng bán |

#### Bảng `ProductImages` (Bộ sưu tập ảnh phụ sản phẩm)

| Tên trường | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `id` | INT | PK | IDENTITY(1,1) | Mã định danh ảnh phụ |
| `product_id` | INT | FK | NOT NULL | Thuộc sản phẩm nào (`Products`) |
| `image_url` | NVARCHAR(255) | | NOT NULL | Đường dẫn ảnh phụ |
| `sort_order` | INT | | DEFAULT 0 | Thứ tự hiển thị hình ảnh |

---

### 3. Phân hệ Đơn hàng, Vận chuyển & Giảm giá

#### Bảng `Vouchers` (Mã giảm giá)

| Tên trường | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `id` | INT | PK | IDENTITY(1,1) | Mã định danh voucher |
| `code` | VARCHAR(50) | | NOT NULL, UNIQUE | Mã code để người dùng nhập (Ví dụ: SALE20) |
| `discount_percent`| FLOAT | | | Phần trăm giảm giá |
| `max_discount` | DECIMAL(18,2)| | | Số tiền giảm tối đa |
| `minimum_order`| DECIMAL(18,2)| | | Giá trị đơn hàng tối thiểu để áp dụng |
| `start_date` | DATETIME | | | Ngày mã bắt đầu có hiệu lực |
| `end_date` | DATETIME | | | Ngày mã hết hạn |
| `quantity` | INT | | | Tổng số lượng mã phát hành |
| `used_count` | INT | | DEFAULT 0 | Số lượng mã đã được sử dụng |
| `status` | BIT | | DEFAULT 1 | Trạng thái hoạt động (1: Kích hoạt, 0: Tắt) |

#### Bảng `Orders` (Đơn hàng tổng)

| Tên trường | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `id` | INT | PK | IDENTITY(1,1) | Mã định danh đơn hàng |
| `customer_id` | INT | FK | NOT NULL | Người mua hàng (`Accounts`) |
| `voucher_id` | INT | FK | | Mã giảm giá áp dụng (`Vouchers`) |
| `recipient_name`| NVARCHAR(100)| | | Tên người nhận hàng |
| `recipient_phone`| VARCHAR(15) | | | Số điện thoại nhận hàng |
| `address` | NVARCHAR(255)| | | Địa chỉ giao nhận đơn hàng |
| `payment_method`| VARCHAR(10) | | DEFAULT 'COD' | Phương thức thanh toán ('COD', 'VNPay', 'MoMo') |
| `status` | TINYINT | | DEFAULT 1 | Trạng thái đơn: 1:Pending, 2:Confirmed, 3:Shipping, 4:Delivered, 5:Canceled |
| `payment_status`| TINYINT | | DEFAULT 0 | Trạng thái thanh toán: 0:Unpaid, 1:Paid, 2:Refunded |
| `total_cost` | DECIMAL(18,2)| | NOT NULL | Tổng tiền hàng (chưa giảm giá) |
| `discount_amount`| DECIMAL(18,2)| | DEFAULT 0 | Số tiền được giảm trừ bằng voucher |
| `shipping_fee` | DECIMAL(18,2)| | DEFAULT 0 | Phí vận chuyển đơn hàng |
| `final_cost` | DECIMAL(18,2)| | | Số tiền thực tế khách phải trả |
| `note` | NVARCHAR(500)| | | Ghi chú từ khách hàng |
| `order_date` | DATETIME | | DEFAULT GETDATE() | Thời gian đặt hàng |
| `cancelled_at` | DATETIME | | | Thời gian đơn bị hủy (nếu có) |

#### Bảng `OrderDetails` (Chi tiết đơn hàng)

| Tên trường | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `id` | INT | PK | IDENTITY(1,1) | Mã chi tiết đơn hàng |
| `order_id` | INT | FK | NOT NULL | Thuộc mã đơn hàng tổng nào (`Orders`) |
| `product_id` | INT | FK | NOT NULL | Mã sản phẩm mua (`Products`) |
| `quantity` | INT | | NOT NULL | Số lượng mua |
| `unit_price` | DECIMAL(18,2)| | NOT NULL | Giá của 1 sản phẩm tại thời điểm mua |
| `total_price` | DECIMAL(18,2)| | NOT NULL | Thành tiền (`quantity` * `unit_price`) |

#### Bảng `DeliveryOrders` (Đơn vận chuyển dành cho Shipper)

| Tên trường | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `id` | INT | PK | IDENTITY(1,1) | Mã định danh vận đơn |
| `order_id` | INT | FK | NOT NULL, UNIQUE | Liên kết 1-1 với đơn hàng gốc (`Orders`) |
| `shipper_id` | INT | FK | NOT NULL | Tài khoản giao hàng phụ trách (`Accounts`) |
| `assigned_at` | DATETIME | | DEFAULT GETDATE() | Thời gian điều phối shipper |
| `picked_up_at` | DATETIME | | | Thời gian shipper đã lấy hàng |
| `delivered_at` | DATETIME | | | Thời gian giao thành công |
| `failed_at` | DATETIME | | | Thời gian giao thất bại |
| `fail_reason` | NVARCHAR(500)| | | Lý do giao hàng không thành công |
| `status` | TINYINT | | DEFAULT 1 | Trạng thái: 1:Assigned, 2:PickedUp, 3:Delivering, 4:Delivered, 5:Failed |
| `note` | NVARCHAR(500)| | | Ghi chú của shipper |

---

### 4. Phân hệ Tương tác & Bài viết

#### Bảng `Feedbacks` (Đánh giá & Phản hồi)
Người dùng chỉ được đánh giá sản phẩm sau khi trạng thái đơn hàng chuyển sang `Delivered`.

| Tên trường | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `id` | INT | PK | IDENTITY(1,1) | Mã định danh feedback |
| `customer_id` | INT | FK | NOT NULL | Khách hàng đánh giá |
| `product_id` | INT | FK | NOT NULL | Sản phẩm được đánh giá |
| `order_id` | INT | FK | NOT NULL | Đánh giá dựa trên đơn hàng nào |
| `rated_star` | INT | | CHECK (1-5) | Số sao đánh giá (từ 1 đến 5 sao) |
| `comment` | NVARCHAR(1000)| | | Nội dung nhận xét |
| `image_url` | NVARCHAR(255)| | | Hình ảnh phản hồi thực tế từ khách |
| `status` | TINYINT | | DEFAULT 0 | Trạng thái hiển thị (0: Pending, 1: Approved, 2: Rejected) |
| `created_at` | DATETIME | | DEFAULT GETDATE() | Thời gian đánh giá |

#### Bảng `Blogs` (Tin tức / Bài viết chia sẻ)

| Tên trường | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `id` | INT | PK | IDENTITY(1,1) | Mã định danh bài viết |
| `author_id` | INT | FK | NOT NULL | Tác giả bài viết (Admin hoặc Seller) |
| `title` | NVARCHAR(255)| | | Tiêu đề bài viết |
| `image` | NVARCHAR(255)| | | Ảnh đại diện bài viết |
| `description` | NVARCHAR(MAX)| | | Đoạn tóm tắt/mô tả ngắn ngắn |
| `content` | NVARCHAR(MAX)| | | Nội dung chi tiết bài viết (HTML/Text) |
| `is_featured` | BIT | | DEFAULT 0 | Bài viết nổi bật (1: Có, 0: Không) |
| `status` | BIT | | DEFAULT 1 | Trạng thái hoạt động (1: Hiển thị, 0: Ẩn) |
| `created_at` | DATETIME | | DEFAULT GETDATE() | Ngày đăng bài |

#### Bảng `Notifications` (Thông báo người dùng)

| Tên trường | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `id` | INT | PK | IDENTITY(1,1) | Mã thông báo |
| `account_id` | INT | FK | NOT NULL | Tài khoản nhận thông báo |
| `title` | NVARCHAR(255)| | NOT NULL | Tiêu đề thông báo |
| `message` | NVARCHAR(MAX)| | NOT NULL | Nội dung chi tiết thông báo |
| `type` | VARCHAR(15) | | | Thể loại: 'Order', 'Promotion', 'System', 'Delivery' |
| `link` | NVARCHAR(255)| | | Đường dẫn chuyển hướng khi nhấp vào thông báo |
| `is_read` | BIT | | DEFAULT 0 | Trạng thái (0: Chưa đọc, 1: Đã đọc) |
| `created_at` | DATETIME | | DEFAULT GETDATE() | Thời gian gửi |

---

## III. DANH SÁCH CÁC RÀNG BUỘC INDEXES (TỐI ƯU HÓA TRUY VẤN)

Để tăng tốc độ phản hồi và tối ưu hóa hiệu năng truy xuất dữ liệu, các chỉ mục (Indexes) sau đã được thiết lập:

* `IX_Accounts_Role`: Tăng tốc độ lọc và phân quyền người dùng theo vai trò.
* `IX_Products_Category`: Tối ưu tìm kiếm sản phẩm phân loại theo danh mục.
* `IX_Products_Shop`: Tăng tốc độ hiển thị và liệt kê danh sách sản phẩm trực thuộc riêng từng Cửa hàng.
* `IX_Orders_Customer`: Hỗ trợ tải nhanh lịch sử mua sắm của khách hàng.
* `IX_Orders_Status`: Tăng hiệu năng bộ lọc đơn hàng theo trạng thái xử lý cho Admin/Seller.
* `IX_Feedbacks_Product`: Tăng tốc tải toàn bộ phần đánh giá/feedback của một sản phẩm.
* `IX_Delivery_Shipper`: Giúp Shipper truy xuất nhanh danh sách vận đơn được giao.
* `IX_Delivery_Order`: Định vị nhanh trạng thái vận chuyển thông qua mã đơn hàng liên kết.

---

## IV. CÁC NGHIỆP VỤ ĐƯỢC ĐIỀU KHIỂN TỰ ĐỘNG (TRIGGERS)

Hệ thống tích hợp 4 Triggers xử lý tự động ở tầng Database, giúp giảm thiểu logic dư thừa trên ứng dụng:

1. **`trg_UpdateStock` (AFTER INSERT trên bảng `OrderDetails`):**
   * *Nghiệp vụ:* Tự động trừ số lượng sản phẩm tồn kho (`stock_quantity`) và cộng dồn vào số lượng đã bán (`sold_quantity`) dựa theo số lượng khách vừa đặt mua thành công.
2. **`trg_UpdateRating` (AFTER INSERT, UPDATE trên bảng `Feedbacks`):**
   * *Nghiệp vụ:* Tự động tính toán lại điểm số đánh giá trung bình (`average_rating`) của sản phẩm. Hệ thống chỉ gom nhóm và tính toán dựa trên các feedback đã được kiểm duyệt (`status = 1`).
3. **`trg_VoucherUsage` (AFTER INSERT trên bảng `Orders`):**
   * *Nghiệp vụ:* Nếu đơn hàng có áp dụng mã giảm giá (`voucher_id IS NOT NULL`), hệ thống tự động tăng số lần đã dùng (`used_count`) của voucher đó thêm 1 đơn vị.
4. **`trg_OrderStatusNotify` (AFTER UPDATE trên bảng `Orders`):**
   * *Nghiệp vụ:* Lắng nghe sự thay đổi của trường `status`. Khi đơn hàng chuyển trạng thái (Từ Xác nhận $\rightarrow$ Đang giao $\rightarrow$ Thành công/Hủy), hệ thống tự động tạo một bản ghi văn bản thông báo tương ứng vào bảng `Notifications` để gửi trực tiếp tới khách hàng.