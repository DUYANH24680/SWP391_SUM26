package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Order;
import model.OrderDetail;
import service.OrderService;

import java.io.IOException;
import java.util.List;
import java.util.Map;




@WebServlet("/my-orders")
public class MyOrdersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Account user = (Account) session.getAttribute("Account");

        OrderService orderService = new OrderService();
        List<Order> orders = orderService.getOrdersByCustomerId(user.getId());

        // 1. Filter by status if parameter is present
        String statusParam = req.getParameter("status");
        Integer activeStatus = null;
        if (statusParam != null && !statusParam.trim().isEmpty()) {
            try {
                activeStatus = Integer.parseInt(statusParam.trim());
                final int statusToKeep = activeStatus;
                orders.removeIf(o -> o.getStatus() != statusToKeep);
            } catch (NumberFormatException e) {
                // Ignore invalid status format
            }
        }

        // 2. Pagination
        int page = 1;
        String pageParam = req.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam.trim());
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                // Ignore invalid page format
            }
        }

        int pageSize = 5; // 5 orders per page
        int totalOrders = orders.size();
        int totalPages = (int) Math.ceil((double) totalOrders / pageSize);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int start = (page - 1) * pageSize;
        int end = Math.min(start + pageSize, totalOrders);

        List<Order> paginatedOrders = orders.subList(start, end);
        Map<Integer, List<OrderDetail>> orderDetailsMap = orderService.getOrderDetailsMap(paginatedOrders);

        req.setAttribute("orders", paginatedOrders);
        req.setAttribute("detailsMap", orderDetailsMap);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("activeStatus", activeStatus);

        req.getRequestDispatcher("/my-orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Account user = (Account) session.getAttribute("Account");

        String action = req.getParameter("action");
        String orderIdParam = req.getParameter("orderId");

        if ("cancel".equals(action) && orderIdParam != null) {
            try {
                int orderId = Integer.parseInt(orderIdParam.trim());
                OrderService orderService = new OrderService();
                orderService.cancelOrderByCustomer(orderId, user.getId());
                session.setAttribute("message", "Đã hủy đơn hàng thành công!");
            } catch (NumberFormatException e) {
                session.setAttribute("error", "ID đơn hàng không hợp lệ.");
            } catch (IllegalArgumentException e) {
                session.setAttribute("error", e.getMessage());
            } catch (RuntimeException e) {
                session.setAttribute("error", e.getMessage());
            }
        }

        resp.sendRedirect(req.getContextPath() + "/my-orders");
    }
}
