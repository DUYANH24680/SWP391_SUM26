package Utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DbContext {

    private static final String USER = "sa";
    private static final String PASS = "123";
    private static final String URL = "jdbc:sqlserver://localhost:1433;"
            + "databaseName=FruitShopSystem;"
            + "encrypt=false;"
            + "trustServerCertificate=true;"
            + "loginTimeout=30";

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(
                "SQL Server JDBC Driver not found! Please add mssql-jdbc.jar to your classpath.", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }

    public static void close(Connection conn) {
        if (conn != null) {
            try {
                if (!conn.isClosed()) {
                    conn.close();
                }
            } catch (SQLException ignored) {
            }
        }
    }

    public static void main(String[] args) {
        try (Connection conn = getConnection()) {
            System.out.println(conn.isValid(5)
                ? "Database connection established successfully."
                : "Failed to connect.");
        } catch (SQLException e) {
            System.out.println("DB Connection FAILED: " + e.getMessage());
        }
    }
}
