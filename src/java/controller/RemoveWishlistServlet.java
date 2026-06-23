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

@WebServlet(name = "RemoveWishlistServlet", urlPatterns = {"/remove-wishlist"})
public class RemoveWishlistServlet extends HttpServlet {

    private final WishlistService wishlistService = new WishlistService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Vui lòng đăng nhập để sử dụng wishlist.");
            return;
        }

        Account user = (Account) session.getAttribute("user");
        int productId = parsePositiveInt(req.getParameter("productId"), 0);

        try {
            boolean removed = wishlistService.removeFromWishlist(user.getId(), productId);
            if (removed) {
                session.setAttribute("message", "Đã xóa sản phẩm khỏi wishlist.");
            } else {
                session.setAttribute("message", "Không tìm thấy sản phẩm trong wishlist.");
            }
        } catch (IllegalArgumentException e) {
            session.setAttribute("error", e.getMessage());
        } catch (Exception e) {
            System.err.println("[RemoveWishlistServlet] " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi khi xóa sản phẩm khỏi wishlist.");
        }

        resp.sendRedirect(req.getContextPath() + "/wishlist");
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
