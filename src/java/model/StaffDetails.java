package model;

import java.sql.Date;

/**
 * StaffDetails - Lưu thông tin đặc thù của nhân viên.
 * Tách riêng khỏi Account để dễ quản lý.
 */
public class StaffDetails {
    private int id;
    private int accountId;
    private String staffCode;        // Mã nhân viên (duy nhất)
    private String cccd;             // Căn cước công dân (12 số)
    private String managedArea;       // Khu vực quản lý shipper
    private Date createdAt;
    private Date updatedAt;

    public StaffDetails() {
    }

    public StaffDetails(int id, int accountId, String staffCode, String cccd, 
                        String managedArea, Date createdAt, Date updatedAt) {
        this.id = id;
        this.accountId = accountId;
        this.staffCode = staffCode;
        this.cccd = cccd;
        this.managedArea = managedArea;
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

    public String getStaffCode() {
        return staffCode;
    }

    public void setStaffCode(String staffCode) {
        this.staffCode = staffCode;
    }

    public String getCccd() {
        return cccd;
    }

    public void setCccd(String cccd) {
        this.cccd = cccd;
    }

    public String getManagedArea() {
        return managedArea;
    }

    public void setManagedArea(String managedArea) {
        this.managedArea = managedArea;
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
}
