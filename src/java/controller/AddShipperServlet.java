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
 * AddShipperServlet - Admin: Add new shipper account.
 */
@WebServlet("/admin/shipper/add")
public class AddShipperServlet extends HttpServlet {
    
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
        
        req.getRequestDispatcher("/admin/shipper-form.jsp").forward(req, resp);
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
        
        // Lấy các tham số tài khoản
        String fullname = req.getParameter("fullname");
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String address = req.getParameter("address");
        String genderParam = req.getParameter("gender");
        
        // Lấy các tham số shipper details
        String shipperCode = req.getParameter("shipper_code");
        String birthdate = req.getParameter("birthdate");
        String cccd = req.getParameter("cccd");
        String vehicleType = req.getParameter("vehicle_type");
        String deliveryArea = req.getParameter("delivery_area");
        
        // Set attributes cho form redisplay
        req.setAttribute("val_fullname", fullname);
        req.setAttribute("val_username", username);
        req.setAttribute("val_email", email);
        req.setAttribute("val_phone", phone);
        req.setAttribute("val_address", address);
        req.setAttribute("val_gender", genderParam);
        req.setAttribute("val_shipper_code", shipperCode);
        req.setAttribute("val_birthdate", birthdate);
        req.setAttribute("val_cccd", cccd);
        req.setAttribute("val_vehicle_type", vehicleType);
        req.setAttribute("val_delivery_area", deliveryArea);
        
        // 1. Tạo tài khoản shipper
        String accountError = accountService.addShipper(fullname, username, password, email, phone, address);
        if (accountError != null) {
            req.setAttribute("formError", accountError);
            req.getRequestDispatcher("/admin/shipper-form.jsp").forward(req, resp);
            return;
        }
        
        // 2. Lấy accountId vừa tạo
        Account newShipper = accountService.getShipperByUsername(username);
        if (newShipper == null) {
            req.setAttribute("formError", "Không thể tìm thấy tài khoản vừa tạo.");
            req.getRequestDispatcher("/admin/shipper-form.jsp").forward(req, resp);
            return;
        }
        
        int accountId = newShipper.getId();
        
        // 3. Thêm thông tin chi tiết shipper (bao gồm shipperCode)
        String detailsError = shipperService.addShipperDetails(accountId, shipperCode, birthdate, cccd, vehicleType, deliveryArea);
        if (detailsError != null) {
            // Rollback: xóa tài khoản nếu thêm details thất bại
            accountService.deleteShipper(accountId);
            req.setAttribute("formError", detailsError);
            req.getRequestDispatcher("/admin/shipper-form.jsp").forward(req, resp);
            return;
        }
        
        // Thành công
        session.setAttribute("message", "Thêm shipper thành công!");
        resp.sendRedirect(req.getContextPath() + "/admin/shipper");
    }
}
