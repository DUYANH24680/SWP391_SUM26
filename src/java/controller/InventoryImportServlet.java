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
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

/**
 * Servlet xu ly nhap kho (Inventory Import).
 * GET: hien thi form chon san pham de nhap kho.
 * POST: xu ly ghi nhan so luong nhap vao, cap nhat stock san pham,
 *       dong thoi ghi log vao bang InventoryTransactions.
 */
@WebServlet(name = "InventoryImportServlet", urlPatterns = {"/inventory-import"})
public class InventoryImportServlet extends HttpServlet {

    // ===== GET: hien thi form nhap kho =====
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || !"seller".equalsIgnoreCase((String) session.getAttribute("role"))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        int ownerId = 1;
        if (session != null && session.getAttribute("userId") != null) {
            try {
                ownerId = (Integer) session.getAttribute("userId");
            } catch (Exception ignored) {}
        }

        ShopDAO shopDAO = new ShopDAO();
        Shop shop = null;
        try {
            shop = shopDAO.getShopByOwnerId(ownerId);
            if (shop == null) {
                shop = new Shop();
                shop.setId(1);
            }
        } catch (Exception e) {
            System.out.println("[InventoryImportServlet] Shop lookup failed: " + e.getMessage());
            shop = new Shop();
            shop.setId(1);
        } finally {
            shopDAO.close();
        }

        int shopId = shop.getId();
        session.setAttribute("shopId", shopId);

        ProductDAO productDAO = new ProductDAO();
        try {
            List<Product> products = productDAO.getProductsByShopId(shopId);
            req.setAttribute("products", products);
            System.out.println("[InventoryImportServlet] Forwarding to inventory-import.jsp with "
                + products.size() + " products (shopId=" + shopId + ")");
        } catch (RuntimeException e) {
            System.err.println("[InventoryImportServlet] Failed to load products: " + e.getMessage());
            req.setAttribute("products", java.util.Collections.emptyList());
            if (session != null) {
                session.setAttribute("error", "Khong the tai danh sach san pham. Vui long thu lai sau.");
            }
        } finally {
            productDAO.close();
        }

        req.getRequestDispatcher("/inventory-import.jsp").forward(req, resp);
    }

    // ===== POST: xu ly nhap kho =====
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || !"seller".equalsIgnoreCase((String) session.getAttribute("role"))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        int ownerId = 1;
        if (session != null && session.getAttribute("userId") != null) {
            try {
                ownerId = (Integer) session.getAttribute("userId");
            } catch (Exception ignored) {}
        }

        String productIdStr   = req.getParameter("productId");
        String quantityStr    = req.getParameter("quantity");
        String note           = req.getParameter("note");
        String expiredDateStr = req.getParameter("expiredDate");

        Timestamp expiredDate = null;
        if (expiredDateStr != null && !expiredDateStr.trim().isEmpty()) {
            try {
                expiredDate = Timestamp.valueOf(expiredDateStr.trim() + " 23:59:59");
            } catch (IllegalArgumentException e) {
                System.out.println("[InventoryImportServlet] Invalid expiredDate format: " + expiredDateStr);
            }
        }

        if (productIdStr == null || productIdStr.trim().isEmpty()
                || quantityStr == null || quantityStr.trim().isEmpty()) {
            if (session != null) {
                session.setAttribute("error", "Vui long chon san pham va nhap so luong.");
            }
            resp.sendRedirect(req.getContextPath() + "/inventory-import");
            return;
        }

        int productId;
        int quantity;
        try {
            productId = Integer.parseInt(productIdStr.trim());
            quantity  = Integer.parseInt(quantityStr.trim());
        } catch (NumberFormatException e) {
            if (session != null) {
                session.setAttribute("error", "Du lieu so khong hop le.");
            }
            resp.sendRedirect(req.getContextPath() + "/inventory-import");
            return;
        }

        if (quantity <= 0) {
            if (session != null) {
                session.setAttribute("error", "So luong nhap kho phai lon hon 0.");
            }
            resp.sendRedirect(req.getContextPath() + "/inventory-import");
            return;
        }

        // Lay shopId cua nguoi dung
        ShopDAO shopDAO = new ShopDAO();
        int shopId = 1;
        try {
            Shop shop = shopDAO.getShopByOwnerId(ownerId);
            if (shop != null) {
                shopId = shop.getId();
            }
        } catch (Exception e) {
            System.out.println("[InventoryImportServlet] Shop lookup failed: " + e.getMessage());
        } finally {
            shopDAO.close();
        }

        // Lay stock hien tai cua san pham va kiem tra ownership
        ProductDAO productDAO = new ProductDAO();

        try {
            int[] result = productDAO.importStock(productId, shopId, ownerId, quantity, note, expiredDate);

            if (result == null) {
                if (session != null) {
                    session.setAttribute("error", "San pham khong ton tai hoac khong the cap nhat kho.");
                }
                resp.sendRedirect(req.getContextPath() + "/inventory-import");
                return;
            }

            int previousStock = result[0];
            int newStock = result[1];

            System.out.println("[InventoryImportServlet] Import success: productId=" + productId
                + ", qty=" + quantity + ", previousStock=" + previousStock + ", newStock=" + newStock);

            if (session != null) {
                session.setAttribute("message",
                    "Nhập kho thành công! Đã nhập " + quantity + " sản phẩm. "
                    + "Tồn kho cũ: " + previousStock + " → Tồn kho mới: " + newStock);
            }

        } catch (SQLException e) {
            System.err.println("[InventoryImportServlet] doPost() SQL error: " + e.getMessage());
            e.printStackTrace();
            if (session != null) {
                session.setAttribute("error", "Loi he thong khi nhap kho: " + e.getMessage());
            }
        } finally {
            productDAO.close();
        }

        resp.sendRedirect(req.getContextPath() + "/inventory-import");
    }
}
