package model;

import java.sql.Timestamp;

public class Wishlist {
    private int id; // wishlist_id
    private int customerId;
    private Product product;
    private Timestamp addedAt;

    public Wishlist() {
    }

    public Wishlist(int id, int customerId, Product product, Timestamp addedAt) {
        this.id = id;
        this.customerId = customerId;
        this.product = product;
        this.addedAt = addedAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public Timestamp getAddedAt() {
        return addedAt;
    }

    public void setAddedAt(Timestamp addedAt) {
        this.addedAt = addedAt;
    }
}
