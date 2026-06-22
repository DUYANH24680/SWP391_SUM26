package model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class Cart {
    private int id;
    private int customerId;
    private int totalItems;
    private double totalAmount;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private List<CartItem> items = new ArrayList<>();

    public Cart() {
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

    public int getTotalItems() {
        return totalItems;
    }

    public void setTotalItems(int totalItems) {
        this.totalItems = totalItems;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<CartItem> getItems() {
        return items;
    }

    public void setItems(List<CartItem> items) {
        this.items = items != null ? items : new ArrayList<>();
    }

    public void addItem(CartItem item) {
        if (item == null || item.getProductId() <= 0) {
            return;
        }
        String key = item.getItemKey();
        Optional<CartItem> existing = items.stream()
                .filter(i -> key.equals(i.getItemKey()))
                .findFirst();
        if (existing.isPresent()) {
            CartItem found = existing.get();
            found.incrementQuantity(item.getQuantity());
            if (item.getNote() != null && !item.getNote().trim().isEmpty()) {
                found.setNote(item.getNote());
            }
            if (item.getDiscountCode() != null && !item.getDiscountCode().trim().isEmpty()) {
                found.setDiscountCode(item.getDiscountCode());
            }
        } else {
            items.add(item);
        }
    }

    public void updateQuantity(int productId, String size, int quantity) {
        if (quantity < 1) {
            removeItem(productId, size);
            return;
        }
        getItem(productId, size).ifPresent(item -> item.setQuantity(quantity));
    }

    public void removeItem(int productId, String size) {
        items.removeIf(item -> item.getProductId() == productId && safeEquals(item.getSize(), size));
    }

    public void clear() {
        items.clear();
    }

    public int getTotalQuantity() {
        return items.stream().mapToInt(CartItem::getQuantity).sum();
    }

    public double getTotalPrice() {
        return items.stream().mapToDouble(CartItem::getSubtotal).sum();
    }

    public boolean isEmpty() {
        return items.isEmpty();
    }

    public Optional<CartItem> getItem(int productId, String size) {
        return items.stream()
                .filter(item -> item.getProductId() == productId && safeEquals(item.getSize(), size))
                .findFirst();
    }

    private boolean safeEquals(String a, String b) {
        if (a == null && b == null) return true;
        if (a == null || b == null) return false;
        return a.equals(b);
    }
}
