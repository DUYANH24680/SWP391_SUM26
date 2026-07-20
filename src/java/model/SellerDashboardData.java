package model;

import java.util.List;

public class SellerDashboardData {
    private Shop shop;
    private boolean shopNotApproved;
    private String shopNotApprovedMsg;
    private int totalProducts;
    private int totalOrders;
    private int pendingOrders;
    private int completedOrders;
    private double totalRevenue;
    private double todayRevenue;
    private double monthRevenue;
    private int todayOrderCount;
    private double avgOrderValue;
    private List<Order> orders;
    private List<String[]> revenueByDay;

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

    public int getCompletedOrders() {
        return completedOrders;
    }

    public void setCompletedOrders(int completedOrders) {
        this.completedOrders = completedOrders;
    }

    public double getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(double totalRevenue) {
        this.totalRevenue = totalRevenue;
    }

    public double getTodayRevenue() { return todayRevenue; }
    public void setTodayRevenue(double todayRevenue) { this.todayRevenue = todayRevenue; }

    public double getMonthRevenue() { return monthRevenue; }
    public void setMonthRevenue(double monthRevenue) { this.monthRevenue = monthRevenue; }

    public int getTodayOrderCount() { return todayOrderCount; }
    public void setTodayOrderCount(int todayOrderCount) { this.todayOrderCount = todayOrderCount; }

    public double getAvgOrderValue() { return avgOrderValue; }
    public void setAvgOrderValue(double avgOrderValue) { this.avgOrderValue = avgOrderValue; }

    public List<String[]> getRevenueByDay() { return revenueByDay; }
    public void setRevenueByDay(List<String[]> revenueByDay) { this.revenueByDay = revenueByDay; }

    public List<Order> getOrders() {
        return orders;
    }

    public void setOrders(List<Order> orders) {
        this.orders = orders;
    }
}
