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

@WebServlet(name = "UpdateCartServlet", urlPatterns = {"/update-cart"})
public class UpdateCartServlet extends HttpServlet {

    private final CartService cartService = new CartService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        try {
            HttpSession session = request.getSession();
            Account Account = (Account) session.getAttribute("Account");

            if (Account == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }

            String productIdStr = request.getParameter("productId");
            String quantityStr = request.getParameter("quantity");
            String note = request.getParameter("note");
            String discountCode = request.getParameter("discountCode");
            String selectedStr = request.getParameter("selected");

            if (productIdStr == null || productIdStr.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            int productId = Integer.parseInt(productIdStr.trim());
            Integer quantity = null;
            if (quantityStr != null && !quantityStr.trim().isEmpty()) {
                try {
                    quantity = Integer.parseInt(quantityStr.trim());
                } catch (NumberFormatException e) {
                    response.setContentType("text/plain");
                    response.getWriter().write("INVALID_PARAMS");
                    return;
                }
            }

            boolean hasNote = note != null && !note.trim().isEmpty();
            boolean hasDiscountCode = discountCode != null && !discountCode.trim().isEmpty();
            boolean hasEditFields = hasNote || hasDiscountCode || quantity != null;

            // Chi thay doi trang thai chon (checkbox)
            if (selectedStr != null && !hasEditFields) {
                boolean selected = Boolean.parseBoolean(selectedStr);
                cartService.updateItemSelection(Account.getId(), productId, selected);
            }

            if (hasEditFields) {
                // Cap nhat cart item (so luong, ghi chu, ma giam gia)
                Cart cart = cartService.updateCartItem(
                        Account.getId(), productId,
                        quantity,
                        note,
                        hasDiscountCode ? discountCode.trim() : null
                );
                session.setAttribute("cart", cart);
                session.setAttribute("cartCount", cart.getTotalQuantity());
                double selectedTotal = 0;
                for (var item : cart.getItems()) {
                    if (item.isSelected()) {
                        selectedTotal += item.getSubtotal();
                    }
                }
                session.setAttribute("cartTotal", selectedTotal);
            } else if (quantity != null && quantity > 0) {
                // Chi thay doi so luong (tu nut +/-)
                Cart cart = cartService.updateQuantity(Account.getId(), productId, quantity);
                session.setAttribute("cart", cart);
                session.setAttribute("cartCount", cart.getTotalQuantity());
                double selectedTotal = 0;
                for (var item : cart.getItems()) {
                    if (item.isSelected()) {
                        selectedTotal += item.getSubtotal();
                    }
                }
                session.setAttribute("cartTotal", selectedTotal);
            }

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            Cart cartForResponse = cartService.getCartByCustomerId(Account.getId());
            double total = 0;
            int totalQty = 0;
            if (cartForResponse != null) {
                for (var item : cartForResponse.getItems()) {
                    if (item.isSelected()) {
                        total += item.getSubtotal();
                        totalQty += item.getQuantity();
                    }
                }
            }

            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"selectedTotal\":").append(String.format("%.2f", total));
            json.append(",\"totalQuantity\":").append(totalQty);
            json.append(",\"cartCount\":").append(cartForResponse != null ? cartForResponse.getTotalQuantity() : 0);
            json.append("}");

            response.getWriter().write(json.toString());

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("text/plain");
            response.getWriter().write("INVALID_PARAMS");
        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("text/plain");
            response.getWriter().write("ERROR:" + e.getMessage());
        } catch (Exception e) {
            System.out.println("UpdateCartServlet Error: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("text/plain");
            response.getWriter().write("SERVER_ERROR");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/view-cart");
    }
}

