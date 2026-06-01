package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Seller;
import model.Product;
import service.ProductService;
import dao.ProductDAO;

import java.io.IOException;
import java.util.List;

@WebServlet("/seller/products")
public class ProductListServlet extends HttpServlet {

    private final ProductService productService = new ProductService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isSellerLoggedIn(session)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Seller seller = getSeller(session);
        if (seller == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String idStr = request.getParameter("id");

        if ("delete".equals(action) && idStr != null && !idStr.trim().isEmpty()) {
            try {
                int productId = Integer.parseInt(idStr);
                Product product = productService.getById(productId);
                if (product != null && product.getSellerId() == seller.getId()) {
                    productService.deleteProduct(productId);
                }
            } catch (NumberFormatException ignored) { }
            response.sendRedirect(request.getContextPath() + "/seller/products");
            return;
        }

        List<Product> products = productService.getBySeller(seller.getId());
        request.setAttribute("products", products);

        String message = (String) session.getAttribute("message");
        if (message != null) {
            request.setAttribute("message", message);
            session.removeAttribute("message");
        }

        request.getRequestDispatcher("/seller/products.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isSellerLoggedIn(session)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Seller seller = getSeller(session);
        if (seller == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String idStr = request.getParameter("id");

        if ("delete".equals(action) && idStr != null && !idStr.trim().isEmpty()) {
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
                session.setAttribute("message", "San pham khong ton tai.");
                response.sendRedirect(request.getContextPath() + "/seller/products");
                return;
            }

            if (product.isIsDelete()) {
                session.setAttribute("message", "San pham da bi xoa.");
                response.sendRedirect(request.getContextPath() + "/seller/products");
                return;
            }

            if (product.getSellerId() != seller.getId()) {
                session.setAttribute("message", "Ban khong co quyen xoa san pham nay.");
                response.sendRedirect(request.getContextPath() + "/seller/products");
                return;
            }

            productService.deleteProduct(productId);
            response.sendRedirect(request.getContextPath() + "/seller/products");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/seller/products");
    }

    private boolean isSellerLoggedIn(HttpSession session) {
        if (session == null) {
            return false;
        }
        Object account = session.getAttribute("account");
        if (account instanceof Seller) {
            return true;
        }
        Object user = session.getAttribute("user");
        return user instanceof Seller;
    }

    private Seller getSeller(HttpSession session) {
        Object account = session.getAttribute("account");
        if (account instanceof Seller) {
            return (Seller) account;
        }
        Object user = session.getAttribute("user");
        if (user instanceof Seller) {
            return (Seller) user;
        }
        return null;
    }
}
