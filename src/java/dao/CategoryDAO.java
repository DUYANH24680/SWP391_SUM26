package dao;

import model.Category;
import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO extends Utils.DbContext {

    public List<Category> getAllActiveCategories() {
        System.out.println("[CategoryDAO] getAllActiveCategories() called");

        List<Category> list = new ArrayList<>();
        String sql = "SELECT id, name, image, isDelete FROM Categories WHERE isDelete = 0 ORDER BY name ASC";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            System.out.println("[CategoryDAO] Query executed, collecting results...");

            while (rs.next()) {
                Category c = new Category();
                c.setId(rs.getInt("id"));
                c.setName(rs.getString("name"));
                c.setImage(rs.getString("image"));
                c.setIsDelete(rs.getBoolean("isDelete"));
                list.add(c);
                System.out.println("[CategoryDAO] Loaded category: id=" + c.getId() + ", name=" + c.getName());
            }

            System.out.println("[CategoryDAO] Total categories loaded: " + list.size());
            return list;

        } catch (SQLException e) {
            System.err.println("[CategoryDAO] ERROR executing query: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("CategoryDAO.getAllActiveCategories error: " + e.getMessage(), e);
        }
    }
}
