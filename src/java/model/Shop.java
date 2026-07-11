package model;

import java.sql.Timestamp;

public class Shop {
    private int id;
    private int ownerId;
    private String shopName;
    private String logo;
    private String description;
    private String address;
    private int status;  // 0=Blocked | 1=Approved | 2=Rejected | 3=Blocked
    private Timestamp createdAt;
    
        // Joined owner info
    private String ownerFullname;
    private String ownerEmail;
    private String ownerPhone;
    private int ownerAccountStatus;


    public Shop() {
    }

    public Shop(int id, int ownerId, String shopName, String logo, String description,
            String address, int status, Timestamp createdAt) {
        this.id = id;
        this.ownerId = ownerId;
        this.shopName = shopName;
        this.logo = logo;
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

    public int getOwnerId() {
        return ownerId;
    }

    public void setOwnerId(int ownerId) {
        this.ownerId = ownerId;
    }

    public String getShopName() {
        return shopName;
    }

    public void setShopName(String shopName) {
        this.shopName = shopName;
    }

    public String getLogo() {
        return logo;
    }

    public void setLogo(String logo) {
        this.logo = logo;
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

    public boolean isApproved() {
        return status == 1;
    }

    public boolean isBlocked() { return status == 3; }

    public String getStatusLabel() {
        switch (status) {
            case 0: return "Chờ duyệt";
            case 1: return "Hoạt động";
            case 2: return "Từ chối";
            case 3: return "Bị khóa";
            default: return "Không xác định";
        }
    }

    public boolean isActive() { return status == 1; }

    // ---- Owner info ----
    public String getOwnerFullname() {
        return ownerFullname;
    }

    public void setOwnerFullname(String ownerFullname) {
        this.ownerFullname = ownerFullname;
    }

    public String getOwnerEmail() {
        return ownerEmail;
    }

    public void setOwnerEmail(String ownerEmail) {
        this.ownerEmail = ownerEmail;
    }

    public String getOwnerPhone() {
        return ownerPhone;
    }

    public void setOwnerPhone(String ownerPhone) {
        this.ownerPhone = ownerPhone;
    }

    public int getOwnerAccountStatus() {
        return ownerAccountStatus;
    }

    public void setOwnerAccountStatus(int ownerAccountStatus) {
        this.ownerAccountStatus = ownerAccountStatus;
    }

    public void setExtra(String productCount, int countProductsByShopId) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}
