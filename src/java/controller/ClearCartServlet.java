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

@WebServlet(name = "ClearCartServlet", urlPatterns = {"/clear-cart"})
public class ClearCartServlet extends HttpServlet {

    private final CartService cartService = new CartService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            Account Account = (Account) session.getAttribute("Account");

            if (Account == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            System.out.println("ClearCartServlet: Xoa toan bo gio hang cho khach hang ID=" + Account.getId());

            cartService.clearCart(Account.getId());

            session.setAttribute("cart", new model.Cart());
            session.setAttribute("cartCount", 0);
            session.setAttribute("message", "Gio hang da duoc xoa!");

            response.sendRedirect(request.getContextPath() + "/view-cart");

        } catch (Exception e) {
            System.out.println("ClearCartServlet Error: " + e.getMessage());
            e.printStackTrace();
            request.getSession().setAttribute("error", "Loi khi xoa gio hang");
            response.sendRedirect(request.getContextPath() + "/view-cart");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
