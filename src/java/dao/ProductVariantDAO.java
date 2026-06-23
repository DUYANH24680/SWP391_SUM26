package dao;

import model.ProductVariant;
import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for ProductVariant (Weight Variants).
 *
 * SQL table reference:
 * CREATE TABLE ProductVariants (
 *     id          INT IDENTITY(1,1) PRIMARY KEY,
 *     product_id  INT NOT NULL,
 *     weight      NVARCHAR(50) NOT NULL,   -- e.g. '500g', '1kg', '2kg'
 *     price       DECIMAL(18,2) NOT NULL,
 *     stock_quantity INT NOT NULL DEFAULT 0,
 *     isDelete    BIT NOT NULL DEFAULT 0,
 *     created_at  DATETIME DEFAULT GETDATE(),
 *     FOREIGN KEY (product_id) REFERENCES Products(id)
 * );
 */
public class ProductVariantDAO extends DbContext {

    /**
     * Xoa tat ca cac variant cua san pham roi them lai danh sach moi.
     * Dung transaction de dam bao tinh toan ven.
     */
    public void insertVariants(int productId, List<ProductVariant> variants) {
        if (variants == null || variants.isEmpty()) {
            return;
        }

        String sqlDelete = "DELETE FROM ProductVariants WHERE product_id = ?";
        String sqlInsert = "INSERT INTO ProductVariants (product_id, weight, price, stock_quantity, isDelete, created_at) "
                         + "VALUES (?, ?, ?, ?, 0, GETDATE())";

        Connection conn = null;
        PreparedStatement psDelete = null;
        PreparedStatement psInsert = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            psDelete = conn.prepareStatement(sqlDelete);
            psDelete.setInt(1, productId);
            psDelete.executeUpdate();

            psInsert = conn.prepareStatement(sqlInsert);
            for (ProductVariant v : variants) {
                psInsert.setInt(1, productId);
                psInsert.setString(2, v.getWeight());
                psInsert.setDouble(3, v.getPrice());
                psInsert.setInt(4, v.getStockQuantity());
                psInsert.addBatch();
            }
            psInsert.executeBatch();

            conn.commit();
            System.out.println("[ProductVariantDAO] insertVariants(productId=" + productId
                + ") inserted " + variants.size() + " variants");

        } catch (SQLException e) {
            System.err.println("[ProductVariantDAO] insertVariants(" + productId + ") error: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { }
            }
            throw new RuntimeException("ProductVariantDAO.insertVariants error: " + e.getMessage(), e);
        } finally {
            if (psDelete != null) try { psDelete.close(); } catch (SQLException ignored) {}
            if (psInsert != null) try { psInsert.close(); } catch (SQLException ignored) {}
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ignored) {}
            }
        }
    }

    /**
     * Lay tat ca cac variant (weight) cua mot san pham.
     */
    public List<ProductVariant> getVariantsByProductId(int productId) {
        String sql = "SELECT id, product_id, weight, price, stock_quantity, isDelete, created_at "
                   + "FROM ProductVariants WHERE product_id = ? AND isDelete = 0 "
                   + "ORDER BY id ASC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                List<ProductVariant> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
                System.out.println("[ProductVariantDAO] getVariantsByProductId(" + productId
                    + ") returned " + list.size() + " variants");
                return list;
            }
        } catch (SQLException e) {
            System.err.println("[ProductVariantDAO] getVariantsByProductId(" + productId
                + ") error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ProductVariantDAO.getVariantsByProductId error: " + e.getMessage(), e);
        }
    }

    /**
     * Cap nhat so luong ton kho cho mot variant cu the.
     */
    public boolean updateVariantStock(int variantId, int newStock) {
        String sql = "UPDATE ProductVariants SET stock_quantity = ? WHERE id = ? AND isDelete = 0";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, newStock);
            ps.setInt(2, variantId);
            int rowsUpdated = ps.executeUpdate();
            if (rowsUpdated > 0) {
                System.out.println("[ProductVariantDAO] updateVariantStock(variantId=" + variantId
                    + ", newStock=" + newStock + ") success");
            }
            return rowsUpdated > 0;
        } catch (SQLException e) {
            System.err.println("[ProductVariantDAO] updateVariantStock(" + variantId + ") error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ProductVariantDAO.updateVariantStock error: " + e.getMessage(), e);
        }
    }

    /**
     * Xoa (soft delete) tat ca cac variant cua mot san pham.
     */
    public boolean deleteVariantsByProductId(int productId) {
        String sql = "UPDATE ProductVariants SET isDelete = 1 WHERE product_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, productId);
            int rowsUpdated = ps.executeUpdate();
            System.out.println("[ProductVariantDAO] deleteVariantsByProductId(" + productId
                + ") soft-deleted " + rowsUpdated + " variants");
            return rowsUpdated >= 0;
        } catch (SQLException e) {
            System.err.println("[ProductVariantDAO] deleteVariantsByProductId(" + productId
                + ") error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("ProductVariantDAO.deleteVariantsByProductId error: " + e.getMessage(), e);
        }
    }

    private ProductVariant mapRow(ResultSet rs) throws SQLException {
        ProductVariant v = new ProductVariant();
        v.setId(rs.getInt("id"));
        v.setProductId(rs.getInt("product_id"));
        v.setWeight(rs.getString("weight"));
        v.setPrice(rs.getDouble("price"));
        v.setStockQuantity(rs.getInt("stock_quantity"));
        v.setIsDelete(rs.getBoolean("isDelete"));
        v.setCreatedAt(rs.getTimestamp("created_at"));
        return v;
    }
}
