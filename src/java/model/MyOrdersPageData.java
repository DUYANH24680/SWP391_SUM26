package model;

import java.util.List;
import java.util.Map;

public class MyOrdersPageData {
    private final List<Order> orders;
    private final Map<Integer, List<OrderDetail>> detailsMap;
    private final int currentPage;
    private final int totalPages;
    private final Integer activeStatus;

    public MyOrdersPageData(List<Order> orders, Map<Integer, List<OrderDetail>> detailsMap,
                            int currentPage, int totalPages, Integer activeStatus) {
        this.orders = orders;
        this.detailsMap = detailsMap;
        this.currentPage = currentPage;
        this.totalPages = totalPages;
        this.activeStatus = activeStatus;
    }

    public List<Order> getOrders() { return orders; }
    public Map<Integer, List<OrderDetail>> getDetailsMap() { return detailsMap; }
    public int getCurrentPage() { return currentPage; }
    public int getTotalPages() { return totalPages; }
    public Integer getActiveStatus() { return activeStatus; }
}
