package model;

public class ReorderResult {
    private final boolean success;
    private final String message;
    private final String error;

    private ReorderResult(boolean success, String message, String error) {
        this.success = success;
        this.message = message;
        this.error = error;
    }

    public static ReorderResult success(String message) {
        return new ReorderResult(true, message, null);
    }

    public static ReorderResult failure(String error) {
        return new ReorderResult(false, null, error);
    }

    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }

    public String getError() {
        return error;
    }
}
