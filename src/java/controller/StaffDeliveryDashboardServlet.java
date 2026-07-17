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
import model.Order;
import java.io.IOException;
import java.util.List;

/**
 * StaffDeliveryDashboardServlet - Staff: View delivery dashboard.
 */
@WebServlet("/staff/delivery")
public class StaffDeliveryDashboardServlet extends HttpServlet {
    
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
            // Get statistics
            List<DeliveryOrder> allDeliveries = deliveryService.getAllDeliveries();
            int totalDeliveries = allDeliveries.size();
            int pendingDeliveries = 0;
            int completedDeliveries = 0;
            
            for (DeliveryOrder d : allDeliveries) {
                if (d.getStatus() == DeliveryOrder.STATUS_DELIVERED || d.getStatus() == DeliveryOrder.STATUS_FAILED) {
                    completedDeliveries++;
                } else {
                    pendingDeliveries++;
                }
            }
            
            // Get recent deliveries
            List<DeliveryOrder> recentDeliveries = allDeliveries.size() > 5 
                ? allDeliveries.subList(0, 5) : allDeliveries;
            
            req.setAttribute("totalDeliveries", totalDeliveries);
            req.setAttribute("pendingDeliveries", pendingDeliveries);
            req.setAttribute("completedDeliveries", completedDeliveries);
            req.setAttribute("recentDeliveries", recentDeliveries);
            
        } catch (Exception e) {
            System.err.println("[StaffDeliveryDashboardServlet] Error: " + e.getMessage());
            session.setAttribute("error", "Lỗi khi tải dữ liệu dashboard.");
        }
        
        req.getRequestDispatcher("/staff/delivery-dashboard.jsp").forward(req, resp);
    }
}
