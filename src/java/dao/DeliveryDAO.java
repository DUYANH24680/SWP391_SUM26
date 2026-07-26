package dao;

import model.DeliveryOrder;
import model.OrderTracking;
import model.Order;
import model.OrderDetail;
import Utils.DbContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * DeliveryDAO - Handles all DB operations for DeliveryOrders and OrderTracking tables.
 */
public class DeliveryDAO extends DbContext {
    
    // ==================== Delivery Order Methods ====================
    
    /**
     * Assign a shipper to an order.
     * Creates delivery order and initial tracking record.
     */
    public boolean assignShipper(int orderId, int shipperId, int assignedBy, String note) {
        String sqlDelivery = "INSERT INTO DeliveryOrders (order_id, shipper_id, status, note) "
                           + "VALUES (?, ?, ?, ?)";
        String sqlOrderStatus = "UPDATE Orders SET status = 3 WHERE id = ?"; // 3 = Shipping
        
        Connection conn = null;
        PreparedStatement psDelivery = null;
        PreparedStatement psOrderStatus = null;
        
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // Insert delivery order
            psDelivery = conn.prepareStatement(sqlDelivery);
            psDelivery.setInt(1, orderId);
            psDelivery.setInt(2, shipperId);
            psDelivery.setInt(3, DeliveryOrder.STATUS_ASSIGNED);
            psDelivery.setString(4, note);
            int deliveryRows = psDelivery.executeUpdate();
            
            if (deliveryRows == 0) {
                conn.rollback();
                return false;
            }
            
            // Try inserting tracking record if OrderTracking table exists
            try {
                String sqlTracking = "INSERT INTO OrderTracking (order_id, status, description, updated_by) "
                                   + "VALUES (?, ?, ?, ?)";
                try (PreparedStatement psTracking = conn.prepareStatement(sqlTracking)) {
                    psTracking.setInt(1, orderId);
                    psTracking.setString(2, OrderTracking.Status.DELIVERY_ASSIGNED);
                    psTracking.setString(3, "Đơn hàng đã được giao cho shipper. Mã đơn: " + orderId);
                    psTracking.setInt(4, assignedBy);
                    psTracking.executeUpdate();
                }
            } catch (SQLException ex) {
                System.err.println("[DeliveryDAO] OrderTracking table optional insert warning: " + ex.getMessage());
            }
            
            // Update order status
            psOrderStatus = conn.prepareStatement(sqlOrderStatus);
            psOrderStatus.setInt(1, orderId);
            psOrderStatus.executeUpdate();
            
            conn.commit();
            System.out.println("[DeliveryDAO] assignShipper success: orderId=" + orderId + ", shipperId=" + shipperId);
            return true;
            
        } catch (SQLException e) {
            System.err.println("[DeliveryDAO] assignShipper error: " + e.getMessage());
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { /* ignore */ }
            }
            throw new RuntimeException("DeliveryDAO.assignShipper error: " + e.getMessage(), e);
        } finally {
            closeResources(psDelivery, null, psOrderStatus, conn);
        }
    }
    
    /**
     * Accept delivery by shipper.
     */
    public boolean acceptDelivery(int deliveryId, int shipperId) {
        String sqlDelivery = "UPDATE DeliveryOrders SET status = ? "
                           + "WHERE id = ? AND shipper_id = ? AND status = ?";
        
        Connection conn = null;
        PreparedStatement psDelivery = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // Get order_id before update
            int orderId = 0;
            psDelivery = conn.prepareStatement("SELECT order_id FROM DeliveryOrders WHERE id = ?");
            psDelivery.setInt(1, deliveryId);
            rs = psDelivery.executeQuery();
            if (rs.next()) {
                orderId = rs.getInt("order_id");
            }
            rs.close();
            psDelivery.close();
            
            // Update delivery status
            psDelivery = conn.prepareStatement(sqlDelivery);
            psDelivery.setInt(1, DeliveryOrder.STATUS_ACCEPTED);
            psDelivery.setInt(2, deliveryId);
            psDelivery.setInt(3, shipperId);
            psDelivery.setInt(4, DeliveryOrder.STATUS_ASSIGNED);
            int updated = psDelivery.executeUpdate();
            
            if (updated == 0) {
                conn.rollback();
                return false;
            }
            
            // Try insert tracking record
            try {
                String sqlTracking = "INSERT INTO OrderTracking (order_id, delivery_id, status, description, updated_by) "
                                   + "SELECT order_id, ?, ?, ?, ? FROM DeliveryOrders WHERE id = ?";
                try (PreparedStatement psTracking = conn.prepareStatement(sqlTracking)) {
                    psTracking.setInt(1, deliveryId);
                    psTracking.setString(2, OrderTracking.Status.DELIVERY_ACCEPTED);
                    psTracking.setString(3, "Shipper đã chấp nhận giao hàng. Mã giao hàng: " + deliveryId);
                    psTracking.setInt(4, shipperId);
                    psTracking.setInt(5, deliveryId);
                    psTracking.executeUpdate();
                }
            } catch (SQLException ex) {
                System.err.println("[DeliveryDAO] OrderTracking optional insert warning: " + ex.getMessage());
            }
            
            conn.commit();
            System.out.println("[DeliveryDAO] acceptDelivery success: deliveryId=" + deliveryId);
            return true;
            
        } catch (SQLException e) {
            System.err.println("[DeliveryDAO] acceptDelivery error: " + e.getMessage());
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { /* ignore */ }
            }
            throw new RuntimeException("DeliveryDAO.acceptDelivery error: " + e.getMessage(), e);
        } finally {
            closeResources(psDelivery, null, null, conn);
        }
    }
    
    /**
     * Update delivery status with tracking.
     * Status values: 3=PickingUp, 4=Delivering, 5=Delivered, 6=Failed
     */
    public boolean updateStatus(int deliveryId, int shipperId, int newStatus, String note, String trackingStatus) {
        StringBuilder sqlDelivery = new StringBuilder("UPDATE DeliveryOrders SET status = ?");
        if (note != null && !note.trim().isEmpty()) {
            sqlDelivery.append(", note = ?");
        }
        sqlDelivery.append(" WHERE id = ? AND shipper_id = ?");
        
        String sqlOrderStatus = "UPDATE Orders SET status = ? WHERE id = "
                              + "(SELECT order_id FROM DeliveryOrders WHERE id = ?)";
        
        Connection conn = null;
        PreparedStatement psDelivery = null;
        PreparedStatement psOrderStatus = null;
        
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // Update delivery status
            psDelivery = conn.prepareStatement(sqlDelivery.toString());
            int paramIndex = 1;
            psDelivery.setInt(paramIndex++, newStatus);
            
            if (note != null && !note.trim().isEmpty()) {
                psDelivery.setString(paramIndex++, note);
            }
            
            psDelivery.setInt(paramIndex++, deliveryId);
            psDelivery.setInt(paramIndex++, shipperId);
            int updated = psDelivery.executeUpdate();
            psDelivery.close();
            
            if (updated == 0) {
                conn.rollback();
                return false;
            }
            
            // Try insert tracking record
            try {
                String sqlTracking = "INSERT INTO OrderTracking (order_id, delivery_id, status, description, updated_by) "
                                   + "SELECT order_id, ?, ?, ?, ? FROM DeliveryOrders WHERE id = ?";
                try (PreparedStatement psTracking = conn.prepareStatement(sqlTracking)) {
                    psTracking.setInt(1, deliveryId);
                    psTracking.setString(2, trackingStatus);
                    psTracking.setString(3, note != null ? note : getDefaultTrackingDescription(newStatus, deliveryId));
                    psTracking.setInt(4, shipperId);
                    psTracking.setInt(5, deliveryId);
                    psTracking.executeUpdate();
                }
            } catch (SQLException ex) {
                System.err.println("[DeliveryDAO] OrderTracking optional insert warning: " + ex.getMessage());
            }
            
            // Update order status if delivered or failed
            if (newStatus == DeliveryOrder.STATUS_DELIVERED) {
                psOrderStatus = conn.prepareStatement(sqlOrderStatus);
                psOrderStatus.setInt(1, 4); // 4 = Delivered
                psOrderStatus.setInt(2, deliveryId);
                psOrderStatus.executeUpdate();
            } else if (newStatus == DeliveryOrder.STATUS_FAILED) {
                psOrderStatus = conn.prepareStatement(sqlOrderStatus);
                psOrderStatus.setInt(1, 5); // 5 = Cancelled
                psOrderStatus.setInt(2, deliveryId);
                psOrderStatus.executeUpdate();
            }
            
            conn.commit();
            System.out.println("[DeliveryDAO] updateStatus success: deliveryId=" + deliveryId + ", newStatus=" + newStatus);
            return true;
            
        } catch (SQLException e) {
            System.err.println("[DeliveryDAO] updateStatus error: " + e.getMessage());
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { /* ignore */ }
            }
            throw new RuntimeException("DeliveryDAO.updateStatus error: " + e.getMessage(), e);
        } finally {
            closeResources(psDelivery, null, psOrderStatus, conn);
        }
    }
    
    /**
     * Confirm delivery completion (shortcut for delivered status).
     */
    public boolean confirmDelivery(int deliveryId, int shipperId, String note) {
        return updateStatus(deliveryId, shipperId, DeliveryOrder.STATUS_DELIVERED, note, 
                          OrderTracking.Status.DELIVERY_COMPLETED);
    }
    
    /**
     * Get delivery order by ID.
     */
    public DeliveryOrder getDeliveryById(int deliveryId) {
        String sql = "SELECT d.id, d.order_id, d.shipper_id, d.status, d.note, "
                   + "s.fullname AS shipper_name, s.phone AS shipper_phone, "
                   + "o.status AS order_status, o.final_cost, "
                   + "o.recipient_name, o.recipient_phone, o.address AS delivery_address "
                   + "FROM DeliveryOrders d "
                   + "LEFT JOIN Accounts s ON d.shipper_id = s.id "
                   + "LEFT JOIN Orders o ON d.order_id = o.id "
                   + "WHERE d.id = ?";
        
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, deliveryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapDeliveryRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[DeliveryDAO] getDeliveryById error: " + e.getMessage());
            throw new RuntimeException("DeliveryDAO.getDeliveryById error: " + e.getMessage(), e);
        }
        return null;
    }
    
    /**
     * Get delivery order by order ID.
     */
    public DeliveryOrder getDeliveryByOrderId(int orderId) {
        String sql = "SELECT d.id, d.order_id, d.shipper_id, d.status, d.note, "
                   + "s.fullname AS shipper_name, s.phone AS shipper_phone, "
                   + "o.status AS order_status, o.final_cost, "
                   + "o.recipient_name, o.recipient_phone, o.address AS delivery_address "
                   + "FROM DeliveryOrders d "
                   + "LEFT JOIN Accounts s ON d.shipper_id = s.id "
                   + "LEFT JOIN Orders o ON d.order_id = o.id "
                   + "WHERE d.order_id = ?";
        
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapDeliveryRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[DeliveryDAO] getDeliveryByOrderId error: " + e.getMessage());
            throw new RuntimeException("DeliveryDAO.getDeliveryByOrderId error: " + e.getMessage(), e);
        }
        return null;
    }
    
    /**
     * Get all orders assigned to a specific shipper.
     */
    public List<DeliveryOrder> getDeliveriesByShipperId(int shipperId) {
        return getDeliveriesByShipperId(shipperId, null);
    }
    
    /**
     * Get orders assigned to a shipper with status filter.
     */
    public List<DeliveryOrder> getDeliveriesByShipperId(int shipperId, Integer status) {
        List<DeliveryOrder> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT d.order_id, d.shipper_id, d.status, d.note, "
          + "s.fullname AS shipper_name, s.phone AS shipper_phone, "
          + "o.status AS order_status, o.final_cost, "
          + "o.recipient_name, o.recipient_phone, o.address AS delivery_address "
          + "FROM DeliveryOrders d "
          + "LEFT JOIN Accounts s ON d.shipper_id = s.id "
          + "LEFT JOIN Orders o ON d.order_id = o.id "
          + "WHERE d.shipper_id = ? "
        );
        
        if (status != null) {
            sql.append("AND d.status = ? ");
        }
        sql.append("ORDER BY d.order_id DESC");
        
        try (PreparedStatement ps = getConnection().prepareStatement(sql.toString())) {
            ps.setInt(1, shipperId);
            if (status != null) {
                ps.setInt(2, status);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapDeliveryRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[DeliveryDAO] getDeliveriesByShipperId error: " + e.getMessage());
            throw new RuntimeException("DeliveryDAO.getDeliveriesByShipperId error: " + e.getMessage(), e);
        }
        return list;
    }
    
    /**
     * Get all delivery orders.
     */
    public List<DeliveryOrder> getAllDeliveries() {
        List<DeliveryOrder> list = new ArrayList<>();
        String sql = "SELECT d.order_id, d.shipper_id, d.status, d.note, "
                   + "s.fullname AS shipper_name, s.phone AS shipper_phone, "
                   + "o.status AS order_status, o.final_cost, "
                   + "o.recipient_name, o.recipient_phone, o.address AS delivery_address "
                   + "FROM DeliveryOrders d "
                   + "LEFT JOIN Accounts s ON d.shipper_id = s.id "
                   + "LEFT JOIN Orders o ON d.order_id = o.id "
                   + "ORDER BY d.order_id DESC";
        
        try (PreparedStatement ps = getConnection().prepareStatement(sql);
              ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapDeliveryRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[DeliveryDAO] getAllDeliveries error: " + e.getMessage());
            throw new RuntimeException("DeliveryDAO.getAllDeliveries error: " + e.getMessage(), e);
        }
        return list;
    }
    
    /**
     * Get orders waiting for delivery assignment (status = 2 = Confirmed).
     */
    public List<Order> getOrdersWaitingForDelivery() {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, a.fullname AS customer_name "
                   + "FROM Orders o "
                   + "JOIN Accounts a ON o.customer_id = a.id "
                   + "WHERE o.status = 2 " // 2 = Confirmed by seller
                   + "AND o.id NOT IN (SELECT order_id FROM DeliveryOrders) "
                   + "ORDER BY o.order_date ASC";
        
        try (PreparedStatement ps = getConnection().prepareStatement(sql);
              ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Order o = mapOrderRow(rs);
                o.setCustomerName(rs.getString("customer_name"));
                list.add(o);
            }
        } catch (SQLException e) {
            System.err.println("[DeliveryDAO] getOrdersWaitingForDelivery error: " + e.getMessage());
            throw new RuntimeException("DeliveryDAO.getOrdersWaitingForDelivery error: " + e.getMessage(), e);
        }
        return list;
    }
    
    /**
     * Get delivery history for a shipper.
     */
    public List<DeliveryOrder> getDeliveryHistory(int shipperId) {
        List<DeliveryOrder> list = new ArrayList<>();
        String sql = "SELECT d.order_id, d.shipper_id, d.status, d.note, "
                   + "s.fullname AS shipper_name, s.phone AS shipper_phone, "
                   + "o.status AS order_status, o.final_cost, "
                   + "o.recipient_name, o.recipient_phone, o.address AS delivery_address "
                   + "FROM DeliveryOrders d "
                   + "LEFT JOIN Accounts s ON d.shipper_id = s.id "
                   + "LEFT JOIN Orders o ON d.order_id = o.id "
                   + "WHERE d.shipper_id = ? AND d.status IN (?, ?) "
                   + "ORDER BY d.order_id DESC";
        
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shipperId);
            ps.setInt(2, DeliveryOrder.STATUS_DELIVERED);
            ps.setInt(3, DeliveryOrder.STATUS_FAILED);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapDeliveryRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[DeliveryDAO] getDeliveryHistory error: " + e.getMessage());
            throw new RuntimeException("DeliveryDAO.getDeliveryHistory error: " + e.getMessage(), e);
        }
        return list;
    }
    
    /**
     * Get pending deliveries for a shipper.
     */
    public List<DeliveryOrder> getPendingDeliveries(int shipperId) {
        List<DeliveryOrder> list = new ArrayList<>();
        String sql = "SELECT d.order_id, d.shipper_id, d.status, d.note, "
                   + "s.fullname AS shipper_name, s.phone AS shipper_phone, "
                   + "o.status AS order_status, o.final_cost, "
                   + "o.recipient_name, o.recipient_phone, o.address AS delivery_address "
                   + "FROM DeliveryOrders d "
                   + "LEFT JOIN Accounts s ON d.shipper_id = s.id "
                   + "LEFT JOIN Orders o ON d.order_id = o.id "
                   + "WHERE d.shipper_id = ? AND d.status NOT IN (?, ?) "
                   + "ORDER BY d.order_id ASC";
        
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, shipperId);
            ps.setInt(2, DeliveryOrder.STATUS_DELIVERED);
            ps.setInt(3, DeliveryOrder.STATUS_FAILED);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapDeliveryRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[DeliveryDAO] getPendingDeliveries error: " + e.getMessage());
            throw new RuntimeException("DeliveryDAO.getPendingDeliveries error: " + e.getMessage(), e);
        }
        return list;
    }
    
    // ==================== Order Tracking Methods ====================
    
    /**
     * Get tracking history for an order.
     */
    public List<OrderTracking> getTrackingByOrderId(int orderId) {
        List<OrderTracking> list = new ArrayList<>();
        String sql = "SELECT t.*, a.fullname AS updated_by_name "
                   + "FROM OrderTracking t "
                   + "LEFT JOIN Accounts a ON t.updated_by = a.id "
                   + "WHERE t.order_id = ? "
                   + "ORDER BY t.created_at ASC";
        
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderTracking tracking = new OrderTracking();
                    tracking.setTrackingId(rs.getInt("tracking_id"));
                    tracking.setOrderId(rs.getInt("order_id"));
                    int deliveryId = rs.getInt("delivery_id");
                    tracking.setDeliveryId(rs.wasNull() ? null : deliveryId);
                    tracking.setStatus(rs.getString("status"));
                    tracking.setDescription(rs.getString("description"));
                    tracking.setCreatedAt(rs.getTimestamp("created_at"));
                    int updatedBy = rs.getInt("updated_by");
                    tracking.setUpdatedBy(rs.wasNull() ? null : updatedBy);
                    tracking.setUpdatedByName(rs.getString("updated_by_name"));
                    list.add(tracking);
                }
            }
        } catch (SQLException e) {
            System.err.println("[DeliveryDAO] getTrackingByOrderId error: " + e.getMessage());
            throw new RuntimeException("DeliveryDAO.getTrackingByOrderId error: " + e.getMessage(), e);
        }
        return list;
    }
    
    /**
     * Add a tracking record.
     */
    public boolean addTracking(int orderId, Integer deliveryId, String status, String description, Integer updatedBy) {
        String sql = "INSERT INTO OrderTracking (order_id, delivery_id, status, description, updated_by) "
                   + "VALUES (?, ?, ?, ?, ?)";
        
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, orderId);
            if (deliveryId != null) {
                ps.setInt(2, deliveryId);
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, status);
            ps.setString(4, description);
            if (updatedBy != null) {
                ps.setInt(5, updatedBy);
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            int rows = ps.executeUpdate();
            System.out.println("[DeliveryDAO] addTracking success: orderId=" + orderId + ", status=" + status);
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("[DeliveryDAO] addTracking error: " + e.getMessage());
            throw new RuntimeException("DeliveryDAO.addTracking error: " + e.getMessage(), e);
        }
    }
    
    // ==================== Helper Methods ====================
    
    private DeliveryOrder mapDeliveryRow(ResultSet rs) throws SQLException {
        DeliveryOrder d = new DeliveryOrder();
        try {
            d.setDeliveryId(rs.getInt("id"));
        } catch (SQLException e) {
            try {
                d.setDeliveryId(rs.getInt("delivery_id"));
            } catch (SQLException ex) {
                d.setDeliveryId(rs.getInt("order_id"));
            }
        }
        d.setOrderId(rs.getInt("order_id"));
        int shipperId = rs.getInt("shipper_id");
        d.setShipperId(rs.wasNull() ? null : shipperId);
        
        try {
            int assignedBy = rs.getInt("assigned_by");
            d.setAssignedBy(rs.wasNull() ? 0 : assignedBy);
        } catch (SQLException e) {
            // Column doesn't exist in SELECT, skip
        }
        
        try {
            d.setAcceptedDate(rs.getTimestamp("accepted_date"));
        } catch (SQLException e) {
            // Column doesn't exist, skip
        }
        
        try {
            d.setPickupTime(rs.getTimestamp("pickup_time"));
        } catch (SQLException e) {
            // Column doesn't exist, skip
        }
        
        try {
            d.setDeliveryTime(rs.getTimestamp("delivery_time"));
        } catch (SQLException e) {
            // Column doesn't exist, skip
        }
        
        try {
            d.setStatus(rs.getInt("status"));
        } catch (SQLException e) {
            // default
        }
        
        try {
            d.setNote(rs.getString("note"));
        } catch (SQLException e) {
            // default
        }
        
        try {
            Timestamp ca = rs.getTimestamp("created_at");
            d.setCreatedAt(ca);
            d.setAssignedDate(ca);
        } catch (SQLException e) {
            try {
                Timestamp aa = rs.getTimestamp("assigned_at");
                d.setCreatedAt(aa);
                d.setAssignedDate(aa);
            } catch (SQLException ex) {
                // skip
            }
        }
        
        try {
            d.setUpdatedAt(rs.getTimestamp("updated_at"));
        } catch (SQLException e) {
            // Column doesn't exist, skip
        }
        
        // Joined fields
        try {
            d.setShipperName(rs.getString("shipper_name"));
            d.setShipperPhone(rs.getString("shipper_phone"));
        } catch (SQLException e) {
            // Column doesn't exist, skip
        }
        
        try {
            int orderStatus = rs.getInt("order_status");
            d.setOrderStatusLabel(getOrderStatusLabel(orderStatus));
            d.setOrderTotal(rs.getDouble("final_cost"));
            d.setRecipientName(rs.getString("recipient_name"));
            d.setRecipientPhone(rs.getString("recipient_phone"));
            d.setDeliveryAddress(rs.getString("delivery_address"));
        } catch (SQLException e) {
            // Order data might not be available
        }
        
        return d;
    }
    
    private Order mapOrderRow(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setId(rs.getInt("id"));
        o.setCustomerId(rs.getInt("customer_id"));
        int voucherId = rs.getInt("voucher_id");
        o.setVoucherId(rs.wasNull() ? null : voucherId);
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
    
    private String getOrderStatusLabel(int status) {
        switch (status) {
            case 1: return "Chờ xác nhận";
            case 2: return "Đã xác nhận";
            case 3: return "Đang giao hàng";
            case 4: return "Đã giao hàng";
            case 5: return "Đã hủy";
            default: return "Không xác định";
        }
    }
    
    private String getDefaultTrackingDescription(int status, int deliveryId) {
        switch (status) {
            case DeliveryOrder.STATUS_PICKING_UP:
                return "Shipper đang lấy hàng. Mã giao hàng: " + deliveryId;
            case DeliveryOrder.STATUS_DELIVERING:
                return "Shipper đang giao hàng. Mã giao hàng: " + deliveryId;
            case DeliveryOrder.STATUS_DELIVERED:
                return "Giao hàng thành công. Mã giao hàng: " + deliveryId;
            case DeliveryOrder.STATUS_FAILED:
                return "Giao hàng thất bại. Mã giao hàng: " + deliveryId;
            default:
                return "Cập nhật trạng thái giao hàng. Mã giao hàng: " + deliveryId;
        }
    }
    
    private void closeResources(Statement ps1, Statement ps2, Statement ps3, Connection conn) {
        try {
            if (ps1 != null) ps1.close();
            if (ps2 != null) ps2.close();
            if (ps3 != null) ps3.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        } catch (SQLException e) {
            System.err.println("[DeliveryDAO] closeResources error: " + e.getMessage());
        }
    }
    
    /**
     * Get deliveries assigned to shippers but not accepted after a timeout.
     */
    public List<DeliveryOrder> getStaleAssignedDeliveries(int timeoutMinutes) {
        List<DeliveryOrder> list = new ArrayList<>();
        String sql = "SELECT d.id, d.order_id, d.shipper_id, d.status, d.note, "
                   + "s.fullname AS shipper_name, s.phone AS shipper_phone, "
                   + "o.status AS order_status, o.final_cost, "
                   + "o.recipient_name, o.recipient_phone, o.address AS delivery_address "
                   + "FROM DeliveryOrders d "
                   + "LEFT JOIN Accounts s ON d.shipper_id = s.id "
                   + "LEFT JOIN Orders o ON d.order_id = o.id "
                   + "WHERE d.status = ?";

        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, DeliveryOrder.STATUS_ASSIGNED);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapDeliveryRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[DeliveryDAO] getStaleAssignedDeliveries error: " + e.getMessage());
        }
        return list;
    }

    /**
     * Reassign a delivery order to a different shipper.
     */
    public boolean reassignShipper(int deliveryId, int newShipperId, int staffId, String note) {
        String sqlUpdate = "UPDATE DeliveryOrders SET shipper_id = ?, note = ? WHERE id = ?";

        try (PreparedStatement ps = getConnection().prepareStatement(sqlUpdate)) {
            ps.setInt(1, newShipperId);
            ps.setString(2, note != null ? note : "");
            ps.setInt(3, deliveryId);
            int updated = ps.executeUpdate();
            return updated > 0;
        } catch (SQLException e) {
            System.err.println("[DeliveryDAO] reassignShipper error: " + e.getMessage());
            return false;
        }
    }

    /**
     * Get delivery completion notes written by Shipper when confirming delivery.
     */
    public Map<Integer, String> getDeliveryNotesForOrders(List<Integer> orderIds) {
        Map<Integer, String> map = new HashMap<>();
        if (orderIds == null || orderIds.isEmpty()) return map;

        StringBuilder sql = new StringBuilder(
            "SELECT order_id, description FROM OrderTracking WHERE order_id IN ("
        );
        for (int i = 0; i < orderIds.size(); i++) {
            if (i > 0) sql.append(",");
            sql.append("?");
        }
        sql.append(") AND description IS NOT NULL");

        try (PreparedStatement ps = getConnection().prepareStatement(sql.toString())) {
            for (int i = 0; i < orderIds.size(); i++) {
                ps.setInt(i + 1, orderIds.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getInt("order_id"), rs.getString("description"));
                }
            }
        } catch (SQLException e) {
            System.err.println("[DeliveryDAO] getDeliveryNotesForOrders error: " + e.getMessage());
        }
        return map;
    }
}
