package model;

import java.sql.Timestamp;

public class CartItem {
    private int id;
    private int cartId;
    private int productId;
    private int shopId;
    private String title;
    private String image;
    private String unit;
    private double unitPrice;
    private int quantity;
    private String size;
    private String note;
    private int voucherId;
    private String discountCode;
    private double discountAmount;
    private double totalPrice;
    private boolean isSelected;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public CartItem() {
    }

    public CartItem(int productId, int shopId, String title, String image, String unit,
                    double unitPrice, int quantity, String size, String note, String discountCode) {
        this.productId = productId;
        this.shopId = shopId;
        this.title = title;
        this.image = image;
        this.unit = unit;
        this.unitPrice = unitPrice;
        this.quantity = quantity;
        this.size = size;
        this.note = note;
        this.discountCode = discountCode;
        this.discountAmount = 0;
        this.totalPrice = unitPrice * quantity;
        this.isSelected = true;
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

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getShopId() {
        return shopId;
    }

    public void setShopId(int shopId) {
        this.shopId = shopId;
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

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public double getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getSize() {
        return size;
    }

    public int getVoucherId() {
        return voucherId;
    }

    public void setVoucherId(int voucherId) {
        this.voucherId = voucherId;
    }

    public double getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(double discountAmount) {
        this.discountAmount = discountAmount;
    }

    public double getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(double totalPrice) {
        this.totalPrice = totalPrice;
    }

    public boolean isSelected() {
        return isSelected;
    }

    public void setSelected(boolean selected) {
        isSelected = selected;
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

    public void setSize(String size) {
        this.size = size;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getDiscountCode() {
        return discountCode;
    }

    public void setDiscountCode(String discountCode) {
        this.discountCode = discountCode;
    }

    public double getSubtotal() {
        return totalPrice;
    }

    public void incrementQuantity(int amount) {
        this.quantity = Math.max(1, this.quantity + amount);
    }

    public String getItemKey() {
        return String.valueOf(productId);
    }
}

