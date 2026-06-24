/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 *
 * @author DELL
 */
public class DbContext {
    
    protected Connection connection;
    private static final String DB_URL = "jdbc:sqlserver://localhost\\SQLEXPRESS;"
            + "databaseName=SENAFRUIT;"
            + "encrypt=false;"
            + "trustServerCertificate=true;"
            + "loginTimeout=30;"
            + "socketTimeout=60;"
            + "sendStringParametersAsUnicode=true;";
    private static final String DB_USER = "sa";
    private static final String DB_PASS = "123456";

    public DbContext() {
        try {
            // Load SQL Server JDBC Driver
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            connection = createConnection();
            System.out.println("Database connection established successfully.");
        } catch (ClassNotFoundException ex) {
            throw new RuntimeException(
                "SQL Server JDBC Driver not found! Please add mssql-jdbc.jar to your classpath.", ex);
        } catch (Exception ex) {
            throw new RuntimeException(
                "DB Connection FAILED! " + ex.getMessage()
                + " | Check: 1) SQL Server is running, "
                + "2) Database 'SENAFRUIT' exists, "
                + "3) sa password='123456' is correct, "
                + "4) SQL Server is listening on port 1433", ex);
        }
    }

    protected Connection createConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }

    protected Connection getConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            connection = createConnection();
        }
        return connection;
    }

    public boolean isConnected() {
        try {
            return connection != null && !connection.isClosed();
        } catch (SQLException e) {
            return false;
        }
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
