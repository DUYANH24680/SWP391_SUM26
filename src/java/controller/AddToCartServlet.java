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
import java.io.PrintWriter;

@WebServlet(name = "AddToCartServlet", urlPatterns = {"/add-to-cart"})
public class AddToCartServlet extends HttpServlet {

    private final CartService cartService = new CartService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/plain; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        // ---- Buoc 1: Kiem tra dang nhap ----
        if (session == null || session.getAttribute("Account") == null) {
            System.out.println("[AddToCartServlet] CHUA DANG NHAP - redirect ve login");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Account account = (Account) session.getAttribute("Account");
        System.out.println("[AddToCartServlet] USER: id=" + account.getId()
                + ", username=" + account.getUsername());

        // ---- Buoc 2: Doc tham so ----
        String productIdStr = request.getParameter("productId");
        String quantityStr = request.getParameter("quantity");

        System.out.println("[AddToCartServlet] PARAM: productId=" + productIdStr
                + ", quantity=" + quantityStr);

        // ---- Buoc 3: Validate productId ----
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            System.out.println("[AddToCartServlet] LOI: productId rong");
            session.setAttribute("error", "Khong tim thay ID san pham");
            redirectBack(request, response);
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            System.out.println("[AddToCartServlet] LOI: productId khong hop le: " + productIdStr);
            session.setAttribute("error", "ID san pham khong hop le");
            redirectBack(request, response);
            return;
        }

        // ---- Buoc 4: Validate so luong ----
        int quantity = 1;
        if (quantityStr != null && !quantityStr.trim().isEmpty()) {
            try {
                quantity = Integer.parseInt(quantityStr.trim());
            } catch (NumberFormatException e) {
                quantity = 1;
            }
        }

        // ---- Buoc 4.1: Doc ghi chu ----
        String note = request.getParameter("note");
        String discountCode = request.getParameter("discountCode");

        // ---- Buoc 5: Them vao gio hang ----
        try {
            System.out.println("[AddToCartServlet] Goi cartService.addToCart(customerId="
                    + account.getId() + ", productId=" + productId
                    + ", quantity=" + quantity + ", discountCode=" + discountCode
                    + ", note=" + note + ")");

            Cart cart = cartService.addToCart(
                    account.getId(), productId, quantity, discountCode, note);

            if (cart != null) {
                System.out.println("[AddToCartServlet] SUCCESS: Da them vao gio hang. "
                        + "Cart co " + cart.getTotalQuantity() + " san pham");

                session.setAttribute("cart", cart);
                session.setAttribute("cartCount", cart.getTotalQuantity());
                session.setAttribute("message", "Da them san pham vao gio hang!");
            } else {
                System.out.println("[AddToCartServlet] WARNING: cart tra ve null");
                session.setAttribute("error", "Co loi xay ra khi them san pham vao gio hang.");
            }

        } catch (IllegalArgumentException e) {
            // Loi nghiep vu - hien thi thong bao cho nguoi dung
            System.out.println("[AddToCartServlet] NGHIEP VU LOI: " + e.getMessage());
            session.setAttribute("error", e.getMessage());

        } catch (Exception e) {
            // Loi he thong - khong hien thi chi tiet
            System.out.println("[AddToCartServlet] HE THONG LOI: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Loi he thong khi them san pham vao gio hang.");
        }

        // Success - redirect to cart page
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/home.jsp");
    }

    private void redirectBack(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/view-cart");
    }
}

