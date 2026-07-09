package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.*;
import service.CheckoutService;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private CheckoutService checkoutService;

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
        Account user = (Account) session.getAttribute("Account");

        String recipientName = req.getParameter("recipientName");
        String recipientPhone = req.getParameter("recipientPhone");
        String address = req.getParameter("address");
        String paymentMethod = req.getParameter("paymentMethod");
        String note = req.getParameter("note");
        String voucherCode = req.getParameter("voucherCode");

        Integer productId = checkoutService.parseProductId(req.getParameter("productId"));
        Integer buyNowProductId = productId;
        Integer buyNowQuantity = null;
        if (buyNowProductId != null) {
            buyNowQuantity = checkoutService.parseQuantity(req.getParameter("quantity"), 1);
        }

        try {
            PlaceOrderResult result = checkoutService.placeOrder(
                user.getId(), recipientName, recipientPhone, address,
                paymentMethod, note, voucherCode, buyNowProductId, buyNowQuantity
            );

            if (result.isSuccess()) {
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
        String code = req.getParameter("code");
        double total = checkoutService.parseDouble(req.getParameter("total"));

        VoucherCheckResult result = checkoutService.validateVoucher(code, total);

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        out.write(result.toJson());
        out.flush();
    }
}
