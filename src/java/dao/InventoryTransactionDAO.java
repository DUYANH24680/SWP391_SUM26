package dao;

import model.InventoryTransaction;
import Utils.DbContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DuyAnhNgo- DAO QUẢN LÝ THAO TÁC GHI LỊCH SỬ XUẤT NHẬP KHO (INVENTORY TRANSACTIONS):
 * 
 * 1. CÁCH HOẠT ĐỘNG CỦA CODE:
 *    - Lớp này kế thừa DbContext để làm việc với DB SQL Server.
 *    - Cung cấp các phương thức lưu nhật ký (log) mỗi khi có hoạt động xuất hoặc nhập kho xảy ra.
 *    - Hỗ trợ truyền Connection ngoài để thực thi chung trong 1 Transaction (setAutoCommit(false)) đảm bảo tính toàn vẹn dữ liệu.
 * 
 * 2. ĐIỀU ĐI ĐÂU (LUỒNG GỌI / CHUYỂN DỮ LIỆU):
 *    - Được gọi gián tiếp từ ProductDAO (hoặc Servlet) khi tiến hành nhập kho/xuất kho.
 *    - Dữ liệu lưu vào bảng InventoryTransactions trong DB, kết quả sẽ được hiển thị lịch sử ở các trang quản lý kho của Seller.
 * 
 * 3. IMPORT EXPORT Ở ĐÂU TRONG DAO NÀO:
 *    - Nhập kho (Import): Phương thức addImport(InventoryTransaction tx, Connection conn) và addImport(InventoryTransaction tx).
 *    - Xuất kho (Export): Phương thức addExport(InventoryTransaction tx, Connection conn) và addExport(InventoryTransaction tx).
 */
public class InventoryTransactionDAO extends DbContext {

    // DuyAnhNgo- Hàm thêm lịch sử NHẬP KHO (Import) dùng chung Transaction
    public boolean addImport(InventoryTransaction tx, Connection conn) throws SQLException {
        String sql = "INSERT INTO InventoryTransactions "
                   + "(product_id, account_id, quantity, previous_stock, new_stock, note, transaction_type, expired_date) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tx.getProductId());
            ps.setInt(2, tx.getAccountId());
            ps.setInt(3, tx.getQuantity());
            ps.setInt(4, tx.getPreviousStock());
            ps.setInt(5, tx.getNewStock());
            if (tx.getNote() != null && !tx.getNote().trim().isEmpty()) {
                ps.setString(6, tx.getNote().trim());
            } else {
                ps.setNull(6, Types.NVARCHAR);
            }
            ps.setString(7, tx.getTransactionType());
            if (tx.getExpiredDate() != null) {
                ps.setTimestamp(8, tx.getExpiredDate());
            } else {
                ps.setNull(8, Types.TIMESTAMP);
            }
            int rows = ps.executeUpdate();
            System.out.println("[InventoryTransactionDAO] addImport(conn) inserted " + rows + " row(s)");
            return rows > 0;
        }
    }

    /**
     * Chen mot giao dich kho moi (standalone, tu tao connection rieng).
     * Su dung method addImport(tx, conn) neu can tich hop transaction ben ngoai.
     */
    public boolean addImport(InventoryTransaction tx) {
        try {
            return addImport(tx, getConnection());
        } catch (SQLException e) {
            System.err.println("[InventoryTransactionDAO] addImport() error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("InventoryTransactionDAO.addImport error: " + e.getMessage(), e);
        }
    }

    // DuyAnhNgo- Hàm thêm lịch sử XUẤT KHO (Export) dùng chung Transaction
    public boolean addExport(InventoryTransaction tx, Connection conn) throws SQLException {
        String sql = "INSERT INTO InventoryTransactions "
                   + "(product_id, account_id, quantity, previous_stock, new_stock, note, transaction_type, expired_date) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tx.getProductId());
            ps.setInt(2, tx.getAccountId());
            ps.setInt(3, tx.getQuantity());
            ps.setInt(4, tx.getPreviousStock());
            ps.setInt(5, tx.getNewStock());
            if (tx.getNote() != null && !tx.getNote().trim().isEmpty()) {
                ps.setString(6, tx.getNote().trim());
            } else {
                ps.setNull(6, Types.NVARCHAR);
            }
            ps.setString(7, tx.getTransactionType());
            ps.setNull(8, Types.TIMESTAMP);
            int rows = ps.executeUpdate();
            System.out.println("[InventoryTransactionDAO] addExport(conn) inserted " + rows + " row(s)");
            return rows > 0;
        }
    }

    /**
     * Chen mot giao dich xuat kho moi (standalone, tu tao connection rieng).
     */
    public boolean addExport(InventoryTransaction tx) {
        try {
            return addExport(tx, getConnection());
        } catch (SQLException e) {
            System.err.println("[InventoryTransactionDAO] addExport() error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("InventoryTransactionDAO.addExport error: " + e.getMessage(), e);
        }
    }

    /**
     * Lay danh sach giao dich kho theo productId, moi nhat truoc.
     */
    public List<InventoryTransaction> getByProductId(int productId) {
        String sql = "SELECT id, product_id, account_id, quantity, previous_stock, new_stock, "
                   + "       note, transaction_type, expired_date, created_at "
                   + "FROM InventoryTransactions "
                   + "WHERE product_id = ? "
                   + "ORDER BY created_at DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                List<InventoryTransaction> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
                System.out.println("[InventoryTransactionDAO] getByProductId(" + productId
                    + ") returned " + list.size() + " transaction(s)");
                return list;
            }
        } catch (SQLException e) {
            System.err.println("[InventoryTransactionDAO] getByProductId(" + productId
                + ") error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("InventoryTransactionDAO.getByProductId error: " + e.getMessage(), e);
        }
    }

    private InventoryTransaction mapRow(ResultSet rs) throws SQLException {
        InventoryTransaction tx = new InventoryTransaction();
        tx.setId(rs.getInt("id"));
        tx.setProductId(rs.getInt("product_id"));
        tx.setAccountId(rs.getInt("account_id"));
        tx.setQuantity(rs.getInt("quantity"));
        tx.setPreviousStock(rs.getInt("previous_stock"));
        tx.setNewStock(rs.getInt("new_stock"));
        tx.setNote(rs.getString("note"));
        tx.setTransactionType(rs.getString("transaction_type"));
        tx.setExpiredDate(rs.getTimestamp("expired_date"));
        tx.setCreatedAt(rs.getTimestamp("created_at"));
        return tx;
    }

    // DuyAnhNgo- Lay danh sach lo hang (batch) con ton kho cho mot shop
    // ========================================================================
    // CÁCH HOẠT ĐỘNG CỦA CÂU QUERY GOM LÔ HÀNG (BATCHING):
    // Hệ thống không tạo bảng phụ cho các lô hàng. Thay vào đó, gom nhóm tự động
    // bằng cách gộp (UNION ALL) 2 nguồn dữ liệu:
    // 
    // NGUỒN 1: TỒN KHO GỐC TỪ BẢNG Products
    // Lấy tồn kho hiện tại (stock_quantity) TRỪ ĐI tất cả các biến động đã được
    // ghi trong lịch sử giao dịch (InventoryTransactions) của sản phẩm đó.
    // Kết quả thu được chính là số tồn kho ban đầu (chưa có lịch sử giao dịch) 
    // kèm theo hạn sử dụng gốc của nó.
    //
    // NGUỒN 2: CÁC LÔ NHẬP/XUẤT MỚI TỪ BẢNG InventoryTransactions
    // Quét toàn bộ lịch sử. Nếu là 'IMPORT' thì cộng (+), 'EXPORT' thì trừ (-).
    // Gắn với hạn sử dụng (expired_date) của chính lần giao dịch đó.
    //
    // Cuối cùng, SUM(quantity) theo từng sản phẩm và từng ngày hết hạn,
    // lọc bỏ các lô đã hết hàng (HAVING SUM > 0).
    // ========================================================================
    public List<java.util.Map<String, Object>> getInventoryBatches(int shopId) {
        String sql = "SELECT product_id, expired_date, title, image, unit, SUM(quantity) AS remaining_quantity "
                   + "FROM ( "
                   + "    -- NGUỒN 1: TỒN KHO GỐC \n"
                   + "    SELECT id AS product_id, expired_date, title, image, unit, "
                   + "           (stock_quantity - COALESCE((SELECT SUM(CASE WHEN transaction_type = 'IMPORT' THEN quantity ELSE -quantity END) FROM InventoryTransactions WHERE product_id = p.id), 0)) AS quantity "
                   + "    FROM Products p WHERE shop_id = ? AND isDelete = 0 AND status = 1 "
                   + "    UNION ALL "
                   + "    -- NGUỒN 2: CÁC GIAO DỊCH MỚI CÓ GHI HSD \n"
                   + "    SELECT t.product_id, t.expired_date, p.title, p.image, p.unit, "
                   + "           CASE WHEN t.transaction_type = 'IMPORT' THEN t.quantity ELSE -t.quantity END AS quantity "
                   + "    FROM InventoryTransactions t "
                   + "    JOIN Products p ON t.product_id = p.id "
                   + "    WHERE p.shop_id = ? AND p.isDelete = 0 AND p.status = 1 "
                   + ") AS SubQuery "
                   + "GROUP BY product_id, expired_date, title, image, unit "
                   + "HAVING SUM(quantity) > 0 "
                   + "ORDER BY expired_date ASC";

        List<java.util.Map<String, Object>> list = new java.util.ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shopId);
            ps.setInt(2, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> map = new java.util.HashMap<>();
                    map.put("productId", rs.getInt("product_id"));
                    map.put("expiredDate", rs.getTimestamp("expired_date"));
                    map.put("title", rs.getString("title"));
                    map.put("image", rs.getString("image"));
                    map.put("unit", rs.getString("unit"));
                    map.put("quantity", rs.getInt("remaining_quantity"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            System.err.println("[InventoryTransactionDAO] getInventoryBatches() error: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }
}
