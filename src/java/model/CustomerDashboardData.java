package model;

import java.util.List;
import java.util.Map;

public class CustomerDashboardData {
    private final List<Order> orders;
    private final Map<Integer, List<OrderDetail>> detailsMap;
    private final int totalOrders;
    private final double totalSpent;
    private final int pendingCount;
    private final int confirmedCount;
    private final int shippingCount;
    private final int deliveredCount;
    private final int canceledCount;
    private final int recentOrderCount;
    private final double avgOrderValue;
    private final double monthlySpend;
    private final List<Order> recentOrders;

    public CustomerDashboardData(List<Order> orders, Map<Integer, List<OrderDetail>> detailsMap,
                                  int totalOrders, double totalSpent,
                                  int pendingCount, int confirmedCount, int shippingCount,
                                  int deliveredCount, int canceledCount, int recentOrderCount,
                                  double avgOrderValue, double monthlySpend, List<Order> recentOrders) {
        this.orders = orders;
        this.detailsMap = detailsMap;
        this.totalOrders = totalOrders;
        this.totalSpent = totalSpent;
        this.pendingCount = pendingCount;
        this.confirmedCount = confirmedCount;
        this.shippingCount = shippingCount;
        this.deliveredCount = deliveredCount;
        this.canceledCount = canceledCount;
        this.recentOrderCount = recentOrderCount;
        this.avgOrderValue = avgOrderValue;
        this.monthlySpend = monthlySpend;
        this.recentOrders = recentOrders;
    }

    public List<Order> getOrders() { return orders; }
    public Map<Integer, List<OrderDetail>> getDetailsMap() { return detailsMap; }
    public int getTotalOrders() { return totalOrders; }
    public double getTotalSpent() { return totalSpent; }
    public int getPendingCount() { return pendingCount; }
    public int getConfirmedCount() { return confirmedCount; }
    public int getShippingCount() { return shippingCount; }
    public int getDeliveredCount() { return deliveredCount; }
    public int getCanceledCount() { return canceledCount; }
    public int getRecentOrderCount() { return recentOrderCount; }
    public double getAvgOrderValue() { return avgOrderValue; }
    public double getMonthlySpend() { return monthlySpend; }
    public List<Order> getRecentOrders() { return recentOrders; }
}
