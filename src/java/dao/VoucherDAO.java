package dao;

import model.Voucher;
import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VoucherDAO extends DbContext {

    /**
     * Find a voucher by its code.
     */
    public Voucher findByCode(String code) {
        if (code == null || code.trim().isEmpty()) return null;
        
        String sql = "SELECT id, code, discount_percent, max_discount, minimum_order, start_date, end_date, quantity, used_count, status "
                   + "FROM Vouchers WHERE code = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[VoucherDAO] findByCode error: " + e.getMessage());
            throw new RuntimeException("VoucherDAO.findByCode error: " + e.getMessage(), e);
        }
        return null;
    }

    /**
     * Get all active vouchers that can be used.
     */
    public List<Voucher> getAllActiveVouchers() {
        List<Voucher> list = new ArrayList<>();
        String sql = "SELECT id, code, discount_percent, max_discount, minimum_order, start_date, end_date, quantity, used_count, status "
                   + "FROM Vouchers "
                   + "WHERE status = 1 AND used_count < quantity AND (start_date IS NULL OR start_date <= GETDATE()) AND (end_date IS NULL OR end_date >= GETDATE()) "
                   + "ORDER BY discount_percent DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[VoucherDAO] getAllActiveVouchers error: " + e.getMessage());
            throw new RuntimeException("VoucherDAO.getAllActiveVouchers error: " + e.getMessage(), e);
        }
        return list;
    }

    private Voucher mapRow(ResultSet rs) throws SQLException {
        Voucher v = new Voucher();
        v.setId(rs.getInt("id"));
        v.setCode(rs.getString("code"));
        v.setDiscountPercent(rs.getDouble("discount_percent"));
        v.setMaxDiscount(rs.getDouble("max_discount"));
        v.setMinimumOrder(rs.getDouble("minimum_order"));
        v.setStartDate(rs.getTimestamp("start_date"));
        v.setEndDate(rs.getTimestamp("end_date"));
        v.setQuantity(rs.getInt("quantity"));
        v.setUsedCount(rs.getInt("used_count"));
        v.setStatus(rs.getBoolean("status"));
        return v;
    }
}

