package model;

public class CancelOrderResult {
    private final boolean success;
    private final String error;

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

    public boolean isSuccess() { return success; }
    public String getError() { return error; }
}
