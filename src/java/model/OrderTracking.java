package model;

import java.sql.Timestamp;

/**
 * OrderTracking - Model for order tracking history.
 * Represents a status change event in an order's lifecycle.
 */
public class OrderTracking {
    
    // Status constants
    public static class Status {
        public static final String ORDER_PLACED = "ORDER_PLACED";
        public static final String ORDER_CONFIRMED = "ORDER_CONFIRMED";
        public static final String ORDER_CANCELLED = "ORDER_CANCELLED";
        public static final String DELIVERY_ASSIGNED = "DELIVERY_ASSIGNED";
        public static final String DELIVERY_ACCEPTED = "DELIVERY_ACCEPTED";
        public static final String DELIVERY_PICKING_UP = "DELIVERY_PICKING_UP";
        public static final String DELIVERY_DELIVERING = "DELIVERY_DELIVERING";
        public static final String DELIVERY_COMPLETED = "DELIVERY_COMPLETED";
        public static final String DELIVERY_FAILED = "DELIVERY_FAILED";
    }
    
    private int trackingId;
    private int orderId;
    private Integer deliveryId;
    private String status;
    private String description;
    private Timestamp createdAt;
    private Integer updatedBy;
    
    // Joined fields
    private String updatedByName;
    
    public OrderTracking() {
    }
    
    public OrderTracking(int trackingId, int orderId, Integer deliveryId, String status,
            String description, Timestamp createdAt, Integer updatedBy) {
        this.trackingId = trackingId;
        this.orderId = orderId;
        this.deliveryId = deliveryId;
        this.status = status;
        this.description = description;
        this.createdAt = createdAt;
        this.updatedBy = updatedBy;
    }
    
    // Getters and Setters
    public int getTrackingId() {
        return trackingId;
    }
    
    public void setTrackingId(int trackingId) {
        this.trackingId = trackingId;
    }
    
    public int getOrderId() {
        return orderId;
    }
    
    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }
    
    public Integer getDeliveryId() {
        return deliveryId;
    }
    
    public void setDeliveryId(Integer deliveryId) {
        this.deliveryId = deliveryId;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Integer getUpdatedBy() {
        return updatedBy;
    }
    
    public void setUpdatedBy(Integer updatedBy) {
        this.updatedBy = updatedBy;
    }
    
    public String getUpdatedByName() {
        return updatedByName;
    }
    
    public void setUpdatedByName(String updatedByName) {
        this.updatedByName = updatedByName;
    }
    
}
