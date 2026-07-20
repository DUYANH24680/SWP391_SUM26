package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.StaffDetails;
import service.AdminAccountService;
import service.StaffService;
import java.io.IOException;

/**
 * EditStaffServlet - Admin: Edit staff account.
 */
@WebServlet("/admin/staff/edit")
public class EditStaffServlet extends HttpServlet {
    
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
        
        String idParam = req.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            session.setAttribute("error", "ID nhân viên không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/staff");
            return;
        }
        
        try {
            int id = Integer.parseInt(idParam.trim());
            Account staff = accountService.getStaffById(id);
            
            if (staff == null) {
                session.setAttribute("error", "Nhân viên không tồn tại.");
                resp.sendRedirect(req.getContextPath() + "/admin/staff");
                return;
            }
            
            if (!"staff".equalsIgnoreCase(staff.getRoleName())) {
                session.setAttribute("error", "Tài khoản không phải là nhân viên.");
                resp.sendRedirect(req.getContextPath() + "/admin/staff");
                return;
            }
            
            // Lấy thông tin chi tiết staff
            StaffDetails staffDetails = staffService.getStaffDetails(id);
            
            req.setAttribute("staff", staff);
            req.setAttribute("staffDetails", staffDetails);
            req.getRequestDispatcher("/admin/staff-form.jsp").forward(req, resp);
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID nhân viên không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/staff");
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
        
        // Các tham số staff details
        String staffCode = req.getParameter("staff_code");
        String cccd = req.getParameter("cccd");
        String managedArea = req.getParameter("managed_area");
        
        if (idParam == null || idParam.trim().isEmpty()) {
            session.setAttribute("error", "ID nhân viên không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/staff");
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
            req.setAttribute("val_staff_code", staffCode);
            req.setAttribute("val_cccd", cccd);
            req.setAttribute("val_managed_area", managedArea);
            
            Boolean gender = null;
            if (genderParam != null && !genderParam.isEmpty()) {
                gender = Boolean.parseBoolean(genderParam);
            }
            
            // 1. Cập nhật thông tin tài khoản
            String accountError = accountService.updateStaff(id, fullname, email, phone, address, gender);
            if (accountError != null) {
                Account staff = accountService.getStaffById(id);
                StaffDetails details = staffService.getStaffDetails(id);
                req.setAttribute("staff", staff);
                req.setAttribute("staffDetails", details);
                req.setAttribute("formError", accountError);
                req.getRequestDispatcher("/admin/staff-form.jsp").forward(req, resp);
                return;
            }
            
            // 2. Cập nhật thông tin chi tiết staff
            String detailsError = staffService.updateStaffDetails(id, staffCode, cccd, managedArea);
            if (detailsError != null) {
                Account staff = accountService.getStaffById(id);
                StaffDetails details = staffService.getStaffDetails(id);
                req.setAttribute("staff", staff);
                req.setAttribute("staffDetails", details);
                req.setAttribute("formError", detailsError);
                req.getRequestDispatcher("/admin/staff-form.jsp").forward(req, resp);
                return;
            }
            
            session.setAttribute("message", "Cập nhật nhân viên thành công!");
            resp.sendRedirect(req.getContextPath() + "/admin/staff");
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID nhân viên không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/staff");
        }
    }
}
