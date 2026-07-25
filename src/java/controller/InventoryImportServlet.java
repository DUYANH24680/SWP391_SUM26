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
 * DuyAnhNgo- CÁCH HOẠT ĐỘNG VÀ ĐIỀU HƯỚNG XỬ LÝ NHẬP KHO (INVENTORY IMPORT):
 * 
 * 1. CÁCH HOẠT ĐỘNG CỦA CODE:
 *    - Phương thức doGet(): Kiểm tra phiên làm việc (Session) của Seller. Sử dụng ShopDAO để lấy shopId theo userId, 
 *      sau đó dùng ProductDAO.getProductsByShopId(shopId) lấy danh sách các sản phẩm thuộc cửa hàng để truyền sang JSP.
 *    - Phương thức doPost(): Lấy các tham số từ form nhập kho (productId, quantity, note, expiredDate). Kiếm tra dữ liệu 
 *      đầu vào (quantity > 0). Gọi ProductDAO.importStock() để thực hiện tăng số lượng tồn kho và tự động ghi log vào bảng 
 *      InventoryTransactions trong cùng 1 Database Transaction.
 * 
 * 2. ĐIỀU ĐI ĐÂU (FORWARD / REDIRECT):
 *    - doGet(): req.getRequestDispatcher("/inventory-import.jsp").forward(req, resp); -> Chuyển hướng nội bộ sang JSP.
 *    - doPost(): resp.sendRedirect(req.getContextPath() + "/inventory-import"); -> Sau khi hoàn tất (hoặc lỗi), chuyển hướng 
 *      trình duyệt quay lại URL /inventory-import để load lại dữ liệu mới và hiển thị thông báo qua Session message/error.
 * 
 * 3. HIỂN THỊ TRONG JSP NÀO:
 *    - Giao diện form chọn sản phẩm & nhập số lượng được hiển thị tại JSP: web/inventory-import.jsp
 * 
 * 4. IMPORT EXPORT Ở ĐÂU TRONG DAO NÀO:
 *    - Xử lý tăng tồn kho sản phẩm & ghi nhận giao dịch nhập kho tại DAO: 
 *      + ProductDAO.java -> phương thức importStock(productId, shopId, ownerId, quantity, note, expiredDate)
 *      + InventoryTransactionDAO.java -> phương thức addImport(tx, conn) (Ghi chép lịch sử giao dịch vào DB)
 */
@WebServlet(name = "InventoryImportServlet", urlPatterns = {"/inventory-import"})
public class InventoryImportServlet extends HttpServlet {

    // DuyAnhNgo- GET: Hiển thị form nhập kho, lấy danh sách sản phẩm thuộc shop chuyển tới inventory-import.jsp
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

    // DuyAnhNgo- POST: Xử lý dữ liệu form gửi lên, gọi ProductDAO.importStock() để nhập kho và redirect về /inventory-import
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
