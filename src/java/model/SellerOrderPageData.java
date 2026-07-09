package model;

import java.util.List;
import java.util.Map;

public class SellerOrderPageData {
    private final boolean shopNotApproved;
    private final String shopNotApprovedMsg;
    private final List<Order> orders;
    private final Map<Integer, List<OrderDetail>> detailsMap;
    private final Shop shop;

    private SellerOrderPageData(boolean shopNotApproved, String shopNotApprovedMsg,
                                List<Order> orders, Map<Integer, List<OrderDetail>> detailsMap, Shop shop) {
        this.shopNotApproved = shopNotApproved;
        this.shopNotApprovedMsg = shopNotApprovedMsg;
        this.orders = orders;
        this.detailsMap = detailsMap;
        this.shop = shop;
    }

    public static SellerOrderPageData shopNotFound(String msg) {
        return new SellerOrderPageData(true, msg, null, null, null);
    }

    public static SellerOrderPageData success(List<Order> orders, Map<Integer, List<OrderDetail>> detailsMap, Shop shop) {
        return new SellerOrderPageData(false, null, orders, detailsMap, shop);
    }

    public boolean isShopNotApproved() { return shopNotApproved; }
    public String getShopNotApprovedMsg() { return shopNotApprovedMsg; }
    public List<Order> getOrders() { return orders; }
    public Map<Integer, List<OrderDetail>> getDetailsMap() { return detailsMap; }
    public Shop getShop() { return shop; }
}
