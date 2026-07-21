package service;

import dao.StaffDetailsDAO;
import model.StaffDetails;
import java.util.regex.Pattern;

/**
 * StaffService - Business logic cho Staff.
 * Xử lý validation: mã nhân viên, format CCCD, khu vực quản lý.
 */
public class StaffService {

    private StaffDetailsDAO staffDetailsDAO = new StaffDetailsDAO();

    // Regex cho mã nhân viên: cho phép chữ và số, 3-20 ký tự
    private static final Pattern STAFF_CODE_PATTERN = Pattern.compile("^[A-Za-z0-9]{3,20}$");

    // Regex cho CCCD: đúng 12 số
    private static final Pattern CCCD_PATTERN = Pattern.compile("^\\d{12}$");

    /**
     * Thêm thông tin chi tiết nhân viên sau khi tạo tài khoản.
     */
    public String addStaffDetails(int accountId, String staffCode, String cccd, String managedArea) {
        // Validate staff code
        String codeError = validateStaffCode(staffCode, 0);
        if (codeError != null) return codeError;

        // Validate CCCD
        String cccdError = validateCccd(cccd, 0);
        if (cccdError != null) return cccdError;

        // Validate managed area
        if (managedArea == null || managedArea.trim().isEmpty()) {
            return "Khu vực quản lý không được để trống.";
        }

        // Add to database
        boolean success = staffDetailsDAO.addStaffDetails(accountId, staffCode.trim().toUpperCase(), cccd.trim(), managedArea.trim());
        if (!success) {
            return "Không thể lưu thông tin nhân viên. Vui lòng thử lại.";
        }

        System.out.println("[StaffService] Staff details added for account: " + accountId);
        return null;
    }

    /**
     * Cập nhật thông tin chi tiết nhân viên.
     */
    public String updateStaffDetails(int accountId, String staffCode, String cccd, String managedArea) {
        // Validate staff code
        String codeError = validateStaffCode(staffCode, accountId);
        if (codeError != null) return codeError;

        // Validate CCCD
        String cccdError = validateCccd(cccd, accountId);
        if (cccdError != null) return cccdError;

        // Validate managed area
        if (managedArea == null || managedArea.trim().isEmpty()) {
            return "Khu vực quản lý không được để trống.";
        }

        // Update database
        boolean success = staffDetailsDAO.updateStaffDetails(accountId, staffCode.trim().toUpperCase(), cccd.trim(), managedArea.trim());
        if (!success) {
            return "Không thể cập nhật thông tin nhân viên. Vui lòng thử lại.";
        }

        System.out.println("[StaffService] Staff details updated for account: " + accountId);
        return null;
    }

    /**
     * Validate mã nhân viên.
     */
    private String validateStaffCode(String staffCode, int excludeAccountId) {
        if (staffCode == null || staffCode.trim().isEmpty()) {
            return "Mã nhân viên không được để trống.";
        }
        String cleanCode = staffCode.trim().toUpperCase();
        if (!STAFF_CODE_PATTERN.matcher(cleanCode).matches()) {
            return "Mã nhân viên phải từ 3-20 ký tự, chỉ gồm chữ và số.";
        }
        if (staffDetailsDAO.isStaffCodeTaken(cleanCode, excludeAccountId)) {
            return "Mã nhân viên đã được sử dụng bởi tài khoản khác.";
        }
        return null;
    }

    /**
     * Validate CCCD.
     */
    private String validateCccd(String cccd, int excludeAccountId) {
        if (cccd == null || cccd.trim().isEmpty()) {
            return "Số CCCD không được để trống.";
        }
        String cleanCccd = cccd.trim().replaceAll("\\s+", "");
        if (!CCCD_PATTERN.matcher(cleanCccd).matches()) {
            return "Số CCCD phải gồm đúng 12 chữ số.";
        }
        if (staffDetailsDAO.isCccdTaken(cleanCccd, excludeAccountId)) {
            return "Số CCCD đã được sử dụng bởi tài khoản khác.";
        }
        // Kiểm tra CCCD trùng với Shipper
        if (staffDetailsDAO.isCccdExistsInShipperDetails(cleanCccd)) {
            return "Số CCCD đã được sử dụng bởi shipper khác.";
        }
        return null;
    }

    /**
     * Lấy thông tin chi tiết nhân viên theo accountId.
     */
    public StaffDetails getStaffDetails(int accountId) {
        return staffDetailsDAO.getByAccountId(accountId);
    }

    /**
     * Xóa thông tin chi tiết nhân viên.
     */
    public void deleteStaffDetails(int accountId) {
        staffDetailsDAO.deleteByAccountId(accountId);
    }
}
