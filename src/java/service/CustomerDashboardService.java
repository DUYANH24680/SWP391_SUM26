package service;

import dao.OrderDAO;
import model.CustomerOrdersData;
import model.Order;
import model.OrderDetail;

import java.util.*;
import model.CustomerDashboardData;

public class CustomerDashboardService {

    public CustomerDashboardData getDashboardData(int customerId) {
        OrderService orderService = new OrderService();
        try {
            CustomerOrdersData data = orderService.getCustomerOrdersWithDetails(customerId, null);
            List<Order> orders = data.getOrders();
            Map<Integer, List<OrderDetail>> detailsMap = data.getDetailsMap();

            return computeDashboardData(orders, detailsMap);
        } finally {
            orderService = null;
        }
    }

    public CustomerDashboardData computeDashboardData(List<Order> orders,
                                                      Map<Integer, List<OrderDetail>> detailsMap) {
        double totalSpent = 0;
        int pendingCount = 0;
        int confirmedCount = 0;
        int shippingCount = 0;
        int deliveredCount = 0;
        int canceledCount = 0;
        int recentOrderCount = 0;
        double monthlySpend = 0;

        Calendar thirtyDaysAgo = Calendar.getInstance();
        thirtyDaysAgo.add(Calendar.DAY_OF_MONTH, -30);
        Calendar monthStart = Calendar.getInstance();
        monthStart.set(Calendar.DAY_OF_MONTH, 1);
        monthStart.set(Calendar.HOUR_OF_DAY, 0);
        monthStart.set(Calendar.MINUTE, 0);
        monthStart.set(Calendar.SECOND, 0);
        monthStart.set(Calendar.MILLISECOND, 0);

        if (orders != null) {
            for (Order order : orders) {
                totalSpent += order.getFinalCost();
                switch (order.getStatus()) {
                    case 1 -> pendingCount++;
                    case 2 -> confirmedCount++;
                    case 3 -> shippingCount++;
                    case 4 -> deliveredCount++;
                    case 5 -> canceledCount++;
                    default -> {}
                }

                if (order.getOrderDate() != null) {
                    Calendar orderCal = Calendar.getInstance();
                    orderCal.setTimeInMillis(order.getOrderDate().getTime());
                    if (!orderCal.before(thirtyDaysAgo)) {
                        recentOrderCount++;
                    }
                    if (!orderCal.before(monthStart)) {
                        monthlySpend += order.getFinalCost();
                    }
                }
            }
        }

        List<Order> recentOrders = new ArrayList<>();
        if (orders != null) {
            for (Order order : orders) {
                if (order.getOrderDate() != null) {
                    Calendar orderCal = Calendar.getInstance();
                    orderCal.setTimeInMillis(order.getOrderDate().getTime());
                    if (!orderCal.before(thirtyDaysAgo)) {
                        recentOrders.add(order);
                    }
                }
            }
        }
        recentOrders.sort(Comparator.comparing(Order::getOrderDate).reversed());
        if (recentOrders.size() > 3) {
            recentOrders = new ArrayList<>(recentOrders.subList(0, 3));
        }

        double avgOrderValue = orders != null && !orders.isEmpty() ? totalSpent / orders.size() : 0;

        return new CustomerDashboardData(
                orders,
                detailsMap,
                orders != null ? orders.size() : 0,
                totalSpent,
                pendingCount,
                confirmedCount,
                shippingCount,
                deliveredCount,
                canceledCount,
                recentOrderCount,
                avgOrderValue,
                monthlySpend,
                recentOrders
        );
    }
}
