package controller;

import service.OrderService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.CancelCustomerOrderResult;
import model.CustomerOrdersData;

import java.io.IOException;

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
        Account account = (Account) session.getAttribute("Account");

        OrderService orderService = new OrderService();
        String statusParam = req.getParameter("status");
        Integer statusFilter = null;
        if (statusParam != null && !statusParam.trim().isEmpty()) {
            try {
                statusFilter = Integer.parseInt(statusParam.trim());
            } catch (NumberFormatException e) {
                statusFilter = null;
            }
        }
        CustomerOrdersData data = orderService.getCustomerOrdersWithDetails(account.getId(), statusFilter);

        req.setAttribute("orders", data.getOrders());
        req.setAttribute("detailsMap", data.getDetailsMap());
        req.setAttribute("activeStatus", statusFilter);
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
        Account account = (Account) session.getAttribute("Account");

        String action = req.getParameter("action");
        String orderIdParam = req.getParameter("orderId");

        if ("cancel".equals(action) && orderIdParam != null) {
            int orderId;
            try {
                orderId = Integer.parseInt(orderIdParam.trim());
            } catch (NumberFormatException e) {
                session.setAttribute("error", "ID đơn hàng không hợp lệ.");
                resp.sendRedirect(req.getContextPath() + "/my-orders");
                return;
            }

            OrderService orderService = new OrderService();
            CancelCustomerOrderResult result = orderService.cancelCustomerOrder(orderId, account.getId());
            if (result.isSuccess()) {
                session.setAttribute("message", result.getMessage());
            } else {
                session.setAttribute("error", result.getMessage());
            }
        }

        resp.sendRedirect(req.getContextPath() + "/my-orders");
    }
}
