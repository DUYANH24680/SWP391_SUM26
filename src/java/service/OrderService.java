package service;

import dao.OrderDAO;
import dao.ProductDAO;
import dao.VoucherDAO;
import dao.ShopDAO;
import model.Order;
import model.OrderDetail;
import model.Product;
import model.Voucher;
import model.Shop;
import service.CartService;
import model.Cart;
import model.CartItem;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class OrderService {

    // Query Methods
    public List<Order> getOrdersByCustomerId(int customerId) {
        OrderDAO dao = new OrderDAO();
        try {
            return dao.getOrdersByCustomerId(customerId);
        } finally {
            dao.close();
        }
    }

    public List<Order> getOrdersByShopId(int shopId) {
        OrderDAO dao = new OrderDAO();
        try {
            return dao.getOrdersByShopId(shopId);
        } finally {
            dao.close();
        }
    }

    public Order getOrderById(int orderId) {
        OrderDAO dao = new OrderDAO();
        try {
            return dao.getOrderById(orderId);
        } finally {
            dao.close();
        }
    }

    public List<OrderDetail> getOrderDetails(int orderId) {
        OrderDAO dao = new OrderDAO();
        try {
            return dao.getOrderDetails(orderId);
        } finally {
            dao.close();
        }
    }

    public Map<Integer, List<OrderDetail>> getOrderDetailsMap(List<Order> orders) {
        Map<Integer, List<OrderDetail>> detailsMap = new HashMap<>();
        OrderDAO dao = new OrderDAO();
        try {
            for (Order o : orders) {
                detailsMap.put(o.getId(), dao.getOrderDetails(o.getId()));
            }
        } finally {
            dao.close();
        }
        return detailsMap;
    }

    // Cancel order by customer
    public void cancelOrderByCustomer(int orderId, int customerId) {
        OrderDAO dao = new OrderDAO();
        try {
            Order order = dao.getOrderById(orderId);
            if (order == null || order.getCustomerId() != customerId) {
                throw new IllegalArgumentException("Đơn hàng không tồn tại hoặc không thuộc quyền sở hữu của bạn.");
            }
            if (order.getStatus() != 1) { // 1 is Pending
                throw new IllegalArgumentException("Chỉ có thể hủy đơn hàng ở trạng thái Chờ xác nhận.");
            }
            boolean ok = dao.updateOrderStatus(orderId, 5); // 5 = Canceled
            if (!ok) {
                throw new RuntimeException("Hủy đơn hàng thất bại.");
            }
        } finally {
            dao.close();
        }
    }

    // Update order status by seller
    public void updateOrderStatusBySeller(int orderId, int sellerId, String action) {
        ShopDAO shopDAO = new ShopDAO();
        OrderDAO orderDAO = new OrderDAO();
        ProductDAO productDAO = new ProductDAO();
        try {
            Shop shop = shopDAO.getShopByOwnerId(sellerId);
            if (shop == null || shop.getStatus() != 1) {
                throw new IllegalArgumentException("Shop của bạn chưa được tạo hoặc chưa được phê duyệt.");
            }

            List<OrderDetail> details = orderDAO.getOrderDetails(orderId);
            boolean ownsOrder = false;
            for (OrderDetail od : details) {
                Product p = productDAO.getProductById(od.getProductId());
                if (p != null && p.getShopId() == shop.getId()) {
                    ownsOrder = true;
                    break;
                }
            }

            if (!ownsOrder) {
                throw new IllegalArgumentException("Đơn hàng không thuộc về shop của bạn.");
            }

            int newStatus;
            String actionMsg;
            if ("confirm".equals(action)) {
                newStatus = 2; // Confirmed
                actionMsg = "Xác nhận";
            } else if ("cancel".equals(action)) {
                newStatus = 5; // Canceled
                actionMsg = "Hủy";
            } else {
                throw new IllegalArgumentException("Hành động không hợp lệ.");
            }

            boolean ok = orderDAO.updateOrderStatus(orderId, newStatus);
            if (!ok) {
                throw new RuntimeException(actionMsg + " đơn hàng thất bại.");
            }
        } finally {
            shopDAO.close();
            orderDAO.close();
            productDAO.close();
        }
    }

    // Place Order Business Logic
    public Order placeOrder(int customerId, String recipientName, String recipientPhone, String address,
                             String paymentMethod, String note, String voucherCode,
                             Integer buyNowProductId, Integer buyNowQuantity) {
        
        if (recipientName == null || recipientName.trim().isEmpty() ||
            recipientPhone == null || recipientPhone.trim().isEmpty() ||
            address == null || address.trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập đầy đủ thông tin giao hàng.");
        }

        ProductDAO productDAO = new ProductDAO();
        VoucherDAO voucherDAO = new VoucherDAO();
        OrderDAO orderDAO = new OrderDAO();
        
        try {
            double totalCost = 0.0;
            List<OrderDetail> details = new ArrayList<>();
            boolean isBuyNow = (buyNowProductId != null);

            if (isBuyNow) {
                if (buyNowQuantity == null || buyNowQuantity <= 0) {
                    throw new IllegalArgumentException("Số lượng mua không hợp lệ.");
                }
                Product product = productDAO.getProductById(buyNowProductId);
                if (product == null || product.isIsDelete() || product.getStatus() != 1) {
                    throw new IllegalArgumentException("Sản phẩm không tồn tại hoặc đã ngừng bán.");
                }
                if (product.getStockQuantity() < buyNowQuantity) {
                    throw new IllegalArgumentException("Số lượng trong kho không đủ cho sản phẩm " + product.getTitle());
                }

                double unitPrice = product.getSalePrice() > 0 && product.getSalePrice() < product.getOriginalPrice()
                        ? product.getSalePrice() : product.getOriginalPrice();
                totalCost = unitPrice * buyNowQuantity;

                OrderDetail detail = new OrderDetail();
                detail.setProductId(buyNowProductId);
                detail.setQuantity(buyNowQuantity);
                detail.setUnitPrice(unitPrice);
                detail.setTotalPrice(totalCost);
                details.add(detail);
            } else {
                CartService cartService = new CartService();
                Cart cart = cartService.getCartByCustomerId(customerId);
                if (cart == null || cart.isEmpty()) {
                    throw new IllegalArgumentException("Giỏ hàng của bạn đang trống.");
                }

                for (CartItem item : cart.getItems()) {
                    Product p = productDAO.getProductById(item.getProductId());
                    if (p == null || p.isIsDelete() || p.getStatus() != 1) {
                        throw new IllegalArgumentException("Sản phẩm " + item.getTitle() + " không còn khả dụng.");
                    }
                    if (p.getStockQuantity() < item.getQuantity()) {
                        throw new IllegalArgumentException("Sản phẩm " + item.getTitle() + " không đủ hàng trong kho.");
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

            boolean success = orderDAO.createOrder(order, details);
            if (!success) {
                throw new RuntimeException("Đặt hàng thất bại. Vui lòng thử lại.");
            }

            if (!isBuyNow) {
                // Clear the cart
                CartService cartService = new CartService();
                cartService.clearCart(customerId);
            }

            return order;

        } finally {
            productDAO.close();
            voucherDAO.close();
            orderDAO.close();
        }
    }
    public model.CustomerOrdersData getCustomerOrdersWithDetails(int customerId, Integer status) {
        OrderDAO dao = new OrderDAO();
        try {
            List<Order> orders = dao.getOrdersByCustomerId(customerId);
            if (status != null) {
                orders.removeIf(o -> o.getStatus() != status);
            }
            Map<Integer, List<OrderDetail>> map = getOrderDetailsMap(orders);
            return new model.CustomerOrdersData(orders, map);
        } finally {
            dao.close();
        }
    }

    public model.PlaceOrderResult placeCartOrder(int customerId, List<CartItem> selectedItems, String recipientName, String recipientPhone, String address, String paymentMethod, String note, String voucherCode) {
        if (selectedItems == null || selectedItems.isEmpty()) {
            return new model.PlaceOrderResult(false, "Không có sản phẩm nào được chọn.");
        }
        if (recipientName == null || recipientName.trim().isEmpty() ||
            recipientPhone == null || recipientPhone.trim().isEmpty() ||
            address == null || address.trim().isEmpty()) {
            return new model.PlaceOrderResult(false, "Vui lòng nhập đầy đủ thông tin giao hàng.");
        }

        ProductDAO productDAO = new ProductDAO();
        VoucherDAO voucherDAO = new VoucherDAO();
        OrderDAO orderDAO = new OrderDAO();
        
        try {
            double totalCost = 0.0;
            List<OrderDetail> details = new ArrayList<>();

            for (CartItem item : selectedItems) {
                Product p = productDAO.getProductById(item.getProductId());
                if (p == null || p.isIsDelete() || p.getStatus() != 1) {
                    return new model.PlaceOrderResult(false, "Sản phẩm " + item.getTitle() + " không còn khả dụng.");
                }
                if (p.getStockQuantity() < item.getQuantity()) {
                    return new model.PlaceOrderResult(false, "Sản phẩm " + item.getTitle() + " không đủ hàng trong kho.");
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
            order.setStatus(1); // Pending
            order.setPaymentStatus(0); // Unpaid
            order.setTotalCost(totalCost);
            order.setDiscountAmount(discountAmount);
            order.setShippingFee(shippingFee);
            order.setFinalCost(finalCost);
            order.setNote(note != null ? note.trim() : "");

            boolean success = orderDAO.createOrder(order, details);
            if (!success) {
                return new model.PlaceOrderResult(false, "Đặt hàng thất bại. Vui lòng thử lại.");
            }

            CartService cartService = new CartService();
            for (CartItem item : selectedItems) {
                cartService.removeItem(customerId, item.getProductId());
            }

            return new model.PlaceOrderResult(true, order.getId());

        } catch (Exception e) {
            e.printStackTrace();
            return new model.PlaceOrderResult(false, "Lỗi hệ thống: " + e.getMessage());
        } finally {
            productDAO.close();
            voucherDAO.close();
            orderDAO.close();
        }
    }
}
