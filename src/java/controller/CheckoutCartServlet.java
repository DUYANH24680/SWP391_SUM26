package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Cart;
import model.CartItem;
import model.DeliveryAddress;
import model.PlaceOrderResult;
import model.Product;
import model.Voucher;
import service.CartService;
import service.CheckoutService;
import service.OrderService;
import dao.DeliveryAddressDAO;
import dao.ProductDAO;
import dao.VoucherDAO;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(name = "CheckoutCartServlet", urlPatterns = {"/checkout-cart"})
public class CheckoutCartServlet extends HttpServlet {

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

        List<Integer> selectedProductIds = Arrays.stream(selectedProductsParam.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .map(Integer::parseInt)
                .collect(Collectors.toList());

        CartService cartService = new CartService();
        Cart cart = cartService.getCartByCustomerId(account.getId());
        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/view-cart");
            return;
        }

        List<CartItem> selectedItems = new ArrayList<>();
        for (CartItem item : cart.getItems()) {
            if (selectedProductIds.contains(item.getProductId())) {
                selectedItems.add(item);
            }
        }

        if (selectedItems.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/view-cart");
            return;
        }

        CheckoutService checkoutService = new CheckoutService();
        ProductDAO productDAO = new ProductDAO();
        DeliveryAddressDAO addressDAO = new DeliveryAddressDAO();
        VoucherDAO voucherDAO = new VoucherDAO();

        try {
            System.out.println("[CheckoutCartServlet] doGet: selectedProductIds=" + selectedProductIds);
            System.out.println("[CheckoutCartServlet] doGet: customerId=" + account.getId());

            double totalCost = 0;
            for (CartItem item : selectedItems) {
                Product product = productDAO.getProductById(item.getProductId());
                if (product != null && product.getSalePrice() > 0 && product.getSalePrice() < product.getOriginalPrice()) {
                    totalCost += product.getSalePrice() * item.getQuantity();
                } else if (product != null) {
                    totalCost += product.getOriginalPrice() * item.getQuantity();
                }
                System.out.println("[CheckoutCartServlet] doGet: productId=" + item.getProductId() + ", unitPrice=" + (product != null ? product.getOriginalPrice() : "NULL"));
            }
            System.out.println("[CheckoutCartServlet] doGet: totalCost=" + totalCost);

            List<DeliveryAddress> addresses = addressDAO.findByCustomerId(account.getId());
            System.out.println("[CheckoutCartServlet] doGet: addresses count=" + (addresses != null ? addresses.size() : "NULL"));

            List<Voucher> vouchers = voucherDAO.getAllActiveVouchers();
            System.out.println("[CheckoutCartServlet] doGet: vouchers count=" + (vouchers != null ? vouchers.size() : "NULL"));

            // Fetch shops for all selected cart items
            dao.ShopDAO shopDAO = new dao.ShopDAO();
            try {
                java.util.Map<Integer, model.Shop> shopMap = new java.util.HashMap<>();
                for (CartItem item : selectedItems) {
                    Product p = productDAO.getProductById(item.getProductId());
                    if (p != null && !shopMap.containsKey(p.getShopId())) {
                        model.Shop shop = shopDAO.getShopById(p.getShopId());
                        if (shop != null) {
                            shopMap.put(p.getShopId(), shop);
                        }
                    }
                }
                req.setAttribute("shopMap", shopMap);
            } finally {
                shopDAO.close();
            }

            req.setAttribute("selectedItems", selectedItems);
            req.setAttribute("totalCost", totalCost);
            req.setAttribute("addresses", addresses);
            req.setAttribute("vouchers", vouchers);
            req.setAttribute("selectedProductIds", selectedProductIds);

            req.getRequestDispatcher("/checkout-cart.jsp").forward(req, resp);
        } catch (Exception e) {
            System.err.println("[CheckoutCartServlet] doGet ERROR: " + e.getClass().getName() + ": " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi hệ thống khi tải trang thanh toán: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/view-cart");
        } finally {
            checkoutService.close();
            productDAO.close();
            addressDAO.close();
            voucherDAO.close();
            cartService.close();
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

        Account account = (Account) session.getAttribute("Account");

        String selectedProductsParam = req.getParameter("selectedProducts");
        String recipientName = req.getParameter("recipientName");
        String recipientPhone = req.getParameter("recipientPhone");
        String address = req.getParameter("address");
        String paymentMethod = req.getParameter("paymentMethod");
        String note = req.getParameter("note");
String voucherCode = req.getParameter("voucherCode");

        if (selectedProductsParam == null || selectedProductsParam.trim().isEmpty()
                || recipientName == null || recipientPhone == null || address == null) {
            session.setAttribute("error", "Vui lòng nhập đầy đủ thông tin giao hàng.");
            resp.sendRedirect(req.getContextPath() + "/view-cart");
            return;
        }

        List<Integer> selectedProductIds = Arrays.stream(selectedProductsParam.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .map(Integer::parseInt)
                .collect(Collectors.toList());

        CartService cartService = new CartService();
        Cart cart = cartService.getCartByCustomerId(account.getId());
        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/view-cart");
            return;
        }

        List<CartItem> selectedItems = new ArrayList<>();
        for (CartItem item : cart.getItems()) {
            if (selectedProductIds.contains(item.getProductId())) {
                selectedItems.add(item);
            }
        }

        if (selectedItems.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/view-cart");
            return;
        }

        OrderService orderService = new OrderService();
        PlaceOrderResult result = orderService.placeCartOrder(
                account.getId(), selectedItems, recipientName, recipientPhone,
                address, paymentMethod, note, voucherCode);

        if (result.isSuccess()) {
            try {
                Cart updatedCart = cartService.getCartByCustomerId(account.getId());
                session.setAttribute("cart", updatedCart);
                session.setAttribute("cartCount", updatedCart != null ? updatedCart.getTotalQuantity() : 0);
            } catch (Exception e) {
                System.err.println("[CheckoutCartServlet] Error updating cart session: " + e.getMessage());
            } finally {
                cartService.close();
            }
            
            String message;
            if (result.getOrderCount() > 1) {
                message = String.format("Đặt hàng thành công! Bạn đã tạo %d đơn hàng từ %d shop khác nhau. Vui lòng kiểm tra email để xem chi tiết từng đơn.", 
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
}