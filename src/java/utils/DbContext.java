/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Utils;

import java.sql.Connection;
import java.sql.DriverManager;

/**
 *
 * @author DELL
 */
public class DbContext {
    
    protected Connection connection;
    public DbContext() {
        try {
            // Load SQL Server JDBC Driver
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            
            String user = "sa";
            String pass = "123";
            String url = "jdbc:sqlserver://localhost\\SQLEXPRESS;"
           + "databaseName=FruitShopSystem;"
           + "encrypt=true;"
           + "trustServerCertificate=true";

            connection = DriverManager.getConnection(url, user, pass);
            System.out.println("Database connection established successfully.");
        } catch (ClassNotFoundException ex) {
            throw new RuntimeException(
                "SQL Server JDBC Driver not found! Please add mssql-jdbc.jar to your classpath.", ex);
        } catch (Exception ex) {
            throw new RuntimeException(
                "DB Connection FAILED! " + ex.getMessage()
                + " | Check: 1) SQL Server is running, "
                + "2) Database 'FruitShopSystem' exists, "
                + "3) sa password='123' is correct, "
                + "4) SQL Server is listening on port 1433", ex);
        }
    }

    public boolean isConnected() {
        return connection != null;
    }
    
    public void close() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (Exception e) {
            // silently ignore
        }
    }

    public static void main(String[] args) {
        DbContext dbContext = new DbContext();
        try{
            if (dbContext.isConnected()) {
            System.out.println("Successfully connected");
        } else {
            System.out.println("Failed to connected");
        }
        }
        catch(Exception ex)
        {
            System.out.println(ex);
        }
    }
}