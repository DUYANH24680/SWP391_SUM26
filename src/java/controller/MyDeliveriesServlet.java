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
 * MyDeliveriesServlet - Shipper: View assigned deliveries.
 */
@WebServlet("/shipper/my-deliveries")
public class MyDeliveriesServlet extends HttpServlet {
    
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
        
        // Get filter
        String filter = req.getParameter("filter");
        List<DeliveryOrder> deliveries;
        
        try {
            if ("history".equals(filter)) {
                deliveries = deliveryService.getDeliveryHistory(user.getId());
            } else {
                deliveries = deliveryService.getShipperDeliveries(user.getId());
            }
            
            req.setAttribute("deliveries", deliveries);
            req.setAttribute("currentFilter", filter);
            
            System.out.println("[MyDeliveriesServlet] Loaded " + (deliveries != null ? deliveries.size() : 0) + " deliveries for shipperId=" + user.getId());
            
        } catch (Exception e) {
            System.err.println("[MyDeliveriesServlet] ERROR loading deliveries: " + e.getClass().getName() + ": " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("deliveries", java.util.Collections.emptyList());
            session.setAttribute("error", "Lỗi khi tải danh sách giao hàng: " + e.getMessage());
        }
        
        req.getRequestDispatcher("/shipper/my-deliveries.jsp").forward(req, resp);
    }
}
