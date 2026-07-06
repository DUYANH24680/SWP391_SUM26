package controller;

import dao.DeliveryAddressDAO;
import dao.ProductDAO;
import dao.VoucherDAO;
import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.DeliveryAddress;
import model.Product;
import model.Voucher;
import model.Order;
import model.OrderDetail;
import model.PlaceOrderResult;
import model.Cart;
import model.CartItem;
import service.CartService;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

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
        Account user = (Account) session.getAttribute("Account");

        String action = req.getParameter("action");
        if ("checkVoucher".equals(action)) {
            handleCheckVoucher(req, resp);
            return;
        }

        DeliveryAddressDAO addressDAO = new DeliveryAddressDAO();
        VoucherDAO voucherDAO = new VoucherDAO();
        ProductDAO productDAO = new ProductDAO();
        
        try {
            List<DeliveryAddress> addresses = addressDAO.findByCustomerId(user.getId());
            List<Voucher> vouchers = voucherDAO.getAllActiveVouchers();
            
            req.setAttribute("addresses", addresses);
            req.setAttribute("vouchers", vouchers);

            String prodIdParam = req.getParameter("productId");
            if (prodIdParam != null && !prodIdParam.trim().isEmpty()) {
                // 1. Buy Now Flow
                int productId = Integer.parseInt(prodIdParam.trim());
                int quantity = 1;
                String qtyParam = req.getParameter("quantity");
                if (qtyParam != null && !qtyParam.trim().isEmpty()) {
                    quantity = Integer.parseInt(qtyParam.trim());
                }

                Product product = productDAO.getProductById(productId);
                if (product == null || product.isIsDelete() || product.getStatus() != 1) {
                    session.setAttribute("error", "Sản phẩm không tồn tại hoặc đã ngừng bán.");
                    resp.sendRedirect(req.getContextPath() + "/home.jsp");
                    return;
                }
                
                req.setAttribute("product", product);
                req.setAttribute("quantity", quantity);
                req.setAttribute("isBuyNow", true);

                // Add Shop Details for Buy Now
                dao.ShopDAO shopDAO = new dao.ShopDAO();
                try {
                    model.Shop shop = shopDAO.getShopById(product.getShopId());
                    req.setAttribute("shop", shop);
                } finally {
                    shopDAO.close();
                }
            } else {
                // 2. Cart Checkout Flow
                CartService cartService = new CartService();
                Cart cart = cartService.getCartByCustomerId(user.getId());
                if (cart == null || cart.isEmpty()) {
                    session.setAttribute("error", "Giỏ hàng của bạn đang trống.");
                    resp.sendRedirect(req.getContextPath() + "/cart");
                    return;
                }
                
                // Validate stock for all items
                for (CartItem item : cart.getItems()) {
                    Product p = productDAO.getProductById(item.getProductId());
                    if (p == null || p.isIsDelete() || p.getStatus() != 1) {
                        session.setAttribute("error", "Sản phẩm " + item.getTitle() + " không còn khả dụng.");
                        resp.sendRedirect(req.getContextPath() + "/cart");
                        return;
                    }
                    if (p.getStockQuantity() < item.getQuantity()) {
                        session.setAttribute("error", "Sản phẩm " + item.getTitle() + " không đủ hàng trong kho.");
                        resp.sendRedirect(req.getContextPath() + "/cart");
                        return;
                    }
                }
                
                req.setAttribute("cart", cart);
                req.setAttribute("isBuyNow", false);

                // Fetch shops for all cart items
                dao.ShopDAO shopDAO = new dao.ShopDAO();
                try {
                    java.util.Map<Integer, model.Shop> shopMap = new java.util.HashMap<>();
                    for (CartItem item : cart.getItems()) {
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
            }

            req.getRequestDispatcher("/checkout.jsp").forward(req, resp);
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Tham số không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
        } finally {
            addressDAO.close();
            voucherDAO.close();
            productDAO.close();
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

        String recipientName = req.getParameter("recipientName");
        String recipientPhone = req.getParameter("recipientPhone");
        String address = req.getParameter("address");
        String paymentMethod = req.getParameter("paymentMethod");
        String note = req.getParameter("note");
        String voucherCode = req.getParameter("voucherCode");

        String prodIdParam = req.getParameter("productId");
        Integer buyNowProductId = null;
        Integer buyNowQuantity = null;

        try {
            if (prodIdParam != null && !prodIdParam.trim().isEmpty()) {
                buyNowProductId = Integer.parseInt(prodIdParam.trim());
                buyNowQuantity = Integer.parseInt(req.getParameter("quantity").trim());
            }

            service.OrderService orderService = new service.OrderService();
            PlaceOrderResult result = orderService.placeOrderWithDetails(
                user.getId(),
                recipientName,
                recipientPhone,
                address,
                paymentMethod,
                note,
                voucherCode,
                buyNowProductId,
                buyNowQuantity
            );

            if (result.isSuccess()) {
                String message;
                if (result.getOrderCount() > 1) {
                    message = String.format("Đặt hàng thành công! Bạn đã tạo %d đơn hàng từ %d shop khác nhau. Vui lòng kiểm tra email để xem chi tiết từng đơn.", 
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

        VoucherDAO voucherDAO = new VoucherDAO();
        try {
            Voucher voucher = voucherDAO.findByCode(code);
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            PrintWriter out = resp.getWriter();

            if (voucher == null) {
                out.write("{\"valid\": false, \"msg\": \"Mã giảm giá không tồn tại.\"}");
            } else if (!voucher.isStatus()) {
                out.write("{\"valid\": false, \"msg\": \"Mã giảm giá đã bị khóa.\"}");
            } else if (voucher.getUsedCount() >= voucher.getQuantity()) {
                out.write("{\"valid\": false, \"msg\": \"Mã giảm giá đã hết lượt sử dụng.\"}");
            } else if (voucher.getStartDate() != null && new java.util.Date().before(voucher.getStartDate())) {
                out.write("{\"valid\": false, \"msg\": \"Mã giảm giá chưa đến hạn sử dụng.\"}");
            } else if (voucher.getEndDate() != null && new java.util.Date().after(voucher.getEndDate())) {
                out.write("{\"valid\": false, \"msg\": \"Mã giảm giá đã hết hạn sử dụng.\"}");
            } else if (total < voucher.getMinimumOrder()) {
                out.write(String.format("{\"valid\": false, \"msg\": \"Giá trị đơn hàng chưa đạt mức tối thiểu (%,.0f đ).\"}", voucher.getMinimumOrder()));
            } else {
                double discount = voucher.calculateDiscount(total);
                out.write(String.format("{\"valid\": true, \"discount\": %.2f, \"voucherId\": %d, \"msg\": \"Áp dụng mã giảm giá thành công!\"}",
                        discount, voucher.getId()));
            }
            out.flush();
        } finally {
            voucherDAO.close();
        }
    }
}
