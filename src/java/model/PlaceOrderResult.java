package model;

public class PlaceOrderResult {
    private final boolean success;
    private final String error;
    private final int orderId;

    public PlaceOrderResult(boolean success, String error) {
        this.success = success;
        this.error = error;
        this.orderId = 0;
    }

    public PlaceOrderResult(boolean success, int orderId) {
        this.success = success;
        this.orderId = orderId;
        this.error = null;
    }

    public boolean isSuccess() {
        return success;
    }

    public String getError() {
        return error;
    }

    public int getOrderId() {
        return orderId;
    }
}
