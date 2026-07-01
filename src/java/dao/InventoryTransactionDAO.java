package dao;

import model.InventoryTransaction;
import Utils.DbContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bang InventoryTransactions.
 * Ho tro cac thao tac CRUD tren lich su nhap/xuat kho.
 */
public class InventoryTransactionDAO extends DbContext {

    /**
     * Chen mot giao dich kho moi dung transaction cua caller.
     * Dung khi caller da setAutoCommit(false) va muon dam bao atomic voi cac thao tac khac.
     *
     * @param tx   giao dich kho
     * @param conn connection dang duoc caller quan ly transaction (khong dong sau khi goi)
     * @return true neu insert thanh cong
     */
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

    /**
     * Chen mot giao dich xuat kho moi dung transaction cua caller.
     *
     * @param tx   giao dich kho
     * @param conn connection dang duoc caller quan ly transaction
     * @return true neu insert thanh cong
     */
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
}
