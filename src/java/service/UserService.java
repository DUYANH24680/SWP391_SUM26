package service;

import dao.CustomerDAO;
import dao.SellerDAO;
import model.Customer;
import model.Seller;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.nio.charset.StandardCharsets;

public class UserService {

    private final CustomerDAO customerDao = new CustomerDAO();
    private final SellerDAO sellerDao = new SellerDAO();

    public String updateProfile(int customerId, String fullname, String email,
                                String phone, String address, Boolean gender, String avatar) {
        if (fullname == null || fullname.trim().isEmpty()) {
            return "Ho va ten khong duoc de trong.";
        }
        if (email == null || email.trim().isEmpty()) {
            return "Email khong duoc de trong.";
        }
        if (!email.contains("@")) {
            return "Email khong dung dinh dang.";
        }
        if (phone != null && !phone.isEmpty() && !phone.matches("^[0-9]{9,11}$")) {
            return "So dien thoai khong hop le (9-11 chu so).";
        }
        if (customerDao.isEmailTaken(email.trim(), customerId)) {
            return "Email nay da duoc su dung boi mot tai khoan khac.";
        }
        boolean ok = customerDao.updateProfile(customerId, fullname.trim(),
                email.trim(), phone, address, gender, avatar);
        return ok ? null : "Cap nhat that bai. Vui long thu lai.";
    }

    public String changePassword(int customerId, String currentPassword,
                                 String newPassword, String confirmPassword) {
        if (newPassword == null || newPassword.length() < 6) {
            return "Mat khau moi phai co it nhat 6 ky tu.";
        }
        if (!newPassword.equals(confirmPassword)) {
            return "Xac nhan mat khau khong khop.";
        }
        Customer c = customerDao.findById(customerId);
        if (c == null) return "Khong tim thay tai khoan.";
        if (!currentPassword.equals(c.getPasswordHash())) {
            return "Mat khau hien tai khong dung.";
        }
        boolean ok = customerDao.updatePassword(customerId, newPassword);
        return ok ? null : "Doi mat khau that bai. Vui long thu lai.";
    }

    public String updateSellerProfile(int sellerId, String fullname, String email,
                                       String phone, String address, Boolean gender, String avatar) {
        if (fullname == null || fullname.trim().isEmpty()) {
            return "Ho va ten khong duoc de trong.";
        }
        if (email == null || email.trim().isEmpty()) {
            return "Email khong duoc de trong.";
        }
        boolean ok = sellerDao.updateProfile(sellerId, fullname.trim(),
                email.trim(), phone, address, gender, avatar);
        return ok ? null : "Cap nhat that bai. Vui long thu lai.";
    }

    public String changeSellerPassword(int sellerId, String currentPassword,
                                       String newPassword, String confirmPassword) {
        if (newPassword == null || newPassword.length() < 6) {
            return "Mat khau moi phai co it nhat 6 ky tu.";
        }
        if (!newPassword.equals(confirmPassword)) {
            return "Xac nhan mat khau khong khop.";
        }
        Seller s = sellerDao.findById(sellerId);
        if (s == null) return "Khong tim thay tai khoan.";
        if (!currentPassword.equals(s.getPasswordHash())) {
            return "Mat khau hien tai khong dung.";
        }
        boolean ok = sellerDao.updatePassword(sellerId, newPassword);
        return ok ? null : "Doi mat khau that bai. Vui long thu lai.";
    }

    public Customer getCustomerById(int id) {
        return customerDao.findById(id);
    }

    public Seller getSellerById(int id) {
        return sellerDao.findById(id);
    }

    public static String hashPassword(String plain) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(plain.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) sb.append('0');
                sb.append(hex);
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 not available", e);
        }
    }
}
