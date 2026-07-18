package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import service.DeliveryService;
import model.Order;
import model.DeliveryOrder;
import java.io.IOException;
import java.util.List;

/**
 * AssignDeliveryServlet - Staff: Assign orders to shippers.
 */
@WebServlet("/staff/assign-delivery-old")
public class AssignDeliveryServlet extends HttpServlet {
    
    private DeliveryService deliveryService = new DeliveryService();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        Account user = (Account) session.getAttribute("Account");
        if (!"staff".equalsIgnoreCase(user.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }
        
        // Get order ID if provided
        String orderIdParam = req.getParameter("orderId");
        if (orderIdParam != null && !orderIdParam.trim().isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdParam.trim());
                req.setAttribute("selectedOrderId", orderId);
            } catch (NumberFormatException e) {
                // Ignore
            }
        }
        
        // Get available shippers
        try {
            List<Account> shippers = deliveryService.getAvailableShippers();
            req.setAttribute("shippers", shippers);
            
            List<Order> waitingOrders = deliveryService.getOrdersWaitingForDelivery();
            req.setAttribute("waitingOrders", waitingOrders);
        } catch (Exception e) {
            System.err.println("[AssignDeliveryServlet] Error: " + e.getMessage());
            session.setAttribute("error", "Lỗi khi tải dữ liệu.");
        }
        
        req.getRequestDispatcher("/staff/assign-delivery.jsp").forward(req, resp);
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
        if (!"staff".equalsIgnoreCase(user.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }
        
        String orderIdParam = req.getParameter("orderId");
        String shipperIdParam = req.getParameter("shipperId");
        String note = req.getParameter("note");
        
        if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng chọn đơn hàng.");
            resp.sendRedirect(req.getContextPath() + "/staff/orders-waiting");
            return;
        }
        
        if (shipperIdParam == null || shipperIdParam.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng chọn shipper.");
            resp.sendRedirect(req.getContextPath() + "/staff/assign-delivery?orderId=" + orderIdParam);
            return;
        }
        
        try {
            int orderId = Integer.parseInt(orderIdParam.trim());
            int shipperId = Integer.parseInt(shipperIdParam.trim());
            
            String error = deliveryService.assignShipper(orderId, shipperId, user.getId(), note);
            
            if (error != null) {
                session.setAttribute("error", error);
            } else {
                session.setAttribute("message", "Giao đơn hàng cho shipper thành công!");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Tham số không hợp lệ.");
        }
        
        resp.sendRedirect(req.getContextPath() + "/staff/orders-waiting");
    }
}
