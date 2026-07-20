package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.ShipperDetails;
import service.AdminAccountService;
import service.ShipperService;
import java.io.IOException;

/**
 * EditShipperServlet - Admin: Edit shipper account.
 */
@WebServlet("/admin/shipper/edit")
public class EditShipperServlet extends HttpServlet {
    
    private AdminAccountService accountService = new AdminAccountService();
    private ShipperService shipperService = new ShipperService();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
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
        if (idParam == null || idParam.trim().isEmpty()) {
            session.setAttribute("error", "ID shipper không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/shipper");
            return;
        }
        
        try {
            int id = Integer.parseInt(idParam.trim());
            Account shipper = accountService.getShipperById(id);
            
            if (shipper == null) {
                session.setAttribute("error", "Shipper không tồn tại.");
                resp.sendRedirect(req.getContextPath() + "/admin/shipper");
                return;
            }
            
            if (!"shipper".equalsIgnoreCase(shipper.getRoleName())) {
                session.setAttribute("error", "Tài khoản không phải là shipper.");
                resp.sendRedirect(req.getContextPath() + "/admin/shipper");
                return;
            }
            
            // Lấy thông tin chi tiết shipper
            ShipperDetails shipperDetails = shipperService.getShipperDetails(id);
            
            req.setAttribute("shipper", shipper);
            req.setAttribute("shipperDetails", shipperDetails);
            req.getRequestDispatcher("/admin/shipper-form.jsp").forward(req, resp);
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID shipper không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/shipper");
        }
    }
    
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
        String fullname = req.getParameter("fullname");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String address = req.getParameter("address");
        String genderParam = req.getParameter("gender");
        
        // Các tham số shipper details
        String shipperCode = req.getParameter("shipper_code");
        String birthdate = req.getParameter("birthdate");
        String cccd = req.getParameter("cccd");
        String vehicleType = req.getParameter("vehicle_type");
        String deliveryArea = req.getParameter("delivery_area");
        
        if (idParam == null || idParam.trim().isEmpty()) {
            session.setAttribute("error", "ID shipper không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/shipper");
            return;
        }
        
        try {
            int id = Integer.parseInt(idParam.trim());
            
            // Keep values for form redisplay
            req.setAttribute("val_fullname", fullname);
            req.setAttribute("val_email", email);
            req.setAttribute("val_phone", phone);
            req.setAttribute("val_address", address);
            req.setAttribute("val_gender", genderParam);
            req.setAttribute("val_shipper_code", shipperCode);
            req.setAttribute("val_birthdate", birthdate);
            req.setAttribute("val_cccd", cccd);
            req.setAttribute("val_vehicle_type", vehicleType);
            req.setAttribute("val_delivery_area", deliveryArea);
            
            Boolean gender = null;
            if (genderParam != null && !genderParam.isEmpty()) {
                gender = Boolean.parseBoolean(genderParam);
            }
            
            // 1. Cập nhật thông tin tài khoản
            String accountError = accountService.updateShipper(id, fullname, email, phone, address, gender);
            if (accountError != null) {
                Account shipper = accountService.getShipperById(id);
                ShipperDetails details = shipperService.getShipperDetails(id);
                req.setAttribute("shipper", shipper);
                req.setAttribute("shipperDetails", details);
                req.setAttribute("formError", accountError);
                req.getRequestDispatcher("/admin/shipper-form.jsp").forward(req, resp);
                return;
            }
            
            // 2. Cập nhật thông tin chi tiết shipper
            String detailsError = shipperService.updateShipperDetails(id, shipperCode, birthdate, cccd, vehicleType, deliveryArea);
            if (detailsError != null) {
                Account shipper = accountService.getShipperById(id);
                ShipperDetails details = shipperService.getShipperDetails(id);
                req.setAttribute("shipper", shipper);
                req.setAttribute("shipperDetails", details);
                req.setAttribute("formError", detailsError);
                req.getRequestDispatcher("/admin/shipper-form.jsp").forward(req, resp);
                return;
            }
            
            session.setAttribute("message", "Cập nhật shipper thành công!");
            resp.sendRedirect(req.getContextPath() + "/admin/shipper");
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID shipper không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/shipper");
        }
    }
}
