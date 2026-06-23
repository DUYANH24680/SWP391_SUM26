package controller;

import dao.AccountDAO;
import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Order;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Admin: Manage customers (list, search, view order history, block/unblock).
 */
@WebServlet(name = "ManageCustomerServlet", urlPatterns = {"/admin/customers"})
public class ManageCustomerServlet extends HttpServlet {

    private static final String ROLE_CUSTOMER = "customer";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        String role = (session != null) ? (String) session.getAttribute("role") : null;

        // Chỉ admin được truy cập
        if (!"admin".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String keyword = req.getParameter("search");
        String action = req.getParameter("action");

        // === Xem lịch sử đơn hàng của 1 khách ===
        if ("viewOrders".equals(action)) {
            handleViewOrders(req, resp, session);
            return;
        }

        // === Mặc định: hiển thị danh sách / search ===
        handleList(req, keyword, session);

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

        // Quay lại trang danh sách
        String keyword = req.getParameter("searchKeyword");
        resp.sendRedirect(req.getContextPath() + "/admin/customers"
                + (keyword != null && !keyword.trim().isEmpty() ? "?search=" + java.net.URLEncoder.encode(keyword.trim(), "UTF-8") : ""));
    }

    // ================================================================
    //  Xử lý hiển thị danh sách khách hàng
    // ================================================================
    private void handleList(HttpServletRequest req, String keyword, HttpSession session) {
        try {
            AccountDAO dao = new AccountDAO();
            try {
                List<Account> customers;
                if (keyword != null && !keyword.trim().isEmpty()) {
                    customers = dao.searchAccountsByRole(ROLE_CUSTOMER, keyword.trim());
                    req.setAttribute("searchKeyword", keyword.trim());
                } else {
                    customers = dao.getAccountsByRole(ROLE_CUSTOMER);
                }

                // Đếm số đơn hàng của mỗi khách (hiển thị badge)
                OrderDAO orderDAO = new OrderDAO();
                try {
                    for (Account c : customers) {
                        List<Order> orders = orderDAO.getOrdersByCustomerId(c.getId());
                        c.setExtra("orderCount", orders.size());
                    }
                } finally {
                    orderDAO.close();
                }

                req.setAttribute("customers", customers);
                req.setAttribute("totalCount", customers.size());

            } finally {
                dao.close();
            }
        } catch (Exception e) {
            System.err.println("[ManageCustomerServlet] handleList error: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "Lỗi khi tải danh sách khách hàng: " + e.getMessage());
            req.setAttribute("customers", java.util.Collections.emptyList());
        }
    }

    // ================================================================
    //  Xem lịch sử đơn hàng của 1 khách hàng
    // ================================================================
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
            AccountDAO accountDAO = new AccountDAO();
            Account customer;
            try {
                customer = accountDAO.findByIdIncludeAll(customerId);
            } finally {
                accountDAO.close();
            }

            if (customer == null || !"customer".equals(customer.getRoleName())) {
                session.setAttribute("error", "Không tìm thấy khách hàng.");
                resp.sendRedirect(req.getContextPath() + "/admin/customers");
                return;
            }

            OrderDAO orderDAO = new OrderDAO();
            List<Order> orders;
            try {
                orders = orderDAO.getOrdersByCustomerId(customerId);
            } finally {
                orderDAO.close();
            }

            req.setAttribute("customer", customer);
            req.setAttribute("orders", orders);
            req.getRequestDispatcher("/admin/customer-orders.jsp").forward(req, resp);
            return;

        } catch (Exception e) {
            System.err.println("[ManageCustomerServlet] handleViewOrders error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi khi tải đơn hàng: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/admin/customers");
        }
    }

    // ================================================================
    //  Khóa / Mở khóa tài khoản
    // ================================================================
    private void handleToggleStatus(HttpServletRequest req, HttpSession session) {
        String idParam = req.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            session.setAttribute("error", "ID tài khoản không hợp lệ.");
            return;
        }

        int accountId;
        try {
            accountId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID tài khoản phải là số.");
            return;
        }

        // Không cho admin tự khóa chính mình
        Integer currentUserId = (Integer) session.getAttribute("userId");
        if (currentUserId != null && currentUserId == accountId) {
            session.setAttribute("error", "Bạn không thể khóa chính mình.");
            return;
        }

        try {
            AccountDAO dao = new AccountDAO();
            try {
                Account acc = dao.findByIdIncludeAll(accountId);
                if (acc == null) {
                    session.setAttribute("error", "Không tìm thấy tài khoản.");
                    return;
                }

                // Chỉ khóa/mở khóa tài khoản customer
                if (!"customer".equals(acc.getRoleName())) {
                    session.setAttribute("error", "Chỉ có thể khóa/mở khóa tài khoản khách hàng.");
                    return;
                }

                int newStatus = (acc.getStatus() == 1) ? 0 : 1;
                boolean success = dao.updateAccountStatus(accountId, newStatus);

                if (success) {
                    String action = (newStatus == 0) ? "khóa" : "mở khóa";
                    session.setAttribute("message", "Đã " + action + " tài khoản thành công.");
                } else {
                    session.setAttribute("error", "Không thể cập nhật trạng thái tài khoản.");
                }
            } finally {
                dao.close();
            }
        } catch (Exception e) {
            System.err.println("[ManageCustomerServlet] handleToggleStatus error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi khi cập nhật trạng thái: " + e.getMessage());
        }
    }
}
