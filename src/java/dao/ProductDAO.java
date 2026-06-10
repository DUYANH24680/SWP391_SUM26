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

    /**
     * Lay danh sach san pham thuoc mot shop, bao gom ca san pham cho duyet (status = 0).
     * Su dung de hien thi danh sach san pham cua nguoi ban.
     */
    public List<Product> getProductsByShopId(int shopId) {
        String sql = "SELECT p.id, p.category_id, p.shop_id, p.title, p.image, p.description, p.unit, "
                   + "p.stock_quantity, p.sold_quantity, p.original_price, p.sale_price, p.expired_date, "
                   + "p.average_rating, p.is_featured, p.status, p.isDelete, p.created_at, "
                   + "s.shop_name "
                   + "FROM Products p "
                   + "LEFT JOIN Shops s ON p.shop_id = s.id "
                   + "WHERE p.shop_id = ? AND p.isDelete = 0 "
                   + "ORDER BY p.created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                List<Product> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
                return list;
            }
        } catch (SQLException e) {
            throw new RuntimeException("ProductDAO.getProductsByShopId error: " + e.getMessage(), e);
        }
    }

    /**
     * Tao san pham moi cung voi danh sach anh.
     * Dung transaction de dam bao tinh toan ven cua phep toan.
     */
    public boolean addProduct(Product product, List<String> imageUrls) {
        String sqlProduct = "INSERT INTO Products "
                + "(title, description, image, unit, stock_quantity, original_price, sale_price, "
                + "expired_date, category_id, shop_id, status, isDelete, is_featured, average_rating, sold_quantity) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, 0, 0, 0)";

        String sqlImage = "INSERT INTO ProductImages (product_id, image_url, sort_order) VALUES (?, ?, ?)";

        Connection conn = null;
        PreparedStatement psProduct = null;
        PreparedStatement psImage = null;
        ResultSet rsKeys = null;

        try {
            // Bat transaction
            conn = connection;
            conn.setAutoCommit(false);

            // INSERT vao bang Products
            psProduct = conn.prepareStatement(sqlProduct, Statement.RETURN_GENERATED_KEYS);
            psProduct.setString(1, product.getTitle());
            psProduct.setString(2, product.getDescription());

            // imageUrls.get(0) lam anh chinh trong bang Products
            if (imageUrls != null && !imageUrls.isEmpty()) {
                psProduct.setString(3, imageUrls.get(0));
            } else {
                psProduct.setNull(3, Types.VARCHAR);
            }

            psProduct.setString(4, product.getUnit());
            psProduct.setInt(5, product.getStockQuantity());
            psProduct.setDouble(6, product.getOriginalPrice());
            psProduct.setDouble(7, product.getSalePrice());

            if (product.getExpiredDate() != null) {
                psProduct.setTimestamp(8, product.getExpiredDate());
            } else {
                psProduct.setNull(8, Types.TIMESTAMP);
            }

            psProduct.setInt(9, product.getCategoryId());
            psProduct.setInt(10, product.getShopId());

            int rowsInserted = psProduct.executeUpdate();
            if (rowsInserted == 0) {
                conn.rollback();
                return false;
            }

            // Lay product_id vua duoc tao
            rsKeys = psProduct.getGeneratedKeys();
            if (!rsKeys.next()) {
                conn.rollback();
                return false;
            }
            int generatedProductId = rsKeys.getInt(1);

            // Neu co anh thi INSERT vao bang ProductImages
            if (imageUrls != null && !imageUrls.isEmpty()) {
                psImage = conn.prepareStatement(sqlImage);
                for (int i = 0; i < imageUrls.size(); i++) {
                    psImage.setInt(1, generatedProductId);
                    psImage.setString(2, imageUrls.get(i));
                    psImage.setInt(3, i + 1);
                    psImage.addBatch();
                }
                psImage.executeBatch();
            }

            // Commit transaction
            conn.commit();
            return true;

        } catch (SQLException e) {
            // Rollback neu co loi
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    throw new RuntimeException("ProductDAO.addProduct rollback error: " + ex.getMessage(), ex);
                }
            }
            throw new RuntimeException("ProductDAO.addProduct error: " + e.getMessage(), e);
        } finally {
            // Dong tat ca resource
            if (rsKeys != null) try { rsKeys.close(); } catch (SQLException ignored) {}
            if (psProduct != null) try { psProduct.close(); } catch (SQLException ignored) {}
            if (psImage != null) try { psImage.close(); } catch (SQLException ignored) {}
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignored) {}
            }
        }
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