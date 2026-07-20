package service;

import dao.ShopDAO;
import dao.OrderDAO;
import dao.ProductDAO;
import model.Shop;
import model.Order;
import model.SellerDashboardData;
import Utils.DbContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;

public class SellerDashboardService extends DbContext {

    /**
     * Get today's revenue for a shop.
     */
    public double getTodayRevenue(int shopId) {
        String sql = "SELECT ISNULL(SUM(o.final_cost), 0) FROM Orders o "
                   + "JOIN OrderDetails od ON o.id = od.order_id "
                   + "JOIN Products p ON od.product_id = p.id "
                   + "WHERE p.shop_id = ? AND o.status = 4 "
                   + "AND CAST(o.order_date AS DATE) = CAST(GETDATE() AS DATE)";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble(1);
            }
        } catch (Exception e) {
            System.err.println("[SellerDashboardService] getTodayRevenue error: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Get this month's revenue for a shop.
     */
    public double getMonthRevenue(int shopId) {
        String sql = "SELECT ISNULL(SUM(o.final_cost), 0) FROM Orders o "
                   + "JOIN OrderDetails od ON o.id = od.order_id "
                   + "JOIN Products p ON od.product_id = p.id "
                   + "WHERE p.shop_id = ? AND o.status = 4 "
                   + "AND MONTH(o.order_date) = MONTH(GETDATE()) "
                   + "AND YEAR(o.order_date) = YEAR(GETDATE())";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble(1);
            }
        } catch (Exception e) {
            System.err.println("[SellerDashboardService] getMonthRevenue error: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Get count of today's orders.
     */
    public int getTodayOrderCount(int shopId) {
        String sql = "SELECT COUNT(DISTINCT o.id) FROM Orders o "
                   + "JOIN OrderDetails od ON o.id = od.order_id "
                   + "JOIN Products p ON od.product_id = p.id "
                   + "WHERE p.shop_id = ? "
                   + "AND CAST(o.order_date AS DATE) = CAST(GETDATE() AS DATE)";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            System.err.println("[SellerDashboardService] getTodayOrderCount error: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Get average order value (from completed orders).
     */
    public double getAverageOrderValue(int shopId) {
        String sql = "SELECT ISNULL(AVG(o.final_cost), 0) FROM Orders o "
                   + "JOIN OrderDetails od ON o.id = od.order_id "
                   + "JOIN Products p ON od.product_id = p.id "
                   + "WHERE p.shop_id = ? AND o.status = 4";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble(1);
            }
        } catch (Exception e) {
            System.err.println("[SellerDashboardService] getAverageOrderValue error: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Get pending order count.
     */
    public int getPendingOrderCount(int shopId) {
        String sql = "SELECT COUNT(DISTINCT o.id) FROM Orders o "
                   + "JOIN OrderDetails od ON o.id = od.order_id "
                   + "JOIN Products p ON od.product_id = p.id "
                   + "WHERE p.shop_id = ? AND o.status = 1";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            System.err.println("[SellerDashboardService] getPendingOrderCount error: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Get revenue grouped by day for the last N days (for chart).
     * Returns array of {label, value} pairs.
     */
    public List<String[]> getRevenueByDay(int shopId, int days) {
        java.util.List<String[]> result = new java.util.ArrayList<>();
        String sql = "SELECT CAST(o.order_date AS DATE) AS order_day, "
                   + "ISNULL(SUM(o.final_cost), 0) AS day_revenue "
                   + "FROM Orders o "
                   + "JOIN OrderDetails od ON o.id = od.order_id "
                   + "JOIN Products p ON od.product_id = p.id "
                   + "WHERE p.shop_id = ? AND o.status = 4 "
                   + "AND o.order_date >= DATEADD(day, -?, GETDATE()) "
                   + "GROUP BY CAST(o.order_date AS DATE) "
                   + "ORDER BY order_day ASC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            ps.setInt(2, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.add(new String[]{rs.getString("order_day"), String.valueOf(rs.getDouble("day_revenue"))});
                }
            }
        } catch (Exception e) {
            System.err.println("[SellerDashboardService] getRevenueByDay error: " + e.getMessage());
        }
        return result;
    }

    /**
     * Get filtered orders for a shop based on status and date range.
     */
    public List<Order> getFilteredOrders(int shopId, String statusParam, String dateFrom, String dateTo) {
        StringBuilder sql = new StringBuilder(
            "SELECT DISTINCT o.id, o.customer_id, o.voucher_id, o.recipient_name, o.recipient_phone, o.address, o.payment_method, "
          + "o.status, o.payment_status, o.total_cost, o.discount_amount, o.shipping_fee, o.final_cost, o.note, o.order_date, o.cancelled_at, "
          + "a.fullname AS customer_name, v.code AS voucher_code "
          + "FROM Orders o "
          + "JOIN OrderDetails od ON o.id = od.order_id "
          + "JOIN Products p ON od.product_id = p.id "
          + "JOIN Accounts a ON o.customer_id = a.id "
          + "LEFT JOIN Vouchers v ON o.voucher_id = v.id "
          + "WHERE p.shop_id = ? ");
        java.util.List<Object> params = new java.util.ArrayList<>();
        params.add(shopId);

        if (statusParam != null && !statusParam.isEmpty()) {
            try {
                int st = Integer.parseInt(statusParam);
                sql.append("AND o.status = ? ");
                params.add(st);
            } catch (NumberFormatException ignored) {}
        }
        if (dateFrom != null && !dateFrom.trim().isEmpty()) {
            sql.append("AND CAST(o.order_date AS DATE) >= ? ");
            params.add(dateFrom);
        }
        if (dateTo != null && !dateTo.trim().isEmpty()) {
            sql.append("AND CAST(o.order_date AS DATE) <= ? ");
            params.add(dateTo);
        }

        sql.append("ORDER BY o.order_date DESC");

        java.util.List<Order> result = new java.util.ArrayList<>();
        try (PreparedStatement ps = getConnection().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = new Order();
                    o.setId(rs.getInt("id"));
                    o.setCustomerId(rs.getInt("customer_id"));
                    o.setVoucherId(rs.getObject("voucher_id") != null ? rs.getInt("voucher_id") : null);
                    o.setRecipientName(rs.getString("recipient_name"));
                    o.setRecipientPhone(rs.getString("recipient_phone"));
                    o.setAddress(rs.getString("address"));
                    o.setPaymentMethod(rs.getString("payment_method"));
                    o.setStatus(rs.getInt("status"));
                    o.setPaymentStatus(rs.getInt("payment_status"));
                    o.setTotalCost(rs.getDouble("total_cost"));
                    o.setDiscountAmount(rs.getDouble("discount_amount"));
                    o.setShippingFee(rs.getDouble("shipping_fee"));
                    o.setFinalCost(rs.getDouble("final_cost"));
                    o.setNote(rs.getString("note"));
                    o.setOrderDate(rs.getTimestamp("order_date"));
                    o.setCancelledAt(rs.getTimestamp("cancelled_at"));
                    o.setCustomerName(rs.getString("customer_name"));
                    o.setVoucherCode(rs.getString("voucher_code"));
                    result.add(o);
                }
            }
        } catch (Exception e) {
            System.err.println("[SellerDashboardService] getFilteredOrders error: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

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
                int completedOrders = 0;
                double totalRevenue = 0.0;

                for (Order o : orders) {
                    if (o.getStatus() == 1) {
                        pendingOrders++;
                    }
                    if (o.getStatus() == 4) {
                        completedOrders++;
                        totalRevenue += (o.getTotalCost() - o.getDiscountAmount());
                    }
                }

                data.setShop(shop);
                data.setTotalProducts(totalProducts);
                data.setTotalOrders(totalOrders);
                data.setPendingOrders(pendingOrders);
                data.setCompletedOrders(completedOrders);
                data.setTotalRevenue(totalRevenue);
                data.setTodayRevenue(getTodayRevenue(shop.getId()));
                data.setMonthRevenue(getMonthRevenue(shop.getId()));
                data.setTodayOrderCount(getTodayOrderCount(shop.getId()));
                data.setAvgOrderValue(getAverageOrderValue(shop.getId()));
                data.setRevenueByDay(getRevenueByDay(shop.getId(), 14));
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
