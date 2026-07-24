package model;

/**
 * CancelOrderResult - Result object for order cancellation operations.
 */
public class CancelOrderResult {
    private boolean success;
    private String error;

    private CancelOrderResult(boolean success, String error) {
        this.success = success;
        this.error = error;
    }

    public static CancelOrderResult success() {
        return new CancelOrderResult(true, null);
    }

    public static CancelOrderResult failure(String error) {
        return new CancelOrderResult(false, error);
    }

    public boolean isSuccess() {
        return success;
    }

    public String getError() {
        return error;
    }
}
