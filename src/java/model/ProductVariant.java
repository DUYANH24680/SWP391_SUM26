package model;

import java.sql.Timestamp;

public class ProductVariant {
    private int id;
    private int productId;
    private String weightValue;  // e.g. "500", "1", "2"
    private String weightUnit;  // e.g. "g", "kg", "ml"
    private String sku;          // SKU code for variant
    private double price;            // giá bán riêng cho variant này
    private int stockQuantity;       // tồn kho riêng
    private boolean isDelete;
    private Timestamp createdAt;

    public ProductVariant() {
    }

    public ProductVariant(int id, int productId, String weightValue, String weightUnit, String sku,
            double price, int stockQuantity, boolean isDelete, Timestamp createdAt) {
        this.id = id;
        this.productId = productId;
        this.weightValue = weightValue;
        this.weightUnit = weightUnit;
        this.sku = sku;
        this.price = price;
        this.stockQuantity = stockQuantity;
        this.isDelete = isDelete;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getWeight() {
        if (weightValue != null && weightUnit != null) {
            return weightValue + weightUnit;
        }
        return weightValue != null ? weightValue : "";
    }

    public void setWeight(String weight) {
        this.weightValue = weight;
    }

    public String getWeightValue() {
        return weightValue;
    }

    public void setWeightValue(String weightValue) {
        this.weightValue = weightValue;
    }

    public String getWeightUnit() {
        return weightUnit;
    }

    public void setWeightUnit(String weightUnit) {
        this.weightUnit = weightUnit;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
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

    public boolean isInStock() {
        return stockQuantity > 0;
    }

    public boolean isLowStock() {
        return stockQuantity > 0 && stockQuantity <= 20;
    }

    public boolean isActive() {
        return !isDelete;
    }
}



