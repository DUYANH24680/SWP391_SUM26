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
 * OrderWaitingServlet - Staff: View orders waiting for delivery assignment.
 */
@WebServlet("/staff/orders-waiting-old")
public class OrderWaitingServlet extends HttpServlet {
    
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
            List<Order> waitingOrders = deliveryService.getOrdersWaitingForDelivery();
            req.setAttribute("waitingOrders", waitingOrders);
        } catch (Exception e) {
            System.err.println("[OrderWaitingServlet] Error: " + e.getMessage());
            req.setAttribute("waitingOrders", java.util.Collections.emptyList());
            session.setAttribute("error", "Lỗi khi tải danh sách đơn hàng.");
        }
        
        req.getRequestDispatcher("/staff/orders-waiting.jsp").forward(req, resp);
    }
}
