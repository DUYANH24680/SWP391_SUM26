package service;

import dao.CustomerDAO;
import model.Customer;

/**
 * Business logic for customer login and registration.
 */
public class CustomerService {

    private static final String CUSTOMER_ROLE_NAME = "user";

    public Customer login(String username, String password) {
        CustomerDAO dao = new CustomerDAO();
        try {
            if (username == null || username.trim().isEmpty()) {
                return null;
            }
            if (password == null || password.trim().isEmpty()) {
                return null;
            }

            Customer customer = dao.findByUsernameOrEmail(username.trim());
            if (customer == null) {
                return null;
            }

            String hashedInput = UserService.hashPassword(password);
            String stored = customer.getPasswordHash();
            if (stored.equals(hashedInput) || stored.equals(password)) {
                return customer;
            }

            return null;
        } finally {
            dao.close();
        }
    }

    /**
     * Register a new customer. Returns null on success, or an error message.
     */
    public String register(String fullname, String email, String password,
                           String confirmPassword, String phone) {
        CustomerDAO dao = new CustomerDAO();
        try {
            if (fullname == null || fullname.trim().isEmpty()) {
                return "Họ và tên không được để trống.";
            }
            if (fullname.trim().length() < 2) {
                return "Họ và tên phải có ít nhất 2 ký tự.";
            }
            if (email == null || email.trim().isEmpty()) {
                return "Email không được để trống.";
            }
            email = email.trim().toLowerCase();
            if (!email.matches("^[\\w.+-]+@[\\w.-]+\\.[a-zA-Z]{2,}$")) {
                return "Email không đúng định dạng.";
            }
            if (password == null || password.isEmpty()) {
                return "Mật khẩu không được để trống.";
            }
            if (password.length() < 6) {
                return "Mật khẩu phải có ít nhất 6 ký tự.";
            }
            if (!password.equals(confirmPassword)) {
                return "Xác nhận mật khẩu không khớp.";
            }
            if (phone == null || phone.trim().isEmpty()) {
                return "Số điện thoại không được để trống.";
            }
            phone = phone.trim();
            if (!phone.matches("^[0-9]{9,11}$")) {
                return "Số điện thoại không hợp lệ (9-11 chữ số).";
            }

            if (dao.existsByEmail(email)) {
                return "Email này đã được sử dụng. Vui lòng chọn email khác.";
            }

            int roleId = dao.findRoleIdByName(CUSTOMER_ROLE_NAME);
            if (roleId < 0) {
                return "Lỗi";
            }

            String username = generateUniqueUsername(dao, email);
            String passwordHash = UserService.hashPassword(password);

            boolean ok = dao.insertUser(
                    roleId,
                    fullname.trim(),
                    username,
                    passwordHash,
                    email,
                    phone
            );
            return ok ? null : "Đăng ký thất bại. Vui lòng thử lại.";
        } finally {
            dao.close();
        }
    }

    private String generateUniqueUsername(CustomerDAO dao, String email) {
        int at = email.indexOf('@');
        String base = at > 0 ? email.substring(0, at) : email;
        base = base.replaceAll("[^a-zA-Z0-9_]", "");
        if (base.isEmpty()) {
            base = "user";
        }
        if (base.length() > 50) {
            base = base.substring(0, 50);
        }

<<<<<<< HEAD
        String username = base;
        int suffix = 1;
        while (dao.existsByUsername(username)) {
            username = base + suffix++;
        }
        return username;
=======
        // Lấy dữ liệu từ DB (DAO)
        Customer customer = dao.findByUsernameOrEmail(username);

        // Kiểm tra (Logic) - so sánh SHA-256 hash của mật khẩu nhập vào với hash trong DB
        if (customer != null && customer.getPasswordHash().equals(UserService.hashPassword(password))) {
            return customer;
        }

        return null;
>>>>>>> main
    }
}
