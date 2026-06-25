package model;

public class SellerOrderActionResult {
    private final boolean success;
    private final String message;

    public SellerOrderActionResult(boolean success, String message) {
        this.success = success;
        this.message = message;
    }

    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }
}
