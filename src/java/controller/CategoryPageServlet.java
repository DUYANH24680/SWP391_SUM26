package controller;

import dao.CategoryDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Category;
import model.Product;

import java.io.IOException;
import java.util.List;

/**
 * Public page: hiển thị danh sách danh mục và sản phẩm theo danh mục đã chọn.
 * URL: /danh-muc
 */
@WebServlet(name = "CategoryPageServlet", urlPatterns = {"/danh-muc"})
public class CategoryPageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        CategoryDAO categoryDAO = new CategoryDAO();
        ProductDAO productDAO = new ProductDAO();

        try {
            // Load all active categories
            List<Category> categories = categoryDAO.getAllActiveCategories();
            req.setAttribute("categories", categories);

            // If a category is selected, load its products
            String catIdParam = req.getParameter("categoryId");
            if (catIdParam != null && !catIdParam.trim().isEmpty()) {
                try {
                    int categoryId = Integer.parseInt(catIdParam.trim());
                    List<Product> products = productDAO.getProductsByCategoryId(categoryId);
                    req.setAttribute("products", products);
                    req.setAttribute("selectedCategoryId", categoryId);

                    // Find the selected category name
                    for (Category c : categories) {
                        if (c.getId() == categoryId) {
                            req.setAttribute("selectedCategoryName", c.getName());
                            break;
                        }
                    }
                } catch (NumberFormatException e) {
                    req.setAttribute("error", "ID danh mục không hợp lệ.");
                }
            }

            req.getRequestDispatcher("/category-page.jsp").forward(req, resp);

        } catch (Exception e) {
            System.err.println("[CategoryPageServlet] Error: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "Lỗi khi tải dữ liệu: " + e.getMessage());
            req.setAttribute("categories", java.util.Collections.emptyList());
            req.getRequestDispatcher("/category-page.jsp").forward(req, resp);
        }
    }
}
