package model;

import java.util.List;
import java.util.Map;

public class SellerOrdersData {
    private final boolean shopNotApproved;
    private final String shopNotApprovedMsg;
    private final Shop shop;
    private final List<Order> orders;
    private final Map<Integer, List<OrderDetail>> detailsMap;

    private SellerOrdersData(boolean shopNotApproved, String shopNotApprovedMsg,
                             Shop shop, List<Order> orders, Map<Integer, List<OrderDetail>> detailsMap) {
        this.shopNotApproved = shopNotApproved;
        this.shopNotApprovedMsg = shopNotApprovedMsg;
        this.shop = shop;
        this.orders = orders;
        this.detailsMap = detailsMap;
    }

    public static SellerOrdersData notApproved(String message) {
        return new SellerOrdersData(true, message, null, null, null);
    }

    public static SellerOrdersData approved(Shop shop, List<Order> orders,
                                            Map<Integer, List<OrderDetail>> detailsMap) {
        return new SellerOrdersData(false, null, shop, orders, detailsMap);
    }

    public boolean isShopNotApproved() {
        return shopNotApproved;
    }

    public String getShopNotApprovedMsg() {
        return shopNotApprovedMsg;
    }

    public Shop getShop() {
        return shop;
    }

    public List<Order> getOrders() {
        return orders;
    }

    public Map<Integer, List<OrderDetail>> getDetailsMap() {
        return detailsMap;
    }
}
