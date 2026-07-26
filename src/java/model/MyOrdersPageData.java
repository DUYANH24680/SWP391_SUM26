package model;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MyOrdersPageData {
    private final List<Order> orders;
    private final Map<Integer, List<OrderDetail>> detailsMap;
    private final Map<Integer, String> deliveryNotesMap;
    private final int currentPage;
    private final int totalPages;
    private final Integer activeStatus;

    public MyOrdersPageData(List<Order> orders, Map<Integer, List<OrderDetail>> detailsMap,
            int currentPage, int totalPages, Integer activeStatus) {
        this(orders, detailsMap, new HashMap<>(), currentPage, totalPages, activeStatus);
    }

    public MyOrdersPageData(List<Order> orders, Map<Integer, List<OrderDetail>> detailsMap,
            Map<Integer, String> deliveryNotesMap,
            int currentPage, int totalPages, Integer activeStatus) {
        this.orders = orders;
        this.detailsMap = detailsMap;
        this.deliveryNotesMap = deliveryNotesMap != null ? deliveryNotesMap : new HashMap<>();
        this.currentPage = currentPage;
        this.totalPages = totalPages;
        this.activeStatus = activeStatus;
    }

    public List<Order> getOrders() {
        return orders;
    }

    public Map<Integer, List<OrderDetail>> getDetailsMap() {
        return detailsMap;
    }

    public Map<Integer, String> getDeliveryNotesMap() {
        return deliveryNotesMap;
    }

    public int getCurrentPage() {
        return currentPage;
    }

    public int getTotalPages() {
        return totalPages;
    }

    public Integer getActiveStatus() {
        return activeStatus;
    }
}
