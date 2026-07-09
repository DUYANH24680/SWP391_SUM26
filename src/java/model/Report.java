package model;

import java.sql.Timestamp;

public class Report {
    private int id;
    private int customerId;
    private int productId;
    private String reason;
    private String status; // PENDING, CONFIRMED, REJECTED
    private Timestamp createdAt;
    
    // Virtual fields for UI convenience
    private String customerName;
    private String productName;
    private String productThumb;
    private int sellerId;
    
    public Report() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }
    
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getProductThumb() { return productThumb; }
    public void setProductThumb(String productThumb) { this.productThumb = productThumb; }

    public int getSellerId() { return sellerId; }
    public void setSellerId(int sellerId) { this.sellerId = sellerId; }
}
