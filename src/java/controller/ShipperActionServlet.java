package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import service.AdminAccountService;
import service.ShipperService;
import java.io.IOException;

/**
 * ShipperActionServlet - Admin: Lock, Unlock, Delete shipper account.
 * Handles actions: lock, unlock, delete
 */
@WebServlet("/admin/shipper/action")
public class ShipperActionServlet extends HttpServlet {
    
    private AdminAccountService accountService = new AdminAccountService();
    private ShipperService shipperService = new ShipperService();
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        Account user = (Account) session.getAttribute("Account");
        if (!"admin".equalsIgnoreCase(user.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }
        
        String idParam = req.getParameter("id");
        String action = req.getParameter("action");
        
        if (idParam == null || idParam.trim().isEmpty() || action == null || action.trim().isEmpty()) {
            session.setAttribute("error", "Tham số không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/shipper");
            return;
        }
        
        try {
            int id = Integer.parseInt(idParam.trim());
            boolean success = false;
            String successMsg = "";
            String errorMsg = "";
            
            switch (action.trim().toLowerCase()) {
                case "lock":
                    success = accountService.lockShipper(id);
                    successMsg = "Khóa tài khoản thành công.";
                    errorMsg = "Khóa tài khoản thất bại.";
                    break;
                case "unlock":
                    success = accountService.unlockShipper(id);
                    successMsg = "Mở khóa tài khoản thành công.";
                    errorMsg = "Mở khóa tài khoản thất bại.";
                    break;
                case "delete":
                    // Xóa ShipperDetails trước
                    shipperService.deleteShipperDetails(id);
                    // Xóa vĩnh viễn tài khoản
                    try {
                        success = accountService.hardDeleteShipper(id);
                        successMsg = "Xóa tài khoản thành công.";
                        errorMsg = "Xóa tài khoản thất bại.";
                    } catch (RuntimeException ex) {
                        success = false;
                        errorMsg = accountService.getHardDeleteErrorMessageForShipper(id, ex);
                    }
                    break;
                default:
                    session.setAttribute("error", "Hành động không hợp lệ.");
                    resp.sendRedirect(req.getContextPath() + "/admin/shipper");
                    return;
            }
            
            if (success) {
                session.setAttribute("message", successMsg);
            } else {
                session.setAttribute("error", errorMsg);
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID shipper không hợp lệ.");
        }
        
        resp.sendRedirect(req.getContextPath() + "/admin/shipper");
    }
}
