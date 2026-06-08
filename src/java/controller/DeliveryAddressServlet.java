package controller;

// Import thư mục chứa Data Access Object để làm việc với DB
import dao.DeliveryAddressDAO;
// Import các thư viện dùng cho Servlet
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
// Import Model để tương tác với Object
import model.User;
import model.DeliveryAddress;

// Import IO để xử lý ngoại lệ đầu vào/đầu ra
import java.io.IOException;

/**
 * DeliveryAddressServlet: Servlet chịu trách nhiệm quản lý các thao tác thêm, sửa, xóa
 * đối với Sổ địa chỉ giao hàng của người dùng.
 * Endpoint: /delivery-address
 */
// Định nghĩa URL mapping cho file Servlet này, khi form POST tới /delivery-address nó sẽ chui vào đây
@WebServlet("/delivery-address")
// Kế thừa HttpServlet để biến class này thành 1 Servlet thực thụ có thể nhận Request/Response
public class DeliveryAddressServlet extends HttpServlet {
    
    // Khởi tạo đối tượng DAO dùng chung cho toàn bộ Servlet để tương tác với Database
    private final DeliveryAddressDAO deliveryAddressDAO = new DeliveryAddressDAO();

    // Ghi đè phương thức doPost vì form của chúng ta gửi data bằng method="POST"
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Lấy Session hiện tại (phiên làm việc của người dùng)
        HttpSession session = req.getSession();
        
        // Lấy object 'user' (Tài khoản đang đăng nhập) từ trong session ra, ép kiểu về class User
        User user = (User) session.getAttribute("user");
        
        // Nếu user bằng null nghĩa là khách chưa đăng nhập hoặc session đã hết hạn
        if (user == null) {
            // Đẩy họ về lại trang đăng nhập
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            // Lệnh return để lập tức thoát khỏi hàm, không chạy phần code phía dưới nữa
            return;
        }

        // Lấy giá trị của input có name="action" (VD: action="add", "update", "delete")
        String action = req.getParameter("action");
        
        // Nếu không truyền action nào cả
        if (action == null) {
            // Bắn ngược về lại trang profile ở tab address
            resp.sendRedirect(req.getContextPath() + "/profile?tab=address");
            // Thoát khỏi hàm
            return;
        }

        // Mở khối try/catch để phòng trường hợp lỗi code, lỗi CSDL không làm sập web
        try {
            // Dựa vào tham số 'action' từ form để quyết định gọi hàm xử lý tương ứng
            switch (action) {
                // Nếu action là add thì nhảy vào case này
                case "add":
                    // Gọi hàm con chuyên xử lý insert
                    handleAddAddress(req, session, user);
                    // Thoát khỏi switch
                    break;
                // Nếu action là update
                case "update":
                    // Gọi hàm con chuyên xử lý update
                    handleUpdateAddress(req, session, user);
                    // Thoát khỏi switch
                    break;
                // Nếu action là delete
                case "delete":
                    // Gọi hàm con chuyên xử lý delete
                    handleDeleteAddress(req, session, user);
                    // Thoát khỏi switch
                    break;
            }
        } catch (Exception e) {
            // Bắt lỗi, lưu nguyên nhân lỗi e.getMessage() vào attribute "error" của session để hiển thị cho UI
            session.setAttribute("error", "Đã xảy ra lỗi: " + e.getMessage());
        }

        // Cuối cùng, luôn luôn điều hướng (redirect) người dùng về lại trang Profile kèm theo tham số mở sẵn tab address
        resp.sendRedirect(req.getContextPath() + "/profile?tab=address");
    }

    /**
     * Hàm xử lý Thêm địa chỉ mới
     * Lấy dữ liệu từ form, tạo đối tượng DeliveryAddress và lưu vào DB.
     */
    // Định nghĩa hàm truyền vào 3 tham số: req, session, và user hiện tại
    private void handleAddAddress(HttpServletRequest req, HttpSession session, User user) {
        // Lấy ô Tên người nhận (name="recipientName")
        String recipientName = req.getParameter("recipientName");
        // Lấy ô Số điện thoại (name="recipientPhone")
        String recipientPhone = req.getParameter("recipientPhone");
        // Lấy ô Địa chỉ (name="address")
        String address = req.getParameter("address");
        // Lấy ô Ghi chú (name="note")
        String note = req.getParameter("note");

        // Tạo 1 đối tượng DeliveryAddress trống rỗng
        DeliveryAddress da = new DeliveryAddress();
        // Cắm ID của khách hàng đang đăng nhập vào đối tượng
        da.setCustomerId(user.getId());
        // Cắm tên người nhận
        da.setRecipientName(recipientName);
        // Cắm số điện thoại
        da.setRecipientPhone(recipientPhone);
        // Cắm địa chỉ chi tiết
        da.setAddress(address);
        // Cắm ghi chú, nếu ghi chú null thì set thành chuỗi rỗng ""
        da.setNote(note != null ? note : "");
        // Đã bỏ chức năng mặc định nên luôn set là false
        da.setIsDefault(false); 

        // Truyền nguyên đối tượng 'da' này xuống cho DAO chạy lệnh SQL INSERT INTO. Hàm trả về boolean.
        if (deliveryAddressDAO.insert(da)) {
            // Nếu insert true (thành công) thì lưu thông báo màu xanh lên session
            session.setAttribute("message", "Thêm địa chỉ giao hàng thành công!");
        } else {
            // Nếu false (thất bại) thì lưu thông báo lỗi màu đỏ lên session
            session.setAttribute("error", "Không thể thêm địa chỉ giao hàng.");
        }
    }

    /**
     * Hàm xử lý Cập nhật địa chỉ đã có
     * Tìm địa chỉ theo ID và CustomerID (để đảm bảo tính bảo mật), cập nhật thông tin và lưu lại.
     */
    private void handleUpdateAddress(HttpServletRequest req, HttpSession session, User user) {
        // Lấy ID của cái địa chỉ cần sửa và ép kiểu về int. (VD: "5" -> số 5)
        int id = Integer.parseInt(req.getParameter("id"));
        
        // Lấy Tên mới
        String recipientName = req.getParameter("recipientName");
        // Lấy SĐT mới
        String recipientPhone = req.getParameter("recipientPhone");
        // Lấy Địa chỉ mới
        String address = req.getParameter("address");
        // Lấy Ghi chú mới
        String note = req.getParameter("note");

        // Verify ownership (kiểm tra xem địa chỉ này có đúng là của user đang đăng nhập không bằng cách truyền id và customer_id)
        DeliveryAddress existing = deliveryAddressDAO.findByIdAndCustomer(id, user.getId());
        
        // Nếu trong DB không có (existing = null)
        if (existing == null) {
            // Báo lỗi hack hoặc địa chỉ không tồn tại
            session.setAttribute("error", "Không tìm thấy địa chỉ này.");
            // Dừng lại
            return;
        }

        // Thay đổi Tên của cái địa chỉ cũ bằng tên mới
        existing.setRecipientName(recipientName);
        // Đổi SĐT mới
        existing.setRecipientPhone(recipientPhone);
        // Đổi địa chỉ mới
        existing.setAddress(address);
        // Đổi ghi chú mới
        existing.setNote(note != null ? note : "");
        // Bỏ chức năng mặc định
        existing.setIsDefault(false); 

        // Gửi nguyên cái cục Object existing (đã bị sửa) xuống DAO để nó chạy lệnh UPDATE SET...
        if (deliveryAddressDAO.update(existing)) {
            // Nếu thành công hiện thông báo này
            session.setAttribute("message", "Cập nhật địa chỉ thành công!");
        } else {
            // Nếu thất bại hiện thông báo này
            session.setAttribute("error", "Không thể cập nhật địa chỉ.");
        }
    }

    /**
     * Hàm xử lý Xóa địa chỉ
     * Xóa địa chỉ theo ID và CustomerID.
     */
    private void handleDeleteAddress(HttpServletRequest req, HttpSession session, User user) {
        // Lấy ID của thẻ địa chỉ mà khách bấm nút Xóa
        int id = Integer.parseInt(req.getParameter("id"));
        
        // Đưa ID địa chỉ và ID người dùng xuống DAO để thực thi lệnh DELETE FROM...
        if (deliveryAddressDAO.delete(id, user.getId())) {
            // Trả về true thì báo xóa thành công
            session.setAttribute("message", "Xóa địa chỉ thành công!");
        } else {
            // Báo lỗi nếu xóa xịt
            session.setAttribute("error", "Không thể xóa địa chỉ. Có thể địa chỉ này không tồn tại.");
        }
    }
}
