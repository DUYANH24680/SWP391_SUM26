package service;

import dao.AccountDAO;
import model.Account;

public class AccountService {

    private AccountDAO dao = new AccountDAO();

    public Account login(String username, String password) {

        if (username == null || username.trim().isEmpty()) {
            return null;
        }
        if (password == null || password.trim().isEmpty()) {
            return null;
        }

        Account account = dao.findByUsernameOrEmail(username);

        if (account != null && account.getPasswordHash().equals(UserService.hashPassword(password))) {
            return account;
        }

        return null;
    }
}
