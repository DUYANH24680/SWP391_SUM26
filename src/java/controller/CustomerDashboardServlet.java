package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.CustomerOrdersData;
import model.Order;
import model.OrderDetail;
import service.OrderService;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "CustomerDashboardServlet", urlPatterns = {"/customer-dashboard"})
public class CustomerDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Account account = (Account) session.getAttribute("Account");
        OrderService orderService = new OrderService();
        CustomerOrdersData data = orderService.getCustomerOrdersWithDetails(account.getId(), null);

        List<Order> orders = data.getOrders();
        Map<Integer, List<OrderDetail>> detailsMap = data.getDetailsMap();

        double totalSpent = 0;
        int pendingCount = 0;
        int confirmedCount = 0;
        int shippingCount = 0;
        int deliveredCount = 0;
        int canceledCount = 0;

        if (orders != null) {
            for (Order order : orders) {
                totalSpent += order.getFinalCost();
                switch (order.getStatus()) {
                    case 1 -> pendingCount++;
                    case 2 -> confirmedCount++;
                    case 3 -> shippingCount++;
                    case 4 -> deliveredCount++;
                    case 5 -> canceledCount++;
                    default -> {}
                }
            }
        }

        req.setAttribute("orders", orders);
        req.setAttribute("detailsMap", detailsMap);
        req.setAttribute("totalOrders", orders != null ? orders.size() : 0);
        req.setAttribute("totalSpent", totalSpent);
        req.setAttribute("pendingCount", pendingCount);
        req.setAttribute("confirmedCount", confirmedCount);
        req.setAttribute("shippingCount", shippingCount);
        req.setAttribute("deliveredCount", deliveredCount);
        req.setAttribute("canceledCount", canceledCount);
        req.getRequestDispatcher("/customer-dashboard.jsp").forward(req, resp);
    }
}

