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
 * AddShipperServlet - Admin: Add new shipper account.
 */
@WebServlet("/admin/shipper/add")
public class AddShipperServlet extends HttpServlet {
    
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
        
        String fullname = req.getParameter("fullname");
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        
        // Keep values for form redisplay
        req.setAttribute("val_fullname", fullname);
        req.setAttribute("val_username", username);
        req.setAttribute("val_email", email);
        req.setAttribute("val_phone", phone);
        
        String error = service.addShipper(fullname, username, password, email, phone);
        
        if (error != null) {
            req.setAttribute("formError", error);
            req.getRequestDispatcher("/admin/shipper-form.jsp").forward(req, resp);
            return;
        }
        
        session.setAttribute("message", "Thêm shipper thành công!");
        resp.sendRedirect(req.getContextPath() + "/admin/shipper");
    }
}
