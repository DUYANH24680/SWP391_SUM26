package service;

import dao.NotificationDAO;
import dao.OrderDAO;
import dao.AccountDAO;
import model.Notification;
import model.Order;
import model.Account;
import java.util.List;

/**
 * NotificationService - Business logic for creating and managing notifications.
 */
public class NotificationService {

    private NotificationDAO notifDao = new NotificationDAO();
    private OrderDAO orderDao = new OrderDAO();
    private AccountDAO accountDao = new AccountDAO();

    // ==================== CRUD ====================

    public int create(Notification notif) {
        return notifDao.insert(notif);
    }

    public List<Notification> getByUserId(int userId, int limit) {
        return notifDao.getByUserId(userId, limit);
    }

    public List<Notification> getAllByUserId(int userId) {
        return notifDao.getAllByUserId(userId);
    }

    public int getUnreadCount(int userId) {
        return notifDao.getUnreadCount(userId);
    }

    public boolean markAsRead(int id) {
        return notifDao.markAsRead(id);
    }

    public int markAllAsRead(int userId) {
        return notifDao.markAllAsRead(userId);
    }

    public boolean delete(int id) {
        return notifDao.delete(id);
    }

    public void cleanupOldNotifications(int days) {
        notifDao.deleteOld(days);
    }

    // ==================== Notification Creators ====================

    /**
     * Notify customer when their order status changes.
     */
    public void notifyOrderStatus(int orderId, int customerId, String statusText, String description) {
        Notification n = new Notification(
            customerId,
            "Cập nhật đơn hàng #" + orderId,
            "Đơn hàng #" + orderId + " đã được cập nhật: " + statusText + ". " + (description != null ? description : ""),
            Notification.TYPE_ORDER_STATUS,
            String.valueOf(orderId)
        );
        create(n);
    }

    /**
     * Notify seller when they receive a new order.
     */
    public void notifyNewOrder(int orderId, int sellerId) {
        try {
            Order order = orderDao.getOrderById(orderId);
            if (order == null) return;

            Notification n = new Notification(
                sellerId,
                "Đơn hàng mới #" + orderId,
                "Bạn có đơn hàng mới từ khách hàng " + order.getRecipientName() + " với tổng giá trị " + formatMoney(order.getFinalCost()),
                Notification.TYPE_NEW_ORDER,
                "/orders/" + orderId
            );
            create(n);
        } catch (Exception e) {
            System.err.println("[NotificationService] notifyNewOrder error: " + e.getMessage());
        }
    }

    /**
     * Notify customer when they successfully place an order.
     */
    public void notifyOrderPlaced(int customerId, java.util.List<Integer> orderIds) {
        try {
            String title;
            String content;
            String link;
            if (orderIds.size() == 1) {
                int orderId = orderIds.get(0);
                title = "Đặt hàng thành công! #" + orderId;
                content = "Đơn hàng #" + orderId + " của bạn đã được đặt thành công. Vui lòng chờ người bán xác nhận.";
                link = "/orders/" + orderId;
            } else {
                title = "Đặt hàng thành công!";
                content = "Bạn đã đặt " + orderIds.size() + " đơn hàng thành công. Vui lòng chờ người bán xác nhận từng đơn.";
                link = "/orders/" + orderIds.get(0);
            }
            Notification n = new Notification(customerId, title, content, Notification.TYPE_ORDER_STATUS, link);
            create(n);
        } catch (Exception e) {
            System.err.println("[NotificationService] notifyOrderPlaced error: " + e.getMessage());
        }
    }

    /**
     * Notify seller when a product is approved or rejected.
     */
    public void notifyProductApproval(int sellerId, String productTitle, boolean approved, String reason) {
        String title = approved ? "Sản phẩm được duyệt" : "Sản phẩm bị từ chối";
        String content = approved
            ? "Sản phẩm '" + productTitle + "' đã được duyệt và hiển thị trên cửa hàng."
            : "Sản phẩm '" + productTitle + "' đã bị từ chối. Lý do: " + (reason != null ? reason : "Không có");

        Notification n = new Notification(sellerId, title, content, Notification.TYPE_PRODUCT_APPROVAL, null);
        create(n);
    }

    /**
     * Notify shipper when assigned to deliver an order.
     */
    public void notifyDeliveryAssignment(int shipperId, int orderId, String orderAddress) {
        Notification n = new Notification(
            shipperId,
            "Bạn được giao đơn hàng #" + orderId,
            "Bạn có đơn hàng mới cần giao đến: " + orderAddress,
            Notification.TYPE_DELIVERY,
            String.valueOf(orderId)
        );
        create(n);
    }

    /**
     * Notify admin when a new seller registration request is submitted.
     */
    public void notifyNewSellerRequest(int adminId, String sellerName, String shopName) {
        Notification n = new Notification(
            adminId,
            "Yêu cầu đăng ký seller mới",
            sellerName + " đã gửi yêu cầu đăng ký cửa hàng '" + shopName + "'. Vui lòng kiểm tra và phê duyệt.",
            Notification.TYPE_SELLER_REQUEST,
            null
        );
        create(n);
    }

    /**
     * Notify seller when their seller request is approved.
     */
    public void notifySellerRequestApproved(int sellerId, String shopName) {
        Notification n = new Notification(
            sellerId,
            "Yêu cầu đăng ký được duyệt!",
            "Chúc mừng! Cửa hàng '" + shopName + "' của bạn đã được phê duyệt. Bạn có thể bắt đầu bán hàng ngay!",
            Notification.TYPE_SELLER_REQUEST,
            null
        );
        create(n);
    }

    /**
     * Notify seller when their seller request is rejected.
     */
    public void notifySellerRequestRejected(int sellerId, String shopName, String reason) {
        Notification n = new Notification(
            sellerId,
            "Yêu cầu đăng ký bị từ chối",
            "Yêu cầu đăng ký cửa hàng '" + shopName + "' đã bị từ chối. Lý do: " + (reason != null ? reason : "Không có"),
            Notification.TYPE_SELLER_REQUEST,
            null
        );
        create(n);
    }

    /**
     * Notify when order is delivered successfully.
     */
    public void notifyOrderDelivered(int customerId, int orderId) {
        Notification n = new Notification(
            customerId,
            "Đơn hàng #" + orderId + " đã giao thành công!",
            "Đơn hàng #" + orderId + " đã được giao thành công. Cảm ơn bạn đã mua sắm tại Sena Shop!",
            Notification.TYPE_ORDER_STATUS,
            String.valueOf(orderId)
        );
        create(n);
    }

    /**
     * Notify when order delivery fails.
     */
    public void notifyOrderDeliveryFailed(int customerId, int orderId, String reason) {
        Notification n = new Notification(
            customerId,
            "Giao hàng đơn #" + orderId + " không thành công",
            "Đơn hàng #" + orderId + " giao không thành công. Lý do: " + (reason != null ? reason : "Không rõ"),
            Notification.TYPE_ORDER_STATUS,
            String.valueOf(orderId)
        );
        create(n);
    }

    /**
     * Notify seller when voucher is about to expire.
     */
    public void notifyVoucherExpiry(int sellerId, String voucherCode, String expiryDate) {
        Notification n = new Notification(
            sellerId,
            "Voucher sắp hết hạn",
            "Voucher '" + voucherCode + "' sẽ hết hạn vào ngày " + expiryDate + ". Hãy gia hạn nếu cần.",
            Notification.TYPE_VOUCHER,
            null
        );
        create(n);
    }

    // ==================== Helpers ====================

    private String formatMoney(double amount) {
        java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi"));
        return nf.format(amount) + "đ";
    }

    /**
     * Notify all staff when a seller confirms an order — so staff can assign a shipper.
     */
    public void notifyStaffOrderConfirmed(int orderId, String shopName) {
        try {
            List<Account> staffList = accountDao.getAllStaff();
            if (staffList == null || staffList.isEmpty()) return;

            String title = "Đơn hàng #" + orderId + " cần phân công shipper";
            String content = "Shop \"" + shopName + "\" vừa xác nhận đơn hàng #" + orderId
                    + ". Vui lòng phân công shipper để giao hàng.";

            for (Account staff : staffList) {
                try {
                    Notification n = new Notification(
                        staff.getId(),
                        title,
                        content,
                        Notification.TYPE_STAFF_ASSIGN,
                        "/orders/" + orderId
                    );
                    create(n);
                } catch (Exception e) {
                    System.err.println("[NotificationService] notifyStaffOrderConfirmed for staff "
                            + staff.getId() + " error: " + e.getMessage());
                }
            }
        } catch (Exception e) {
            System.err.println("[NotificationService] notifyStaffOrderConfirmed error: " + e.getMessage());
        }
    }

    /**
     * Notify all customers when a seller creates a new voucher.
     * @param voucherCode  mã voucher vừa tạo
     * @param shopName     tên shop tạo voucher (null nếu là global voucher của admin)
     * @param discountInfo mô tả giảm giá (ví dụ "10% tối đa 50.000đ")
     */
    public void notifyNewVoucher(String voucherCode, String shopName, String discountInfo) {
        try {
            java.util.List<model.Account> customers = accountDao.getAccountsByRole("customer");
            if (customers == null || customers.isEmpty()) return;

            String title = "🎉 Voucher mới: " + voucherCode;
            String content;
            if (shopName != null && !shopName.trim().isEmpty()) {
                content = "Shop " + shopName + " vừa phát hành voucher [" + voucherCode + "] - " + discountInfo + ". Sử dụng ngay khi đặt hàng!";
            } else {
                content = "Sena Shop vừa phát hành voucher [" + voucherCode + "] - " + discountInfo + ". Sử dụng ngay khi đặt hàng!";
            }

            for (model.Account customer : customers) {
                try {
                    Notification n = new Notification(
                        customer.getId(),
                        title,
                        content,
                        Notification.TYPE_VOUCHER,
                        "/vouchers"
                    );
                    create(n);
                } catch (Exception e) {
                    System.err.println("[NotificationService] notifyNewVoucher for user " + customer.getId() + " error: " + e.getMessage());
                }
            }
        } catch (Exception e) {
            System.err.println("[NotificationService] notifyNewVoucher error: " + e.getMessage());
        }
    }

    public void close() {
        notifDao.close();
        orderDao.close();
        accountDao.close();
    }
}
