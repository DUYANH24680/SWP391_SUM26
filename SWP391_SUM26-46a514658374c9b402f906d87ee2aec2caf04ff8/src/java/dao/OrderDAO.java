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
    public boolean createOrder(Order order, OrderDetail detail) {
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
            psDetail.setInt(1, generatedOrderId);
            psDetail.setInt(2, detail.getProductId());
            psDetail.setInt(3, detail.getQuantity());
            psDetail.setDouble(4, detail.getUnitPrice());
            psDetail.setDouble(5, detail.getTotalPrice());

            psDetail.executeUpdate();

            conn.commit();
            order.setId(generatedOrderId);
            detail.setOrderId(generatedOrderId);
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

