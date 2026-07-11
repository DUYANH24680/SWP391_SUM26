package model;

import java.sql.Timestamp;

public class SellerAction {
    private int id;
    private int shopId;
    private int sellerId;
    private String actionType;
    private String reason;
    private String note;
    private int performedBy;
    private Timestamp suspendUntil;
    private Timestamp createdAt;

    // Joined fields
    private String shopName;
    private String sellerFullname;
    private String adminFullname;

    public SellerAction() {}

    public String getActionTypeLabel() {
        switch (actionType) {
            case "warn":               return "Cảnh cáo";
            case "temp_suspend":       return "Khóa tạm";
            case "temp_suspend_end":  return "Hết hạn khóa tạm";
            case "block":              return "Khóa vĩnh viễn";
            case "unblock":            return "Mở khóa";
            default:                   return actionType;
        }
    }

    public String getActionCssClass() {
        switch (actionType) {
            case "warn":              return "action-warn";
            case "temp_suspend":      return "action-suspend";
            case "temp_suspend_end":  return "action-suspend-end";
            case "block":             return "action-block";
            case "unblock":            return "action-unblock";
            default:                  return "";
        }
    }

    public boolean isActiveSuspension() {
        return "temp_suspend".equals(actionType)
            && suspendUntil != null
            && suspendUntil.after(new Timestamp(System.currentTimeMillis()));
    }

    // ---- Getters & Setters ----
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getShopId() { return shopId; }
    public void setShopId(int shopId) { this.shopId = shopId; }

    public int getSellerId() { return sellerId; }
    public void setSellerId(int sellerId) { this.sellerId = sellerId; }

    public String getActionType() { return actionType; }
    public void setActionType(String actionType) { this.actionType = actionType; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public int getPerformedBy() { return performedBy; }
    public void setPerformedBy(int performedBy) { this.performedBy = performedBy; }

    public Timestamp getSuspendUntil() { return suspendUntil; }
    public void setSuspendUntil(Timestamp suspendUntil) { this.suspendUntil = suspendUntil; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getShopName() { return shopName; }
    public void setShopName(String shopName) { this.shopName = shopName; }

    public String getSellerFullname() { return sellerFullname; }
    public void setSellerFullname(String sellerFullname) { this.sellerFullname = sellerFullname; }

    public String getAdminFullname() { return adminFullname; }
    public void setAdminFullname(String adminFullname) { this.adminFullname = adminFullname; }
}
