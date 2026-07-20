package dao;

import model.Order;
import model.OrderDetail;
import model.Shop;
import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO extends DbContext {

    /**
     * Create a new order with its details in a transaction.
     */
    public boolean createOrder(Order order, OrderDetail detail) {
        List<OrderDetail> list = new ArrayList<>();
        list.add(detail);
        return createOrder(order, list);
    }

    /**
     * Create a new order with multiple details in a transaction.
     */
    public boolean createOrder(Order order, List<OrderDetail> details) {
        String sqlOrder = "INSERT INTO Orders (customer_id, voucher_id, recipient_name, recipient_phone, address, payment_method, status, payment_status, total_cost, discount_amount, shipping_fee, final_cost, note, order_date, platform_discount_amount, shop_actual_revenue) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), ?, ?)";

        String sqlDetail = "INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price, total_price) VALUES (?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement psOrder = null;
        PreparedStatement psDetail = null;
        ResultSet rsKeys = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            psOrder = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS);
            psOrder.setInt(1, order.getCustomerId());
            if (order.getVoucherId() != null) {
                psOrder.setInt(2, order.getVoucherId());
            } else {
                psOrder.setNull(2, Types.INTEGER);
            }
            psOrder.setString(3, order.getRecipientName());
            psOrder.setString(4, order.getRecipientPhone());
            psOrder.setString(5, order.getAddress());
            psOrder.setString(6, order.getPaymentMethod());
            psOrder.setInt(7, order.getStatus());
            psOrder.setInt(8, order.getPaymentStatus());
            psOrder.setDouble(9, order.getTotalCost());
            psOrder.setDouble(10, order.getDiscountAmount());
            psOrder.setDouble(11, order.getShippingFee());
            psOrder.setDouble(12, order.getFinalCost());
            psOrder.setString(13, order.getNote());
            psOrder.setDouble(14, order.getPlatformDiscountAmount());
            psOrder.setDouble(15, order.getShopActualRevenue());

            int affectedRows = psOrder.executeUpdate();
            if (affectedRows == 0) {
                conn.rollback();
                return false;
            }

            rsKeys = psOrder.getGeneratedKeys();
            if (!rsKeys.next()) {
                conn.rollback();
                return false;
            }
            int generatedOrderId = rsKeys.getInt(1);

            psDetail = conn.prepareStatement(sqlDetail);
            for (OrderDetail detail : details) {
                psDetail.setInt(1, generatedOrderId);
                psDetail.setInt(2, detail.getProductId());
                psDetail.setInt(3, detail.getQuantity());
                psDetail.setDouble(4, detail.getUnitPrice());
                psDetail.setDouble(5, detail.getTotalPrice());
                psDetail.addBatch();
            }

            psDetail.executeBatch();

            conn.commit();
            order.setId(generatedOrderId);
            for (OrderDetail d : details) {
                d.setOrderId(generatedOrderId);
            }
            System.out.println("[OrderDAO] Order created successfully, id = " + generatedOrderId);
            return true;
        } catch (SQLException e) {
            System.err.println("[OrderDAO] createOrder error: " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    /* ignore */
                }
            }
            throw new RuntimeException("OrderDAO.createOrder error: " + e.getMessage(), e);
        } finally {
            if (rsKeys != null) try { rsKeys.close(); } catch (SQLException ignored) {}
            if (psOrder != null) try { psOrder.close(); } catch (SQLException ignored) {}
            if (psDetail != null) try { psDetail.close(); } catch (SQLException ignored) {}
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ignored) {}
            }
        }
    }

    /**
     * Create multiple orders with their respective details in a single database transaction.
     */
    public boolean createMultipleOrders(List<Order> orders, List<List<OrderDetail>> detailsList) {
        if (orders == null || detailsList == null || orders.size() != detailsList.size() || orders.isEmpty()) {
            return false;
        }

        String sqlOrder = "INSERT INTO Orders (customer_id, voucher_id, recipient_name, recipient_phone, address, payment_method, status, payment_status, total_cost, discount_amount, shipping_fee, final_cost, note, order_date, platform_discount_amount, shop_actual_revenue) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), ?, ?)";
        
        String sqlDetail = "INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price, total_price) VALUES (?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement psOrder = null;
        PreparedStatement psDetail = null;
        ResultSet rsKeys = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            psOrder = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS);
            psDetail = conn.prepareStatement(sqlDetail);

            for (int i = 0; i < orders.size(); i++) {
                Order order = orders.get(i);
                List<OrderDetail> details = detailsList.get(i);

                psOrder.setInt(1, order.getCustomerId());
                if (order.getVoucherId() != null) {
                    psOrder.setInt(2, order.getVoucherId());
                } else {
                    psOrder.setNull(2, Types.INTEGER);
                }
                psOrder.setString(3, order.getRecipientName());
                psOrder.setString(4, order.getRecipientPhone());
                psOrder.setString(5, order.getAddress());
                psOrder.setString(6, order.getPaymentMethod());
                psOrder.setInt(7, order.getStatus());
                psOrder.setInt(8, order.getPaymentStatus());
                psOrder.setDouble(9, order.getTotalCost());
                psOrder.setDouble(10, order.getDiscountAmount());
                psOrder.setDouble(11, order.getShippingFee());
                psOrder.setDouble(12, order.getFinalCost());
                psOrder.setString(13, order.getNote());
                psOrder.setDouble(14, order.getPlatformDiscountAmount());
                psOrder.setDouble(15, order.getShopActualRevenue());

                int affectedRows = psOrder.executeUpdate();
                if (affectedRows == 0) {
                    conn.rollback();
                    return false;
                }

                rsKeys = psOrder.getGeneratedKeys();
                if (!rsKeys.next()) {
                    conn.rollback();
                    return false;
                }
                int generatedOrderId = rsKeys.getInt(1);
                order.setId(generatedOrderId);

                // Insert details for this order
                for (OrderDetail detail : details) {
                    psDetail.setInt(1, generatedOrderId);
                    psDetail.setInt(2, detail.getProductId());
                    psDetail.setInt(3, detail.getQuantity());
                    psDetail.setDouble(4, detail.getUnitPrice());
                    psDetail.setDouble(5, detail.getTotalPrice());
                    psDetail.addBatch();
                    
                    detail.setOrderId(generatedOrderId);
                }
                psDetail.executeBatch();
                psDetail.clearBatch();
                
                rsKeys.close();
                rsKeys = null;
            }

            conn.commit();
            System.out.println("[OrderDAO] createMultipleOrders: " + orders.size() + " orders created successfully.");
            return true;
        } catch (SQLException e) {
            System.err.println("[OrderDAO] createMultipleOrders error: " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    /* ignore */
                }
            }
            throw new RuntimeException("OrderDAO.createMultipleOrders error: " + e.getMessage(), e);
        } finally {
            if (rsKeys != null) try { rsKeys.close(); } catch (SQLException ignored) {}
            if (psOrder != null) try { psOrder.close(); } catch (SQLException ignored) {}
            if (psDetail != null) try { psDetail.close(); } catch (SQLException ignored) {}
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ignored) {}
            }
        }
    }


    /**
     * Get orders for a specific customer.
     */
    public List<Order> getOrdersByCustomerId(int customerId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.id, o.customer_id, o.voucher_id, o.recipient_name, o.recipient_phone, o.address, o.payment_method, "
                   + "o.status, o.payment_status, o.total_cost, o.discount_amount, o.shipping_fee, o.final_cost, o.note, o.order_date, o.cancelled_at, o.cancel_reason, "
                   + "o.platform_discount_amount, o.shop_actual_revenue, v.code AS voucher_code "
                   + "FROM Orders o "
                   + "LEFT JOIN Vouchers v ON o.voucher_id = v.id "
                   + "WHERE o.customer_id = ? "
                   + "ORDER BY o.order_date DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = mapRow(rs);
                    o.setVoucherCode(rs.getString("voucher_code"));
                    list.add(o);
                }
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAO] getOrdersByCustomerId error: " + e.getMessage());
            throw new RuntimeException("OrderDAO.getOrdersByCustomerId error: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Get orders for products belonging to a specific shop (Seller view).
     */
    public List<Order> getOrdersByShopId(int shopId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT DISTINCT o.id, o.customer_id, o.voucher_id, o.recipient_name, o.recipient_phone, o.address, o.payment_method, "
                   + "o.status, o.payment_status, o.total_cost, o.discount_amount, o.shipping_fee, o.final_cost, o.note, o.order_date, o.cancelled_at, o.cancel_reason, "
                   + "o.platform_discount_amount, o.shop_actual_revenue, a.fullname AS customer_name, v.code AS voucher_code "
                   + "FROM Orders o "
                   + "JOIN OrderDetails od ON o.id = od.order_id "
                   + "JOIN Products p ON od.product_id = p.id "
                   + "JOIN Accounts a ON o.customer_id = a.id "
                   + "LEFT JOIN Vouchers v ON o.voucher_id = v.id "
                   + "WHERE p.shop_id = ? "
                   + "ORDER BY o.order_date DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = mapRow(rs);
                    o.setCustomerName(rs.getString("customer_name"));
                    o.setVoucherCode(rs.getString("voucher_code"));
                    list.add(o);
                }
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAO] getOrdersByShopId error: " + e.getMessage());
            throw new RuntimeException("OrderDAO.getOrdersByShopId error: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Get details of a single order.
     */
    public Order getOrderById(int orderId) {
        String sql = "SELECT o.id, o.customer_id, o.voucher_id, o.recipient_name, o.recipient_phone, o.address, o.payment_method, "
                   + "o.status, o.payment_status, o.total_cost, o.discount_amount, o.shipping_fee, o.final_cost, o.note, o.order_date, o.cancelled_at, o.cancel_reason, "
                   + "o.platform_discount_amount, o.shop_actual_revenue, a.fullname AS customer_name, v.code AS voucher_code "
                   + "FROM Orders o "
                   + "JOIN Accounts a ON o.customer_id = a.id "
                   + "LEFT JOIN Vouchers v ON o.voucher_id = v.id "
                   + "WHERE o.id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order o = mapRow(rs);
                    o.setCustomerName(rs.getString("customer_name"));
                    o.setVoucherCode(rs.getString("voucher_code"));
                    return o;
                }
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAO] getOrderById error: " + e.getMessage());
            throw new RuntimeException("OrderDAO.getOrderById error: " + e.getMessage(), e);
        }
        return null;
    }
    /**
     * Get all orders for Admin with optional filters: status, shop, date range, value range.
     * Returns orders from ALL shops across the entire system.
     */
    public List<Order> getAllOrdersForAdmin(Integer status, Integer shopId,
            java.sql.Date fromDate, java.sql.Date toDate,
            Double minValue, Double maxValue) {
        List<Order> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT o.id, o.customer_id, o.voucher_id, o.recipient_name, o.recipient_phone, o.address, o.payment_method, "
          + "o.status, o.payment_status, o.total_cost, o.discount_amount, o.shipping_fee, o.final_cost, o.note, o.order_date, o.cancelled_at, o.cancel_reason, "
          + "o.platform_discount_amount, o.shop_actual_revenue, a.fullname AS customer_name, v.code AS voucher_code, s.shop_name "
          + "FROM Orders o "
          + "JOIN OrderDetails od ON o.id = od.order_id "
          + "JOIN Products p ON od.product_id = p.id "
          + "JOIN Shops s ON p.shop_id = s.id "
          + "JOIN Accounts a ON o.customer_id = a.id "
          + "LEFT JOIN Vouchers v ON o.voucher_id = v.id "
          + "WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (shopId != null && shopId > 0) {
            sql.append("AND p.shop_id = ? ");
            params.add(shopId);
        }
        if (status != null && status > 0) {
            sql.append("AND o.status = ? ");
            params.add(status);
        }
        if (fromDate != null) {
            sql.append("AND CAST(o.order_date AS DATE) >= ? ");
            params.add(fromDate);
        }
        if (toDate != null) {
            sql.append("AND CAST(o.order_date AS DATE) <= ? ");
            params.add(toDate);
        }
        if (minValue != null) {
            sql.append("AND o.final_cost >= ? ");
            params.add(minValue);
        }
        if (maxValue != null) {
            sql.append("AND o.final_cost <= ? ");
            params.add(maxValue);
        }

        sql.append("GROUP BY o.id, o.customer_id, o.voucher_id, o.recipient_name, o.recipient_phone, o.address, o.payment_method, "
                 + "o.status, o.payment_status, o.total_cost, o.discount_amount, o.shipping_fee, o.final_cost, o.note, o.order_date, o.cancelled_at, o.cancel_reason, "
                 + "o.platform_discount_amount, o.shop_actual_revenue, a.fullname, v.code, s.shop_name "
                 + "ORDER BY o.order_date DESC");

        try (PreparedStatement ps = getConnection().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = mapRow(rs);
                    o.setCustomerName(rs.getString("customer_name"));
                    o.setVoucherCode(rs.getString("voucher_code"));
                    o.setShopName(rs.getString("shop_name"));
                    list.add(o);
                }
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAO] getAllOrdersForAdmin error: " + e.getMessage());
            throw new RuntimeException("OrderDAO.getAllOrdersForAdmin error: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Count total orders for Admin with optional filters (for pagination).
     */
    public int getAllOrdersForAdminCount(Integer status, Integer shopId,
            java.sql.Date fromDate, java.sql.Date toDate,
            Double minValue, Double maxValue) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(DISTINCT o.id) "
          + "FROM Orders o "
          + "JOIN OrderDetails od ON o.id = od.order_id "
          + "JOIN Products p ON od.product_id = p.id "
          + "JOIN Shops s ON p.shop_id = s.id "
          + "WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (shopId != null && shopId > 0) {
            sql.append("AND p.shop_id = ? ");
            params.add(shopId);
        }
        if (status != null && status > 0) {
            sql.append("AND o.status = ? ");
            params.add(status);
        }
        if (fromDate != null) {
            sql.append("AND CAST(o.order_date AS DATE) >= ? ");
            params.add(fromDate);
        }
        if (toDate != null) {
            sql.append("AND CAST(o.order_date AS DATE) <= ? ");
            params.add(toDate);
        }
        if (minValue != null) {
            sql.append("AND o.final_cost >= ? ");
            params.add(minValue);
        }
        if (maxValue != null) {
            sql.append("AND o.final_cost <= ? ");
            params.add(maxValue);
        }

        try (PreparedStatement ps = getConnection().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAO] getAllOrdersForAdminCount error: " + e.getMessage());
            throw new RuntimeException("OrderDAO.getAllOrdersForAdminCount error: " + e.getMessage(), e);
        }
        return 0;
    }

    /**
     * Get all orders for Admin with pagination and optional filters.
     * Returns orders from ALL shops across the entire system.
     */
    public List<Order> getAllOrdersForAdmin(Integer status, Integer shopId,
            java.sql.Date fromDate, java.sql.Date toDate,
            Double minValue, Double maxValue, int page, int pageSize) {
        List<Order> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT o.id, o.customer_id, o.voucher_id, o.recipient_name, o.recipient_phone, o.address, o.payment_method, "
          + "o.status, o.payment_status, o.total_cost, o.discount_amount, o.shipping_fee, o.final_cost, o.note, o.order_date, o.cancelled_at, o.cancel_reason, "
          + "o.platform_discount_amount, o.shop_actual_revenue, a.fullname AS customer_name, v.code AS voucher_code, s.shop_name "
          + "FROM Orders o "
          + "JOIN OrderDetails od ON o.id = od.order_id "
          + "JOIN Products p ON od.product_id = p.id "
          + "JOIN Shops s ON p.shop_id = s.id "
          + "JOIN Accounts a ON o.customer_id = a.id "
          + "LEFT JOIN Vouchers v ON o.voucher_id = v.id "
          + "WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (shopId != null && shopId > 0) {
            sql.append("AND p.shop_id = ? ");
            params.add(shopId);
        }
        if (status != null && status > 0) {
            sql.append("AND o.status = ? ");
            params.add(status);
        }
        if (fromDate != null) {
            sql.append("AND CAST(o.order_date AS DATE) >= ? ");
            params.add(fromDate);
        }
        if (toDate != null) {
            sql.append("AND CAST(o.order_date AS DATE) <= ? ");
            params.add(toDate);
        }
        if (minValue != null) {
            sql.append("AND o.final_cost >= ? ");
            params.add(minValue);
        }
        if (maxValue != null) {
            sql.append("AND o.final_cost <= ? ");
            params.add(maxValue);
        }

        sql.append("GROUP BY o.id, o.customer_id, o.voucher_id, o.recipient_name, o.recipient_phone, o.address, o.payment_method, "
                 + "o.status, o.payment_status, o.total_cost, o.discount_amount, o.shipping_fee, o.final_cost, o.note, o.order_date, o.cancelled_at, o.cancel_reason, "
                 + "o.platform_discount_amount, o.shop_actual_revenue, a.fullname, v.code, s.shop_name "
                 + "ORDER BY o.order_date DESC "
                 + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        int offset = (page - 1) * pageSize;
        params.add(offset);
        params.add(pageSize);

        try (PreparedStatement ps = getConnection().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = mapRow(rs);
                    o.setCustomerName(rs.getString("customer_name"));
                    o.setVoucherCode(rs.getString("voucher_code"));
                    o.setShopName(rs.getString("shop_name"));
                    list.add(o);
                }
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAO] getAllOrdersForAdmin (paginated) error: " + e.getMessage());
            throw new RuntimeException("OrderDAO.getAllOrdersForAdmin error: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Get items (OrderDetails) belonging to a specific order.
     */
    public List<OrderDetail> getOrderDetails(int orderId) {
        List<OrderDetail> list = new ArrayList<>();
        String sql = "SELECT od.id, od.order_id, od.product_id, od.quantity, od.unit_price, od.total_price, "
                   + "p.title AS product_title, p.image AS product_image, p.unit AS product_unit, p.shop_id, s.shop_name "
                   + "FROM OrderDetails od "
                   + "JOIN Products p ON od.product_id = p.id "
                   + "LEFT JOIN Shops s ON p.shop_id = s.id "
                   + "WHERE od.order_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderDetail od = new OrderDetail();
                    od.setId(rs.getInt("id"));
                    od.setOrderId(rs.getInt("order_id"));
                    od.setProductId(rs.getInt("product_id"));
                    od.setQuantity(rs.getInt("quantity"));
                    od.setUnitPrice(rs.getDouble("unit_price"));
                    od.setTotalPrice(rs.getDouble("total_price"));
                    od.setProductTitle(rs.getString("product_title"));
                    od.setProductImage(rs.getString("product_image"));
                    od.setProductUnit(rs.getString("product_unit"));
                    od.setShopName(rs.getString("shop_name"));
                    list.add(od);
                }
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAO] getOrderDetails error: " + e.getMessage());
            throw new RuntimeException("OrderDAO.getOrderDetails error: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Update order status.
     */
    public boolean updateOrderStatus(int orderId, int status) {
        String sql = "UPDATE Orders SET status = ?, cancelled_at = (CASE WHEN ? = 5 THEN GETDATE() ELSE NULL END) WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setInt(2, status);
            ps.setInt(3, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[OrderDAO] updateOrderStatus error: " + e.getMessage());
            throw new RuntimeException("OrderDAO.updateOrderStatus error: " + e.getMessage(), e);
        }
    }

    public boolean updateOrderStatus(int orderId, int status, String cancelReason) {
        String sql = "UPDATE Orders SET status = ?, cancelled_at = (CASE WHEN ? = 5 THEN GETDATE() ELSE NULL END), cancel_reason = ? WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setInt(2, status);
            if (cancelReason != null) {
                ps.setString(3, cancelReason);
            } else {
                ps.setNull(3, Types.NVARCHAR);
            }
            ps.setInt(4, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[OrderDAO] updateOrderStatus with reason error: " + e.getMessage());
            throw new RuntimeException("OrderDAO.updateOrderStatus error: " + e.getMessage(), e);
        }
    }

    public int cancelLateUnconfirmedOrders(int thresholdHours) {
        String sql = "UPDATE Orders SET status = 5, cancelled_at = GETDATE(), "
                   + "cancel_reason = N'Hủy tự động: Cửa hàng không xác nhận đơn hàng sau ' + CAST(? AS VARCHAR) + N' giờ.' "
                   + "WHERE status = 1 AND DATEDIFF(hour, order_date, GETDATE()) >= ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, thresholdHours);
            ps.setInt(2, thresholdHours);
            return ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[OrderDAO] cancelLateUnconfirmedOrders error: " + e.getMessage());
            throw new RuntimeException("OrderDAO.cancelLateUnconfirmedOrders error: " + e.getMessage(), e);
        }
    }
        /**
     * Get filtered orders for a specific shop (Seller view).
     * Supports filtering by status, date range, and total value range.
     */
    public List<Order> getOrdersByShopIdFiltered(int shopId, Integer status,
            java.sql.Date fromDate, java.sql.Date toDate,
            Double minValue, Double maxValue) {
        List<Order> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT DISTINCT o.id, o.customer_id, o.voucher_id, o.recipient_name, o.recipient_phone, o.address, o.payment_method, "
          + "o.status, o.payment_status, o.total_cost, o.discount_amount, o.shipping_fee, o.final_cost, o.note, o.order_date, o.cancelled_at, o.cancel_reason, "
          + "o.platform_discount_amount, o.shop_actual_revenue, a.fullname AS customer_name, v.code AS voucher_code "
          + "FROM Orders o "
          + "JOIN OrderDetails od ON o.id = od.order_id "
          + "JOIN Products p ON od.product_id = p.id "
          + "JOIN Accounts a ON o.customer_id = a.id "
          + "LEFT JOIN Vouchers v ON o.voucher_id = v.id "
          + "WHERE p.shop_id = ? ");

        List<Object> params = new ArrayList<>();
        params.add(shopId);

        if (status != null && status > 0) {
            sql.append("AND o.status = ? ");
            params.add(status);
        }
        if (fromDate != null) {
            sql.append("AND CAST(o.order_date AS DATE) >= ? ");
            params.add(fromDate);
        }
        if (toDate != null) {
            sql.append("AND CAST(o.order_date AS DATE) <= ? ");
            params.add(toDate);
        }
        if (minValue != null) {
            sql.append("AND o.final_cost >= ? ");
            params.add(minValue);
        }
        if (maxValue != null) {
            sql.append("AND o.final_cost <= ? ");
            params.add(maxValue);
        }

        sql.append("ORDER BY o.order_date DESC");

        try (PreparedStatement ps = getConnection().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = mapRow(rs);
                    o.setCustomerName(rs.getString("customer_name"));
                    o.setVoucherCode(rs.getString("voucher_code"));
                    list.add(o);
                }
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAO] getOrdersByShopIdFiltered error: " + e.getMessage());
            throw new RuntimeException("OrderDAO.getOrdersByShopIdFiltered error: " + e.getMessage(), e);
        }
        return list;
    }


    /**
     * Get seller ID for an order by joining Orders -> OrderDetails -> Products -> Shops -> Accounts.
     */
    public int getSellerIdByOrderId(int orderId) {
        String sql = "SELECT TOP 1 a.id "
                   + "FROM Orders o "
                   + "JOIN OrderDetails od ON od.order_id = o.id "
                   + "JOIN Products p ON p.id = od.product_id "
                   + "JOIN Shops s ON s.id = p.shop_id "
                   + "JOIN Accounts a ON a.id = s.owner_id "
                   + "WHERE o.id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAO] getSellerIdByOrderId error: " + e.getMessage());
        }
        return -1;
    }


    private Order mapRow(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setId(rs.getInt("id"));
        o.setCustomerId(rs.getInt("customer_id"));
        int vId = rs.getInt("voucher_id");
        o.setVoucherId(rs.wasNull() ? null : vId);
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
        o.setCancelReason(rs.getString("cancel_reason"));
        o.setPlatformDiscountAmount(rs.getDouble("platform_discount_amount"));
        o.setShopActualRevenue(rs.getDouble("shop_actual_revenue"));
        return o;
    }
}
