package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import service.AdminAccountService;
import java.io.IOException;

/**
 * EditStaffServlet - Admin: Edit staff account.
 */
@WebServlet("/admin/staff/edit")
public class EditStaffServlet extends HttpServlet {
    
    private AdminAccountService service = new AdminAccountService();
    
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
            Account staff = service.getStaffById(id);
            
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
            
            req.setAttribute("staff", staff);
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
            
            Boolean gender = null;
            if (genderParam != null && !genderParam.isEmpty()) {
                gender = Boolean.parseBoolean(genderParam);
            }
            
            String error = service.updateStaff(id, fullname, email, phone, address, gender);
            
            if (error != null) {
                Account staff = service.getStaffById(id);
                req.setAttribute("staff", staff);
                req.setAttribute("formError", error);
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
