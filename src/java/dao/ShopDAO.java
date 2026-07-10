package dao;

import model.Shop;
import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * ShopDAO - Handles all DB operations for Shops table.
 */
public class ShopDAO extends Utils.DbContext {

    /**
     * Lay thong tin shop theo id (khong kiem tra status).
     * Su dung de hien thi thong tin shop trong trang chi tiet san pham.
     */
    public Shop getShopById(int shopId) {
        String sql = "SELECT id, owner_id, shop_name, logo, description, address, status, created_at "
                   + "FROM Shops WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Shop shop = new Shop();
                    shop.setId(rs.getInt("id"));
                    shop.setOwnerId(rs.getInt("owner_id"));
                    shop.setShopName(rs.getString("shop_name"));
                    shop.setLogo(rs.getString("logo"));
                    shop.setDescription(rs.getString("description"));
                    shop.setAddress(rs.getString("address"));
                    shop.setStatus(rs.getInt("status"));
                    shop.setCreatedAt(rs.getTimestamp("created_at"));
                    return shop;
                }
            }
        } catch (SQLException e) {
            System.err.println("[ShopDAO] getShopById error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lay thong tin shop theo owner_id, chi tra ve neu shop da duoc Approved (status = 1).
     * Neu khong co shop hoac status khac 1 thi tra ve null.
     */
    public Shop getShopByOwnerId(int ownerId) {
        String sql = "SELECT id, owner_id, shop_name, logo, description, address, status, created_at "
                   + "FROM Shops "
                   + "WHERE owner_id = ? AND status = 1";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, ownerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ShopDAO] getShopByOwnerId error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ShopDAO.getShopByOwnerId error: " + e.getMessage(), e);
        }
        return null;
    }

    /**
     * Kiem tra xem owner da co shop nao duoc Approved (status = 1) hay chua.
     * Tra ve true neu co, false neu khong.
     */
    public boolean hasApprovedShop(int ownerId) {
        System.out.println("[ShopDAO] hasApprovedShop() called for ownerId=" + ownerId);
        String sql = "SELECT COUNT(1) FROM Shops WHERE owner_id = ? AND status = 1";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, ownerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    boolean result = rs.getInt(1) > 0;
                    System.out.println("[ShopDAO] hasApprovedShop result: " + result);
                    return result;
                }
            }
        } catch (SQLException e) {
            System.err.println("[ShopDAO] hasApprovedShop error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ShopDAO.hasApprovedShop error: " + e.getMessage(), e);
        }
        return false;
    }

    /**
     * Get all shops (for admin dropdown filter).
     */
    public List<Shop> getAllShops() {
        List<Shop> list = new ArrayList<>();
        String sql = "SELECT id, owner_id, shop_name, logo, description, address, status, created_at FROM Shops ORDER BY shop_name ASC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[ShopDAO] getAllShops error: " + e.getMessage());
            throw new RuntimeException("ShopDAO.getAllShops error: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Get all approved shops with full owner info (for Manage Sellers page).
     * Returns shops with owner account data joined.
     */
    public List<Shop> getAllSellers() {
        List<Shop> list = new ArrayList<>();
        String sql = "SELECT s.id, s.owner_id, s.shop_name, s.logo, s.description, s.address, s.status, s.created_at, "
                   + "       a.fullname AS owner_fullname, a.email AS owner_email, a.phone AS owner_phone "
                   + "FROM Shops s "
                   + "JOIN Accounts a ON s.owner_id = a.id "
                   + "WHERE s.status = 1 "
                   + "ORDER BY s.created_at DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Shop shop = mapRow(rs);
                shop.setOwnerFullname(rs.getString("owner_fullname"));
                shop.setOwnerEmail(rs.getString("owner_email"));
                shop.setOwnerPhone(rs.getString("owner_phone"));
                list.add(shop);
            }
        } catch (SQLException e) {
            System.err.println("[ShopDAO] getAllSellers error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ShopDAO.getAllSellers error: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Search approved shops by keyword (shop name, owner name, email, phone).
     */
    public List<Shop> searchSellers(String keyword) {
        List<Shop> list = new ArrayList<>();
        String sql = "SELECT s.id, s.owner_id, s.shop_name, s.logo, s.description, s.address, s.status, s.created_at, "
                   + "       a.fullname AS owner_fullname, a.email AS owner_email, a.phone AS owner_phone "
                   + "FROM Shops s "
                   + "JOIN Accounts a ON s.owner_id = a.id "
                   + "WHERE s.status = 1 "
                   + "  AND (s.shop_name LIKE ? OR a.fullname LIKE ? OR a.email LIKE ? OR a.phone LIKE ?) "
                   + "ORDER BY s.created_at DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            String kw = "%" + keyword.trim() + "%";
            ps.setString(1, kw);
            ps.setString(2, kw);
            ps.setString(3, kw);
            ps.setString(4, kw);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Shop shop = mapRow(rs);
                    shop.setOwnerFullname(rs.getString("owner_fullname"));
                    shop.setOwnerEmail(rs.getString("owner_email"));
                    shop.setOwnerPhone(rs.getString("owner_phone"));
                    list.add(shop);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ShopDAO] searchSellers error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ShopDAO.searchSellers error: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Get all shops including blocked ones (for admin block/unblock).
     * Returns shops with owner account data joined.
     */
    public List<Shop> getAllShopsWithOwner() {
        List<Shop> list = new ArrayList<>();
        String sql = "SELECT s.id, s.owner_id, s.shop_name, s.logo, s.description, s.address, s.status, s.created_at, "
                   + "       a.fullname AS owner_fullname, a.email AS owner_email, a.phone AS owner_phone, "
                   + "       a.status AS account_status "
                   + "FROM Shops s "
                   + "JOIN Accounts a ON s.owner_id = a.id "
                   + "ORDER BY s.created_at DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Shop shop = mapRow(rs);
                shop.setOwnerFullname(rs.getString("owner_fullname"));
                shop.setOwnerEmail(rs.getString("owner_email"));
                shop.setOwnerPhone(rs.getString("owner_phone"));
                shop.setOwnerAccountStatus(rs.getInt("account_status"));
                list.add(shop);
            }
        } catch (SQLException e) {
            System.err.println("[ShopDAO] getAllShopsWithOwner error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ShopDAO.getAllShopsWithOwner error: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Block a shop: set status = 3 (Blocked).
     */
    public boolean blockShop(int shopId) {
        String sql = "UPDATE Shops SET status = 3 WHERE id = ? AND status IN (1, 2)";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                System.out.println("[ShopDAO] blockShop() success, shopId=" + shopId);
                return true;
            }
            return false;
        } catch (SQLException e) {
            System.err.println("[ShopDAO] blockShop() error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ShopDAO.blockShop error: " + e.getMessage(), e);
        }
    }

    /**
     * Unblock a shop: set status = 1 (Approved).
     */
    public boolean unblockShop(int shopId) {
        String sql = "UPDATE Shops SET status = 1 WHERE id = ? AND status = 3";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                System.out.println("[ShopDAO] unblockShop() success, shopId=" + shopId);
                return true;
            }
            return false;
        } catch (SQLException e) {
            System.err.println("[ShopDAO] unblockShop() error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ShopDAO.unblockShop error: " + e.getMessage(), e);
        }
    }

    /**
     * Temporarily suspend a shop: set status = 0 (Suspended).
     */
    public boolean suspendShop(int shopId) {
        String sql = "UPDATE Shops SET status = 0 WHERE id = ? AND status = 1";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                System.out.println("[ShopDAO] suspendShop() success, shopId=" + shopId);
                return true;
            }
            return false;
        } catch (SQLException e) {
            System.err.println("[ShopDAO] suspendShop() error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ShopDAO.suspendShop error: " + e.getMessage(), e);
        }
    }

    /**
     * End temporary suspension: restore status = 1 (Approved).
     */
    public boolean endSuspension(int shopId) {
        String sql = "UPDATE Shops SET status = 1 WHERE id = ? AND status = 0";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                System.out.println("[ShopDAO] endSuspension() success, shopId=" + shopId);
                return true;
            }
            return false;
        } catch (SQLException e) {
            System.err.println("[ShopDAO] endSuspension() error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ShopDAO.endSuspension error: " + e.getMessage(), e);
        }
    }

    /**
     * Count products for a shop.
     */
    public int countProductsByShopId(int shopId) {
        String sql = "SELECT COUNT(1) FROM Products WHERE shop_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[ShopDAO] countProductsByShopId error: " + e.getMessage());
        }
        return 0;
    }


    // ---- helper ----
    private Shop mapRow(ResultSet rs) throws SQLException {
        Shop shop = new Shop();
        shop.setId(rs.getInt("id"));
        shop.setOwnerId(rs.getInt("owner_id"));
        shop.setShopName(rs.getString("shop_name"));
        shop.setLogo(rs.getString("logo"));
        shop.setDescription(rs.getString("description"));
        shop.setAddress(rs.getString("address"));
        shop.setStatus(rs.getInt("status"));
        shop.setCreatedAt(rs.getTimestamp("created_at"));
        return shop;
    }
}

