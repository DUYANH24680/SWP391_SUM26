package dao;

import model.ShopRequest;
import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * ShopRequestDAO - Handles DB operations for ShopRequests table.
 */
public class ShopRequestDAO extends DbContext {

    /**
     * Submit a new seller registration request for an account.
     * Returns the generated request id, or -1 on failure.
     */
    public int insert(int accountId, String shopName, String description, String address) {
        String sql = "INSERT INTO ShopRequests (account_id, shop_name, description, address, status) "
                   + "VALUES (?, ?, ?, ?, 0)";
        try (PreparedStatement ps = getConnection().prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, accountId);
            ps.setString(2, shopName.trim());
            ps.setString(3, description != null ? description.trim() : null);
            ps.setString(4, address != null ? address.trim() : null);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int newId = rs.getInt(1);
                        System.out.println("[ShopRequestDAO] insert() success, id=" + newId);
                        return newId;
                    }
                }
            }
            return -1;
        } catch (SQLException e) {
            System.err.println("[ShopRequestDAO] insert() error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ShopRequestDAO.insert error: " + e.getMessage(), e);
        }
    }

    /**
     * Check if an account already has a pending seller request.
     */
    public boolean hasPendingRequest(int accountId) {
        String sql = "SELECT COUNT(1) FROM ShopRequests WHERE account_id = ? AND status = 0";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("ShopRequestDAO.hasPendingRequest error: " + e.getMessage(), e);
        }
        return false;
    }

    /**
     * Check if an account already has a shop (any status).
     */
    public boolean hasShop(int accountId) {
        String sql = "SELECT COUNT(1) FROM Shops WHERE owner_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("ShopRequestDAO.hasShop error: " + e.getMessage(), e);
        }
        return false;
    }

    /**
     * Get the most recent request for an account (any status).
     */
    public ShopRequest getByAccountId(int accountId) {
        String sql = "SELECT r.*, a.fullname AS account_fullname, a.email AS account_email, a.phone AS account_phone "
                   + "FROM ShopRequests r "
                   + "JOIN Accounts a ON r.account_id = a.id "
                   + "WHERE r.account_id = ? "
                   + "ORDER BY r.created_at DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("ShopRequestDAO.getByAccountId error: " + e.getMessage(), e);
        }
        return null;
    }

    /**
     * Get all pending requests, newest first.
     */
    public List<ShopRequest> getPending() {
        List<ShopRequest> list = new ArrayList<>();
        String sql = "SELECT r.*, a.fullname AS account_fullname, a.email AS account_email, a.phone AS account_phone "
                   + "FROM ShopRequests r "
                   + "JOIN Accounts a ON r.account_id = a.id "
                   + "WHERE r.status = 0 "
                   + "ORDER BY r.created_at DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("ShopRequestDAO.getPending error: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Get all requests, newest first.
     */
    public List<ShopRequest> getAll() {
        List<ShopRequest> list = new ArrayList<>();
        String sql = "SELECT r.*, a.fullname AS account_fullname, a.email AS account_email, a.phone AS account_phone "
                   + "FROM ShopRequests r "
                   + "JOIN Accounts a ON r.account_id = a.id "
                   + "ORDER BY r.created_at DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("ShopRequestDAO.getAll error: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Find a request by id.
     */
    public ShopRequest findById(int id) {
        String sql = "SELECT r.*, a.fullname AS account_fullname, a.email AS account_email, a.phone AS account_phone "
                   + "FROM ShopRequests r "
                   + "JOIN Accounts a ON r.account_id = a.id "
                   + "WHERE r.id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("ShopRequestDAO.findById error: " + e.getMessage(), e);
        }
        return null;
    }

    /**
     * Approve a request: update status + create the Shop + update account role to seller.
     */
    public boolean approve(int requestId) {
        ShopRequest req = findById(requestId);
        if (req == null || !req.isPending()) return false;

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            // 1. Update request status to Approved
            String sqlReq = "UPDATE ShopRequests SET status = 1 WHERE id = ? AND status = 0";
            try (PreparedStatement ps = conn.prepareStatement(sqlReq)) {
                ps.setInt(1, requestId);
                if (ps.executeUpdate() == 0) { conn.rollback(); return false; }
            }

            // 2. Create Shop (status 1 = Approved)
            String sqlShop = "INSERT INTO Shops (owner_id, shop_name, description, address, status) VALUES (?, ?, ?, ?, 1)";
            int newShopId = -1;
            try (PreparedStatement ps = conn.prepareStatement(sqlShop, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, req.getAccountId());
                ps.setString(2, req.getShopName());
                ps.setString(3, req.getDescription());
                ps.setString(4, req.getAddress());
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) newShopId = rs.getInt(1);
                }
            }

            // 3. Update account role to seller (role_id = 2)
            String sqlRole = "UPDATE Accounts SET role_id = 2 WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlRole)) {
                ps.setInt(1, req.getAccountId());
                ps.executeUpdate();
            }

            conn.commit();
            System.out.println("[ShopRequestDAO] approve() success: requestId=" + requestId + ", newShopId=" + newShopId);
            return true;

        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ignored) {}
            System.err.println("[ShopRequestDAO] approve() error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ShopRequestDAO.approve error: " + e.getMessage(), e);
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ignored) {}
            }
        }
    }

    /**
     * Reject a request: update status to Rejected (2).
     */
    public boolean reject(int requestId) {
        String sql = "UPDATE ShopRequests SET status = 2 WHERE id = ? AND status = 0";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, requestId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                System.out.println("[ShopRequestDAO] reject() success: requestId=" + requestId);
                return true;
            }
            return false;
        } catch (SQLException e) {
            System.err.println("[ShopRequestDAO] reject() error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ShopRequestDAO.reject error: " + e.getMessage(), e);
        }
    }

    // ---- helper ----
    private ShopRequest mapRow(ResultSet rs) throws SQLException {
        ShopRequest r = new ShopRequest();
        r.setId(rs.getInt("id"));
        r.setAccountId(rs.getInt("account_id"));
        r.setShopName(rs.getString("shop_name"));
        r.setDescription(rs.getString("description"));
        r.setAddress(rs.getString("address"));
        r.setStatus(rs.getInt("status"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setAccountFullname(rs.getString("account_fullname"));
        r.setAccountEmail(rs.getString("account_email"));
        r.setAccountPhone(rs.getString("account_phone"));
        return r;
    }
}
