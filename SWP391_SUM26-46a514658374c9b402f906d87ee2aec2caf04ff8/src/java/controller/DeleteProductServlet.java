package controller;

import dao.ProductDAO;
import dao.ShopDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
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
        if (!ROLE_SELLER.equals(role)) {
            session.setAttribute("error", "Ban khong co quyen xoa san pham.");
            resp.sendRedirect(req.getContextPath() + REDIRECT_PRODUCTS);
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

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
            session.setAttribute("error", "Khong tim thay cua hang. Vui long lien he admin.");
            resp.sendRedirect(req.getContextPath() + REDIRECT_PRODUCTS);
            return;
        }

        int shopId = shop.getId();

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

        System.out.println("[DeleteProductServlet] Attempting delete productId=" + productId
                + ", shopId=" + shopId + ", userId=" + userId);

        ProductDAO productDAO = new ProductDAO();
        try {
            boolean deleted = productDAO.deleteProduct(productId, shopId);
            if (deleted) {
                session.setAttribute("message", "San pham da duoc xoa thanh cong.");
                System.out.println("[DeleteProductServlet] Product " + productId + " deleted successfully");
            } else {
                session.setAttribute("error", "Khong the xoa san pham. San pham khong ton tai hoac khong thuoc cua hang cua ban.");
                System.out.println("[DeleteProductServlet] Product " + productId
                        + " not found or not owned by shop " + shopId);
            }
        } catch (RuntimeException e) {
            System.err.println("[DeleteProductServlet] deleteProduct() threw: " + e.getMessage());
            e.printStackTrace();
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

