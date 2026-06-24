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

@WebServlet(name = "ViewWishlistServlet", urlPatterns = {"/wishlist"})
public class ViewWishlistServlet extends HttpServlet {

    private final WishlistService wishlistService = new WishlistService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Account Account = (Account) session.getAttribute("Account");
        req.setAttribute("wishlist", wishlistService.getWishlistByCustomerId(Account.getId()));
        req.getRequestDispatcher("/wishlist.jsp").forward(req, resp);
    }
}

