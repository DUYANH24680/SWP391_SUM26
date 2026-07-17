package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import service.DeliveryService;
import model.DeliveryOrder;
import java.io.IOException;
import java.util.List;

/**
 * ShipperDeliveryDashboardServlet - Shipper: View delivery dashboard.
 */
@WebServlet("/shipper/delivery")
public class ShipperDeliveryDashboardServlet extends HttpServlet {
    
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
        if (!"shipper".equalsIgnoreCase(user.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }
        
        try {
            // Get statistics
            int[] stats = deliveryService.getDeliveryStats(user.getId());
            int pending = stats[0];
            int completed = stats[1];
            int failed = stats[2];
            
            // Get pending deliveries
            List<DeliveryOrder> pendingDeliveries = deliveryService.getPendingDeliveries(user.getId());
            
            req.setAttribute("pendingCount", pending);
            req.setAttribute("completedCount", completed);
            req.setAttribute("failedCount", failed);
            req.setAttribute("pendingDeliveries", pendingDeliveries);
            
        } catch (Exception e) {
            System.err.println("[ShipperDeliveryDashboardServlet] Error: " + e.getMessage());
            session.setAttribute("error", "Lỗi khi tải dữ liệu dashboard.");
        }
        
        req.getRequestDispatcher("/shipper/delivery-dashboard.jsp").forward(req, resp);
    }
}
