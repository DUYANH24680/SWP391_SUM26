package model;

import java.sql.Timestamp;

public class CartItem {
    private int id; // cart_item_id
    private int cartId;
    private Product product;
    private int quantity;
    private Timestamp addedAt;

    public CartItem() {
    }

    public CartItem(int id, int cartId, Product product, int quantity, Timestamp addedAt) {
        this.id = id;
        this.cartId = cartId;
        this.product = product;
        this.quantity = quantity;
        this.addedAt = addedAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getCartId() {
        return cartId;
    }

    public void setCartId(int cartId) {
        this.cartId = cartId;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public Timestamp getAddedAt() {
        return addedAt;
    }

    public void setAddedAt(Timestamp addedAt) {
        this.addedAt = addedAt;
    }

    public double getTotalPrice() {
        if (product != null) {
            return this.quantity * product.getSalePrice(); // Assuming getSalePrice() is the actual selling price
        }
        return 0;
    }
}
