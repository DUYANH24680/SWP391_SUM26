package controller;

import dao.ShopDAO;
import dao.VoucherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Shop;
import model.Voucher;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "VoucherPageServlet", urlPatterns = {"/vouchers"})
public class VoucherPageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // DuyAnhNgo- Lấy thông tin session hiện tại
        jakarta.servlet.http.HttpSession session = request.getSession(false);
        if (session != null) {
            model.Account account = (model.Account) session.getAttribute("Account");
            // DuyAnhNgo- Chặn quyền: Nếu là Admin hoặc Seller thì đẩy về trang chủ (chỉ hiển thị Voucher cho Khách hàng xem)
            if (account != null && ("admin".equalsIgnoreCase(account.getRoleName()) || "seller".equalsIgnoreCase(account.getRoleName()))) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        }

        VoucherDAO voucherDAO = new VoucherDAO();
        ShopDAO shopDAO = new ShopDAO();

        try {
            // DuyAnhNgo- Gọi DAO Lấy toàn bộ danh sách Voucher đang có hiệu lực (còn hạn, còn số lượng)
            List<Voucher> activeVouchers = voucherDAO.getAllActiveVouchers();
            Map<Integer, Shop> shopMap = new HashMap<>();

            // DuyAnhNgo- Lặp qua các voucher: Kiểm tra xem voucher đó thuộc Shop nào để lấy tên Shop hiển thị lên UI
            for (Voucher v : activeVouchers) {
                if (v.getShopId() != null && !shopMap.containsKey(v.getShopId())) {
                    Shop shop = shopDAO.getShopById(v.getShopId());
                    if (shop != null) {
                        shopMap.put(v.getShopId(), shop);
                    }
                }
            }

            // DuyAnhNgo- Đẩy dữ liệu qua request để trang JSP vẽ giao diện
            request.setAttribute("vouchers", activeVouchers);
            request.setAttribute("shopMap", shopMap);

            request.getRequestDispatcher("/vouchers.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home");
        } finally {
            voucherDAO.close();
            shopDAO.close();
        }
    }
}
