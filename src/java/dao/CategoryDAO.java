package dao;

import model.Category;
import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO extends DbContext {

    public List<Category> getAllCategories(boolean includeDeleted) {
        System.out.println("[CategoryDAO] getAllCategories(includeDeleted=" + includeDeleted + ") called");

        String sql = includeDeleted
                ? "SELECT id, name, image, isDelete FROM Categories ORDER BY name ASC"
                : "SELECT id, name, image, isDelete FROM Categories WHERE isDelete = 0 ORDER BY name ASC";

        List<Category> list = new ArrayList<>();

        try (PreparedStatement ps = getConnection().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }

            System.out.println("[CategoryDAO] getAllCategories returned " + list.size() + " categories");
            return list;

        } catch (SQLException e) {
            System.err.println("[CategoryDAO] getAllCategories() error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("CategoryDAO.getAllCategories error: " + e.getMessage(), e);
        }
    }

    public List<Category> getAllActiveCategories() {
        return getAllCategories(false);
    }

    public Category getCategoryById(int id) {
        System.out.println("[CategoryDAO] getCategoryById(id=" + id + ") called");

        String sql = "SELECT id, name, image, isDelete FROM Categories WHERE id = ?";

        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    System.out.println("[CategoryDAO] getCategoryById(" + id + ") found");
                    return mapRow(rs);
                }
            }

            System.out.println("[CategoryDAO] getCategoryById(" + id + ") — not found");
            return null;

        } catch (SQLException e) {
            System.err.println("[CategoryDAO] getCategoryById(" + id + ") error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("CategoryDAO.getCategoryById error: " + e.getMessage(), e);
        }
    }

    public boolean createCategory(String name, String image) {
        System.out.println("[CategoryDAO] createCategory(name=" + name + ") called");

        String sql = "INSERT INTO Categories (name, image, isDelete) VALUES (?, ?, 0)";

        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, name);
            if (image != null && !image.isEmpty()) {
                ps.setString(2, image);
            } else {
                ps.setNull(2, Types.VARCHAR);
            }

            int rowsInserted = ps.executeUpdate();
            if (rowsInserted > 0) {
                System.out.println("[CategoryDAO] createCategory success: " + name);
                return true;
            }
            System.out.println("[CategoryDAO] createCategory failed: no rows inserted");
            return false;

        } catch (SQLException e) {
            System.err.println("[CategoryDAO] createCategory() error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("CategoryDAO.createCategory error: " + e.getMessage(), e);
        }
    }

    public boolean updateCategory(int id, String name, String image) {
        System.out.println("[CategoryDAO] updateCategory(id=" + id + ", name=" + name + ") called");

        String sql = "UPDATE Categories SET name = ?, image = ? WHERE id = ? AND isDelete = 0";

        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, name);
            if (image != null && !image.isEmpty()) {
                ps.setString(2, image);
            } else {
                ps.setNull(2, Types.VARCHAR);
            }
            ps.setInt(3, id);

            int rowsUpdated = ps.executeUpdate();
            if (rowsUpdated > 0) {
                System.out.println("[CategoryDAO] updateCategory(" + id + ") success");
            } else {
                System.out.println("[CategoryDAO] updateCategory(" + id + ") — category not found or already deleted");
            }
            return rowsUpdated > 0;

        } catch (SQLException e) {
            System.err.println("[CategoryDAO] updateCategory(" + id + ") error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("CategoryDAO.updateCategory error: " + e.getMessage(), e);
        }
    }

    public boolean softDeleteCategory(int id) {
        System.out.println("[CategoryDAO] softDeleteCategory(id=" + id + ") called");

        String sql = "UPDATE Categories SET isDelete = 1 WHERE id = ? AND isDelete = 0";

        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, id);

            int rowsUpdated = ps.executeUpdate();
            if (rowsUpdated > 0) {
                System.out.println("[CategoryDAO] softDeleteCategory(" + id + ") success");
            } else {
                System.out.println("[CategoryDAO] softDeleteCategory(" + id + ") — category not found or already deleted");
            }
            return rowsUpdated > 0;

        } catch (SQLException e) {
            System.err.println("[CategoryDAO] softDeleteCategory(" + id + ") error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("CategoryDAO.softDeleteCategory error: " + e.getMessage(), e);
        }
    }

    public boolean isNameExists(String name, int excludeId) {
        System.out.println("[CategoryDAO] isNameExists(name=" + name + ", excludeId=" + excludeId + ") called");

        String sql = "SELECT COUNT(*) FROM Categories WHERE name = ? AND id != ? AND isDelete = 0";

        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setInt(2, excludeId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    boolean exists = count > 0;
                    System.out.println("[CategoryDAO] isNameExists(" + name + ") = " + exists);
                    return exists;
                }
            }

            return false;

        } catch (SQLException e) {
            System.err.println("[CategoryDAO] isNameExists() error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("CategoryDAO.isNameExists error: " + e.getMessage(), e);
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
