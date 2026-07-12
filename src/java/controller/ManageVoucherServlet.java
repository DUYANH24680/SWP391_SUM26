package controller;

import dao.ShopDAO;
import dao.VoucherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Shop;
import model.Voucher;

import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;

@WebServlet(name = "ManageVoucherServlet", urlPatterns = {"/manage-vouchers"})
public class ManageVoucherServlet extends HttpServlet {

    private Timestamp parseTimestamp(String dtStr) {
        if (dtStr == null || dtStr.trim().isEmpty()) {
            return null;
        }
        try {
            // HTML5 datetime-local format: yyyy-MM-dd'T'HH:mm
            LocalDateTime ldt = LocalDateTime.parse(dtStr.trim(), DateTimeFormatter.ISO_LOCAL_DATE_TIME);
            return Timestamp.valueOf(ldt);
        } catch (DateTimeParseException e) {
            // Try appending :00 if seconds are missing or handle other formats if needed
            try {
                LocalDateTime ldt = LocalDateTime.parse(dtStr.trim() + ":00", DateTimeFormatter.ISO_LOCAL_DATE_TIME);
                return Timestamp.valueOf(ldt);
            } catch (Exception ex) {
                return null;
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Account account = (Account) session.getAttribute("Account");
        String role = account.getRoleName();

        // 1. Chỉ cho phép Admin hoặc Seller truy cập trang quản lý Voucher
        if (!"admin".equalsIgnoreCase(role) && !"seller".equalsIgnoreCase(role)) {
            session.setAttribute("error", "Bạn không có quyền truy cập trang này.");
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        VoucherDAO voucherDAO = new VoucherDAO();
        try {
            List<Voucher> vouchers;
            // 2. Nếu là Admin: Lấy danh sách Voucher toàn hệ thống (shop_id = NULL)
            if ("admin".equalsIgnoreCase(role)) {
                vouchers = voucherDAO.getGlobalVouchers();
                request.setAttribute("isGlobal", true);
            } else {
                // 3. Nếu là Seller: Tìm ID của Shop thuộc về Seller này
                ShopDAO shopDAO = new ShopDAO();
                Shop shop = shopDAO.getShopByOwnerId(account.getId());
                shopDAO.close();
                
                // 4. Nếu chưa có Shop hợp lệ, không cho phép tạo Voucher
                if (shop == null || shop.getStatus() != 1) {
                    session.setAttribute("error", "Bạn chưa có shop hợp lệ để tạo voucher.");
                    response.sendRedirect(request.getContextPath() + "/seller-dashboard");
                    return;
                }
                // 5. Lấy danh sách Voucher chỉ thuộc về Shop này
                vouchers = voucherDAO.getVouchersByShop(shop.getId());
                request.setAttribute("isGlobal", false);
                request.setAttribute("shopId", shop.getId());
            }

            // 6. Trả dữ liệu về view manage-vouchers.jsp
            request.setAttribute("vouchers", vouchers);
            request.getRequestDispatcher("/manage-vouchers.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home");
        } finally {
            voucherDAO.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Account account = (Account) session.getAttribute("Account");
        String role = account.getRoleName();

        if (!"admin".equalsIgnoreCase(role) && !"seller".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String action = request.getParameter("action");
        VoucherDAO voucherDAO = new VoucherDAO();

        try {
            Integer shopId = null;
            // 7. Xác định shopId nếu người tạo là Seller
            if ("seller".equalsIgnoreCase(role)) {
                ShopDAO shopDAO = new ShopDAO();
                Shop shop = shopDAO.getShopByOwnerId(account.getId());
                shopDAO.close();
                if (shop != null) {
                    shopId = shop.getId();
                }
            }

            // 8. Xử lý tạo mới hoặc cập nhật Voucher
            if ("create".equals(action) || "update".equals(action)) {
                String idStr = request.getParameter("id");
                String code = request.getParameter("code");
                String type = request.getParameter("type");
                double discountPercent = Double.parseDouble(request.getParameter("discountPercent"));
                double maxDiscount = Double.parseDouble(request.getParameter("maxDiscount"));
                double minimumOrder = Double.parseDouble(request.getParameter("minimumOrder"));
                Timestamp startDate = parseTimestamp(request.getParameter("startDate"));
                Timestamp endDate = parseTimestamp(request.getParameter("endDate"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                int maxUsagesPerUser = Integer.parseInt(request.getParameter("maxUsagesPerUser"));
                boolean status = request.getParameter("status") != null;

                if (code == null || code.trim().isEmpty()) {
                    session.setAttribute("error", "Mã voucher không được để trống.");
                    response.sendRedirect("manage-vouchers");
                    return;
                }

                // 9. Đóng gói dữ liệu vào Model
                Voucher v = new Voucher();
                if ("update".equals(action) && idStr != null) {
                    v.setId(Integer.parseInt(idStr));
                }
                v.setShopId(shopId); // Admin thì shopId = NULL
                v.setCode(code.trim().toUpperCase()); // Luôn lưu mã dạng IN HOA
                v.setType(type); // 'DISCOUNT' hoặc 'FREESHIP'
                v.setDiscountPercent(discountPercent);
                v.setMaxDiscount(maxDiscount);
                v.setMinimumOrder(minimumOrder);
                v.setStartDate(startDate);
                v.setEndDate(endDate);
                v.setQuantity(quantity);
                v.setMaxUsagesPerUser(maxUsagesPerUser);
                v.setStatus(status);

                if ("create".equals(action)) {
                    // 10. Kiểm tra trùng lặp mã trước khi tạo
                    Voucher existing = voucherDAO.findByCode(v.getCode());
                    if (existing != null) {
                        session.setAttribute("error", "Mã voucher đã tồn tại.");
                        response.sendRedirect("manage-vouchers");
                        return;
                    }
                    voucherDAO.insertVoucher(v);
                    session.setAttribute("message", "Tạo voucher thành công!");
                } else {
                    voucherDAO.updateVoucher(v);
                    session.setAttribute("message", "Cập nhật voucher thành công!");
                }
            } else if ("delete".equals(action)) {
                // 11. Xử lý xóa Voucher (Chỉ Admin hoặc Seller sở hữu mới được xóa)
                int id = Integer.parseInt(request.getParameter("id"));
                Voucher v = voucherDAO.getVoucherById(id);
                if (v != null) {
                    if ("admin".equalsIgnoreCase(role) || (shopId != null && shopId.equals(v.getShopId()))) {
                        voucherDAO.deleteVoucher(id);
                        session.setAttribute("message", "Xóa voucher thành công!");
                    } else {
                        session.setAttribute("error", "Bạn không có quyền xóa voucher này.");
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
        } finally {
            voucherDAO.close();
        }

        response.sendRedirect("manage-vouchers");
    }
}
