package dao;

import model.Product;
import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO extends DbContext {

    public List<Product> getAllProducts() {
        String sql = "SELECT p.id, p.category_id, p.shop_id, p.title, p.image, p.description, p.unit, "
                   + "p.stock_quantity, p.sold_quantity, p.original_price, p.sale_price, p.expired_date, "
                   + "p.average_rating, p.is_featured, p.status, p.isDelete, p.created_at, "
                   + "s.shop_name "
                   + "FROM Products p "
                   + "LEFT JOIN Shops s ON p.shop_id = s.id "
                   + "WHERE p.isDelete = 0 ORDER BY p.created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<Product> list = new ArrayList<>();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
            return list;
        } catch (SQLException e) {
            throw new RuntimeException("ProductDAO.getAllProducts error: " + e.getMessage(), e);
        }
    }

    public List<Product> searchProducts(String keyword) {
        String sql = "SELECT p.id, p.category_id, p.shop_id, p.title, p.image, p.description, p.unit, "
                   + "p.stock_quantity, p.sold_quantity, p.original_price, p.sale_price, p.expired_date, "
                   + "p.average_rating, p.is_featured, p.status, p.isDelete, p.created_at, "
                   + "s.shop_name "
                   + "FROM Products p "
                   + "LEFT JOIN Shops s ON p.shop_id = s.id "
                   + "WHERE p.isDelete = 0 "
                   + "  AND (p.title LIKE ? OR p.description LIKE ?) "
                   + "ORDER BY p.created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            String pattern = "%" + keyword + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            try (ResultSet rs = ps.executeQuery()) {
                List<Product> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
                return list;
            }
        } catch (SQLException e) {
            throw new RuntimeException("ProductDAO.searchProducts error: " + e.getMessage(), e);
        }
    }

    public Product getProductById(int id) {
        String sql = "SELECT p.id, p.category_id, p.shop_id, p.title, p.image, p.description, p.unit, "
                   + "p.stock_quantity, p.sold_quantity, p.original_price, p.sale_price, p.expired_date, "
                   + "p.average_rating, p.is_featured, p.status, p.isDelete, p.created_at, "
                   + "s.shop_name "
                   + "FROM Products p "
                   + "LEFT JOIN Shops s ON p.shop_id = s.id "
                   + "WHERE p.id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("ProductDAO.getProductById error: " + e.getMessage(), e);
        }
        return null;
    }

    private Product mapRow(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setId(rs.getInt("id"));
        p.setCategoryId(rs.getInt("category_id"));
        p.setShopId(rs.getInt("shop_id"));
        p.setShopName(rs.getString("shop_name"));
        p.setTitle(rs.getString("title"));
        p.setImage(rs.getString("image"));
        p.setDescription(rs.getString("description"));
        p.setUnit(rs.getString("unit"));
        p.setStockQuantity(rs.getInt("stock_quantity"));
        p.setSoldQuantity(rs.getInt("sold_quantity"));
        p.setOriginalPrice(rs.getDouble("original_price"));
        p.setSalePrice(rs.getDouble("sale_price"));
        p.setExpiredDate(rs.getTimestamp("expired_date"));
        p.setAverageRating(rs.getDouble("average_rating"));
        p.setIsFeatured(rs.getBoolean("is_featured"));
        p.setStatus(rs.getInt("status"));
        p.setIsDelete(rs.getBoolean("isDelete"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        return p;
    }
}
