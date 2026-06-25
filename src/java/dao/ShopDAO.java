package dao;

import model.Shop;
import Utils.DbContext;
import java.sql.*;

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

