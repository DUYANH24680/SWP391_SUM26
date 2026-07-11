package model;

import java.util.List;

public class BuyNowCheckoutResult {
    private final boolean success;
    private final String error;
    private final Product product;
    private final List<DeliveryAddress> addresses;
    private final List<Voucher> vouchers;
    private final int quantity;
    private final Shop shop;

    private BuyNowCheckoutResult(boolean success, String error, Product product,
                                 List<DeliveryAddress> addresses, List<Voucher> vouchers,
                                 int quantity, Shop shop) {
        this.success = success;
        this.error = error;
        this.product = product;
        this.addresses = addresses;
        this.vouchers = vouchers;
        this.quantity = quantity;
        this.shop = shop;
    }

    public static BuyNowCheckoutResult error(String error) {
        return new BuyNowCheckoutResult(false, error, null, null, null, 0, null);
    }

    public static BuyNowCheckoutResult success(Product product, List<DeliveryAddress> addresses,
                                               List<Voucher> vouchers, int quantity, Shop shop) {
        return new BuyNowCheckoutResult(true, null, product, addresses, vouchers, quantity, shop);
    }

    public boolean isSuccess() {
        return success;
    }

    public String getError() {
        return error;
    }

    public Product getProduct() {
        return product;
    }

    public List<DeliveryAddress> getAddresses() {
        return addresses;
    }

    public List<Voucher> getVouchers() {
        return vouchers;
    }

    public int getQuantity() {
        return quantity;
    }

    public Shop getShop() {
        return shop;
    }
}
