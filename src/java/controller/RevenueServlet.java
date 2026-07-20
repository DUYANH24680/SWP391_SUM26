package controller;

import service.SellerDashboardService;
import model.Account;
import model.Order;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@WebServlet(name = "RevenueServlet", urlPatterns = {"/seller/revenue"})
public class RevenueServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        Account user = (Account) session.getAttribute("user");
        if (!"seller".equalsIgnoreCase(user.getRoleName())) {
            session.setAttribute("error", "Bạn không có quyền truy cập trang Doanh Thu.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        // Read filter params
        String dateFrom = req.getParameter("dateFrom");
        String dateTo = req.getParameter("dateTo");
        String statusParam = req.getParameter("status");

        SellerDashboardService dashboardService = new SellerDashboardService();
        try {
            var data = dashboardService.getDashboardData(user.getId());
            if (data.isShopNotApproved()) {
                req.setAttribute("shopNotApproved", true);
                req.setAttribute("shopNotApprovedMsg", data.getShopNotApprovedMsg());
            } else {
                req.setAttribute("shop", data.getShop());
                req.setAttribute("totalRevenue", data.getTotalRevenue());
                req.setAttribute("totalOrders", data.getTotalOrders());
                req.setAttribute("completedOrders", data.getCompletedOrders());
                req.setAttribute("todayRevenue", data.getTodayRevenue());
                req.setAttribute("monthRevenue", data.getMonthRevenue());
                req.setAttribute("todayOrderCount", data.getTodayOrderCount());
                req.setAttribute("avgOrderValue", data.getAvgOrderValue());
                req.setAttribute("revenueByDay", data.getRevenueByDay());

                // Apply custom filters if provided
                List<Order> orders = dashboardService.getFilteredOrders(
                    data.getShop().getId(), statusParam, dateFrom, dateTo);
                req.setAttribute("filteredOrders", orders);

                double filteredRevenue = 0;
                for (Order o : orders) {
                    if (o.getStatus() == 4) {
                        filteredRevenue += (o.getFinalCost());
                    }
                }
                req.setAttribute("filteredRevenue", filteredRevenue);
            }

            req.setAttribute("dateFrom", dateFrom);
            req.setAttribute("dateTo", dateTo);
            req.setAttribute("statusParam", statusParam);

            req.getRequestDispatcher("/seller/revenue.jsp").forward(req, resp);
        } catch (Exception e) {
            System.err.println("[RevenueServlet] error: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "Đã xảy ra lỗi khi tải dữ liệu doanh thu: " + e.getMessage());
            req.getRequestDispatcher("/seller/revenue.jsp").forward(req, resp);
        }
    }
}
