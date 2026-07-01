package Utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DbContext {

    private static final String DB_URL = "jdbc:sqlserver://localhost\\SQLEXPRESS;"
            + "databaseName=SENAFRUIT;"
            + "encrypt=false;"
            + "trustServerCertificate=true;"
            + "loginTimeout=30;"
            + "socketTimeout=60;"
            + "sendStringParametersAsUnicode=true;";
    private static final String DB_USER = "sa";
    private static final String DB_PASS = "123";

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            System.out.println("SQL Server JDBC Driver loaded.");
        } catch (ClassNotFoundException ex) {
            throw new RuntimeException(
                "SQL Server JDBC Driver not found! Please add mssql-jdbc.jar to your classpath.", ex);
        }
    }

    protected Connection createConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }

    protected Connection getConnection() throws SQLException {
        return createConnection();
    }

    public boolean isConnected() {
        try (Connection conn = createConnection()) {
            return conn != null && conn.isValid(2);
        } catch (SQLException e) {
            return false;
        }
    }
    
    public void close() {
    }
}
