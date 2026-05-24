/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import Utils.DbContext;
import model.Customer;
import java.sql.*;
/**
 *
 * @author Doan PC
 */
public class CustomerDAO {
    public Customer login(String username, String password) {

        String sql = "SELECT * FROM Customers WHERE username = ? AND password_hash = ? AND status = 1 AND isDelete = 0";

        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return new Customer(
                        rs.getInt("id"),
                        rs.getString("fullname"),
                        rs.getString("username"),
                        rs.getString("password_hash"),
                        rs.getString("email"),
                        rs.getInt("status")
                );
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}
