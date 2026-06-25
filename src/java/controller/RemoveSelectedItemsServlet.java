package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Cart;
import dao.CartDAO;
import dao.CartItemDAO;
import service.CartService;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(name = "RemoveSelectedItemsServlet", urlPatterns = {"/remove-selected-items"})
public class RemoveSelectedItemsServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            Account Account = (Account) session.getAttribute("Account");

            if (Account == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }

            String selectedProductsStr = request.getParameter("selectedProducts");
            if (selectedProductsStr == null || selectedProductsStr.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            List<Integer> productIds = Arrays.stream(selectedProductsStr.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .map(Integer::parseInt)
                    .collect(Collectors.toList());

            System.out.println("RemoveSelectedItemsServlet: Xoa cac san pham " + productIds + " khoi gio hang");

            CartDAO cartDAO = new CartDAO();
            CartItemDAO cartItemDAO = new CartItemDAO();

            Cart cart = cartDAO.getCartByCustomerId(Account.getId());
            if (cart != null) {
                cartItemDAO.deleteItemsByProductIds(cart.getId(), productIds);
                cartDAO.recalculateCartTotals(cart.getId());
            }

            cartDAO.close();
            cartItemDAO.close();

            Cart updatedCart = new CartService().getCartByCustomerId(Account.getId());
            session.setAttribute("cart", updatedCart);
            session.setAttribute("cartCount", updatedCart != null ? updatedCart.getTotalQuantity() : 0);

            response.setStatus(HttpServletResponse.SC_OK);

        } catch (Exception e) {
            System.out.println("RemoveSelectedItemsServlet Error: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
