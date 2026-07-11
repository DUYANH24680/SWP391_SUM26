package model;

import java.sql.Timestamp;

public class Account {
    private int id;
    private int roleId;
    private String roleName;
    private String fullname;
    private String username;
    private String passwordHash;
    private String email;
    private String phone;
    private String address;
    private String avatar;
    private Boolean gender;
    private int status;
    private Timestamp createdAt;
    
        private java.util.Map<String, Object> extra;

    public Account() {
    }

    public Account(int id, int roleId, String roleName, String fullname, String username, String passwordHash, String email, String phone, String address, String avatar, Boolean gender, int status, Timestamp createdAt) {
        this.id = id;
        this.roleId = roleId;
        this.roleName = roleName;
        this.fullname = fullname;
        this.username = username;
        this.passwordHash = passwordHash;
        this.email = email;
        this.phone = phone;
        this.address = address;
        this.avatar = avatar;
        this.gender = gender;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
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

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
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

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public Boolean getGender() {
        return gender;
    }

    public void setGender(Boolean gender) {
        this.gender = gender;
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
    
        public java.util.Map<String, Object> getExtra() {
        if (extra == null) extra = new java.util.HashMap<>();
        return extra;
    }
        public void setExtra(String key, Object value) {
        getExtra().put(key, value);
    }
}
