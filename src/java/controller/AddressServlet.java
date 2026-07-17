package controller;
//DUy Anh
import dao.DeliveryAddressDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.DeliveryAddress;

import java.io.IOException;
import java.util.List;

@WebServlet("/address")
public class AddressServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // DuyAnhNgo- Logic hiển thị Sổ Địa Chỉ: Khi người dùng vào trang /address
        // Hệ thống sẽ kiểm tra đăng nhập, sau đó gọi DAO lấy danh sách địa chỉ rồi truyền qua JSP hiển thị
        HttpSession session = req.getSession(true);
        Account user = (Account) session.getAttribute("Account");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        DeliveryAddressDAO dao = new DeliveryAddressDAO();
        List<DeliveryAddress> addresses = dao.findByCustomerId(user.getId());
        req.setAttribute("addresses", addresses);

        req.getRequestDispatcher("/address.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // DuyAnhNgo- Logic xử lý các thao tác của Sổ Địa Chỉ: Thêm, Sửa, Xóa, Đặt mặc định
        // Nhận action từ form gửi lên và gọi các hàm tương ứng bên dưới
        HttpSession session = req.getSession(true);
        Account user = (Account) session.getAttribute("Account");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/address");
            return;
        }

        switch (action) {
            case "addAddress":
                handleAddAddress(req, session, user);
                break;
            case "updateAddress":
                handleUpdateAddress(req, session, user);
                break;
            case "deleteAddress":
                handleDeleteAddress(req, session, user);
                break;
            case "setDefaultAddress":
                handleSetDefaultAddress(req, session, user);
                break;
        }

        resp.sendRedirect(req.getContextPath() + "/address");
    }

    // DuyAnhNgo- Hàm Xử lý Thêm Địa Chỉ: Lấy dữ liệu từ form, đóng gói thành object rồi gọi DeliveryAddressDAO (hàm insert) để lưu vào DB
    private void handleAddAddress(HttpServletRequest req, HttpSession session, Account user) {
        String name = req.getParameter("recipientName");
        String phone = req.getParameter("recipientPhone");
        String address = req.getParameter("address");
        String note = req.getParameter("note");
        boolean isDefault = "on".equals(req.getParameter("isDefault"));

        DeliveryAddress da = new DeliveryAddress();
        da.setCustomerId(user.getId());
        da.setRecipientName(name);
        da.setRecipientPhone(phone);
        da.setAddress(address);
        da.setNote(note);
        da.setIsDefault(isDefault);

        DeliveryAddressDAO dao = new DeliveryAddressDAO();
        if (dao.insert(da)) {
            session.setAttribute("message", "Thêm địa chỉ thành công!");
        } else {
            session.setAttribute("error", "Lỗi khi thêm địa chỉ!");
        }
    }

    // DuyAnhNgo- Hàm Xử lý Cập Nhật Địa Chỉ: Tương tự Thêm mới, nhưng gọi DeliveryAddressDAO (hàm update) kèm ID địa chỉ cũ để UPDATE trong DB
    private void handleUpdateAddress(HttpServletRequest req, HttpSession session, Account user) {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            String name = req.getParameter("recipientName");
            String phone = req.getParameter("recipientPhone");
            String address = req.getParameter("address");
            String note = req.getParameter("note");
            boolean isDefault = "on".equals(req.getParameter("isDefault"));

            DeliveryAddress da = new DeliveryAddress();
            da.setId(id);
            da.setCustomerId(user.getId());
            da.setRecipientName(name);
            da.setRecipientPhone(phone);
            da.setAddress(address);
            da.setNote(note);
            da.setIsDefault(isDefault);

            DeliveryAddressDAO dao = new DeliveryAddressDAO();
            if (dao.update(da)) {
                if (isDefault) {
                    dao.setDefault(id, user.getId());
                }
                session.setAttribute("message", "Cập nhật địa chỉ thành công!");
            } else {
                session.setAttribute("error", "Lỗi khi cập nhật địa chỉ!");
            }
        } catch (Exception e) {
            session.setAttribute("error", "Dữ liệu không hợp lệ!");
        }
    }

    // DuyAnhNgo- Hàm Xử lý Xóa Địa Chỉ: Lấy ID từ giao diện, gọi DeliveryAddressDAO (hàm delete) thực thi lệnh DELETE
    private void handleDeleteAddress(HttpServletRequest req, HttpSession session, Account user) {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            DeliveryAddressDAO dao = new DeliveryAddressDAO();
            if (dao.delete(id, user.getId())) {
                session.setAttribute("message", "Đã xóa địa chỉ!");
            } else {
                session.setAttribute("error", "Không thể xóa địa chỉ này!");
            }
        } catch (Exception e) {
            session.setAttribute("error", "Dữ liệu không hợp lệ!");
        }
    }

    // DuyAnhNgo- Hàm Xử lý Đặt Mặc Định: Lấy ID địa chỉ cần ưu tiên, gọi DeliveryAddressDAO (hàm setDefault), các địa chỉ khác tự động về 0
    private void handleSetDefaultAddress(HttpServletRequest req, HttpSession session, Account user) {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            DeliveryAddressDAO dao = new DeliveryAddressDAO();
            if (dao.setDefault(id, user.getId())) {
                session.setAttribute("message", "Đã đặt làm địa chỉ mặc định!");
            } else {
                session.setAttribute("error", "Không thể đặt mặc định!");
            }
        } catch (Exception e) {
            session.setAttribute("error", "Dữ liệu không hợp lệ!");
        }
    }
}
