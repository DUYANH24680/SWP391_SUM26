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

@WebServlet(name = "ViewCartServlet", urlPatterns = {"/cart", "/view-cart"})
public class ViewCartServlet extends HttpServlet {

    private final CartService cartService = new CartService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("Account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Cart cart = cartService.getCartByCustomerId(account.getId());
        if (cart == null) {
            cart = new Cart();
        }

        double cartTotal = 0;
        for (var item : cart.getItems()) {
            if (item.isSelected()) {
                cartTotal += item.getSubtotal();
            }
        }
        session.setAttribute("cartTotal", cartTotal);
        session.setAttribute("cart", cart);

        request.setAttribute("cart", cart);
        if (cart.isEmpty()) {
            request.setAttribute("emptyCart", true);
        } else {
            request.setAttribute("cartItems", cart.getItems());
        }

        request.getRequestDispatcher("/cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("Account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        if ("add".equals(action) || "buyNow".equals(action)) {
            // ---- Xu ly them san pham vao gio hang ----
            String productIdStr = request.getParameter("productId");
            String quantityStr = request.getParameter("quantity");
            String note = request.getParameter("note");
            String discountCode = request.getParameter("discountCode");

            if (productIdStr == null || productIdStr.trim().isEmpty()) {
                session.setAttribute("error", "Khong tim thay san pham.");
                response.sendRedirect(request.getContextPath() + "/home.jsp");
                return;
            }

            int productId;
            try {
                productId = Integer.parseInt(productIdStr.trim());
            } catch (NumberFormatException e) {
                session.setAttribute("error", "ID san pham khong hop le.");
                response.sendRedirect(request.getContextPath() + "/home.jsp");
                return;
            }

            int quantity = 1;
            if (quantityStr != null && !quantityStr.trim().isEmpty()) {
                try {
                    quantity = Integer.parseInt(quantityStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            // Size mac dinh la "M" neu khong chon
            // Size da duoc loai bo khoi he thong

            try {
                Cart cart = cartService.addToCart(
                        account.getId(), productId, quantity, discountCode, note);

                session.setAttribute("cart", cart);
                session.setAttribute("cartCount", cart.getTotalQuantity());

                if ("buyNow".equals(action)) {
                    response.sendRedirect(request.getContextPath() + "/checkout?productId=" + productId + "&quantity=" + quantity);
                } else {
                    session.setAttribute("message", "Da them san pham vao gio hang!");
                    response.sendRedirect(request.getContextPath() + "/view-cart");
                }
                return;

            } catch (IllegalArgumentException e) {
                session.setAttribute("error", e.getMessage());
            } catch (Exception e) {
                System.err.println("[ViewCartServlet] addToCart error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("error", "Loi khi them san pham vao gio hang.");
            }

            // Quay lai trang truoc
            String referer = request.getHeader("Referer");
            if (referer != null && !referer.trim().isEmpty()) {
                response.sendRedirect(referer);
            } else {
                response.sendRedirect(request.getContextPath() + "/home.jsp");
            }
            return;
        }

        // Cac action khac (update, remove, clear, select) chi xu ly o servlet rieng
        doGet(request, response);
    }
}
