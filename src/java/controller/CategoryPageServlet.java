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
            // DuyAnhNgo- Gọi CategoryDAO (hàm getAllActiveCategories) để tải toàn bộ danh sách Danh mục đang hoạt động (ví dụ: Trái cây cao cấp) hiển thị lên Header/Sidebar
            List<Category> categories = categoryDAO.getAllActiveCategories();
            req.setAttribute("categories", categories);

            // DuyAnhNgo- Kiểm tra xem người dùng có đang click vào một Danh mục cụ thể nào không (qua biến categoryId trên URL)
            String catIdParam = req.getParameter("categoryId");
            if (catIdParam != null && !catIdParam.trim().isEmpty()) {
                try {
                    int categoryId = Integer.parseInt(catIdParam.trim());
                    // DuyAnhNgo- Nếu có, gọi ProductDAO (cụ thể là hàm getProductsByCategoryId) để lấy toàn bộ danh sách sản phẩm thuộc đúng danh mục đó
                    List<Product> products = productDAO.getProductsByCategoryId(categoryId);
                    req.setAttribute("products", products);
                    req.setAttribute("selectedCategoryId", categoryId);

                    // DuyAnhNgo- Vòng lặp tìm Tên của danh mục đang được chọn (để in ra dòng chữ "Sản phẩm: Trái cây cao cấp" trên giao diện)
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

            // DuyAnhNgo- Đẩy toàn bộ dữ liệu danh mục & sản phẩm sang trang category-page.jsp để vẽ giao diện
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
