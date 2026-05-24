<<<<<<< HEAD
package model;

import java.sql.Timestamp;

public class Customer {
    private int id;
    private String fullname;
    private String username;
    private String passwordHash;
    private String email;
    private String phone;
    private String address;
    private Boolean gender;
    private String avatar;
    private int status;
    private boolean isDelete;
    private Timestamp createdAt;
=======
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Doan PC
 */
public class Customer {

    private int id;
    private String fullname;
    private String username;
    private String password;
    private String email;
    private int status;
>>>>>>> 851a23d5c8adece6c9421844a5b518864e74ff14

    public Customer() {
    }

<<<<<<< HEAD
    public Customer(int id, String fullname, String username, String passwordHash, String email, String phone, String address, Boolean gender, String avatar, int status, boolean isDelete, Timestamp createdAt) {
        this.id = id;
        this.fullname = fullname;
        this.username = username;
        this.passwordHash = passwordHash;
        this.email = email;
        this.phone = phone;
        this.address = address;
        this.gender = gender;
        this.avatar = avatar;
        this.status = status;
        this.isDelete = isDelete;
        this.createdAt = createdAt;
=======
    public Customer(int id, String fullname, String username, String password, String email, int status) {
        this.id = id;
        this.fullname = fullname;
        this.username = username;
        this.password = password;
        this.email = email;
        this.status = status;
>>>>>>> 851a23d5c8adece6c9421844a5b518864e74ff14
    }

    public int getId() {
        return id;
    }

<<<<<<< HEAD
    public void setId(int id) {
        this.id = id;
    }

=======
>>>>>>> 851a23d5c8adece6c9421844a5b518864e74ff14
    public String getFullname() {
        return fullname;
    }

<<<<<<< HEAD
    public void setFullname(String fullname) {
        this.fullname = fullname;
    }

=======
>>>>>>> 851a23d5c8adece6c9421844a5b518864e74ff14
    public String getUsername() {
        return username;
    }

<<<<<<< HEAD
    public void setUsername(String username) {
        this.username = username;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
=======
    public String getPassword() {
        return password;
>>>>>>> 851a23d5c8adece6c9421844a5b518864e74ff14
    }

    public String getEmail() {
        return email;
    }

<<<<<<< HEAD
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

    public Boolean getGender() {
        return gender;
    }

    public void setGender(Boolean gender) {
        this.gender = gender;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

=======
>>>>>>> 851a23d5c8adece6c9421844a5b518864e74ff14
    public int getStatus() {
        return status;
    }

<<<<<<< HEAD
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
=======
    public void setId(int id) {
        this.id = id;
    }

    public void setFullname(String fullname) {
        this.fullname = fullname;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setStatus(int status) {
        this.status = status;
    }
>>>>>>> 851a23d5c8adece6c9421844a5b518864e74ff14
}
