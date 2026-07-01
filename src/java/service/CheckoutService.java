package service;

import dao.DeliveryAddressDAO;
import dao.ProductDAO;
import dao.VoucherDAO;
import model.CheckoutPageResult;
import model.DeliveryAddress;
import model.Product;
import model.Voucher;
import model.VoucherCheckResult;

import java.util.List;

public class CheckoutService {

    private ProductDAO productDAO;
    private DeliveryAddressDAO addressDAO;
    private VoucherDAO voucherDAO;

    public CheckoutService() {
        this.productDAO = new ProductDAO();
        this.addressDAO = new DeliveryAddressDAO();
        this.voucherDAO = new VoucherDAO();
    }

    public void close() {
        if (productDAO != null) {
            try { productDAO.close(); } catch (Exception ignored) {}
            productDAO = null;
        }
        if (addressDAO != null) {
            try { addressDAO.close(); } catch (Exception ignored) {}
            addressDAO = null;
        }
        if (voucherDAO != null) {
            try { voucherDAO.close(); } catch (Exception ignored) {}
            voucherDAO = null;
        }
    }

    public CheckoutPageResult getCheckoutPageData(int customerId, int productId, int quantity) {
        ProductDAO productDAO = new ProductDAO();
        DeliveryAddressDAO addressDAO = new DeliveryAddressDAO();
        VoucherDAO voucherDAO = new VoucherDAO();

        try {
            Product product = productDAO.getProductById(productId);
            if (product == null || product.isIsDelete() || product.getStatus() != 1) {
                return CheckoutPageResult.error("Sản phẩm không tồn tại hoặc ngừng bán.");
            }

            List<DeliveryAddress> addresses = addressDAO.findByCustomerId(customerId);
            List<Voucher> vouchers = voucherDAO.getAllActiveVouchers();

            return CheckoutPageResult.success(product, addresses, vouchers, quantity);
        } catch (Exception e) {
            System.err.println("[CheckoutService] getCheckoutPageData error: " + e.getMessage());
            e.printStackTrace();
            return CheckoutPageResult.error("Lỗi hệ thống khi tải trang thanh toán.");
        } finally {
            productDAO.close();
            addressDAO.close();
            voucherDAO.close();
        }
    }

    public VoucherCheckResult validateVoucher(String code, double total) {
        VoucherDAO voucherDAO = new VoucherDAO();
        try {
            Voucher voucher = voucherDAO.findByCode(code);
            if (voucher == null) {
                return new VoucherCheckResult(false, "Mã giảm giá không tồn tại.");
            }
            if (!voucher.isStatus()) {
                return new VoucherCheckResult(false, "Mã giảm giá đã bị khóa.");
            }
            if (voucher.getUsedCount() >= voucher.getQuantity()) {
                return new VoucherCheckResult(false, "Mã giảm giá đã hết lượt sử dụng.");
            }
            if (voucher.getStartDate() != null && new java.util.Date().before(voucher.getStartDate())) {
                return new VoucherCheckResult(false, "Mã giảm giá chưa đến hạn sử dụng.");
            }
            if (voucher.getEndDate() != null && new java.util.Date().after(voucher.getEndDate())) {
                return new VoucherCheckResult(false, "Mã giảm giá đã hết hạn sử dụng.");
            }
            if (total < voucher.getMinimumOrder()) {
                return new VoucherCheckResult(false,
                        String.format("Giá trị đơn hàng chưa đạt mức tối thiểu (%,.0f đ).", voucher.getMinimumOrder()));
            }

            double discount = voucher.calculateDiscount(total);
            return new VoucherCheckResult(true, "Áp dụng mã giảm giá thành công!", discount, voucher.getId());
        } finally {
            voucherDAO.close();
        }
    }
}
