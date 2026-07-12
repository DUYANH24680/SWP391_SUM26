package dao;

import model.Voucher;
import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VoucherDAO extends DbContext {

    // Hàm kiểm tra và tự động khởi tạo bảng nếu chưa có
    private void ensureTableExists() {
        try {
            DatabaseMetaData meta = getConnection().getMetaData();
            try (ResultSet tables = meta.getTables(null, null, "Vouchers", null)) {
                if (!tables.next()) {
                    // Nếu bảng Vouchers chưa tồn tại, tạo mới
                    String createSql = "CREATE TABLE Vouchers ("
                        + "id INT IDENTITY(1,1) PRIMARY KEY, "
                        + "shop_id INT NULL, "
                        + "code NVARCHAR(50) NOT NULL UNIQUE, "
                        + "type VARCHAR(20) DEFAULT 'DISCOUNT', "
                        + "discount_percent FLOAT DEFAULT 0, "
                        + "max_discount FLOAT DEFAULT 0, "
                        + "minimum_order FLOAT DEFAULT 0, "
                        + "start_date DATETIME NULL, "
                        + "end_date DATETIME NULL, "
                        + "quantity INT DEFAULT 0, "
                        + "used_count INT DEFAULT 0, "
                        + "max_usages_per_user INT DEFAULT 3, "
                        + "status BIT DEFAULT 1)";
                    try (Statement st = getConnection().createStatement()) {
                        st.execute(createSql);
                        System.out.println("[VoucherDAO] Created Vouchers table");
                    }
                } else {
                    // Nếu bảng Vouchers đã tồn tại, kiểm tra và thêm các cột mới cho hệ thống cập nhật (nếu thiếu)
                    try (Statement st = getConnection().createStatement()) {
                        st.execute("IF COL_LENGTH('Vouchers', 'shop_id') IS NULL ALTER TABLE Vouchers ADD shop_id INT NULL;");
                        st.execute("IF COL_LENGTH('Vouchers', 'type') IS NULL ALTER TABLE Vouchers ADD type VARCHAR(20) DEFAULT 'DISCOUNT';");
                        st.execute("IF COL_LENGTH('Vouchers', 'max_usages_per_user') IS NULL ALTER TABLE Vouchers ADD max_usages_per_user INT DEFAULT 3;");
                    } catch (SQLException e) {
                        System.err.println("[VoucherDAO] Error altering Vouchers table: " + e.getMessage());
                    }
                }
            }

            // Đảm bảo bảng theo dõi lượt sử dụng của từng user (UserVouchers) tồn tại
            try (ResultSet tables = meta.getTables(null, null, "UserVouchers", null)) {
                if (!tables.next()) {
                    String createSql = "CREATE TABLE UserVouchers ("
                        + "id INT IDENTITY(1,1) PRIMARY KEY, "
                        + "user_id INT NOT NULL, "
                        + "voucher_id INT NOT NULL, "
                        + "usage_count INT DEFAULT 0)";
                    try (Statement st = getConnection().createStatement()) {
                        st.execute(createSql);
                        System.out.println("[VoucherDAO] Created UserVouchers table");
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[VoucherDAO] ensureTableExists warning: " + e.getMessage());
        }
    }

    public void insertVoucher(Voucher v) {
        ensureTableExists();
        String sql = "INSERT INTO Vouchers (shop_id, code, type, discount_percent, max_discount, minimum_order, start_date, end_date, quantity, used_count, max_usages_per_user, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            if (v.getShopId() != null) {
                ps.setInt(1, v.getShopId());
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setString(2, v.getCode());
            ps.setString(3, v.getType());
            ps.setDouble(4, v.getDiscountPercent());
            ps.setDouble(5, v.getMaxDiscount());
            ps.setDouble(6, v.getMinimumOrder());
            ps.setTimestamp(7, v.getStartDate());
            ps.setTimestamp(8, v.getEndDate());
            ps.setInt(9, v.getQuantity());
            ps.setInt(10, v.getUsedCount());
            ps.setInt(11, v.getMaxUsagesPerUser());
            ps.setBoolean(12, v.isStatus());
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[VoucherDAO] insertVoucher error: " + e.getMessage());
            throw new RuntimeException(e);
        }
    }

    public void updateVoucher(Voucher v) {
        ensureTableExists();
        String sql = "UPDATE Vouchers SET shop_id=?, code=?, type=?, discount_percent=?, max_discount=?, minimum_order=?, start_date=?, end_date=?, quantity=?, used_count=?, max_usages_per_user=?, status=? "
                   + "WHERE id=?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            if (v.getShopId() != null) {
                ps.setInt(1, v.getShopId());
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setString(2, v.getCode());
            ps.setString(3, v.getType());
            ps.setDouble(4, v.getDiscountPercent());
            ps.setDouble(5, v.getMaxDiscount());
            ps.setDouble(6, v.getMinimumOrder());
            ps.setTimestamp(7, v.getStartDate());
            ps.setTimestamp(8, v.getEndDate());
            ps.setInt(9, v.getQuantity());
            ps.setInt(10, v.getUsedCount());
            ps.setInt(11, v.getMaxUsagesPerUser());
            ps.setBoolean(12, v.isStatus());
            ps.setInt(13, v.getId());
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[VoucherDAO] updateVoucher error: " + e.getMessage());
            throw new RuntimeException(e);
        }
    }

    public void deleteVoucher(int id) {
        ensureTableExists();
        String sql = "DELETE FROM Vouchers WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public Voucher findByCode(String code) {
        if (code == null || code.trim().isEmpty()) return null;
        ensureTableExists();
        
        String sql = "SELECT * FROM Vouchers WHERE code = ?";
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
    
    public Voucher getVoucherById(int id) {
        ensureTableExists();
        String sql = "SELECT * FROM Vouchers WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return null;
    }

    // Lấy tất cả voucher có thể dùng được (Trạng thái = 1, Số lượng > Đã Dùng, Đang trong hạn)
    public List<Voucher> getAllActiveVouchers() {
        ensureTableExists();
        List<Voucher> list = new ArrayList<>();
        String sql = "SELECT * FROM Vouchers "
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

    // Lấy voucher chung của toàn hệ thống (Dành cho Admin)
    public List<Voucher> getGlobalVouchers() {
        ensureTableExists();
        List<Voucher> list = new ArrayList<>();
        String sql = "SELECT * FROM Vouchers WHERE shop_id IS NULL ORDER BY id DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return list;
    }

    // Lấy voucher riêng của một Shop (Dành cho Seller)
    public List<Voucher> getVouchersByShop(int shopId) {
        ensureTableExists();
        List<Voucher> list = new ArrayList<>();
        String sql = "SELECT * FROM Vouchers WHERE shop_id = ? ORDER BY id DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return list;
    }

    private Voucher mapRow(ResultSet rs) throws SQLException {
        Voucher v = new Voucher();
        v.setId(rs.getInt("id"));
        int shopId = rs.getInt("shop_id");
        if (!rs.wasNull()) {
            v.setShopId(shopId);
        }
        v.setCode(rs.getString("code"));
        v.setType(rs.getString("type"));
        v.setDiscountPercent(rs.getDouble("discount_percent"));
        v.setMaxDiscount(rs.getDouble("max_discount"));
        v.setMinimumOrder(rs.getDouble("minimum_order"));
        v.setStartDate(rs.getTimestamp("start_date"));
        v.setEndDate(rs.getTimestamp("end_date"));
        v.setQuantity(rs.getInt("quantity"));
        v.setUsedCount(rs.getInt("used_count"));
        v.setMaxUsagesPerUser(rs.getInt("max_usages_per_user"));
        v.setStatus(rs.getBoolean("status"));
        return v;
    }

    // Cập nhật tăng số lượt dùng chung của một Voucher (Bảng Vouchers)
    public void incrementUsedCount(int voucherId) {
        if (voucherId <= 0) return;
        String sql = "UPDATE Vouchers SET used_count = used_count + 1 WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, voucherId);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[VoucherDAO] incrementUsedCount error: " + e.getMessage());
            throw new RuntimeException("VoucherDAO.incrementUsedCount error: " + e.getMessage(), e);
        }
    }

    // Hoàn trả lại lượt dùng khi đơn hàng bị hủy
    public void decrementUsedCount(int voucherId) {
        if (voucherId <= 0) return;
        String sql = "UPDATE Vouchers SET used_count = CASE WHEN used_count > 0 THEN used_count - 1 ELSE 0 END WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, voucherId);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[VoucherDAO] decrementUsedCount error: " + e.getMessage());
            throw new RuntimeException("VoucherDAO.decrementUsedCount error: " + e.getMessage(), e);
        }
    }
    
    // --- Bảng theo dõi số lượt dùng của Từng User (UserVouchers) ---
    
    // Kiểm tra số lượt mà User A đã sử dụng cho Voucher B
    public int getUserUsageCount(int userId, int voucherId) {
        ensureTableExists();
        String sql = "SELECT usage_count FROM UserVouchers WHERE user_id = ? AND voucher_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, voucherId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("usage_count");
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return 0;
    }
    
    // Tăng số lượt dùng của 1 user (gọi sau khi thanh toán thành công)
    public void incrementUserUsage(int userId, int voucherId) {
        ensureTableExists();
        int currentUsage = getUserUsageCount(userId, voucherId);
        if (currentUsage == 0) {
            // Chưa dùng bao giờ -> Insert
            String sql = "INSERT INTO UserVouchers (user_id, voucher_id, usage_count) VALUES (?, ?, 1)";
            try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, voucherId);
                ps.executeUpdate();
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        } else {
            // Đã từng dùng -> Update cộng lên 1
            String sql = "UPDATE UserVouchers SET usage_count = usage_count + 1 WHERE user_id = ? AND voucher_id = ?";
            try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, voucherId);
                ps.executeUpdate();
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        }
    }
}
