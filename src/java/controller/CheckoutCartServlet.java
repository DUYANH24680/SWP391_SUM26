package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.*;
import service.CheckoutService;
import service.NotificationService;
import dao.OrderDAO;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import service.CartService;

@WebServlet(name = "CheckoutCartServlet", urlPatterns = {"/checkout-cart"})
public class CheckoutCartServlet extends HttpServlet {

    private CheckoutService checkoutService;
    private NotificationService notifService = new NotificationService();
    private OrderDAO orderDao = new OrderDAO();

    @Override
    public void init() throws ServletException {
        this.checkoutService = new CheckoutService();
    }

    @Override
    public void destroy() {
        if (checkoutService != null) {
            checkoutService.close();
        }
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
        String selectedProductsParam = req.getParameter("selectedProducts");
        if (selectedProductsParam == null || selectedProductsParam.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/view-cart");
            return;
        }

        List<Integer> selectedProductIds = parseSelectedProductIds(selectedProductsParam);
        if (selectedProductIds.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/view-cart");
            return;
        }

        SelectedItemsCheckoutResult result = checkoutService.getSelectedItemsCheckoutData(
                account.getId(), selectedProductIds);

        if (!result.isSuccess()) {
            session.setAttribute("error", result.getError());
            resp.sendRedirect(req.getContextPath() + "/view-cart");
            return;
        }

        req.setAttribute("selectedItems", result.getSelectedItems());
        req.setAttribute("totalCost", result.getTotalCost());
        req.setAttribute("addresses", result.getAddresses());
        req.setAttribute("vouchers", result.getVouchers());
        req.setAttribute("shopMap", result.getShopMap());
        req.setAttribute("selectedProductIds", result.getSelectedProductIds());

        req.getRequestDispatcher("/checkout-cart.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Account account = (Account) session.getAttribute("Account");

        String selectedProductsParam = req.getParameter("selectedProducts");
        String recipientName = req.getParameter("recipientName");
        String recipientPhone = req.getParameter("recipientPhone");
        String address = req.getParameter("address");
        String paymentMethod = req.getParameter("paymentMethod");
        String note = req.getParameter("note");
        String platformVoucherCode = req.getParameter("platformVoucherCode");

        // Parse per-shop voucher codes (shopVoucher_1, shopVoucher_2, ...)
        java.util.Map<Integer, String> shopVoucherCodes = new java.util.HashMap<>();
        java.util.Enumeration<String> paramNames = req.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String name = paramNames.nextElement();
            if (name.startsWith("shopVoucher_")) {
                String shopIdStr = name.replace("shopVoucher_", "");
                String code = req.getParameter(name);
                try {
                    int shopId = Integer.parseInt(shopIdStr);
                    if (code != null && !code.trim().isEmpty()) {
                        shopVoucherCodes.put(shopId, code.trim());
                    }
                } catch (NumberFormatException e) {
                    // Ignore invalid shop ID
                }
            }
        }

        if (selectedProductsParam == null || selectedProductsParam.trim().isEmpty()
                || recipientName == null || recipientPhone == null || address == null) {
            session.setAttribute("error", "Vui lòng nhập đầy đủ thông tin giao hàng.");
            resp.sendRedirect(req.getContextPath() + "/view-cart");
            return;
        }

        List<Integer> selectedProductIds = parseSelectedProductIds(selectedProductsParam);

        PlaceOrderResult result = checkoutService.placeCartOrderFromSelected(
                account.getId(), selectedProductIds,
                recipientName, recipientPhone, address, paymentMethod, note,
                shopVoucherCodes, platformVoucherCode);

        if (result.isSuccess()) {
            // Notify each seller about new orders
            List<Integer> orderIds = result.getOrderIds();
            if (orderIds != null) {
                for (int orderId : orderIds) {
                    try {
                        int sellerId = orderDao.getSellerIdByOrderId(orderId);
                        if (sellerId > 0) {
                            notifService.notifyNewOrder(orderId, sellerId);
                        }
                    } catch (Exception e) {
                        System.err.println("[CheckoutCartServlet] notifyNewOrder error: " + e.getMessage());
                    }
                }
                // Notify customer that order was placed successfully
                try {
                    notifService.notifyOrderPlaced(account.getId(), orderIds);
                } catch (Exception e) {
                    System.err.println("[CheckoutCartServlet] notifyOrderPlaced error: " + e.getMessage());
                }
            }

            try {
                CartService cartService = new CartService();
                Cart updatedCart = cartService.getCartByCustomerId(account.getId());
                session.setAttribute("cart", updatedCart);
                session.setAttribute("cartCount", updatedCart != null ? updatedCart.getTotalQuantity() : 0);
                cartService.close();
            } catch (Exception e) {
                System.err.println("[CheckoutCartServlet] Error updating cart session: " + e.getMessage());
            }

            String message;
            if (result.getOrderCount() > 1) {
                message = String.format(
                        "Đặt hàng thành công! Bạn đã tạo %d đơn hàng từ %d shop khác nhau. Vui lòng kiểm tra email để xem chi tiết từng đơn.",
                        result.getOrderCount(), result.getShopCount());
            } else {
                message = "Đặt hàng thành công! Cảm ơn bạn đã đặt hàng.";
            }
            session.setAttribute("message", message);
            resp.sendRedirect(req.getContextPath() + "/my-orders");
        } else {
            session.setAttribute("error", result.getError());
            resp.sendRedirect(req.getContextPath() + "/view-cart");
        }
    }

    private List<Integer> parseSelectedProductIds(String param) {
        if (param == null || param.trim().isEmpty()) {
            return List.of();
        }
        return Arrays.stream(param.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .map(Integer::parseInt)
                .collect(Collectors.toList());
    }
}
