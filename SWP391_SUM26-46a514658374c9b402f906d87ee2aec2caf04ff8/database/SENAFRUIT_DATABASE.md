# SENAFRUIT – Tài liệu Cơ sở Dữ liệu

> **Phiên bản:** 2.0 · **DBMS:** SQL Server · **Database:** `SENAFRUIT`

---

## Tổng quan

SENAFRUIT là hệ thống marketplace bán trái cây trực tuyến đa người bán (multi-seller). Database gồm **15 bảng chính**, **4 trigger tự động**, và các index tối ưu truy vấn.

**Các vai trò hệ thống:** `admin` · `seller` · `customer` · `delivery`

---

## Sơ đồ quan hệ (tóm tắt)

```
Roles ──< Accounts ──< Shops ──< Products >── Categories
                  │                    │
                  │              ProductImages
                  │
                  ├──< ShopRequests
                  ├──< Orders >── Vouchers
                  │         └──< OrderDetails >── Products
                  ├──< DeliveryOrders (shipper)
                  ├──< Feedbacks
                  ├──< Blogs
                  ├──< Notifications
                  ├──< DeliveryAddresses
                  └── PasswordResetTokens
```

---

## Chi tiết các bảng

### 1. `Roles` – Vai trò người dùng

| Cột | Kiểu | Ghi chú |
|-----|------|---------|
| `id` | INT PK IDENTITY | |
| `name` | VARCHAR(20) UNIQUE NOT NULL | `admin` / `seller` / `customer` / `delivery` |
| `created_at` | DATETIME | Mặc định `GETDATE()` |

---

### 2. `Accounts` – Tài khoản người dùng

| Cột | Kiểu | Ghi chú |
|-----|------|---------|
| `id` | INT PK IDENTITY | |
| `role_id` | INT FK → Roles | |
| `fullname` | NVARCHAR(100) NOT NULL | |
| `username` | VARCHAR(50) UNIQUE NOT NULL | |
| `password_hash` | VARCHAR(255) NOT NULL | |
| `email` | VARCHAR(255) UNIQUE NOT NULL | |
| `phone` | VARCHAR(15) | |
| `address` | NVARCHAR(255) | |
| `avatar` | NVARCHAR(255) | |
| `gender` | BIT | |
| `status` | TINYINT | `0`=Bị khóa · `1`=Hoạt động |
| `created_at` | DATETIME | Mặc định `GETDATE()` |

**Index:** `IX_Accounts_Role` trên `role_id`

---

### 3. `Shops` – Cửa hàng của Seller

| Cột | Kiểu | Ghi chú |
|-----|------|---------|
| `id` | INT PK IDENTITY | |
| `owner_id` | INT FK → Accounts | Tài khoản Seller |
| `shop_name` | NVARCHAR(255) NOT NULL | |
| `logo` | NVARCHAR(255) | |
| `description` | NVARCHAR(MAX) | |
| `address` | NVARCHAR(255) | |
| `status` | TINYINT | `0`=Pending · `1`=Approved · `2`=Rejected · `3`=Blocked |
| `created_at` | DATETIME | |

---

### 4. `ShopRequests` – Yêu cầu mở cửa hàng

| Cột | Kiểu | Ghi chú |
|-----|------|---------|
| `id` | INT PK IDENTITY | |
| `account_id` | INT FK → Accounts | |
| `shop_name` | NVARCHAR(255) NOT NULL | |
| `description` | NVARCHAR(MAX) | |
| `address` | NVARCHAR(255) | |
| `status` | TINYINT | `0`=Pending · `1`=Approved · `2`=Rejected |
| `created_at` | DATETIME | |

---

### 5. `Categories` – Danh mục sản phẩm

| Cột | Kiểu | Ghi chú |
|-----|------|---------|
| `id` | INT PK IDENTITY | |
| `name` | NVARCHAR(100) UNIQUE NOT NULL | |
| `image` | NVARCHAR(255) | |
| `isDelete` | BIT | Soft delete, mặc định `0` |

---

### 6. `Products` – Sản phẩm trái cây

| Cột | Kiểu | Ghi chú |
|-----|------|---------|
| `id` | INT PK IDENTITY | |
| `category_id` | INT FK → Categories | |
| `seller_id` | INT FK → Accounts | Seller quản lý |
| `shop_id` | INT FK → Shops | |
| `title` | NVARCHAR(255) NOT NULL | |
| `image` | NVARCHAR(255) | Ảnh đại diện |
| `description` | NVARCHAR(MAX) | |
| `unit` | NVARCHAR(20) | Đơn vị tính (kg, hộp…) |
| `stock_quantity` | INT | Tồn kho, tự giảm qua trigger |
| `sold_quantity` | INT | Đã bán, tự tăng qua trigger |
| `original_price` | DECIMAL(18,2) NOT NULL | Giá gốc |
| `sale_price` | DECIMAL(18,2) | Giá khuyến mãi (NULL = không KM) |
| `expired_date` | DATE | Hạn sử dụng |
| `average_rating` | DECIMAL(3,2) | Tự cập nhật qua trigger |
| `is_featured` | BIT | Sản phẩm nổi bật |
| `status` | TINYINT | `0`=Pending · `1`=Active · `2`=Hidden |
| `isDelete` | BIT | Soft delete |
| `created_at` | DATETIME | |

**Index:** `IX_Products_Category`, `IX_Products_Seller`

---

### 7. `ProductImages` – Ảnh phụ sản phẩm

| Cột | Kiểu | Ghi chú |
|-----|------|---------|
| `id` | INT PK IDENTITY | |
| `product_id` | INT FK → Products | |
| `image_url` | NVARCHAR(255) NOT NULL | |
| `sort_order` | INT | Thứ tự hiển thị |

---

### 8. `Vouchers` – Mã giảm giá

| Cột | Kiểu | Ghi chú |
|-----|------|---------|
| `id` | INT PK IDENTITY | |
| `code` | VARCHAR(50) UNIQUE NOT NULL | |
| `discount_percent` | FLOAT | % giảm giá |
| `max_discount` | DECIMAL(18,2) | Giảm tối đa |
| `minimum_order` | DECIMAL(18,2) | Giá trị đơn tối thiểu |
| `start_date` | DATETIME | |
| `end_date` | DATETIME | |
| `quantity` | INT | Số lượng phát hành |
| `used_count` | INT | Đã dùng, tự tăng qua trigger |
| `status` | BIT | `0`=Inactive · `1`=Active |

---

### 9. `Orders` – Đơn hàng

| Cột | Kiểu | Ghi chú |
|-----|------|---------|
| `id` | INT PK IDENTITY | |
| `customer_id` | INT FK → Accounts | |
| `voucher_id` | INT FK → Vouchers | Nullable |
| `recipient_name` | NVARCHAR(100) | Người nhận |
| `recipient_phone` | VARCHAR(15) | |
| `address` | NVARCHAR(255) | Địa chỉ giao |
| `payment_method` | VARCHAR(10) | `COD` / `VNPay` / `MoMo` |
| `status` | TINYINT | `1`=Pending · `2`=Confirmed · `3`=Shipping · `4`=Delivered · `5`=Canceled |
| `payment_status` | TINYINT | `0`=Chưa TT · `1`=Đã TT · `2`=Hoàn tiền |
| `total_cost` | DECIMAL(18,2) NOT NULL | Tổng trước giảm |
| `discount_amount` | DECIMAL(18,2) | Số tiền giảm |
| `shipping_fee` | DECIMAL(18,2) | Phí vận chuyển |
| `final_cost` | DECIMAL(18,2) | Thực thu |
| `note` | NVARCHAR(500) | |
| `order_date` | DATETIME | |
| `cancelled_at` | DATETIME | |

**Index:** `IX_Orders_Customer`, `IX_Orders_Status`

---

### 10. `OrderDetails` – Chi tiết đơn hàng

| Cột | Kiểu | Ghi chú |
|-----|------|---------|
| `id` | INT PK IDENTITY | |
| `order_id` | INT FK → Orders | |
| `product_id` | INT FK → Products | |
| `quantity` | INT NOT NULL | |
| `unit_price` | DECIMAL(18,2) NOT NULL | Giá tại thời điểm mua |
| `total_price` | DECIMAL(18,2) NOT NULL | `quantity × unit_price` |

---

### 11. `DeliveryOrders` – Đơn giao hàng (Shipper)

| Cột | Kiểu | Ghi chú |
|-----|------|---------|
| `id` | INT PK IDENTITY | |
| `order_id` | INT FK → Orders UNIQUE | Mỗi đơn chỉ có 1 shipper |
| `shipper_id` | INT FK → Accounts | |
| `assigned_at` | DATETIME | Thời điểm phân công |
| `picked_up_at` | DATETIME | Đã lấy hàng |
| `delivered_at` | DATETIME | Giao thành công |
| `failed_at` | DATETIME | Giao thất bại |
| `fail_reason` | NVARCHAR(500) | |
| `status` | TINYINT | `1`=Assigned · `2`=PickedUp · `3`=Delivering · `4`=Delivered · `5`=Failed |
| `note` | NVARCHAR(500) | |

**Index:** `IX_Delivery_Shipper`, `IX_Delivery_Order`

---

### 12. `Feedbacks` – Đánh giá sản phẩm

| Cột | Kiểu | Ghi chú |
|-----|------|---------|
| `id` | INT PK IDENTITY | |
| `customer_id` | INT FK → Accounts | |
| `product_id` | INT FK → Products | |
| `order_id` | INT FK → Orders | Chỉ đánh giá sau khi đơn Delivered |
| `rated_star` | INT | 1–5 sao (CHECK constraint) |
| `comment` | NVARCHAR(1000) | |
| `image_url` | NVARCHAR(255) | |
| `status` | TINYINT | `0`=Pending · `1`=Approved · `2`=Rejected |
| `created_at` | DATETIME | |

**Index:** `IX_Feedbacks_Product`

---

### 13. `Blogs` – Bài viết / Tin tức

| Cột | Kiểu | Ghi chú |
|-----|------|---------|
| `id` | INT PK IDENTITY | |
| `author_id` | INT FK → Accounts | Admin hoặc Seller |
| `title` | NVARCHAR(255) | |
| `image` | NVARCHAR(255) | |
| `description` | NVARCHAR(MAX) | Tóm tắt |
| `content` | NVARCHAR(MAX) | Nội dung đầy đủ |
| `is_featured` | BIT | Bài nổi bật |
| `status` | BIT | `0`=Ẩn · `1`=Hiển thị |
| `created_at` | DATETIME | |

---

### 14. `Notifications` – Thông báo người dùng

| Cột | Kiểu | Ghi chú |
|-----|------|---------|
| `id` | INT PK IDENTITY | |
| `account_id` | INT FK → Accounts | |
| `title` | NVARCHAR(255) NOT NULL | |
| `message` | NVARCHAR(MAX) NOT NULL | |
| `type` | VARCHAR(15) | `Order` / `Promotion` / `System` / `Delivery` |
| `link` | NVARCHAR(255) | Deep link |
| `is_read` | BIT | Mặc định `0` |
| `created_at` | DATETIME | |

---

### 15. `DeliveryAddresses` – Sổ địa chỉ giao hàng

| Cột | Kiểu | Ghi chú |
|-----|------|---------|
| `id` | INT PK IDENTITY | |
| `customer_id` | INT FK → Accounts | ON DELETE CASCADE |
| `recipient_name` | NVARCHAR(255) NOT NULL | |
| `recipient_phone` | NVARCHAR(50) NOT NULL | |
| `address` | NVARCHAR(500) NOT NULL | |
| `note` | NVARCHAR(500) | |
| `isDefault` | BIT | Địa chỉ mặc định |
| `created_at` | DATETIME | |

---

### 16. `PasswordResetTokens` – Token đặt lại mật khẩu

| Cột | Kiểu | Ghi chú |
|-----|------|---------|
| `id` | INT PK IDENTITY | |
| `email` | NVARCHAR(255) NOT NULL | |
| `token` | NVARCHAR(255) NOT NULL | |
| `expiry_time` | DATETIME NOT NULL | Thời hạn token |
| `is_used` | BIT | `0`=Chưa dùng · `1`=Đã dùng |
| `created_at` | DATETIME | |

---

## Triggers

| Trigger | Bảng | Sự kiện | Chức năng |
|---------|------|---------|-----------|
| `trg_UpdateStock` | `OrderDetails` | AFTER INSERT | Giảm `stock_quantity`, tăng `sold_quantity` trong `Products` |
| `trg_UpdateRating` | `Feedbacks` | AFTER INSERT, UPDATE | Tính lại `average_rating` của `Products` (chỉ feedback status=1) |
| `trg_VoucherUsage` | `Orders` | AFTER INSERT | Tăng `used_count` của `Vouchers` |
| `trg_OrderStatusNotify` | `Orders` | AFTER UPDATE | Tự tạo bản ghi `Notifications` khi `status` thay đổi |

---

## Indexes

| Index | Bảng | Cột |
|-------|------|-----|
| `IX_Accounts_Role` | Accounts | role_id |
| `IX_Products_Category` | Products | category_id |
| `IX_Products_Seller` | Products | seller_id |
| `IX_Orders_Customer` | Orders | customer_id |
| `IX_Orders_Status` | Orders | status |
| `IX_Feedbacks_Product` | Feedbacks | product_id |
| `IX_Delivery_Shipper` | DeliveryOrders | shipper_id |
| `IX_Delivery_Order` | DeliveryOrders | order_id |

---

## Dữ liệu mẫu (seed)

**Roles:** admin, seller, customer, delivery

**Accounts:**
| username | role | email |
|----------|------|-------|
| admin | admin | admin@fruitshop.com |
| seller | seller | seller@fruitshop.com |
| customer1 | customer | customer1@gmail.com |
| customer2 | customer | customer2@gmail.com |
| shipper1 | delivery | shipper1@fruitshop.com |

**Shops:** Sena Fruit Store (Hà Nội, status=Approved)

**Categories:** Trái cây nhập khẩu · Trái cây nội địa · Trái cây hữu cơ · Trái cây cao cấp

**Products (5 sản phẩm):** Táo Mỹ Fuji, Nho Úc không hạt, Xoài cát Hòa Lộc, Cam hữu cơ Đà Lạt, Sầu riêng Musang King

**Vouchers:** `WELCOME10` (10%), `SALE20` (20%), `FREESHIP`

**Blogs:** 3 bài viết về sức khỏe & bảo quản trái cây

---

## Lưu ý thiết kế

- **Soft delete** dùng cột `isDelete` (BIT) trên `Categories` và `Products` thay vì xóa vật lý.
- **Giá tại thời điểm mua** được lưu riêng vào `OrderDetails.unit_price` để tránh sai lệch khi giá sản phẩm thay đổi sau này.
- `DeliveryOrders.order_id` có ràng buộc **UNIQUE** – mỗi đơn hàng chỉ được gán cho đúng 1 shipper.
- `DeliveryAddresses` dùng **ON DELETE CASCADE** – xóa tài khoản customer sẽ tự xóa toàn bộ địa chỉ liên quan.
- Thông báo đơn hàng được **tạo tự động** bởi trigger `trg_OrderStatusNotify`, không cần xử lý thủ công từ backend.
