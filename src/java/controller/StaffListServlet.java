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
import java.util.*;

/**
 * StaffListServlet - Admin: View and search staff accounts.
 */
@WebServlet("/admin/staff")
public class StaffListServlet extends HttpServlet {
    
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
        
        String keyword = req.getParameter("search");
        List<Account> staffList;
        
        try {
            staffList = accountService.searchStaff(keyword);
            
            // Load StaffDetails cho mỗi staff và lưu vào Map
            Map<Integer, StaffDetails> staffDetailsMap = new HashMap<>();
            for (Account staff : staffList) {
                StaffDetails details = staffService.getStaffDetails(staff.getId());
                if (details != null) {
                    staffDetailsMap.put(staff.getId(), details);
                }
            }
            req.setAttribute("staffDetailsMap", staffDetailsMap);
            
        } catch (Exception e) {
            System.err.println("[StaffListServlet] Error loading staff: " + e.getMessage());
            staffList = Collections.emptyList();
            session.setAttribute("error", "Lỗi khi tải danh sách nhân viên.");
        }
        
        req.setAttribute("staffList", staffList);
        req.setAttribute("searchKeyword", keyword);
        req.getRequestDispatcher("/admin/staff-list.jsp").forward(req, resp);
    }
}
