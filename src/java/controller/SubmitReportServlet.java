package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

import dao.UserReportDAO;
import dao.ShopDAO;
import model.Account;
import model.UserReport;

/**
 * Customer submits a report against a seller/shop.
 * GET: show form
 * POST: process submission
 */
@WebServlet(name = "SubmitReportServlet", urlPatterns = {"/submit-report"})
public class SubmitReportServlet extends HttpServlet {

    private final UserReportDAO reportDAO = new UserReportDAO();
    private final ShopDAO shopDAO = new ShopDAO();

    // DuyAnhNgo- Hàm GET: Hiển thị giao diện form Tố cáo cửa hàng (report-seller.jsp)
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Account user = (Account) (session != null ? session.getAttribute("user") : null);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        if (!"customer".equalsIgnoreCase(user.getRoleName())) {
            req.setAttribute("error", "Chỉ khách hàng mới có thể gửi báo cáo.");
            req.getRequestDispatcher("/home.jsp").forward(req, resp);
            return;
        }

        String shopIdStr = req.getParameter("shopId");
        int shopId = -1;
        try { shopId = Integer.parseInt(shopIdStr); } catch (Exception ignored) {}

        if (shopId <= 0) {
            session.setAttribute("error", "Không tìm thấy cửa hàng.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        var shop = shopDAO.getShopById(shopId);
        if (shop == null) {
            session.setAttribute("error", "Cửa hàng không tồn tại.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        req.setAttribute("shop", shop);
        req.getRequestDispatcher("/report-seller.jsp").forward(req, resp);
    }

    // DuyAnhNgo- Hàm POST: Nhận dữ liệu từ form khi khách hàng bấm gửi tố cáo Cửa hàng
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        boolean isAjax = "create_ajax".equals(req.getParameter("action"));
        
        HttpSession session = req.getSession(false);
        Account user = (Account) (session != null ? session.getAttribute("user") : null);
        if (user == null) {
            if (isAjax) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write("{\"success\":false, \"message\":\"Vui lòng đăng nhập.\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/login.jsp");
            }
            return;
        }
        if (!"customer".equalsIgnoreCase(user.getRoleName())) {
            if (isAjax) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write("{\"success\":false, \"message\":\"Chỉ khách hàng mới có thể báo cáo.\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/home.jsp");
            }
            return;
        }

        String shopIdStr = req.getParameter("shopId");
        String orderIdStr = req.getParameter("orderId");
        String reportType = req.getParameter("reportType");
        String description = req.getParameter("description");
        String priorityStr = req.getParameter("priority");

        int shopId = -1;
        try { shopId = Integer.parseInt(shopIdStr); } catch (Exception ignored) {}

        if (shopId <= 0) {
            if (isAjax) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write("{\"success\":false, \"message\":\"Không tìm thấy cửa hàng.\"}");
            } else {
                session.setAttribute("error", "Không tìm thấy cửa hàng.");
                resp.sendRedirect(req.getContextPath() + "/home.jsp");
            }
            return;
        }

        if (reportType == null || reportType.trim().isEmpty()
                || description == null || description.trim().isEmpty()
                || description.trim().length() < 10) {
            if (isAjax) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write("{\"success\":false, \"message\":\"Vui lòng chọn loại vi phạm và nhập mô tả ít nhất 10 ký tự.\"}");
            } else {
                session.setAttribute("error", "Vui lòng chọn loại vi phạm và nhập mô tả ít nhất 10 ký tự.");
                resp.sendRedirect(req.getContextPath() + "/submit-report?shopId=" + shopId);
            }
            return;
        }

        Integer orderId = null;
        if (orderIdStr != null && !orderIdStr.trim().isEmpty()) {
            try { orderId = Integer.parseInt(orderIdStr.trim()); } catch (Exception ignored) {}
        }

        // DuyAnhNgo- Gọi ReportDAO (hàm hasPendingReport) kiểm tra xem Khách hàng này có đang có đơn tố cáo Cửa hàng này chờ xử lý không, tránh Spam
        if (reportDAO.hasPendingReport(user.getId(), shopId)) {
            if (isAjax) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write("{\"success\":false, \"message\":\"Bạn đã gửi báo cáo cho cửa hàng này rồi. Vui lòng đợi admin xử lý.\"}");
            } else {
                session.setAttribute("error", "Bạn đã gửi báo cáo cho cửa hàng này rồi. Vui lòng đợi admin xử lý.");
                resp.sendRedirect(req.getContextPath() + "/home.jsp");
            }
            return;
        }

        int priority = 2;
        try { priority = Integer.parseInt(priorityStr); } catch (Exception ignored) {}

        UserReport report = new UserReport();
        report.setReporterId(user.getId());
        report.setReportedShopId(shopId);
        report.setOrderId(orderId);
        report.setReportType(reportType.trim());
        report.setDescription(description.trim());
        report.setPriority(priority);

        // DuyAnhNgo- Gọi ReportDAO (hàm insert) để chèn dữ liệu báo cáo vào CSDL (bảng UserReports)
        int id = reportDAO.insert(report);
        if (id > 0) {
            if (isAjax) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write("{\"success\":true, \"message\":\"Cảm ơn bạn! Báo cáo của bạn đã được gửi. Admin sẽ xem xét trong thời gian sớm nhất.\"}");
            } else {
                session.setAttribute("message", "Cảm ơn bạn! Báo cáo của bạn đã được gửi. Admin sẽ xem xét trong thời gian sớm nhất.");
                resp.sendRedirect(req.getContextPath() + "/home.jsp");
            }
        } else {
            if (isAjax) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write("{\"success\":false, \"message\":\"Gửi báo cáo thất bại. Vui lòng thử lại.\"}");
            } else {
                session.setAttribute("error", "Gửi báo cáo thất bại. Vui lòng thử lại.");
                resp.sendRedirect(req.getContextPath() + "/submit-report?shopId=" + shopId);
            }
        }
    }
}
