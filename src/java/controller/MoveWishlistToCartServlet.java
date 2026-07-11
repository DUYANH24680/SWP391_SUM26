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
import java.util.logging.Logger;

@WebServlet(name = "MoveWishlistToCartServlet", urlPatterns = {"/move-wishlist-to-cart"})
public class MoveWishlistToCartServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(MoveWishlistToCartServlet.class.getName());
    private final WishlistService wishlistService = new WishlistService();
    private final CartService cartService = new CartService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        LOG.info("[MoveWishlistToCartServlet] POST /move-wishlist-to-cart productId=" + req.getParameter("productId")
                + " session=" + (session == null ? "null" : session.getId()));
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Vui lòng đăng nhập để sử dụng wishlist.");
            return;
        }

        Account Account = (Account) session.getAttribute("Account");
        int productId = parsePositiveInt(req.getParameter("productId"), 0);
        LOG.info("[MoveWishlistToCartServlet] customerId=" + Account.getId() + " parsedProductId=" + productId);

        try {
            WishlistService.MoveToCartResult result = wishlistService.moveWishlistItemToCart(Account.getId(), productId);
            Cart cart = result.getCart();
            boolean alreadyInCart = result.wasAlreadyInCart();

            session.setAttribute("cart", cart);
            refreshBothCounts(session, Account.getId());

            // Set message based on whether product was already in cart
            if (alreadyInCart) {
                session.setAttribute("error", "San pham da co trong gio hang.");
            } else {
                session.setAttribute("message", "Da chuyen san pham vao gio hang.");
            }

            String json = "{\"success\":true,\"alreadyInCart\":" + alreadyInCart + ",\"message\":\""
                        + (alreadyInCart ? "San pham da co trong gio hang." : "Da chuyen san pham vao gio hang.")
                        + "\",\"cartTotalQuantity\":" + (cart != null ? cart.getTotalQuantity() : 0) + "}";
            LOG.info("[MoveWishlistToCartServlet] success json=" + json);
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write(json);
        } catch (IllegalArgumentException e) {
            LOG.warning("[MoveWishlistToCartServlet] IllegalArgumentException: " + e.getMessage());
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write("{\"success\":false,\"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        } catch (Exception e) {
            LOG.severe("[MoveWishlistToCartServlet] Exception: " + e.getMessage());
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi khi chuyển sản phẩm vào giỏ hàng.\"}");
        }
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

