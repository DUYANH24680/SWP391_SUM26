package service;

import dao.DeliveryAddressDAO;
import dao.ProductDAO;
import dao.ShopDAO;
import dao.VoucherDAO;
import model.*;
import model.VoucherValidationRequest;
import model.VoucherValidationResult;

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
                                        Map<Integer, String> shopVoucherCodes, String platformVoucherCode,
                                        Integer buyNowProductId, Integer buyNowQuantity) {
        OrderService orderService = new OrderService();
        try {
            return orderService.placeOrderWithDetails(
                customerId, recipientName, recipientPhone, address,
                paymentMethod, note, shopVoucherCodes, platformVoucherCode,
                buyNowProductId, buyNowQuantity
            );
        } finally {
            orderService = null;
        }
    }

    public PlaceOrderResult placeCartOrderFromSelected(int customerId, List<Integer> selectedProductIds,
                                                        String recipientName, String recipientPhone,
                                                        String address, String paymentMethod,
                                                        String note, Map<Integer, String> shopVoucherCodes, String platformVoucherCode) {
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
                    address, paymentMethod, note, shopVoucherCodes, platformVoucherCode);
        } finally {
            cartService.close();
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

    // ===================== Dual Voucher Validation =====================

    public VoucherValidationResult validateBothVouchers(VoucherValidationRequest request) {
        VoucherDAO voucherDAO = new VoucherDAO();
        try {
            double totalSubtotal = request.getTotalSubtotal();
            Map<Integer, Double> shopSubtotals = request.getShopSubtotals();
            Map<Integer, String> shopVoucherCodes = request.getShopVoucherCodes();

            if (shopSubtotals == null || shopSubtotals.isEmpty()) {
                return VoucherValidationResult.error("Không có sản phẩm nào trong giỏ hàng.");
            }

            // Step 1: Validate each shop voucher against its shop's subtotal
            double totalShopDiscount = 0.0;
            Map<Integer, Double> shopDiscountMap = new HashMap<>();
            Map<Integer, Integer> shopVoucherIdMap = new HashMap<>();
            Map<Integer, String> shopVoucherErrorsMap = new HashMap<>();

            for (Map.Entry<Integer, Double> entry : shopSubtotals.entrySet()) {
                int shopId = entry.getKey();
                double shopSubtotal = entry.getValue();
                String voucherCode = shopVoucherCodes != null ? shopVoucherCodes.get(shopId) : null;

                double discount = 0.0;
                if (voucherCode != null && !voucherCode.trim().isEmpty()) {
                    Voucher shopVoucher = voucherDAO.findByCode(voucherCode.trim());
                    if (shopVoucher == null) {
                        shopVoucherErrorsMap.put(shopId, "Mã '" + voucherCode + "' không tồn tại.");
                    } else if (shopVoucher.getShopId() == null || shopVoucher.getShopId() != shopId) {
                        shopVoucherErrorsMap.put(shopId, "Mã này không áp dụng cho cửa hàng này.");
                    } else if (!shopVoucher.isStatus()) {
                        shopVoucherErrorsMap.put(shopId, "Mã giảm giá đã bị khóa.");
                    } else if (shopVoucher.getUsedCount() >= shopVoucher.getQuantity()) {
                        shopVoucherErrorsMap.put(shopId, "Mã đã hết lượt sử dụng.");
                    } else if (shopVoucher.getStartDate() != null && new java.util.Date().before(shopVoucher.getStartDate())) {
                        shopVoucherErrorsMap.put(shopId, "Mã chưa đến hạn sử dụng.");
                    } else if (shopVoucher.getEndDate() != null && new java.util.Date().after(shopVoucher.getEndDate())) {
                        shopVoucherErrorsMap.put(shopId, "Mã đã hết hạn sử dụng.");
                    } else if (shopSubtotal < shopVoucher.getMinimumOrder()) {
                        shopVoucherErrorsMap.put(shopId, "Đơn tối thiểu " + String.format("%,.0f", shopVoucher.getMinimumOrder()) + " đ để dùng mã này.");
                    } else {
                        discount = shopVoucher.calculateDiscount(shopSubtotal);
                        shopVoucherIdMap.put(shopId, shopVoucher.getId());
                    }
                }

                // Apply extra 5% discount for shop orders > 500k
                if (shopSubtotal > 500000) {
                    discount += shopSubtotal * 0.05;
                }
                if (discount > shopSubtotal) {
                    discount = shopSubtotal;
                }

                shopDiscountMap.put(shopId, discount);
                totalShopDiscount += discount;
            }

            // Step 2: Calculate base for platform discount
            double baseForPlatform = totalSubtotal - totalShopDiscount;
            if (baseForPlatform < 0) baseForPlatform = 0;

            // Step 3: Validate and calculate platform voucher
            double platformDiscount = 0.0;
            Integer platformVoucherId = null;

            if (request.getPlatformVoucherCode() != null && !request.getPlatformVoucherCode().trim().isEmpty()) {
                Voucher platformVoucher = voucherDAO.findByCode(request.getPlatformVoucherCode());
                if (platformVoucher == null) {
                    return VoucherValidationResult.error("Mã giảm giá sàn không tồn tại.");
                }
                if (!platformVoucher.isStatus()) {
                    return VoucherValidationResult.error("Mã giảm giá sàn đã bị khóa.");
                }
                if (platformVoucher.getUsedCount() >= platformVoucher.getQuantity()) {
                    return VoucherValidationResult.error("Mã giảm giá sàn đã hết lượt sử dụng.");
                }
                if (platformVoucher.getStartDate() != null && new java.util.Date().before(platformVoucher.getStartDate())) {
                    return VoucherValidationResult.error("Mã giảm giá sàn chưa đến hạn sử dụng.");
                }
                if (platformVoucher.getEndDate() != null && new java.util.Date().after(platformVoucher.getEndDate())) {
                    return VoucherValidationResult.error("Mã giảm giá sàn đã hết hạn sử dụng.");
                }
                if (platformVoucher.getShopId() != null) {
                    return VoucherValidationResult.error("Mã này là mã của Shop, không phải mã Sàn.");
                }
                if (baseForPlatform < platformVoucher.getMinimumOrder()) {
                    return VoucherValidationResult.error(
                        "Giá trị sau khi giảm shop chưa đạt mức tối thiểu (" + String.format("%,.0f", platformVoucher.getMinimumOrder()) + " đ) cho mã sàn.");
                }

                platformDiscount = platformVoucher.calculateDiscount(baseForPlatform);
                if (platformDiscount > baseForPlatform) {
                    platformDiscount = baseForPlatform;
                }
                platformVoucherId = platformVoucher.getId();
            }

            // Step 4: Allocate platform discount to each shop proportionally
            Map<Integer, Double> shopAllocatedPlatformDiscount = new HashMap<>();
            double allocatedPlatformDiscount = 0.0;
            int shopIndex = 0;
            int numShops = shopSubtotals.size();

            for (Map.Entry<Integer, Double> entry : shopSubtotals.entrySet()) {
                int shopId = entry.getKey();
                double shopSubtotal = entry.getValue();
                shopIndex++;

                double allocated;
                if (shopIndex == numShops) {
                    allocated = platformDiscount - allocatedPlatformDiscount;
                } else {
                    allocated = Math.round((platformDiscount * (shopSubtotal / totalSubtotal)) * 100.0) / 100.0;
                    allocatedPlatformDiscount += allocated;
                }
                shopAllocatedPlatformDiscount.put(shopId, allocated);
            }

            // Step 5: Calculate final amounts
            double totalDiscount = totalShopDiscount + platformDiscount;
            double finalTotal = totalSubtotal - totalDiscount;

            // Build result with per-shop voucher errors
            VoucherValidationResult result = VoucherValidationResult.error("");
            result.setSuccess(true);
            result.setMessage("Áp dụng mã giảm giá thành công!");
            result.setTotalShopDiscount(totalShopDiscount);
            result.setPlatformDiscount(platformDiscount);
            result.setTotalDiscount(totalDiscount);
            result.setFinalTotal(finalTotal);
            result.setShopAllocatedPlatformDiscount(shopAllocatedPlatformDiscount);
            result.setShopDiscountsPerShop(shopDiscountMap);
            result.setShopVoucherIdsPerShop(shopVoucherIdMap);
            result.setShopVoucherErrorsPerShop(shopVoucherErrorsMap);
            result.setPlatformVoucherId(platformVoucherId);
            return result;
        } catch (Exception e) {
            System.err.println("[CheckoutService] validateBothVouchers error: " + e.getMessage());
            e.printStackTrace();
            return VoucherValidationResult.error("Lỗi khi xử lý mã giảm giá: " + e.getMessage());
        } finally {
            voucherDAO.close();
        }
    }
}
