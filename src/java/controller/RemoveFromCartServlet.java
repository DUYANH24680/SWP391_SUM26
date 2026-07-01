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

@WebServlet(name = "RemoveFromCartServlet", urlPatterns = {"/remove-from-cart"})
public class RemoveFromCartServlet extends HttpServlet {

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

            String productIdStr = request.getParameter("productId");

            if (productIdStr == null || productIdStr.trim().isEmpty()) {
                System.out.println("RemoveFromCartServlet: Khong tim thay ID san pham");
                session.setAttribute("error", "Khong tim thay ID san pham");
                response.sendRedirect(request.getContextPath() + "/view-cart");
                return;
            }

            int productId = Integer.parseInt(productIdStr.trim());
            System.out.println("RemoveFromCartServlet: Xoa san pham ID=" + productId + " khoi gio hang");

            cartService.removeItem(Account.getId(), productId);

            Cart cart = cartService.getCartByCustomerId(Account.getId());
            if (cart != null) {
                session.setAttribute("cart", cart);
                session.setAttribute("cartCount", cart.getTotalQuantity());
            } else {
                session.setAttribute("cartCount", 0);
            }

            session.setAttribute("message", "Da xoa san pham khoi gio hang!");
            response.sendRedirect(request.getContextPath() + "/view-cart");

        } catch (NumberFormatException e) {
            System.out.println("RemoveFromCartServlet Error: " + e.getMessage());
            request.getSession().setAttribute("error", "ID san pham khong hop le");
            response.sendRedirect(request.getContextPath() + "/view-cart");
        } catch (Exception e) {
            System.out.println("RemoveFromCartServlet Error: " + e.getMessage());
            e.printStackTrace();
            request.getSession().setAttribute("error", "Loi khi xoa san pham khoi gio hang");
            response.sendRedirect(request.getContextPath() + "/view-cart");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
