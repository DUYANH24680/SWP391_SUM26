package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import service.WishlistService;

import java.io.IOException;

@WebServlet(name = "AddToWishlistServlet", urlPatterns = {"/add-to-wishlist"})
public class AddToWishlistServlet extends HttpServlet {

    private static final int MAX_PRODUCT_ID = 1_000_000;

    private final WishlistService wishlistService = new WishlistService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Vui lòng đăng nhập để sử dụng wishlist.");
            return;
        }

        Account user = (Account) session.getAttribute("Account");

        String productIdStr = req.getParameter("productId");
        int productId = parsePositiveInt(productIdStr, 0);

        if (productId <= 0 || productId > MAX_PRODUCT_ID) {
            session.setAttribute("error", "Sản phẩm không hợp lệ.");
            redirectBack(req, resp);
            return;
        }

        try {
            WishlistService.AddResult result = wishlistService.addToWishlist(user.getId(), productId);

            if (result.isSuccess()) {
                session.setAttribute("message", result.getMessage());
                refreshWishlistCount(session, user.getId());
            } else {
                session.setAttribute("error", result.getMessage());
            }

        } catch (Exception e) {
            session.setAttribute("error", "Lỗi khi thêm vào wishlist. Vui lòng thử lại.");
        }

        redirectBack(req, resp);
    }

    private void refreshWishlistCount(HttpSession session, int customerId) {
        try {
            int count = wishlistService.getWishlistCount(customerId);
            session.setAttribute("wishlistCount", count);
        } catch (Exception ignored) {}
    }

    private void redirectBack(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String referer = req.getHeader("Referer");
        if (referer != null && !referer.isEmpty()) {
            resp.sendRedirect(referer);
        } else {
            resp.sendRedirect(req.getContextPath() + "/wishlist");
        }
    }

    private int parsePositiveInt(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            int parsed = Integer.parseInt(value.trim());
            return parsed > 0 ? parsed : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}

