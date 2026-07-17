package model;

import java.sql.Timestamp;

public class Voucher {
    private int id;
    private Integer shopId; // null = Admin global voucher
    private String code;
    private String type; // 'DISCOUNT' or 'FREESHIP'
    private double discountPercent; // also used for FREESHIP max value or just 100%
    private double maxDiscount;
    private double minimumOrder;
    private Timestamp startDate;
    private Timestamp endDate;
    private int quantity;
    private int usedCount;
    private int maxUsagesPerUser; // max times a single user can use this
    private boolean status;

    public Voucher() {
        this.type = "DISCOUNT";
        this.maxUsagesPerUser = 3;
    }

    public Voucher(int id, Integer shopId, String code, String type, double discountPercent, double maxDiscount, double minimumOrder,
                   Timestamp startDate, Timestamp endDate, int quantity, int usedCount, int maxUsagesPerUser, boolean status) {
        this.id = id;
        this.shopId = shopId;
        this.code = code;
        this.type = type != null ? type : "DISCOUNT";
        this.discountPercent = discountPercent;
        this.maxDiscount = maxDiscount;
        this.minimumOrder = minimumOrder;
        this.startDate = startDate;
        this.endDate = endDate;
        this.quantity = quantity;
        this.usedCount = usedCount;
        this.maxUsagesPerUser = maxUsagesPerUser;
        this.status = status;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Integer getShopId() { return shopId; }
    public void setShopId(Integer shopId) { this.shopId = shopId; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public double getDiscountPercent() { return discountPercent; }
    public void setDiscountPercent(double discountPercent) { this.discountPercent = discountPercent; }

    public double getMaxDiscount() { return maxDiscount; }
    public void setMaxDiscount(double maxDiscount) { this.maxDiscount = maxDiscount; }

    public double getMinimumOrder() { return minimumOrder; }
    public void setMinimumOrder(double minimumOrder) { this.minimumOrder = minimumOrder; }

    public Timestamp getStartDate() { return startDate; }
    public void setStartDate(Timestamp startDate) { this.startDate = startDate; }

    public Timestamp getEndDate() { return endDate; }
    public void setEndDate(Timestamp endDate) { this.endDate = endDate; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public int getUsedCount() { return usedCount; }
    public void setUsedCount(int usedCount) { this.usedCount = usedCount; }

    public int getMaxUsagesPerUser() { return maxUsagesPerUser; }
    public void setMaxUsagesPerUser(int maxUsagesPerUser) { this.maxUsagesPerUser = maxUsagesPerUser; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }

    public boolean isActive() { return status; }

    public boolean isExpired() {
        Timestamp now = new Timestamp(System.currentTimeMillis());
        return endDate != null && now.after(endDate);
    }

    public boolean hasAvailableUsage() {
        return usedCount < quantity;
    }

    public boolean isValid(double orderTotal) {
        if (!status) return false;
        Timestamp now = new Timestamp(System.currentTimeMillis());
        if (startDate != null && now.before(startDate)) return false;
        if (endDate != null && now.after(endDate)) return false;
        if (usedCount >= quantity) return false;
        if (orderTotal < minimumOrder) return false;
        return true;
    }

    public boolean isValidForCart(double orderTotal) {
        if (!status) return false;
        Timestamp now = new Timestamp(System.currentTimeMillis());
        if (startDate != null && now.before(startDate)) return false;
        if (endDate != null && now.after(endDate)) return false;
        if (orderTotal < minimumOrder) return false;
        return true;
    }

    public double calculateDiscount(double orderTotal) {
        if (!isValid(orderTotal)) return 0.0;
        double discount = orderTotal * (discountPercent / 100.0);
        if (maxDiscount > 0 && discount > maxDiscount) {
            discount = maxDiscount;
        }
        return discount;
    }

    public double calculateCartDiscount(double orderTotal) {
        if (!isValidForCart(orderTotal)) return 0.0;
        double discount = orderTotal * (discountPercent / 100.0);
        if (maxDiscount > 0 && discount > maxDiscount) {
            discount = maxDiscount;
        }
        return discount;
    }
}
