package Utils;

import java.sql.*;

public class DbContext {

    public static Connection getConnection() {

        try {

            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

            String url
                    = "jdbc:sqlserver://localhost:1433;"
                    + "databaseName=FruitShopSystem;"
                    + "encrypt=true;"
                    + "trustServerCertificate=true";

            return DriverManager.getConnection(url, "sa", "123456");

        } catch (Exception e) {

            e.printStackTrace();

        }

        return null;

    }

}
