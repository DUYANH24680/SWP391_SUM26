package model;

public class VoucherCheckResult {
    private final boolean valid;
    private final String msg;
    private final double discount;
    private final int voucherId;

    public VoucherCheckResult(boolean valid, String msg) {
        this(valid, msg, 0.0, 0);
    }

    public VoucherCheckResult(boolean valid, String msg, double discount, int voucherId) {
        this.valid = valid;
        this.msg = msg;
        this.discount = discount;
        this.voucherId = voucherId;
    }

    public boolean isValid() {
        return valid;
    }

    public String getMsg() {
        return msg;
    }

    public double getDiscount() {
        return discount;
    }

    public int getVoucherId() {
        return voucherId;
    }

    public String toJson() {
        if (valid) {
            return String.format(
                    "{\"valid\": true, \"discount\": %.2f, \"voucherId\": %d, \"msg\": \"%s\"}",
                    discount, voucherId, msg);
        }
        return String.format("{\"valid\": false, \"msg\": \"%s\"}", msg);
    }
}
