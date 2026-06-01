package service;

import dao.CategoryDAO;
import model.Category;
import java.util.List;

public class CategoryService {

    private final CategoryDAO dao = new CategoryDAO();

    public List<Category> getAllActiveCategories() {
        return dao.getAllActiveCategories();
    }

    public List<Category> getAll() {
        return dao.getAll();
    }

    public Category getById(int id) {
        return dao.findById(id);
    }

    public String addCategory(String name, String image) {
        if (name == null || name.trim().isEmpty()) {
            return "Ten danh muc khong duoc de trong.";
        }
        Category c = new Category();
        c.setName(name.trim());
        c.setImage(image);
        boolean ok = dao.insert(c);
        return ok ? null : "Them danh muc that bai. Vui long thu lai.";
    }

    public String updateCategory(int id, String name, String image) {
        if (name == null || name.trim().isEmpty()) {
            return "Ten danh muc khong duoc de trong.";
        }
        Category existing = dao.findById(id);
        if (existing == null) {
            return "Khong tim thay danh muc.";
        }
        existing.setName(name.trim());
        existing.setImage(image);
        boolean ok = dao.update(existing);
        return ok ? null : "Cap nhat danh muc that bai. Vui long thu lai.";
    }

    public String deleteCategory(int id) {
        Category existing = dao.findById(id);
        if (existing == null) {
            return "Khong tim thay danh muc.";
        }
        boolean ok = dao.delete(id);
        return ok ? null : "Xoa danh muc that bai. Vui long thu lai.";
    }
}
