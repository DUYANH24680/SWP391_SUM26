package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import service.CartService;

import java.io.IOException;

@WebServlet(name = "AddToCartServlet", urlPatterns = {"/add-to-cart"})
public class AddToCartServlet extends HttpServlet {

    private final CartService cartService = new CartService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/home.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Account user = (Account) session.getAttribute("user");
        String productIdParam = trimParam(req.getParameter("productId"));
        String size = trimParam(req.getParameter("size"));
        String quantityParam = trimParam(req.getParameter("quantity"));
        String voucherCode = trimParam(req.getParameter("voucherCode"));
        String note = trimParam(req.getParameter("note"));

        // ---- Buoc 5: Them vao gio hang ----
        try {
            cartService.addToCart(user.getId(), productId, quantity, voucherCode, note);
            session.setAttribute("message", "Thêm giỏ hàng thành công.");
        } catch (IllegalArgumentException e) {
            session.setAttribute("error", e.getMessage());
        } catch (Exception e) {
            System.err.println("[AddToCartServlet] error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi khi thêm sản phẩm vào giỏ hàng. Vui lòng thử lại.");
        }

        String referer = req.getHeader("Referer");
        if (referer != null && !referer.trim().isEmpty()) {
            resp.sendRedirect(referer);
        } else {
            resp.sendRedirect(req.getContextPath() + "/cart");
        }
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

    private String trimParam(String value) {
        return value != null ? value.trim() : null;
    }
}
