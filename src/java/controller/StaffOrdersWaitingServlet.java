package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Order;
import service.DeliveryService;
import java.io.IOException;
import java.util.List;

/**
 * StaffOrdersWaitingServlet - Staff: List orders waiting for delivery assignment.
 */
@WebServlet("/staff/orders-waiting")
public class StaffOrdersWaitingServlet extends HttpServlet {
    
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
            // Get orders that are confirmed (status=2) and not yet assigned to a delivery
            List<Order> waitingOrders = deliveryService.getOrdersWaitingForDelivery();
            List<Account> shippers = deliveryService.getAvailableShippers();
            req.setAttribute("waitingOrders", waitingOrders);
            req.setAttribute("shippers", shippers);
            
        } catch (Exception e) {
            System.err.println("[StaffOrdersWaitingServlet] Error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi khi tải danh sách đơn hàng chờ giao.");
        }
        
        req.getRequestDispatcher("/staff/orders-waiting.jsp").forward(req, resp);
    }
}
