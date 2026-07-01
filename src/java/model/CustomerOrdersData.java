package model;

import java.util.List;
import java.util.Map;

public class CustomerOrdersData {
    private final List<Order> orders;
    private final Map<Integer, List<OrderDetail>> detailsMap;

    public CustomerOrdersData(List<Order> orders, Map<Integer, List<OrderDetail>> detailsMap) {
        this.orders = orders;
        this.detailsMap = detailsMap;
    }

    public List<Order> getOrders() {
        return orders;
    }

    public Map<Integer, List<OrderDetail>> getDetailsMap() {
        return detailsMap;
    }
}
