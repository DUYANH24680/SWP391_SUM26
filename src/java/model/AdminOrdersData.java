package model;

import java.util.List;
import java.util.Map;

public class AdminOrdersData {
    private final List<Order> orders;
    private final Map<Integer, List<OrderDetail>> detailsMap;
    private final List<Shop> shops;
    private final int totalOrders;
    private final int totalPages;
    private final int currentPage;

    public AdminOrdersData(List<Order> orders, Map<Integer, List<OrderDetail>> detailsMap,
                           List<Shop> shops, int totalOrders, int totalPages, int currentPage) {
        this.orders = orders;
        this.detailsMap = detailsMap;
        this.shops = shops;
        this.totalOrders = totalOrders;
        this.totalPages = totalPages;
        this.currentPage = currentPage;
    }

    public List<Order> getOrders() {
        return orders;
    }

    public Map<Integer, List<OrderDetail>> getDetailsMap() {
        return detailsMap;
    }

    public List<Shop> getShops() {
        return shops;
    }

    public int getTotalOrders() {
        return totalOrders;
    }

    public int getTotalPages() {
        return totalPages;
    }

    public int getCurrentPage() {
        return currentPage;
    }
}
