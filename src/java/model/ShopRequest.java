package model;

import java.sql.Timestamp;

public class ShopRequest {
    private int id;
    private int accountId;
    private String shopName;
    private String description;
    private String address;
    private int status;       // 0 = Pending, 1 = Approved, 2 = Rejected
    private Timestamp createdAt;

    // Extra: joined data from Accounts
    private String accountFullname;
    private String accountEmail;
    private String accountPhone;

    public ShopRequest() {
    }

    public ShopRequest(int id, int accountId, String shopName, String description,
            String address, int status, Timestamp createdAt) {
        this.id = id;
        this.accountId = accountId;
        this.shopName = shopName;
        this.description = description;
        this.address = address;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public String getShopName() {
        return shopName;
    }

    public void setShopName(String shopName) {
        this.shopName = shopName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getAccountFullname() {
        return accountFullname;
    }

    public void setAccountFullname(String accountFullname) {
        this.accountFullname = accountFullname;
    }

    public String getAccountEmail() {
        return accountEmail;
    }

    public void setAccountEmail(String accountEmail) {
        this.accountEmail = accountEmail;
    }

    public String getAccountPhone() {
        return accountPhone;
    }

    public void setAccountPhone(String accountPhone) {
        this.accountPhone = accountPhone;
    }

    public boolean isPending()  { return status == 0; }
    public boolean isApproved() { return status == 1; }
    public boolean isRejected() { return status == 2; }

    public String getStatusLabel() {
        switch (status) {
            case 0: return "Chờ duyệt";
            case 1: return "Đã duyệt";
            case 2: return "Từ chối";
            default: return "Không xác định";
        }
    }
}
