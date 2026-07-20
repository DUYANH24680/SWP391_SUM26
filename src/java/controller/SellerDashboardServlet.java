package controller;

import service.SellerDashboardService;
import model.SellerDashboardData;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;

import java.io.IOException;

@WebServlet("/seller/dashboard")
public class SellerDashboardServlet extends HttpServlet {
    private static final String ROLE_SELLER = "seller";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Account Account = (Account) session.getAttribute("Account");

        if (!ROLE_SELLER.equalsIgnoreCase(Account.getRoleName())) {
            session.setAttribute("error", "Bạn không có quyền truy cập trang Seller Dashboard.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        SellerDashboardService dashboardService = new SellerDashboardService();
        try {
            SellerDashboardData data = dashboardService.getDashboardData(Account.getId());
            if (data.isShopNotApproved()) {
                req.setAttribute("shopNotApproved", true);
                req.setAttribute("shopNotApprovedMsg", data.getShopNotApprovedMsg());
            } else {
                req.setAttribute("shop", data.getShop());
                req.setAttribute("totalProducts", data.getTotalProducts());
                req.setAttribute("totalOrders", data.getTotalOrders());
                req.setAttribute("pendingOrders", data.getPendingOrders());
                req.setAttribute("totalRevenue", data.getTotalRevenue());

            }
            req.getRequestDispatcher("/seller/dashboard.jsp").forward(req, resp);
        } catch (Exception e) {
            System.err.println("[SellerDashboardServlet] error: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "Đã xảy ra lỗi khi tải dữ liệu dashboard: " + e.getMessage());
            req.getRequestDispatcher("/seller/dashboard.jsp").forward(req, resp);
        }
    }
}

