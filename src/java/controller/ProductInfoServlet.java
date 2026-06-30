//Duy Anh
package controller;

import dao.CategoryDAO;
import dao.ProductDAO;
import dao.ShopDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Category;
import model.Product;
import model.Shop;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ProductInfoServlet", urlPatterns = {"/info"})
public class ProductInfoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);

        String idParam = req.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID sản phẩm không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        ProductDAO productDAO = new ProductDAO();
        try {
            Product product = productDAO.getProductById(productId);

            if (product == null || product.isIsDelete()) {
                session.setAttribute("error", "Sản phẩm không tồn tại hoặc đã bị xóa.");
                resp.sendRedirect(req.getContextPath() + "/home.jsp");
                return;
            }

            // Load category name
            String categoryName = "-";
            try {
                CategoryDAO categoryDAO = new CategoryDAO();
                try {
                    List<Category> allCats = categoryDAO.getAllActiveCategories();
                    for (Category c : allCats) {
                        if (c.getId() == product.getCategoryId()) {
                            categoryName = c.getName();
                            break;
                        }
                    }
                } finally {
                    categoryDAO.close();
                }
            } catch (Exception ex) {
                System.err.println("[ProductInfoServlet] load category name failed: " + ex.getMessage());
            }

            // Load shop info
            Shop shopInfo = null;
            if (product.getShopId() > 0) {
                try {
                    ShopDAO shopDAO = new ShopDAO();
                    try {
                        shopInfo = shopDAO.getShopById(product.getShopId());
                    } finally {
                        shopDAO.close();
                    }
                } catch (Exception ex) {
                    System.err.println("[ProductInfoServlet] load shop info failed: " + ex.getMessage());
                }
            }

            req.setAttribute("product", product);
            req.setAttribute("categoryName", categoryName);
            if (shopInfo != null) {
                req.setAttribute("shopInfo", shopInfo);
            }

            req.getRequestDispatcher("/product-info.jsp").forward(req, resp);

        } catch (Exception e) {
            System.err.println("[ProductInfoServlet] error: " + e.getMessage());
            e.printStackTrace();
            if (session != null) {
                session.setAttribute("error", "Không thể tải chi tiết sản phẩm: " + e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
        } finally {
            productDAO.close();
        }
    }
}

