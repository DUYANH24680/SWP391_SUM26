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

import java.io.IOException;
import java.util.List;

@WebServlet("/seller/dashboard")
public class SellerDashboardServlet extends HttpServlet {

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

        List<Product> products = productService.getBySeller(seller.getId());
        int totalProducts = products.size();
        int totalStock = products.stream().mapToInt(Product::getStockQuantity).sum();
        int totalSold = products.stream().mapToInt(Product::getSoldQuantity).sum();
        int activeProducts = (int) products.stream().filter(p -> p.getStatus() == 1).count();

        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("totalStock", totalStock);
        request.setAttribute("totalSold", totalSold);
        request.setAttribute("activeProducts", activeProducts);
        request.setAttribute("products", products);
        request.setAttribute("sellerName", seller.getFullname());

        request.getRequestDispatcher("/seller/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/seller/dashboard");
    }

    private boolean isSellerLoggedIn(HttpSession session) {
        if (session == null) return false;
        Object account = session.getAttribute("account");
        if (account instanceof Seller) return true;
        Object user = session.getAttribute("user");
        return user instanceof Seller;
    }

    private Seller getSeller(HttpSession session) {
        Object account = session.getAttribute("account");
        if (account instanceof Seller) return (Seller) account;
        Object user = session.getAttribute("user");
        if (user instanceof Seller) return (Seller) user;
        return null;
    }
}
