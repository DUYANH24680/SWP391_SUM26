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
import java.io.IOException;
import java.util.List;

/**
 * StaffAssignDeliveryServlet - Staff: Assign shipper to an order.
 */
@WebServlet("/staff/assign-delivery")
public class StaffAssignDeliveryServlet extends HttpServlet {
    
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
        
        try {
            // Get order ID from request (if provided)
            String orderIdParam = req.getParameter("orderId");
            Integer selectedOrderId = null;
            if (orderIdParam != null && !orderIdParam.isEmpty()) {
                selectedOrderId = Integer.parseInt(orderIdParam);
            }
            
            // Get waiting orders
            List<Order> waitingOrders = deliveryService.getOrdersWaitingForDelivery();
            
            // Get available shippers
            List<Account> shippers = deliveryService.getAvailableShippers();
            
            req.setAttribute("waitingOrders", waitingOrders);
            req.setAttribute("shippers", shippers);
            req.setAttribute("selectedOrderId", selectedOrderId);
            
        } catch (Exception e) {
            System.err.println("[StaffAssignDeliveryServlet] Error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi khi tải dữ liệu phân công giao hàng.");
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
        
        try {
            // Get parameters
            String orderIdParam = req.getParameter("orderId");
            String shipperIdParam = req.getParameter("shipperId");
            String note = req.getParameter("note");
            
            if (orderIdParam == null || orderIdParam.isEmpty()) {
                session.setAttribute("error", "Vui lòng chọn đơn hàng.");
                resp.sendRedirect(req.getContextPath() + "/staff/orders-waiting");
                return;
            }
            
            if (shipperIdParam == null || shipperIdParam.isEmpty()) {
                session.setAttribute("error", "Vui lòng chọn shipper.");
                resp.sendRedirect(req.getContextPath() + "/staff/assign-delivery?orderId=" + orderIdParam);
                return;
            }
            
            int orderId = Integer.parseInt(orderIdParam);
            int shipperId = Integer.parseInt(shipperIdParam);
            int assignedBy = user.getId();
            
            // Assign shipper
            String errorMsg = deliveryService.assignShipper(orderId, shipperId, assignedBy, note);
            
            if (errorMsg != null) {
                session.setAttribute("error", errorMsg);
                resp.sendRedirect(req.getContextPath() + "/staff/assign-delivery?orderId=" + orderId);
                return;
            }
            
            session.setAttribute("message", "Đã giao đơn hàng cho shipper thành công!");
            resp.sendRedirect(req.getContextPath() + "/staff/delivery");
            
        } catch (NumberFormatException e) {
            System.err.println("[StaffAssignDeliveryServlet] NumberFormatException: " + e.getMessage());
            session.setAttribute("error", "Dữ liệu không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/staff/orders-waiting");
        } catch (Exception e) {
            System.err.println("[StaffAssignDeliveryServlet] Error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi khi phân công giao hàng: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/staff/orders-waiting");
        }
    }
}
