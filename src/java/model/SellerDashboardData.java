package model;

import java.util.List;

public class SellerDashboardData {
    private Shop shop;
    private boolean shopNotApproved;
    private String shopNotApprovedMsg;
    private int totalProducts;
    private int totalOrders;
    private int pendingOrders;
    private double totalRevenue;
    private List<Order> orders;

    public SellerDashboardData() {
    }

    public Shop getShop() {
        return shop;
    }

    public void setShop(Shop shop) {
        this.shop = shop;
    }

    public boolean isShopNotApproved() {
        return shopNotApproved;
    }

    public void setShopNotApproved(boolean shopNotApproved) {
        this.shopNotApproved = shopNotApproved;
    }

    public String getShopNotApprovedMsg() {
        return shopNotApprovedMsg;
    }

    public void setShopNotApprovedMsg(String shopNotApprovedMsg) {
        this.shopNotApprovedMsg = shopNotApprovedMsg;
    }

    public int getTotalProducts() {
        return totalProducts;
    }

    public void setTotalProducts(int totalProducts) {
        this.totalProducts = totalProducts;
    }

    public int getTotalOrders() {
        return totalOrders;
    }

    public void setTotalOrders(int totalOrders) {
        this.totalOrders = totalOrders;
    }

    public int getPendingOrders() {
        return pendingOrders;
    }

    public void setPendingOrders(int pendingOrders) {
        this.pendingOrders = pendingOrders;
    }

    public double getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(double totalRevenue) {
        this.totalRevenue = totalRevenue;
    }

    public List<Order> getOrders() {
        return orders;
    }

    public void setOrders(List<Order> orders) {
        this.orders = orders;
    }
}
