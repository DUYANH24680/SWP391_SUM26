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
import service.NotificationService;

import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;

@WebServlet(name = "ManageVoucherServlet", urlPatterns = {"/manage-vouchers"})
public class ManageVoucherServlet extends HttpServlet {

    private NotificationService notifService = new NotificationService();
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

        // DuyAnhNgo- Chỉ cho phép Admin hoặc Seller truy cập trang quản lý Voucher
        if (!"admin".equalsIgnoreCase(role) && !"seller".equalsIgnoreCase(role)) {
            session.setAttribute("error", "Bạn không có quyền truy cập trang này.");
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        VoucherDAO voucherDAO = new VoucherDAO();
        try {
            List<Voucher> vouchers;
            // DuyAnhNgo- Nếu là Admin: Lấy danh sách toàn bộ Voucher của hệ thống (shop_id = NULL)
            if ("admin".equalsIgnoreCase(role)) {
                vouchers = voucherDAO.getGlobalVouchers();
                request.setAttribute("isGlobal", true);
            } else {
                // DuyAnhNgo- Nếu là Seller: Tìm ID của Shop thuộc về Seller này
                ShopDAO shopDAO = new ShopDAO();
                Shop shop = shopDAO.getShopByOwnerId(account.getId());
                shopDAO.close();
                
                // DuyAnhNgo- Nếu chưa tạo Shop hợp lệ, chặn không cho tạo Voucher
                if (shop == null || shop.getStatus() != 1) {
                    session.setAttribute("error", "Bạn chưa có shop hợp lệ để tạo voucher.");
                    response.sendRedirect(request.getContextPath() + "/seller-dashboard");
                    return;
                }
                // DuyAnhNgo- Chỉ lấy danh sách Voucher thuộc về Shop này
                vouchers = voucherDAO.getVouchersByShop(shop.getId());
                request.setAttribute("isGlobal", false);
                request.setAttribute("shopId", shop.getId());
            }

            // DuyAnhNgo- Trả dữ liệu hiển thị về trang manage-vouchers.jsp
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
            // DuyAnhNgo- Xác định shopId nếu người đang thao tác là Seller
            if ("seller".equalsIgnoreCase(role)) {
                ShopDAO shopDAO = new ShopDAO();
                Shop shop = shopDAO.getShopByOwnerId(account.getId());
                shopDAO.close();
                if (shop != null) {
                    shopId = shop.getId();
                }
            }

            // DuyAnhNgo- Nhận request gửi lên. Nếu action là create/update thì xử lý:
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

                // DuyAnhNgo- Đóng gói dữ liệu từ các form input HTML vào đối tượng Voucher
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
                    // DuyAnhNgo- Check Validation: Kiểm tra mã trùng lặp trong DB trước khi tạo mới
                    Voucher existing = voucherDAO.findByCode(v.getCode());
                    if (existing != null) {
                        session.setAttribute("error", "Mã voucher đã tồn tại.");
                        response.sendRedirect("manage-vouchers");
                        return;
                    }
                    voucherDAO.insertVoucher(v);
                    session.setAttribute("message", "Tạo voucher thành công!");

                    // Gửi thông báo đến tất cả customers
                    try {
                        String shopName = null;
                        if (shopId != null) {
                            ShopDAO sDAO = new ShopDAO();
                            Shop s = sDAO.getShopById(shopId);
                            sDAO.close();
                            if (s != null) shopName = s.getShopName();
                        }
                        String discountInfo;
                        if ("FREESHIP".equalsIgnoreCase(type)) {
                            discountInfo = "Miễn phí vận chuyển";
                        } else {
                            discountInfo = (int) discountPercent + "% giảm tối đa " + String.format("%,.0f", maxDiscount) + "đ";
                        }
                        notifService.notifyNewVoucher(v.getCode(), shopName, discountInfo);
                    } catch (Exception ex) {
                        System.err.println("[ManageVoucherServlet] notifyNewVoucher error: " + ex.getMessage());
                    }
                } else {
                    voucherDAO.updateVoucher(v);
                    session.setAttribute("message", "Cập nhật voucher thành công!");
                }
            } else if ("delete".equals(action)) {
                // DuyAnhNgo- Logic Xóa: Kiểm tra ID người gọi lệnh xóa có khớp với quyền sở hữu voucher không
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
