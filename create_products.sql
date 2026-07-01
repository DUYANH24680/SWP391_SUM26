-- SQL Script to generate mock products for all shops in the SENAFRUIT database.
-- Target Database: SENAFRUIT

USE [SENAFRUIT];
GO

BEGIN TRANSACTION;

BEGIN TRY
    -- Insert mock products for each shop, alternating between two sets of products to create diversity.
    INSERT INTO [dbo].[Products] (
        [category_id],
        [seller_id],
        [shop_id],
        [title],
        [image],
        [description],
        [unit],
        [stock_quantity],
        [sold_quantity],
        [original_price],
        [sale_price],
        [expired_date],
        [average_rating],
        [is_featured],
        [status],
        [isDelete],
        [created_at]
    )
    SELECT 
        m.[category_id],
        sh.[owner_id] AS [seller_id],
        sh.[id] AS [shop_id],
        m.[title],
        m.[image],
        m.[description] + N' từ ' + sh.[shop_name] AS [description],
        m.[unit],
        m.[stock_quantity],
        m.[sold_quantity],
        m.[original_price],
        m.[sale_price],
        NULL AS [expired_date],
        0.0 AS [average_rating],
        m.[is_featured],
        1 AS [status],
        0 AS [isDelete],
        GETDATE() AS [created_at]
    FROM [dbo].[Shops] sh
    INNER JOIN (
        -- Set 0: Mock products for even shop IDs (sh.id % 2 = 0)
        SELECT 0 AS [set_id], 1 AS [category_id], N'Táo Mỹ Fuji' AS [title], 'apple.png' AS [image], N'Táo Mỹ Fuji tươi giòn ngọt, chứa nhiều vitamin.' AS [description], N'kg' AS [unit], 100 AS [stock_quantity], 0 AS [sold_quantity], 120000.00 AS [original_price], 99000.00 AS [sale_price], 1 AS [is_featured]
        UNION ALL
        SELECT 0 AS [set_id], 2 AS [category_id], N'Xoài cát Hòa Lộc' AS [title], 'mango.png' AS [image], N'Xoài cát Hòa Lộc loại đặc sản ngọt thơm chín tự nhiên.' AS [description], N'kg' AS [unit], 150 AS [stock_quantity], 0 AS [sold_quantity], 65000.00 AS [original_price], NULL AS [sale_price], 0 AS [is_featured]
        UNION ALL
        SELECT 0 AS [set_id], 3 AS [category_id], N'Cam hữu cơ Đà Lạt' AS [title], 'orange.png' AS [image], N'Cam canh hữu cơ Đà Lạt trồng theo chuẩn organic sạch.' AS [description], N'kg' AS [unit], 120 AS [stock_quantity], 0 AS [sold_quantity], 55000.00 AS [original_price], 45000.00 AS [sale_price], 0 AS [is_featured]
        UNION ALL
        SELECT 0 AS [set_id], 4 AS [category_id], N'Sầu riêng Musang King' AS [title], 'durian.png' AS [image], N'Sầu riêng Musang King cơm vàng hạt dẹt thơm béo ngậy.' AS [description], N'kg' AS [unit], 50 AS [stock_quantity], 0 AS [sold_quantity], 350000.00 AS [original_price], 320000.00 AS [sale_price], 0 AS [is_featured]
        
        UNION ALL
        
        -- Set 1: Mock products for odd shop IDs (sh.id % 2 = 1)
        SELECT 1 AS [set_id], 1 AS [category_id], N'Nho Úc không hạt' AS [title], 'grape.png' AS [image], N'Nho Úc tươi ngon ngọt nước, không hạt, nhiều dinh dưỡng.' AS [description], N'kg' AS [unit], 80 AS [stock_quantity], 0 AS [sold_quantity], 180000.00 AS [original_price], 150000.00 AS [sale_price], 1 AS [is_featured]
        UNION ALL
        SELECT 1 AS [set_id], 2 AS [category_id], N'Cam sành Hàm Yên' AS [title], 'orange.png' AS [image], N'Cam sành Hàm Yên nhiều nước, vỏ mỏng, vị chua ngọt đậm đà.' AS [description], N'kg' AS [unit], 200 AS [stock_quantity], 0 AS [sold_quantity], 35000.00 AS [original_price], 29000.00 AS [sale_price], 0 AS [is_featured]
        UNION ALL
        SELECT 1 AS [set_id], 3 AS [category_id], N'Chuối Laba hữu cơ' AS [title], 'banana.png' AS [image], N'Chuối Laba Đà Lạt dẻo ngọt thơm ngon chuẩn organic.' AS [description], N'kg' AS [unit], 150 AS [stock_quantity], 0 AS [sold_quantity], 35000.00 AS [original_price], 30000.00 AS [sale_price], 0 AS [is_featured]
        UNION ALL
        SELECT 1 AS [set_id], 4 AS [category_id], N'Nho mẫu đơn Hàn Quốc' AS [title], 'shine_muscat.png' AS [image], N'Nho mẫu đơn (Shine Muscat) Hàn Quốc trái to giòn ngọt lịm.' AS [description], N'chùm' AS [unit], 30 AS [stock_quantity], 0 AS [sold_quantity], 650000.00 AS [original_price], 590000.00 AS [sale_price], 0 AS [is_featured]
    ) m
    ON sh.[id] % 2 = m.[set_id]
    WHERE NOT EXISTS (
        SELECT 1 FROM [dbo].[Products] p 
        WHERE p.[shop_id] = sh.[id] AND p.[title] = m.[title]
    );

    DECLARE @RowsInserted INT = @@ROWCOUNT;
    
    COMMIT TRANSACTION;
    
    PRINT N'Successfully created ' + CAST(@RowsInserted AS VARCHAR(10)) + N' mock products for shops.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
        
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;
GO
