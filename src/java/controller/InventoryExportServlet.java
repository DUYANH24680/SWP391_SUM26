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
import java.util.List;

/**
 * Servlet xu ly xuat kho (Inventory Export).
 * GET: hien thi form chon san pham de xuat kho.
 * POST: xu ly ghi nhan so luong xuat ra, cap nhat stock san pham,
 *       dong thoi ghi log vao bang InventoryTransactions.
 */
@WebServlet(name = "InventoryExportServlet", urlPatterns = {"/inventory-export"})
public class InventoryExportServlet extends HttpServlet {

    // ===== GET: hien thi form xuat kho =====
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);

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
            System.out.println("[InventoryExportServlet] Shop lookup failed: " + e.getMessage());
            shop = new Shop();
            shop.setId(1);
        } finally {
            shopDAO.close();
        }

        int shopId = shop.getId();

        ProductDAO productDAO = new ProductDAO();
        try {
            List<Product> products = productDAO.getProductsByShopId(shopId);
            req.setAttribute("products", products);
            System.out.println("[InventoryExportServlet] Forwarding to inventory-export.jsp with "
                + products.size() + " products (shopId=" + shopId + ")");
        } catch (RuntimeException e) {
            System.err.println("[InventoryExportServlet] Failed to load products: " + e.getMessage());
            req.setAttribute("products", java.util.Collections.emptyList());
            if (session != null) {
                session.setAttribute("error", "Khong the tai danh sach san pham. Vui long thu lai sau.");
            }
        } finally {
            productDAO.close();
        }

        req.getRequestDispatcher("/inventory-export.jsp").forward(req, resp);
    }

    // ===== POST: xu ly xuat kho =====
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);

        int ownerId = 1;
        if (session != null && session.getAttribute("userId") != null) {
            try {
                ownerId = (Integer) session.getAttribute("userId");
            } catch (Exception ignored) {}
        }

        String productIdStr = req.getParameter("productId");
        String quantityStr  = req.getParameter("quantity");
        String note         = req.getParameter("note");

        if (productIdStr == null || productIdStr.trim().isEmpty()
                || quantityStr == null || quantityStr.trim().isEmpty()) {
            if (session != null) {
                session.setAttribute("error", "Vui long chon san pham va nhap so luong.");
            }
            resp.sendRedirect(req.getContextPath() + "/inventory-export");
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
            resp.sendRedirect(req.getContextPath() + "/inventory-export");
            return;
        }

        if (quantity <= 0) {
            if (session != null) {
                session.setAttribute("error", "So luong xuat kho phai lon hon 0.");
            }
            resp.sendRedirect(req.getContextPath() + "/inventory-export");
            return;
        }

        ShopDAO shopDAO = new ShopDAO();
        int shopId = 1;
        try {
            Shop shop = shopDAO.getShopByOwnerId(ownerId);
            if (shop != null) {
                shopId = shop.getId();
            }
        } catch (Exception e) {
            System.out.println("[InventoryExportServlet] Shop lookup failed: " + e.getMessage());
        } finally {
            shopDAO.close();
        }

        ProductDAO productDAO = new ProductDAO();

        try {
            int[] result = productDAO.exportStock(productId, shopId, ownerId, quantity, note);

            if (result == null) {
                if (session != null) {
                    session.setAttribute("error", "San pham khong ton tai, khong thuoc shop, "
                        + "hoac khong du hang trong kho.");
                }
                resp.sendRedirect(req.getContextPath() + "/inventory-export");
                return;
            }

            int previousStock = result[0];
            int newStock = result[1];

            System.out.println("[InventoryExportServlet] Export success: productId=" + productId
                + ", qty=" + quantity + ", previousStock=" + previousStock + ", newStock=" + newStock);

            if (session != null) {
                session.setAttribute("message",
                    "Xuất kho thành công! Đã xuất " + quantity + " sản phẩm. "
                    + "Tồn kho cũ: " + previousStock + " → Tồn kho mới: " + newStock);
            }

        } catch (SQLException e) {
            System.err.println("[InventoryExportServlet] doPost() SQL error: " + e.getMessage());
            e.printStackTrace();
            if (session != null) {
                session.setAttribute("error", "Loi he thong khi xuat kho: " + e.getMessage());
            }
        } finally {
            productDAO.close();
        }

        resp.sendRedirect(req.getContextPath() + "/inventory-export");
    }
}
