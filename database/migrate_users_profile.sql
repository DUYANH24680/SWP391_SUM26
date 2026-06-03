-- Chạy script này trên DB MarketplaceSystem ĐÃ TẠO TRƯỚC ĐÓ (không cần chạy nếu tạo DB mới từ database.sql đã cập nhật)
USE MarketplaceSystem;
GO

-- Thêm cột profile nếu bảng Users chưa có
IF COL_LENGTH('Users', 'address') IS NULL
    ALTER TABLE Users ADD address NVARCHAR(255) NULL;
GO
IF COL_LENGTH('Users', 'gender') IS NULL
    ALTER TABLE Users ADD gender BIT NULL;
GO

-- Seed Roles (bắt buộc cho Register)
IF NOT EXISTS (SELECT 1 FROM Roles WHERE name = 'admin')
    INSERT INTO Roles (name) VALUES ('admin');
IF NOT EXISTS (SELECT 1 FROM Roles WHERE name = 'user')
    INSERT INTO Roles (name) VALUES ('user');
IF NOT EXISTS (SELECT 1 FROM Roles WHERE name = 'shipper')
    INSERT INTO Roles (name) VALUES ('shipper');
GO
