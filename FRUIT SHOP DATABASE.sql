CREATE DATABASE FruitShopSystem
GO

USE FruitShopSystem
GO

-- =============================================
-- BẢNG: Roles
-- Lưu vai trò hệ thống: Admin, Seller, Manager, Shipper
-- =============================================
CREATE TABLE Roles(
    id   INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(50) NOT NULL UNIQUE
);

-- =============================================
-- BẢNG: Staffs
-- Nhân viên hệ thống (Admin, Seller, Manager, Shipper)
-- seller_status dùng để track luồng đăng ký Seller
-- =============================================
CREATE TABLE Staffs(
    id            INT PRIMARY KEY IDENTITY(1,1),

    email         VARCHAR(255)   NOT NULL UNIQUE,
    fullname      NVARCHAR(100)  NOT NULL,
    username      VARCHAR(50)    NOT NULL UNIQUE,
    password_hash VARCHAR(255)   NOT NULL,

    gender        BIT            NOT NULL,
    phone         VARCHAR(15),
    address       NVARCHAR(255),
    avatar        NVARCHAR(255),

    role_id       INT            NOT NULL,

    seller_status TINYINT DEFAULT 0,
    -- 0: Normal Staff
    -- 1: Pending Seller (đang chờ duyệt)
    -- 2: Approved Seller
    -- 3: Seller Banned

    status        TINYINT DEFAULT 1,
    -- 1: Active
    -- 0: Blocked

    isDelete      BIT DEFAULT 0,

    created_at    DATETIME DEFAULT GETDATE(),

    FOREIGN KEY(role_id) REFERENCES Roles(id)
);

-- =============================================
-- BẢNG: Customers
-- Khách hàng đặt mua sản phẩm
-- =============================================
CREATE TABLE Customers(
    id            INT PRIMARY KEY IDENTITY(1,1),

    fullname      NVARCHAR(100)  NOT NULL,
    username      VARCHAR(50)    NOT NULL UNIQUE,
    password_hash VARCHAR(255)   NOT NULL,
    email         VARCHAR(255)   NOT NULL UNIQUE,
    phone         VARCHAR(15),
    address       NVARCHAR(255),
    gender        BIT,
    avatar        NVARCHAR(255),

    status        TINYINT DEFAULT 1,
    -- 1: Active
    -- 0: Blocked

    isDelete      BIT DEFAULT 0,

    created_at    DATETIME DEFAULT GETDATE()
);

-- =============================================
-- BẢNG: PasswordResetTokens
-- Token đặt lại mật khẩu qua email (dùng chung Customer & Staff)
-- =============================================
CREATE TABLE PasswordResetTokens(
    id          INT PRIMARY KEY IDENTITY(1,1),
    email       VARCHAR(255) NOT NULL,
    token       VARCHAR(255) NOT NULL UNIQUE,
    expiry_time DATETIME     NOT NULL,
    is_used     BIT DEFAULT 0,
    created_at  DATETIME DEFAULT GETDATE()
);

-- =============================================
-- BẢNG: Notifications
-- Thông báo trong ứng dụng (Order, Payment, Delivery, Promotion, System)
-- link: deeplink khi người dùng click vào thông báo
-- related_id: ID của đối tượng liên quan (order_id, product_id, ...)
-- =============================================
CREATE TABLE Notifications(
    id          INT PRIMARY KEY IDENTITY(1,1),
    customer_id INT NULL,
    staff_id    INT NULL,
    title       NVARCHAR(255) NOT NULL,
    message     NVARCHAR(MAX) NOT NULL,
    type        VARCHAR(50),
    -- 'Order', 'Payment', 'Delivery', 'Promotion', 'System'
    link        NVARCHAR(255) NULL,
    related_id  INT NULL,
    is_read     BIT DEFAULT 0,
    created_at  DATETIME DEFAULT GETDATE(),

    FOREIGN KEY(customer_id) REFERENCES Customers(id),
    FOREIGN KEY(staff_id)    REFERENCES Staffs(id)
);

-- =============================================
-- BẢNG: SellerRequests
-- Yêu cầu đăng ký trở thành Seller (Admin duyệt/từ chối)
-- =============================================
CREATE TABLE SellerRequests(
    id                   INT PRIMARY KEY IDENTITY(1,1),

    staff_id             INT           NOT NULL,

    shop_name            NVARCHAR(255) NOT NULL,
    shop_phone           VARCHAR(15),
    shop_address         NVARCHAR(255),
    business_description NVARCHAR(MAX),
    identity_card_front  NVARCHAR(255),
    identity_card_back   NVARCHAR(255),

    status               TINYINT DEFAULT 1,
    -- 1: Pending
    -- 2: Approved
    -- 3: Rejected

    admin_note           NVARCHAR(MAX),
    created_at           DATETIME DEFAULT GETDATE(),
    reviewed_at          DATETIME,

    FOREIGN KEY(staff_id) REFERENCES Staffs(id)
);

-- =============================================
-- BẢNG: Shops
-- Cửa hàng của Seller sau khi được Admin duyệt
-- seller_request_id: liên kết với đơn đăng ký đã được duyệt
-- =============================================
CREATE TABLE Shops(
    id                INT PRIMARY KEY IDENTITY(1,1),

    shop_code         VARCHAR(20)    UNIQUE NOT NULL,
    shop_name         NVARCHAR(100)  NOT NULL,
    owner_staff_id    INT            NOT NULL,
    approved_by       INT,
    seller_request_id INT NULL,

    phone             VARCHAR(15),
    address           NVARCHAR(255),
    logo              NVARCHAR(255),
    banner            NVARCHAR(255),
    description       NVARCHAR(500),

    total_report      INT DEFAULT 0,

    status            TINYINT DEFAULT 1,
    -- 1: Active
    -- 2: Warning
    -- 3: Suspended
    -- 4: Banned

    isDelete          BIT DEFAULT 0,
    created_at        DATETIME DEFAULT GETDATE(),

    FOREIGN KEY(owner_staff_id)    REFERENCES Staffs(id),
    FOREIGN KEY(approved_by)       REFERENCES Staffs(id),
    FOREIGN KEY(seller_request_id) REFERENCES SellerRequests(id)
);

-- =============================================
-- BẢNG: FruitOrigins
-- Nguồn gốc xuất xứ trái cây (Mỹ, Úc, Nhật, ...)
-- =============================================
CREATE TABLE FruitOrigins(
    id           INT PRIMARY KEY IDENTITY(1,1),
    country_name NVARCHAR(100) NOT NULL,
    code         VARCHAR(10),
    isDelete     BIT DEFAULT 0
);

-- =============================================
-- BẢNG: Categories
-- Danh mục sản phẩm (Nhập khẩu, Nội địa, Cao cấp, Hữu cơ)
-- =============================================
CREATE TABLE Categories(
    id       INT PRIMARY KEY IDENTITY(1,1),
    name     NVARCHAR(100) NOT NULL UNIQUE,
    isDelete BIT DEFAULT 0
);

-- =============================================
-- BẢNG: FruitTypes
-- Loại trái cây (Táo, Nho, Cherry, ...)
-- =============================================
CREATE TABLE FruitTypes(
    id       INT PRIMARY KEY IDENTITY(1,1),
    name     NVARCHAR(100) NOT NULL UNIQUE,
    isDelete BIT DEFAULT 0
);

-- =============================================
-- BẢNG: Products
-- Sản phẩm trái cây của các Shop
-- average_rating: lưu cache điểm trung bình để tránh JOIN phức tạp
-- =============================================
CREATE TABLE Products(
    id                  INT PRIMARY KEY IDENTITY(1,1),

    sku                 VARCHAR(30)    UNIQUE NOT NULL,
    shop_id             INT            NOT NULL,
    fruit_origin_id     INT            NOT NULL,
    fruit_type_id       INT            NOT NULL,
    category_id         INT            NOT NULL,

    title               NVARCHAR(255)  NOT NULL,
    image               NVARCHAR(255),
    description         NVARCHAR(MAX),

    stock_quantity      INT DEFAULT 0,
    reserved_quantity   INT DEFAULT 0,
    sold_quantity       INT DEFAULT 0,

    unit                NVARCHAR(20),
    weight              FLOAT,

    original_price      DECIMAL(18,2)  NOT NULL,
    sale_price          DECIMAL(18,2),

    expired_date        DATE,
    low_stock_threshold INT DEFAULT 5,

    average_rating      DECIMAL(3,2) DEFAULT 0,
    is_featured         BIT DEFAULT 0,

    status              TINYINT DEFAULT 0,
    -- 0: Pending Approval
    -- 1: Approved / Active
    -- 2: Rejected
    -- 3: Hidden / Inactive

    admin_note          NVARCHAR(MAX),
    isDelete            BIT DEFAULT 0,
    created_at          DATETIME DEFAULT GETDATE(),
    updated_at          DATETIME,

    FOREIGN KEY(shop_id)         REFERENCES Shops(id),
    FOREIGN KEY(fruit_origin_id) REFERENCES FruitOrigins(id),
    FOREIGN KEY(fruit_type_id)   REFERENCES FruitTypes(id),
    FOREIGN KEY(category_id)     REFERENCES Categories(id)
);

-- =============================================
-- BẢNG: ProductWeightVariants
-- Biến thể trọng lượng sản phẩm (500g, 1kg, 2kg, ...)
-- =============================================
CREATE TABLE ProductWeightVariants(
    id                  INT PRIMARY KEY IDENTITY(1,1),
    product_id          INT            NOT NULL,
    weight              NVARCHAR(50)   NOT NULL,
    original_price      DECIMAL(18,2)  NOT NULL,
    sale_price          DECIMAL(18,2),
    stock_quantity      INT DEFAULT 0,
    reserved_quantity   INT DEFAULT 0,
    sold_quantity       INT DEFAULT 0,
    low_stock_threshold INT DEFAULT 5,
    isDelete            BIT DEFAULT 0,

    FOREIGN KEY(product_id) REFERENCES Products(id)
);

-- =============================================
-- BẢNG: ProductImages
-- Thư viện ảnh sản phẩm (nhiều ảnh/sản phẩm)
-- =============================================
CREATE TABLE ProductImages(
    id         INT PRIMARY KEY IDENTITY(1,1),
    product_id INT           NOT NULL,
    image_url  NVARCHAR(255) NOT NULL,
    sort_order INT DEFAULT 0,

    FOREIGN KEY(product_id) REFERENCES Products(id)
);

-- =============================================
-- BẢNG: Wishlists
-- Danh sách yêu thích của khách hàng
-- =============================================
CREATE TABLE Wishlists(
    id          INT PRIMARY KEY IDENTITY(1,1),
    customer_id INT NOT NULL,
    product_id  INT NOT NULL,
    created_at  DATETIME DEFAULT GETDATE(),

    UNIQUE(customer_id, product_id),
    FOREIGN KEY(customer_id) REFERENCES Customers(id),
    FOREIGN KEY(product_id)  REFERENCES Products(id)
);

-- =============================================
-- BẢNG: FlashSales
-- Chương trình Flash Sale có thời gian giới hạn
-- =============================================
CREATE TABLE FlashSales(
    id          INT PRIMARY KEY IDENTITY(1,1),
    name        NVARCHAR(255) NOT NULL,
    description NVARCHAR(500),
    start_date  DATETIME      NOT NULL,
    end_date    DATETIME      NOT NULL,
    created_by  INT NULL,
    -- staff_id của Admin hoặc Seller tạo flash sale
    status      BIT DEFAULT 1,
    isDelete    BIT DEFAULT 0,
    created_at  DATETIME DEFAULT GETDATE(),

    FOREIGN KEY(created_by) REFERENCES Staffs(id)
);

-- =============================================
-- BẢNG: FlashSaleProducts
-- Sản phẩm tham gia Flash Sale
-- discount_percent: % giảm để hiển thị trên UI
-- =============================================
CREATE TABLE FlashSaleProducts(
    id                 INT PRIMARY KEY IDENTITY(1,1),
    flash_sale_id      INT           NOT NULL,
    product_id         INT           NOT NULL,
    weight_variant_id  INT NULL,
    flash_sale_price   DECIMAL(18,2) NOT NULL,
    discount_percent   FLOAT,
    flash_sale_quantity INT          NOT NULL,
    flash_sale_sold    INT DEFAULT 0,

    FOREIGN KEY(flash_sale_id)     REFERENCES FlashSales(id),
    FOREIGN KEY(product_id)        REFERENCES Products(id),
    FOREIGN KEY(weight_variant_id) REFERENCES ProductWeightVariants(id)
);

-- =============================================
-- BẢNG: Carts
-- Giỏ hàng (mỗi khách hàng có 1 giỏ hàng duy nhất)
-- =============================================
CREATE TABLE Carts(
    id          INT PRIMARY KEY IDENTITY(1,1),
    customer_id INT NOT NULL UNIQUE,
    created_at  DATETIME DEFAULT GETDATE(),

    FOREIGN KEY(customer_id) REFERENCES Customers(id)
);

-- =============================================
-- BẢNG: CartProducts
-- Chi tiết sản phẩm trong giỏ hàng
-- flash_sale_id: nếu thêm vào giỏ từ chương trình Flash Sale
-- =============================================
CREATE TABLE CartProducts(
    id                INT PRIMARY KEY IDENTITY(1,1),
    cart_id           INT NOT NULL,
    product_id        INT NOT NULL,
    weight_variant_id INT NULL,
    flash_sale_id     INT NULL,
    quantity          INT NOT NULL,
    created_at        DATETIME DEFAULT GETDATE(),

    FOREIGN KEY(cart_id)           REFERENCES Carts(id),
    FOREIGN KEY(product_id)        REFERENCES Products(id),
    FOREIGN KEY(weight_variant_id) REFERENCES ProductWeightVariants(id),
    FOREIGN KEY(flash_sale_id)     REFERENCES FlashSales(id)
);

-- =============================================
-- BẢNG: Payments
-- Phương thức thanh toán (COD, VNPay, Momo)
-- =============================================
CREATE TABLE Payments(
    id       INT PRIMARY KEY IDENTITY(1,1),
    name     NVARCHAR(50) NOT NULL,
    status   BIT DEFAULT 1,
    isDelete BIT DEFAULT 0
);

-- =============================================
-- BẢNG: OrderStatus
-- Trạng thái đơn hàng (Pending, Confirmed, Packing, Shipping, Delivered, Canceled)
-- =============================================
CREATE TABLE OrderStatus(
    id       INT PRIMARY KEY IDENTITY(1,1),
    name     NVARCHAR(50) NOT NULL,
    isDelete BIT DEFAULT 0
);

-- =============================================
-- BẢNG: DeliveryAddresses
-- Địa chỉ giao hàng đã lưu của khách hàng
-- =============================================
CREATE TABLE DeliveryAddresses(
    id              INT PRIMARY KEY IDENTITY(1,1),
    customer_id     INT           NOT NULL,
    recipient_name  NVARCHAR(100),
    recipient_phone VARCHAR(15),
    address         NVARCHAR(255),
    note            NVARCHAR(255),
    isDefault       BIT DEFAULT 0,
    created_at      DATETIME DEFAULT GETDATE(),

    FOREIGN KEY(customer_id) REFERENCES Customers(id)
);

-- =============================================
-- BẢNG: Vouchers
-- Mã giảm giá (toàn sàn hoặc theo Shop)
-- type: 1 = Platform voucher, 2 = Shop voucher
-- used_count: số lần đã được sử dụng
-- =============================================
CREATE TABLE Vouchers(
    id               INT PRIMARY KEY IDENTITY(1,1),
    code             VARCHAR(50)    UNIQUE,
    shop_id          INT NULL,
    -- NULL = voucher toàn sàn (Admin tạo)
    -- NOT NULL = voucher của Shop (Seller tạo)

    type             TINYINT DEFAULT 1,
    -- 1: Platform (toàn sàn)
    -- 2: Shop

    discount_percent FLOAT,
    max_discount     DECIMAL(18,2),
    minimum_order    DECIMAL(18,2),
    start_date       DATETIME,
    end_date         DATETIME,
    quantity         INT,
    used_count       INT DEFAULT 0,
    status           BIT DEFAULT 1,

    FOREIGN KEY(shop_id) REFERENCES Shops(id)
);

-- =============================================
-- BẢNG: Orders
-- Đơn hàng của khách hàng
-- payment_status: trạng thái thanh toán (riêng với trạng thái đơn)
-- discount_amount: số tiền thực tế được giảm từ voucher
-- cancelled_at: thời điểm hủy đơn
-- =============================================
CREATE TABLE Orders(
    id                  INT PRIMARY KEY IDENTITY(1,1),

    customer_id         INT           NOT NULL,
    shop_id             INT           NOT NULL,
    payment_id          INT           NOT NULL,
    status_id           INT           NOT NULL,
    delivery_address_id INT           NOT NULL,
    voucher_id          INT,

    total_cost          DECIMAL(18,2) NOT NULL,
    discount_amount     DECIMAL(18,2) DEFAULT 0,
    shipping_fee        DECIMAL(18,2) DEFAULT 0,
    final_cost          DECIMAL(18,2),

    payment_status      TINYINT DEFAULT 0,
    -- 0: Unpaid
    -- 1: Paid
    -- 2: Refunded

    note                NVARCHAR(500),
    order_date          DATETIME DEFAULT GETDATE(),
    cancelled_at        DATETIME NULL,
    isDelete            BIT DEFAULT 0,

    FOREIGN KEY(customer_id)         REFERENCES Customers(id),
    FOREIGN KEY(shop_id)             REFERENCES Shops(id),
    FOREIGN KEY(payment_id)          REFERENCES Payments(id),
    FOREIGN KEY(status_id)           REFERENCES OrderStatus(id),
    FOREIGN KEY(delivery_address_id) REFERENCES DeliveryAddresses(id),
    FOREIGN KEY(voucher_id)          REFERENCES Vouchers(id)
);

-- =============================================
-- BẢNG: Invoices
-- Hóa đơn điện tử tự động sinh sau khi thanh toán thành công
-- =============================================
CREATE TABLE Invoices(
    id                     INT PRIMARY KEY IDENTITY(1,1),
    order_id               INT           NOT NULL UNIQUE,
    invoice_code           VARCHAR(50)   UNIQUE NOT NULL,
    invoice_date           DATETIME DEFAULT GETDATE(),
    tax_amount             DECIMAL(18,2) DEFAULT 0,
    total_amount           DECIMAL(18,2) NOT NULL,
    payment_transaction_id VARCHAR(100),
    status                 TINYINT DEFAULT 1,
    -- 1: Generated
    -- 2: Paid
    -- 3: Cancelled

    FOREIGN KEY(order_id) REFERENCES Orders(id)
);

-- =============================================
-- BẢNG: OrderDetails
-- Chi tiết từng sản phẩm trong đơn hàng
-- =============================================
CREATE TABLE OrderDetails(
    id                INT PRIMARY KEY IDENTITY(1,1),
    order_id          INT           NOT NULL,
    product_id        INT           NOT NULL,
    weight_variant_id INT NULL,
    quantity          INT           NOT NULL,
    unit_price        DECIMAL(18,2) NOT NULL,
    total_price       DECIMAL(18,2) NOT NULL,
    isDelete          BIT DEFAULT 0,

    FOREIGN KEY(order_id)          REFERENCES Orders(id),
    FOREIGN KEY(product_id)        REFERENCES Products(id),
    FOREIGN KEY(weight_variant_id) REFERENCES ProductWeightVariants(id)
);

-- =============================================
-- BẢNG: OrderTracking
-- Lịch sử tracking trạng thái giao hàng
-- staff_id: Shipper hoặc Seller cập nhật trạng thái
-- =============================================
CREATE TABLE OrderTracking(
    id         INT PRIMARY KEY IDENTITY(1,1),
    order_id   INT           NOT NULL,
    status     NVARCHAR(100),
    note       NVARCHAR(255),
    staff_id   INT NULL,
    created_at DATETIME DEFAULT GETDATE(),

    FOREIGN KEY(order_id) REFERENCES Orders(id),
    FOREIGN KEY(staff_id) REFERENCES Staffs(id)
);

-- =============================================
-- BẢNG: Feedbacks
-- Đánh giá sản phẩm của khách hàng (sau khi mua)
-- order_id: chỉ được review sau khi đơn hàng Delivered
-- updated_at: hỗ trợ chức năng Edit Review
-- =============================================
CREATE TABLE Feedbacks(
    id         INT PRIMARY KEY IDENTITY(1,1),
    customer_id INT NOT NULL,
    product_id  INT NOT NULL,
    order_id    INT NOT NULL,

    rated_star  INT NOT NULL
        CHECK(rated_star BETWEEN 1 AND 5),

    comment     NVARCHAR(1000),
    image_url   NVARCHAR(255),

    status      TINYINT DEFAULT 0,
    -- 0: Pending Approval
    -- 1: Approved
    -- 2: Rejected

    admin_note  NVARCHAR(MAX),
    isDelete    BIT DEFAULT 0,
    created_at  DATETIME DEFAULT GETDATE(),
    updated_at  DATETIME NULL,

    FOREIGN KEY(customer_id) REFERENCES Customers(id),
    FOREIGN KEY(product_id)  REFERENCES Products(id),
    FOREIGN KEY(order_id)    REFERENCES Orders(id)
);

-- =============================================
-- BẢNG: Reports
-- Khiếu nại của khách hàng về Shop hoặc Sản phẩm
-- product_id: NULL nếu report Shop, NOT NULL nếu report Sản phẩm cụ thể
-- resolved_by: Admin xử lý
-- (Đã gộp ProductReports vào đây)
-- =============================================
CREATE TABLE Reports(
    id             INT PRIMARY KEY IDENTITY(1,1),

    customer_id    INT NOT NULL,
    shop_id        INT NOT NULL,
    order_id       INT NOT NULL,
    product_id     INT NULL,
    -- NULL: report cả Shop / NOT NULL: report sản phẩm cụ thể

    title          NVARCHAR(255),
    reason         NVARCHAR(MAX),
    image_evidence NVARCHAR(255),

    status         TINYINT DEFAULT 1,
    -- 1: Pending
    -- 2: Reviewing
    -- 3: Resolved
    -- 4: Rejected

    admin_note     NVARCHAR(MAX),
    resolved_by    INT NULL,
    created_at     DATETIME DEFAULT GETDATE(),
    resolved_at    DATETIME NULL,

    FOREIGN KEY(customer_id) REFERENCES Customers(id),
    FOREIGN KEY(shop_id)     REFERENCES Shops(id),
    FOREIGN KEY(order_id)    REFERENCES Orders(id),
    FOREIGN KEY(product_id)  REFERENCES Products(id),
    FOREIGN KEY(resolved_by) REFERENCES Staffs(id)
);

-- =============================================
-- BẢNG: ShopViolations
-- Vi phạm của Shop, Admin ghi nhận và xử phạt
-- admin_id: Admin thực hiện xử phạt
-- (Đã gộp ReportActions vào đây)
-- =============================================
CREATE TABLE ShopViolations(
    id             INT PRIMARY KEY IDENTITY(1,1),

    shop_id        INT NOT NULL,
    report_id      INT NULL,
    admin_id       INT NOT NULL,

    violation_type TINYINT,
    -- 1: Fake Product
    -- 2: Rotten Fruit
    -- 3: Wrong Product
    -- 4: Scam
    -- 5: Spam

    penalty_type   TINYINT,
    -- 1: Warning
    -- 2: Temporary Ban
    -- 3: Permanent Ban

    penalty_days   INT,
    note           NVARCHAR(MAX),
    created_at     DATETIME DEFAULT GETDATE(),

    FOREIGN KEY(shop_id)   REFERENCES Shops(id),
    FOREIGN KEY(report_id) REFERENCES Reports(id),
    FOREIGN KEY(admin_id)  REFERENCES Staffs(id)
);

-- =============================================
-- BẢNG: StockIns
-- Lịch sử nhập hàng (Restock Management)
-- staff_id: Seller hoặc Manager thực hiện nhập
-- note: ghi chú khi nhập hàng
-- =============================================
CREATE TABLE StockIns(
    id                INT PRIMARY KEY IDENTITY(1,1),
    product_id        INT           NOT NULL,
    weight_variant_id INT NULL,
    staff_id          INT           NOT NULL,
    quantity          INT           NOT NULL,
    import_price      DECIMAL(18,2),
    note              NVARCHAR(255) NULL,
    imported_at       DATETIME DEFAULT GETDATE(),

    FOREIGN KEY(product_id)        REFERENCES Products(id),
    FOREIGN KEY(weight_variant_id) REFERENCES ProductWeightVariants(id),
    FOREIGN KEY(staff_id)          REFERENCES Staffs(id)
);

-- =============================================
-- BẢNG: Sliders
-- Ảnh banner slider hiển thị trên trang chủ
-- =============================================
CREATE TABLE Sliders(
    id         INT PRIMARY KEY IDENTITY(1,1),
    title      NVARCHAR(255),
    image      NVARCHAR(255),
    link_url   NVARCHAR(255),
    note       NVARCHAR(500),
    start_date DATE,
    end_date   DATE,
    sort_order INT DEFAULT 0,
    status     BIT DEFAULT 1,
    isDelete   BIT DEFAULT 0
);

-- =============================================
-- BẢNG: Blogs
-- Bài viết / tin tức hiển thị trên trang chủ
-- =============================================
CREATE TABLE Blogs(
    id          INT PRIMARY KEY IDENTITY(1,1),
    staff_id    INT           NOT NULL,
    title       NVARCHAR(255),
    image       NVARCHAR(255),
    description NVARCHAR(MAX),
    content     NVARCHAR(MAX),
    is_featured BIT DEFAULT 0,
    status      BIT DEFAULT 1,
    created_at  DATETIME DEFAULT GETDATE(),
    updated_at  DATETIME NULL,

    FOREIGN KEY(staff_id) REFERENCES Staffs(id)
);

-- =============================================
-- INDEXES
-- =============================================
CREATE INDEX IX_Products_Shop       ON Products(shop_id);
CREATE INDEX IX_Products_Category   ON Products(category_id);
CREATE INDEX IX_Products_Origin     ON Products(fruit_origin_id);
CREATE INDEX IX_Products_FruitType  ON Products(fruit_type_id);
CREATE INDEX IX_Orders_Customer     ON Orders(customer_id);
CREATE INDEX IX_Orders_Shop         ON Orders(shop_id);
CREATE INDEX IX_Orders_Status       ON Orders(status_id);
CREATE INDEX IX_Reports_Shop        ON Reports(shop_id);
CREATE INDEX IX_Feedbacks_Product   ON Feedbacks(product_id);
CREATE INDEX IX_Feedbacks_Customer  ON Feedbacks(customer_id);
CREATE INDEX IX_Notifications_Cust  ON Notifications(customer_id);
CREATE INDEX IX_Notifications_Staff ON Notifications(staff_id);
GO

-- =============================================
-- TRIGGER: Cập nhật tồn kho khi tạo OrderDetail
-- Giảm stock_quantity, tăng sold_quantity
-- =============================================
CREATE TRIGGER trg_UpdateProductStock
ON OrderDetails
AFTER INSERT
AS
BEGIN
    -- Giảm tồn kho variant nếu có chỉ định variant
    UPDATE ProductWeightVariants
    SET
        stock_quantity  = stock_quantity  - i.quantity,
        sold_quantity   = sold_quantity   + i.quantity
    FROM ProductWeightVariants v
    INNER JOIN inserted i ON v.id = i.weight_variant_id
    WHERE i.weight_variant_id IS NOT NULL;

    -- Giảm tồn kho sản phẩm nếu không có variant
    UPDATE Products
    SET
        stock_quantity = stock_quantity - i.quantity
    FROM Products p
    INNER JOIN inserted i ON p.id = i.product_id
    WHERE i.weight_variant_id IS NULL;

    -- Tăng sold_quantity tổng của sản phẩm trong mọi trường hợp
    UPDATE Products
    SET
        sold_quantity = sold_quantity + i.quantity
    FROM Products p
    INNER JOIN inserted i ON p.id = i.product_id;
END
GO

-- =============================================
-- TRIGGER: Cập nhật tồn kho khi nhập hàng (StockIn)
-- =============================================
CREATE TRIGGER trg_UpdateProductStockOnImport
ON StockIns
AFTER INSERT
AS
BEGIN
    -- Tăng tồn kho variant nếu có
    UPDATE ProductWeightVariants
    SET
        stock_quantity = stock_quantity + i.quantity
    FROM ProductWeightVariants v
    INNER JOIN inserted i ON v.id = i.weight_variant_id
    WHERE i.weight_variant_id IS NOT NULL;

    -- Tăng tồn kho sản phẩm nếu không có variant
    UPDATE Products
    SET
        stock_quantity = stock_quantity + i.quantity
    FROM Products p
    INNER JOIN inserted i ON p.id = i.product_id
    WHERE i.weight_variant_id IS NULL;
END
GO

-- =============================================
-- TRIGGER: Cập nhật total_report khi có Report mới
-- =============================================
CREATE TRIGGER trg_UpdateShopReportCount
ON Reports
AFTER INSERT
AS
BEGIN
    UPDATE Shops
    SET total_report = total_report + 1
    FROM Shops s
    INNER JOIN inserted i ON s.id = i.shop_id;
END
GO

-- =============================================
-- TRIGGER: Tự động thay đổi trạng thái Shop theo số report
-- =============================================
CREATE TRIGGER trg_AutoBanShop
ON Reports
AFTER INSERT
AS
BEGIN
    UPDATE Shops
    SET status =
        CASE
            WHEN total_report >= 10 THEN 4  -- Banned
            WHEN total_report >= 5  THEN 3  -- Suspended
            WHEN total_report >= 3  THEN 2  -- Warning
            ELSE 1                          -- Active
        END
    FROM Shops s
    INNER JOIN inserted i ON s.id = i.shop_id;
END
GO

-- =============================================
-- TRIGGER: Cập nhật average_rating khi có Feedback mới hoặc được duyệt
-- =============================================
CREATE TRIGGER trg_UpdateAverageRating
ON Feedbacks
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE Products
    SET average_rating = (
        SELECT AVG(CAST(f.rated_star AS DECIMAL(3,2)))
        FROM Feedbacks f
        WHERE f.product_id = p.id
          AND f.status = 1        -- Chỉ tính feedback đã Approved
          AND f.isDelete = 0
    )
    FROM Products p
    WHERE p.id IN (SELECT DISTINCT product_id FROM inserted);
END
GO

-- =============================================
-- TRIGGER: Tăng used_count Voucher khi đơn hàng dùng voucher
-- =============================================
CREATE TRIGGER trg_IncrementVoucherUsage
ON Orders
AFTER INSERT
AS
BEGIN
    UPDATE Vouchers
    SET used_count = used_count + 1
    FROM Vouchers v
    INNER JOIN inserted i ON v.id = i.voucher_id
    WHERE i.voucher_id IS NOT NULL;
END
GO

-- =============================================
-- DỮ LIỆU MẪU
-- =============================================

-- Sample: DeliveryAddresses
INSERT INTO DeliveryAddresses(customer_id, recipient_name, recipient_phone, address, note, isDefault)
VALUES
INSERT INTO Roles(name)
VALUES
('Admin'),
('Seller'),
('Manager'),
('Shipper');

INSERT INTO Customers(fullname, username, password_hash, email, phone, address, gender, avatar, status, isDelete)
VALUES
(N'Nguyễn Văn Khách',  'customer1',  '1', 'customer1@gmail.com',  '0912345678', N'123 Đường Láng, Đống Đa, Hà Nội', 1, 'avatar1.png', 1, 0),
(N'Trần Thị Khách',    'customer2', '1', 'customer2@gmail.com', '0987654321', N'456 Nguyễn Trãi, Thanh Xuân, Hà Nội', 0, 'avatar2.png', 1, 0);

INSERT INTO Staffs(email, fullname, username, password_hash, gender, phone, address, role_id, seller_status, status, isDelete)
VALUES
('admin@example.com',  N'Nguyễn Văn Admin', 'admin',  '1', 1, '0900000001', N'Head Office', 1, 0, 1, 0),
('seller@example.com', N'Phạm Văn Bán',    'seller', '1', 1, '0900000002', N'Cửa hàng 1', 2, 2, 1, 0);

-- Customer creates a seller request (simulated by linking to staff who will become seller)
INSERT INTO SellerRequests(staff_id, shop_name, shop_phone, shop_address, business_description, status, reviewed_at)
VALUES
(2, N'Cửa hàng Trái cây Sạch Hà Nội', '02433334444', N'789 Cầu Giấy, Hà Nội', N'Chuyên trái cây nhập khẩu và hữu cơ', 2, GETDATE());

-- After admin approval, the staff becomes owner of a shop
INSERT INTO Shops(shop_code, shop_name, owner_staff_id, approved_by, seller_request_id, phone, address, logo, banner, description, total_report, status, isDelete)
VALUES
('SHOP001', N'Cửa hàng Trái cây Sạch Hà Nội', 2, 1, 1, '02433334444', N'789 Cầu Giấy, Hà Nội', 'logo.png', 'banner.png', N'Chuyên cung cấp hoa quả sạch hữu cơ và nhập khẩu', 0, 1, 0);

INSERT INTO DeliveryAddresses(customer_id, recipient_name, recipient_phone, address, note, isDefault)
VALUES
(1, N'Nguyễn Văn Khách',         '0912345678', N'123 Đường Láng, Đống Đa, Hà Nội',              N'Giao giờ hành chính',  1),
(1, N'Nguyễn Văn Khách (Cơ quan)','0912345679', N'Tòa nhà Keangnam, Mễ Trì, Nam Từ Liêm, Hà Nội', N'Giao ở quầy lễ tân', 0);
GO
GO