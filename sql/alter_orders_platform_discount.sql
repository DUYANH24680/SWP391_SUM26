-- ============================================================
-- Add platform discount tracking columns to Orders table
-- SQL Server syntax
-- ============================================================

ALTER TABLE Orders ADD platform_discount_amount DECIMAL(18, 2) NOT NULL DEFAULT 0;
ALTER TABLE Orders ADD shop_actual_revenue DECIMAL(18, 2) NOT NULL DEFAULT 0;
