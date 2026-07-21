package model;

import java.io.Serializable;
import java.util.Date;

/**
 * Notification model for user notifications.
 */
public class Notification implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final String TYPE_ORDER_STATUS = "order_status";
    public static final String TYPE_NEW_ORDER = "new_order";
    public static final String TYPE_DELIVERY = "delivery";
    public static final String TYPE_PRODUCT_APPROVAL = "product_approval";
    public static final String TYPE_SELLER_REQUEST = "seller_request";
    public static final String TYPE_VOUCHER = "voucher";
    public static final String TYPE_CHAT = "chat";
    public static final String TYPE_SYSTEM = "system";
    public static final String TYPE_STAFF_ASSIGN = "staff_assign"; // staff: cần phân công shipper

    private int id;
    private int userId;
    private String title;
    private String content; // DB: message
    private String type;
    private String link; // DB: link column - stores related entity ID as string
    private boolean isRead;
    private Date createdAt;

    public Notification() {}

    public Notification(int userId, String title, String content, String type) {
        this.userId = userId;
        this.title = title;
        this.content = content;
        this.type = type;
        this.isRead = false;
        this.createdAt = new Date();
    }

    public Notification(int userId, String title, String content, String type, String link) {
        this.userId = userId;
        this.title = title;
        this.content = content;
        this.type = type;
        this.link = link;
        this.isRead = false;
        this.createdAt = new Date();
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getLink() { return link; }
    public void setLink(String link) { this.link = link; }

    public boolean isRead() { return isRead; }
    public void setRead(boolean read) { this.isRead = read; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public String getTypeIcon() {
        switch (type) {
            case TYPE_ORDER_STATUS: return "fa-receipt";
            case TYPE_NEW_ORDER: return "fa-shopping-cart";
            case TYPE_DELIVERY: return "fa-motorcycle";
            case TYPE_PRODUCT_APPROVAL: return "fa-check-circle";
            case TYPE_SELLER_REQUEST: return "fa-store";
            case TYPE_VOUCHER: return "fa-ticket";
            case TYPE_CHAT: return "fa-comments";
            default: return "fa-bell";
        }
    }

    public String getTypeColor() {
        switch (type) {
            case TYPE_ORDER_STATUS: return "#f59e0b";
            case TYPE_NEW_ORDER: return "#10b981";
            case TYPE_DELIVERY: return "#3b82f6";
            case TYPE_PRODUCT_APPROVAL: return "#8b5cf6";
            case TYPE_SELLER_REQUEST: return "#ec4899";
            case TYPE_VOUCHER: return "#f97316";
            default: return "#6b7280";
        }
    }

    public String getTimeAgo() {
        if (createdAt == null) return "";

        long diff = System.currentTimeMillis() - createdAt.getTime();
        long seconds = diff / 1000;
        long minutes = seconds / 60;
        long hours = minutes / 60;
        long days = hours / 24;

        if (days > 0) return days + " ngày trước";
        if (hours > 0) return hours + " giờ trước";
        if (minutes > 0) return minutes + " phút trước";
        return "Vừa xong";
    }

    /**
     * Returns the navigation URL based on notification type.
     * Use this instead of getLink() for actual page navigation.
     */
    public String getLinkUrl() {
        if (link == null || link.trim().isEmpty()) return "#";

        switch (type) {
            case TYPE_ORDER_STATUS:
            case TYPE_NEW_ORDER:
            case TYPE_DELIVERY:
                return "/my-orders";
            case TYPE_PRODUCT_APPROVAL:
                return "/seller/products";
            case TYPE_SELLER_REQUEST:
                return "/admin/seller-requests";
            default:
                return "#";
        }
    }

    @Override
    public String toString() {
        return "Notification{" +
                "id=" + id +
                ", userId=" + userId +
                ", title='" + title + '\'' +
                ", type='" + type + '\'' +
                ", isRead=" + isRead +
                ", createdAt=" + createdAt +
                '}';
    }
}
