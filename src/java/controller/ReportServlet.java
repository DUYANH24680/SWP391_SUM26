package controller;

import dao.ChatDAO;
import dao.ReportDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Product;
import model.Report;

@WebServlet(name = "ReportServlet", urlPatterns = {"/report", "/admin/reports"})
public class ReportServlet extends HttpServlet {

    private final ReportDAO reportDAO = new ReportDAO();
    private final ChatDAO chatDAO = new ChatDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        HttpSession session = request.getSession(false);
        Account user = (session != null) ? (Account) session.getAttribute("user") : null;
        
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Vui long dang nhap");
            return;
        }

        // DuyAnhNgo- Nếu Admin vào đường dẫn /admin/reports -> Lấy danh sách tất cả các đơn tố cáo chờ xử lý (PENDING)
        if ("/admin/reports".equals(path)) {
            if (!"admin".equals(user.getRoleName())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
                return;
            }
            // DuyAnhNgo- Gọi ReportDAO (hàm getPendingReports) lấy danh sách báo cáo đang chờ xử lý
            List<Report> reports = reportDAO.getPendingReports();
            request.setAttribute("reports", reports);
            request.getRequestDispatcher("/admin/reports.jsp").forward(request, response);
            return;
        }

        String action = request.getParameter("action");
        if ("getPurchased".equals(action)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            List<Product> products = reportDAO.getPurchasedProducts(user.getId());
            
            // Build JSON manually
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < products.size(); i++) {
                Product p = products.get(i);
                json.append("{\"id\":").append(p.getId())
                    .append(",\"name\":\"").append(p.getTitle() != null ? p.getTitle().replace("\"", "\\\"").replace("\n", " ") : "").append("\"}");
                if (i < products.size() - 1) json.append(",");
            }
            json.append("]");
            response.getWriter().write(json.toString());
            
        } else if ("getPendingAdminAjax".equals(action)) {
            if (!"admin".equals(user.getRoleName())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            List<Report> reports = reportDAO.getPendingReports();
            
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < reports.size(); i++) {
                Report r = reports.get(i);
                json.append("{")
                    .append("\"id\":").append(r.getId()).append(",")
                    .append("\"customerName\":\"").append(r.getCustomerName() != null ? r.getCustomerName().replace("\"", "\\\"").replace("\n", " ") : "").append("\",")
                    .append("\"productName\":\"").append(r.getProductName() != null ? r.getProductName().replace("\"", "\\\"").replace("\n", " ") : "").append("\",")
                    .append("\"reason\":\"").append(r.getReason() != null ? r.getReason().replace("\"", "\\\"").replace("\n", " ") : "").append("\",")
                    .append("\"createdAt\":\"").append(r.getCreatedAt() != null ? r.getCreatedAt().toString() : "").append("\"")
                    .append("}");
                if (i < reports.size() - 1) json.append(",");
            }
            json.append("]");
            response.getWriter().write(json.toString());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Account user = (session != null) ? (Account) session.getAttribute("user") : null;
        
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Vui long dang nhap");
            return;
        }

        String action = request.getParameter("action");
        
        // DuyAnhNgo- Nhận yêu cầu TẠO BÁO CÁO (Tố cáo sản phẩm) từ phía Khách hàng
        if ("create".equals(action)) {
            int productId = Integer.parseInt(request.getParameter("productId"));
            String reason = request.getParameter("reason");
            // DuyAnhNgo- Gọi ReportDAO (hàm createReport) để INSERT báo cáo vào bảng Reports
            boolean success = reportDAO.createReport(user.getId(), productId, reason);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            
        } else if ("confirm".equals(action)) {
            // DuyAnhNgo- Khi Admin bấm XÁC NHẬN đơn tố cáo
            if (!"admin".equals(user.getRoleName())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            int reportId = Integer.parseInt(request.getParameter("reportId"));
            Report r = reportDAO.getReportById(reportId);
            if (r != null && "PENDING".equals(r.getStatus())) {
                // DuyAnhNgo- Đổi trạng thái Report thành CONFIRMED trong DB bằng ReportDAO (hàm confirmReport)
                if (reportDAO.confirmReport(reportId)) {
                    // DuyAnhNgo- TỰ ĐỘNG TẠO PHÒNG CHAT: Gọi ChatDAO (hàm createSession) kết nối người mua, người bán và admin vào chung 1 phòng chat để giải quyết tranh chấp
                    chatDAO.createSession(reportId, r.getCustomerId(), r.getSellerId(), user.getId());
                    response.sendRedirect(request.getContextPath() + "/admin/reports?msg=Confirmed");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/reports?error=Failed");
                }
            }
        } else if ("confirmAjax".equals(action) || "rejectAjax".equals(action)) {
            if (!"admin".equals(user.getRoleName())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            response.setContentType("application/json");
            int reportId = Integer.parseInt(request.getParameter("reportId"));
            Report r = reportDAO.getReportById(reportId);
            boolean success = false;
            
            if (r != null && "PENDING".equals(r.getStatus())) {
                if ("confirmAjax".equals(action)) {
                    // DuyAnhNgo- Tương tự như trên nhưng chạy bằng AJAX: Gọi ReportDAO (hàm confirmReport) và ChatDAO (hàm createSession)
                    if (reportDAO.confirmReport(reportId)) {
                        chatDAO.createSession(reportId, r.getCustomerId(), r.getSellerId(), user.getId());
                        success = true;
                    }
                } else if ("rejectAjax".equals(action)) {
                    // DuyAnhNgo- Xử lý Từ Chối (Reject) bằng AJAX: Gọi ReportDAO (hàm rejectReport) để update trạng thái thành REJECTED
                    if (reportDAO.rejectReport(reportId)) {
                        success = true;
                    }
                }
            }
            response.getWriter().write("{\"success\":" + success + "}");
        }
    }
}
