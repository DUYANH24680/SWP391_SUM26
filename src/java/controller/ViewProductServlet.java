package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Seller;
import model.Product;
import model.Category;
import service.ProductService;
import service.CategoryService;

import java.io.IOException;

@WebServlet("/seller/view-product")
public class ViewProductServlet extends HttpServlet {

    private final ProductService productService = new ProductService();
    private final CategoryService categoryService = new CategoryService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isSellerLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Seller seller = getSeller(request);
        if (seller == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            session.setAttribute("message", "Khong tim thay san pham.");
            response.sendRedirect(request.getContextPath() + "/seller/products");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            session.setAttribute("message", "ID san pham khong hop le.");
            response.sendRedirect(request.getContextPath() + "/seller/products");
            return;
        }

        Product product = productService.getById(productId);
        if (product == null) {
            session.setAttribute("message", "San pham khong ton tai hoac da bi xoa.");
            response.sendRedirect(request.getContextPath() + "/seller/products");
            return;
        }

        if (product.getSellerId() != seller.getId()) {
            session.setAttribute("message", "Ban khong co quyen xem san pham nay.");
            response.sendRedirect(request.getContextPath() + "/seller/products");
            return;
        }

        Category category = categoryService.getById(product.getCategoryId());
        request.setAttribute("product", product);
        request.setAttribute("category", category);

        request.getRequestDispatcher("/seller/view-product.jsp").forward(request, response);
    }

    private boolean isSellerLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        Object account = session.getAttribute("account");
        if (account instanceof Seller) return true;
        Object user = session.getAttribute("user");
        return user instanceof Seller;
    }

    private Seller getSeller(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object account = session.getAttribute("account");
        if (account instanceof Seller) return (Seller) account;
        Object user = session.getAttribute("user");
        if (user instanceof Seller) return (Seller) user;
        return null;
    }
}
