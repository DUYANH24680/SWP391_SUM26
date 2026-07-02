package Utils;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DbContext {

    protected Connection connection;
    private static DataSource dataSource;
    private static String JDBC_URL = "jdbc:sqlserver://localhost:1433;databaseName=SENAFRUIT;encrypt=false;trustServerCertificate=true;loginTimeout=30";
    private static String JDBC_USER = "sa";
    private static String JDBC_PASSWORD = "123";

    public DbContext() {
        initDataSource();
    }

    private static volatile boolean dsInitAttempted = false;

    private void initDataSource() {
        if (dataSource != null || dsInitAttempted) {
            return;
        }
        synchronized (DbContext.class) {
            if (dataSource != null || dsInitAttempted) {
                return;
            }
            try {
                Context initContext = new InitialContext();
                Context envContext = (Context) initContext.lookup("java:comp/env");
                dataSource = (DataSource) envContext.lookup("jdbc/SENAFRUIT");

                if (dataSource == null) {
                    throw new RuntimeException(
                        "DataSource 'jdbc/SENAFRUIT' not found in JNDI. "
                        + "Check context.xml and make sure <Resource> is defined correctly.");
                }

                System.out.println("[DbContext] DataSource initialized successfully from JNDI.");
            } catch (NoClassDefFoundError | javax.naming.NoInitialContextException e) {
                // JNDI not available (standalone main / unit test) — fall back to direct JDBC
                System.out.println("[DbContext] JNDI not available, falling back to direct JDBC.");
                dsInitAttempted = true;
                dataSource = null;
            } catch (IllegalStateException e) {
                // Tomcat JDBC pool already cancelled (hot-reload / double init) — fall back to direct JDBC
                System.err.println("[DbContext] JNDI pool timer conflict, falling back to direct JDBC: " + e.getMessage());
                dsInitAttempted = true;
                dataSource = null;
            } catch (Exception e) {
                throw new RuntimeException(
                    "[DbContext] Failed to initialize DataSource from JNDI: " + e.getMessage()
                    + " | Check: 1) SQL Server is running, "
                    + "2) Database 'SENAFRUIT' exists, "
                    + "3) SQL Server is listening on port 1433", e);
            }
            dsInitAttempted = true;
        }
    }

    protected Connection createConnection() throws SQLException {
        if (dataSource != null) {
            return dataSource.getConnection();
        }
        // Standalone fallback: direct JDBC
        return DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
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
        try {
            Connection conn = dbContext.getConnection();
            System.out.println("Successfully connected to " + conn.getCatalog());
            dbContext.close();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}
