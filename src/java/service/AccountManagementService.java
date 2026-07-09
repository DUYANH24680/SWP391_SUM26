package service;

import dao.AccountDAO;
import dao.OrderDAO;
import model.Account;
import model.Order;

import java.util.List;

public class AccountManagementService {

    // ===================== Customer List =====================

    public CustomerListResult getCustomerList(String keyword) {
        AccountDAO dao = new AccountDAO();
        try {
            List<Account> customers;
            if (keyword != null && !keyword.trim().isEmpty()) {
                customers = dao.searchAccountsByRole("customer", keyword.trim());
            } else {
                customers = dao.getAccountsByRole("customer");
            }

            OrderDAO orderDAO = new OrderDAO();
            try {
                for (Account c : customers) {
                    List<Order> orders = orderDAO.getOrdersByCustomerId(c.getId());
                    c.setExtra("orderCount", orders.size());
                }
            } finally {
                orderDAO.close();
            }

            return new CustomerListResult(customers, customers.size());
        } finally {
            dao.close();
        }
    }

    // ===================== Customer Order History =====================

    public CustomerOrderHistoryResult getCustomerOrderHistory(int customerId) {
        AccountDAO accountDAO = new AccountDAO();
        try {
            Account customer = accountDAO.findByIdIncludeAll(customerId);
            if (customer == null || !"customer".equals(customer.getRoleName())) {
                return CustomerOrderHistoryResult.notFound();
            }

            OrderDAO orderDAO = new OrderDAO();
            try {
                List<Order> orders = orderDAO.getOrdersByCustomerId(customerId);
                return CustomerOrderHistoryResult.success(customer, orders);
            } finally {
                orderDAO.close();
            }
        } finally {
            accountDAO.close();
        }
    }

    // ===================== Toggle Account Status =====================

    public ToggleStatusResult toggleAccountStatus(int accountId, Integer currentUserId) {
        AccountDAO dao = new AccountDAO();
        try {
            Account acc = dao.findByIdIncludeAll(accountId);
            if (acc == null) {
                return ToggleStatusResult.failure("Không tìm thấy tài khoản.");
            }
            if (!"customer".equals(acc.getRoleName())) {
                return ToggleStatusResult.failure("Chỉ có thể khóa/mở khóa tài khoản khách hàng.");
            }
            if (currentUserId != null && currentUserId == accountId) {
                return ToggleStatusResult.failure("Bạn không thể khóa chính mình.");
            }

            int newStatus = (acc.getStatus() == 1) ? 0 : 1;
            boolean success = dao.updateAccountStatus(accountId, newStatus);
            if (!success) {
                return ToggleStatusResult.failure("Không thể cập nhật trạng thái tài khoản.");
            }
            String action = (newStatus == 0) ? "khóa" : "mở khóa";
            return ToggleStatusResult.success("Đã " + action + " tài khoản thành công.");
        } finally {
            dao.close();
        }
    }

    // ===================== Result Models =====================

    public static class CustomerListResult {
        private final List<Account> customers;
        private final int totalCount;

        public CustomerListResult(List<Account> customers, int totalCount) {
            this.customers = customers;
            this.totalCount = totalCount;
        }

        public List<Account> getCustomers() { return customers; }
        public int getTotalCount() { return totalCount; }
    }

    public static class CustomerOrderHistoryResult {
        private final boolean found;
        private final Account customer;
        private final List<Order> orders;

        private CustomerOrderHistoryResult(boolean found, Account customer, List<Order> orders) {
            this.found = found;
            this.customer = customer;
            this.orders = orders;
        }

        public static CustomerOrderHistoryResult notFound() {
            return new CustomerOrderHistoryResult(false, null, null);
        }

        public static CustomerOrderHistoryResult success(Account customer, List<Order> orders) {
            return new CustomerOrderHistoryResult(true, customer, orders);
        }

        public boolean isFound() { return found; }
        public Account getCustomer() { return customer; }
        public List<Order> getOrders() { return orders; }
    }

    public static class ToggleStatusResult {
        private final boolean success;
        private final String message;

        private ToggleStatusResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public static ToggleStatusResult success(String message) {
            return new ToggleStatusResult(true, message);
        }

        public static ToggleStatusResult failure(String message) {
            return new ToggleStatusResult(false, message);
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
    }
}
