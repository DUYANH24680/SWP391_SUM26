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
import model.DeliveryOrder;
import model.OrderTracking;
import service.OrderService;
import service.DeliveryService;

import java.io.IOException;
import java.util.List;

/**
 * OrderDetailServlet - Handles order detail view for customers.
 * URL: /order-detail?id={orderId}
 */
@WebServlet("/order-detail")
public class OrderDetailServlet extends HttpServlet {

    private OrderService orderService;
    private DeliveryService deliveryService;

    @Override
    public void init() throws ServletException {
        this.orderService = new OrderService();
        this.deliveryService = new DeliveryService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        // Check authentication
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Account customer = (Account) session.getAttribute("Account");

        // Validate order ID parameter
        String orderIdParam = req.getParameter("id");
        if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
            session.setAttribute("error", "ID đơn hàng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/my-orders");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdParam.trim());
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID đơn hàng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/my-orders");
            return;
        }

        try {
            // Get order details
            System.out.println("[OrderDetailServlet] Getting order " + orderId);
            Order order = orderService.getOrderById(orderId);
            if (order == null) {
                session.setAttribute("error", "Đơn hàng không tồn tại.");
                resp.sendRedirect(req.getContextPath() + "/my-orders");
                return;
            }

            // Security: Validate customer ownership (if seller/admin, redirect to seller/admin view)
            if (order.getCustomerId() != customer.getId()) {
                String role = (String) session.getAttribute("role");
                if ("seller".equalsIgnoreCase(role) || "seller".equalsIgnoreCase(customer.getRoleName())) {
                    resp.sendRedirect(req.getContextPath() + "/seller/order-detail?id=" + orderId);
                    return;
                } else if ("admin".equalsIgnoreCase(role) || "admin".equalsIgnoreCase(customer.getRoleName())) {
                    // Admin can view order details as well
                } else {
                    session.setAttribute("error", "Bạn không có quyền xem đơn hàng này.");
                    resp.sendRedirect(req.getContextPath() + "/my-orders");
                    return;
                }
            }

            // Get order items
            System.out.println("[OrderDetailServlet] Getting order items");
            List<OrderDetail> orderItems = orderService.getOrderDetails(orderId);
            if (orderItems == null || orderItems.isEmpty()) {
                session.setAttribute("error", "Đơn hàng không có sản phẩm nào.");
                resp.sendRedirect(req.getContextPath() + "/my-orders");
                return;
            }

            // Get delivery information (if exists)
            System.out.println("[OrderDetailServlet] Getting delivery info");
            DeliveryOrder deliveryInfo = deliveryService.getDeliveryByOrderId(orderId);
            
            // Get tracking history
            System.out.println("[OrderDetailServlet] Getting tracking history");
            List<OrderTracking> trackingHistory = deliveryService.getOrderTracking(orderId);

            // Set attributes for JSP
            req.setAttribute("order", order);
            req.setAttribute("orderItems", orderItems);
            req.setAttribute("deliveryInfo", deliveryInfo);
            req.setAttribute("trackingHistory", trackingHistory);

            // Forward to order detail page
            req.getRequestDispatcher("/order-detail.jsp").forward(req, resp);

        } catch (Exception e) {
            System.err.println("[OrderDetailServlet] Error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi hệ thống. Vui lòng thử lại sau.");
            resp.sendRedirect(req.getContextPath() + "/my-orders");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Account customer = (Account) session.getAttribute("Account");

        String action = req.getParameter("action");
        String orderIdParam = req.getParameter("orderId");

        if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
            session.setAttribute("error", "ID đơn hàng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/my-orders");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdParam.trim());
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID đơn hàng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/my-orders");
            return;
        }

        try {
            // Validate order ownership
            Order order = orderService.getOrderById(orderId);
            if (order == null || order.getCustomerId() != customer.getId()) {
                session.setAttribute("error", "Bạn không có quyền thực hiện hành động này.");
                resp.sendRedirect(req.getContextPath() + "/my-orders");
                return;
            }

            if ("cancel".equals(action)) {
                // Cancel order (only if status = 1 - Pending)
                if (order.getStatus() != 1) {
                    session.setAttribute("error", "Chỉ có thể hủy đơn hàng đang chờ xác nhận.");
                } else {
                    // Use existing cancel order logic
                    model.CancelOrderResult result = orderService.cancelOrderByCustomer(orderId, customer.getId());
                    session.setAttribute(result.isSuccess() ? "message" : "error",
                            result.isSuccess() ? "Đã hủy đơn hàng thành công!" : result.getError());
                }
            } else {
                session.setAttribute("error", "Hành động không hợp lệ.");
            }

        } catch (Exception e) {
            System.err.println("[OrderDetailServlet] POST error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi hệ thống. Vui lòng thử lại sau.");
        }

        // Redirect back to order detail or my orders
        resp.sendRedirect(req.getContextPath() + "/order-detail?id=" + orderId);
    }

    @Override
    public void destroy() {
        if (orderService != null) {
            orderService.close();
        }
        if (deliveryService != null) {
            deliveryService.close();
        }
    }
}