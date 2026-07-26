package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.CancelOrderResult;
import model.MyOrdersPageData;
import service.OrderService;

import java.io.IOException;

@WebServlet("/my-orders")
public class MyOrdersServlet extends HttpServlet {

    private OrderService orderService;

    @Override
    public void init() throws ServletException {
        this.orderService = new OrderService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Account user = (Account) session.getAttribute("Account");

        Integer activeStatus = null;
        String statusParam = req.getParameter("status");
        if (statusParam != null && !statusParam.trim().isEmpty()) {
            try {
                activeStatus = Integer.parseInt(statusParam.trim());
            } catch (NumberFormatException ignored) {}
        }

        Integer targetOrderId = null;
        String orderIdParam = req.getParameter("orderId");
        if (orderIdParam != null && !orderIdParam.trim().isEmpty()) {
            try {
                String clean = orderIdParam.replaceAll("[^0-9]", "");
                if (!clean.isEmpty()) {
                    targetOrderId = Integer.parseInt(clean);
                }
            } catch (NumberFormatException ignored) {}
        }

        int page = 1;
        String pageParam = req.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam.trim());
            } catch (NumberFormatException ignored) {}
        } else if (targetOrderId != null) {
            // Find which page contains this target order
            try {
                java.util.List<model.Order> userOrders = orderService.getOrdersByCustomerId(user.getId());
                if (userOrders != null) {
                    if (activeStatus != null) {
                        final int statusToKeep = activeStatus;
                        userOrders.removeIf(o -> o.getStatus() != statusToKeep);
                    }
                    int foundIndex = -1;
                    for (int i = 0; i < userOrders.size(); i++) {
                        if (userOrders.get(i).getId() == targetOrderId) {
                            foundIndex = i;
                            break;
                        }
                    }
                    if (foundIndex != -1) {
                        page = (foundIndex / 5) + 1;
                    }
                }
            } catch (Exception ignored) {}
        }

        MyOrdersPageData data = orderService.getMyOrdersPageData(user.getId(), activeStatus, page);

        req.setAttribute("orders", data.getOrders());
        req.setAttribute("detailsMap", data.getDetailsMap());
        req.setAttribute("deliveryNotesMap", data.getDeliveryNotesMap());
        req.setAttribute("currentPage", data.getCurrentPage());
        req.setAttribute("totalPages", data.getTotalPages());
        req.setAttribute("activeStatus", data.getActiveStatus());
        req.setAttribute("targetOrderId", targetOrderId);

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

        if ("cancel".equals(action) && orderIdParam != null && !orderIdParam.trim().isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdParam.trim());
                CancelOrderResult result = orderService.cancelOrderByCustomer(orderId, user.getId());
                session.setAttribute(result.isSuccess() ? "message" : "error",
                        result.isSuccess() ? "Đã hủy đơn hàng thành công!" : result.getError());
            } catch (NumberFormatException e) {
                session.setAttribute("error", "ID đơn hàng không hợp lệ.");
            }
        }

        resp.sendRedirect(req.getContextPath() + "/my-orders");
    }
}
