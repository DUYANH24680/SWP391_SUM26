package service;

import dao.ShopDAO;
import dao.OrderDAO;
import dao.ProductDAO;
import model.Shop;
import model.Order;
import model.SellerDashboardData;
import java.util.List;

public class SellerDashboardService {

    public SellerDashboardData getDashboardData(int sellerId) {
        SellerDashboardData data = new SellerDashboardData();
        ShopDAO shopDAO = new ShopDAO();
        OrderDAO orderDAO = new OrderDAO();
        ProductDAO productDAO = new ProductDAO();

        try {
            Shop shop = shopDAO.getShopByOwnerId(sellerId);
            if (shop == null) {
                data.setShopNotApproved(true);
                data.setShopNotApprovedMsg("Cửa hàng của bạn chưa được tạo. Vui lòng tạo cửa hàng.");
            } else if (shop.getStatus() != 1) {
                data.setShopNotApproved(true);
                data.setShopNotApprovedMsg("Cửa hàng của bạn chưa được phê duyệt. Vui lòng đợi admin xác nhận.");
            } else {
                int totalProducts = productDAO.countProductsByShopId(shop.getId());
                List<Order> orders = orderDAO.getOrdersByShopId(shop.getId());
                
                int totalOrders = orders.size();
                int pendingOrders = 0;
                double totalRevenue = 0.0;
                
                for (Order o : orders) {
                    if (o.getStatus() == 1) {
                        pendingOrders++;
                    }
                    if (o.getStatus() == 4) {
                        totalRevenue += o.getShopActualRevenue();
                    }
                }
                
                data.setShop(shop);
                data.setTotalProducts(totalProducts);
                data.setTotalOrders(totalOrders);
                data.setPendingOrders(pendingOrders);
                data.setTotalRevenue(totalRevenue);
                data.setOrders(orders);
            }
        } catch (Exception e) {
            System.err.println("[SellerDashboardService] Error retrieving dashboard data: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("SellerDashboardService.getDashboardData error: " + e.getMessage(), e);
        } finally {
            shopDAO.close();
            orderDAO.close();
            productDAO.close();
        }
        return data;
    }
}
