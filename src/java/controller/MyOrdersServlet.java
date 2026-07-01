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
import 



@WebServlet("/my-orders")
public class MyOrdersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Account user = (Account) session.getAttribute("user");

        OrderService orderService = new OrderService();
        List<Order> orders = orderService.getOrdersByCustomerId(user.getId());
        Map<Integer, List<OrderDetail>> orderDetailsMap = orderService.getOrderDetailsMap(orders);

        req.setAttribute("orders", orders);
        req.setAttribute("detailsMap", orderDetailsMap);

        req.getRequestDispatcher("/my-orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Account user = (Account) session.getAttribute("user");

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
