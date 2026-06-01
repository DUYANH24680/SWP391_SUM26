package controller;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import model.Product;

@WebServlet(name = "ProductServlet", urlPatterns = {"/products"})
public class ProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        ProductDAO productDAO = null;
        try {
            productDAO = new ProductDAO();
            List<Product> products;
            String keyword = req.getParameter("search");

            if (keyword != null && !keyword.trim().isEmpty()) {
                products = productDAO.searchProducts(keyword.trim());
            } else {
                products = productDAO.getAllProducts();
            }

            req.setAttribute("products", products);
            if (keyword != null) {
                req.setAttribute("searchKeyword", keyword.trim());
            }
        } catch (Exception e) {
            req.setAttribute("error", "Lỗi khi tải danh sách sản phẩm: " + e.getMessage());
        } finally {
            if (productDAO != null) {
                productDAO.close();
            }
        }

        req.getRequestDispatcher("/products.jsp").forward(req, resp);
    }
}
