package model;

import java.util.HashMap;
import java.util.Map;

public class VoucherValidationResult {
    private boolean success;
    private String message;
    private double totalShopDiscount;
    private double platformDiscount;
    private double totalDiscount;
    private double finalTotal;
    private Map<Integer, Double> shopAllocatedPlatformDiscount;
    private Map<Integer, Double> shopDiscountsPerShop;
    private Map<Integer, Integer> shopVoucherIdsPerShop;
    private Map<Integer, String> shopVoucherErrorsPerShop;
    private Integer platformVoucherId;
    private String platformVoucherError;

    public VoucherValidationResult() {
        this.shopAllocatedPlatformDiscount = new HashMap<>();
        this.shopDiscountsPerShop = new HashMap<>();
        this.shopVoucherIdsPerShop = new HashMap<>();
        this.shopVoucherErrorsPerShop = new HashMap<>();
    }

    public static VoucherValidationResult error(String message) {
        VoucherValidationResult result = new VoucherValidationResult();
        result.success = false;
        result.message = message;
        return result;
    }

    public static VoucherValidationResult success(
            double totalShopDiscount,
            double platformDiscount,
            double totalDiscount,
            double finalTotal,
            Map<Integer, Double> shopAllocatedPlatformDiscount,
            Map<Integer, Double> shopDiscountsPerShop,
            Map<Integer, Integer> shopVoucherIdsPerShop,
            Integer platformVoucherId) {
        VoucherValidationResult result = new VoucherValidationResult();
        result.success = true;
        result.message = "Áp dụng mã giảm giá thành công!";
        result.totalShopDiscount = totalShopDiscount;
        result.platformDiscount = platformDiscount;
        result.totalDiscount = totalDiscount;
        result.finalTotal = finalTotal;
        result.shopAllocatedPlatformDiscount = shopAllocatedPlatformDiscount;
        result.shopDiscountsPerShop = shopDiscountsPerShop;
        result.shopVoucherIdsPerShop = shopVoucherIdsPerShop;
        result.platformVoucherId = platformVoucherId;
        return result;
    }

    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public double getTotalShopDiscount() { return totalShopDiscount; }
    public void setTotalShopDiscount(double totalShopDiscount) { this.totalShopDiscount = totalShopDiscount; }
    public double getPlatformDiscount() { return platformDiscount; }
    public void setPlatformDiscount(double platformDiscount) { this.platformDiscount = platformDiscount; }
    public double getTotalDiscount() { return totalDiscount; }
    public void setTotalDiscount(double totalDiscount) { this.totalDiscount = totalDiscount; }
    public double getFinalTotal() { return finalTotal; }
    public void setFinalTotal(double finalTotal) { this.finalTotal = finalTotal; }
    public Map<Integer, Double> getShopAllocatedPlatformDiscount() { return shopAllocatedPlatformDiscount; }
    public void setShopAllocatedPlatformDiscount(Map<Integer, Double> shopAllocatedPlatformDiscount) { this.shopAllocatedPlatformDiscount = shopAllocatedPlatformDiscount; }
    public Map<Integer, Double> getShopDiscountsPerShop() { return shopDiscountsPerShop; }
    public void setShopDiscountsPerShop(Map<Integer, Double> shopDiscountsPerShop) { this.shopDiscountsPerShop = shopDiscountsPerShop; }
    public Map<Integer, Integer> getShopVoucherIdsPerShop() { return shopVoucherIdsPerShop; }
    public void setShopVoucherIdsPerShop(Map<Integer, Integer> shopVoucherIdsPerShop) { this.shopVoucherIdsPerShop = shopVoucherIdsPerShop; }
    public Map<Integer, String> getShopVoucherErrorsPerShop() { return shopVoucherErrorsPerShop; }
    public void setShopVoucherErrorsPerShop(Map<Integer, String> shopVoucherErrorsPerShop) { this.shopVoucherErrorsPerShop = shopVoucherErrorsPerShop; }
    public Integer getPlatformVoucherId() { return platformVoucherId; }
    public void setPlatformVoucherId(Integer platformVoucherId) { this.platformVoucherId = platformVoucherId; }
    public String getPlatformVoucherError() { return platformVoucherError; }
    public void setPlatformVoucherError(String platformVoucherError) { this.platformVoucherError = platformVoucherError; }

    public String toJson() {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"success\":").append(success);
        sb.append(",\"message\":\"").append(escapeJson(message != null ? message : "")).append("\"");

        if (success) {
            sb.append(",\"totalShopDiscount\":").append(totalShopDiscount);
            sb.append(",\"platformDiscount\":").append(platformDiscount);
            sb.append(",\"totalDiscount\":").append(totalDiscount);
            sb.append(",\"finalTotal\":").append(finalTotal);

            if (platformVoucherId != null) {
                sb.append(",\"platformVoucherId\":").append(platformVoucherId);
            }

            // Per-shop discounts
            sb.append(",\"shopDiscountsPerShop\":{");
            boolean first = true;
            for (Map.Entry<Integer, Double> e : shopDiscountsPerShop.entrySet()) {
                if (!first) sb.append(",");
                sb.append("\"").append(e.getKey()).append("\":").append(e.getValue());
                first = false;
            }
            sb.append("}");

            // Per-shop voucher IDs
            sb.append(",\"shopVoucherIdsPerShop\":{");
            first = true;
            for (Map.Entry<Integer, Integer> e : shopVoucherIdsPerShop.entrySet()) {
                if (!first) sb.append(",");
                sb.append("\"").append(e.getKey()).append("\":").append(e.getValue());
                first = false;
            }
            sb.append("}");

            // Platform allocated discount per shop
            sb.append(",\"shopAllocatedPlatformDiscount\":{");
            first = true;
            for (Map.Entry<Integer, Double> e : shopAllocatedPlatformDiscount.entrySet()) {
                if (!first) sb.append(",");
                sb.append("\"").append(e.getKey()).append("\":").append(e.getValue());
                first = false;
            }
            sb.append("}");

            // Per-shop messages
            for (Map.Entry<Integer, String> e : shopVoucherErrorsPerShop.entrySet()) {
                sb.append(",\"shop_").append(e.getKey()).append("_msg\":\"")
                  .append(escapeJson(e.getValue())).append("\"");
                sb.append(",\"shop_").append(e.getKey()).append("_discount\":0");
            }
            for (Map.Entry<Integer, Double> e : shopDiscountsPerShop.entrySet()) {
                if (!shopVoucherErrorsPerShop.containsKey(e.getKey())) {
                    sb.append(",\"shop_").append(e.getKey()).append("_msg\":\"Áp dụng thành công\"");
                    sb.append(",\"shop_").append(e.getKey()).append("_discount\":").append(e.getValue());
                    Integer vid = shopVoucherIdsPerShop.get(e.getKey());
                    if (vid != null) {
                        sb.append(",\"shop_").append(e.getKey()).append("_id\":").append(vid);
                    }
                }
            }
        } else {
            if (platformVoucherError != null && !platformVoucherError.isEmpty()) {
                sb.append(",\"platformVoucherError\":\"").append(escapeJson(platformVoucherError)).append("\"");
            }
            // Per-shop errors
            for (Map.Entry<Integer, String> e : shopVoucherErrorsPerShop.entrySet()) {
                sb.append(",\"shop_").append(e.getKey()).append("_msg\":\"")
                  .append(escapeJson(e.getValue())).append("\"");
            }
        }

        sb.append("}");
        return sb.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
