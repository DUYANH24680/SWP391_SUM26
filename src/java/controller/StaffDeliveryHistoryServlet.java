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
 * StaffDeliveryHistoryServlet - Staff: View all deliveries and their history.
 */
@WebServlet("/staff/delivery-history")
public class StaffDeliveryHistoryServlet extends HttpServlet {
    
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
        
        // Get filter parameters
        String statusParam = req.getParameter("status");
        Integer statusFilter = null;
        if (statusParam != null && !statusParam.trim().isEmpty()) {
            try {
                statusFilter = Integer.parseInt(statusParam.trim());
            } catch (NumberFormatException e) {
                // Ignore
            }
        }
        
        try {
            List<DeliveryOrder> deliveries;
            if (statusFilter != null) {
                // Filter by status if provided
                deliveries = deliveryService.getAllDeliveries();
                final int filter = statusFilter;
                deliveries.removeIf(d -> d.getStatus() != filter);
            } else {
                deliveries = deliveryService.getAllDeliveries();
            }
            
            req.setAttribute("deliveries", deliveries);
            req.setAttribute("statusFilter", statusParam);
            
        } catch (Exception e) {
            System.err.println("[StaffDeliveryHistoryServlet] Error: " + e.getMessage());
            req.setAttribute("deliveries", java.util.Collections.emptyList());
            session.setAttribute("error", "Lỗi khi tải lịch sử giao hàng.");
        }
        
        req.getRequestDispatcher("/staff/delivery-history.jsp").forward(req, resp);
    }
}
