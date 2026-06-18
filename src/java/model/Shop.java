package model;

import java.sql.Timestamp;

public class Shop {
    private int id;
    private int ownerId;
    private String name;
    private String logo;
    private String banner;
    private String description;
    private String address;
    private String phone;
    private double rating;
    private int status;
    private Timestamp createdAt;

    public Shop() {
    }

    public Shop(int id, int ownerId, String name, String logo, String banner, String description,
            String address, String phone, double rating, int status, Timestamp createdAt) {
        this.id = id;
        this.ownerId = ownerId;
        this.name = name;
        this.logo = logo;
        this.banner = banner;
        this.description = description;
        this.address = address;
        this.phone = phone;
        this.rating = rating;
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

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getLogo() {
        return logo;
    }

    public void setLogo(String logo) {
        this.logo = logo;
    }

    public String getBanner() {
        return banner;
    }

    public void setBanner(String banner) {
        this.banner = banner;
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

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
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
}
