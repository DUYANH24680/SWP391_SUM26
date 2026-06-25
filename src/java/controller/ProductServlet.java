package controller;

import dao.CategoryDAO;
import dao.ProductDAO;
import dao.ShopDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Category;
import model.Product;
import model.Shop;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "ProductServlet", urlPatterns = {"/products"})
public class ProductServlet extends HttpServlet {

    private static final String ROLE_SELLER = "seller";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("addProductForm".equals(action) || "add-product".equals(action)) {
            resp.sendRedirect(req.getContextPath() + "/add-product");
            return;
        }

        // ---- product-detail handler ----
        String idParam = req.getParameter("id");
        if (idParam != null && !idParam.trim().isEmpty()) {
            HttpSession session = req.getSession(false);
            try {
                handleProductDetail(req, resp);
            } catch (Exception e) {
                System.err.println("[ProductServlet] product-detail error: " + e.getMessage());
                e.printStackTrace();
                if (session != null) {
                    session.setAttribute("error", "Khong the tai chi tiet san pham: " + e.getMessage());
                }
                resp.sendRedirect(req.getContextPath() + "/products");
            }
            return;
        }

        HttpSession session = req.getSession(false);
        String role = (session != null) ? (String) session.getAttribute("role") : null;
        String keyword = req.getParameter("search");

        System.out.println("[ProductServlet] === NEW REQUEST ===");
        System.out.println("[ProductServlet] role=" + role
                         + ", userId=" + (session != null ? session.getAttribute("userId") : "null")
                         + ", keyword=" + (keyword != null ? "\"" + keyword + "\"" : "null"));

        req.setAttribute("debugRole", role);
        req.setAttribute("role", role);

        try {
            List<Product> products = loadProducts(role, session, keyword);
            int totalCount = getTotalCount(role, session);

            req.setAttribute("products", products);
            req.setAttribute("totalProductCount", totalCount);

            if (keyword != null) {
                req.setAttribute("searchKeyword", keyword.trim());
            }

            System.out.println("[ProductServlet] SUCCESS — dispatching with " + products.size() + " products");

        } catch (ShopNotApprovedException e) {
            System.out.println("[ProductServlet] ShopNotApprovedException: " + e.getMessage());
            req.setAttribute("shopNotApproved", true);
            req.setAttribute("shopNotApprovedMsg", e.getMessage());
            req.setAttribute("products", Collections.emptyList());
            req.setAttribute("totalProductCount", 0);

        } catch (Exception e) {
            System.err.println("[ProductServlet] loadProducts() FAILED:");
            e.printStackTrace();
            req.setAttribute("error", "Khong the tai danh sach san pham: " + e.getMessage());
            req.setAttribute("products", Collections.emptyList());
            req.setAttribute("totalProductCount", 0);
        }

        req.getRequestDispatcher("/products.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/products");
    }

    // -----------------------------------------------------------------
    // Product detail handler
    // -----------------------------------------------------------------
    private void handleProductDetail(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String idParam = req.getParameter("id").trim();
        int productId;
        try {
            productId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID san pham khong hop le.");
            resp.sendRedirect(req.getContextPath() + "/products");
            return;
        }

        ProductDAO productDAO = new ProductDAO();
        try {
            Product product = productDAO.getProductById(productId);

            if (product == null || product.isIsDelete()) {
                session.setAttribute("error", "San pham khong ton tai hoac da bi xoa.");
                resp.sendRedirect(req.getContextPath() + "/products");
                return;
            }

            // Load category name
            String categoryName = "-";
            try {
                CategoryDAO categoryDAO = new CategoryDAO();
                try {
                    List<Category> allCats = categoryDAO.getAllActiveCategories();
                    for (Category c : allCats) {
                        if (c.getId() == product.getCategoryId()) {
                            categoryName = c.getName();
                            break;
                        }
                    }
                } finally {
                    categoryDAO.close();
                }
            } catch (Exception ex) {
                System.err.println("[ProductServlet] load category name failed: " + ex.getMessage());
            }

            // Load shop info
            Shop shopInfo = null;
            if (product.getShopId() > 0) {
                try {
                    ShopDAO shopDAO = new ShopDAO();
                    try {
                        shopInfo = shopDAO.getShopById(product.getShopId());
                    } finally {
                        shopDAO.close();
                    }
                } catch (Exception ex) {
                    System.err.println("[ProductServlet] load shop info failed: " + ex.getMessage());
                }
            }

            req.setAttribute("product", product);
            req.setAttribute("categoryName", categoryName);
            if (shopInfo != null) {
                req.setAttribute("shopInfo", shopInfo);
            }

            req.getRequestDispatcher("/product-detail.jsp").forward(req, resp);

        } finally {
            productDAO.close();
        }
    }

    // -----------------------------------------------------------------
    // Lay danh sach san pham theo role
    // -----------------------------------------------------------------
    private List<Product> loadProducts(String role, HttpSession session, String keyword) throws Exception {
        if (ROLE_SELLER.equals(role)) {
            return loadSellerProducts(session, keyword);
        }
        return loadUserProducts(keyword);
    }

    // -----------------------------------------------------------------
    // Seller: chi thay san pham cua shop minh
    // -----------------------------------------------------------------
    private List<Product> loadSellerProducts(HttpSession session, String keyword) throws Exception {
        Integer userIdObj = (session != null) ? (Integer) session.getAttribute("userId") : null;
        int userId = (userIdObj != null) ? userIdObj : 0;

        System.out.println("[ProductServlet.loadSellerProducts] userId=" + userId);

        if (userId == 0) {
            throw new IllegalStateException("Khong xac dinh duoc nguoi dung. Vui long dang nhap lai.");
        }

        ShopDAO shopDAO = new ShopDAO();
        try {
            // Buoc 1: kiem tra co shop approved khong
            boolean hasApprovedShop = shopDAO.hasApprovedShop(userId);
            System.out.println("[ProductServlet.loadSellerProducts] hasApprovedShop=" + hasApprovedShop);

            if (!hasApprovedShop) {
                throw new ShopNotApprovedException(
                    "Cua hang cua ban chua duoc phe duyet. Vui long cho admin xac nhan hoac tao cua hang moi.");
            }

            // Buoc 2: lay shop info
            Shop shop = shopDAO.getShopByOwnerId(userId);
            System.out.println("[ProductServlet.loadSellerProducts] shop=" + (shop != null ? shop.getId() + "/" + shop.getShopName() : "null"));

            if (shop == null) {
                throw new IllegalStateException("Khong tim thay thong tin cua hang. Lien he admin.");
            }

            // Buoc 3: lay san pham
            return fetchProductsForShop(shop.getId(), keyword);

        } finally {
            shopDAO.close();
        }
    }

    private List<Product> fetchProductsForShop(int shopId, String keyword) throws Exception {
        ProductDAO dao = new ProductDAO();
        try {
            if (keyword != null && !keyword.trim().isEmpty()) {
                System.out.println("[ProductServlet.fetchProductsForShop] searching keyword='" + keyword.trim() + "'");
                return filterByShopId(dao.searchProducts(keyword.trim()), shopId);
            }
            System.out.println("[ProductServlet.fetchProductsForShop] loading all for shopId=" + shopId);
            return dao.getProductsByShopId(shopId);
        } finally {
            dao.close();
        }
    }

    // -----------------------------------------------------------------
    // Account / khach: thay tat ca san pham
    // -----------------------------------------------------------------
    private List<Product> loadUserProducts(String keyword) throws Exception {
        System.out.println("[ProductServlet.loadUserProducts] loading all products");
        ProductDAO dao = new ProductDAO();
        try {
            if (keyword != null && !keyword.trim().isEmpty()) {
                System.out.println("[ProductServlet.loadUserProducts] searching '" + keyword.trim() + "'");
                return dao.searchProducts(keyword.trim());
            }
            return dao.getAllProducts();
        } finally {
            dao.close();
        }
    }

    // -----------------------------------------------------------------
    // Dem tong so (cho hien thi header)
    // -----------------------------------------------------------------
    private int getTotalCount(String role, HttpSession session) {
        try {
            if (ROLE_SELLER.equals(role)) {
                Integer userIdObj = (Integer) session.getAttribute("userId");
                if (userIdObj == null) return 0;
                ShopDAO shopDAO = new ShopDAO();
                try {
                    Shop shop = shopDAO.getShopByOwnerId(userIdObj);
                    if (shop == null) return 0;
                    ProductDAO pdao = new ProductDAO();
                    try {
                        return pdao.countProductsByShopId(shop.getId());
                    } finally {
                        pdao.close();
                    }
                } finally {
                    shopDAO.close();
                }
            } else {
                ProductDAO dao = new ProductDAO();
                try {
                    return dao.countAllProducts();
                } finally {
                    dao.close();
                }
            }
        } catch (Exception e) {
            System.err.println("[ProductServlet.getTotalCount] failed: " + e.getMessage());
            return 0;
        }
    }

    // -----------------------------------------------------------------
    // Loc san pham theo shopId (null-safe)
    // -----------------------------------------------------------------
    private List<Product> filterByShopId(List<Product> list, int shopId) {
        if (list == null) {
            return Collections.emptyList();
        }
        return list.stream()
                .filter(p -> p != null && p.getShopId() == shopId)
                .collect(java.util.stream.Collectors.toList());
    }

    // -----------------------------------------------------------------
    // Custom exception: shop chua approved
    // -----------------------------------------------------------------
    public static class ShopNotApprovedException extends Exception {
        public ShopNotApprovedException(String message) {
            super(message);
        }
    }
}

