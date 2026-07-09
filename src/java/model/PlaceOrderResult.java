package model;

public class PlaceOrderResult {
    private boolean success;
    private Object message; // int (orderId) or String (error)
    private int orderCount;
    private int shopCount;

    public PlaceOrderResult(boolean success, int orderId) {
        this.success = success;
        this.message = orderId;
    }

    public PlaceOrderResult(boolean success, String error) {
        this.success = success;
        this.message = error;
    }

    // Extended constructor with order and shop counts
    public PlaceOrderResult(boolean success, int orderId, int orderCount, int shopCount) {
        this.success = success;
        this.message = orderId;
        this.orderCount = orderCount;
        this.shopCount = shopCount;
    }

    public static PlaceOrderResult failure(String error) {
        return new PlaceOrderResult(false, error);
    }

    public boolean isSuccess() {
        return success;
    }

    public Object getMessage() {
        return message;
    }

    public int getOrderId() {
        if (message instanceof Integer) {
            return (Integer) message;
        }
        return 0;
    }

    public String getError() {
        if (message instanceof String) {
            return (String) message;
        }
        return null;
    }

    public int getOrderCount() {
        return orderCount;
    }

    public int getShopCount() {
        return shopCount;
    }
}
