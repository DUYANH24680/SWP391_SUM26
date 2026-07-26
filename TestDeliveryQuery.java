import java.sql.*;
public class TestDeliveryQuery {
    public static void main(String[] args) throws Exception {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        String url = "jdbc:sqlserver://localhost\\SQLEXPRESS;databaseName=SENAFRUIT;encrypt=false;trustServerCertificate=true;";
        Connection c = DriverManager.getConnection(url, "sa", "123456");
        String sql = "SELECT d.*, s.fullname AS shipper_name, s.phone AS shipper_phone, a.fullname AS assigned_by_name, o.status AS order_status, o.final_cost, o.recipient_name, o.recipient_phone, o.address AS delivery_address, o.note AS customer_note, (SELECT TOP 1 t.description FROM OrderTracking t WHERE t.delivery_id = d.delivery_id AND (t.status = 'delivery_completed' OR t.status = '5') AND t.description NOT LIKE N'Giao hàng thành công%') AS shipper_completion_note FROM DeliveryOrders d LEFT JOIN Accounts s ON d.shipper_id = s.id JOIN Accounts a ON d.assigned_by = a.id JOIN Orders o ON d.order_id = o.id WHERE d.shipper_id = 1 ORDER BY d.assigned_date DESC";
        try (PreparedStatement ps = c.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            ResultSetMetaData md = rs.getMetaData();
            int n = md.getColumnCount();
            System.out.println("Columns:" + n);
            for (int i = 1; i <= n; i++) {
                System.out.println(i + ": " + md.getColumnName(i) + " (" + md.getColumnTypeName(i) + ")");
            }
            if (rs.next()) {
                System.out.println("shipper_completion_note getString: " + rs.getString("shipper_completion_note"));
            }
        }
    }
}
