CREATE TABLE [Notifications] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [account_id] INT NOT NULL,
    [title] NVARCHAR(255) NOT NULL,
    [message] NVARCHAR(MAX) NOT NULL,
    [type] VARCHAR(15) NULL,
    [link] NVARCHAR(255) NULL,
    [is_read] BIT NULL,
    [created_at] DATETIME NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([account_id]) REFERENCES [Accounts] ([id])
);
GO
 
CREATE TABLE [DeliveryAddresses] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [customer_id] INT NOT NULL,
    [recipient_name] NVARCHAR(255) NOT NULL,
    [recipient_phone] NVARCHAR(50) NOT NULL,
    [address] NVARCHAR(500) NOT NULL,
    [note] NVARCHAR(500) NULL,
    [isDefault] BIT NOT NULL,
    [created_at] DATETIME NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([customer_id]) REFERENCES [Accounts] ([id])
);
GO
 
CREATE TABLE [UserVouchers] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [user_id] INT NOT NULL,
    [voucher_id] INT NOT NULL,
    [usage_count] INT NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([user_id]) REFERENCES [Accounts] ([id]),
    FOREIGN KEY ([voucher_id]) REFERENCES [Vouchers] ([id])
);
GO
 
CREATE TABLE [PasswordResetTokens] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [email] NVARCHAR(255) NOT NULL,
    [token] NVARCHAR(255) NOT NULL,
    [expiry_time] DATETIME NOT NULL,
    [is_used] BIT NOT NULL,
    [created_at] DATETIME NULL,
    PRIMARY KEY ([id])
);
GO
 
CREATE TABLE [ProductVariants] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [product_id] INT NOT NULL,
    [weight_value] DECIMAL(10, 2) NOT NULL,
    [weight_unit] NVARCHAR(10) NULL,
    [sale_price] DECIMAL(18, 2) NOT NULL,
    [stock_quantity] INT NOT NULL,
    [sku] NVARCHAR(100) NULL,
    [is_active] BIT NULL,
    [created_at] DATETIME NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([product_id]) REFERENCES [Products] ([id])
);
GO
 
CREATE TABLE [Wishlists] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [customer_id] INT NOT NULL,
    [created_at] DATETIME NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([customer_id]) REFERENCES [Accounts] ([id])
);
GO
 
CREATE TABLE [WishlistItems] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [wishlist_id] INT NOT NULL,
    [product_id] INT NOT NULL,
    [created_at] DATETIME NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([product_id]) REFERENCES [Products] ([id]),
    FOREIGN KEY ([wishlist_id]) REFERENCES [Wishlists] ([id])
);
GO
 
CREATE TABLE [Carts] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [customer_id] INT NOT NULL,
    [created_at] DATETIME NULL,
    [total_items] INT NULL,
    [total_amount] DECIMAL(18, 2) NULL,
    [updated_at] DATETIME NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([customer_id]) REFERENCES [Accounts] ([id])
);
GO
 
CREATE TABLE [CartItems] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [cart_id] INT NOT NULL,
    [product_id] INT NOT NULL,
    [quantity] INT NOT NULL,
    [created_at] DATETIME NULL,
    [unit_price] DECIMAL(18, 2) NULL,
    [discount_amount] DECIMAL(18, 2) NULL,
    [total_price] DECIMAL(18, 2) NULL,
    [voucher_id] INT NULL,
    [note] NVARCHAR(MAX) NULL,
    [is_selected] BIT NULL,
    [updated_at] DATETIME NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([cart_id]) REFERENCES [Carts] ([id]),
    FOREIGN KEY ([product_id]) REFERENCES [Products] ([id])
);
GO
 
CREATE TABLE [Roles] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [name] VARCHAR(20) NOT NULL,
    [created_at] DATETIME NULL,
    PRIMARY KEY ([id])
);
GO
 
CREATE TABLE [Accounts] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [role_id] INT NOT NULL,
    [fullname] NVARCHAR(100) NOT NULL,
    [username] VARCHAR(50) NOT NULL,
    [password_hash] VARCHAR(255) NOT NULL,
    [email] VARCHAR(255) NOT NULL,
    [phone] VARCHAR(15) NULL,
    [address] NVARCHAR(255) NULL,
    [avatar] NVARCHAR(255) NULL,
    [gender] BIT NULL,
    [status] TINYINT NULL,
    [created_at] DATETIME NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([role_id]) REFERENCES [Roles] ([id])
);
GO
 
CREATE TABLE [Shops] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [owner_id] INT NOT NULL,
    [shop_name] NVARCHAR(255) NOT NULL,
    [logo] NVARCHAR(255) NULL,
    [description] NVARCHAR(MAX) NULL,
    [address] NVARCHAR(255) NULL,
    [status] TINYINT NULL,
    [created_at] DATETIME NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([owner_id]) REFERENCES [Accounts] ([id])
);
GO
 
CREATE TABLE [ShipperDetails] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [account_id] INT NOT NULL,
    [shipper_code] NVARCHAR(20) NOT NULL,
    [birthdate] DATE NOT NULL,
    [cccd] VARCHAR(15) NOT NULL,
    [vehicle_type] NVARCHAR(50) NOT NULL,
    [delivery_area] NVARCHAR(255) NOT NULL,
    [created_at] DATETIME NULL,
    [updated_at] DATETIME NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([account_id]) REFERENCES [Accounts] ([id])
);
GO
 
CREATE TABLE [ShopRequests] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [account_id] INT NOT NULL,
    [shop_name] NVARCHAR(255) NOT NULL,
    [description] NVARCHAR(MAX) NULL,
    [address] NVARCHAR(255) NULL,
    [status] TINYINT NULL,
    [created_at] DATETIME NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([account_id]) REFERENCES [Accounts] ([id])
);
GO
 
CREATE TABLE [StaffDetails] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [account_id] INT NOT NULL,
    [staff_code] NVARCHAR(20) NOT NULL,
    [cccd] VARCHAR(15) NOT NULL,
    [managed_area] NVARCHAR(255) NOT NULL,
    [created_at] DATETIME NULL,
    [updated_at] DATETIME NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([account_id]) REFERENCES [Accounts] ([id])
);
GO
 
CREATE TABLE [Categories] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [name] NVARCHAR(100) NOT NULL,
    [image] NVARCHAR(255) NULL,
    [isDelete] BIT NULL,
    PRIMARY KEY ([id])
);
GO
 
CREATE TABLE [ProductReviews] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [product_id] INT NOT NULL,
    [account_id] INT NOT NULL,
    [rating] TINYINT NOT NULL,
    [comment] NVARCHAR(2000) NULL,
    [created_at] DATETIME NULL,
    [reply] NVARCHAR(MAX) NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([account_id]) REFERENCES [Accounts] ([id]),
    FOREIGN KEY ([product_id]) REFERENCES [Products] ([id])
);
GO
 
CREATE TABLE [Products] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [category_id] INT NOT NULL,
    [seller_id] INT NOT NULL,
    [shop_id] INT NOT NULL,
    [title] NVARCHAR(255) NOT NULL,
    [image] NVARCHAR(255) NULL,
    [description] NVARCHAR(MAX) NULL,
    [unit] NVARCHAR(20) NULL,
    [stock_quantity] INT NULL,
    [sold_quantity] INT NULL,
    [original_price] DECIMAL(18, 2) NOT NULL,
    [sale_price] DECIMAL(18, 2) NULL,
    [expired_date] DATE NULL,
    [average_rating] DECIMAL(3, 2) NULL,
    [is_featured] BIT NULL,
    [status] TINYINT NULL,
    [isDelete] BIT NULL,
    [created_at] DATETIME NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([category_id]) REFERENCES [Categories] ([id]),
    FOREIGN KEY ([seller_id]) REFERENCES [Accounts] ([id]),
    FOREIGN KEY ([shop_id]) REFERENCES [Shops] ([id])
);
GO
 
CREATE TABLE [ReviewReplies] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [review_id] INT NOT NULL,
    [account_id] INT NOT NULL,
    [reply_text] NVARCHAR(2000) NOT NULL,
    [created_at] DATETIME NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([account_id]) REFERENCES [Accounts] ([id]),
    FOREIGN KEY ([review_id]) REFERENCES [ProductReviews] ([id])
);
GO
 
CREATE TABLE [ProductImages] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [product_id] INT NOT NULL,
    [image_url] NVARCHAR(255) NOT NULL,
    [sort_order] INT NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([product_id]) REFERENCES [Products] ([id])
);
GO
 
CREATE TABLE [Vouchers] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [code] VARCHAR(50) NOT NULL,
    [discount_percent] FLOAT NULL,
    [max_discount] DECIMAL(18, 2) NULL,
    [minimum_order] DECIMAL(18, 2) NULL,
    [start_date] DATETIME NULL,
    [end_date] DATETIME NULL,
    [quantity] INT NULL,
    [used_count] INT NULL,
    [status] BIT NULL,
    [shop_id] INT NULL,
    [type] VARCHAR(20) NULL,
    [max_usages_per_user] INT NULL,
    PRIMARY KEY ([id])
);
GO
 
CREATE TABLE [Reports] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [customer_id] INT NOT NULL,
    [product_id] INT NOT NULL,
    [reason] NVARCHAR(MAX) NULL,
    [status] VARCHAR(20) NULL,
    [created_at] DATETIME NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([customer_id]) REFERENCES [Accounts] ([id]),
    FOREIGN KEY ([product_id]) REFERENCES [Products] ([id])
);
GO
 
CREATE TABLE [Orders] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [customer_id] INT NOT NULL,
    [voucher_id] INT NULL,
    [recipient_name] NVARCHAR(100) NULL,
    [recipient_phone] VARCHAR(15) NULL,
    [address] NVARCHAR(255) NULL,
    [payment_method] VARCHAR(10) NULL,
    [status] TINYINT NULL,
    [payment_status] TINYINT NULL,
    [total_cost] DECIMAL(18, 2) NOT NULL,
    [discount_amount] DECIMAL(18, 2) NULL,
    [shipping_fee] DECIMAL(18, 2) NULL,
    [final_cost] DECIMAL(18, 2) NULL,
    [note] NVARCHAR(500) NULL,
    [order_date] DATETIME NULL,
    [cancelled_at] DATETIME NULL,
    [platform_discount_amount] DECIMAL(18, 2) NOT NULL,
    [shop_actual_revenue] DECIMAL(18, 2) NOT NULL,
    [cancel_reason] NVARCHAR(MAX) NULL,
    [platform_discount] DECIMAL(18, 2) NOT NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([customer_id]) REFERENCES [Accounts] ([id]),
    FOREIGN KEY ([voucher_id]) REFERENCES [Vouchers] ([id])
);
GO
 
CREATE TABLE [ChatSessions] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [report_id] INT NOT NULL,
    [customer_id] INT NOT NULL,
    [seller_id] INT NOT NULL,
    [admin_id] INT NULL,
    [status] VARCHAR(20) NULL,
    [created_at] DATETIME NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([customer_id]) REFERENCES [Accounts] ([id]),
    FOREIGN KEY ([report_id]) REFERENCES [Reports] ([id]),
    FOREIGN KEY ([seller_id]) REFERENCES [Accounts] ([id])
);
GO
 
CREATE TABLE [OrderDetails] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [order_id] INT NOT NULL,
    [product_id] INT NOT NULL,
    [quantity] INT NOT NULL,
    [unit_price] DECIMAL(18, 2) NOT NULL,
    [total_price] DECIMAL(18, 2) NOT NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([order_id]) REFERENCES [Orders] ([id]),
    FOREIGN KEY ([product_id]) REFERENCES [Products] ([id])
);
GO
 
CREATE TABLE [ChatMessages] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [session_id] INT NOT NULL,
    [sender_id] INT NOT NULL,
    [message] NVARCHAR(MAX) NULL,
    [created_at] DATETIME NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([sender_id]) REFERENCES [Accounts] ([id]),
    FOREIGN KEY ([session_id]) REFERENCES [ChatSessions] ([id])
);
GO
 
CREATE TABLE [DeliveryOrders] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [order_id] INT NOT NULL,
    [shipper_id] INT NOT NULL,
    [assigned_at] DATETIME NULL,
    [picked_up_at] DATETIME NULL,
    [delivered_at] DATETIME NULL,
    [failed_at] DATETIME NULL,
    [fail_reason] NVARCHAR(500) NULL,
    [status] TINYINT NULL,
    [note] NVARCHAR(500) NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([order_id]) REFERENCES [Orders] ([id]),
    FOREIGN KEY ([shipper_id]) REFERENCES [Accounts] ([id])
);
GO
 
CREATE TABLE [Feedbacks] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [customer_id] INT NOT NULL,
    [product_id] INT NOT NULL,
    [order_id] INT NOT NULL,
    [rated_star] INT NOT NULL,
    [comment] NVARCHAR(1000) NULL,
    [image_url] NVARCHAR(255) NULL,
    [status] TINYINT NULL,
    [created_at] DATETIME NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([customer_id]) REFERENCES [Accounts] ([id]),
    FOREIGN KEY ([order_id]) REFERENCES [Orders] ([id]),
    FOREIGN KEY ([product_id]) REFERENCES [Products] ([id])
);
GO
 
CREATE TABLE [Blogs] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [author_id] INT NOT NULL,
    [title] NVARCHAR(255) NULL,
    [image] NVARCHAR(255) NULL,
    [description] NVARCHAR(MAX) NULL,
    [content] NVARCHAR(MAX) NULL,
    [is_featured] BIT NULL,
    [status] BIT NULL,
    [created_at] DATETIME NULL,
    PRIMARY KEY ([id]),
    FOREIGN KEY ([author_id]) REFERENCES [Accounts] ([id])
);
GO
 
