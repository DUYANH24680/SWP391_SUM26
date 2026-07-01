package controller;

import dao.ShopDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Shop;
import model.Order;
import model.OrderDetail;
import service.OrderService;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/seller/orders")
public class SellerOrdersServlet extends HttpServlet {

    private static final String ROLE_SELLER = "seller";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Account user = (Account) session.getAttribute("Account");

        if (!ROLE_SELLER.equalsIgnoreCase(user.getRoleName())) {
            session.setAttribute("error", "Bạn không có quyền truy cập trang quản lý đơn hàng của Seller.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        ShopDAO shopDAO = new ShopDAO();
        try {
            Shop shop = shopDAO.getShopByOwnerId(user.getId());
            if (shop == null) {
                req.setAttribute("shopNotApproved", true);
                req.setAttribute("shopNotApprovedMsg", "Cửa hàng của bạn chưa được tạo hoặc chưa được phê duyệt. Vui lòng đợi admin xác nhận.");
            } else {
                OrderService orderService = new OrderService();
                List<Order> orders = orderService.getOrdersByShopId(shop.getId());
                Map<Integer, List<OrderDetail>> detailsMap = orderService.getOrderDetailsMap(orders);
                req.setAttribute("orders", orders);
                req.setAttribute("detailsMap", detailsMap);
                req.setAttribute("shop", shop);
            }

            req.getRequestDispatcher("/seller/orders.jsp").forward(req, resp);
        } finally {
            shopDAO.close();
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

        if (!ROLE_SELLER.equalsIgnoreCase(user.getRoleName())) {
            session.setAttribute("error", "Bạn không có quyền thực hiện thao tác này.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        String action = req.getParameter("action");
        String orderIdParam = req.getParameter("orderId");

        if (action != null && orderIdParam != null) {
            try {
                int orderId = Integer.parseInt(orderIdParam.trim());
                OrderService orderService = new OrderService();
                orderService.updateOrderStatusBySeller(orderId, user.getId(), action);
                if ("confirm".equals(action)) {
                    session.setAttribute("message", "Đã xác nhận đơn hàng thành công!");
                } else if ("cancel".equals(action)) {
                    session.setAttribute("message", "Đã hủy đơn hàng thành công!");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("error", "ID đơn hàng không hợp lệ.");
            } catch (RuntimeException e) {
                session.setAttribute("error", e.getMessage());
            }
        }

        resp.sendRedirect(req.getContextPath() + "/seller/orders");
    }
}
