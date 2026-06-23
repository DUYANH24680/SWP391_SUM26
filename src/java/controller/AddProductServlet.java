package controller;

import dao.CategoryDAO;
import dao.ProductDAO;
import dao.ProductVariantDAO;
import dao.ShopDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.Category;
import model.Product;
import model.ProductVariant;
import model.Shop;
import Utils.FileUploadUtil;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@WebServlet(name = "AddProductServlet", urlPatterns = {"/add-product"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 20 * 1024 * 1024
)
public class AddProductServlet extends HttpServlet {

    // ===== GET: hien thi form them san pham =====
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);

        // TODO: bo phan quyen, chi test
        int ownerId = 1; // mac dinh cho test

        if (session != null && session.getAttribute("userId") != null) {
            try {
                ownerId = (Integer) session.getAttribute("userId");
            } catch (Exception ignored) {}
        }

        ShopDAO shopDAO = new ShopDAO();
        int shopId = 1;
        try {
            Shop shop = shopDAO.getShopByOwnerId(ownerId);
            if (shop != null) {
                shopId = shop.getId();
            }
        } catch (Exception e) {
            System.out.println("[AddProductServlet] Shop lookup failed, using default shopId=1: " + e.getMessage());
        } finally {
            shopDAO.close();
        }

        CategoryDAO categoryDAO = new CategoryDAO();
        try {
            List<Category> categories = categoryDAO.getAllCategories(false);
            req.setAttribute("categories", categories);
            System.out.println("[AddProductServlet] Forwarding to add-product.jsp with " + categories.size() + " categories");
        } catch (RuntimeException e) {
            System.err.println("[AddProductServlet] Failed to load categories (DB may be slow/unavailable): " + e.getMessage());
            req.setAttribute("categories", java.util.Collections.emptyList());
            if (session != null) {
                session.setAttribute("error", "Khong the tai danh muc. Vui long thu lai sau.");
            }
        } finally {
            categoryDAO.close();
        }

        req.getRequestDispatcher("/add-product.jsp").forward(req, resp);
    }

    // ===== POST: xu ly tao san pham moi =====
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);

        // TODO: bo phan quyen, chi test
        int ownerId = 1;

        if (session != null && session.getAttribute("userId") != null) {
            try {
                ownerId = (Integer) session.getAttribute("userId");
            } catch (Exception ignored) {}
        }

        ShopDAO shopDAO = new ShopDAO();
        Shop shop = null;
        try {
            shop = shopDAO.getShopByOwnerId(ownerId);
            if (shop == null) {
                shop = new Shop();
                shop.setId(1);
                System.out.println("[AddProductServlet] Shop not found, using default shopId=1");
            }
        } catch (Exception e) {
            System.out.println("[AddProductServlet] Shop lookup failed: " + e.getMessage());
            shop = new Shop();
            shop.setId(1);
        } finally {
            shopDAO.close();
        }

        int shopId = shop.getId();

        // Parse parameters
        String title = req.getParameter("title");
        String description = req.getParameter("description");
        String unit = req.getParameter("unit");
        String stockStr = req.getParameter("stockQuantity");
        String originalPriceStr = req.getParameter("originalPrice");
        String salePriceStr = req.getParameter("salePrice");
        String categoryIdStr = req.getParameter("categoryId");
        String expiredDateStr = req.getParameter("expiredDate");

        System.out.println("[AddProductServlet.doPost] Parameters received:");
        System.out.println("  title          = " + title);
        System.out.println("  description    = " + description);
        System.out.println("  unit           = " + unit);
        System.out.println("  stockQuantity  = " + stockStr);
        System.out.println("  originalPrice  = " + originalPriceStr);
        System.out.println("  salePrice      = " + salePriceStr);
        System.out.println("  categoryId     = " + categoryIdStr);
        System.out.println("  expiredDate    = " + expiredDateStr);

        if (title == null || title.trim().isEmpty()
                || description == null || description.trim().isEmpty()
                || unit == null || unit.trim().isEmpty()
                || stockStr == null || stockStr.trim().isEmpty()
                || originalPriceStr == null || originalPriceStr.trim().isEmpty()
                || salePriceStr == null || salePriceStr.trim().isEmpty()
                || categoryIdStr == null || categoryIdStr.trim().isEmpty()) {
            if (session != null) {
                session.setAttribute("error", "Vui long dien day du thong tin bat buoc.");
            }
            System.out.println("[AddProductServlet.doPost] Validation failed: missing required fields");
            resp.sendRedirect(req.getContextPath() + "/add-product");
            return;
        }

        int stockQuantity;
        double originalPrice;
        double salePrice;
        int categoryId;
        Timestamp expiredDate = null;

        try {
            stockQuantity = Integer.parseInt(stockStr.trim());
            originalPrice = Double.parseDouble(originalPriceStr.trim());
            salePrice = Double.parseDouble(salePriceStr.trim());
            categoryId = Integer.parseInt(categoryIdStr.trim());
        } catch (NumberFormatException e) {
            if (session != null) {
                session.setAttribute("error", "Du lieu so khong hop le.");
            }
            resp.sendRedirect(req.getContextPath() + "/add-product");
            return;
        }

        if (expiredDateStr != null && !expiredDateStr.trim().isEmpty()) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                sdf.setLenient(false);
                Date utilDate = sdf.parse(expiredDateStr.trim());
                expiredDate = new Timestamp(utilDate.getTime());
            } catch (ParseException e) {
                if (session != null) {
                    session.setAttribute("error", "Dinh dang ngay het han khong hop le (dinh dang: yyyy-MM-dd).");
                }
                resp.sendRedirect(req.getContextPath() + "/add-product");
                return;
            }
        }

        // Upload images
        List<String> imageUrls = new ArrayList<>();
        List<Part> fileParts;
        try {
            fileParts = req.getParts().stream()
                    .filter(p -> p.getName().equals("images") && p.getContentType() != null)
                    .toList();
        } catch (Exception e) {
            if (session != null) {
                session.setAttribute("error", "Loi khi doc file upload: " + e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/add-product");
            return;
        }

        boolean uploadError = false;
        String uploadErrorMsg = null;
        for (Part part : fileParts) {
            if (part.getSize() > 0) {
                try {
                    String imagePath = FileUploadUtil.saveProductImage(part, String.valueOf(shopId));
                    imageUrls.add(imagePath);
                } catch (Exception e) {
                    uploadError = true;
                    uploadErrorMsg = e.getMessage();
                    break;
                }
            }
        }

        if (uploadError) {
            if (session != null) {
                session.setAttribute("error", "Loi upload anh: " + uploadErrorMsg);
            }
            resp.sendRedirect(req.getContextPath() + "/add-product");
            return;
        }

        // Build product
        Product product = new Product();
        product.setTitle(title.trim());
        product.setDescription(description.trim());
        product.setUnit(unit.trim());
        product.setStockQuantity(stockQuantity);
        product.setOriginalPrice(originalPrice);
        product.setSalePrice(salePrice);
        product.setCategoryId(categoryId);
        product.setShopId(shopId);
        product.setExpiredDate(expiredDate);
        product.setStatus(0);

        ProductDAO productDAO = new ProductDAO();
        try {
            boolean success = productDAO.addProduct(product, imageUrls);
            if (success) {
                // Parse & insert variants
                List<ProductVariant> variants = parseVariants(req);
                if (!variants.isEmpty()) {
                    ProductVariantDAO variantDAO = new ProductVariantDAO();
                    try {
                        variantDAO.insertVariants(product.getId(), variants);
                    } finally {
                        variantDAO.close();
                    }
                }

                if (session != null) {
                    session.setAttribute("message", "San pham da duoc tao thanh cong va dang cho duyet!");
                }
                resp.sendRedirect(req.getContextPath() + "/products");
            } else {
                if (session != null) {
                    session.setAttribute("error", "Khong the tao san pham. Vui long thu lai.");
                }
                resp.sendRedirect(req.getContextPath() + "/add-product");
            }
        } finally {
            productDAO.close();
        }
    }

    // ===== Parse variant parameters =====
    private List<ProductVariant> parseVariants(HttpServletRequest req) {
        List<ProductVariant> variants = new ArrayList<>();
        String[] weights  = req.getParameterValues("variantWeight");
        String[] units    = req.getParameterValues("variantUnit");
        String[] prices   = req.getParameterValues("variantPrice");
        String[] stocks   = req.getParameterValues("variantStock");

        if (weights == null) {
            return variants;
        }

        for (int i = 0; i < weights.length; i++) {
            String weight = weights[i];
            if (weight == null || weight.trim().isEmpty()) {
                continue; // skip empty rows
            }

            ProductVariant v = new ProductVariant();

            String w = weight.trim();
            String u = (units != null && units.length > i && units[i] != null) ? units[i].trim() : "";
            v.setWeightValue(w);
            v.setWeightUnit(u);

            if (prices != null && prices.length > i && prices[i] != null && !prices[i].trim().isEmpty()) {
                try {
                    v.setPrice(Double.parseDouble(prices[i].trim()));
                } catch (NumberFormatException ignored) {}
            }

            if (stocks != null && stocks.length > i && stocks[i] != null && !stocks[i].trim().isEmpty()) {
                try {
                    v.setStockQuantity(Integer.parseInt(stocks[i].trim()));
                } catch (NumberFormatException ignored) {}
            }

            variants.add(v);
        }

        System.out.println("[AddProductServlet] parseVariants() parsed " + variants.size() + " valid variants");
        return variants;
    }
}
