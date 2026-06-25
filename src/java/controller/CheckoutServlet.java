package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.CheckoutPageResult;
import model.PlaceOrderResult;
import model.VoucherCheckResult;
import service.CheckoutService;
import service.OrderService;
import service.CartService;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Account account = (Account) session.getAttribute("Account");

        String action = req.getParameter("action");
        if ("checkVoucher".equals(action)) {
            handleCheckVoucher(req, resp);
            return;
        }

        String prodIdParam = req.getParameter("productId");
        if (prodIdParam == null || prodIdParam.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        int productId;
        int quantity = 1;
        try {
            productId = Integer.parseInt(prodIdParam.trim());
            String qtyParam = req.getParameter("quantity");
            if (qtyParam != null && !qtyParam.trim().isEmpty()) {
                quantity = Integer.parseInt(qtyParam.trim());
            }
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Tham số không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        CheckoutService checkoutService = new CheckoutService();
        CheckoutPageResult result = checkoutService.getCheckoutPageData(
                account.getId(), productId, quantity);

        if (!result.isSuccess()) {
            session.setAttribute("error", result.getError());
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        req.setAttribute("product", result.getProduct());
        req.setAttribute("addresses", result.getAddresses());
        req.setAttribute("vouchers", result.getVouchers());
        req.setAttribute("quantity", result.getQuantity());
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
        Account account = (Account) session.getAttribute("Account");

        String prodIdParam = req.getParameter("productId");
        String qtyParam = req.getParameter("quantity");
        String recipientName = req.getParameter("recipientName");
        String recipientPhone = req.getParameter("recipientPhone");
        String address = req.getParameter("address");
        String paymentMethod = req.getParameter("paymentMethod");
        String note = req.getParameter("note");
        String voucherCode = req.getParameter("voucherCode");

        if (prodIdParam == null || qtyParam == null || recipientName == null
                || recipientPhone == null || address == null) {
            req.setAttribute("error", "Vui lòng nhập đầy đủ thông tin giao hàng.");
            doGet(req, resp);
            return;
        }

        int productId;
        int quantity;
        try {
            productId = Integer.parseInt(prodIdParam.trim());
            quantity = Integer.parseInt(qtyParam.trim());
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Tham số không hợp lệ.");
            doGet(req, resp);
            return;
        }

        try {
            OrderService orderService = new OrderService();
            PlaceOrderResult result = orderService.placeOrder(
                    account.getId(), productId, quantity, recipientName, recipientPhone,
                    address, paymentMethod, note, voucherCode);

            if (result.isSuccess()) {
                CartService cartService = new CartService();
                try {
                    model.Cart cart = cartService.getCartByCustomerId(account.getId());
                    if (cart != null) {
                        session.setAttribute("cart", cart);
                        session.setAttribute("cartCount", cart.getTotalQuantity());
                    } else {
                        session.removeAttribute("cart");
                        session.setAttribute("cartCount", 0);
                    }
                } catch (Exception e) {
                    System.err.println("[CheckoutServlet] Error updating cart session: " + e.getMessage());
                } finally {
                    cartService.close();
                }
                session.setAttribute("message", "Đặt hàng thành công!");
                resp.sendRedirect(req.getContextPath() + "/my-orders");
            } else {
                req.setAttribute("error", result.getError());
                doGet(req, resp);
            }
        } catch (Exception e) {
            System.err.println("[CheckoutServlet] Error during checkout doPost: " + e.getMessage());
            req.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            doGet(req, resp);
        }
    }

    private void handleCheckVoucher(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String code = req.getParameter("code");
        String totalParam = req.getParameter("total");

        double total = 0;
        try {
            if (totalParam != null) {
                total = Double.parseDouble(totalParam.trim());
            }
        } catch (NumberFormatException e) {
            // ignore
        }

        CheckoutService checkoutService = new CheckoutService();
        VoucherCheckResult result = checkoutService.validateVoucher(code, total);

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        out.write(result.toJson());
        out.flush();
    }
}
