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
import model.OrderTracking;
import model.Order;
import java.io.IOException;
import java.util.List;

/**
 * ShipperDeliveryDetailServlet - Shipper: View delivery details with tracking.
 */
@WebServlet("/shipper/delivery-detail")
public class ShipperDeliveryDetailServlet extends HttpServlet {
    
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
        
        String deliveryIdParam = req.getParameter("id");
        if (deliveryIdParam == null || deliveryIdParam.trim().isEmpty()) {
            session.setAttribute("error", "ID giao hàng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/shipper/my-deliveries");
            return;
        }
        
        try {
            int deliveryId = Integer.parseInt(deliveryIdParam.trim());
            DeliveryOrder delivery = deliveryService.getDeliveryById(deliveryId);
            
            if (delivery == null) {
                session.setAttribute("error", "Giao hàng không tồn tại.");
                resp.sendRedirect(req.getContextPath() + "/shipper/my-deliveries");
                return;
            }
            
            // Verify ownership
            if (delivery.getShipperId() == null || delivery.getShipperId() != user.getId()) {
                session.setAttribute("error", "Bạn không có quyền xem giao hàng này.");
                resp.sendRedirect(req.getContextPath() + "/shipper/my-deliveries");
                return;
            }
            
            // Get tracking history
            List<OrderTracking> trackingHistory = deliveryService.getOrderTracking(delivery.getOrderId());
            
            req.setAttribute("delivery", delivery);
            req.setAttribute("trackingHistory", trackingHistory);
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID giao hàng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/shipper/my-deliveries");
        } catch (Exception e) {
            System.err.println("[ShipperDeliveryDetailServlet] Error: " + e.getMessage());
            session.setAttribute("error", "Lỗi khi tải chi tiết giao hàng.");
            resp.sendRedirect(req.getContextPath() + "/shipper/my-deliveries");
        }
        
        req.getRequestDispatcher("/shipper/delivery-detail.jsp").forward(req, resp);
    }
}
