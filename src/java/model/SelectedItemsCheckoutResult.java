package model;

import java.util.List;
import java.util.Map;

public class SelectedItemsCheckoutResult {
    private final boolean success;
    private final boolean emptyCart;
    private final String error;
    private final List<CartItem> selectedItems;
    private final double totalCost;
    private final List<DeliveryAddress> addresses;
    private final List<Voucher> vouchers;
    private final Map<Integer, Shop> shopMap;
    private final List<Integer> selectedProductIds;

    private SelectedItemsCheckoutResult(boolean success, boolean emptyCart, String error,
                                        List<CartItem> selectedItems, double totalCost,
                                        List<DeliveryAddress> addresses, List<Voucher> vouchers,
                                        Map<Integer, Shop> shopMap, List<Integer> selectedProductIds) {
        this.success = success;
        this.emptyCart = emptyCart;
        this.error = error;
        this.selectedItems = selectedItems;
        this.totalCost = totalCost;
        this.addresses = addresses;
        this.vouchers = vouchers;
        this.shopMap = shopMap;
        this.selectedProductIds = selectedProductIds;
    }

    public static SelectedItemsCheckoutResult error(String error) {
        return new SelectedItemsCheckoutResult(false, false, error, null, 0, null, null, null, null);
    }

    public static SelectedItemsCheckoutResult errorEmptyCart() {
        return new SelectedItemsCheckoutResult(false, true, "Giỏ hàng của bạn đang trống.", null, 0, null, null, null, null);
    }

    public static SelectedItemsCheckoutResult success(List<CartItem> selectedItems, double totalCost,
                                                      List<DeliveryAddress> addresses, List<Voucher> vouchers,
                                                      Map<Integer, Shop> shopMap, List<Integer> selectedProductIds) {
        return new SelectedItemsCheckoutResult(true, false, null, selectedItems, totalCost, addresses, vouchers, shopMap, selectedProductIds);
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

    public List<CartItem> getSelectedItems() {
        return selectedItems;
    }

    public double getTotalCost() {
        return totalCost;
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

    public List<Integer> getSelectedProductIds() {
        return selectedProductIds;
    }
}
