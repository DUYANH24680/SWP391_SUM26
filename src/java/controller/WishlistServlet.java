package controller;

import dao.CartDAO;
import dao.ProductDAO;
import dao.WishlistDAO;
import model.User;
import model.Product;
import model.Wishlist;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "WishlistServlet", urlPatterns = {"/wishlist"})
public class WishlistServlet extends HttpServlet {

    private final WishlistDAO wishlistDAO = new WishlistDAO();
    private final CartDAO cartDAO = new CartDAO();
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // View Wishlist
        List<Wishlist> wishlist = wishlistDAO.getWishlistByCustomerId(user.getId());
        request.setAttribute("wishlist", wishlist);
        request.getRequestDispatcher("/wishlist.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            // For AJAX requests, you might want to return JSON error instead, 
            // but for form submissions, redirect to login.
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/wishlist");
            return;
        }

        try {
            switch (action) {
                case "add":
                    addToWishlist(request, session, user);
                    break;
                case "remove":
                    removeFromWishlist(request, session, user);
                    break;
                case "moveToCart":
                    moveToCart(request, session, user);
                    break;
            }
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Dữ liệu không hợp lệ.");
        }

        // If action is add, they might be on a product page, so redirecting to /wishlist might not be ideal
        // But for simplicity, we redirect to wishlist. You can change this to use `Referer` header to redirect back.
        String referer = request.getHeader("Referer");
        if (referer != null && action.equals("add")) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/wishlist");
        }
    }

    private void addToWishlist(HttpServletRequest request, HttpSession session, User user) {
        int productId = Integer.parseInt(request.getParameter("productId"));
        boolean success = wishlistDAO.addToWishlist(user.getId(), productId);
        if (success) {
            session.setAttribute("message", "Đã thêm vào danh sách yêu thích.");
        } else {
            session.setAttribute("error", "Sản phẩm đã có trong danh sách yêu thích.");
        }
    }

    private void removeFromWishlist(HttpServletRequest request, HttpSession session, User user) {
        int productId = Integer.parseInt(request.getParameter("productId"));
        boolean success = wishlistDAO.removeFromWishlist(user.getId(), productId);
        if (success) {
            session.setAttribute("message", "Đã xóa khỏi danh sách yêu thích.");
        } else {
            session.setAttribute("error", "Lỗi xóa sản phẩm.");
        }
    }

    private void moveToCart(HttpServletRequest request, HttpSession session, User user) {
        int productId = Integer.parseInt(request.getParameter("productId"));
        
        Product product = productDAO.getProductById(productId);
        if (product == null || !product.isActive()) {
            session.setAttribute("error", "Sản phẩm không khả dụng.");
            return;
        }

        if (product.getStockQuantity() <= 0) {
            session.setAttribute("error", "Sản phẩm này hiện đang hết hàng, không thể thêm vào giỏ.");
            return;
        }

        // 1. Add to Cart
        boolean addedToCart = cartDAO.addCartItem(user.getId(), productId, 1);
        
        if (addedToCart) {
            // 2. Remove from Wishlist
            wishlistDAO.removeFromWishlist(user.getId(), productId);
            session.setAttribute("message", "Đã chuyển sản phẩm vào giỏ hàng.");
        } else {
            session.setAttribute("error", "Lỗi chuyển vào giỏ hàng.");
        }
    }
}
