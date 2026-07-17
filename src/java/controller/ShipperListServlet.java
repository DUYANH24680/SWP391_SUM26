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
import java.util.List;

/**
 * ShipperListServlet - Admin: View and search shipper accounts.
 */
@WebServlet("/admin/shipper")
public class ShipperListServlet extends HttpServlet {
    
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
        
        String keyword = req.getParameter("search");
        List<Account> shipperList;
        
        try {
            shipperList = service.searchShippers(keyword);
        } catch (Exception e) {
            System.err.println("[ShipperListServlet] Error loading shippers: " + e.getMessage());
            shipperList = java.util.Collections.emptyList();
            session.setAttribute("error", "Lỗi khi tải danh sách shipper.");
        }
        
        req.setAttribute("shipperList", shipperList);
        req.setAttribute("searchKeyword", keyword);
        req.getRequestDispatcher("/admin/shipper-list.jsp").forward(req, resp);
    }
}
