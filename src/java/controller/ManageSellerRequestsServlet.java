package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

import dao.ShopRequestDAO;
import model.Account;
import model.ShopRequest;

/**
 * Admin: list all seller registration requests, approve or reject.
 */
@WebServlet(name = "ManageSellerRequestsServlet", urlPatterns = {"/admin/seller-requests"})
public class ManageSellerRequestsServlet extends HttpServlet {

    private final ShopRequestDAO dao = new ShopRequestDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        guard(req, resp);

        String filter = req.getParameter("filter");
        List<ShopRequest> requests;

        if ("pending".equals(filter)) {
            requests = dao.getPending();
        } else if ("all".equals(filter)) {
            requests = dao.getAll();
        } else {
            // Default: show pending
            requests = dao.getPending();
            filter = "pending";
        }

        req.setAttribute("requests", requests);
        req.setAttribute("currentFilter", filter);
        req.getRequestDispatcher("/admin/seller-requests.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        guard(req, resp);

        String action = req.getParameter("action");
        int requestId = parseInt(req.getParameter("id"));
        if (requestId <= 0) {
            redirectWithError(req, resp, "ID yêu cầu không hợp lệ.");
            return;
        }

        HttpSession session = req.getSession();
        String filter = req.getParameter("filter");

        try {
            if ("approve".equals(action)) {
                boolean ok = dao.approve(requestId);
                if (ok) {
                    session.setAttribute("message", "Duyệt thành công! Cửa hàng đã được tạo và tài khoản đã nâng cấp lên Seller.");
                } else {
                    session.setAttribute("error", "Yêu cầu không tồn tại hoặc đã được xử lý trước đó.");
                }
            } else if ("reject".equals(action)) {
                boolean ok = dao.reject(requestId);
                if (ok) {
                    session.setAttribute("message", "Đã từ chối yêu cầu.");
                } else {
                    session.setAttribute("error", "Yêu cầu không tồn tại hoặc đã được xử lý trước đó.");
                }
            } else {
                session.setAttribute("error", "Hành động không hợp lệ.");
            }
        } catch (Exception e) {
            session.setAttribute("error", "Lỗi xử lý: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/seller-requests?filter=" + filter);
    }

    private void guard(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        Account user = (Account) (session != null ? session.getAttribute("user") : null);
        if (user == null || !"admin".equals(user.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
        }
    }

    private void redirectWithError(HttpServletRequest req, HttpServletResponse resp, String msg)
            throws IOException {
        req.getSession().setAttribute("error", msg);
        resp.sendRedirect(req.getContextPath() + "/admin/seller-requests");
    }

    private int parseInt(String s) {
        try { return Integer.parseInt(s); } catch (Exception e) { return -1; }
    }
}
