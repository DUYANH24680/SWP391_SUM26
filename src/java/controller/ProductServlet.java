package controller;

import dao.ProductDAO;
import dao.ShopDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Product;
import model.Shop;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "ProductServlet", urlPatterns = {"/products"})
public class ProductServlet extends HttpServlet {

    private static final String ROLE_SELLER = "seller";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("addProductForm".equals(action) || "add-product".equals(action)) {
            resp.sendRedirect(req.getContextPath() + "/add-product");
            return;
        }

        HttpSession session = req.getSession(false);
        String role = (session != null) ? (String) session.getAttribute("role") : null;
        String keyword = req.getParameter("search");

        List<Product> products = loadProducts(role, session, keyword);

        req.setAttribute("products", products);
        if (keyword != null) {
            req.setAttribute("searchKeyword", keyword.trim());
        }

        req.getRequestDispatcher("/products.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/products");
    }

    // Tai san pham theo role: seller -> cua shop minh, customer/chua login -> tat ca
    private List<Product> loadProducts(String role, HttpSession session, String keyword) {
        try {
            if (ROLE_SELLER.equals(role)) {
                return loadSellerProducts(session, keyword);
            }
            return loadCustomerProducts(keyword);
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }

    private List<Product> loadSellerProducts(HttpSession session, String keyword) throws Exception {
        int userId = (session != null && session.getAttribute("userId") != null)
                ? (Integer) session.getAttribute("userId")
                : 0;

        ShopDAO shopDAO = new ShopDAO();
        try {
            Shop shop = shopDAO.getShopByOwnerId(userId);
            if (shop == null) {
                return Collections.emptyList();
            }
            return fetchProductsForShop(shop.getId(), keyword);
        } finally {
            shopDAO.close();
        }
    }

    private List<Product> fetchProductsForShop(int shopId, String keyword) throws Exception {
        ProductDAO dao = new ProductDAO();
        try {
            if (keyword != null && !keyword.trim().isEmpty()) {
                return filterByShopId(dao.searchProducts(keyword.trim()), shopId);
            }
            return dao.getProductsByShopId(shopId);
        } finally {
            dao.close();
        }
    }

    private List<Product> loadCustomerProducts(String keyword) throws Exception {
        ProductDAO dao = new ProductDAO();
        try {
            if (keyword != null && !keyword.trim().isEmpty()) {
                return dao.searchProducts(keyword.trim());
            }
            return dao.getAllProducts();
        } finally {
            dao.close();
        }
    }

    // Loc san pham theo shopId, xu ly null-safe
    private List<Product> filterByShopId(List<Product> list, int shopId) {
        if (list == null) {
            return Collections.emptyList();
        }
        return list.stream()
                .filter(p -> p != null && p.getShopId() == shopId)
                .collect(java.util.stream.Collectors.toList());
    }
}
