package service;

import dao.AccountDAO;
import model.Account;

public class AccountService {

    private AccountDAO dao = new AccountDAO();

    public Account login(String username, String password) {

        // Validate basic
        if (username == null || username.trim().isEmpty()) {
            return null;
        }
        if (password == null || password.trim().isEmpty()) {
            return null;
        }

        // Lấy dữ liệu từ DB (DAO)
        Account account = dao.findByUsernameOrEmail(username);
        
        // Kiểm tra (Logic)
        if (account != null && account.getPasswordHash().equals(password)) {
            return account;
        }
        
        return null;
    }
}
