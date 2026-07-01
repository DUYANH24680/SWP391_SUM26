package model;

import java.util.List;

public class CheckoutPageResult {
    private final boolean success;
    private final String error;
    private final Product product;
    private final List<DeliveryAddress> addresses;
    private final List<Voucher> vouchers;
    private final int quantity;

    private CheckoutPageResult(boolean success, String error, Product product,
                               List<DeliveryAddress> addresses, List<Voucher> vouchers, int quantity) {
        this.success = success;
        this.error = error;
        this.product = product;
        this.addresses = addresses;
        this.vouchers = vouchers;
        this.quantity = quantity;
    }

    public static CheckoutPageResult error(String error) {
        return new CheckoutPageResult(false, error, null, null, null, 0);
    }

    public static CheckoutPageResult success(Product product, List<DeliveryAddress> addresses,
                                             List<Voucher> vouchers, int quantity) {
        return new CheckoutPageResult(true, null, product, addresses, vouchers, quantity);
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
}
