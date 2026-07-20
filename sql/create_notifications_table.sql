-- =====================================================
-- Create Notifications table for Sena Shop
-- =====================================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'Notifications' AND xtype = 'U')
BEGIN
    CREATE TABLE Notifications (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        title NVARCHAR(255) NOT NULL,
        content NVARCHAR(MAX) NOT NULL,
        type NVARCHAR(50) NOT NULL,
        related_id INT NULL,
        is_read BIT DEFAULT 0,
        created_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (user_id) REFERENCES Accounts(id)
    );
    
    -- Index for fast lookup by user
    CREATE NONCLUSTERED INDEX IX_Notifications_UserId ON Notifications(user_id);
    
    -- Index for unread count
    CREATE NONCLUSTERED INDEX IX_Notifications_Unread ON Notifications(user_id, is_read) WHERE is_read = 0;
    
    PRINT 'Table Notifications created successfully.';
END
ELSE
BEGIN
    PRINT 'Table Notifications already exists.';
END
GO
