package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

import model.Account;
import model.Cart;
import model.Wishlist;
import service.AccountService;
import service.CartService;
import service.WishlistService;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private AccountService accountService = new AccountService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Account account = accountService.login(username, password);

        if (account != null) {
            HttpSession session = request.getSession();
            session.setAttribute("Account", account);
            session.setAttribute("userId", account.getId());
            session.setAttribute("role", account.getRoleName());

            // Load cart tu database vao session
            CartService cartService = new CartService();
            try {
                Cart cart = cartService.getCartByCustomerId(account.getId());
                if (cart != null) {
                    session.setAttribute("cart", cart);
                    session.setAttribute("cartCount", cart.getTotalQuantity());
                } else {
                    session.setAttribute("cartCount", 0);
                }
            } catch (Exception e) {
                System.err.println("[LoginServlet] Loi load cart: " + e.getMessage());
                session.setAttribute("cartCount", 0);
            } finally {
                cartService.close();
            }

            // Load wishlist tu database vao session
            WishlistService wishlistService = new WishlistService();
            try {
                Wishlist wishlist = wishlistService.getWishlistByCustomerId(account.getId());
                if (wishlist != null) {
                    session.setAttribute("wishlistCount", wishlist.getTotalItems());
                } else {
                    session.setAttribute("wishlistCount", 0);
                }
            } catch (Exception e) {
                System.err.println("[LoginServlet] Loi load wishlist: " + e.getMessage());
                session.setAttribute("wishlistCount", 0);
            } finally {
                wishlistService.close();
            }

            System.out.println("[LoginServlet] User '" + username
                    + "' da login thanh cong. Cart: " + session.getAttribute("cartCount")
                    + " san pham, Wishlist: " + session.getAttribute("wishlistCount") + " san pham");

            response.sendRedirect(request.getContextPath() + "/home.jsp");
        } else {
            request.setAttribute("error", "Sai tai khoan hoac mat khau");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}

