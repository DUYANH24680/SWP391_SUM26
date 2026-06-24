package model;

import java.sql.Timestamp;

public class Order {
    private int id;
    private int customerId;
    private Integer voucherId; // Nullable
    private String recipientName;
    private String recipientPhone;
    private String address;
    private String paymentMethod;
    private int status; // 1=Pending, 2=Confirmed, 3=Shipping, 4=Delivered, 5=Canceled
    private int paymentStatus; // 0=Unpaid, 1=Paid, 2=Refunded
    private double totalCost;
    private double discountAmount;
    private double shippingFee;
    private double finalCost;
    private String note;
    private Timestamp orderDate;
    private Timestamp cancelledAt;

    // Additional fields for displaying info in views
    private String customerName;
    private String voucherCode;

    public Order() {
    }

    public Order(int id, int customerId, Integer voucherId, String recipientName, String recipientPhone,
                 String address, String paymentMethod, int status, int paymentStatus, double totalCost,
                 double discountAmount, double shippingFee, double finalCost, String note, Timestamp orderDate,
                 Timestamp cancelledAt) {
        this.id = id;
        this.customerId = customerId;
        this.voucherId = voucherId;
        this.recipientName = recipientName;
        this.recipientPhone = recipientPhone;
        this.address = address;
        this.paymentMethod = paymentMethod;
        this.status = status;
        this.paymentStatus = paymentStatus;
        this.totalCost = totalCost;
        this.discountAmount = discountAmount;
        this.shippingFee = shippingFee;
        this.finalCost = finalCost;
        this.note = note;
        this.orderDate = orderDate;
        this.cancelledAt = cancelledAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public Integer getVoucherId() {
        return voucherId;
    }

    public void setVoucherId(Integer voucherId) {
        this.voucherId = voucherId;
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

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public int getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(int paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public double getTotalCost() {
        return totalCost;
    }

    public void setTotalCost(double totalCost) {
        this.totalCost = totalCost;
    }

    public double getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(double discountAmount) {
        this.discountAmount = discountAmount;
    }

    public double getShippingFee() {
        return shippingFee;
    }

    public void setShippingFee(double shippingFee) {
        this.shippingFee = shippingFee;
    }

    public double getFinalCost() {
        return finalCost;
    }

    public void setFinalCost(double finalCost) {
        this.finalCost = finalCost;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public Timestamp getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Timestamp orderDate) {
        this.orderDate = orderDate;
    }

    public Timestamp getCancelledAt() {
        return cancelledAt;
    }

    public void setCancelledAt(Timestamp cancelledAt) {
        this.cancelledAt = cancelledAt;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getVoucherCode() {
        return voucherCode;
    }

    public void setVoucherCode(String voucherCode) {
        this.voucherCode = voucherCode;
    }

    // Helper status strings
    public String getStatusLabel() {
        switch (status) {
            case 1: return "Chờ xác nhận";
            case 2: return "Đã xác nhận";
            case 3: return "Đang giao hàng";
            case 4: return "Đã giao hàng";
            case 5: return "Đã hủy";
            default: return "Không xác định";
        }
    }

    public String getStatusClass() {
        switch (status) {
            case 1: return "badge-yellow";
            case 2: return "badge-blue";
            case 3: return "badge-yellow";
            case 4: return "badge-green";
            case 5: return "badge-red";
            default: return "badge-gray";
        }
    }

    public String getPaymentStatusLabel() {
        switch (paymentStatus) {
            case 0: return "Chưa thanh toán";
            case 1: return "Đã thanh toán";
            case 2: return "Đã hoàn tiền";
            default: return "Không xác định";
        }
    }
}

