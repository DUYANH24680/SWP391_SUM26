package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

import dao.ShopRequestDAO;
import dao.AccountDAO;
import model.Account;
import service.NotificationService;

/**
 * Allow logged-in customers to apply for a seller account.
 * GET  → show registration form
 * POST → validate + insert ShopRequests record (status=0), redirect on success
 */
@WebServlet(name = "RegisterSellerServlet", urlPatterns = {"/register-seller"})
public class RegisterSellerServlet extends HttpServlet {

    private final ShopRequestDAO dao = new ShopRequestDAO();
    private final AccountDAO accountDao = new AccountDAO();
    private final NotificationService notifService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Account user = (Account) session.getAttribute("user");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // Prevent seller/admin from accessing
        if ("seller".equals(user.getRoleName()) || "admin".equals(user.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        // Load existing request status (if any)
        var existing = dao.getByAccountId(user.getId());
        req.setAttribute("existingRequest", existing);
        req.getRequestDispatcher("/register-seller.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Account user = (Account) session.getAttribute("user");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String shopName     = req.getParameter("shopName");
        String description  = req.getParameter("description");
        String address      = req.getParameter("address");

        // ---- Validation ----
        if (shopName == null || shopName.trim().isEmpty()) {
            forwardWithError(req, resp, "Tên cửa hàng không được để trống.", shopName, description, address);
            return;
        }
        if (shopName.trim().length() < 3 || shopName.trim().length() > 100) {
            forwardWithError(req, resp, "Tên cửa hàng phải từ 3 đến 100 ký tự.", shopName, description, address);
            return;
        }
        if (address == null || address.trim().isEmpty()) {
            forwardWithError(req, resp, "Địa chỉ cửa hàng không được để trống.", shopName, description, address);
            return;
        }
        if (description != null && description.trim().length() > 1000) {
            forwardWithError(req, resp, "Mô tả không được vượt quá 1000 ký tự.", shopName, description, address);
            return;
        }

        // ---- Business rules ----
        if (dao.hasShop(user.getId())) {
            forwardWithError(req, resp, "Tài khoản này đã có cửa hàng.", shopName, description, address);
            return;
        }
        if (dao.hasPendingRequest(user.getId())) {
            forwardWithError(req, resp, "Bạn đã có một yêu cầu đang chờ duyệt. Vui lòng chờ Admin phê duyệt.", shopName, description, address);
            return;
        }

        // ---- Insert ----
        int newId = dao.insert(user.getId(), shopName.trim(), description, address);
        if (newId <= 0) {
            forwardWithError(req, resp, "Gửi yêu cầu thất bại. Vui lòng thử lại sau.", shopName, description, address);
            return;
        }

        // Notify all admins about new seller request
        var admins = accountDao.getAllAdmins();
        for (Account admin : admins) {
            notifService.notifyNewSellerRequest(admin.getId(), user.getFullname(), shopName.trim());
        }

        // ---- Success ----
        session.setAttribute("registerSellerSuccess",
                "Yêu cầu đăng ký đã được gửi! Vui lòng chờ Admin duyệt.");
        resp.sendRedirect(req.getContextPath() + "/register-seller");
    }

    private void forwardWithError(HttpServletRequest req, HttpServletResponse resp,
                                  String error, String shopName, String description, String address)
            throws ServletException, IOException {
        req.setAttribute("error", error);
        req.setAttribute("val_shopName",    shopName);
        req.setAttribute("val_description", description);
        req.setAttribute("val_address",     address);
        req.getRequestDispatcher("/register-seller.jsp").forward(req, resp);
    }
}
