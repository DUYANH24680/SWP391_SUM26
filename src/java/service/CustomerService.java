/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.CustomerDAO;
import model.Customer;

/**
 *
 * @author Doan PC
 */
public class CustomerService {

    private CustomerDAO dao = new CustomerDAO();

    public Customer login(String username, String password) {

        // Validate basic
        if (username == null || username.trim().isEmpty()) {
            return null;
        }
        if (password == null || password.trim().isEmpty()) {
            return null;
        }

        // Lấy dữ liệu từ DB (DAO)
        Customer customer = dao.findByUsernameOrEmail(username);
        
        // Kiểm tra (Logic)
        if (customer != null && Utils.PasswordHashUtil.checkPassword(password, customer.getPasswordHash())) {
            return customer;
        }
        
        return null;
    }
}
