package model;

import java.sql.Timestamp;

public class Staff {
    private int id;
    private String email;
    private String fullname;
    private String username;
    private String passwordHash;
    private boolean gender;
    private String phone;
    private String address;
    private int roleId;
    private int sellerStatus;
    private int status;
    private boolean isDelete;
    private Timestamp createdAt;

    public Staff() {
    }

    public Staff(int id, String email, String fullname, String username, String passwordHash, boolean gender, String phone, String address, int roleId, int sellerStatus, int status, boolean isDelete, Timestamp createdAt) {
        this.id = id;
        this.email = email;
        this.fullname = fullname;
        this.username = username;
        this.passwordHash = passwordHash;
        this.gender = gender;
        this.phone = phone;
        this.address = address;
        this.roleId = roleId;
        this.sellerStatus = sellerStatus;
        this.status = status;
        this.isDelete = isDelete;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getFullname() {
        return fullname;
    }

    public void setFullname(String fullname) {
        this.fullname = fullname;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public boolean isGender() {
        return gender;
    }

    public void setGender(boolean gender) {
        this.gender = gender;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public int getSellerStatus() {
        return sellerStatus;
    }

    public void setSellerStatus(int sellerStatus) {
        this.sellerStatus = sellerStatus;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public boolean isIsDelete() {
        return isDelete;
    }

    public void setIsDelete(boolean isDelete) {
        this.isDelete = isDelete;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
