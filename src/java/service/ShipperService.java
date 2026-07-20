package service;

import dao.ShipperDetailsDAO;
import dao.AccountDAO;
import model.ShipperDetails;
import java.sql.Date;
import java.time.LocalDate;
import java.time.Period;
import java.util.regex.Pattern;

/**
 * ShipperService - Business logic cho Shipper.
 * Xử lý validation đặc thù: mã shipper, tuổi >= 18, format CCCD, vehicle type, delivery area.
 */
public class ShipperService {

    private ShipperDetailsDAO shipperDetailsDAO = new ShipperDetailsDAO();
    private AccountDAO accountDAO = new AccountDAO();

    // Regex cho mã shipper: cho phép chữ và số, 3-20 ký tự
    private static final Pattern SHIPPER_CODE_PATTERN = Pattern.compile("^[A-Za-z0-9]{3,20}$");

    // Regex cho CCCD: đúng 12 số
    private static final Pattern CCCD_PATTERN = Pattern.compile("^\\d{12}$");

    /**
     * Thêm thông tin chi tiết shipper sau khi tạo tài khoản.
     */
    public String addShipperDetails(int accountId, String shipperCode, String birthdateStr, String cccd,
                                   String vehicleType, String deliveryArea) {
        // Validate shipper code
        String codeError = validateShipperCode(shipperCode, 0);
        if (codeError != null) return codeError;

        // Validate CCCD
        String cccdError = validateCccd(cccd, 0);
        if (cccdError != null) return cccdError;

        // Validate ngày sinh và tuổi >= 18
        String ageError = validateAge(birthdateStr);
        if (ageError != null) return ageError;

        // Validate vehicle type
        if (vehicleType == null || vehicleType.trim().isEmpty()) {
            return "Loại phương tiện không được để trống.";
        }

        // Validate delivery area
        if (deliveryArea == null || deliveryArea.trim().isEmpty()) {
            return "Khu vực giao hàng không được để trống.";
        }

        // Parse birthdate
        Date birthdate = parseDate(birthdateStr);
        if (birthdate == null) {
            return "Ngày sinh không hợp lệ.";
        }

        // Add to database
        boolean success = shipperDetailsDAO.addShipperDetails(accountId, shipperCode.trim().toUpperCase(), birthdate, cccd.trim(), vehicleType.trim(), deliveryArea.trim());
        if (!success) {
            return "Không thể lưu thông tin shipper. Vui lòng thử lại.";
        }

        System.out.println("[ShipperService] Shipper details added for account: " + accountId);
        return null;
    }

    /**
     * Cập nhật thông tin chi tiết shipper.
     */
    public String updateShipperDetails(int accountId, String shipperCode, String birthdateStr, String cccd,
                                       String vehicleType, String deliveryArea) {
        // Validate shipper code
        String codeError = validateShipperCode(shipperCode, accountId);
        if (codeError != null) return codeError;

        // Validate CCCD
        String cccdError = validateCccd(cccd, accountId);
        if (cccdError != null) return cccdError;

        // Validate ngày sinh và tuổi >= 18
        String ageError = validateAge(birthdateStr);
        if (ageError != null) return ageError;

        // Validate vehicle type
        if (vehicleType == null || vehicleType.trim().isEmpty()) {
            return "Loại phương tiện không được để trống.";
        }

        // Validate delivery area
        if (deliveryArea == null || deliveryArea.trim().isEmpty()) {
            return "Khu vực giao hàng không được để trống.";
        }

        // Parse birthdate
        Date birthdate = parseDate(birthdateStr);
        if (birthdate == null) {
            return "Ngày sinh không hợp lệ.";
        }

        // Update database
        boolean success = shipperDetailsDAO.updateShipperDetails(accountId, shipperCode.trim().toUpperCase(), birthdate, cccd.trim(), vehicleType.trim(), deliveryArea.trim());
        if (!success) {
            return "Không thể cập nhật thông tin shipper. Vui lòng thử lại.";
        }

        System.out.println("[ShipperService] Shipper details updated for account: " + accountId);
        return null;
    }

    /**
     * Validate mã shipper.
     */
    private String validateShipperCode(String shipperCode, int excludeAccountId) {
        if (shipperCode == null || shipperCode.trim().isEmpty()) {
            return "Mã shipper không được để trống.";
        }
        String cleanCode = shipperCode.trim().toUpperCase();
        if (!SHIPPER_CODE_PATTERN.matcher(cleanCode).matches()) {
            return "Mã shipper phải từ 3-20 ký tự, chỉ gồm chữ và số.";
        }
        if (shipperDetailsDAO.isShipperCodeTaken(cleanCode, excludeAccountId)) {
            return "Mã shipper đã được sử dụng bởi tài khoản khác.";
        }
        return null;
    }

    /**
     * Validate CCCD - phải là 12 số.
     */
    private String validateCccd(String cccd, int excludeAccountId) {
        if (cccd == null || cccd.trim().isEmpty()) {
            return "Số CCCD không được để trống.";
        }
        String cleanCccd = cccd.trim().replaceAll("\\s+", "");
        if (!CCCD_PATTERN.matcher(cleanCccd).matches()) {
            return "Số CCCD phải gồm đúng 12 chữ số.";
        }
        if (shipperDetailsDAO.isCccdTaken(cleanCccd, excludeAccountId)) {
            return "Số CCCD đã được sử dụng bởi tài khoản khác.";
        }
        // Kiểm tra CCCD trùng với Staff
        if (shipperDetailsDAO.isCccdExistsInStaffDetails(cleanCccd)) {
            return "Số CCCD đã được sử dụng bởi nhân viên khác.";
        }
        return null;
    }

    /**
     * Validate tuổi >= 18.
     */
    private String validateAge(String birthdateStr) {
        if (birthdateStr == null || birthdateStr.trim().isEmpty()) {
            return "Ngày sinh không được để trống.";
        }

        LocalDate birthdate = parseLocalDate(birthdateStr);
        if (birthdate == null) {
            return "Ngày sinh không đúng định dạng (yyyy-MM-dd).";
        }

        LocalDate today = LocalDate.now();
        Period age = Period.between(birthdate, today);
        int ageInYears = age.getYears();

        if (ageInYears < 18 || (ageInYears == 18 && (age.getMonths() > 0 || age.getDays() > 0))) {
            return "Shipper phải đủ 18 tuổi trở lên.";
        }

        if (birthdate.isAfter(today)) {
            return "Ngày sinh không thể là ngày trong tương lai.";
        }

        return null;
    }

    /**
     * Parse date string (yyyy-MM-dd) to java.sql.Date.
     */
    private Date parseDate(String dateStr) {
        try {
            LocalDate localDate = LocalDate.parse(dateStr.trim());
            return Date.valueOf(localDate);
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Parse date string (yyyy-MM-dd) to LocalDate.
     */
    private LocalDate parseLocalDate(String dateStr) {
        try {
            return LocalDate.parse(dateStr.trim());
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Lấy thông tin chi tiết shipper theo accountId.
     */
    public ShipperDetails getShipperDetails(int accountId) {
        return shipperDetailsDAO.getByAccountId(accountId);
    }

    /**
     * Xóa thông tin chi tiết shipper.
     */
    public void deleteShipperDetails(int accountId) {
        shipperDetailsDAO.deleteByAccountId(accountId);
    }
}
