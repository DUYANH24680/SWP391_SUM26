package model;

import java.util.List;
import java.util.Map;

public class CartCheckoutResult {
    private final boolean success;
    private final boolean emptyCart;
    private final String error;
    private final Cart cart;
    private final List<DeliveryAddress> addresses;
    private final List<Voucher> vouchers;
    private final Map<Integer, Shop> shopMap;

    private CartCheckoutResult(boolean success, boolean emptyCart, String error, Cart cart,
                               List<DeliveryAddress> addresses, List<Voucher> vouchers,
                               Map<Integer, Shop> shopMap) {
        this.success = success;
        this.emptyCart = emptyCart;
        this.error = error;
        this.cart = cart;
        this.addresses = addresses;
        this.vouchers = vouchers;
        this.shopMap = shopMap;
    }

    public static CartCheckoutResult error(String error) {
        return new CartCheckoutResult(false, false, error, null, null, null, null);
    }

    public static CartCheckoutResult errorEmptyCart() {
        return new CartCheckoutResult(false, true, "Giỏ hàng của bạn đang trống.", null, null, null, null);
    }

    public static CartCheckoutResult success(Cart cart, List<DeliveryAddress> addresses,
                                             List<Voucher> vouchers, Map<Integer, Shop> shopMap) {
        return new CartCheckoutResult(true, false, null, cart, addresses, vouchers, shopMap);
    }

    public boolean isSuccess() {
        return success;
    }

    public boolean isEmptyCart() {
        return emptyCart;
    }

    public String getError() {
        return error;
    }

    public Cart getCart() {
        return cart;
    }

    public List<DeliveryAddress> getAddresses() {
        return addresses;
    }

    public List<Voucher> getVouchers() {
        return vouchers;
    }

    public Map<Integer, Shop> getShopMap() {
        return shopMap;
    }
}
