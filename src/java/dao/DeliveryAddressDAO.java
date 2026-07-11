package dao;

import Utils.DbContext;
import model.DeliveryAddress;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DeliveryAddressDAO - Handles all DB operations for DeliveryAddresses table.
 */
public class DeliveryAddressDAO extends DbContext {

    /**
     * Get all addresses for a user.
     * Auto-creates the table if it doesn't exist (backward compatible).
     * @param customerId
     * @return 
     */
    public List<DeliveryAddress> findByCustomerId(int customerId) {
        ensureTableExists();
        List<DeliveryAddress> list = new ArrayList<>();
        String sql = "SELECT id, customer_id, recipient_name, recipient_phone, address, note, isDefault, created_at "
                   + "FROM DeliveryAddresses WHERE customer_id = ? ORDER BY isDefault DESC, created_at DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("DeliveryAddressDAO.findByCustomerId error: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Ensure the DeliveryAddresses table exists in the database.
     * Creates the table if it doesn't exist (backward compatible).
     */
    private void ensureTableExists() {
        try {
            DatabaseMetaData meta = getConnection().getMetaData();
            try (ResultSet tables = meta.getTables(null, null, "DeliveryAddresses", null)) {
                if (!tables.next()) {
                    String createSql = "CREATE TABLE DeliveryAddresses ("
                        + "id INT IDENTITY(1,1) PRIMARY KEY, "
                        + "customer_id INT NOT NULL, "
                        + "recipient_name NVARCHAR(100) NOT NULL, "
                        + "recipient_phone NVARCHAR(20) NOT NULL, "
                        + "address NVARCHAR(500) NOT NULL, "
                        + "note NVARCHAR(500) NULL, "
                        + "isDefault BIT DEFAULT 0, "
                        + "created_at DATETIME DEFAULT GETDATE())";
                    try (Statement st = getConnection().createStatement()) {
                        st.execute(createSql);
                        System.out.println("[DeliveryAddressDAO] Created DeliveryAddresses table");
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[DeliveryAddressDAO] ensureTableExists warning: " + e.getMessage());
        }
    }

    /**
     * Find a single address by id and user id (ownership check).
     * @param id
     * @param customerId
     * @return 
     */
    public DeliveryAddress findByIdAndUser(int id, int customerId) {
        ensureTableExists();
        String sql = "SELECT id, customer_id, recipient_name, recipient_phone, address, note, isDefault, created_at "
                   + "FROM DeliveryAddresses WHERE id = ? AND customer_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("DeliveryAddressDAO.findByIdAndUser error: " + e.getMessage(), e);
        }
        return null;
    }

    /**
     * Insert a new address.
     * @param da
     * @return 
     */
    public boolean insert(DeliveryAddress da) {
        ensureTableExists();
        String sql = "INSERT INTO DeliveryAddresses (customer_id, recipient_name, recipient_phone, address, note, isDefault) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, da.getCustomerId());
            ps.setString(2, da.getRecipientName());
            ps.setString(3, da.getRecipientPhone());
            ps.setString(4, da.getAddress());
            ps.setString(5, da.getNote());
            ps.setBoolean(6, da.isIsDefault());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("DeliveryAddressDAO.insert error: " + e.getMessage(), e);
        }
    }

    /**
     * Update an existing address.
     * @param da
     * @return 
     */
    public boolean update(DeliveryAddress da) {
        ensureTableExists();
        String sql = "UPDATE DeliveryAddresses SET recipient_name = ?, recipient_phone = ?, address = ?, note = ?, isDefault = ? "
                   + "WHERE id = ? AND customer_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, da.getRecipientName());
            ps.setString(2, da.getRecipientPhone());
            ps.setString(3, da.getAddress());
            ps.setString(4, da.getNote());
            ps.setBoolean(5, da.isIsDefault());
            ps.setInt(6, da.getId());
            ps.setInt(7, da.getCustomerId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("DeliveryAddressDAO.update error: " + e.getMessage(), e);
        }
    }

    /**
     * Delete an address.
     * @param id
     * @param customerId
     * @return 
     */
    
    public boolean delete(int id, int customerId) {
        ensureTableExists();
        String sql = "DELETE FROM DeliveryAddresses WHERE id = ? AND customer_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, customerId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("DeliveryAddressDAO.delete error: " + e.getMessage(), e);
        }
    }

    /**
     * Unset all default addresses for a user, then set the given one as default.
     * @param id
     * @param customerId
     * @return 
     */
    public boolean setDefault(int id, int customerId) {
        ensureTableExists();
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            String clearSql = "UPDATE DeliveryAddresses SET isDefault = 0 WHERE customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(clearSql)) {
                ps.setInt(1, customerId);
                ps.executeUpdate();
            }
            String setSql = "UPDATE DeliveryAddresses SET isDefault = 1 WHERE id = ? AND customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(setSql)) {
                ps.setInt(1, id);
                ps.setInt(2, customerId);
                int rows = ps.executeUpdate();
                conn.commit();
                return rows > 0;
            }
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) { /* ignore */ }
            throw new RuntimeException("DeliveryAddressDAO.setDefault error: " + e.getMessage(), e);
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { /* ignore */ }
            }
        }
    }

    // ---- helper ----
    private DeliveryAddress mapRow(ResultSet rs) throws SQLException {
        DeliveryAddress da = new DeliveryAddress();
        da.setId(rs.getInt("id"));
        da.setCustomerId(rs.getInt("customer_id"));
        da.setRecipientName(rs.getString("recipient_name"));
        da.setRecipientPhone(rs.getString("recipient_phone"));
        da.setAddress(rs.getString("address"));
        da.setNote(rs.getString("note"));
        da.setIsDefault(rs.getBoolean("isDefault"));
        da.setCreatedAt(rs.getTimestamp("created_at"));
        return da;
    }
}
