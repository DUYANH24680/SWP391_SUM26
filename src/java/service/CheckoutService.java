package service;

import dao.DeliveryAddressDAO;
import dao.ProductDAO;
import dao.ShopDAO;
import dao.VoucherDAO;
import model.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CheckoutService {

    public void close() {
        // all DAOs are method-local; nothing to close at service level
    }

    // ===================== Buy Now Flow =====================

    public BuyNowCheckoutResult getBuyNowCheckoutData(int customerId, int productId, int quantity) {
        ProductDAO productDAO = new ProductDAO();
        DeliveryAddressDAO addressDAO = new DeliveryAddressDAO();
        VoucherDAO voucherDAO = new VoucherDAO();
        ShopDAO shopDAO = new ShopDAO();

        try {
            Product product = productDAO.getProductById(productId);
            if (product == null || product.isIsDelete() || product.getStatus() != 1) {
                return BuyNowCheckoutResult.error("Sản phẩm không tồn tại hoặc ngừng bán.");
            }

            List<DeliveryAddress> addresses = addressDAO.findByCustomerId(customerId);
            List<Voucher> vouchers = voucherDAO.getAllActiveVouchers();
            Shop shop = shopDAO.getShopById(product.getShopId());

            return BuyNowCheckoutResult.success(product, addresses, vouchers, quantity, shop);
        } catch (Exception e) {
            System.err.println("[CheckoutService] getBuyNowCheckoutData error: " + e.getMessage());
            e.printStackTrace();
            return BuyNowCheckoutResult.error("Lỗi hệ thống khi tải trang thanh toán.");
        } finally {
            productDAO.close();
            addressDAO.close();
            voucherDAO.close();
            shopDAO.close();
        }
    }

    // ===================== Cart Checkout Flow =====================

    public CartCheckoutResult getCartCheckoutData(int customerId) {
        ProductDAO productDAO = new ProductDAO();
        DeliveryAddressDAO addressDAO = new DeliveryAddressDAO();
        VoucherDAO voucherDAO = new VoucherDAO();
        ShopDAO shopDAO = new ShopDAO();
        CartService cartService = new CartService();

        try {
            Cart cart = cartService.getCartByCustomerId(customerId);
            if (cart == null || cart.isEmpty()) {
                return CartCheckoutResult.errorEmptyCart();
            }

            // Validate stock for all items
            for (CartItem item : cart.getItems()) {
                Product p = productDAO.getProductById(item.getProductId());
                if (p == null || p.isIsDelete() || p.getStatus() != 1) {
                    return CartCheckoutResult.error("Sản phẩm " + item.getTitle() + " không còn khả dụng.");
                }
                if (p.getStockQuantity() < item.getQuantity()) {
                    return CartCheckoutResult.error("Sản phẩm " + item.getTitle() + " không đủ hàng trong kho.");
                }
            }

            List<DeliveryAddress> addresses = addressDAO.findByCustomerId(customerId);
            List<Voucher> vouchers = voucherDAO.getAllActiveVouchers();

            // Fetch shops for all cart items
            Map<Integer, Shop> shopMap = new HashMap<>();
            for (CartItem item : cart.getItems()) {
                Product p = productDAO.getProductById(item.getProductId());
                if (p != null && !shopMap.containsKey(p.getShopId())) {
                    Shop shop = shopDAO.getShopById(p.getShopId());
                    if (shop != null) {
                        shopMap.put(p.getShopId(), shop);
                    }
                }
            }

            return CartCheckoutResult.success(cart, addresses, vouchers, shopMap);
        } catch (Exception e) {
            System.err.println("[CheckoutService] getCartCheckoutData error: " + e.getMessage());
            e.printStackTrace();
            return CartCheckoutResult.error("Lỗi hệ thống khi tải trang thanh toán.");
        } finally {
            productDAO.close();
            addressDAO.close();
            voucherDAO.close();
            shopDAO.close();
        }
    }

    // ===================== Place Order =====================

    public PlaceOrderResult placeOrder(int customerId, String recipientName, String recipientPhone,
                                        String address, String paymentMethod, String note,
                                        String voucherCode, Integer buyNowProductId, Integer buyNowQuantity) {
        OrderService orderService = new OrderService();
        try {
            return orderService.placeOrderWithDetails(
                customerId, recipientName, recipientPhone, address,
                paymentMethod, note, voucherCode, buyNowProductId, buyNowQuantity
            );
        } finally {
            orderService = null;
        }
    }

    // ===================== Voucher Validation =====================

    public VoucherCheckResult validateVoucher(String code, double total) {
        VoucherDAO voucherDAO = new VoucherDAO();
        try {
            Voucher voucher = voucherDAO.findByCode(code);
            if (voucher == null) {
                return new VoucherCheckResult(false, "Mã giảm giá không tồn tại.");
            }
            if (!voucher.isStatus()) {
                return new VoucherCheckResult(false, "Mã giảm giá đã bị khóa.");
            }
            if (voucher.getUsedCount() >= voucher.getQuantity()) {
                return new VoucherCheckResult(false, "Mã giảm giá đã hết lượt sử dụng.");
            }
            if (voucher.getStartDate() != null && new java.util.Date().before(voucher.getStartDate())) {
                return new VoucherCheckResult(false, "Mã giảm giá chưa đến hạn sử dụng.");
            }
            if (voucher.getEndDate() != null && new java.util.Date().after(voucher.getEndDate())) {
                return new VoucherCheckResult(false, "Mã giảm giá đã hết hạn sử dụng.");
            }
            if (total < voucher.getMinimumOrder()) {
                return new VoucherCheckResult(false,
                        String.format("Giá trị đơn hàng chưa đạt mức tối thiểu (%,.0f đ).", voucher.getMinimumOrder()));
            }

            double discount = voucher.calculateDiscount(total);
            return new VoucherCheckResult(true, "Áp dụng mã giảm giá thành công!", discount, voucher.getId());
        } finally {
            voucherDAO.close();
        }
    }

    // ===================== Selected Cart Items Checkout Flow =====================

    public SelectedItemsCheckoutResult getSelectedItemsCheckoutData(int customerId, List<Integer> selectedProductIds) {
        ProductDAO productDAO = new ProductDAO();
        DeliveryAddressDAO addressDAO = new DeliveryAddressDAO();
        VoucherDAO voucherDAO = new VoucherDAO();
        ShopDAO shopDAO = new ShopDAO();
        CartService cartService = new CartService();

        try {
            Cart cart = cartService.getCartByCustomerId(customerId);
            if (cart == null || cart.isEmpty()) {
                return SelectedItemsCheckoutResult.errorEmptyCart();
            }

            List<CartItem> selectedItems = new ArrayList<>();
            for (CartItem item : cart.getItems()) {
                if (selectedProductIds.contains(item.getProductId())) {
                    selectedItems.add(item);
                }
            }

            if (selectedItems.isEmpty()) {
                return SelectedItemsCheckoutResult.errorEmptyCart();
            }

            double totalCost = 0;
            for (CartItem item : selectedItems) {
                Product p = productDAO.getProductById(item.getProductId());
                if (p != null && p.getSalePrice() > 0 && p.getSalePrice() < p.getOriginalPrice()) {
                    totalCost += p.getSalePrice() * item.getQuantity();
                } else if (p != null) {
                    totalCost += p.getOriginalPrice() * item.getQuantity();
                }
            }

            List<DeliveryAddress> addresses = addressDAO.findByCustomerId(customerId);
            List<Voucher> vouchers = voucherDAO.getAllActiveVouchers();

            Map<Integer, Shop> shopMap = new HashMap<>();
            for (CartItem item : selectedItems) {
                Product p = productDAO.getProductById(item.getProductId());
                if (p != null && !shopMap.containsKey(p.getShopId())) {
                    Shop shop = shopDAO.getShopById(p.getShopId());
                    if (shop != null) {
                        shopMap.put(p.getShopId(), shop);
                    }
                }
            }

            return SelectedItemsCheckoutResult.success(selectedItems, totalCost, addresses, vouchers, shopMap, selectedProductIds);
        } catch (Exception e) {
            System.err.println("[CheckoutService] getSelectedItemsCheckoutData error: " + e.getMessage());
            e.printStackTrace();
            return SelectedItemsCheckoutResult.error("Lỗi hệ thống khi tải trang thanh toán.");
        } finally {
            productDAO.close();
            addressDAO.close();
            voucherDAO.close();
            shopDAO.close();
        }
    }

    public PlaceOrderResult placeCartOrderFromSelected(int customerId, List<Integer> selectedProductIds,
                                                        String recipientName, String recipientPhone,
                                                        String address, String paymentMethod,
                                                        String note, String voucherCode) {
        CartService cartService = new CartService();
        OrderService orderService = new OrderService();
        try {
            Cart cart = cartService.getCartByCustomerId(customerId);
            if (cart == null || cart.isEmpty()) {
                return model.PlaceOrderResult.failure("Giỏ hàng của bạn đang trống.");
            }

            List<CartItem> selectedItems = new ArrayList<>();
            for (CartItem item : cart.getItems()) {
                if (selectedProductIds.contains(item.getProductId())) {
                    selectedItems.add(item);
                }
            }

            if (selectedItems.isEmpty()) {
                return model.PlaceOrderResult.failure("Không có sản phẩm nào được chọn để thanh toán.");
            }

            return orderService.placeCartOrder(customerId, selectedItems, recipientName, recipientPhone,
                    address, paymentMethod, note, voucherCode);
        } finally {
            cartService.close();
        }
    }

    // ===================== Parse Helpers =====================

    public Integer parseProductId(String param) {
        if (param == null || param.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(param.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    public int parseQuantity(String param, int defaultValue) {
        if (param == null || param.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(param.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    public double parseDouble(String param) {
        if (param == null || param.trim().isEmpty()) {
            return 0.0;
        }
        try {
            return Double.parseDouble(param.trim());
        } catch (NumberFormatException e) {
            return 0.0;
        }
    }
}
