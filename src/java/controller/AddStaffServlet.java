package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import service.AdminAccountService;
import service.StaffService;
import java.io.IOException;

/**
 * AddStaffServlet - Admin: Add new staff account.
 */
@WebServlet("/admin/staff/add")
public class AddStaffServlet extends HttpServlet {
    
    private AdminAccountService accountService = new AdminAccountService();
    private StaffService staffService = new StaffService();
    
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
        
        req.getRequestDispatcher("/admin/staff-form.jsp").forward(req, resp);
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
        
        // Lấy các tham số staff details
        String staffCode = req.getParameter("staff_code");
        String cccd = req.getParameter("cccd");
        String managedArea = req.getParameter("managed_area");
        
        // Set attributes cho form redisplay
        req.setAttribute("val_fullname", fullname);
        req.setAttribute("val_username", username);
        req.setAttribute("val_email", email);
        req.setAttribute("val_phone", phone);
        req.setAttribute("val_address", address);
        req.setAttribute("val_gender", genderParam);
        req.setAttribute("val_staff_code", staffCode);
        req.setAttribute("val_cccd", cccd);
        req.setAttribute("val_managed_area", managedArea);
        
        // 1. Tạo tài khoản staff
        String accountError = accountService.addStaff(fullname, username, password, email, phone, address);
        if (accountError != null) {
            req.setAttribute("formError", accountError);
            req.getRequestDispatcher("/admin/staff-form.jsp").forward(req, resp);
            return;
        }
        
        // 2. Lấy accountId vừa tạo
        Account newStaff = accountService.getStaffByUsername(username);
        if (newStaff == null) {
            req.setAttribute("formError", "Không thể tìm thấy tài khoản vừa tạo.");
            req.getRequestDispatcher("/admin/staff-form.jsp").forward(req, resp);
            return;
        }
        
        int accountId = newStaff.getId();
        
        // 3. Thêm thông tin chi tiết staff (bao gồm staffCode)
        String detailsError = staffService.addStaffDetails(accountId, staffCode, cccd, managedArea);
        if (detailsError != null) {
            // Rollback: xóa tài khoản nếu thêm details thất bại
            accountService.deleteStaff(accountId);
            req.setAttribute("formError", detailsError);
            req.getRequestDispatcher("/admin/staff-form.jsp").forward(req, resp);
            return;
        }
        
        // Thành công
        session.setAttribute("message", "Thêm nhân viên thành công!");
        resp.sendRedirect(req.getContextPath() + "/admin/staff");
    }
}
