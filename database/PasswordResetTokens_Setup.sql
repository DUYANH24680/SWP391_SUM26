-- SQL Script: Create PasswordResetTokens Table
-- Run this script in SQL Server Management Studio

-- Check if table exists
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='PasswordResetTokens' and xtype='U')
BEGIN
    CREATE TABLE PasswordResetTokens (
        id INT IDENTITY(1,1) PRIMARY KEY,
        email VARCHAR(255) NOT NULL,
        token VARCHAR(500) NOT NULL UNIQUE,
        expiry_time DATETIME NOT NULL,
        is_used BIT DEFAULT 0,
        created_at DATETIME DEFAULT GETDATE()
    );
    
    -- Create indexes for better query performance
    CREATE INDEX idx_email_token ON PasswordResetTokens(email, token);
    CREATE INDEX idx_expiry_time ON PasswordResetTokens(expiry_time);
    CREATE INDEX idx_is_used ON PasswordResetTokens(is_used);
    
    PRINT 'Table PasswordResetTokens created successfully!';
END
ELSE
BEGIN
    PRINT 'Table PasswordResetTokens already exists!';
END
GO

-- Verify the table
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='PasswordResetTokens';

-- View the table structure
EXEC sp_help 'PasswordResetTokens';

-- Optional: Clean up expired tokens (run periodically)
-- DELETE FROM PasswordResetTokens 
-- WHERE expiry_time < GETDATE() AND is_used = 0;
