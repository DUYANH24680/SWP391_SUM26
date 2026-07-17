package model;

import java.sql.Timestamp;

/**
 * OrderTracking - Model for order tracking history.
 * Represents a status change event in an order's lifecycle.
 */
public class OrderTracking {
    
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
    
    // Common status constants for easy reference
    public static class Status {
        public static final String PENDING = "pending";
        public static final String CONFIRMED = "confirmed";
        public static final String PREPARING = "preparing";
        public static final String SHIPPING = "shipping";
        public static final String DELIVERED = "delivered";
        public static final String CANCELLED = "cancelled";
        public static final String DELIVERY_ASSIGNED = "delivery_assigned";
        public static final String DELIVERY_ACCEPTED = "delivery_accepted";
        public static final String DELIVERY_PICKING_UP = "delivery_picking_up";
        public static final String DELIVERY_DELIVERING = "delivery_delivering";
        public static final String DELIVERY_COMPLETED = "delivery_completed";
        public static final String DELIVERY_FAILED = "delivery_failed";
    }
}
