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

import java.io.IOException;

@WebServlet(name = "BuyNowServlet", urlPatterns = {"/buy-now"})
public class BuyNowServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/plain; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("Account") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Account account = (Account) session.getAttribute("Account");

        String productIdStr = request.getParameter("productId");
        String quantityStr = request.getParameter("quantity");

        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            session.setAttribute("error", "Khong tim thay ID san pham");
            redirectBack(request, response);
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID san pham khong hop le");
            redirectBack(request, response);
            return;
        }

        int quantity = 1;
        if (quantityStr != null && !quantityStr.trim().isEmpty()) {
            try {
                quantity = Integer.parseInt(quantityStr.trim());
            } catch (NumberFormatException e) {
                quantity = 1;
            }
        }

        String note = request.getParameter("note");
        String discountCode = request.getParameter("discountCode");

        CartService cartService = new CartService();
        try {
            Cart cart = cartService.addToCart(
                    account.getId(), productId, quantity, discountCode, note);

            if (cart != null) {
                session.setAttribute("cart", cart);
                session.setAttribute("cartCount", cart.getTotalQuantity());
            } else {
                session.setAttribute("error", "Co loi xay ra khi them san pham vao gio hang.");
                redirectBack(request, response);
                return;
            }

        } catch (IllegalArgumentException e) {
            session.setAttribute("error", e.getMessage());
            redirectBack(request, response);
            return;
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Loi he thong khi them san pham vao gio hang.");
            redirectBack(request, response);
            return;
        } finally {
            cartService.close();
        }

        // Always redirect to cart after adding
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/home.jsp");
    }

    private void redirectBack(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String referer = request.getHeader("Referer");
        if (referer != null && !referer.trim().isEmpty()) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/home.jsp");
        }
    }
}

