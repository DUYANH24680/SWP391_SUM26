package dao;

import model.Order;
import model.OrderDetail;
import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO extends DbContext {

    /**
     * Create a new order with its details in a transaction.
     */
    public boolean createOrder(Order order, List<OrderDetail> details) {
        String sqlOrder = "INSERT INTO Orders (customer_id, voucher_id, recipient_name, recipient_phone, address, payment_method, status, payment_status, total_cost, discount_amount, shipping_fee, final_cost, note, order_date) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";
        
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
     * Create a new order with a single detail for backward compatibility.
     */
    public boolean createOrder(Order order, OrderDetail detail) {
        return createOrder(order, List.of(detail));
    }

    /**
     * Get orders for a specific customer.
     */
    public List<Order> getOrdersByCustomerId(int customerId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.id, o.customer_id, o.voucher_id, o.recipient_name, o.recipient_phone, o.address, o.payment_method, "
                   + "o.status, o.payment_status, o.total_cost, o.discount_amount, o.shipping_fee, o.final_cost, o.note, o.order_date, o.cancelled_at, "
                   + "v.code AS voucher_code "
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

    public List<Order> getOrdersByCustomerIdAndStatus(int customerId, int status) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.id, o.customer_id, o.voucher_id, o.recipient_name, o.recipient_phone, o.address, o.payment_method, "
                   + "o.status, o.payment_status, o.total_cost, o.discount_amount, o.shipping_fee, o.final_cost, o.note, o.order_date, o.cancelled_at, "
                   + "v.code AS voucher_code "
                   + "FROM Orders o "
                   + "LEFT JOIN Vouchers v ON o.voucher_id = v.id "
                   + "WHERE o.customer_id = ? AND o.status = ? "
                   + "ORDER BY o.order_date DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = mapRow(rs);
                    o.setVoucherCode(rs.getString("voucher_code"));
                    list.add(o);
                }
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAO] getOrdersByCustomerIdAndStatus error: " + e.getMessage());
            throw new RuntimeException("OrderDAO.getOrdersByCustomerIdAndStatus error: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Get orders for products belonging to a specific shop (Seller view).
     */
    public List<Order> getOrdersByShopId(int shopId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT DISTINCT o.id, o.customer_id, o.voucher_id, o.recipient_name, o.recipient_phone, o.address, o.payment_method, "
                   + "o.status, o.payment_status, o.total_cost, o.discount_amount, o.shipping_fee, o.final_cost, o.note, o.order_date, o.cancelled_at, "
                   + "a.fullname AS customer_name, v.code AS voucher_code "
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
                   + "o.status, o.payment_status, o.total_cost, o.discount_amount, o.shipping_fee, o.final_cost, o.note, o.order_date, o.cancelled_at, "
                   + "a.fullname AS customer_name, v.code AS voucher_code "
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
     * Get items (OrderDetails) belonging to a specific order.
     */
    public List<OrderDetail> getOrderDetails(int orderId) {
        List<OrderDetail> list = new ArrayList<>();
        String sql = "SELECT od.id, od.order_id, od.product_id, od.quantity, od.unit_price, od.total_price, "
                   + "p.title AS product_title, p.image AS product_image, p.unit AS product_unit "
                   + "FROM OrderDetails od "
                   + "JOIN Products p ON od.product_id = p.id "
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

    /**
     * Check if order belongs to the seller's shop to prevent illegal updates
     */
    public boolean checkOrderOwnership(int orderId, int shopId) {
        String sql = "SELECT 1 FROM OrderDetails od "
                   + "JOIN Products p ON od.product_id = p.id "
                   + "WHERE od.order_id = ? AND p.shop_id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAO] checkOrderOwnership error: " + e.getMessage());
            throw new RuntimeException("OrderDAO.checkOrderOwnership error: " + e.getMessage(), e);
        }
    }

    /**
     * Confirm order (transitions from Pending=1 to Confirmed=2)
     */
    public boolean confirmOrder(int orderId) {
        String sqlCheck = "SELECT status FROM Orders WHERE id = ?";
        String sqlUpdate = "UPDATE Orders SET status = 2 WHERE id = ? AND status = 1";
        try (PreparedStatement psCheck = getConnection().prepareStatement(sqlCheck)) {
            psCheck.setInt(1, orderId);
            try (ResultSet rs = psCheck.executeQuery()) {
                if (rs.next()) {
                    int currentStatus = rs.getInt("status");
                    if (currentStatus != 1) {
                        System.out.println("[OrderDAO] confirmOrder: order " + orderId + " is not in Pending status (status=" + currentStatus + ")");
                        return false;
                    }
                } else {
                    System.out.println("[OrderDAO] confirmOrder: order " + orderId + " not found");
                    return false;
                }
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAO] confirmOrder status check error: " + e.getMessage());
            throw new RuntimeException("OrderDAO.confirmOrder error: " + e.getMessage(), e);
        }

        try (PreparedStatement psUpdate = getConnection().prepareStatement(sqlUpdate)) {
            psUpdate.setInt(1, orderId);
            return psUpdate.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[OrderDAO] confirmOrder update error: " + e.getMessage());
            throw new RuntimeException("OrderDAO.confirmOrder error: " + e.getMessage(), e);
        }
    }

    /**
     * Cancel order (transitions from Pending=1 to Canceled=5)
     * Restores product stock and decreases sold quantity, and restores voucher count in a transaction.
     */
    public boolean cancelOrder(int orderId) {
        Connection conn = null;
        PreparedStatement psOrder = null;
        PreparedStatement psDetails = null;
        PreparedStatement psProduct = null;
        PreparedStatement psVoucher = null;
        ResultSet rsOrder = null;
        ResultSet rsDetails = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            // 1. Get order information (current status, voucher_id) to verify
            String sqlGetOrder = "SELECT status, voucher_id FROM Orders WHERE id = ?";
            psOrder = conn.prepareStatement(sqlGetOrder);
            psOrder.setInt(1, orderId);
            rsOrder = psOrder.executeQuery();

            int currentStatus = -1;
            Integer voucherId = null;
            if (rsOrder.next()) {
                currentStatus = rsOrder.getInt("status");
                int vId = rsOrder.getInt("voucher_id");
                if (!rsOrder.wasNull()) {
                    voucherId = vId;
                }
            }

            // Clean up rsOrder and psOrder before moving forward
            rsOrder.close();
            psOrder.close();

            // Only Pending (1) orders can be canceled/rejected
            if (currentStatus != 1) {
                System.out.println("[OrderDAO] cancelOrder: order " + orderId + " cannot be canceled (current status=" + currentStatus + ")");
                conn.rollback();
                return false;
            }

            // 2. Update order status to 5 (Canceled) and set cancelled_at = GETDATE()
            String sqlUpdateOrder = "UPDATE Orders SET status = 5, cancelled_at = GETDATE() WHERE id = ?";
            try (PreparedStatement psUpdate = conn.prepareStatement(sqlUpdateOrder)) {
                psUpdate.setInt(1, orderId);
                psUpdate.executeUpdate();
            }

            // 3. Get order details to restore product stock and sold quantity
            String sqlGetDetails = "SELECT product_id, quantity FROM OrderDetails WHERE order_id = ?";
            psDetails = conn.prepareStatement(sqlGetDetails);
            psDetails.setInt(1, orderId);
            rsDetails = psDetails.executeQuery();

            String sqlRestoreProduct = "UPDATE Products SET stock_quantity = stock_quantity + ?, "
                                     + "sold_quantity = CASE WHEN sold_quantity >= ? THEN sold_quantity - ? ELSE 0 END "
                                     + "WHERE id = ?";
            psProduct = conn.prepareStatement(sqlRestoreProduct);

            while (rsDetails.next()) {
                int productId = rsDetails.getInt("product_id");
                int qty = rsDetails.getInt("quantity");

                psProduct.setInt(1, qty);
                psProduct.setInt(2, qty);
                psProduct.setInt(3, qty);
                psProduct.setInt(4, productId);
                psProduct.addBatch();
            }
            psProduct.executeBatch();

            // 4. Restore Voucher usage count if applicable
            if (voucherId != null) {
                String sqlRestoreVoucher = "UPDATE Vouchers SET used_count = CASE WHEN used_count > 0 THEN used_count - 1 ELSE 0 END WHERE id = ?";
                psVoucher = conn.prepareStatement(sqlRestoreVoucher);
                psVoucher.setInt(1, voucherId);
                psVoucher.executeUpdate();
            }

            conn.commit();
            System.out.println("[OrderDAO] cancelOrder: order " + orderId + " canceled successfully. Stock and voucher usage restored.");
            return true;
        } catch (SQLException e) {
            System.err.println("[OrderDAO] cancelOrder SQL error: " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    /* ignore */
                }
            }
            throw new RuntimeException("OrderDAO.cancelOrder error: " + e.getMessage(), e);
        } finally {
            if (rsOrder != null) try { rsOrder.close(); } catch (SQLException ignored) {}
            if (rsDetails != null) try { rsDetails.close(); } catch (SQLException ignored) {}
            if (psOrder != null) try { psOrder.close(); } catch (SQLException ignored) {}
            if (psDetails != null) try { psDetails.close(); } catch (SQLException ignored) {}
            if (psProduct != null) try { psProduct.close(); } catch (SQLException ignored) {}
            if (psVoucher != null) try { psVoucher.close(); } catch (SQLException ignored) {}
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ignored) {}
            }
        }
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
        return o;
    }
}

