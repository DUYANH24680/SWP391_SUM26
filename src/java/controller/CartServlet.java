package controller;

import dao.CartDAO;
import dao.ProductDAO;
import model.Cart;
import model.CartItem;
import model.User;
import model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {

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

        // View Cart
        Cart cart = cartDAO.getCartByCustomerId(user.getId());
        request.setAttribute("cart", cart);
        request.setAttribute("totalAmount", cart.getTotalMoney());
        request.getRequestDispatcher("/cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        try {
            switch (action) {
                case "add":
                    addToCart(request, session, user);
                    break;
                case "update":
                    updateQuantity(request, session);
                    break;
                case "remove":
                    removeCartItem(request, session);
                    break;
                default:
                    break;
            }
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Dữ liệu không hợp lệ.");
        }

        response.sendRedirect(request.getContextPath() + "/cart");
    }

    private void addToCart(HttpServletRequest request, HttpSession session, User user) {
        int productId = Integer.parseInt(request.getParameter("productId"));
        int quantity = 1; // Default
        String quantityStr = request.getParameter("quantity");
        if (quantityStr != null && !quantityStr.isEmpty()) {
            quantity = Integer.parseInt(quantityStr);
        }

        if (quantity <= 0) {
            session.setAttribute("error", "Số lượng phải lớn hơn 0.");
            return;
        }

        Product product = productDAO.getProductById(productId);
        if (product == null || !product.isActive()) {
            session.setAttribute("error", "Sản phẩm không tồn tại hoặc đã ngừng kinh doanh.");
            return;
        }

        if (quantity > product.getStockQuantity()) {
            session.setAttribute("error", "Sản phẩm " + product.getTitle() + " chỉ còn " + product.getStockQuantity() + " trong kho.");
            return;
        }

        boolean success = cartDAO.addCartItem(user.getId(), productId, quantity);
        if (success) {
            session.setAttribute("message", "Đã thêm sản phẩm vào giỏ hàng.");
        } else {
            session.setAttribute("error", "Lỗi hệ thống khi thêm vào giỏ hàng.");
        }
    }

    private void updateQuantity(HttpServletRequest request, HttpSession session) {
        int cartItemId = Integer.parseInt(request.getParameter("cartItemId"));
        int quantity = Integer.parseInt(request.getParameter("quantity"));

        if (quantity <= 0) {
            boolean success = cartDAO.removeCartItem(cartItemId);
            if (success) {
                session.setAttribute("message", "Đã xóa sản phẩm khỏi giỏ hàng.");
            } else {
                session.setAttribute("error", "Xóa sản phẩm thất bại.");
            }
            return;
        }

        // Get cart to find the product
        User user = (User) session.getAttribute("user");
        Cart cart = cartDAO.getCartByCustomerId(user.getId());
        
        // Find the cart item and check stock
        CartItem targetItem = null;
        for (CartItem item : cart.getItems()) {
            if (item.getId() == cartItemId) {
                targetItem = item;
                break;
            }
        }

        if (targetItem == null) {
            session.setAttribute("error", "Không tìm thấy sản phẩm trong giỏ hàng.");
            return;
        }

        // Check stock availability
        Product product = targetItem.getProduct();
        if (quantity > product.getStockQuantity()) {
            session.setAttribute("error", "Sản phẩm " + product.getTitle() + " chỉ còn " + product.getStockQuantity() + " trong kho.");
            return;
        }

        boolean success = cartDAO.updateQuantity(cartItemId, quantity);
        if (success) {
            session.setAttribute("message", "Đã cập nhật số lượng.");
        } else {
            session.setAttribute("error", "Cập nhật số lượng thất bại.");
        }
    }

    private void removeCartItem(HttpServletRequest request, HttpSession session) {
        int cartItemId = Integer.parseInt(request.getParameter("cartItemId"));
        boolean success = cartDAO.removeCartItem(cartItemId);
        if (success) {
            session.setAttribute("message", "Đã xóa sản phẩm khỏi giỏ hàng.");
        } else {
            session.setAttribute("error", "Xóa sản phẩm thất bại.");
        }
    }
}
