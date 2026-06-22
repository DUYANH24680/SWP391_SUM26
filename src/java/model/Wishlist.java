package model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Wishlist {
    private int id;
    private int customerId;
    private Timestamp createdAt;
    private List<WishlistItem> items = new ArrayList<>();

    public Wishlist() {
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

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public List<WishlistItem> getItems() {
        return items;
    }

    public void setItems(List<WishlistItem> items) {
        this.items = items != null ? items : new ArrayList<>();
    }

    public boolean isEmpty() {
        return items == null || items.isEmpty();
    }

    public int getTotalItems() {
        return items == null ? 0 : items.size();
    }
}
