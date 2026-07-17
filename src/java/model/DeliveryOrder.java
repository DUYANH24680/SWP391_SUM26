package model;

import java.sql.Timestamp;

/**
 * DeliveryOrder - Model for delivery order tracking.
 * Represents a delivery assignment for an order.
 */
public class DeliveryOrder {
    
    // Status constants
    public static final int STATUS_ASSIGNED = 1;
    public static final int STATUS_ACCEPTED = 2;
    public static final int STATUS_PICKING_UP = 3;
    public static final int STATUS_DELIVERING = 4;
    public static final int STATUS_DELIVERED = 5;
    public static final int STATUS_FAILED = 6;
    
    private int deliveryId;
    private int orderId;
    private Integer shipperId;
    private int assignedBy;
    private Timestamp assignedDate;
    private Timestamp acceptedDate;
    private Timestamp pickupTime;
    private Timestamp deliveryTime;
    private int status;
    private String note;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Joined fields
    private String shipperName;
    private String shipperPhone;
    private String assignedByName;
    private String orderStatusLabel;
    private double orderTotal;
    private String recipientName;
    private String recipientPhone;
    private String deliveryAddress;
    
    public DeliveryOrder() {
    }
    
    public DeliveryOrder(int deliveryId, int orderId, Integer shipperId, int assignedBy,
            Timestamp assignedDate, Timestamp acceptedDate, Timestamp pickupTime,
            Timestamp deliveryTime, int status, String note) {
        this.deliveryId = deliveryId;
        this.orderId = orderId;
        this.shipperId = shipperId;
        this.assignedBy = assignedBy;
        this.assignedDate = assignedDate;
        this.acceptedDate = acceptedDate;
        this.pickupTime = pickupTime;
        this.deliveryTime = deliveryTime;
        this.status = status;
        this.note = note;
    }
    
    // Getters and Setters
    public int getDeliveryId() {
        return deliveryId;
    }
    
    public void setDeliveryId(int deliveryId) {
        this.deliveryId = deliveryId;
    }
    
    public int getOrderId() {
        return orderId;
    }
    
    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }
    
    public Integer getShipperId() {
        return shipperId;
    }
    
    public void setShipperId(Integer shipperId) {
        this.shipperId = shipperId;
    }
    
    public int getAssignedBy() {
        return assignedBy;
    }
    
    public void setAssignedBy(int assignedBy) {
        this.assignedBy = assignedBy;
    }
    
    public Timestamp getAssignedDate() {
        return assignedDate;
    }
    
    public void setAssignedDate(Timestamp assignedDate) {
        this.assignedDate = assignedDate;
    }
    
    public Timestamp getAcceptedDate() {
        return acceptedDate;
    }
    
    public void setAcceptedDate(Timestamp acceptedDate) {
        this.acceptedDate = acceptedDate;
    }
    
    public Timestamp getPickupTime() {
        return pickupTime;
    }
    
    public void setPickupTime(Timestamp pickupTime) {
        this.pickupTime = pickupTime;
    }
    
    public Timestamp getDeliveryTime() {
        return deliveryTime;
    }
    
    public void setDeliveryTime(Timestamp deliveryTime) {
        this.deliveryTime = deliveryTime;
    }
    
    public int getStatus() {
        return status;
    }
    
    public void setStatus(int status) {
        this.status = status;
    }
    
    public String getNote() {
        return note;
    }
    
    public void setNote(String note) {
        this.note = note;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public String getShipperName() {
        return shipperName;
    }
    
    public void setShipperName(String shipperName) {
        this.shipperName = shipperName;
    }
    
    public String getShipperPhone() {
        return shipperPhone;
    }
    
    public void setShipperPhone(String shipperPhone) {
        this.shipperPhone = shipperPhone;
    }
    
    public String getAssignedByName() {
        return assignedByName;
    }
    
    public void setAssignedByName(String assignedByName) {
        this.assignedByName = assignedByName;
    }
    
    public String getOrderStatusLabel() {
        return orderStatusLabel;
    }
    
    public void setOrderStatusLabel(String orderStatusLabel) {
        this.orderStatusLabel = orderStatusLabel;
    }
    
    public double getOrderTotal() {
        return orderTotal;
    }
    
    public void setOrderTotal(double orderTotal) {
        this.orderTotal = orderTotal;
    }
    
    public String getRecipientName() {
        return recipientName;
    }
    
    public void setRecipientName(String recipientName) {
        this.recipientName = recipientName;
    }
    
    public String getRecipientPhone() {
        return recipientPhone;
    }
    
    public void setRecipientPhone(String recipientPhone) {
        this.recipientPhone = recipientPhone;
    }
    
    public String getDeliveryAddress() {
        return deliveryAddress;
    }
    
    public void setDeliveryAddress(String deliveryAddress) {
        this.deliveryAddress = deliveryAddress;
    }
    
    // Status helper methods
    public String getStatusLabel() {
        switch (status) {
            case STATUS_ASSIGNED: return "Chờ nhận";
            case STATUS_ACCEPTED: return "Đã nhận";
            case STATUS_PICKING_UP: return "Đang lấy hàng";
            case STATUS_DELIVERING: return "Đang giao";
            case STATUS_DELIVERED: return "Đã giao";
            case STATUS_FAILED: return "Giao thất bại";
            default: return "Không xác định";
        }
    }
    
    public String getStatusClass() {
        switch (status) {
            case STATUS_ASSIGNED: return "badge-yellow";
            case STATUS_ACCEPTED: return "badge-blue";
            case STATUS_PICKING_UP: return "badge-orange";
            case STATUS_DELIVERING: return "badge-purple";
            case STATUS_DELIVERED: return "badge-green";
            case STATUS_FAILED: return "badge-red";
            default: return "badge-gray";
        }
    }
    
    public boolean isAvailableForAssignment() {
        return status == STATUS_ASSIGNED && shipperId == null;
    }
    
    public boolean canBeAccepted() {
        return status == STATUS_ASSIGNED;
    }
    
    public boolean canBePickedUp() {
        return status == STATUS_ACCEPTED;
    }
    
    public boolean canBeDelivered() {
        return status == STATUS_PICKING_UP || status == STATUS_DELIVERING;
    }
    
    public boolean canBeConfirmed() {
        return status == STATUS_DELIVERING;
    }
    
    public boolean isCompleted() {
        return status == STATUS_DELIVERED || status == STATUS_FAILED;
    }
}
