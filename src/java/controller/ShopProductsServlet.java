package controller;

import dao.ProductDAO;
import dao.ShopDAO;
import model.Account;
import model.Product;
import model.Shop;
import Utils.ProductSorter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ShopProductsServlet", urlPatterns = {"/shop-products"})
public class ShopProductsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        Account user = (Account) session.getAttribute("user");

        String shopIdParam = req.getParameter("shopId");
        if (shopIdParam == null || shopIdParam.trim().isEmpty()) {
            session.setAttribute("error", "Không tìm thấy cửa hàng.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        int shopId;
        try {
            shopId = Integer.parseInt(shopIdParam);
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID cửa hàng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        ShopDAO shopDAO = new ShopDAO();
        Shop shop = shopDAO.getShopById(shopId);
        shopDAO.close();

        if (shop == null || !shop.isActive()) {
            session.setAttribute("error", "Cửa hàng không tồn tại hoặc đã bị khóa.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        ProductDAO productDAO = new ProductDAO();
        List<Product> products = productDAO.getProductsByShopId(shopId);

        String searchKey = req.getParameter("search");
        if (searchKey != null && !searchKey.trim().isEmpty()) {
            products.removeIf(p -> {
                String title = p.getTitle() != null ? p.getTitle().toLowerCase() : "";
                String desc = p.getDescription() != null ? p.getDescription().toLowerCase() : "";
                String key = searchKey.trim().toLowerCase();
                return !title.contains(key) && !desc.contains(key);
            });
        }

        String sort = req.getParameter("sort");
        if (sort != null && !sort.isEmpty()) {
            ProductSorter.sortProducts(products, sort);
        }

        int totalProducts = products.size();
        String avatarUrl = user.getAvatar();
        if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
            String fullname = user.getFullname() != null ? user.getFullname() : user.getUsername();
            avatarUrl = "https://ui-avatars.com/api/?name="
                      + java.net.URLEncoder.encode(fullname, "UTF-8")
                      + "&background=4caf50&color=fff&size=80&bold=true&rounded=true";
        }

        req.setAttribute("shop", shop);
        req.setAttribute("products", products);
        req.setAttribute("totalProducts", totalProducts);
        req.setAttribute("searchKey", searchKey != null ? searchKey.trim() : "");
        req.setAttribute("currentSort", sort != null ? sort : "");
        req.setAttribute("avatarUrl", avatarUrl);

        productDAO.close();
        req.getRequestDispatcher("/shop-products.jsp").forward(req, resp);
    }
}
