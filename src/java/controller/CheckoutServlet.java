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
import dao.AccountDAO;
import dao.OrderDAO;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

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
        Account user = (Account) session.getAttribute("Account");

        String action = req.getParameter("action");
        if ("checkVoucher".equals(action)) {
            handleCheckVoucher(req, resp);
            return;
        }
        if ("checkVouchers".equals(action)) {
            handleCheckVouchers(req, resp);
            return;
        }

        String prodIdParam = req.getParameter("productId");
        Integer productId = checkoutService.parseProductId(prodIdParam);

        if (productId != null) {
            loadBuyNowPage(req, resp, session, user.getId(), productId, req.getParameter("quantity"));
        } else {
            loadCartPage(req, resp, session, user.getId());
        }
    }

    private void loadBuyNowPage(HttpServletRequest req, HttpServletResponse resp,
                                 HttpSession session, int customerId, int productId, String qtyParam)
            throws ServletException, IOException {
        int quantity = checkoutService.parseQuantity(qtyParam, 1);
        BuyNowCheckoutResult result = checkoutService.getBuyNowCheckoutData(customerId, productId, quantity);

        if (!result.isSuccess()) {
            session.setAttribute("error", result.getError());
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        req.setAttribute("product", result.getProduct());
        req.setAttribute("quantity", result.getQuantity());
        req.setAttribute("isBuyNow", true);
        req.setAttribute("addresses", result.getAddresses());
        req.setAttribute("vouchers", result.getVouchers());
        req.setAttribute("shop", result.getShop());

        req.getRequestDispatcher("/checkout.jsp").forward(req, resp);
    }

    private void loadCartPage(HttpServletRequest req, HttpServletResponse resp,
                               HttpSession session, int customerId)
            throws ServletException, IOException {
        CartCheckoutResult result = checkoutService.getCartCheckoutData(customerId);

        if (!result.isSuccess()) {
            if (result.isEmptyCart()) {
                session.setAttribute("error", result.getError());
                resp.sendRedirect(req.getContextPath() + "/cart");
            } else {
                session.setAttribute("error", result.getError());
                resp.sendRedirect(req.getContextPath() + "/cart");
            }
            return;
        }

        req.setAttribute("cart", result.getCart());
        req.setAttribute("isBuyNow", false);
        req.setAttribute("addresses", result.getAddresses());
        req.setAttribute("vouchers", result.getVouchers());
        req.setAttribute("shopMap", result.getShopMap());

        req.getRequestDispatcher("/checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Handle AJAX voucher check
        String action = req.getParameter("action");
        if ("checkVouchers".equals(action)) {
            handleCheckVouchers(req, resp);
            return;
        }

        Account user = (Account) session.getAttribute("Account");

        String recipientName = req.getParameter("recipientName");
        String recipientPhone = req.getParameter("recipientPhone");
        String address = req.getParameter("address");
        String paymentMethod = req.getParameter("paymentMethod");
        String note = req.getParameter("note");
        String platformVoucherCode = req.getParameter("platformVoucherCode");

        // Parse per-shop voucher codes (shopVoucher_1, shopVoucher_2, ...)
        Map<Integer, String> shopVoucherCodes = new HashMap<>();
        // Parse per-shop notes (note_1, note_2, ...)
        Map<Integer, String> shopNotes = new HashMap<>();
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
                    // Ignore
                }
            } else if (name.startsWith("note_")) {
                String shopIdStr = name.replace("note_", "");
                String noteValue = req.getParameter(name);
                try {
                    int shopId = Integer.parseInt(shopIdStr);
                    if (noteValue != null && !noteValue.trim().isEmpty()) {
                        shopNotes.put(shopId, noteValue.trim());
                    }
                } catch (NumberFormatException e) {
                    // Ignore
                }
            }
        }

        Integer productId = checkoutService.parseProductId(req.getParameter("productId"));
        Integer buyNowProductId = productId;
        Integer buyNowQuantity = null;
        if (buyNowProductId != null) {
            buyNowQuantity = checkoutService.parseQuantity(req.getParameter("quantity"), 1);
        }

        try {
            PlaceOrderResult result = checkoutService.placeOrder(
                user.getId(), recipientName, recipientPhone, address,
                paymentMethod, note, shopNotes, shopVoucherCodes, platformVoucherCode,
                buyNowProductId, buyNowQuantity
            );

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
                            System.err.println("[CheckoutServlet] notifyNewOrder error: " + e.getMessage());
                        }
                    }
                    // Notify customer that order was placed successfully
                    try {
                        notifService.notifyOrderPlaced(user.getId(), orderIds);
                    } catch (Exception e) {
                        System.err.println("[CheckoutServlet] notifyOrderPlaced error: " + e.getMessage());
                    }
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
            } else {
                session.setAttribute("error", result.getError());
            }
            resp.sendRedirect(req.getContextPath() + "/my-orders");

        } catch (IllegalArgumentException e) {
            req.setAttribute("error", e.getMessage());
            doGet(req, resp);
        } catch (Exception e) {
            System.err.println("[CheckoutServlet] doPost error: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "Lỗi xử lý đơn hàng: " + e.getMessage());
            doGet(req, resp);
        }
    }

    private void handleCheckVoucher(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        try {
            String code = req.getParameter("code");
            double total = checkoutService.parseDouble(req.getParameter("total"));

            VoucherCheckResult result = checkoutService.validateVoucher(code, total);

            sendJson(resp, result.toJson());
        } catch (Exception e) {
            System.err.println("[CheckoutServlet] handleCheckVoucher error: " + e.getMessage());
            e.printStackTrace();
            sendJson(resp, "{\"valid\":false,\"msg\":\"Lỗi máy chủ khi kiểm tra mã giảm giá. Vui lòng thử lại.\"}");
        }
    }

    private void handleCheckVouchers(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        try {
            String platformVoucherCode = req.getParameter("platformVoucherCode");
            String totalSubtotalStr = req.getParameter("totalSubtotal");
            String shopSubtotalsJson = req.getParameter("shopSubtotals");

            // Parse shop subtotals using regex — handles scientific notation and locale issues safely
            Map<Integer, Double> shopSubtotals = parseShopSubtotals(shopSubtotalsJson);

            // Parse per-shop voucher codes (shopVoucher_1, shopVoucher_2, ...)
            Map<Integer, String> shopVoucherCodes = new HashMap<>();
            for (Integer shopId : shopSubtotals.keySet()) {
                String code = req.getParameter("shopVoucher_" + shopId);
                if (code != null && !code.trim().isEmpty()) {
                    shopVoucherCodes.put(shopId, code.trim());
                }
            }

            double totalSubtotal = checkoutService.parseDouble(totalSubtotalStr);

            VoucherValidationRequest request = new VoucherValidationRequest();
            request.setShopVoucherCodes(shopVoucherCodes);
            request.setPlatformVoucherCode(platformVoucherCode);
            request.setShopSubtotals(shopSubtotals);
            request.setTotalSubtotal(totalSubtotal);

            VoucherValidationResult result = checkoutService.validateBothVouchers(request);

            sendJson(resp, result.toJson());
        } catch (Exception e) {
            System.err.println("[CheckoutServlet] handleCheckVouchers error: " + e.getMessage());
            e.printStackTrace();
            sendJson(resp, "{\"success\":false,\"message\":\"Lỗi máy chủ khi xử lý mã giảm giá. Vui lòng thử lại.\"}");
        }
    }

    /**
     * Parses a JSON object string like {"1":300000,"2":200000} into a Map.
     * Uses regex to extract integer keys and numeric values, avoiding locale-sensitive parsing.
     */
    private Map<Integer, Double> parseShopSubtotals(String json) {
        Map<Integer, Double> result = new HashMap<>();
        if (json == null || json.trim().isEmpty()) {
            return result;
        }
        try {
            // Match "key": value patterns — value can be integer, decimal, or scientific notation
            java.util.regex.Pattern p = java.util.regex.Pattern.compile("\"(\\d+)\"\\s*:\\s*([+-]?\\d+(?:\\.\\d+)?(?:[eE][+-]?\\d+)?)");
            java.util.regex.Matcher m = p.matcher(json.trim());
            while (m.find()) {
                int key = Integer.parseInt(m.group(1));
                double val = Double.parseDouble(m.group(2));
                result.put(key, val);
            }
        } catch (Exception e) {
            System.err.println("[CheckoutServlet] parseShopSubtotals failed: " + e.getMessage());
        }
        return result;
    }

    private void sendJson(HttpServletResponse resp, String json) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        out.write(json);
        out.flush();
    }
}
