package model;

import java.sql.Timestamp;

// DuyAnhNgo- Class Model: Đại diện cho 1 dòng dữ liệu trong bảng DeliveryAddresses của cơ sở dữ liệu
// Các thuộc tính trong này tương ứng với các cột: Tên, SĐT, Địa chỉ, Ghi chú, isDefault,...
public class DeliveryAddress {
    private int id;
    private int customerId;
    private String recipientName;
    private String recipientPhone;
    private String address;
    private String note;
    private boolean isDefault;
    private Timestamp createdAt;

    public DeliveryAddress() {
    }

    public DeliveryAddress(int id, int customerId, String recipientName, String recipientPhone, String address, String note, boolean isDefault, Timestamp createdAt) {
        this.id = id;
        this.customerId = customerId;
        this.recipientName = recipientName;
        this.recipientPhone = recipientPhone;
        this.address = address;
        this.note = note;
        this.isDefault = isDefault;
        this.createdAt = createdAt;
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

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public boolean isIsDefault() {
        return isDefault;
    }

    public void setIsDefault(boolean isDefault) {
        this.isDefault = isDefault;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}

