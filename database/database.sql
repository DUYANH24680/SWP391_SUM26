CREATE DATABASE MarketplaceSystem;
GO
USE MarketplaceSystem;
GO

-- ============================================================
-- 1. HỆ THỐNG TÀI KHOẢN & PHÂN QUYỀN
-- ============================================================
CREATE TABLE Roles (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(20) NOT NULL UNIQUE, -- 'admin', 'user', 'shipper'
    created_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE Users (
    id INT PRIMARY KEY IDENTITY(1,1),
    role_id INT NOT NULL,
    fullname NVARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(15),
    address NVARCHAR(255) NULL,
    gender BIT NULL,
    avatar NVARCHAR(255),
    status TINYINT DEFAULT 1, -- 0=Blocked, 1=Active
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (role_id) REFERENCES Roles(id)
);

-- Địa chỉ nhận hàng (Một user có thể có nhiều địa chỉ, 1 địa chỉ mặc định)
CREATE TABLE UserAddresses (
    id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL,
    recipient_name NVARCHAR(100) NOT NULL,
    recipient_phone VARCHAR(15) NOT NULL,
    province NVARCHAR(100) NOT NULL,
    district NVARCHAR(100) NOT NULL,
    ward NVARCHAR(100) NOT NULL,
    detail_address NVARCHAR(255) NOT NULL,
    is_default BIT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);

-- ============================================================
-- 2. QUẢN LÝ GIAN HÀNG (STORES / SHOPS)
-- Thay vì Seller là một Account, giờ đây Seller sở hữu một Store độc lập
-- ============================================================
CREATE TABLE Stores (
    id INT PRIMARY KEY IDENTITY(1,1),
    owner_id INT NOT NULL, -- Chủ cửa hàng (Liên kết sang Users)
    name NVARCHAR(100) NOT NULL UNIQUE,
    logo NVARCHAR(255),
    banner NVARCHAR(255),
    description NVARCHAR(MAX),
    phone VARCHAR(15),
    address NVARCHAR(255),
    status TINYINT DEFAULT 0, -- 0=Pending, 1=Active, 2=Suspended
    rating_average DECIMAL(3,2) DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (owner_id) REFERENCES Users(id)
);

-- ============================================================
-- 3. DANH MỤC & SẢN PHẨM (PRODUCTS)
-- ============================================================
CREATE TABLE Categories (
    id INT PRIMARY KEY IDENTITY(1,1),
    parent_id INT NULL, -- Danh mục cha (Hỗ trợ danh mục đa cấp: Trái cây -> Trái cây nhập khẩu -> Táo)
    name NVARCHAR(100) NOT NULL,
    image NVARCHAR(255),
    is_deleted BIT DEFAULT 0,
    FOREIGN KEY (parent_id) REFERENCES Categories(id)
);

CREATE TABLE Products (
    id INT PRIMARY KEY IDENTITY(1,1),
    store_id INT NOT NULL, -- Thuộc về gian hàng nào
    category_id INT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    brand NVARCHAR(100),
    sku VARCHAR(50), -- Mã quản lý kho hàng
    origin NVARCHAR(100), -- Xuất xứ (Rất quan trọng với TMĐT)
    rating_average DECIMAL(3,2) DEFAULT 0,
    sold_quantity INT DEFAULT 0,
    status TINYINT DEFAULT 0, -- 0=Pending (Chờ sàn duyệt), 1=Active, 2=Hidden
    is_deleted BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (store_id) REFERENCES Stores(id),
    FOREIGN KEY (category_id) REFERENCES Categories(id)
);

-- Phân loại sản phẩm (Product Variants): Ví dụ: Hộp 1kg, Thùng 5kg, Size S, Size M...
CREATE TABLE ProductVariants (
    id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    variant_name NVARCHAR(100) NOT NULL, -- Ví dụ: "Hộp 1Kg", "Combo 3 can"
    original_price DECIMAL(18,2) NOT NULL,
    sale_price DECIMAL(18,2) NULL,
    stock_quantity INT DEFAULT 0,
    image_url NVARCHAR(255) NULL,
    FOREIGN KEY (product_id) REFERENCES Products(id)
);

-- ============================================================
-- 4. GIỎ HÀNG (CARTS)
-- Khách hàng lưu sản phẩm vào giỏ, có thể chứa sản phẩm của nhiều Shop
-- ============================================================
CREATE TABLE Carts (
    id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL UNIQUE,
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Users(id)
);

CREATE TABLE CartItems (
    id INT PRIMARY KEY IDENTITY(1,1),
    cart_id INT NOT NULL,
    variant_id INT NOT NULL, -- Lưu biến thể sản phẩm cụ thể
    quantity INT NOT NULL CHECK (quantity > 0),
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (cart_id) REFERENCES Carts(id),
    FOREIGN KEY (variant_id) REFERENCES ProductVariants(id)
);

-- ============================================================
-- 5. VOUCHERS (MÃ GIẢM GIÁ ĐA CẤP)
-- Phân loại: Voucher toàn sàn (do Admin tạo) và Voucher của từng Shop
-- ============================================================
CREATE TABLE Vouchers (
    id INT PRIMARY KEY IDENTITY(1,1),
    store_id INT NULL, -- NULL nếu là Voucher toàn sàn (Admin), có ID nếu là voucher riêng của Shop
    code VARCHAR(50) NOT NULL UNIQUE,
    discount_type VARCHAR(10) NOT NULL, -- 'PERCENT' hoặc 'FIXED_AMOUNT'
    discount_value DECIMAL(18,2) NOT NULL,
    max_discount DECIMAL(18,2) NULL, -- Giới hạn số tiền giảm tối đa nếu dùng %
    minimum_order DECIMAL(18,2) DEFAULT 0,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    quantity INT NOT NULL,
    used_count INT DEFAULT 0,
    status BIT DEFAULT 1,
    FOREIGN KEY (store_id) REFERENCES Stores(id)
);

-- ============================================================
-- 6. HỆ THỐNG ĐƠN HÀNG ĐA CẤP (ORDER SPLITTING)
-- Quy trình: Khách nhấn mua hàng -> Tạo 1 OrderMaster -> Tự động tách thành nhiều Orders theo từng Store
-- ============================================================

-- Đơn hàng tổng (Bao gồm toàn bộ giao dịch thanh toán một lần của khách)
CREATE TABLE OrderMaster (
    id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL,
    total_items_price DECIMAL(18,2) NOT NULL, -- Tổng tiền hàng trước ship, trước giảm giá
    platform_coupon_id INT NULL, -- Mã giảm giá áp dụng toàn sàn
    platform_discount DECIMAL(18,2) DEFAULT 0,
    total_shipping_fee DECIMAL(18,2) DEFAULT 0,
    final_amount DECIMAL(18,2) NOT NULL, -- Số tiền cuối cùng khách phải trả
    payment_method VARCHAR(20) DEFAULT 'COD', -- 'COD', 'VNPAY', 'MOMO', 'WALLET'
    payment_status TINYINT DEFAULT 0, -- 0=Chưa thanh toán, 1=Đã thanh toán, 2=Đã hoàn tiền
    recipient_name NVARCHAR(100) NOT NULL,
    recipient_phone VARCHAR(15) NOT NULL,
    shipping_address NVARCHAR(500) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (platform_coupon_id) REFERENCES Vouchers(id)
);

-- Đơn hàng con (Mỗi shop xử lý một đơn hàng riêng biệt)
CREATE TABLE Orders (
    id INT PRIMARY KEY IDENTITY(1,1),
    order_master_id INT NOT NULL,
    store_id INT NOT NULL, -- Thuộc về shop này
    store_coupon_id INT NULL, -- Mã giảm giá riêng của shop này
    store_discount DECIMAL(18,2) DEFAULT 0,
    shipping_fee DECIMAL(18,2) DEFAULT 0,
    subtotal DECIMAL(18,2) NOT NULL, -- Số tiền thực tế của đơn hàng con này (sau giảm giá + ship)
    status TINYINT DEFAULT 1, -- 1=Chờ xác nhận, 2=Đã xác nhận, 3=Đang giao, 4=Thành công, 5=Đã hủy
    note NVARCHAR(500),
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (order_master_id) REFERENCES OrderMaster(id),
    FOREIGN KEY (store_id) REFERENCES Stores(id),
    FOREIGN KEY (store_coupon_id) REFERENCES Vouchers(id)
);

-- Chi tiết đơn hàng con
CREATE TABLE OrderDetails (
    id INT PRIMARY KEY IDENTITY(1,1),
    order_id INT NOT NULL,
    variant_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(18,2) NOT NULL, -- Giá tại thời điểm mua
    total_price DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(id),
    FOREIGN KEY (variant_id) REFERENCES ProductVariants(id)
);

-- ============================================================
-- 7. VẬN CHUYỂN (LOGISTICS)
-- ============================================================
CREATE TABLE DeliveryOrders (
    id INT PRIMARY KEY IDENTITY(1,1),
    order_id INT NOT NULL UNIQUE, -- Liên kết 1-1 với Đơn hàng con (Orders)
    shipper_id INT NULL, -- Có thể bàn giao cho bên thứ 3 hoặc shipper của sàn
    shipping_provider NVARCHAR(100) DEFAULT N'Sàn Tự Vận Chuyển', -- GHTK, GHN, ViettelPost...
    tracking_number VARCHAR(50) NULL, -- Mã vận đơn của đơn vị vận chuyển
    status TINYINT DEFAULT 1, -- 1=Chờ lấy hàng, 2=Đã lấy hàng, 3=Đang giao, 4=Giao thành công, 5=Thất bại
    picked_at DATETIME,
    delivered_at DATETIME,
    fail_reason NVARCHAR(500),
    FOREIGN KEY (order_id) REFERENCES Orders(id),
    FOREIGN KEY (shipper_id) REFERENCES Users(id)
);

-- ============================================================
-- 8. ĐÁNH GIÁ (FEEDBACKS & REVIEWS)
-- Khách hàng đánh giá sản phẩm của từng Shop
-- ============================================================
CREATE TABLE Feedbacks (
    id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    order_id INT NOT NULL, -- Đảm bảo đã mua hàng mới được đánh giá
    rating_star INT NOT NULL CHECK (rating_star BETWEEN 1 AND 5),
    comment NVARCHAR(1000),
    reply_from_store NVARCHAR(1000) NULL, -- Shop phản hồi đánh giá của khách
    status BIT DEFAULT 1, -- 1=Hiển thị, 0=Ẩn (do vi phạm từ ngữ)
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (product_id) REFERENCES Products(id),
    FOREIGN KEY (order_id) REFERENCES Orders(id)
);

-- ============================================================
-- 9. HỆ THỐNG VÍ TIỀN & DÒNG TIỀN (WALLETS & TRANSACTIONS)
-- Rất quan trọng với Sàn TMĐT: Lưu giữ tiền của khách, thanh toán cho các Shop (sau khi trừ chiết khấu sàn)
-- ============================================================
CREATE TABLE Wallets (
    id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NULL,   -- Nếu thuộc về Người dùng / Chủ Shop
    store_id INT NULL,  -- Nếu thuộc về Ví dòng tiền riêng của Cửa hàng
    balance DECIMAL(18,2) DEFAULT 0, -- Số dư khả dụng
    payment_password VARCHAR(255) NOT NULL, -- Mật khẩu thanh toán/rút tiền
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (store_id) REFERENCES Stores(id)
);

CREATE TABLE WalletTransactions (
    id INT PRIMARY KEY IDENTITY(1,1),
    wallet_id INT NOT NULL,
    amount DECIMAL(18,2) NOT NULL, -- Số tiền giao dịch (Dương là cộng, Âm là trừ)
    transaction_type VARCHAR(20) NOT NULL, -- 'DEPOSIT'(Nạp), 'WITHDRAW'(Rút), 'PAYMENT'(Thanh toán), 'REVENUE'(Doanh thu shop), 'REFUND'(Hoàn tiền)
    status TINYINT DEFAULT 0, -- 0=Pending, 1=Success, 2=Failed
    description NVARCHAR(255),
    reference_id INT NULL, -- ID của Đơn hàng (Orders) hoặc Đơn Master liên quan nếu có
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (wallet_id) REFERENCES Wallets(id)
);
GO

-- ============================================================
-- DỮ LIỆU KHỞI TẠO (Roles - bắt buộc cho đăng ký / đăng nhập)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM Roles WHERE name = 'admin')
    INSERT INTO Roles (name) VALUES ('admin');
IF NOT EXISTS (SELECT 1 FROM Roles WHERE name = 'user')
    INSERT INTO Roles (name) VALUES ('user');
IF NOT EXISTS (SELECT 1 FROM Roles WHERE name = 'shipper')
    INSERT INTO Roles (name) VALUES ('shipper');
GO