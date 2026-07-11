package controller;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Product;

import java.io.IOException;
import java.util.List;

/**
 * Admin: Approve pending products (status 0 → 1).
 */
@WebServlet(name = "ApproveProductServlet", urlPatterns = {"/admin/approve-products"})
public class ApproveProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        String role = (session != null) ? (String) session.getAttribute("role") : null;

        if (!"admin".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            ProductDAO dao = new ProductDAO();
            try {
                List<Product> pendingProducts = dao.getPendingProducts();
                req.setAttribute("pendingProducts", pendingProducts);
                req.setAttribute("totalCount", pendingProducts.size());
            } finally {
                dao.close();
            }
        } catch (Exception e) {
            System.err.println("[ApproveProductServlet] load error: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "Lỗi khi tải danh sách sản phẩm: " + e.getMessage());
            req.setAttribute("pendingProducts", java.util.Collections.emptyList());
        }

        req.getRequestDispatcher("/admin/approve-products.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        String role = (session != null) ? (String) session.getAttribute("role") : null;

        if (!"admin".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String productIdParam = req.getParameter("productId");
        String action = req.getParameter("action");

        if (productIdParam == null || productIdParam.trim().isEmpty()) {
            session.setAttribute("error", "ID sản phẩm không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/approve-products");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdParam.trim());

            ProductDAO dao = new ProductDAO();
            boolean success;
            try {
                if ("remove".equalsIgnoreCase(action)) {
                    // ---- Remove inappropriate product ----
                    String reason = req.getParameter("removeReason");
                    if (reason == null || reason.trim().isEmpty()) {
                        session.setAttribute("error", "Vui lòng nhập lý do xóa sản phẩm.");
                        resp.sendRedirect(req.getContextPath() + "/admin/approve-products");
                        return;
                    }
                    if (reason.trim().length() < 10) {
                        session.setAttribute("error", "Lý do xóa phải có ít nhất 10 ký tự.");
                        resp.sendRedirect(req.getContextPath() + "/admin/approve-products");
                        return;
                    }
                    success = dao.removeInappropriateProduct(productId, reason.trim());
                    if (success) {
                        session.setAttribute("message", "Sản phẩm đã được gỡ bỏ thành công. Lý do: " + reason.trim());
                    } else {
                        session.setAttribute("error", "Sản phẩm không tìm thấy hoặc đã bị gỡ trước đó.");
                    }
                } else {
                    // ---- Default: Approve product ----
                    success = dao.approveProduct(productId);
                    if (success) {
                        session.setAttribute("message", "Sản phẩm đã được duyệt thành công.");
                    } else {
                        session.setAttribute("error", "Sản phẩm không tìm thấy hoặc đã được duyệt trước đó.");
                    }
                }
            } finally {
                dao.close();
            }
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID sản phẩm phải là số.");
        } catch (Exception e) {
            System.err.println("[ApproveProductServlet] action error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi khi xử lý: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/approve-products");
    }
}
