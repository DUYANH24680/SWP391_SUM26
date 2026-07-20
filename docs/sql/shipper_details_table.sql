-- =====================================================
-- Script tạo bảng ShipperDetails cho SWP391 Project
-- Chạy script này trong SQL Server Management Studio
-- =====================================================

-- Tạo bảng ShipperDetails để lưu thông tin đặc thù của shipper
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ShipperDetails')
BEGIN
    CREATE TABLE ShipperDetails (
        id INT IDENTITY(1,1) PRIMARY KEY,
        account_id INT NOT NULL UNIQUE,  -- Foreign key đến bảng Accounts
        shipper_code NVARCHAR(20) NOT NULL UNIQUE, -- Mã shipper (duy nhất, dễ quản lý)
        birthdate DATE NOT NULL,          -- Ngày tháng năm sinh
        cccd VARCHAR(15) NOT NULL UNIQUE, -- Căn cước công dân (12 số)
        vehicle_type NVARCHAR(50) NOT NULL, -- Loại phương tiện (Xe máy, Xe đạp, Ô tô, ...)
        delivery_area NVARCHAR(255) NOT NULL, -- Khu vực giao hàng
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT FK_ShipperDetails_Accounts FOREIGN KEY (account_id) REFERENCES Accounts(id)
    );
    
    PRINT 'Bảng ShipperDetails đã được tạo thành công!';
END
ELSE
BEGIN
    -- Thêm cột shipper_code nếu chưa có
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('ShipperDetails') AND name = 'shipper_code')
    BEGIN
        ALTER TABLE ShipperDetails ADD shipper_code NVARCHAR(20) NOT NULL UNIQUE;
        PRINT 'Đã thêm cột shipper_code vào bảng ShipperDetails';
    END
    PRINT 'Bảng ShipperDetails đã tồn tại.';
END

-- Tạo index để tăng tốc độ truy vấn
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ShipperDetails_account_id')
BEGIN
    CREATE INDEX IX_ShipperDetails_account_id ON ShipperDetails(account_id);
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ShipperDetails_shipper_code')
BEGIN
    CREATE INDEX IX_ShipperDetails_shipper_code ON ShipperDetails(shipper_code);
END

GO

-- =====================================================
-- Tạo bảng StaffDetails để lưu thông tin đặc thù của nhân viên
-- =====================================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'StaffDetails')
BEGIN
    CREATE TABLE StaffDetails (
        id INT IDENTITY(1,1) PRIMARY KEY,
        account_id INT NOT NULL UNIQUE,  -- Foreign key đến bảng Accounts
        staff_code NVARCHAR(20) NOT NULL UNIQUE, -- Mã nhân viên (duy nhất, dễ quản lý)
        cccd VARCHAR(15) NOT NULL UNIQUE, -- Căn cước công dân (12 số)
        managed_area NVARCHAR(255) NOT NULL, -- Khu vực quản lý shipper
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT FK_StaffDetails_Accounts FOREIGN KEY (account_id) REFERENCES Accounts(id)
    );
    
    PRINT 'Bảng StaffDetails đã được tạo thành công!';
END
ELSE
BEGIN
    PRINT 'Bảng StaffDetails đã tồn tại.';
END

-- Tạo index
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_StaffDetails_account_id')
BEGIN
    CREATE INDEX IX_StaffDetails_account_id ON StaffDetails(account_id);
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_StaffDetails_staff_code')
BEGIN
    CREATE INDEX IX_StaffDetails_staff_code ON StaffDetails(staff_code);
END

GO

-- Ví dụ thêm dữ liệu (chạy nếu cần test)
-- INSERT INTO ShipperDetails (account_id, shipper_code, birthdate, cccd, vehicle_type, delivery_area)
-- VALUES (1, 'SHP001', '1995-05-15', '079195012345', 'Xe máy', 'TP.HCM');

-- INSERT INTO StaffDetails (account_id, staff_code, cccd, managed_area)
-- VALUES (2, 'NV001', '079195999999', 'TP.HCM');
