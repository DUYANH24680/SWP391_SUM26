package model;

import java.sql.Timestamp;

public class Voucher {
    private int id;
    private String code;
    private double discountPercent;
    private double maxDiscount;
    private double minimumOrder;
    private Timestamp startDate;
    private Timestamp endDate;
    private int quantity;
    private int usedCount;
    private boolean status;

    public Voucher() {
    }

    public Voucher(int id, String code, double discountPercent, double maxDiscount, double minimumOrder,
                   Timestamp startDate, Timestamp endDate, int quantity, int usedCount, boolean status) {
        this.id = id;
        this.code = code;
        this.discountPercent = discountPercent;
        this.maxDiscount = maxDiscount;
        this.minimumOrder = minimumOrder;
        this.startDate = startDate;
        this.endDate = endDate;
        this.quantity = quantity;
        this.usedCount = usedCount;
        this.status = status;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public double getDiscountPercent() {
        return discountPercent;
    }

    public void setDiscountPercent(double discountPercent) {
        this.discountPercent = discountPercent;
    }

    public double getMaxDiscount() {
        return maxDiscount;
    }

    public void setMaxDiscount(double maxDiscount) {
        this.maxDiscount = maxDiscount;
    }

    public double getMinimumOrder() {
        return minimumOrder;
    }

    public void setMinimumOrder(double minimumOrder) {
        this.minimumOrder = minimumOrder;
    }

    public Timestamp getStartDate() {
        return startDate;
    }

    public void setStartDate(Timestamp startDate) {
        this.startDate = startDate;
    }

    public Timestamp getEndDate() {
        return endDate;
    }

    public void setEndDate(Timestamp endDate) {
        this.endDate = endDate;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public int getUsedCount() {
        return usedCount;
    }

    public void setUsedCount(int usedCount) {
        this.usedCount = usedCount;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }

    public boolean isActive() {
        return status;
    }

    public boolean isExpired() {
        Timestamp now = new Timestamp(System.currentTimeMillis());
        return endDate != null && now.after(endDate);
    }

    public boolean hasAvailableUsage() {
        return usedCount < quantity;
    }

    /**
     * Check if the voucher is valid currently and for the given order total.
     */
    public boolean isValid(double orderTotal) {
        if (!status) return false;
        Timestamp now = new Timestamp(System.currentTimeMillis());
        if (startDate != null && now.before(startDate)) return false;
        if (endDate != null && now.after(endDate)) return false;
        if (usedCount >= quantity) return false;
        if (orderTotal < minimumOrder) return false;
        return true;
    }

    /**
     * Calculate discount amount for a given order total.
     */
    public double calculateDiscount(double orderTotal) {
        if (!isValid(orderTotal)) return 0.0;
        double discount = orderTotal * (discountPercent / 100.0);
        if (maxDiscount > 0 && discount > maxDiscount) {
            discount = maxDiscount;
        }
        return discount;
    }
}

