package model;

import java.sql.Timestamp;

/**
 * Model cho bang InventoryTransactions.
 * Luu lich su nhap kho / xuat kho cua tung san pham.
 */
public class InventoryTransaction {

    private int id;
    private int productId;
    private int accountId;
    private int quantity;
    private int previousStock;
    private int newStock;
    private String note;
    private String transactionType;
    private Timestamp expiredDate;
    private Timestamp createdAt;

    public InventoryTransaction() {
    }

    public InventoryTransaction(int productId, int accountId, int quantity,
                                int previousStock, int newStock, String note, String transactionType,
                                Timestamp expiredDate) {
        this.productId = productId;
        this.accountId = accountId;
        this.quantity = quantity;
        this.previousStock = previousStock;
        this.newStock = newStock;
        this.note = note;
        this.transactionType = transactionType;
        this.expiredDate = expiredDate;
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

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public int getPreviousStock() {
        return previousStock;
    }

    public void setPreviousStock(int previousStock) {
        this.previousStock = previousStock;
    }

    public int getNewStock() {
        return newStock;
    }

    public void setNewStock(int newStock) {
        this.newStock = newStock;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public Timestamp getExpiredDate() {
        return expiredDate;
    }

    public void setExpiredDate(Timestamp expiredDate) {
        this.expiredDate = expiredDate;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
