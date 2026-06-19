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
        try (PreparedStatement ps = getConnection().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<Product> list = new ArrayList<>();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
            System.out.println("[ProductDAO] getAllProducts() returned " + list.size() + " products");
            return list;
        } catch (SQLException e) {
            System.err.println("[ProductDAO] getAllProducts() SQL error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ProductDAO.getAllProducts error: " + e.getMessage(), e);
        }
    }

    public int countAllProducts() {
        String sql = "SELECT COUNT(*) FROM Products WHERE isDelete = 0";
        try (PreparedStatement ps = getConnection().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("[ProductDAO] countAllProducts() = " + count);
                return count;
            }
            return 0;
        } catch (SQLException e) {
            System.err.println("[ProductDAO] countAllProducts() error: " + e.getMessage());
            e.printStackTrace();
            return 0;
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
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            String pattern = "%" + keyword + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            try (ResultSet rs = ps.executeQuery()) {
                List<Product> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
                System.out.println("[ProductDAO] searchProducts('" + keyword + "') returned " + list.size() + " products");
                return list;
            }
        } catch (SQLException e) {
            System.err.println("[ProductDAO] searchProducts() SQL error: " + e.getMessage());
            e.printStackTrace();
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
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ProductDAO] getProductById(" + id + ") error: " + e.getMessage());
            e.printStackTrace();
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
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                List<Product> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
                System.out.println("[ProductDAO] getProductsByShopId(" + shopId + ") returned " + list.size() + " products");
                return list;
            }
        } catch (SQLException e) {
            System.err.println("[ProductDAO] getProductsByShopId(" + shopId + ") error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ProductDAO.getProductsByShopId error: " + e.getMessage(), e);
        }
    }

    public int countProductsByShopId(int shopId) {
        String sql = "SELECT COUNT(*) FROM Products WHERE shop_id = ? AND isDelete = 0";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    System.out.println("[ProductDAO] countProductsByShopId(" + shopId + ") = " + count);
                    return count;
                }
            }
        } catch (SQLException e) {
            System.err.println("[ProductDAO] countProductsByShopId(" + shopId + ") error: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
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
            conn = getConnection();
            conn.setAutoCommit(false);

            psProduct = conn.prepareStatement(sqlProduct, Statement.RETURN_GENERATED_KEYS);
            psProduct.setString(1, product.getTitle());
            psProduct.setString(2, product.getDescription());

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

            rsKeys = psProduct.getGeneratedKeys();
            if (!rsKeys.next()) {
                conn.rollback();
                return false;
            }
            int generatedProductId = rsKeys.getInt(1);

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

            conn.commit();
            System.out.println("[ProductDAO] addProduct() success, id=" + generatedProductId);
            return true;

        } catch (SQLException e) {
            System.err.println("[ProductDAO] addProduct() error: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { }
            }
            throw new RuntimeException("ProductDAO.addProduct error: " + e.getMessage(), e);
        } finally {
            if (rsKeys != null) try { rsKeys.close(); } catch (SQLException ignored) {}
            if (psProduct != null) try { psProduct.close(); } catch (SQLException ignored) {}
            if (psImage != null) try { psImage.close(); } catch (SQLException ignored) {}
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ignored) {}
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

    /**
     * Soft delete: danh dau san pham la da xoa (isDelete = 1).
     * Chi seller cua shop so huu moi duoc phep xoa san pham cua minh.
     */
    public boolean deleteProduct(int productId, int shopId) {
        String sql = "UPDATE Products SET isDelete = 1 WHERE id = ? AND shop_id = ? AND isDelete = 0";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, shopId);
            int rowsUpdated = ps.executeUpdate();
            if (rowsUpdated > 0) {
                System.out.println("[ProductDAO] deleteProduct(id=" + productId + ", shopId=" + shopId + ") success");
            } else {
                System.out.println("[ProductDAO] deleteProduct(id=" + productId + ", shopId=" + shopId
                    + ") — product not found or already deleted");
            }
            return rowsUpdated > 0;
        } catch (SQLException e) {
            System.err.println("[ProductDAO] deleteProduct(" + productId + "," + shopId + ") error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ProductDAO.deleteProduct error: " + e.getMessage(), e);
        }
    }

    /**
     * Lay san pham theo id co kiem tra ownership.
     * Tra ve null neu san pham khong ton tai hoac khong thuoc shop.
     */
    public Product getProductByIdForEdit(int productId, int shopId) {
        String sql = "SELECT p.id, p.category_id, p.shop_id, p.title, p.image, p.description, p.unit, "
                   + "p.stock_quantity, p.sold_quantity, p.original_price, p.sale_price, p.expired_date, "
                   + "p.average_rating, p.is_featured, p.status, p.isDelete, p.created_at, "
                   + "s.shop_name "
                   + "FROM Products p "
                   + "LEFT JOIN Shops s ON p.shop_id = s.id "
                   + "WHERE p.id = ? AND p.shop_id = ? AND p.isDelete = 0";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    System.out.println("[ProductDAO] getProductByIdForEdit(productId=" + productId
                        + ", shopId=" + shopId + ") — ownership verified");
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ProductDAO] getProductByIdForEdit(" + productId + "," + shopId
                + ") error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ProductDAO.getProductByIdForEdit error: " + e.getMessage(), e);
        }
        System.out.println("[ProductDAO] getProductByIdForEdit(productId=" + productId
            + ", shopId=" + shopId + ") — product not found or not owned by shop");
        return null;
    }

    /**
     * Lay danh sach anh cua mot san pham.
     */
    public List<String> getProductImageUrls(int productId) {
        String sql = "SELECT image_url FROM ProductImages WHERE product_id = ? ORDER BY sort_order ASC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                List<String> urls = new ArrayList<>();
                while (rs.next()) {
                    urls.add(rs.getString("image_url"));
                }
                System.out.println("[ProductDAO] getProductImageUrls(" + productId
                    + ") returned " + urls.size() + " images");
                return urls;
            }
        } catch (SQLException e) {
            System.err.println("[ProductDAO] getProductImageUrls(" + productId
                + ") error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ProductDAO.getProductImageUrls error: " + e.getMessage(), e);
        }
    }

    /**
     * Xoa toan bo anh cua mot san pham.
     * Tra ve so anh da xoa.
     */
    public boolean deleteAllProductImages(int productId) {
        String sql = "DELETE FROM ProductImages WHERE product_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, productId);
            int rowsDeleted = ps.executeUpdate();
            System.out.println("[ProductDAO] deleteAllProductImages(" + productId
                + ") deleted " + rowsDeleted + " images");
            return rowsDeleted >= 0;
        } catch (SQLException e) {
            System.err.println("[ProductDAO] deleteAllProductImages(" + productId
                + ") error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ProductDAO.deleteAllProductImages error: " + e.getMessage(), e);
        }
    }

    /**
     * Cap nhat thong tin san pham co tich hop thay doi anh.
     * Neu newImageUrls khac null thi xoa anh cu va them anh moi trong cung transaction.
     * Dong thoi cap nhat lai truong image (anh dai dien) theo anh dau tien trong danh sach.
     */
    public boolean updateProduct(Product product, List<String> newImageUrls) {
        String sqlUpdate = "UPDATE Products SET "
                + "title = ?, description = ?, unit = ?, stock_quantity = ?, "
                + "original_price = ?, sale_price = ?, expired_date = ?, "
                + "category_id = ?, status = ? "
                + "WHERE id = ? AND shop_id = ? AND isDelete = 0";

        String sqlDeleteImages = "DELETE FROM ProductImages WHERE product_id = ?";
        String sqlInsertImage = "INSERT INTO ProductImages (product_id, image_url, sort_order) VALUES (?, ?, ?)";

        Connection conn = null;
        PreparedStatement psUpdate = null;
        PreparedStatement psDeleteImages = null;
        PreparedStatement psInsertImage = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            psUpdate = conn.prepareStatement(sqlUpdate);
            psUpdate.setString(1, product.getTitle());
            psUpdate.setString(2, product.getDescription());
            psUpdate.setString(3, product.getUnit());
            psUpdate.setInt(4, product.getStockQuantity());
            psUpdate.setDouble(5, product.getOriginalPrice());
            psUpdate.setDouble(6, product.getSalePrice());

            if (product.getExpiredDate() != null) {
                psUpdate.setTimestamp(7, product.getExpiredDate());
            } else {
                psUpdate.setNull(7, Types.TIMESTAMP);
            }

            psUpdate.setInt(8, product.getCategoryId());
            psUpdate.setInt(9, product.getStatus());
            psUpdate.setInt(10, product.getId());
            psUpdate.setInt(11, product.getShopId());

            int rowsUpdated = psUpdate.executeUpdate();
            if (rowsUpdated == 0) {
                conn.rollback();
                System.out.println("[ProductDAO] updateProduct — no rows updated (product not found or not owned)");
                return false;
            }

            if (newImageUrls != null) {
                psDeleteImages = conn.prepareStatement(sqlDeleteImages);
                psDeleteImages.setInt(1, product.getId());
                psDeleteImages.executeUpdate();

                psInsertImage = conn.prepareStatement(sqlInsertImage);
                for (int i = 0; i < newImageUrls.size(); i++) {
                    psInsertImage.setInt(1, product.getId());
                    psInsertImage.setString(2, newImageUrls.get(i));
                    psInsertImage.setInt(3, i + 1);
                    psInsertImage.addBatch();
                }
                psInsertImage.executeBatch();

                String coverImage = newImageUrls.isEmpty() ? null : newImageUrls.get(0);
                String sqlUpdateCover = "UPDATE Products SET image = ? WHERE id = ?";
                try (PreparedStatement psCover = conn.prepareStatement(sqlUpdateCover)) {
                    if (coverImage != null) {
                        psCover.setString(1, coverImage);
                    } else {
                        psCover.setNull(1, Types.VARCHAR);
                    }
                    psCover.setInt(2, product.getId());
                    psCover.executeUpdate();
                }
            }

            conn.commit();
            System.out.println("[ProductDAO] updateProduct(id=" + product.getId()
                + ", imageCount=" + (newImageUrls != null ? newImageUrls.size() : "unchanged")
                + ") success");
            return true;

        } catch (SQLException e) {
            System.err.println("[ProductDAO] updateProduct(" + product.getId()
                + ") error: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { }
            }
            throw new RuntimeException("ProductDAO.updateProduct error: " + e.getMessage(), e);
        } finally {
            if (psUpdate != null) try { psUpdate.close(); } catch (SQLException ignored) {}
            if (psDeleteImages != null) try { psDeleteImages.close(); } catch (SQLException ignored) {}
            if (psInsertImage != null) try { psInsertImage.close(); } catch (SQLException ignored) {}
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ignored) {}
            }
        }
    }

    public List<Product> filterProducts(String keyword, List<Integer> categoryIds, String status) {
        StringBuilder sql = new StringBuilder(
                "SELECT p.id, p.category_id, p.shop_id, p.title, p.image, p.description, p.unit, "
              + "p.stock_quantity, p.sold_quantity, p.original_price, p.sale_price, p.expired_date, "
              + "p.average_rating, p.is_featured, p.status, p.isDelete, p.created_at, "
              + "s.shop_name "
              + "FROM Products p "
              + "LEFT JOIN Shops s ON p.shop_id = s.id "
              + "WHERE p.isDelete = 0 "
        );

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.title LIKE ? OR p.description LIKE ?) ");
            String pattern = "%" + keyword.trim() + "%";
            params.add(pattern);
            params.add(pattern);
        }

        if (categoryIds != null && !categoryIds.isEmpty()) {
            sql.append(" AND p.category_id IN (");
            for (int i = 0; i < categoryIds.size(); i++) {
                sql.append("?");
                params.add(categoryIds.get(i));
                if (i < categoryIds.size() - 1) {
                    sql.append(",");
                }
            }
            sql.append(") ");
        }

        if (status != null && !status.isEmpty()) {
            if ("in_stock".equals(status)) {
                sql.append(" AND p.stock_quantity > 0 ");
            } else if ("out_of_stock".equals(status)) {
                sql.append(" AND p.stock_quantity <= 0 ");
            }
        }

        sql.append(" ORDER BY p.created_at DESC");

        try (PreparedStatement ps = getConnection().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                List<Product> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
                return list;
            }
        } catch (SQLException e) {
            System.err.println("[ProductDAO] filterProducts SQL error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ProductDAO.filterProducts error: " + e.getMessage(), e);
        }
    }
}
