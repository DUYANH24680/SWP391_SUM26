package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Cart;
import service.CartService;
import service.WishlistService;

import java.io.IOException;

@WebServlet(name = "MoveWishlistToCartServlet", urlPatterns = {"/move-wishlist-to-cart"})
public class MoveWishlistToCartServlet extends HttpServlet {

    private final WishlistService wishlistService = new WishlistService();
    private final CartService cartService = new CartService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Vui lòng đăng nhập để sử dụng wishlist.");
            return;
        }

        Account Account = (Account) session.getAttribute("Account");
        int productId = parsePositiveInt(req.getParameter("productId"), 0);

        try {
            Cart cart = wishlistService.moveWishlistItemToCart(Account.getId(), productId);
            session.setAttribute("message", "Đã chuyển sản phẩm vào giỏ hàng.");
            session.setAttribute("cart", cart);
            refreshBothCounts(session, Account.getId());
        } catch (IllegalArgumentException e) {
            session.setAttribute("error", e.getMessage());
        } catch (Exception e) {
            session.setAttribute("error", "Lỗi khi chuyển sản phẩm vào giỏ hàng.");
        }

        resp.sendRedirect(req.getContextPath() + "/wishlist");
    }

    private void refreshBothCounts(HttpSession session, int customerId) {
        try {
            int wishlistCount = wishlistService.getWishlistCount(customerId);
            session.setAttribute("wishlistCount", wishlistCount);
        } catch (Exception ignored) {}
        try {
            var cart = cartService.getCartByCustomerId(customerId);
            if (cart != null) {
                session.setAttribute("cartCount", cart.getTotalQuantity());
            }
        } catch (Exception ignored) {}
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
