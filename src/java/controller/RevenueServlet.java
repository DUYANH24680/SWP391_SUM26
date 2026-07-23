package controller;

import dao.ProductDAO;
import model.Account;
import model.Order;
import model.Product;
import service.SellerDashboardService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "RevenueServlet", urlPatterns = {"/seller/revenue"})
public class RevenueServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Account user = null;
        if (session != null) {
            user = (Account) session.getAttribute("Account");
            if (user == null) {
                user = (Account) session.getAttribute("user");
            }
        }

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        if (!"seller".equalsIgnoreCase(user.getRoleName())) {
            session.setAttribute("error", "Bạn không có quyền truy cập trang Doanh Thu.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        // Read filter params
        String dateFrom = req.getParameter("dateFrom");
        String dateTo = req.getParameter("dateTo");
        String statusParam = req.getParameter("status");
        String productIdStr = req.getParameter("productId");
        Integer productId = null;
        if (productIdStr != null && !productIdStr.trim().isEmpty()) {
            try {
                productId = Integer.parseInt(productIdStr);
            } catch (NumberFormatException ignored) {}
        }

        SellerDashboardService dashboardService = new SellerDashboardService();
        ProductDAO productDAO = new ProductDAO();
        try {
            var data = dashboardService.getDashboardData(user.getId());
            if (data.isShopNotApproved()) {
                req.setAttribute("shopNotApproved", true);
                req.setAttribute("shopNotApprovedMsg", data.getShopNotApprovedMsg());
            } else {
                int shopId = data.getShop().getId();
                req.setAttribute("shop", data.getShop());
                req.setAttribute("totalRevenue", data.getTotalRevenue());
                req.setAttribute("totalOrders", data.getTotalOrders());
                req.setAttribute("completedOrders", data.getCompletedOrders());
                req.setAttribute("todayRevenue", data.getTodayRevenue());
                req.setAttribute("monthRevenue", data.getMonthRevenue());
                req.setAttribute("todayOrderCount", data.getTodayOrderCount());
                req.setAttribute("avgOrderValue", data.getAvgOrderValue());
                req.setAttribute("revenueByDay", data.getRevenueByDay());

                // Fetch shop products for dropdown filter
                List<Product> shopProducts = productDAO.getProductsByShopId(shopId);
                req.setAttribute("shopProducts", shopProducts);

                Product selectedProduct = null;
                if (productId != null && shopProducts != null) {
                    for (Product p : shopProducts) {
                        if (p.getId() == productId) {
                            selectedProduct = p;
                            break;
                        }
                    }
                }
                req.setAttribute("selectedProduct", selectedProduct);

                // Apply custom filters including productId
                List<Order> orders = dashboardService.getFilteredOrders(
                    shopId, statusParam, dateFrom, dateTo, productId);
                req.setAttribute("filteredOrders", orders);

                double filteredRevenue = 0;
                if (productId != null) {
                    filteredRevenue = dashboardService.getFilteredProductRevenue(
                        shopId, statusParam, dateFrom, dateTo, productId);
                } else {
                    for (Order o : orders) {
                        if (o.getStatus() == 4) {
                            filteredRevenue += o.getFinalCost();
                        }
                    }
                }
                req.setAttribute("filteredRevenue", filteredRevenue);
            }

            req.setAttribute("dateFrom", dateFrom);
            req.setAttribute("dateTo", dateTo);
            req.setAttribute("statusParam", statusParam);
            req.setAttribute("productIdParam", productIdStr);
            req.setAttribute("productId", productIdStr);

            req.getRequestDispatcher("/seller/revenue.jsp").forward(req, resp);
        } catch (Exception e) {
            System.err.println("[RevenueServlet] error: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "Đã xảy ra lỗi khi tải dữ liệu doanh thu: " + e.getMessage());
            req.getRequestDispatcher("/seller/revenue.jsp").forward(req, resp);
        } finally {
            productDAO.close();
        }
    }
}
