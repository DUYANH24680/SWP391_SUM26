package service;

import dao.ProductDAO;
import dao.VoucherDAO;
import dao.OrderDAO;
import dao.ShopDAO;
import java.util.ArrayList;
import model.Shop;
import model.Product;
import model.Voucher;
import model.Order;
import model.OrderDetail;
import model.PlaceOrderResult;
import model.CancelCustomerOrderResult;
import model.SellerOrderActionResult;
import model.CustomerOrdersData;
import model.SellerOrdersData;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.CartItem;

public class OrderService {

    /**
     * Handles order placement business logic, including validations, pricing, vouchers,
     * database record creation, and clearing cart item.
     */
    public PlaceOrderResult placeOrder(int customerId, int productId, int quantity,
                                       String recipientName, String recipientPhone,
                                       String address, String paymentMethod, String note,
                                       String voucherCode) {
        ProductDAO productDAO = new ProductDAO();
        VoucherDAO voucherDAO = new VoucherDAO();
        OrderDAO orderDAO = new OrderDAO();
        CartService cartService = new CartService();

        try {
            Product product = productDAO.getProductById(productId);
            if (product == null || product.isIsDelete() || product.getStatus() != 1) {
                return new PlaceOrderResult(false, "Sản phẩm không tồn tại hoặc đã ngừng bán.");
            }

            if (product.getStockQuantity() < quantity) {
                return new PlaceOrderResult(false, "Tồn kho không đủ (chỉ còn " + product.getStockQuantity() + " " + product.getUnit() + ").");
            }

            double unitPrice = product.getSalePrice() > 0 && product.getSalePrice() < product.getOriginalPrice()
                    ? product.getSalePrice() : product.getOriginalPrice();
            double totalCost = unitPrice * quantity;

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
            order.setCustomerId(customerId);
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

            OrderDetail detail = new OrderDetail();
            detail.setProductId(productId);
            detail.setQuantity(quantity);
            detail.setUnitPrice(unitPrice);
            detail.setTotalPrice(totalCost);

            boolean success = orderDAO.createOrder(order, detail);

            if (success) {
                try {
                    cartService.removeItem(customerId, productId);
                } catch (Exception e) {
                    System.err.println("[OrderService] Error cleaning cart: " + e.getMessage());
                }
                return new PlaceOrderResult(true, order.getId());
            } else {
                return new PlaceOrderResult(false, "Đặt hàng thất bại. Vui lòng thử lại.");
            }

        } catch (Exception e) {
            System.err.println("[OrderService] placeOrder error: " + e.getMessage());
            e.printStackTrace();
            return new PlaceOrderResult(false, "Lỗi hệ thống: " + e.getMessage());
        } finally {
            productDAO.close();
            voucherDAO.close();
            orderDAO.close();
            cartService.close();
        }
    }

    /**
     * Checks if the order belongs to the seller's shop.
     */
    public boolean checkOrderOwnership(int orderId, int shopId) {
        OrderDAO orderDAO = new OrderDAO();
        try {
            return orderDAO.checkOrderOwnership(orderId, shopId);
        } finally {
            orderDAO.close();
        }
    }

    /**
     * Confirms the order.
     */
    public boolean confirmOrder(int orderId) {
        OrderDAO orderDAO = new OrderDAO();
        try {
            return orderDAO.confirmOrder(orderId);
        } finally {
            orderDAO.close();
        }
    }

    /**
     * Cancels the order.
     */
    public boolean cancelOrder(int orderId) {
        OrderDAO orderDAO = new OrderDAO();
        try {
            return orderDAO.cancelOrder(orderId);
        } finally {
            orderDAO.close();
        }
    }

    /**
     * Cancels a customer's order if it belongs to them and is in Pending status.
     */
    public CancelCustomerOrderResult cancelCustomerOrder(int orderId, int customerId) {
        OrderDAO orderDAO = new OrderDAO();
        try {
            Order order = orderDAO.getOrderById(orderId);
            if (order == null || order.getCustomerId() != customerId) {
                return new CancelCustomerOrderResult(false, "Đơn hàng không tồn tại hoặc không thuộc quyền sở hữu của bạn.");
            }
            if (order.getStatus() != 1) { // 1 = Pending
                return new CancelCustomerOrderResult(false, "Chỉ có thể hủy đơn hàng ở trạng thái Chờ xác nhận.");
            }
            boolean ok = orderDAO.cancelOrder(orderId);
            if (ok) {
                return new CancelCustomerOrderResult(true, "Đã hủy đơn hàng thành công và hoàn trả số lượng kho!");
            } else {
                return new CancelCustomerOrderResult(false, "Hủy đơn hàng thất bại.");
            }
        } finally {
            orderDAO.close();
        }
    }

    /**
     * Handles the seller's action (confirm or cancel) on an order.
     */
    public SellerOrderActionResult handleSellerOrderAction(int sellerAccountId, int orderId, String action) {
        ShopDAO shopDAO = new ShopDAO();
        OrderDAO orderDAO = new OrderDAO();
        try {
            Shop shop = shopDAO.getShopByOwnerId(sellerAccountId);
            if (shop == null || shop.getStatus() != 1) {
                return new SellerOrderActionResult(false, "Shop của bạn chưa được phê duyệt.");
            }

            boolean ownsOrder = orderDAO.checkOrderOwnership(orderId, shop.getId());
            if (!ownsOrder) {
                return new SellerOrderActionResult(false, "Đơn hàng không thuộc về shop của bạn.");
            }

            if ("confirm".equals(action)) {
                boolean ok = orderDAO.confirmOrder(orderId);
                if (ok) {
                    return new SellerOrderActionResult(true, "Đã xác nhận đơn hàng thành công!");
                } else {
                    return new SellerOrderActionResult(false, "Xác nhận đơn hàng thất bại. Đơn hàng phải ở trạng thái Chờ xác nhận.");
                }
            } else if ("cancel".equals(action)) {
                Order order = orderDAO.getOrderById(orderId);
                if (order != null && order.getStatus() == 2) {
                    return new SellerOrderActionResult(false,
                            "Không thể từ chối đơn hàng đã xác nhận.");
                }
                boolean ok = orderDAO.cancelOrder(orderId);
                if (ok) {
                    return new SellerOrderActionResult(true, "Đã từ chối đơn hàng thành công và hoàn trả số lượng kho!");
                } else {
                    return new SellerOrderActionResult(false,
                            "Từ chối đơn hàng thất bại. Đơn hàng phải ở trạng thái Chờ xác nhận.");
                }
            } else {
                return new SellerOrderActionResult(false, "Hành động không hợp lệ.");
            }
        } finally {
            shopDAO.close();
            orderDAO.close();
        }
    }

    public CustomerOrdersData getCustomerOrdersWithDetails(int customerId, Integer statusFilter) {
        OrderDAO orderDAO = new OrderDAO();
        try {
            List<Order> orders;
            if (statusFilter != null) {
                orders = orderDAO.getOrdersByCustomerIdAndStatus(customerId, statusFilter);
            } else {
                orders = orderDAO.getOrdersByCustomerId(customerId);
            }
            Map<Integer, List<OrderDetail>> detailsMap = new HashMap<>();
            for (Order order : orders) {
                detailsMap.put(order.getId(), orderDAO.getOrderDetails(order.getId()));
            }
            return new CustomerOrdersData(orders, detailsMap);
        } finally {
            orderDAO.close();
        }
    }

    public SellerOrdersData getSellerOrdersData(int sellerAccountId) {
        ShopDAO shopDAO = new ShopDAO();
        OrderDAO orderDAO = new OrderDAO();
        try {
            Shop shop = shopDAO.getShopByOwnerId(sellerAccountId);
            if (shop == null) {
                return SellerOrdersData.notApproved("Cửa hàng của bạn chưa được tạo. Vui lòng tạo cửa hàng.");
            }
            if (shop.getStatus() != 1) {
                return SellerOrdersData.notApproved(
                        "Cửa hàng của bạn chưa được phê duyệt. Vui lòng đợi admin xác nhận.");
            }

            List<Order> orders = orderDAO.getOrdersByShopId(shop.getId());
            Map<Integer, List<OrderDetail>> detailsMap = new HashMap<>();
            for (Order order : orders) {
                detailsMap.put(order.getId(), orderDAO.getOrderDetails(order.getId()));
            }
            return SellerOrdersData.approved(shop, orders, detailsMap);
        } finally {
            shopDAO.close();
            orderDAO.close();
        }
    }

    public PlaceOrderResult placeCartOrder(int customerId, List<CartItem> items,
                                           String recipientName, String recipientPhone,
                                           String address, String paymentMethod, String note,
                                           String voucherCode) {
        if (items == null || items.isEmpty()) {
            return new PlaceOrderResult(false, "Giỏ hàng không có sản phẩm để đặt.");
        }

        ProductDAO productDAO = new ProductDAO();
        VoucherDAO voucherDAO = new VoucherDAO();
        OrderDAO orderDAO = new OrderDAO();
        CartService cartService = new CartService();

        try {
            double totalCost = 0;
            List<OrderDetail> details = new ArrayList<>();

            for (CartItem cartItem : items) {
                Product product = productDAO.getProductById(cartItem.getProductId());
                if (product == null || product.isIsDelete() || product.getStatus() != 1) {
                    return new PlaceOrderResult(false, "Sản phẩm '" + cartItem.getTitle() + "' không tồn tại hoặc đã ngừng bán.");
                }
                if (product.getStockQuantity() < cartItem.getQuantity()) {
                    return new PlaceOrderResult(false, "Sản phẩm '" + cartItem.getTitle() + "' không đủ tồn kho (còn " + product.getStockQuantity() + " " + product.getUnit() + ").");
                }

                double unitPrice = product.getSalePrice() > 0 && product.getSalePrice() < product.getOriginalPrice()
                        ? product.getSalePrice() : product.getOriginalPrice();
                totalCost += unitPrice * cartItem.getQuantity();

                OrderDetail detail = new OrderDetail();
                detail.setProductId(cartItem.getProductId());
                detail.setQuantity(cartItem.getQuantity());
                detail.setUnitPrice(unitPrice);
                detail.setTotalPrice(unitPrice * cartItem.getQuantity());
                details.add(detail);
            }

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
            order.setCustomerId(customerId);
            order.setVoucherId(voucherId);
            order.setRecipientName(recipientName != null ? recipientName.trim() : "");
            order.setRecipientPhone(recipientPhone != null ? recipientPhone.trim() : "");
            order.setAddress(address != null ? address.trim() : "");
            order.setPaymentMethod(paymentMethod != null ? paymentMethod.trim() : "COD");
            order.setStatus(1);
            order.setPaymentStatus(0);
            order.setTotalCost(totalCost);
            order.setDiscountAmount(discountAmount);
            order.setShippingFee(shippingFee);
            order.setFinalCost(finalCost);
            order.setNote(note != null ? note.trim() : "");

            boolean success = orderDAO.createOrder(order, details);

            if (success) {
                try {
                    for (CartItem cartItem : items) {
                        cartService.removeItem(customerId, cartItem.getProductId());
                    }
                } catch (Exception e) {
                    System.err.println("[OrderService] Error cleaning cart after cart order: " + e.getMessage());
                }
                return new PlaceOrderResult(true, order.getId());
            } else {
                return new PlaceOrderResult(false, "Đặt hàng thất bại. Vui lòng thử lại.");
            }

        } catch (Exception e) {
            System.err.println("[OrderService] placeCartOrder error: " + e.getMessage());
            e.printStackTrace();
            return new PlaceOrderResult(false, "Lỗi hệ thống: " + e.getMessage());
        } finally {
            productDAO.close();
            voucherDAO.close();
            orderDAO.close();
            cartService.close();
        }
    }
}
