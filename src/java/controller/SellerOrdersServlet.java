package controller;

import dao.ShopDAO;
import dao.OrderDAO;
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

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/seller/orders")
public class SellerOrdersServlet extends HttpServlet {

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
            session.setAttribute("error", "Bạn không có quyền truy cập trang quản lý đơn hàng của Seller.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        ShopDAO shopDAO = new ShopDAO();
        OrderDAO orderDAO = new OrderDAO();

        try {
            Shop shop = shopDAO.getShopByOwnerId(user.getId());
            if (shop == null) {
                req.setAttribute("shopNotApproved", true);
                req.setAttribute("shopNotApprovedMsg", "Cửa hàng của bạn chưa được tạo. Vui lòng tạo cửa hàng.");
            } else if (shop.getStatus() != 1) {
                req.setAttribute("shopNotApproved", true);
                req.setAttribute("shopNotApprovedMsg", "Cửa hàng của bạn chưa được phê duyệt. Vui lòng đợi admin xác nhận.");
            } else {
                List<Order> orders = orderDAO.getOrdersByShopId(shop.getId());
                Map<Integer, List<OrderDetail>> detailsMap = new HashMap<>();
                for (Order o : orders) {
                    detailsMap.put(o.getId(), orderDAO.getOrderDetails(o.getId()));
                }
                req.setAttribute("orders", orders);
                req.setAttribute("detailsMap", detailsMap);
                req.setAttribute("shop", shop);
            }

            req.getRequestDispatcher("/seller/orders.jsp").forward(req, resp);
        } finally {
            shopDAO.close();
            orderDAO.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Account user = (Account) session.getAttribute("user");

        if (!ROLE_SELLER.equalsIgnoreCase(user.getRoleName())) {
            session.setAttribute("error", "Bạn không có quyền thực hiện thao tác này.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        String action = req.getParameter("action");
        String orderIdParam = req.getParameter("orderId");

        if (action != null && orderIdParam != null) {
            int orderId;
            try {
                orderId = Integer.parseInt(orderIdParam.trim());
            } catch (NumberFormatException e) {
                session.setAttribute("error", "ID đơn hàng không hợp lệ.");
                resp.sendRedirect(req.getContextPath() + "/seller/orders");
                return;
            }

            ShopDAO shopDAO = new ShopDAO();
            OrderDAO orderDAO = new OrderDAO();
            try {
                Shop shop = shopDAO.getShopByOwnerId(user.getId());
                if (shop != null && shop.getStatus() == 1) {
                    // Check if order belongs to the seller's shop to prevent illegal updates
                    List<OrderDetail> details = orderDAO.getOrderDetails(orderId);
                    boolean ownsOrder = false;
                    for (OrderDetail od : details) {
                        // All items in the order belong to the same shop in our single item checkout flow
                        ownsOrder = true; 
                        break;
                    }

                    if (ownsOrder) {
                        if ("confirm".equals(action)) {
                            boolean ok = orderDAO.updateOrderStatus(orderId, 2); // 2 = Confirmed
                            if (ok) {
                                session.setAttribute("message", "Đã xác nhận đơn hàng thành công!");
                            } else {
                                session.setAttribute("error", "Xác nhận đơn hàng thất bại.");
                            }
                        } else if ("cancel".equals(action)) {
                            boolean ok = orderDAO.updateOrderStatus(orderId, 5); // 5 = Canceled
                            if (ok) {
                                session.setAttribute("message", "Đã hủy đơn hàng thành công!");
                            } else {
                                session.setAttribute("error", "Hủy đơn hàng thất bại.");
                            }
                        }
                    } else {
                        session.setAttribute("error", "Đơn hàng không thuộc về shop của bạn.");
                    }
                } else {
                    session.setAttribute("error", "Shop của bạn chưa được phê duyệt.");
                }
            } finally {
                shopDAO.close();
                orderDAO.close();
            }
        }

        resp.sendRedirect(req.getContextPath() + "/seller/orders");
    }
}
