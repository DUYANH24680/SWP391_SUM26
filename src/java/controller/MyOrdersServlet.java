package controller;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Order;
import model.OrderDetail;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

        OrderDAO orderDAO = new OrderDAO();
        try {
            List<Order> orders = orderDAO.getOrdersByCustomerId(user.getId());
            Map<Integer, List<OrderDetail>> orderDetailsMap = new HashMap<>();

            for (Order o : orders) {
                List<OrderDetail> details = orderDAO.getOrderDetails(o.getId());
                orderDetailsMap.put(o.getId(), details);
            }

            req.setAttribute("orders", orders);
            req.setAttribute("detailsMap", orderDetailsMap);

            req.getRequestDispatcher("/my-orders.jsp").forward(req, resp);
        } finally {
            orderDAO.close();
        }
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
            int orderId;
            try {
                orderId = Integer.parseInt(orderIdParam.trim());
            } catch (NumberFormatException e) {
                session.setAttribute("error", "ID đơn hàng không hợp lệ.");
                resp.sendRedirect(req.getContextPath() + "/my-orders");
                return;
            }

            OrderDAO orderDAO = new OrderDAO();
            try {
                Order order = orderDAO.getOrderById(orderId);
                if (order != null && order.getCustomerId() == user.getId()) {
                    if (order.getStatus() == 1) { // Only pending orders can be canceled
                        boolean ok = orderDAO.updateOrderStatus(orderId, 5); // 5 = Canceled
                        if (ok) {
                            session.setAttribute("message", "Đã hủy đơn hàng thành công!");
                        } else {
                            session.setAttribute("error", "Hủy đơn hàng thất bại.");
                        }
                    } else {
                        session.setAttribute("error", "Chỉ có thể hủy đơn hàng ở trạng thái Chờ xác nhận.");
                    }
                } else {
                    session.setAttribute("error", "Đơn hàng không tồn tại hoặc không thuộc quyền sở hữu của bạn.");
                }
            } finally {
                orderDAO.close();
            }
        }

        resp.sendRedirect(req.getContextPath() + "/my-orders");
    }
}
