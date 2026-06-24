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
import java.io.PrintWriter;

@WebServlet(name = "CheckWishlistServlet", urlPatterns = {"/check-wishlist"})
public class CheckWishlistServlet extends HttpServlet {

    private final WishlistService wishlistService = new WishlistService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        HttpSession session = req.getSession(false);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        
        if (session == null || session.getAttribute("Account") == null) {
            out.print("{\"inWishlist\": false, \"loggedIn\": false}");
            return;
        }
        
        String productIdParam = req.getParameter("productId");
        if (productIdParam == null || productIdParam.trim().isEmpty()) {
            out.print("{\"inWishlist\": false, \"error\": \"Missing productId\"}");
            return;
        }
        
        try {
            int productId = Integer.parseInt(productIdParam.trim());
            Account Account = (Account) session.getAttribute("Account");
            boolean inWishlist = wishlistService.isInWishlist(Account.getId(), productId);
            out.print("{\"inWishlist\": " + inWishlist + ", \"loggedIn\": true}");
        } catch (NumberFormatException e) {
            out.print("{\"inWishlist\": false, \"error\": \"Invalid productId\"}");
        }
    }
}
