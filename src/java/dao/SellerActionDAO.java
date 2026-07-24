package dao;

import model.SellerAction;
import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * SellerActionDAO - Handles all DB operations for SellerActions table.
 */
public class SellerActionDAO extends DbContext {

    /**
     * Log an admin action against a seller.
     */
    public int insert(SellerAction action) {
        String sql = "INSERT INTO SellerActions "
                   + "(shop_id, seller_id, action_type, reason, note, performed_by, suspend_until) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = getConnection().prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, action.getShopId());
            ps.setInt(2, action.getSellerId());
            ps.setString(3, action.getActionType());
            ps.setString(4, action.getReason());
            ps.setString(5, action.getNote());
            ps.setInt(6, action.getPerformedBy());
            if (action.getSuspendUntil() != null) ps.setTimestamp(7, action.getSuspendUntil());
            else ps.setNull(7, Types.TIMESTAMP);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("[SellerActionDAO] insert error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("SellerActionDAO.insert error: " + e.getMessage(), e);
        }
        return -1;
    }

    /**
     * Get all actions for a shop.
     */
    public List<SellerAction> getByShopId(int shopId) {
        List<SellerAction> list = new ArrayList<>();
        String sql = buildSelectSql() + " WHERE sa.shop_id = ? ORDER BY sa.created_at DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[SellerActionDAO] getByShopId error: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get all actions (for admin log view).
     */
    public List<SellerAction> getAll() {
        List<SellerAction> list = new ArrayList<>();
        String sql = buildSelectSql() + " ORDER BY sa.created_at DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("[SellerActionDAO] getAll error: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Count how many times a shop was blocked (action_type = 'block').
     */
    public int countBlocksByShopId(int shopId) {
        String sql = "SELECT COUNT(1) FROM SellerActions WHERE shop_id = ? AND action_type = 'block'";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[SellerActionDAO] countBlocksByShopId error: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Count how many warnings a shop received.
     */
    public int countWarnsByShopId(int shopId) {
        String sql = "SELECT COUNT(1) FROM SellerActions WHERE shop_id = ? AND action_type = 'warn'";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[SellerActionDAO] countWarnsByShopId error: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Check if a shop has an active temporary suspension.
     */
    public boolean hasActiveSuspension(int shopId) {
        String sql = "SELECT COUNT(1) FROM SellerActions "
                   + "WHERE shop_id = ? AND action_type = 'temp_suspend' "
                   + "  AND suspend_until > GETDATE()";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("[SellerActionDAO] hasActiveSuspension error: " + e.getMessage());
        }
        return false;
    }

    /**
     * Expire (clear) all active temp_suspend records for a shop
     * so hasActiveSuspension() returns false immediately after lift_suspend.
     */
    public void clearActiveSuspensions(int shopId) {
        String sql = "UPDATE SellerActions SET suspend_until = GETDATE() "
                   + "WHERE shop_id = ? AND action_type = 'temp_suspend' AND suspend_until > GETDATE()";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[SellerActionDAO] clearActiveSuspensions error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Get latest action for a shop.
     */
    public SellerAction getLatestByShopId(int shopId) {
        String sql = buildSelectSql() + " WHERE sa.shop_id = ? ORDER BY sa.created_at DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[SellerActionDAO] getLatestByShopId error: " + e.getMessage());
        }
        return null;
    }

    // ---- helpers ----
    private String buildSelectSql() {
        return "SELECT sa.id, sa.shop_id, sa.seller_id, sa.action_type, sa.reason, sa.note, "
             + "       sa.performed_by, sa.suspend_until, sa.created_at, "
             + "       s.shop_name, sel.fullname AS seller_fullname, "
             + "       ad.fullname AS admin_fullname "
             + "FROM SellerActions sa "
             + "JOIN Shops s ON sa.shop_id = s.id "
             + "JOIN Accounts sel ON sa.seller_id = sel.id "
             + "JOIN Accounts ad ON sa.performed_by = ad.id ";
    }

    private SellerAction mapRow(ResultSet rs) throws SQLException {
        SellerAction a = new SellerAction();
        a.setId(rs.getInt("id"));
        a.setShopId(rs.getInt("shop_id"));
        a.setSellerId(rs.getInt("seller_id"));
        a.setActionType(rs.getString("action_type"));
        a.setReason(rs.getString("reason"));
        a.setNote(rs.getString("note"));
        a.setPerformedBy(rs.getInt("performed_by"));
        a.setSuspendUntil(rs.getTimestamp("suspend_until"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        a.setShopName(rs.getString("shop_name"));
        a.setSellerFullname(rs.getString("seller_fullname"));
        a.setAdminFullname(rs.getString("admin_fullname"));
        return a;
    }
}
