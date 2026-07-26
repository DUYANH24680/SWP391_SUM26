package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.DeliveryOrder;
import service.DeliveryService;
import service.NotificationService;
import java.io.IOException;

/**
 * StaffReassignDeliveryServlet - Staff: Reassign a stale delivery to another shipper.
 */
@WebServlet("/staff/reassign-delivery")
public class StaffReassignDeliveryServlet extends HttpServlet {

    private DeliveryService deliveryService = new DeliveryService();
    private NotificationService notifService = new NotificationService();

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
            String deliveryIdParam = req.getParameter("deliveryId");
            String newShipperIdParam = req.getParameter("newShipperId");
            String note = req.getParameter("note");

            if (deliveryIdParam == null || deliveryIdParam.isEmpty()) {
                session.setAttribute("error", "ID giao hàng không hợp lệ.");
                resp.sendRedirect(req.getContextPath() + "/staff/delivery");
                return;
            }
            if (newShipperIdParam == null || newShipperIdParam.isEmpty()) {
                session.setAttribute("error", "Vui lòng chọn shipper mới.");
                resp.sendRedirect(req.getContextPath() + "/staff/delivery");
                return;
            }

            int deliveryId = Integer.parseInt(deliveryIdParam);
            int newShipperId = Integer.parseInt(newShipperIdParam);
            int staffId = user.getId();

            DeliveryOrder delivery = deliveryService.getDeliveryById(deliveryId);
            if (delivery == null) {
                session.setAttribute("error", "Giao hàng không tồn tại.");
                resp.sendRedirect(req.getContextPath() + "/staff/delivery");
                return;
            }

            String errorMsg = deliveryService.reassignDelivery(deliveryId, newShipperId, staffId, note);
            if (errorMsg != null) {
                session.setAttribute("error", errorMsg);
                resp.sendRedirect(req.getContextPath() + "/staff/delivery");
                return;
            }

            notifService.notifyDeliveryAssignment(newShipperId, delivery.getOrderId(), deliveryId, "Đơn hàng được chuyển giao mới");
            session.setAttribute("message", "Đã chuyển giao đơn cho shipper mới thành công.");
            resp.sendRedirect(req.getContextPath() + "/staff/delivery");
        } catch (NumberFormatException e) {
            System.err.println("[StaffReassignDeliveryServlet] NumberFormatException: " + e.getMessage());
            session.setAttribute("error", "Dữ liệu không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/staff/delivery");
        } catch (Exception e) {
            System.err.println("[StaffReassignDeliveryServlet] Error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi khi chuyển giao đơn hàng.");
            resp.sendRedirect(req.getContextPath() + "/staff/delivery");
        }
    }
}
