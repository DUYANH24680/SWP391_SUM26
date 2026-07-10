package model;

import java.sql.Timestamp;

public class UserReport {
    private int id;
    private int reporterId;
    private int reportedShopId;
    private Integer orderId;
    private String reportType;
    private String description;
    private String evidenceUrl;
    private int status;       // 0=Pending | 1=Reviewed | 2=Resolved | 3=Dismissed
    private int priority;     // 1=Low | 2=Medium | 3=High | 4=Critical
    private String adminNote;
    private Integer resolvedBy;
    private Timestamp resolvedAt;
    private Timestamp createdAt;

    // Joined fields
    private String reporterFullname;
    private String reporterEmail;
    private String shopName;
    private String shopOwnerName;
    private String resolvedByName;

    public UserReport() {}

    // Status helpers
    public String getStatusLabel() {
        switch (status) {
            case 0: return "Chờ xử lý";
            case 1: return "Đã xem";
            case 2: return "Đã giải quyết";
            case 3: return "Bỏ qua";
            default: return "Không xác định";
        }
    }

    public String getStatusCssClass() {
        switch (status) {
            case 0: return "status-pending";
            case 1: return "status-reviewed";
            case 2: return "status-resolved";
            case 3: return "status-dismissed";
            default: return "";
        }
    }

    public String getPriorityLabel() {
        switch (priority) {
            case 1: return "Thấp";
            case 2: return "Trung bình";
            case 3: return "Cao";
            case 4: return "Nghiêm trọng";
            default: return "Trung bình";
        }
    }

    public String getPriorityCssClass() {
        switch (priority) {
            case 1: return "priority-low";
            case 2: return "priority-medium";
            case 3: return "priority-high";
            case 4: return "priority-critical";
            default: return "priority-medium";
        }
    }

    public String getReportTypeLabel() {
        switch (reportType) {
            case "Scam":          return "Lừa đảo";
            case "FakeProduct":   return "Sản phẩm giả";
            case "Harassment":   return "Quấy rối";
            case "LateDelivery": return "Giao trễ";
            case "BadReview":    return "Spam đánh giá";
            case "Other":        return "Khác";
            default:             return reportType != null ? reportType : "Khác";
        }
    }

    public boolean isPending()  { return status == 0; }
    public boolean isResolved() { return status == 2; }

    // ---- Getters & Setters ----
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getReporterId() { return reporterId; }
    public void setReporterId(int reporterId) { this.reporterId = reporterId; }

    public int getReportedShopId() { return reportedShopId; }
    public void setReportedShopId(int reportedShopId) { this.reportedShopId = reportedShopId; }

    public Integer getOrderId() { return orderId; }
    public void setOrderId(Integer orderId) { this.orderId = orderId; }

    public String getReportType() { return reportType; }
    public void setReportType(String reportType) { this.reportType = reportType; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getEvidenceUrl() { return evidenceUrl; }
    public void setEvidenceUrl(String evidenceUrl) { this.evidenceUrl = evidenceUrl; }

    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }

    public int getPriority() { return priority; }
    public void setPriority(int priority) { this.priority = priority; }

    public String getAdminNote() { return adminNote; }
    public void setAdminNote(String adminNote) { this.adminNote = adminNote; }

    public Integer getResolvedBy() { return resolvedBy; }
    public void setResolvedBy(Integer resolvedBy) { this.resolvedBy = resolvedBy; }

    public Timestamp getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(Timestamp resolvedAt) { this.resolvedAt = resolvedAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getReporterFullname() { return reporterFullname; }
    public void setReporterFullname(String reporterFullname) { this.reporterFullname = reporterFullname; }

    public String getReporterEmail() { return reporterEmail; }
    public void setReporterEmail(String reporterEmail) { this.reporterEmail = reporterEmail; }

    public String getShopName() { return shopName; }
    public void setShopName(String shopName) { this.shopName = shopName; }

    public String getShopOwnerName() { return shopOwnerName; }
    public void setShopOwnerName(String shopOwnerName) { this.shopOwnerName = shopOwnerName; }

    public String getResolvedByName() { return resolvedByName; }
    public void setResolvedByName(String resolvedByName) { this.resolvedByName = resolvedByName; }
}
