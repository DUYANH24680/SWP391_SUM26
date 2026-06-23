package model;

import java.sql.Timestamp;

public class ProductVariant {
    private int id;
    private int productId;
    private String weight;           // e.g. "500g", "1kg", "2kg"
    private double price;            // giá bán riêng cho variant này
    private int stockQuantity;       // tồn kho riêng
    private boolean isDelete;
    private Timestamp createdAt;

    public ProductVariant() {
    }

    public ProductVariant(int id, int productId, String weight, double price, int stockQuantity,
            boolean isDelete, Timestamp createdAt) {
        this.id = id;
        this.productId = productId;
        this.weight = weight;
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
        return weight;
    }

    public void setWeight(String weight) {
        this.weight = weight;
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
