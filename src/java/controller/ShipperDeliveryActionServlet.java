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

/**
 * ShipperDeliveryActionServlet - Shipper: Accept, update status, confirm delivery.
 * Handles actions: accept, pickingUp, delivering, deliver, fail
 */
@WebServlet("/shipper/delivery-action")
public class ShipperDeliveryActionServlet extends HttpServlet {
    
    private DeliveryService deliveryService = new DeliveryService();
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
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
        
        String deliveryIdParam = req.getParameter("deliveryId");
        String action = req.getParameter("action");
        String note = req.getParameter("note");
        
        if (deliveryIdParam == null || deliveryIdParam.trim().isEmpty() || 
            action == null || action.trim().isEmpty()) {
            session.setAttribute("error", "Tham số không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/shipper/my-deliveries");
            return;
        }
        
        try {
            int deliveryId = Integer.parseInt(deliveryIdParam.trim());
            String error = null;
            String successMsg = "";
            
            switch (action.trim().toLowerCase()) {
                case "accept":
                    error = deliveryService.acceptDelivery(deliveryId, user.getId());
                    successMsg = "Chấp nhận giao hàng thành công!";
                    break;
                    
                case "pickingup":
                    error = deliveryService.updateDeliveryStatus(deliveryId, user.getId(), 
                        DeliveryOrder.STATUS_PICKING_UP, note);
                    successMsg = "Đã cập nhật trạng thái: Đang lấy hàng.";
                    break;
                    
                case "delivering":
                    error = deliveryService.updateDeliveryStatus(deliveryId, user.getId(), 
                        DeliveryOrder.STATUS_DELIVERING, note);
                    successMsg = "Đã cập nhật trạng thái: Đang giao hàng.";
                    break;
                    
                case "deliver":
                    error = deliveryService.confirmDelivery(deliveryId, user.getId(), note);
                    successMsg = "Xác nhận giao hàng thành công!";
                    break;
                    
                case "fail":
                    if (note == null || note.trim().isEmpty()) {
                        error = "Vui lòng cung cấp lý do giao hàng thất bại.";
                    } else {
                        error = deliveryService.markDeliveryFailed(deliveryId, user.getId(), note);
                    }
                    successMsg = "Đã cập nhật: Giao hàng thất bại.";
                    break;
                    
                default:
                    session.setAttribute("error", "Hành động không hợp lệ.");
                    resp.sendRedirect(req.getContextPath() + "/shipper/my-deliveries");
                    return;
            }
            
            if (error != null) {
                session.setAttribute("error", error);
            } else {
                session.setAttribute("message", successMsg);
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID giao hàng không hợp lệ.");
        }
        
        resp.sendRedirect(req.getContextPath() + "/shipper/my-deliveries");
    }
}
