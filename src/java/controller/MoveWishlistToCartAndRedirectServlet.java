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

@WebServlet(name = "MoveWishlistToCartAndRedirectServlet", urlPatterns = {"/move-wishlist-to-cart-redirect"})
public class MoveWishlistToCartAndRedirectServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(MoveWishlistToCartAndRedirectServlet.class.getName());
    private final WishlistService wishlistService = new WishlistService();
    private final CartService cartService = new CartService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        LOG.info("[MoveWishlistToCartAndRedirectServlet] POST /move-wishlist-to-cart-redirect");

        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Account account = (Account) session.getAttribute("Account");
        int customerId = account.getId();

        String productIdsParam = req.getParameter("productIds");
        if (productIdsParam == null || productIdsParam.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/wishlist");
            return;
        }

        String[] productIdStrs = productIdsParam.split(",");
        int movedCount = 0;
        int alreadyInCartCount = 0;

        for (String productIdStr : productIdStrs) {
            try {
                productIdStr = productIdStr.trim();
                if (productIdStr.isEmpty()) continue;

                int productId = Integer.parseInt(productIdStr);
                WishlistService.MoveToCartResult result = wishlistService.moveWishlistItemToCart(customerId, productId);
                if (result.wasAlreadyInCart()) {
                    alreadyInCartCount++;
                } else {
                    movedCount++;
                }
            } catch (Exception e) {
                LOG.warning("[MoveWishlistToCartAndRedirectServlet] Error moving product " + productIdStr + ": " + e.getMessage());
            }
        }

        // Refresh cart in session
        try {
            Cart cart = cartService.getCartByCustomerId(customerId);
            session.setAttribute("cart", cart);
            if (cart != null) {
                int totalQty = cart.getTotalQuantity();
                LOG.info("[MoveWishlistToCartAndRedirectServlet] Cart refreshed: totalItems=" + cart.getTotalItems() + ", totalQuantity=" + totalQty);
                session.setAttribute("cartCount", totalQty);
            }
        } catch (Exception e) {
            LOG.warning("[MoveWishlistToCartAndRedirectServlet] Error refreshing cart: " + e.getMessage());
        }

        // Refresh wishlist count
        try {
            int wishlistCount = wishlistService.getWishlistCount(customerId);
            session.setAttribute("wishlistCount", wishlistCount);
        } catch (Exception e) {
            LOG.warning("[MoveWishlistToCartAndRedirectServlet] Error refreshing wishlist count: " + e.getMessage());
        }

        // Set messages - success (green) and warning (red)
        if (movedCount > 0 && alreadyInCartCount > 0) {
            session.setAttribute("message", "Da chuyen " + movedCount + " san pham vao gio hang.");
            session.setAttribute("error", alreadyInCartCount + " san pham da co trong gio hang.");
        } else if (alreadyInCartCount > 0) {
            session.setAttribute("error", alreadyInCartCount + " san pham da co trong gio hang.");
        } else if (movedCount > 0) {
            session.setAttribute("message", "Da chuyen " + movedCount + " san pham vao gio hang.");
        }

        LOG.info("[MoveWishlistToCartAndRedirectServlet] Moved " + movedCount + " products, " + alreadyInCartCount + " already in cart");

        resp.sendRedirect(req.getContextPath() + "/view-cart");
    }
}
