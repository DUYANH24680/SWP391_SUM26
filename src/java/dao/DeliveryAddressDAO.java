package dao;

import Utils.DbContext;
import model.DeliveryAddress;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DeliveryAddressDAO {

    public List<DeliveryAddress> findByCustomerId(int customerId) {
        List<DeliveryAddress> list = new ArrayList<>();
        String sql = "SELECT id, customer_id, recipient_name, recipient_phone, address, note, isDefault, created_at "
                   + "FROM DeliveryAddresses WHERE customer_id = ? ORDER BY isDefault DESC, created_at DESC";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
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

    public DeliveryAddress findByIdAndCustomer(int id, int customerId) {
        String sql = "SELECT id, customer_id, recipient_name, recipient_phone, address, note, isDefault, created_at "
                   + "FROM DeliveryAddresses WHERE id = ? AND customer_id = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("DeliveryAddressDAO.findByIdAndCustomer error: " + e.getMessage(), e);
        }
        return null;
    }

    public boolean insert(DeliveryAddress da) {
        String sql = "INSERT INTO DeliveryAddresses (customer_id, recipient_name, recipient_phone, address, note, isDefault) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
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

    public boolean update(DeliveryAddress da) {
        String sql = "UPDATE DeliveryAddresses SET recipient_name = ?, recipient_phone = ?, address = ?, note = ?, isDefault = ? "
                   + "WHERE id = ? AND customer_id = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
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

    public boolean delete(int id, int customerId) {
        String sql = "DELETE FROM DeliveryAddresses WHERE id = ? AND customer_id = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, customerId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("DeliveryAddressDAO.delete error: " + e.getMessage(), e);
        }
    }

    public boolean setDefault(int id, int customerId) {
        String clearSql = "UPDATE DeliveryAddresses SET isDefault = 0 WHERE customer_id = ?";
        String setSql = "UPDATE DeliveryAddresses SET isDefault = 1 WHERE id = ? AND customer_id = ?";

        try (Connection conn = DbContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(clearSql)) {
                    ps.setInt(1, customerId);
                    ps.executeUpdate();
                }
                int rows;
                try (PreparedStatement ps = conn.prepareStatement(setSql)) {
                    ps.setInt(1, id);
                    ps.setInt(2, customerId);
                    rows = ps.executeUpdate();
                }
                conn.commit();
                return rows > 0;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new RuntimeException("DeliveryAddressDAO.setDefault error: " + e.getMessage(), e);
        }
    }

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
