package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.SellerOrderActionResult;
import model.SellerOrderPageData;
import service.OrderService;

import java.io.IOException;

@WebServlet("/seller/orders")
public class SellerOrdersServlet extends HttpServlet {

    private static final String ROLE_SELLER = "seller";

    private OrderService orderService;

    @Override
    public void init() throws ServletException {
        this.orderService = new OrderService();
    }

    private boolean isSeller(Account user) {
        return ROLE_SELLER.equalsIgnoreCase(user.getRoleName());
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Account user = (Account) session.getAttribute("Account");

        if (!isSeller(user)) {
            session.setAttribute("error", "Bạn không có quyền truy cập trang quản lý đơn hàng của Seller.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        SellerOrderPageData data = orderService.getSellerOrderPageData(user.getId());

        if (data.isShopNotApproved()) {
            req.setAttribute("shopNotApproved", true);
            req.setAttribute("shopNotApprovedMsg", data.getShopNotApprovedMsg());
        } else {
            req.setAttribute("orders", data.getOrders());
            req.setAttribute("detailsMap", data.getDetailsMap());
            req.setAttribute("shop", data.getShop());
        }

        req.getRequestDispatcher("/seller/orders.jsp").forward(req, resp);
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

        if (!isSeller(user)) {
            session.setAttribute("error", "Bạn không có quyền thực hiện thao tác này.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        String action = req.getParameter("action");
        String orderIdParam = req.getParameter("orderId");

        if (action != null && orderIdParam != null && !orderIdParam.trim().isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdParam.trim());
                SellerOrderActionResult result = orderService.processSellerOrderAction(orderId, user.getId(), action);
                session.setAttribute(result.isSuccess() ? "message" : "error", result.getMessage());
            } catch (NumberFormatException e) {
                session.setAttribute("error", "ID đơn hàng không hợp lệ.");
            }
        }

        resp.sendRedirect(req.getContextPath() + "/seller/orders");
    }
}
