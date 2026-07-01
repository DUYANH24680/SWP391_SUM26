-- ============================================================
-- FRUIT SHOP SYSTEM - DATABASE HOÀN CHỈNH
-- Phiên bản: 2.0 (tách Roles ra bảng riêng, thêm role Delivery, bổ sung DeliveryAddresses)
-- ============================================================

CREATE DATABASE SENAFRUIT
GO
USE SENAFRUIT
GO

-- ============================================================
-- 0. ROLES: Bảng vai trò
-- 'admin' | 'seller' | 'customer' | 'delivery'
-- ============================================================
CREATE TABLE Roles(
    id         INT PRIMARY KEY IDENTITY(1,1),
    name       VARCHAR(20)   NOT NULL UNIQUE,
    created_at DATETIME DEFAULT GETDATE()
);

-- ============================================================
-- 1. ACCOUNTS: Tài khoản người dùng
-- status: 0=Blocked | 1=Active
-- ============================================================
CREATE TABLE Accounts(
    id            INT PRIMARY KEY IDENTITY(1,1),
    role_id       INT           NOT NULL,
    fullname      NVARCHAR(100) NOT NULL,
    username      VARCHAR(50)   NOT NULL UNIQUE,
    password_hash VARCHAR(255)  NOT NULL,
    email         VARCHAR(255)  NOT NULL UNIQUE,
    phone         VARCHAR(15),
    address       NVARCHAR(255),
    avatar        NVARCHAR(255),
    gender        BIT,
    status        TINYINT DEFAULT 1,
    created_at    DATETIME DEFAULT GETDATE(),
    FOREIGN KEY(role_id) REFERENCES Roles(id)
);

-- ============================================================
-- SHOPS: Cửa hàng của Seller
-- status: 0=Pending | 1=Approved | 2=Rejected | 3=Blocked
-- ============================================================
CREATE TABLE Shops(
    id          INT PRIMARY KEY IDENTITY(1,1),
    owner_id    INT           NOT NULL,
    shop_name   NVARCHAR(255) NOT NULL,
    logo        NVARCHAR(255),
    description NVARCHAR(MAX),
    address     NVARCHAR(255),
    status      TINYINT DEFAULT 0,
    created_at  DATETIME DEFAULT GETDATE(),
    FOREIGN KEY(owner_id) REFERENCES Accounts(id)
);

-- ============================================================
-- SHOP REQUESTS: Đăng ký mở shop
-- status: 0=Pending | 1=Approved | 2=Rejected
-- ============================================================
CREATE TABLE ShopRequests(
    id          INT PRIMARY KEY IDENTITY(1,1),
    account_id  INT           NOT NULL,
    shop_name   NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    address     NVARCHAR(255),
    status      TINYINT DEFAULT 0,
    created_at  DATETIME DEFAULT GETDATE(),
    FOREIGN KEY(account_id) REFERENCES Accounts(id)
);

-- ============================================================
-- 2. CATEGORIES: Danh mục sản phẩm
-- ============================================================
CREATE TABLE Categories(
    id       INT PRIMARY KEY IDENTITY(1,1),
    name     NVARCHAR(100) NOT NULL UNIQUE,
    image    NVARCHAR(255),
    isDelete BIT DEFAULT 0
);

-- ============================================================
-- 3. PRODUCTS: Sản phẩm trái cây
-- seller_id: tài khoản Seller quản lý sản phẩm
-- status: 0=Pending | 1=Active | 2=Hidden
-- ============================================================
CREATE TABLE Products(
    id             INT PRIMARY KEY IDENTITY(1,1),
    category_id    INT           NOT NULL,
    seller_id      INT           NOT NULL,
    shop_id        INT           NOT NULL,
    title          NVARCHAR(255) NOT NULL,
    image          NVARCHAR(255),
    description    NVARCHAR(MAX),
    unit           NVARCHAR(20),
    stock_quantity INT DEFAULT 0,
    sold_quantity  INT DEFAULT 0,
    original_price DECIMAL(18,2) NOT NULL,
    sale_price     DECIMAL(18,2),
    expired_date   DATE,
    average_rating DECIMAL(3,2) DEFAULT 0,
    is_featured    BIT DEFAULT 0,
    status         TINYINT DEFAULT 0,
    isDelete       BIT DEFAULT 0,
    created_at     DATETIME DEFAULT GETDATE(),
    FOREIGN KEY(category_id) REFERENCES Categories(id),
    FOREIGN KEY(seller_id)   REFERENCES Accounts(id),
    FOREIGN KEY(shop_id)     REFERENCES Shops(id)
);

-- ============================================================
-- 4. PRODUCT IMAGES: Ảnh phụ của sản phẩm
-- ============================================================
CREATE TABLE ProductImages(
    id         INT PRIMARY KEY IDENTITY(1,1),
    product_id INT           NOT NULL,
    image_url  NVARCHAR(255) NOT NULL,
    sort_order INT DEFAULT 0,
    FOREIGN KEY(product_id) REFERENCES Products(id)
);

-- ============================================================
-- 5. VOUCHERS: Mã giảm giá
-- status: 0=Inactive | 1=Active
-- ============================================================
CREATE TABLE Vouchers(
    id               INT PRIMARY KEY IDENTITY(1,1),
    code             VARCHAR(50)   NOT NULL UNIQUE,
    discount_percent FLOAT,
    max_discount     DECIMAL(18,2),
    minimum_order    DECIMAL(18,2),
    start_date       DATETIME,
    end_date         DATETIME,
    quantity         INT,
    used_count       INT DEFAULT 0,
    status           BIT DEFAULT 1
);

-- ============================================================
-- 6. ORDERS: Đơn hàng
-- payment_method: 'COD' | 'VNPay' | 'MoMo'
-- status: 1=Pending | 2=Confirmed | 3=Shipping | 4=Delivered | 5=Canceled
-- payment_status: 0=Unpaid | 1=Paid | 2=Refunded
-- ============================================================
CREATE TABLE Orders(
    id              INT PRIMARY KEY IDENTITY(1,1),
    customer_id     INT           NOT NULL,
    voucher_id      INT,
    recipient_name  NVARCHAR(100),
    recipient_phone VARCHAR(15),
    address         NVARCHAR(255),
    payment_method  VARCHAR(10)   DEFAULT 'COD',
    status          TINYINT DEFAULT 1,
    payment_status  TINYINT DEFAULT 0,
    total_cost      DECIMAL(18,2) NOT NULL,
    discount_amount DECIMAL(18,2) DEFAULT 0,
    shipping_fee    DECIMAL(18,2) DEFAULT 0,
    final_cost      DECIMAL(18,2),
    note            NVARCHAR(500),
    order_date      DATETIME DEFAULT GETDATE(),
    cancelled_at    DATETIME,
    FOREIGN KEY(customer_id) REFERENCES Accounts(id),
    FOREIGN KEY(voucher_id)  REFERENCES Vouchers(id)
);

-- ============================================================
-- 7. ORDER DETAILS: Chi tiết sản phẩm trong đơn hàng
-- ============================================================
CREATE TABLE OrderDetails(
    id          INT PRIMARY KEY IDENTITY(1,1),
    order_id    INT           NOT NULL,
    product_id  INT           NOT NULL,
    quantity    INT           NOT NULL,
    unit_price  DECIMAL(18,2) NOT NULL,
    total_price DECIMAL(18,2) NOT NULL,
    FOREIGN KEY(order_id)   REFERENCES Orders(id),
    FOREIGN KEY(product_id) REFERENCES Products(id)
);

-- ============================================================
-- 8. DELIVERY ORDERS: Đơn giao hàng (dành cho Shipper)
-- status: 1=Assigned | 2=PickedUp | 3=Delivering | 4=Delivered | 5=Failed
-- ============================================================
CREATE TABLE DeliveryOrders(
    id              INT PRIMARY KEY IDENTITY(1,1),
    order_id        INT           NOT NULL UNIQUE,
    shipper_id      INT           NOT NULL,
    assigned_at     DATETIME DEFAULT GETDATE(),
    picked_up_at    DATETIME,
    delivered_at    DATETIME,
    failed_at       DATETIME,
    fail_reason     NVARCHAR(500),
    status          TINYINT DEFAULT 1,
    note            NVARCHAR(500),
    FOREIGN KEY(order_id)   REFERENCES Orders(id),
    FOREIGN KEY(shipper_id) REFERENCES Accounts(id)
);

-- ============================================================
-- 9. FEEDBACKS: Đánh giá sản phẩm (chỉ sau khi đơn Delivered)
-- status: 0=Pending | 1=Approved | 2=Rejected
-- ============================================================
CREATE TABLE Feedbacks(
    id          INT PRIMARY KEY IDENTITY(1,1),
    customer_id INT NOT NULL,
    product_id  INT NOT NULL,
    order_id    INT NOT NULL,
    rated_star  INT NOT NULL CHECK(rated_star BETWEEN 1 AND 5),
    comment     NVARCHAR(1000),
    image_url   NVARCHAR(255),
    status      TINYINT DEFAULT 0,
    created_at  DATETIME DEFAULT GETDATE(),
    FOREIGN KEY(customer_id) REFERENCES Accounts(id),
    FOREIGN KEY(product_id)  REFERENCES Products(id),
    FOREIGN KEY(order_id)    REFERENCES Orders(id)
);

-- ============================================================
-- 10. BLOGS: Bài viết / tin tức
-- author_id: Admin hoặc Seller
-- ============================================================
CREATE TABLE Blogs(
    id          INT PRIMARY KEY IDENTITY(1,1),
    author_id   INT           NOT NULL,
    title       NVARCHAR(255),
    image       NVARCHAR(255),
    description NVARCHAR(MAX),
    content     NVARCHAR(MAX),
    is_featured BIT DEFAULT 0,
    status      BIT DEFAULT 1,
    created_at  DATETIME DEFAULT GETDATE(),
    FOREIGN KEY(author_id) REFERENCES Accounts(id)
);

-- ============================================================
-- 11. NOTIFICATIONS: Thông báo người dùng
-- type: 'Order' | 'Promotion' | 'System' | 'Delivery'
-- ============================================================
CREATE TABLE Notifications(
    id         INT PRIMARY KEY IDENTITY(1,1),
    account_id INT           NOT NULL,
    title      NVARCHAR(255) NOT NULL,
    message    NVARCHAR(MAX) NOT NULL,
    type       VARCHAR(15),
    link       NVARCHAR(255),
    is_read    BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY(account_id) REFERENCES Accounts(id)
);

-- ============================================================
-- 12. DELIVERY ADDRESSES: Sổ địa chỉ giao hàng
-- ============================================================
CREATE TABLE DeliveryAddresses (
    id              INT PRIMARY KEY IDENTITY(1,1),
    customer_id     INT NOT NULL,
    recipient_name  NVARCHAR(255) NOT NULL,
    recipient_phone NVARCHAR(50) NOT NULL,
    address         NVARCHAR(500) NOT NULL,
    note            NVARCHAR(500),
    isDefault       BIT NOT NULL DEFAULT 0,
    created_at      DATETIME DEFAULT GETDATE(),
    FOREIGN KEY(customer_id) REFERENCES Accounts(id) ON DELETE CASCADE
);

-- ============================================================
-- 13. PASSWORD RESET TOKENS: Token quên mật khẩu
-- ============================================================
CREATE TABLE PasswordResetTokens (
    id              INT PRIMARY KEY IDENTITY(1,1),
    email           NVARCHAR(255) NOT NULL,
    token           NVARCHAR(255) NOT NULL,
    expiry_time     DATETIME NOT NULL,
    is_used         BIT NOT NULL DEFAULT 0,
    created_at      DATETIME DEFAULT GETDATE()
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX IX_Accounts_Role     ON Accounts(role_id);
CREATE INDEX IX_Products_Category ON Products(category_id);
CREATE INDEX IX_Products_Seller   ON Products(seller_id);
CREATE INDEX IX_Orders_Customer   ON Orders(customer_id);
CREATE INDEX IX_Orders_Status     ON Orders(status);
CREATE INDEX IX_Feedbacks_Product ON Feedbacks(product_id);
CREATE INDEX IX_Delivery_Shipper  ON DeliveryOrders(shipper_id);
CREATE INDEX IX_Delivery_Order    ON DeliveryOrders(order_id);
GO

-- ============================================================
-- TRIGGER: Giảm stock & tăng sold khi đặt hàng
-- ============================================================
CREATE TRIGGER trg_UpdateStock
ON OrderDetails AFTER INSERT
AS
BEGIN
    UPDATE Products
    SET stock_quantity = stock_quantity - i.quantity,
        sold_quantity  = sold_quantity  + i.quantity
    FROM Products p
    INNER JOIN inserted i ON p.id = i.product_id;
END
GO

-- ============================================================
-- TRIGGER: Cập nhật average_rating khi feedback được duyệt
-- ============================================================
CREATE TRIGGER trg_UpdateRating
ON Feedbacks AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE Products
    SET average_rating = (
        SELECT AVG(CAST(f.rated_star AS DECIMAL(3,2)))
        FROM Feedbacks f
        WHERE f.product_id = p.id AND f.status = 1
    )
    FROM Products p
    WHERE p.id IN (SELECT DISTINCT product_id FROM inserted);
END
GO

-- ============================================================
-- TRIGGER: Tăng used_count voucher khi đặt đơn
-- ============================================================
CREATE TRIGGER trg_VoucherUsage
ON Orders AFTER INSERT
AS
BEGIN
    UPDATE Vouchers
    SET used_count = used_count + 1
    FROM Vouchers v
    INNER JOIN inserted i ON v.id = i.voucher_id
    WHERE i.voucher_id IS NOT NULL;
END
GO

-- ============================================================
-- TRIGGER: Tự tạo thông báo khi đơn hàng thay đổi trạng thái
-- ============================================================
CREATE TRIGGER trg_OrderStatusNotify
ON Orders AFTER UPDATE
AS
BEGIN
    IF UPDATE(status)
    BEGIN
        INSERT INTO Notifications(account_id, title, message, type, link)
        SELECT
            i.customer_id,
            N'Cập nhật đơn hàng #' + CAST(i.id AS NVARCHAR),
            CASE i.status
                WHEN 2 THEN N'Đơn hàng của bạn đã được xác nhận.'
                WHEN 3 THEN N'Đơn hàng của bạn đang được giao.'
                WHEN 4 THEN N'Đơn hàng của bạn đã giao thành công.'
                WHEN 5 THEN N'Đơn hàng của bạn đã bị hủy.'
                ELSE        N'Trạng thái đơn hàng đã thay đổi.'
            END,
            'Order',
            '/orders/' + CAST(i.id AS NVARCHAR)
        FROM inserted i
        INNER JOIN deleted d ON i.id = d.id
        WHERE i.status <> d.status;
    END
END
GO

-- ============================================================
-- DỮ LIỆU MẪU
-- ============================================================

-- Roles
INSERT INTO Roles(name) VALUES
('admin'),
('seller'),
('customer'),
('delivery');

-- Accounts (role_id: 1=admin, 2=seller, 3=customer, 4=delivery)
INSERT INTO Accounts(role_id, fullname, username, password_hash, email, phone, status)
VALUES
(1, N'Quản Trị Viên',    'admin',     '6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b', 'admin@fruitshop.com',    '0900000001', 1),
(2, N'Nhân Viên Bán',    'seller',    '6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b', 'seller@fruitshop.com',   '0900000002', 1),
(3, N'Nguyễn Văn Khách', 'customer1', '6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b', 'customer1@gmail.com',    '0912345678', 1),
(3, N'Trần Thị Mua',     'customer2', '6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b', 'customer2@gmail.com',    '0987654321', 1),
(4, N'Lê Văn Shipper',   'shipper1',  '6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b', 'shipper1@fruitshop.com', '0933000001', 1);

-- Shops (Cần chèn trước khi chèn Products vì Products yêu cầu shop_id NOT NULL)
INSERT INTO Shops(owner_id, shop_name, logo, description, address, status)
VALUES
(2, N'Sena Fruit Store', 'logo.png', N'Cửa hàng trái cây sạch Sena', N'123 Đường Bưởi, Hà Nội', 1);

-- Categories
INSERT INTO Categories(name, image) VALUES
(N'Trái cây nhập khẩu', 'cat_import.png'),
(N'Trái cây nội địa',   'cat_local.png'),
(N'Trái cây hữu cơ',    'cat_organic.png'),
(N'Trái cây cao cấp',   'cat_premium.png');

-- Products (seller_id = 2, shop_id = 1)
INSERT INTO Products(category_id, seller_id, shop_id, title, image, description, unit, stock_quantity, original_price, sale_price, status)
VALUES
(1, 2, 1, N'Táo Mỹ Fuji',         'apple.png',  N'Táo Fuji nhập khẩu từ Mỹ, giòn ngọt',         N'kg', 100, 120000,  99000, 1),
(1, 2, 1, N'Nho Úc không hạt',    'grape.png',  N'Nho Úc tươi ngon, không hạt',                  N'kg',  80, 180000, 150000, 1),
(2, 2, 1, N'Xoài cát Hòa Lộc',   'mango.png',  N'Xoài cát Hòa Lộc đặc sản miền Nam',            N'kg', 150,  65000,   NULL, 1),
(3, 2, 1, N'Cam hữu cơ Đà Lạt',  'orange.png', N'Cam hữu cơ trồng tại Đà Lạt',                  N'kg', 120,  55000,  45000, 1),
(4, 2, 1, N'Sầu riêng Musang King','durian.png',N'Sầu riêng Musang King nhập khẩu Malaysia',      N'kg',  40, 350000, 320000, 1);

-- Vouchers
INSERT INTO Vouchers(code, discount_percent, max_discount, minimum_order, start_date, end_date, quantity) VALUES
('WELCOME10', 10, 50000,  100000, GETDATE(), DATEADD(MONTH, 3, GETDATE()), 100),
('SALE20',    20, 80000,  200000, GETDATE(), DATEADD(MONTH, 1, GETDATE()),  50),
('FREESHIP',   0,  NULL,   50000, GETDATE(), DATEADD(MONTH, 2, GETDATE()), 200);

-- Blogs
INSERT INTO Blogs(author_id, title, image, description, is_featured, status) VALUES
(1, N'5 loại trái cây tốt nhất cho sức khỏe',     'blog1.png', N'Khám phá những loại trái cây bổ dưỡng nhất bạn nên ăn mỗi ngày', 1, 1),
(2, N'Hướng dẫn bảo quản trái cây đúng cách',     'blog2.png', N'Mẹo hay để giữ trái cây tươi lâu hơn trong tủ lạnh',             0, 1),
(2, N'Phân biệt trái cây hữu cơ và thông thường', 'blog3.png', N'Những điểm khác biệt quan trọng bạn cần biết',                   0, 1);
GO
