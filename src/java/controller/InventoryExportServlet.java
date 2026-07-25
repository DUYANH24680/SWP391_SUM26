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
 * DuyAnhNgo- CÁCH HOẠT ĐỘNG VÀ ĐIỀU HƯỚNG XỬ LÝ XUẤT KHO (INVENTORY EXPORT):
 * 
 * 1. CÁCH HOẠT ĐỘNG CỦA CODE:
 *    - Phương thức doGet(): Kiểm tra phiên làm việc (Session) của Seller. Sử dụng ShopDAO để lấy shopId theo userId, 
 *      sau đó dùng ProductDAO.getProductsByShopId(shopId) lấy danh sách các sản phẩm thuộc cửa hàng để truyền sang JSP.
 *      JSP sẽ tự động lọc các sản phẩm quá hạn (expiredDate < hiện tại & stockQuantity > 0) để hiển thị ở Thẻ Cảnh Báo phía trên.
 *    - Phương thức doPost(): Lấy các tham số từ form xuất kho (productId, quantity, note). Kiểm tra dữ liệu đầu vào (quantity > 0). 
 *      Gọi ProductDAO.exportStock() để kiểm tra số lượng tồn kho khả dụng, trừ tồn kho và tự động ghi log vào bảng 
 *      InventoryTransactions trong cùng 1 Database Transaction.
 * 
 * 2. ĐIỀU ĐI ĐÂU (FORWARD / REDIRECT):
 *    - doGet(): req.getRequestDispatcher("/inventory-export.jsp").forward(req, resp); -> Chuyển hướng nội bộ sang JSP xuất kho.
 *    - doPost(): resp.sendRedirect(req.getContextPath() + "/inventory-export"); -> Sau khi hoàn tất (hoặc lỗi), chuyển hướng 
 *      trình duyệt quay lại URL /inventory-export để load lại dữ liệu mới và hiển thị thông báo kết quả.
 * 
 * 3. HIỂN THỊ TRONG JSP NÀO:
 *    - Giao diện form chọn sản phẩm & thẻ cảnh báo sản phẩm hết hạn được hiển thị tại JSP: web/inventory-export.jsp
 * 
 * 4. IMPORT EXPORT Ở ĐÂU TRONG DAO NÀO:
 *    - Xử lý xuất kho sản phẩm & ghi nhận giao dịch xuất kho tại DAO: 
 *      + ProductDAO.java -> phương thức exportStock(productId, shopId, ownerId, quantity, note)
 *      + InventoryTransactionDAO.java -> phương thức addExport(tx, conn) (Ghi chép lịch sử giao dịch vào DB)
 */
@WebServlet(name = "InventoryExportServlet", urlPatterns = {"/inventory-export"})
public class InventoryExportServlet extends HttpServlet {

    // DuyAnhNgo- GET: Hiển thị form xuất kho, lấy danh sách sản phẩm thuộc shop chuyển tới inventory-export.jsp
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
        int shopId = -1; // DuyAnhNgo - Khởi tạo mặc định là -1 (chưa có cửa hàng) để tránh gán nhầm shopId = 1
        try {
            shop = shopDAO.getShopByOwnerId(ownerId);
            if (shop != null) {
                shopId = shop.getId();
            }
        } catch (Exception e) {
            System.out.println("[InventoryExportServlet] Shop lookup failed: " + e.getMessage());
        } finally {
            shopDAO.close();
        }
        
        // DuyAnhNgo - Kiểm tra nếu shopId = -1 tức là người dùng hiện tại không có cửa hàng
        // => Trả về danh sách rỗng và chặn không cho truy cập / xem kho hàng của shop mặc định (Shop 1)
        // Điều này đảm bảo: "shop nào thì chỉ thấy và xuất sản phẩm của shop đấy"
        if (shopId == -1) {
            req.setAttribute("products", java.util.Collections.emptyList());
            if (session != null) {
                session.setAttribute("error", "Tài khoản của bạn chưa có cửa hàng, không thể xem hoặc xuất kho.");
            }
            req.getRequestDispatcher("/inventory-export.jsp").forward(req, resp);
            return;
        }

        dao.InventoryTransactionDAO txDAO = new dao.InventoryTransactionDAO();
        try {
            java.util.List<java.util.Map<String, Object>> batches = txDAO.getInventoryBatches(shopId);
            req.setAttribute("batches", batches);
            System.out.println("[InventoryExportServlet] Forwarding to inventory-export.jsp with "
                + batches.size() + " batches (shopId=" + shopId + ")");
        } catch (RuntimeException e) {
            System.err.println("[InventoryExportServlet] Failed to load batches: " + e.getMessage());
            req.setAttribute("batches", java.util.Collections.emptyList());
            if (session != null) {
                session.setAttribute("error", "Khong the tai danh sach lo hang. Vui long thu lai sau.");
            }
        } finally {
            txDAO.close();
        }

        req.getRequestDispatcher("/inventory-export.jsp").forward(req, resp);
    }

    // DuyAnhNgo- POST: Xử lý dữ liệu xuất kho từ form, gọi ProductDAO.exportStock() và redirect về /inventory-export
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

        String productIdStr = req.getParameter("productId");
        String quantityStr  = req.getParameter("quantity");
        String note         = req.getParameter("note");
        String expiredDateStr = req.getParameter("expiredDate");

        java.sql.Timestamp expiredDate = null;
        if (expiredDateStr != null && !expiredDateStr.trim().isEmpty()) {
            try {
                // Remove trailing nano precision if exists to parse safely, or just parse directly
                if (expiredDateStr.length() > 19) {
                    expiredDateStr = expiredDateStr.substring(0, 19); // YYYY-MM-DD HH:MM:SS
                }
                expiredDate = java.sql.Timestamp.valueOf(expiredDateStr);
            } catch (Exception e) {
                System.out.println("[InventoryExportServlet] Invalid expiredDate format: " + expiredDateStr);
            }
        }

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
        int shopId = -1;
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
        
        // DuyAnhNgo - Tương tự như lúc GET, chặn đứng thao tác POST (Xuất kho) nếu account không có cửa hàng.
        // Hơn nữa, method productDAO.exportStock bên dưới cũng có lệnh IF (actualShopId != shopId) để xác nhận 
        // chính xác sản phẩm đó có thuộc sở hữu của shopId này hay không trước khi thực thi trừ kho.
        // Nhờ vậy, Shop khác sẽ KHÔNG THỂ hack/chỉnh sửa form để xuất kho sản phẩm của Shop này.
        if (shopId == -1) {
            if (session != null) {
                session.setAttribute("error", "Tài khoản của bạn chưa có cửa hàng, không thể xuất kho.");
            }
            resp.sendRedirect(req.getContextPath() + "/inventory-export");
            return;
        }

        ProductDAO productDAO = new ProductDAO();

        try {
            int[] result = productDAO.exportStock(productId, shopId, ownerId, quantity, note, expiredDate);

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
