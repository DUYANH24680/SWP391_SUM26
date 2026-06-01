package dao;

import Utils.DbContext;
import model.Seller;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SellerDAO {

    public List<Seller> getAll() {
        List<Seller> list = new ArrayList<>();
        String sql = "SELECT a.id, a.role_id, a.fullname, a.username, a.password_hash, a.email, "
                   + "a.phone, a.address, a.avatar, a.gender, a.status, a.created_at "
                   + "FROM Accounts a WHERE a.role_id = 2";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("SellerDAO.getAll error: " + e.getMessage(), e);
        }
        return list;
    }

    public Seller findById(int id) {
        String sql = "SELECT a.id, a.role_id, a.fullname, a.username, a.password_hash, a.email, "
                   + "a.phone, a.address, a.avatar, a.gender, a.status, a.created_at "
                   + "FROM Accounts a WHERE a.id = ? AND a.role_id = 2";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("SellerDAO.findById error: " + e.getMessage(), e);
        }
        return null;
    }

    public boolean updateProfile(int id, String fullname, String email, String phone,
                                String address, Boolean gender, String avatar) {
        String sql = "UPDATE Accounts SET fullname = ?, email = ?, phone = ?, address = ?, "
                   + "gender = ?, avatar = ? WHERE id = ? AND role_id = 2";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullname);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, address);
            if (gender != null) {
                ps.setBoolean(5, gender);
            } else {
                ps.setNull(5, Types.BIT);
            }
            ps.setString(6, avatar);
            ps.setInt(7, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("SellerDAO.updateProfile error: " + e.getMessage(), e);
        }
    }

    public boolean updatePassword(int id, String newPasswordHash) {
        String sql = "UPDATE Accounts SET password_hash = ? WHERE id = ? AND role_id = 2";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("SellerDAO.updatePassword error: " + e.getMessage(), e);
        }
    }

    public boolean updateStatus(int id, int status) {
        String sql = "UPDATE Accounts SET status = ? WHERE id = ? AND role_id = 2";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("SellerDAO.updateStatus error: " + e.getMessage(), e);
        }
    }

    private Seller mapRow(ResultSet rs) throws SQLException {
        Seller s = new Seller();
        s.setId(rs.getInt("id"));
        s.setRoleId(rs.getInt("role_id"));
        s.setFullname(rs.getString("fullname"));
        s.setUsername(rs.getString("username"));
        s.setPasswordHash(rs.getString("password_hash"));
        s.setEmail(rs.getString("email"));
        s.setPhone(rs.getString("phone"));
        s.setAddress(rs.getString("address"));
        s.setAvatar(rs.getString("avatar"));
        boolean genderBit = rs.getBoolean("gender");
        s.setGender(rs.wasNull() ? null : genderBit);
        s.setStatus(rs.getInt("status"));
        s.setCreatedAt(rs.getTimestamp("created_at"));
        return s;
    }
}
