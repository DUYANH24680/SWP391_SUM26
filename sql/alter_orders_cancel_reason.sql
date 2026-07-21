-- ============================================================
-- SQL Migration: Add cancel_reason column to Orders table
-- Run this script on your local SQL Server instance
-- Database Name: SENAFRUIT (or your local database name)
-- ============================================================

-- 1. Check and add column safely
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('Orders') AND name = 'cancel_reason'
)
BEGIN
    EXEC('ALTER TABLE Orders ADD cancel_reason NVARCHAR(500) NULL');
    PRINT 'SUCCESS: Column cancel_reason added to Orders table.';
END
ELSE
BEGIN
    PRINT 'INFO: Column cancel_reason already exists in Orders table.';
END
GO

-- 2. Clean up any existing corrupted auto-cancel records (encoding issue fix)
IF EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('Orders') AND name = 'cancel_reason'
)
BEGIN
    EXEC('UPDATE Orders SET cancel_reason = N''Hủy tự động: Cửa hàng không xác nhận đơn hàng sau 24 giờ.'' WHERE cancel_reason LIKE N''%sau 24 gi%''');
    PRINT 'SUCCESS: Cleaned up any corrupted cancel reasons.';
END
GO
