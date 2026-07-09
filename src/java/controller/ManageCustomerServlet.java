package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.AccountManagementService;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet(name = "ManageCustomerServlet", urlPatterns = {"/admin/customers"})
public class ManageCustomerServlet extends HttpServlet {

    private AccountManagementService accountManagementService;

    @Override
    public void init() throws ServletException {
        this.accountManagementService = new AccountManagementService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String role = (session != null) ? (String) session.getAttribute("role") : null;

        if (!"admin".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String keyword = req.getParameter("search");
        String action = req.getParameter("action");

        if ("viewOrders".equals(action)) {
            handleViewOrders(req, resp, session);
            return;
        }

        handleList(req, keyword);

        req.getRequestDispatcher("/admin/manage-customers.jsp").forward(req, resp);
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

        String action = req.getParameter("action");

        if ("toggleStatus".equals(action)) {
            handleToggleStatus(req, session);
        }

        String keyword = req.getParameter("searchKeyword");
        String redirectUrl = req.getContextPath() + "/admin/customers"
                + (keyword != null && !keyword.trim().isEmpty()
                    ? "?search=" + URLEncoder.encode(keyword.trim(), StandardCharsets.UTF_8) : "");
        resp.sendRedirect(redirectUrl);
    }

    private void handleList(HttpServletRequest req, String keyword) {
        try {
            AccountManagementService.CustomerListResult result =
                    accountManagementService.getCustomerList(keyword);
            req.setAttribute("customers", result.getCustomers());
            req.setAttribute("totalCount", result.getTotalCount());
            if (keyword != null && !keyword.trim().isEmpty()) {
                req.setAttribute("searchKeyword", keyword.trim());
            }
        } catch (Exception e) {
            System.err.println("[ManageCustomerServlet] handleList error: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "Lỗi khi tải danh sách khách hàng: " + e.getMessage());
            req.setAttribute("customers", java.util.Collections.emptyList());
        }
    }

    private void handleViewOrders(HttpServletRequest req, HttpServletResponse resp, HttpSession session)
            throws ServletException, IOException {
        String idParam = req.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            session.setAttribute("error", "ID khách hàng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/customers");
            return;
        }

        int customerId;
        try {
            customerId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID khách hàng phải là số.");
            resp.sendRedirect(req.getContextPath() + "/admin/customers");
            return;
        }

        try {
            AccountManagementService.CustomerOrderHistoryResult result =
                    accountManagementService.getCustomerOrderHistory(customerId);

            if (!result.isFound()) {
                session.setAttribute("error", "Không tìm thấy khách hàng.");
                resp.sendRedirect(req.getContextPath() + "/admin/customers");
                return;
            }

            req.setAttribute("customer", result.getCustomer());
            req.setAttribute("orders", result.getOrders());
            req.getRequestDispatcher("/admin/customer-orders.jsp").forward(req, resp);
        } catch (Exception e) {
            System.err.println("[ManageCustomerServlet] handleViewOrders error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi khi tải đơn hàng: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/admin/customers");
        }
    }

    private void handleToggleStatus(HttpServletRequest req, HttpSession session) {
        String idParam = req.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            session.setAttribute("error", "ID tài khoản không hợp lệ.");
            return;
        }

        try {
            int accountId = Integer.parseInt(idParam.trim());
            Integer currentUserId = (Integer) session.getAttribute("userId");

            AccountManagementService.ToggleStatusResult result =
                    accountManagementService.toggleAccountStatus(accountId, currentUserId);

            if (result.isSuccess()) {
                session.setAttribute("message", result.getMessage());
            } else {
                session.setAttribute("error", result.getMessage());
            }
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID tài khoản phải là số.");
        } catch (Exception e) {
            System.err.println("[ManageCustomerServlet] handleToggleStatus error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi khi cập nhật trạng thái: " + e.getMessage());
        }
    }
}
