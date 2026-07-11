package model;

public class SellerOrderActionResult {
    private final boolean success;
    private final String message;

    private SellerOrderActionResult(boolean success, String message) {
        this.success = success;
        this.message = message;
    }

    public static SellerOrderActionResult success(String message) {
        return new SellerOrderActionResult(true, message);
    }

    public static SellerOrderActionResult failure(String message) {
        return new SellerOrderActionResult(false, message);
    }

    public boolean isSuccess() { return success; }
    public String getMessage() { return message; }
}
