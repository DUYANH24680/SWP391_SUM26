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

@WebServlet(name = "DeleteProductServlet", urlPatterns = {"/delete-product"})
public class DeleteProductServlet extends HttpServlet {

    private static final String ROLE_SELLER = "seller";
    private static final String REDIRECT_PRODUCTS = "/products";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (!ROLE_SELLER.equals(role) && !"admin".equals(role)) {
            session.setAttribute("error", "Ban khong co quyen xoa san pham.");
            resp.sendRedirect(req.getContextPath() + REDIRECT_PRODUCTS);
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        String productIdStr = req.getParameter("id");
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            session.setAttribute("error", "Khong xac dinh san pham can xoa.");
            resp.sendRedirect(req.getContextPath() + REDIRECT_PRODUCTS);
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID san pham khong hop le.");
            resp.sendRedirect(req.getContextPath() + REDIRECT_PRODUCTS);
            return;
        }

        ProductDAO productDAO = new ProductDAO();
        try {
            boolean deleted = false;
            if ("admin".equals(role)) {
                Product p = productDAO.getProductById(productId);
                if (p != null) {
                    deleted = productDAO.deleteProduct(productId, p.getShopId());
                }
            } else {
                ShopDAO shopDAO = new ShopDAO();
                Shop shop = null;
                try {
                    shop = shopDAO.getShopByOwnerId(userId);
                } catch (Exception e) {
                    System.err.println("[DeleteProductServlet] Shop lookup error: " + e.getMessage());
                } finally {
                    shopDAO.close();
                }

                if (shop == null) {
                    session.setAttribute("error", "Khong tim thay cua hang cua ban.");
                    resp.sendRedirect(req.getContextPath() + REDIRECT_PRODUCTS);
                    return;
                }

                deleted = productDAO.deleteProduct(productId, shop.getId());
            }

            if (deleted) {
                session.setAttribute("message", "San pham da duoc xoa thanh cong.");
            } else {
                session.setAttribute("error", "Khong the xoa san pham. San pham khong ton tai hoac khong thuoc cua hang cua ban.");
            }
        } catch (RuntimeException e) {
            System.err.println("[DeleteProductServlet] deleteProduct() threw: " + e.getMessage());
            session.setAttribute("error", "Loi khi xoa san pham: " + e.getMessage());
        } finally {
            productDAO.close();
        }

        resp.sendRedirect(req.getContextPath() + REDIRECT_PRODUCTS);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + REDIRECT_PRODUCTS);
    }
}

