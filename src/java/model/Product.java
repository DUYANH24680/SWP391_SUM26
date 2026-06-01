package model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class Product {
    private int id;
    private int categoryId;
    private int sellerId;
    private String title;
    private String image;
    private String description;
    private String unit;
    private int stockQuantity;
    private int soldQuantity;
    private BigDecimal originalPrice;
    private BigDecimal salePrice;
    private Date expiredDate;
    private BigDecimal averageRating;
    private boolean isFeatured;
    private int status;
    private boolean isDelete;
    private Timestamp createdAt;

    public Product() {
    }

    public Product(int id, int categoryId, int sellerId, String title, String image, String description, String unit, int stockQuantity, int soldQuantity, BigDecimal originalPrice, BigDecimal salePrice, Date expiredDate, BigDecimal averageRating, boolean isFeatured, int status, boolean isDelete, Timestamp createdAt) {
        this.id = id;
        this.categoryId = categoryId;
        this.sellerId = sellerId;
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

    public Product(int categoryId, int sellerId, String title, String image, String description, String unit, int stockQuantity, BigDecimal originalPrice, BigDecimal salePrice, Date expiredDate, int status) {
        this.categoryId = categoryId;
        this.sellerId = sellerId;
        this.title = title;
        this.image = image;
        this.description = description;
        this.unit = unit;
        this.stockQuantity = stockQuantity;
        this.originalPrice = originalPrice;
        this.salePrice = salePrice;
        this.expiredDate = expiredDate;
        this.status = status;
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

    public BigDecimal getOriginalPrice() {
        return originalPrice;
    }

    public void setOriginalPrice(BigDecimal originalPrice) {
        this.originalPrice = originalPrice;
    }

    public BigDecimal getSalePrice() {
        return salePrice;
    }

    public void setSalePrice(BigDecimal salePrice) {
        this.salePrice = salePrice;
    }

    public Date getExpiredDate() {
        return expiredDate;
    }

    public void setExpiredDate(Date expiredDate) {
        this.expiredDate = expiredDate;
    }

    public BigDecimal getAverageRating() {
        return averageRating;
    }

    public void setAverageRating(BigDecimal averageRating) {
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
}
