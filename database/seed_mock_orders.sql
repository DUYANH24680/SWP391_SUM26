-- ====================================================================
-- SENAFRUIT - SCRIPT MOCK DATA TRẠNG THÁI ĐƠN HÀNG
-- Dùng để kiểm thử (test) và demo các tab trạng thái đơn hàng.
-- ====================================================================

USE SENAFRUIT;
GO

-- 1. Xóa các đơn hàng mock cũ trước đó (để có thể chạy lại script nhiều lần)
PRINT 'Đang dọn dẹp các đơn hàng mock cũ...';

DELETE FROM OrderDetails 
WHERE order_id IN (SELECT id FROM Orders WHERE note LIKE 'MOCK_DATA%');

DELETE FROM Orders 
WHERE note LIKE 'MOCK_DATA%';

PRINT 'Dọn dẹp hoàn tất.';

-- 2. Xác định ID của khách hàng để tạo đơn hàng.
-- Theo cơ sở dữ liệu mẫu: 'customer1' có id = 3.
DECLARE @CustomerId INT = 3;
DECLARE @OrderId INT;

-- Đảm bảo khách hàng tồn tại
IF NOT EXISTS (SELECT 1 FROM Accounts WHERE id = @CustomerId)
BEGIN
    PRINT 'ERROR: Không tìm thấy tài khoản khách hàng với ID = ' + CAST(@CustomerId AS VARCHAR) + '. Vui lòng kiểm tra lại bảng Accounts.';
    RETURN;
END

PRINT 'Bắt đầu tạo đơn hàng mock mới cho Customer ID = ' + CAST(@CustomerId AS VARCHAR) + '...';

-- ====================================================================
-- ĐƠN HÀNG 1: CHỜ XÁC NHẬN (status = 1)
-- ====================================================================
INSERT INTO Orders (
    customer_id, voucher_id, recipient_name, recipient_phone, address, 
    payment_method, status, payment_status, total_cost, discount_amount, 
    shipping_fee, final_cost, note, order_date
) VALUES (
    @CustomerId, NULL, N'Nguyễn Văn Khách', '0987654321', N'123 Đường Láng, Đống Đa, Hà Nội',
    'COD', 1, 0, 144000.00, 0.00, 20000.00, 164000.00, N'MOCK_DATA: Chờ xác nhận', DATEADD(minute, -30, GETDATE())
);
SET @OrderId = SCOPE_IDENTITY();

-- Chi tiết đơn: 1 x Táo Mỹ Fuji (99k), 1 x Cam hữu cơ Đà Lạt (45k)
INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price, total_price)
VALUES (@OrderId, 1, 1, 99000.00, 99000.00);

INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price, total_price)
VALUES (@OrderId, 4, 1, 45000.00, 45000.00);

PRINT '  -> Đã tạo đơn CHỜ XÁC NHẬN (ID: ' + CAST(@OrderId AS VARCHAR) + ')';


-- ====================================================================
-- ĐƠN HÀNG 2: ĐÃ XÁC NHẬN (status = 2)
-- ====================================================================
INSERT INTO Orders (
    customer_id, voucher_id, recipient_name, recipient_phone, address, 
    payment_method, status, payment_status, total_cost, discount_amount, 
    shipping_fee, final_cost, note, order_date
) VALUES (
    @CustomerId, NULL, N'Nguyễn Văn Khách', '0987654321', N'123 Đường Láng, Đống Đa, Hà Nội',
    'VNPay', 2, 1, 150000.00, 0.00, 20000.00, 170000.00, N'MOCK_DATA: Đã xác nhận', DATEADD(hour, -2, GETDATE())
);
SET @OrderId = SCOPE_IDENTITY();

-- Chi tiết đơn: 1 x Nho Úc không hạt (150k)
INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price, total_price)
VALUES (@OrderId, 2, 1, 150000.00, 150000.00);

PRINT '  -> Đã tạo đơn ĐÃ XÁC NHẬN (ID: ' + CAST(@OrderId AS VARCHAR) + ')';


-- ====================================================================
-- ĐƠN HÀNG 3: ĐANG GIAO (status = 3)
-- ====================================================================
INSERT INTO Orders (
    customer_id, voucher_id, recipient_name, recipient_phone, address, 
    payment_method, status, payment_status, total_cost, discount_amount, 
    shipping_fee, final_cost, note, order_date
) VALUES (
    @CustomerId, NULL, N'Nguyễn Văn Khách', '0987654321', N'123 Đường Láng, Đống Đa, Hà Nội',
    'COD', 3, 0, 297000.00, 0.00, 20000.00, 317000.00, N'MOCK_DATA: Đang giao', DATEADD(hour, -5, GETDATE())
);
SET @OrderId = SCOPE_IDENTITY();

-- Chi tiết đơn: 3 x Táo Mỹ Fuji (99k)
INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price, total_price)
VALUES (@OrderId, 1, 3, 99000.00, 297000.00);

PRINT '  -> Đã tạo đơn ĐANG GIAO (ID: ' + CAST(@OrderId AS VARCHAR) + ')';


-- ====================================================================
-- ĐƠN HÀNG 4: ĐÃ GIAO (status = 4)
-- ====================================================================
INSERT INTO Orders (
    customer_id, voucher_id, recipient_name, recipient_phone, address, 
    payment_method, status, payment_status, total_cost, discount_amount, 
    shipping_fee, final_cost, note, order_date
) VALUES (
    @CustomerId, NULL, N'Nguyễn Văn Khách', '0987654321', N'123 Đường Láng, Đống Đa, Hà Nội',
    'MoMo', 4, 1, 320000.00, 0.00, 20000.00, 340000.00, N'MOCK_DATA: Đã giao', DATEADD(day, -1, GETDATE())
);
SET @OrderId = SCOPE_IDENTITY();

-- Chi tiết đơn: 1 x Sầu riêng Musang King (320k)
INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price, total_price)
VALUES (@OrderId, 5, 1, 320000.00, 320000.00);

PRINT '  -> Đã tạo đơn ĐÃ GIAO (ID: ' + CAST(@OrderId AS VARCHAR) + ')';


-- ====================================================================
-- ĐƠN HÀNG 5: ĐÃ HỦY (status = 5)
-- ====================================================================
INSERT INTO Orders (
    customer_id, voucher_id, recipient_name, recipient_phone, address, 
    payment_method, status, payment_status, total_cost, discount_amount, 
    shipping_fee, final_cost, note, order_date, cancelled_at
) VALUES (
    @CustomerId, NULL, N'Nguyễn Văn Khách', '0987654321', N'123 Đường Láng, Đống Đa, Hà Nội',
    'COD', 5, 0, 99000.00, 0.00, 20000.00, 119000.00, N'MOCK_DATA: Đã hủy', DATEADD(day, -2, GETDATE()), DATEADD(day, -2, GETDATE())
);
SET @OrderId = SCOPE_IDENTITY();

-- Chi tiết đơn: 1 x Táo Mỹ Fuji (99k)
INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price, total_price)
VALUES (@OrderId, 1, 1, 99000.00, 99000.00);

PRINT '  -> Đã tạo đơn ĐÃ HỦY (ID: ' + CAST(@OrderId AS VARCHAR) + ')';

PRINT 'Hoàn thành tạo mock data cho các trạng thái đơn hàng!';
GO
