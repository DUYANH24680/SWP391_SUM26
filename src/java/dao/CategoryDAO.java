package dao;

import Utils.DbContext;
import model.Category;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {

    public List<Category> getAllActiveCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT id, name, image, isDelete FROM Categories WHERE isDelete = 0";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("CategoryDAO.getAllActiveCategories error: " + e.getMessage(), e);
        }
        return list;
    }

    public List<Category> getAll() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT id, name, image, isDelete FROM Categories";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("CategoryDAO.getAll error: " + e.getMessage(), e);
        }
        return list;
    }

    public Category findById(int id) {
        String sql = "SELECT id, name, image, isDelete FROM Categories WHERE id = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("CategoryDAO.findById error: " + e.getMessage(), e);
        }
        return null;
    }

    public boolean insert(Category category) {
        String sql = "INSERT INTO Categories (name, image) VALUES (?, ?)";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category.getName());
            ps.setString(2, category.getImage());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("CategoryDAO.insert error: " + e.getMessage(), e);
        }
    }

    public boolean update(Category category) {
        String sql = "UPDATE Categories SET name = ?, image = ? WHERE id = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category.getName());
            ps.setString(2, category.getImage());
            ps.setInt(3, category.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("CategoryDAO.update error: " + e.getMessage(), e);
        }
    }

    public boolean delete(int id) {
        String sql = "UPDATE Categories SET isDelete = 1 WHERE id = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("CategoryDAO.delete error: " + e.getMessage(), e);
        }
    }

    private Category mapRow(ResultSet rs) throws SQLException {
        Category c = new Category();
        c.setId(rs.getInt("id"));
        c.setName(rs.getString("name"));
        c.setImage(rs.getString("image"));
        c.setIsDelete(rs.getBoolean("isDelete"));
        return c;
    }
}
