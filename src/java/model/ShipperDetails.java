package model;

import java.sql.Date;

/**
 * ShipperDetails - Lưu thông tin đặc thù của shipper.
 * Tách riêng khỏi Account để dễ quản lý.
 */
public class ShipperDetails {
    private int id;
    private int accountId;
    private String shipperCode;  // Mã shipper (duy nhất)
    private Date birthdate;
    private String cccd;           // Căn cước công dân (12 số)
    private String vehicleType;     // Loại phương tiện
    private String deliveryArea;     // Khu vực giao hàng
    private Date createdAt;
    private Date updatedAt;

    public ShipperDetails() {
    }

    public ShipperDetails(int id, int accountId, String shipperCode, Date birthdate, String cccd, 
                          String vehicleType, String deliveryArea, Date createdAt, Date updatedAt) {
        this.id = id;
        this.accountId = accountId;
        this.shipperCode = shipperCode;
        this.birthdate = birthdate;
        this.cccd = cccd;
        this.vehicleType = vehicleType;
        this.deliveryArea = deliveryArea;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
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

    public String getShipperCode() {
        return shipperCode;
    }

    public void setShipperCode(String shipperCode) {
        this.shipperCode = shipperCode;
    }

    public Date getBirthdate() {
        return birthdate;
    }

    public void setBirthdate(Date birthdate) {
        this.birthdate = birthdate;
    }

    public String getCccd() {
        return cccd;
    }

    public void setCccd(String cccd) {
        this.cccd = cccd;
    }

    public String getVehicleType() {
        return vehicleType;
    }

    public void setVehicleType(String vehicleType) {
        this.vehicleType = vehicleType;
    }

    public String getDeliveryArea() {
        return deliveryArea;
    }

    public void setDeliveryArea(String deliveryArea) {
        this.deliveryArea = deliveryArea;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }

    /**
     * Tính tuổi từ ngày sinh.
     */
    public int getAge() {
        if (birthdate == null) return 0;
        long diffInMillis = System.currentTimeMillis() - birthdate.getTime();
        return (int) (diffInMillis / (1000L * 60 * 60 * 24 * 365));
    }
}
