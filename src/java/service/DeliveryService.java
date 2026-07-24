package service;

import dao.DeliveryDAO;
import dao.AccountDAO;
import model.DeliveryOrder;
import model.OrderTracking;
import model.Order;
import model.Account;
import java.util.List;

/**
 * DeliveryService - Business logic for delivery management.
 */
public class DeliveryService {
    
    // ==================== Order Waiting for Delivery ====================
    
    /**
     * Get orders that are confirmed and waiting for delivery assignment.
     */
    public List<Order> getOrdersWaitingForDelivery() {
        DeliveryDAO dao = new DeliveryDAO();
        try {
            return dao.getOrdersWaitingForDelivery();
        } finally {
            dao.close();
        }
    }
    
    // ==================== Shipper Assignment ====================
    
    /**
     * Assign a shipper to an order.
     */
    public String assignShipper(int orderId, int shipperId, int assignedBy, String note) {
        return assignShipperBatch(new int[]{orderId}, shipperId, assignedBy, note);
    }
    
    /**
     * Assign a shipper to multiple orders at once.
     */
    public String assignShipperBatch(int[] orderIds, int shipperId, int assignedBy, String note) {
        if (orderIds == null || orderIds.length == 0) {
            return "Vui lòng chọn ít nhất một đơn hàng.";
        }
        if (shipperId <= 0) {
            return "Vui lòng chọn shipper.";
        }
        
        // Verify shipper exists and is a shipper
        AccountDAO accountDao = new AccountDAO();
        try {
            Account shipper = accountDao.findByIdIncludeAll(shipperId);
            if (shipper == null) {
                return "Shipper không tồn tại.";
            }
            if (!"shipper".equalsIgnoreCase(shipper.getRoleName())) {
                return "Tài khoản không phải là shipper.";
            }
            if (shipper.getStatus() != 1) {
                return "Shipper đang bị khóa hoặc không hoạt động.";
            }
        } finally {
            accountDao.close();
        }
        
        // Assign shipper to each order
        DeliveryDAO dao = new DeliveryDAO();
        try {
            int successCount = 0;
            int failCount = 0;
            StringBuilder failedOrders = new StringBuilder();
            
            for (int orderId : orderIds) {
                // Check if already assigned
                DeliveryOrder existing = dao.getDeliveryByOrderId(orderId);
                if (existing != null) {
                    failCount++;
                    if (failedOrders.length() > 0) failedOrders.append(", ");
                    failedOrders.append("#").append(orderId);
                    continue;
                }
                
                boolean success = dao.assignShipper(orderId, shipperId, assignedBy, note);
                if (success) {
                    successCount++;
                } else {
                    failCount++;
                    if (failedOrders.length() > 0) failedOrders.append(", ");
                    failedOrders.append("#").append(orderId);
                }
            }
            
            System.out.println("[DeliveryService] Batch assign: " + successCount + " success, " + failCount + " failed");
            
            if (failCount > 0 && successCount == 0) {
                return "Không thể giao đơn hàng " + failedOrders + ". Có thể đã được giao trước đó.";
            }
            
            if (failCount > 0) {
                return "Đã giao " + successCount + " đơn. " + failCount + " đơn thất bại (" + failedOrders + ").";
            }
            
            return null; // Success
            
        } finally {
            dao.close();
        }
    }
    
    /**
     * Get available shippers for assignment.
     */
    public List<Account> getAvailableShippers() {
        AccountDAO dao = new AccountDAO();
        try {
            return dao.getAllShippers();
        } finally {
            dao.close();
        }
    }
    
    // ==================== Shipper Actions ====================
    
    /**
     * Accept delivery by shipper.
     */
    public String acceptDelivery(int deliveryId, int shipperId) {
        if (deliveryId <= 0) {
            return "ID giao hàng không hợp lệ.";
        }
        
        DeliveryDAO dao = new DeliveryDAO();
        try {
            DeliveryOrder delivery = dao.getDeliveryById(deliveryId);
            if (delivery == null) {
                return "Giao hàng không tồn tại.";
            }
            if (delivery.getShipperId() == null || delivery.getShipperId() != shipperId) {
                return "Bạn không phải là shipper được giao cho đơn hàng này.";
            }
            if (!delivery.canBeAccepted()) {
                return "Giao hàng không thể được chấp nhận (trạng thái: " + delivery.getStatusLabel() + ").";
            }
            
            boolean success = dao.acceptDelivery(deliveryId, shipperId);
            if (!success) {
                return "Chấp nhận giao hàng thất bại. Vui lòng thử lại.";
            }
            
            System.out.println("[DeliveryService] Delivery accepted: deliveryId=" + deliveryId);
            return null;
            
        } finally {
            dao.close();
        }
    }
    
    /**
     * Update delivery status.
     * Valid transitions: Accepted -> PickingUp -> Delivering -> Delivered/Failed
     */
    public String updateDeliveryStatus(int deliveryId, int shipperId, int newStatus, String note) {
        if (deliveryId <= 0) {
            return "ID giao hàng không hợp lệ.";
        }
        
        // Validate status
        String trackingStatus;
        switch (newStatus) {
            case DeliveryOrder.STATUS_PICKING_UP:
                trackingStatus = OrderTracking.Status.DELIVERY_PICKING_UP;
                break;
            case DeliveryOrder.STATUS_DELIVERING:
                trackingStatus = OrderTracking.Status.DELIVERY_DELIVERING;
                break;
            case DeliveryOrder.STATUS_DELIVERED:
                trackingStatus = OrderTracking.Status.DELIVERY_COMPLETED;
                break;
            case DeliveryOrder.STATUS_FAILED:
                trackingStatus = OrderTracking.Status.DELIVERY_FAILED;
                break;
            default:
                return "Trạng thái giao hàng không hợp lệ.";
        }
        
        DeliveryDAO dao = new DeliveryDAO();
        try {
            DeliveryOrder delivery = dao.getDeliveryById(deliveryId);
            if (delivery == null) {
                return "Giao hàng không tồn tại.";
            }
            if (delivery.getShipperId() == null || delivery.getShipperId() != shipperId) {
                return "Bạn không phải là shipper được giao cho đơn hàng này.";
            }
            
            // Validate status transition
            boolean validTransition = false;
            switch (delivery.getStatus()) {
                case DeliveryOrder.STATUS_ACCEPTED:
                    validTransition = (newStatus == DeliveryOrder.STATUS_PICKING_UP);
                    break;
                case DeliveryOrder.STATUS_PICKING_UP:
                    validTransition = (newStatus == DeliveryOrder.STATUS_DELIVERING);
                    break;
                case DeliveryOrder.STATUS_DELIVERING:
                    validTransition = (newStatus == DeliveryOrder.STATUS_DELIVERED || newStatus == DeliveryOrder.STATUS_FAILED);
                    break;
            }
            
            if (!validTransition) {
                return "Không thể chuyển từ trạng thái '" + delivery.getStatusLabel() 
                     + "' sang '" + delivery.getStatusLabel() + "'.";
            }
            
            boolean success = dao.updateStatus(deliveryId, shipperId, newStatus, note, trackingStatus);
            if (!success) {
                return "Cập nhật trạng thái thất bại. Vui lòng thử lại.";
            }
            
            System.out.println("[DeliveryService] Status updated: deliveryId=" + deliveryId + ", newStatus=" + newStatus);
            return null;
            
        } finally {
            dao.close();
        }
    }
    
    /**
     * Confirm delivery completion.
     */
    public String confirmDelivery(int deliveryId, int shipperId, String note) {
        return updateDeliveryStatus(deliveryId, shipperId, DeliveryOrder.STATUS_DELIVERED, note);
    }
    
    /**
     * Mark delivery as failed.
     */
    public String markDeliveryFailed(int deliveryId, int shipperId, String reason) {
        if (reason == null || reason.trim().isEmpty()) {
            return "Vui lòng cung cấp lý do giao hàng thất bại.";
        }
        return updateDeliveryStatus(deliveryId, shipperId, DeliveryOrder.STATUS_FAILED, reason);
    }
    
    // ==================== Query Methods ====================
    
    /**
     * Get delivery details by ID.
     */
    public DeliveryOrder getDeliveryById(int deliveryId) {
        DeliveryDAO dao = new DeliveryDAO();
        try {
            return dao.getDeliveryById(deliveryId);
        } finally {
            dao.close();
        }
    }
    
    /**
     * Get delivery by order ID.
     */
    public DeliveryOrder getDeliveryByOrderId(int orderId) {
        DeliveryDAO dao = new DeliveryDAO();
        try {
            return dao.getDeliveryByOrderId(orderId);
        } finally {
            dao.close();
        }
    }
    
    /**
     * Get all deliveries assigned to a shipper.
     */
    public List<DeliveryOrder> getShipperDeliveries(int shipperId) {
        DeliveryDAO dao = new DeliveryDAO();
        try {
            return dao.getDeliveriesByShipperId(shipperId);
        } finally {
            dao.close();
        }
    }
    
    /**
     * Get pending deliveries for a shipper.
     */
    public List<DeliveryOrder> getPendingDeliveries(int shipperId) {
        DeliveryDAO dao = new DeliveryDAO();
        try {
            return dao.getPendingDeliveries(shipperId);
        } finally {
            dao.close();
        }
    }
    
    /**
     * Get completed deliveries for a shipper (history).
     */
    public List<DeliveryOrder> getDeliveryHistory(int shipperId) {
        DeliveryDAO dao = new DeliveryDAO();
        try {
            return dao.getDeliveryHistory(shipperId);
        } finally {
            dao.close();
        }
    }
    
    /**
     * Get tracking history for an order.
     */
    public List<OrderTracking> getOrderTracking(int orderId) {
        DeliveryDAO dao = new DeliveryDAO();
        try {
            return dao.getTrackingByOrderId(orderId);
        } finally {
            dao.close();
        }
    }
    
    /**
     * Get all deliveries (for admin/staff).
     */
    public List<DeliveryOrder> getAllDeliveries() {
        DeliveryDAO dao = new DeliveryDAO();
        try {
            return dao.getAllDeliveries();
        } finally {
            dao.close();
        }
    }
    
    // ==================== Statistics ====================
    
    /**
     * Get delivery statistics for dashboard.
     */
    public int[] getDeliveryStats(int shipperId) {
        DeliveryDAO dao = new DeliveryDAO();
        try {
            List<DeliveryOrder> allDeliveries = dao.getDeliveriesByShipperId(shipperId);
            
            int pending = 0;
            int completed = 0;
            int failed = 0;
            
            for (DeliveryOrder d : allDeliveries) {
                if (d.getStatus() == DeliveryOrder.STATUS_DELIVERED) {
                    completed++;
                } else if (d.getStatus() == DeliveryOrder.STATUS_FAILED) {
                    failed++;
                } else {
                    pending++;
                }
            }
            
            return new int[]{pending, completed, failed};
        } finally {
            dao.close();
        }
    }

    public void close() {
        // No resources to close at service level
    }
}
