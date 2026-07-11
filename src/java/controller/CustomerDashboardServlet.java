package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.CustomerDashboardData;
import service.CustomerDashboardService;

import java.io.IOException;

@WebServlet(name = "CustomerDashboardServlet", urlPatterns = {"/customer-dashboard"})
public class CustomerDashboardServlet extends HttpServlet {

    private CustomerDashboardService dashboardService;

    @Override
    public void init() throws ServletException {
        this.dashboardService = new CustomerDashboardService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Account account = (Account) session.getAttribute("Account");
        CustomerDashboardData data = dashboardService.getDashboardData(account.getId());

        req.setAttribute("orders", data.getOrders());
        req.setAttribute("detailsMap", data.getDetailsMap());
        req.setAttribute("totalOrders", data.getTotalOrders());
        req.setAttribute("totalSpent", data.getTotalSpent());
        req.setAttribute("pendingCount", data.getPendingCount());
        req.setAttribute("confirmedCount", data.getConfirmedCount());
        req.setAttribute("shippingCount", data.getShippingCount());
        req.setAttribute("deliveredCount", data.getDeliveredCount());
        req.setAttribute("canceledCount", data.getCanceledCount());
        req.setAttribute("recentOrderCount", data.getRecentOrderCount());
        req.setAttribute("avgOrderValue", data.getAvgOrderValue());
        req.setAttribute("monthlySpend", data.getMonthlySpend());
        req.setAttribute("recentOrders", data.getRecentOrders());

        req.getRequestDispatcher("/customer-dashboard.jsp").forward(req, resp);
    }
}
