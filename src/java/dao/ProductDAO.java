package dao;

import Utils.DbContext;
import model.Product;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    public boolean addProduct(Product product) {
        String sql = "INSERT INTO Products (category_id, seller_id, title, image, description, unit, stock_quantity, original_price, sale_price, expired_date, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, product.getCategoryId());
            ps.setInt(2, product.getSellerId());
            ps.setString(3, product.getTitle());
            ps.setString(4, product.getImage());
            ps.setString(5, product.getDescription());
            ps.setString(6, product.getUnit());
            ps.setInt(7, product.getStockQuantity());
            ps.setBigDecimal(8, product.getOriginalPrice());
            ps.setBigDecimal(9, product.getSalePrice());
            if (product.getExpiredDate() != null) {
                ps.setDate(10, product.getExpiredDate());
            } else {
                ps.setNull(10, Types.DATE);
            }
            ps.setInt(11, product.getStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("ProductDAO.addProduct error: " + e.getMessage(), e);
        }
    }

    public List<Product> getAll() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT id, category_id, seller_id, title, image, description, unit, stock_quantity, "
                   + "sold_quantity, original_price, sale_price, expired_date, average_rating, "
                   + "is_featured, status, isDelete, created_at "
                   + "FROM Products WHERE isDelete = 0";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("ProductDAO.getAll error: " + e.getMessage(), e);
        }
        return list;
    }

    public Product findById(int id) {
        String sql = "SELECT id, category_id, seller_id, title, image, description, unit, stock_quantity, "
                   + "sold_quantity, original_price, sale_price, expired_date, average_rating, "
                   + "is_featured, status, isDelete, created_at "
                   + "FROM Products WHERE id = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("ProductDAO.findById error: " + e.getMessage(), e);
        }
        return null;
    }

    public List<Product> getByCategory(int categoryId) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT id, category_id, seller_id, title, image, description, unit, stock_quantity, "
                   + "sold_quantity, original_price, sale_price, expired_date, average_rating, "
                   + "is_featured, status, isDelete, created_at "
                   + "FROM Products WHERE category_id = ? AND isDelete = 0";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("ProductDAO.getByCategory error: " + e.getMessage(), e);
        }
        return list;
    }

    public List<Product> getBySeller(int sellerId) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT id, category_id, seller_id, title, image, description, unit, stock_quantity, "
                   + "sold_quantity, original_price, sale_price, expired_date, average_rating, "
                   + "is_featured, status, isDelete, created_at "
                   + "FROM Products WHERE seller_id = ? AND isDelete = 0";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sellerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("ProductDAO.getBySeller error: " + e.getMessage(), e);
        }
        return list;
    }

    public boolean update(Product product) {
        String sql = "UPDATE Products SET category_id = ?, title = ?, image = ?, description = ?, "
                   + "unit = ?, stock_quantity = ?, original_price = ?, sale_price = ?, "
                   + "expired_date = ?, is_featured = ?, status = ? WHERE id = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, product.getCategoryId());
            ps.setString(2, product.getTitle());
            ps.setString(3, product.getImage());
            ps.setString(4, product.getDescription());
            ps.setString(5, product.getUnit());
            ps.setInt(6, product.getStockQuantity());
            ps.setBigDecimal(7, product.getOriginalPrice());
            ps.setBigDecimal(8, product.getSalePrice());
            if (product.getExpiredDate() != null) {
                ps.setDate(9, product.getExpiredDate());
            } else {
                ps.setNull(9, Types.DATE);
            }
            ps.setBoolean(10, product.isIsFeatured());
            ps.setInt(11, product.getStatus());
            ps.setInt(12, product.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("ProductDAO.update error: " + e.getMessage(), e);
        }
    }

    public boolean hardDelete(int id) {
        String sql = "DELETE FROM Products WHERE id = ? AND isDelete = 0";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("ProductDAO.hardDelete error: " + e.getMessage(), e);
        }
    }

    public boolean delete(int id) {
        String sql = "UPDATE Products SET isDelete = 1 WHERE id = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("ProductDAO.delete error: " + e.getMessage(), e);
        }
    }

    public boolean updateStatus(int id, int status) {
        String sql = "UPDATE Products SET status = ? WHERE id = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("ProductDAO.updateStatus error: " + e.getMessage(), e);
        }
    }

    private Product mapRow(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setId(rs.getInt("id"));
        p.setCategoryId(rs.getInt("category_id"));
        p.setSellerId(rs.getInt("seller_id"));
        p.setTitle(rs.getString("title"));
        p.setImage(rs.getString("image"));
        p.setDescription(rs.getString("description"));
        p.setUnit(rs.getString("unit"));
        p.setStockQuantity(rs.getInt("stock_quantity"));
        p.setSoldQuantity(rs.getInt("sold_quantity"));
        p.setOriginalPrice(rs.getBigDecimal("original_price"));
        p.setSalePrice(rs.getBigDecimal("sale_price"));
        p.setExpiredDate(rs.getDate("expired_date"));
        p.setAverageRating(rs.getBigDecimal("average_rating"));
        p.setIsFeatured(rs.getBoolean("is_featured"));
        p.setStatus(rs.getInt("status"));
        p.setIsDelete(rs.getBoolean("isDelete"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        return p;
    }
}
