package model;

import java.sql.Timestamp;

public class Product {
    private int id;
    private int categoryId;
    private int sellerId;
    private int shopId;
    private String shopName;
    private String title;
    private String image;
    private String description;
    private String unit;
    private int stockQuantity;
    private int soldQuantity;
    private double originalPrice;
    private double salePrice;
    private Timestamp expiredDate;
    private double averageRating;
    private boolean isFeatured;
    private int status;
    private boolean isDelete;
    private Timestamp createdAt;

    public Product() {
    }

    public Product(int id, int categoryId, int sellerId, int shopId, String title, String image, String description,
            String unit, int stockQuantity, int soldQuantity, double originalPrice, double salePrice,
            Timestamp expiredDate, double averageRating, boolean isFeatured, int status,
            boolean isDelete, Timestamp createdAt) {
        this.id = id;
        this.categoryId = categoryId;
        this.sellerId = sellerId;
        this.shopId = shopId;
        this.title = title;
        this.image = image;
        this.description = description;
        this.unit = unit;
        this.stockQuantity = stockQuantity;
        this.soldQuantity = soldQuantity;
        this.originalPrice = originalPrice;
        this.salePrice = salePrice;
        this.expiredDate = expiredDate;
        this.averageRating = averageRating;
        this.isFeatured = isFeatured;
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

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public int getSellerId() {
        return sellerId;
    }

    public void setSellerId(int sellerId) {
        this.sellerId = sellerId;
    }

    public int getShopId() {
        return shopId;
    }

    public void setShopId(int shopId) {
        this.shopId = shopId;
    }

    public String getShopName() {
        return shopName;
    }

    public void setShopName(String shopName) {
        this.shopName = shopName;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }

    public int getSoldQuantity() {
        return soldQuantity;
    }

    public void setSoldQuantity(int soldQuantity) {
        this.soldQuantity = soldQuantity;
    }

    public double getOriginalPrice() {
        return originalPrice;
    }

    public void setOriginalPrice(double originalPrice) {
        this.originalPrice = originalPrice;
    }

    public double getSalePrice() {
        return salePrice;
    }

    public void setSalePrice(double salePrice) {
        this.salePrice = salePrice;
    }

    public Timestamp getExpiredDate() {
        return expiredDate;
    }

    public void setExpiredDate(Timestamp expiredDate) {
        this.expiredDate = expiredDate;
    }

    public double getAverageRating() {
        return averageRating;
    }

    public void setAverageRating(double averageRating) {
        this.averageRating = averageRating;
    }

    public boolean isIsFeatured() {
        return isFeatured;
    }

    public void setIsFeatured(boolean isFeatured) {
        this.isFeatured = isFeatured;
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

    public boolean isActive() {
        return status == 1 && !isDelete;
    }

    public boolean isInStock() {
        return stockQuantity > 0;
    }

    public boolean isLowStock() {
        return stockQuantity > 0 && stockQuantity <= 20;
    }

    public String getStatusDisplay() {
        if (isDelete) {
            return "Da xoa";
        }
        return status == 1 ? "Hoat dong" : "Khong hoat dong";
    }

    public double getDiscountPercent() {
        if (originalPrice <= 0 || salePrice <= 0 || salePrice >= originalPrice) {
            return 0;
        }
        return Math.round((1 - salePrice / originalPrice) * 100 * 100.0) / 100.0;
    }
}

