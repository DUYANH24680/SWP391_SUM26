package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Cart;
import model.Account;
import service.CartService;

import java.io.IOException;

@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {

    private static final String ACTION_ADD = "add";
    private static final String ACTION_REMOVE = "remove";
    private static final String ACTION_CLEAR = "clear";
    private static final String ACTION_UPDATE = "update";
    private static final String ACTION_BUY_NOW = "buyNow";
    private static final String ACTION_REORDER = "reorder";
    private final CartService cartService = new CartService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Account user = session != null ? (Account) session.getAttribute("Account") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if (ACTION_ADD.equals(action)) {
            handleAdd(req, resp, session, false);
            return;
        }
        if (ACTION_REMOVE.equals(action)) {
            handleRemove(req, resp, session);
            return;
        }
        if (ACTION_CLEAR.equals(action)) {
            handleClear(req, resp, session);
            return;
        }

        loadCart(req, user.getId());
        req.getRequestDispatcher("/cart.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Account user = session != null ? (Account) session.getAttribute("Account") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if (ACTION_ADD.equals(action)) {
            handleAdd(req, resp, session, false);
            return;
        }
        if (ACTION_BUY_NOW.equals(action)) {
            handleAdd(req, resp, session, true);
            return;
        }
        if (ACTION_UPDATE.equals(action)) {
            handleUpdate(req, resp, session);
            return;
        }
        if (ACTION_REMOVE.equals(action)) {
            handleRemove(req, resp, session);
            return;
        }
        if (ACTION_REORDER.equals(action)) {
            handleReorder(req, resp, session);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/cart");
    }

    private void loadCart(HttpServletRequest req, int customerId) {
        Cart cart = cartService.getCartByCustomerId(customerId);
        if (cart == null) {
            cart = new Cart();
        }
        req.setAttribute("cart", cart);
    }

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp,
                           HttpSession session, boolean redirectToCart)
            throws IOException {
        Account user = (Account) session.getAttribute("Account");
        int productId = parsePositiveInt(req.getParameter("productId"), 0);
        String size = trimParam(req.getParameter("size"));
        int quantity = parsePositiveInt(req.getParameter("quantity"), 1);
        String voucherCode = trimParam(req.getParameter("voucherCode"));
        String note = trimParam(req.getParameter("note"));

        try {
            cartService.addToCart(user.getId(), productId, quantity, voucherCode, note);
            session.setAttribute("message", "Thêm sản phẩm vào giỏ hàng thành công.");
        } catch (IllegalArgumentException e) {
            session.setAttribute("error", e.getMessage());
        } catch (Exception e) {
            System.err.println("[CartServlet] handleAdd error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi khi thêm sản phẩm vào giỏ hàng. Vui lòng thử lại.");
        }

        resp.sendRedirect(req.getContextPath() + "/cart");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp,
                              HttpSession session)
            throws IOException {
        Account user = (Account) session.getAttribute("Account");
        int productId = parsePositiveInt(req.getParameter("productId"), 0);
        String size = trimParam(req.getParameter("size"));
        int quantity = parsePositiveInt(req.getParameter("quantity"), 1);
        try {
            cartService.updateQuantity(user.getId(), productId, quantity);
            session.setAttribute("message", "Cập nhật số lượng giỏ hàng thành công.");
        } catch (IllegalArgumentException e) {
            session.setAttribute("error", e.getMessage());
        } catch (Exception e) {
            System.err.println("[CartServlet] handleUpdate error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi khi cập nhật giỏ hàng.");
        }
        resp.sendRedirect(req.getContextPath() + "/cart");
    }

    private void handleRemove(HttpServletRequest req, HttpServletResponse resp,
                              HttpSession session)
            throws IOException {
        Account user = (Account) session.getAttribute("Account");
        int productId = parsePositiveInt(req.getParameter("productId"), 0);
        String size = trimParam(req.getParameter("size"));
        try {
            cartService.removeItem(user.getId(), productId);
            session.setAttribute("message", "Xóa sản phẩm khỏi giỏ hàng thành công.");
        } catch (IllegalArgumentException e) {
            session.setAttribute("error", e.getMessage());
        } catch (Exception e) {
            System.err.println("[CartServlet] handleRemove error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi khi xóa sản phẩm khỏi giỏ hàng.");
        }
        resp.sendRedirect(req.getContextPath() + "/cart");
    }

    private void handleClear(HttpServletRequest req, HttpServletResponse resp,
                             HttpSession session)
            throws IOException {
        Account user = (Account) session.getAttribute("Account");
        try {
            cartService.clearCart(user.getId());
            session.setAttribute("cartCount", 0);
            session.setAttribute("message", "Giỏ hàng đã được xóa.");
        } catch (IllegalArgumentException e) {
            session.setAttribute("error", e.getMessage());
        } catch (Exception e) {
            System.err.println("[CartServlet] handleClear error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi khi xóa giỏ hàng.");
        }
        resp.sendRedirect(req.getContextPath() + "/cart");
    }

    private void handleReorder(HttpServletRequest req, HttpServletResponse resp, HttpSession session)
            throws IOException {
        Account user = (Account) session.getAttribute("Account");
        int orderId = parsePositiveInt(req.getParameter("orderId"), 0);
        try {
            model.ReorderResult result = cartService.reorder(user.getId(), orderId);
            if (result.isSuccess()) {
                session.setAttribute("message", result.getMessage());
            } else {
                session.setAttribute("error", result.getError());
            }
        } catch (Exception e) {
            System.err.println("[CartServlet] handleReorder error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi khi mua lại đơn hàng. Vui lòng thử lại.");
        }
        resp.sendRedirect(req.getContextPath() + "/cart");
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
