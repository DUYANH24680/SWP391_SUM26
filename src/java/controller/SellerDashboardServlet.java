package controller;

import dao.ShopDAO;
import dao.OrderDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Shop;
import model.Order;

import java.io.IOException;
import java.util.List;

@WebServlet("/seller/dashboard")
public class SellerDashboardServlet extends HttpServlet {
    private static final String ROLE_SELLER = "seller";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Account user = (Account) session.getAttribute("user");

        if (!ROLE_SELLER.equalsIgnoreCase(user.getRoleName())) {
            session.setAttribute("error", "Bạn không có quyền truy cập trang Seller Dashboard.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        ShopDAO shopDAO = new ShopDAO();
        OrderDAO orderDAO = new OrderDAO();
        ProductDAO productDAO = new ProductDAO();

        try {
            Shop shop = shopDAO.getShopByOwnerId(user.getId());
            if (shop == null) {
                req.setAttribute("shopNotApproved", true);
                req.setAttribute("shopNotApprovedMsg", "Cửa hàng của bạn chưa được tạo. Vui lòng tạo cửa hàng.");
            } else if (shop.getStatus() != 1) {
                req.setAttribute("shopNotApproved", true);
                req.setAttribute("shopNotApprovedMsg", "Cửa hàng của bạn chưa được phê duyệt. Vui lòng đợi admin xác nhận.");
            } else {
                int totalProducts = productDAO.countProductsByShopId(shop.getId());
                List<Order> orders = orderDAO.getOrdersByShopId(shop.getId());
                
                int totalOrders = orders.size();
                int pendingOrders = 0;
                double totalRevenue = 0.0;
                
                for (Order o : orders) {
                    if (o.getStatus() == 1) {
                        pendingOrders++;
                    }
                    // Status 4 is Delivered/Completed (Đã giao)
                    if (o.getStatus() == 4) {
                        totalRevenue += o.getFinalCost();
                    }
                }
                
                req.setAttribute("shop", shop);
                req.setAttribute("totalProducts", totalProducts);
                req.setAttribute("totalOrders", totalOrders);
                req.setAttribute("pendingOrders", pendingOrders);
                req.setAttribute("totalRevenue", totalRevenue);
            }
            req.getRequestDispatcher("/seller/dashboard.jsp").forward(req, resp);
        } catch (Exception e) {
            System.err.println("[SellerDashboardServlet] error: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "Đã xảy ra lỗi khi tải dữ liệu dashboard: " + e.getMessage());
            req.getRequestDispatcher("/seller/dashboard.jsp").forward(req, resp);
        } finally {
            shopDAO.close();
            orderDAO.close();
            productDAO.close();
        }
    }
}
