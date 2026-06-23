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
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Account user = (Account) session.getAttribute("user");

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
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Account user = (Account) session.getAttribute("user");

        String recipientName = req.getParameter("recipientName");
        String recipientPhone = req.getParameter("recipientPhone");
        String address = req.getParameter("address");
        String paymentMethod = req.getParameter("paymentMethod");
        String note = req.getParameter("note");
        String voucherCode = req.getParameter("voucherCode");

        if (recipientName == null || recipientPhone == null || address == null ||
            recipientName.trim().isEmpty() || recipientPhone.trim().isEmpty() || address.trim().isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập đầy đủ thông tin giao hàng.");
            doGet(req, resp);
            return;
        }

        String prodIdParam = req.getParameter("productId");
        boolean isBuyNow = (prodIdParam != null && !prodIdParam.trim().isEmpty());

        ProductDAO productDAO = new ProductDAO();
        VoucherDAO voucherDAO = new VoucherDAO();
        OrderDAO orderDAO = new OrderDAO();
        
        try {
            double totalCost = 0.0;
            List<OrderDetail> details = new java.util.ArrayList<>();

            if (isBuyNow) {
                // 1. Buy Now placing order
                int productId = Integer.parseInt(prodIdParam.trim());
                int quantity = Integer.parseInt(req.getParameter("quantity").trim());

                Product product = productDAO.getProductById(productId);
                if (product == null || product.isIsDelete() || product.getStatus() != 1) {
                    req.setAttribute("error", "Sản phẩm không tồn tại hoặc đã ngừng bán.");
                    doGet(req, resp);
                    return;
                }
                if (product.getStockQuantity() < quantity) {
                    req.setAttribute("error", "Số lượng trong kho không đủ cho sản phẩm " + product.getTitle());
                    doGet(req, resp);
                    return;
                }

                double unitPrice = product.getSalePrice() > 0 && product.getSalePrice() < product.getOriginalPrice()
                        ? product.getSalePrice() : product.getOriginalPrice();
                totalCost = unitPrice * quantity;

                OrderDetail detail = new OrderDetail();
                detail.setProductId(productId);
                detail.setQuantity(quantity);
                detail.setUnitPrice(unitPrice);
                detail.setTotalPrice(totalCost);
                details.add(detail);
            } else {
                // 2. Cart checkout placing order
                CartService cartService = new CartService();
                Cart cart = cartService.getCartByCustomerId(user.getId());
                if (cart == null || cart.isEmpty()) {
                    req.setAttribute("error", "Giỏ hàng của bạn đang trống.");
                    doGet(req, resp);
                    return;
                }

                for (CartItem item : cart.getItems()) {
                    Product p = productDAO.getProductById(item.getProductId());
                    if (p == null || p.isIsDelete() || p.getStatus() != 1) {
                        req.setAttribute("error", "Sản phẩm " + item.getTitle() + " không còn khả dụng.");
                        doGet(req, resp);
                        return;
                    }
                    if (p.getStockQuantity() < item.getQuantity()) {
                        req.setAttribute("error", "Sản phẩm " + item.getTitle() + " không đủ hàng trong kho.");
                        doGet(req, resp);
                        return;
                    }

                    double unitPrice = p.getSalePrice() > 0 && p.getSalePrice() < p.getOriginalPrice()
                            ? p.getSalePrice() : p.getOriginalPrice();
                    double itemTotal = unitPrice * item.getQuantity();
                    totalCost += itemTotal;

                    OrderDetail detail = new OrderDetail();
                    detail.setProductId(item.getProductId());
                    detail.setQuantity(item.getQuantity());
                    detail.setUnitPrice(unitPrice);
                    detail.setTotalPrice(itemTotal);
                    details.add(detail);
                }
            }

            // Free shipping on orders from 200,000 VND
            double shippingFee = totalCost >= 200000 ? 0.0 : 20000.0;
            double discountAmount = 0.0;
            Integer voucherId = null;

            if (voucherCode != null && !voucherCode.trim().isEmpty()) {
                Voucher voucher = voucherDAO.findByCode(voucherCode);
                if (voucher != null && voucher.isValid(totalCost)) {
                    voucherId = voucher.getId();
                    discountAmount = voucher.calculateDiscount(totalCost);
                }
            }

            double finalCost = totalCost - discountAmount + shippingFee;

            Order order = new Order();
            order.setCustomerId(user.getId());
            order.setVoucherId(voucherId);
            order.setRecipientName(recipientName.trim());
            order.setRecipientPhone(recipientPhone.trim());
            order.setAddress(address.trim());
            order.setPaymentMethod(paymentMethod != null ? paymentMethod.trim() : "COD");
            order.setStatus(1); // 1 = Pending
            order.setPaymentStatus(0); // 0 = Unpaid
            order.setTotalCost(totalCost);
            order.setDiscountAmount(discountAmount);
            order.setShippingFee(shippingFee);
            order.setFinalCost(finalCost);
            order.setNote(note != null ? note.trim() : "");

            boolean success = orderDAO.createOrder(order, details);

            if (success) {
                if (!isBuyNow) {
                    // Clear the cart
                    CartService cartService = new CartService();
                    cartService.clearCart(user.getId());
                }
                session.setAttribute("message", "Đặt hàng thành công!");
                resp.sendRedirect(req.getContextPath() + "/my-orders");
            } else {
                req.setAttribute("error", "Đặt hàng thất bại. Vui lòng thử lại.");
                doGet(req, resp);
            }

        } catch (Exception e) {
            System.err.println("[CheckoutServlet] doPost error: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "Lỗi xử lý đơn hàng: " + e.getMessage());
            doGet(req, resp);
        } finally {
            productDAO.close();
            voucherDAO.close();
            orderDAO.close();
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
