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
import model.PlaceOrderResult;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.CancelOrderResult;
import model.MyOrdersPageData;
import model.SellerOrderActionResult;
import model.SellerOrderPageData;

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

    // ===================== Seller Order Page =====================

    public SellerOrderPageData getSellerOrderPageData(int sellerId) {
        ShopDAO shopDAO = new ShopDAO();
        try {
            Shop shop = shopDAO.getShopByOwnerId(sellerId);
            if (shop == null) {
                return SellerOrderPageData.shopNotFound(
                        "Cửa hàng của bạn chưa được tạo hoặc chưa được phê duyệt. Vui lòng đợi admin xác nhận.");
            }
            OrderService orderService = new OrderService();
            List<Order> orders = orderService.getOrdersByShopId(shop.getId());
            Map<Integer, List<OrderDetail>> detailsMap = orderService.getOrderDetailsMap(orders);
            return SellerOrderPageData.success(orders, detailsMap, shop);
        } finally {
            shopDAO.close();
        }
    }

    public SellerOrderActionResult processSellerOrderAction(int orderId, int sellerId, String action) {
        ShopDAO shopDAO = new ShopDAO();
        OrderDAO orderDAO = new OrderDAO();
        ProductDAO productDAO = new ProductDAO();
        try {
            Shop shop = shopDAO.getShopByOwnerId(sellerId);
            if (shop == null || shop.getStatus() != 1) {
                return SellerOrderActionResult.failure("Shop của bạn chưa được tạo hoặc chưa được phê duyệt.");
            }

            List<OrderDetail> details = orderDAO.getOrderDetails(orderId);
            if (details == null || details.isEmpty()) {
                return SellerOrderActionResult.failure("Đơn hàng không có sản phẩm nào hoặc không tồn tại.");
            }

            boolean ownsAllItems = true;
            for (OrderDetail od : details) {
                Product p = productDAO.getProductById(od.getProductId());
                if (p == null || p.getShopId() != shop.getId()) {
                    ownsAllItems = false;
                    break;
                }
            }

            if (!ownsAllItems) {
                return SellerOrderActionResult.failure("Đơn hàng chứa sản phẩm không thuộc quyền quản lý của shop bạn.");
            }

            int newStatus;
            String successMsg;
            if ("confirm".equals(action)) {
                newStatus = 2;
                successMsg = "Đã xác nhận đơn hàng thành công!";
            } else if ("cancel".equals(action)) {
                newStatus = 5;
                successMsg = "Đã hủy đơn hàng thành công!";
            } else {
                return SellerOrderActionResult.failure("Hành động không hợp lệ.");
            }

            boolean ok = orderDAO.updateOrderStatus(orderId, newStatus);
            if (!ok) {
                return SellerOrderActionResult.failure("Cập nhật trạng thái đơn hàng thất bại.");
            }
            return SellerOrderActionResult.success(successMsg);
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
            List<CartItem> selectedItems = new ArrayList<>();
            boolean isBuyNow = (buyNowProductId != null);

            if (isBuyNow) {
                if (buyNowQuantity == null || buyNowQuantity <= 0) {
                    throw new IllegalArgumentException("Số lượng mua không hợp lệ.");
                }
                Product product = productDAO.getProductById(buyNowProductId);
                if (product == null || product.isIsDelete() || product.getStatus() != 1) {
                    throw new IllegalArgumentException("Sản phẩm không tồn tại hoặc đã ngừng bán.");
                }
                CartItem item = new CartItem();
                item.setProductId(buyNowProductId);
                item.setQuantity(buyNowQuantity);
                item.setTitle(product.getTitle());
                selectedItems.add(item);
            } else {
                CartService cartService = new CartService();
                Cart cart = cartService.getCartByCustomerId(customerId);
                if (cart == null || cart.isEmpty()) {
                    throw new IllegalArgumentException("Giỏ hàng của bạn đang trống.");
                }
                selectedItems.addAll(cart.getItems());
            }

            List<Order> orders = processAndCreateOrders(
                customerId,
                selectedItems,
                recipientName,
                recipientPhone,
                address,
                paymentMethod,
                note,
                voucherCode,
                productDAO,
                voucherDAO,
                orderDAO
            );

            if (!isBuyNow) {
                CartService cartService = new CartService();
                cartService.clearCart(customerId);
            }

            return orders.isEmpty() ? null : orders.get(0);

        } finally {
            productDAO.close();
            voucherDAO.close();
            orderDAO.close();
        }
    }

    // Place order with full result details (order count, shop count)
    public PlaceOrderResult placeOrderWithDetails(int customerId, String recipientName, String recipientPhone, 
            String address, String paymentMethod, String note, String voucherCode,
            Integer buyNowProductId, Integer buyNowQuantity) {
        
        if (recipientName == null || recipientName.trim().isEmpty() ||
            recipientPhone == null || recipientPhone.trim().isEmpty() ||
            address == null || address.trim().isEmpty()) {
            return new PlaceOrderResult(false, "Vui lòng nhập đầy đủ thông tin giao hàng.");
        }

        ProductDAO productDAO = new ProductDAO();
        VoucherDAO voucherDAO = new VoucherDAO();
        OrderDAO orderDAO = new OrderDAO();
        
        try {
            List<CartItem> selectedItems = new ArrayList<>();
            boolean isBuyNow = (buyNowProductId != null);

            if (isBuyNow) {
                if (buyNowQuantity == null || buyNowQuantity <= 0) {
                    return new PlaceOrderResult(false, "Số lượng mua không hợp lệ.");
                }
                Product product = productDAO.getProductById(buyNowProductId);
                if (product == null || product.isIsDelete() || product.getStatus() != 1) {
                    return new PlaceOrderResult(false, "Sản phẩm không tồn tại hoặc đã ngừng bán.");
                }
                CartItem item = new CartItem();
                item.setProductId(buyNowProductId);
                item.setQuantity(buyNowQuantity);
                item.setTitle(product.getTitle());
                selectedItems.add(item);
            } else {
                CartService cartService = new CartService();
                Cart cart = cartService.getCartByCustomerId(customerId);
                if (cart == null || cart.isEmpty()) {
                    return new PlaceOrderResult(false, "Giỏ hàng của bạn đang trống.");
                }
                selectedItems.addAll(cart.getItems());
            }

            List<Order> orders = processAndCreateOrders(
                customerId,
                selectedItems,
                recipientName,
                recipientPhone,
                address,
                paymentMethod,
                note,
                voucherCode,
                productDAO,
                voucherDAO,
                orderDAO
            );

            if (!isBuyNow) {
                CartService cartService = new CartService();
                cartService.clearCart(customerId);
            }

            int orderCount = orders.size();
            int shopCount = 0;
            
            // Count unique shops from the created orders
            java.util.Set<Integer> uniqueShopIds = new java.util.HashSet<>();
            if (!orders.isEmpty() && selectedItems != null) {
                for (CartItem item : selectedItems) {
                    Product p = productDAO.getProductById(item.getProductId());
                    if (p != null) {
                        uniqueShopIds.add(p.getShopId());
                    }
                }
                shopCount = uniqueShopIds.size();
            }

            int returnOrderId = orders.isEmpty() ? 0 : orders.get(0).getId();
            return new PlaceOrderResult(true, returnOrderId, orderCount, shopCount);

        } catch (Exception e) {
            e.printStackTrace();
            return new PlaceOrderResult(false, "Lỗi hệ thống: " + e.getMessage());
        } finally {
            productDAO.close();
            voucherDAO.close();
            orderDAO.close();
        }
    }

    private List<Order> processAndCreateOrders(
            int customerId,
            List<CartItem> selectedItems,
            String recipientName,
            String recipientPhone,
            String address,
            String paymentMethod,
            String note,
            String voucherCode,
            ProductDAO productDAO,
            VoucherDAO voucherDAO,
            OrderDAO orderDAO) {

        Map<Integer, Product> productMap = new HashMap<>();
        for (CartItem item : selectedItems) {
            Product p = productDAO.getProductById(item.getProductId());
            if (p == null || p.isIsDelete() || p.getStatus() != 1) {
                throw new IllegalArgumentException("Sản phẩm " + item.getTitle() + " không còn khả dụng.");
            }
            if (p.getStockQuantity() < item.getQuantity()) {
                throw new IllegalArgumentException("Sản phẩm " + item.getTitle() + " không đủ hàng trong kho.");
            }
            productMap.put(item.getProductId(), p);
        }

        Map<Integer, List<CartItem>> itemsByShop = new HashMap<>();
        for (CartItem item : selectedItems) {
            Product p = productMap.get(item.getProductId());
            int shopId = p.getShopId();
            itemsByShop.computeIfAbsent(shopId, k -> new ArrayList<>()).add(item);
        }

        double overallTotalCost = 0.0;
        Map<Integer, Double> shopTotalCostMap = new HashMap<>();
        for (Map.Entry<Integer, List<CartItem>> entry : itemsByShop.entrySet()) {
            int shopId = entry.getKey();
            double shopTotalCost = 0.0;
            for (CartItem item : entry.getValue()) {
                Product p = productMap.get(item.getProductId());
                double unitPrice = p.getSalePrice() > 0 && p.getSalePrice() < p.getOriginalPrice()
                        ? p.getSalePrice() : p.getOriginalPrice();
                shopTotalCost += unitPrice * item.getQuantity();
            }
            shopTotalCostMap.put(shopId, shopTotalCost);
            overallTotalCost += shopTotalCost;
        }

        double overallDiscountAmount = 0.0;
        Integer voucherId = null;
        if (voucherCode != null && !voucherCode.trim().isEmpty()) {
            Voucher voucher = voucherDAO.findByCode(voucherCode);
            if (voucher != null && voucher.isValid(overallTotalCost)) {
                voucherId = voucher.getId();
                overallDiscountAmount = voucher.calculateDiscount(overallTotalCost);
            }
        }

        Map<Integer, Double> shopDiscountMap = new HashMap<>();
        double allocatedDiscount = 0.0;
        int shopIndex = 0;
        int numShops = itemsByShop.size();
        for (int shopId : itemsByShop.keySet()) {
            shopIndex++;
            double shopTotal = shopTotalCostMap.get(shopId);
            double shopDiscount = 0.0;
            if (shopIndex == numShops) {
                shopDiscount = overallDiscountAmount - allocatedDiscount;
            } else {
                shopDiscount = Math.round((overallDiscountAmount * (shopTotal / overallTotalCost)) * 100.0) / 100.0;
                allocatedDiscount += shopDiscount;
            }
            shopDiscountMap.put(shopId, shopDiscount);
        }

        Map<Integer, Double> shopShippingMap = new HashMap<>();
        for (int shopId : itemsByShop.keySet()) {
            double shopTotal = shopTotalCostMap.get(shopId);
            double shopShipping = shopTotal >= 200000 ? 0.0 : 20000.0;
            shopShippingMap.put(shopId, shopShipping);
        }

        List<Order> orders = new ArrayList<>();
        List<List<OrderDetail>> detailsList = new ArrayList<>();

        for (int shopId : itemsByShop.keySet()) {
            List<CartItem> shopItems = itemsByShop.get(shopId);
            double totalCost = shopTotalCostMap.get(shopId);
            double discountAmount = shopDiscountMap.get(shopId);
            double shippingFee = shopShippingMap.get(shopId);
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

            List<OrderDetail> details = new ArrayList<>();
            for (CartItem item : shopItems) {
                Product p = productMap.get(item.getProductId());
                double unitPrice = p.getSalePrice() > 0 && p.getSalePrice() < p.getOriginalPrice()
                        ? p.getSalePrice() : p.getOriginalPrice();
                double itemTotal = unitPrice * item.getQuantity();

                OrderDetail detail = new OrderDetail();
                detail.setProductId(item.getProductId());
                detail.setQuantity(item.getQuantity());
                detail.setUnitPrice(unitPrice);
                detail.setTotalPrice(itemTotal);
                details.add(detail);
            }

            orders.add(order);
            detailsList.add(details);
        }

        boolean success = orderDAO.createMultipleOrders(orders, detailsList);
        if (!success) {
            throw new RuntimeException("Đặt hàng thất bại. Vui lòng thử lại.");
        }

        if (voucherId != null) {
            voucherDAO.incrementUsedCount(voucherId);
        }

        return orders;
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
            List<Order> orders = processAndCreateOrders(
                customerId,
                selectedItems,
                recipientName,
                recipientPhone,
                address,
                paymentMethod,
                note,
                voucherCode,
                productDAO,
                voucherDAO,
                orderDAO
            );

            CartService cartService = new CartService();
            for (CartItem item : selectedItems) {
                cartService.removeItem(customerId, item.getProductId());
            }

            int orderCount = orders.size();
            int shopCount = 0;
            
            // Count unique shops from the created orders
            java.util.Set<Integer> uniqueShopIds = new java.util.HashSet<>();
            for (CartItem item : selectedItems) {
                Product p = productDAO.getProductById(item.getProductId());
                if (p != null) {
                    uniqueShopIds.add(p.getShopId());
                }
            }
            shopCount = uniqueShopIds.size();

            int returnOrderId = orders.isEmpty() ? 0 : orders.get(0).getId();
            return new model.PlaceOrderResult(true, returnOrderId, orderCount, shopCount);

        } catch (Exception e) {
            e.printStackTrace();
            return new model.PlaceOrderResult(false, "Lỗi hệ thống: " + e.getMessage());
        } finally {
            productDAO.close();
            voucherDAO.close();
            orderDAO.close();
        }
    }

    public model.AdminOrdersData getAdminOrdersData(Integer status, Integer shopId,
            java.sql.Date fromDate, java.sql.Date toDate,
            Double minValue, Double maxValue, int page, int pageSize) {
        OrderDAO orderDAO = new OrderDAO();
        ShopDAO shopDAO = new ShopDAO();
        try {
            int totalOrders = orderDAO.getAllOrdersForAdminCount(status, shopId, fromDate, toDate, minValue, maxValue);
            int totalPages = (int) Math.ceil((double) totalOrders / pageSize);
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;

            List<Order> orders = orderDAO.getAllOrdersForAdmin(status, shopId, fromDate, toDate, minValue, maxValue, page, pageSize);
            Map<Integer, List<OrderDetail>> detailsMap = new HashMap<>();
            for (Order o : orders) {
                detailsMap.put(o.getId(), orderDAO.getOrderDetails(o.getId()));
            }

            List<Shop> shops = shopDAO.getAllShops();

            return new model.AdminOrdersData(orders, detailsMap, shops, totalOrders, totalPages, page);
        } finally {
            orderDAO.close();
            shopDAO.close();
        }
    }

    // ===================== My Orders Page =====================

    public MyOrdersPageData getMyOrdersPageData(int customerId, Integer activeStatus, int page) {
        OrderDAO orderDAO = new OrderDAO();
        try {
            List<Order> orders = orderDAO.getOrdersByCustomerId(customerId);

            if (activeStatus != null) {
                final int statusToKeep = activeStatus;
                orders.removeIf(o -> o.getStatus() != statusToKeep);
            }

            int pageSize = 5;
            int totalOrders = orders.size();
            int totalPages = (int) Math.ceil((double) totalOrders / pageSize);
            if (totalPages == 0) totalPages = 1;
            if (page < 1) page = 1;
            if (page > totalPages) page = totalPages;

            int start = (page - 1) * pageSize;
            int end = Math.min(start + pageSize, totalOrders);
            List<Order> paginatedOrders = orders.subList(start, end);

            Map<Integer, List<OrderDetail>> detailsMap = getOrderDetailsMap(paginatedOrders);
            return new MyOrdersPageData(paginatedOrders, detailsMap, page, totalPages, activeStatus);
        } finally {
            orderDAO.close();
        }
    }

    public CancelOrderResult cancelOrderByCustomer(int orderId, int customerId) {
        OrderDAO dao = new OrderDAO();
        try {
            Order order = dao.getOrderById(orderId);
            if (order == null || order.getCustomerId() != customerId) {
                return CancelOrderResult.failure("Đơn hàng không tồn tại hoặc không thuộc quyền sở hữu của bạn.");
            }
            if (order.getStatus() != 1) {
                return CancelOrderResult.failure("Chỉ có thể hủy đơn hàng ở trạng thái Chờ xác nhận.");
            }
            boolean ok = dao.updateOrderStatus(orderId, 5);
            if (!ok) {
                return CancelOrderResult.failure("Hủy đơn hàng thất bại.");
            }
            return CancelOrderResult.success();
        } finally {
            dao.close();
        }
    }
}


