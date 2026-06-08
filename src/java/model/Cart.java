package model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Cart {
    private int id; // cart_id
    private int customerId;
    private Timestamp createdAt;
    private List<CartItem> items;

    public Cart() {
        this.items = new ArrayList<>();
    }

    public Cart(int id, int customerId, Timestamp createdAt) {
        this.id = id;
        this.customerId = customerId;
        this.createdAt = createdAt;
        this.items = new ArrayList<>();
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

    public List<CartItem> getItems() {
        return items;
    }

    public void setItems(List<CartItem> items) {
        this.items = items;
    }

    public double getTotalMoney() {
        double total = 0;
        if (items != null) {
            for (CartItem item : items) {
                total += item.getTotalPrice();
            }
        }
        return total;
    }
}
