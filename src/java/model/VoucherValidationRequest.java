package model;

import java.util.HashMap;
import java.util.Map;

public class VoucherValidationRequest {
    private Map<Integer, String> shopVoucherCodes;
    private String platformVoucherCode;
    private Map<Integer, Double> shopSubtotals;
    private double totalSubtotal;

    public VoucherValidationRequest() {
        this.shopVoucherCodes = new HashMap<>();
        this.shopSubtotals = new HashMap<>();
    }

    public Map<Integer, String> getShopVoucherCodes() {
        return shopVoucherCodes;
    }

    public void setShopVoucherCodes(Map<Integer, String> shopVoucherCodes) {
        this.shopVoucherCodes = shopVoucherCodes;
    }

    public String getPlatformVoucherCode() {
        return platformVoucherCode;
    }

    public void setPlatformVoucherCode(String platformVoucherCode) {
        this.platformVoucherCode = platformVoucherCode;
    }

    public Map<Integer, Double> getShopSubtotals() {
        return shopSubtotals;
    }

    public void setShopSubtotals(Map<Integer, Double> shopSubtotals) {
        this.shopSubtotals = shopSubtotals;
    }

    public double getTotalSubtotal() {
        return totalSubtotal;
    }

    public void setTotalSubtotal(double totalSubtotal) {
        this.totalSubtotal = totalSubtotal;
    }
}
