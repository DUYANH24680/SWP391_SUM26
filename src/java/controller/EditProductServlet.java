package controller;

import dao.CategoryDAO;
import dao.ProductDAO;
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
import model.Shop;
import Utils.FileUploadUtil;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@WebServlet(name = "EditProductServlet", urlPatterns = {"/edit-product"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 20 * 1024 * 1024
)
public class EditProductServlet extends HttpServlet {

    // ===== GET: hien thi form chinh sua san pham =====
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);

        String productIdStr = req.getParameter("id");
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            if (session != null) {
                session.setAttribute("error", "Truy cap khong hop le: thieu ma san pham.");
            }
            resp.sendRedirect(req.getContextPath() + "/products");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            if (session != null) {
                session.setAttribute("error", "Ma san pham khong hop le.");
            }
            resp.sendRedirect(req.getContextPath() + "/products");
            return;
        }

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
        } catch (Exception e) {
            System.out.println("[EditProductServlet] Shop lookup failed: " + e.getMessage());
        } finally {
            shopDAO.close();
        }

        if (shop == null) {
            if (session != null) {
                session.setAttribute("error", "Khong tim thay cua hang cua ban.");
            }
            resp.sendRedirect(req.getContextPath() + "/products");
            return;
        }

        int shopId = shop.getId();

        ProductDAO productDAO = new ProductDAO();
        Product product;
        try {
            product = productDAO.getProductByIdForEdit(productId, shopId);
        } finally {
            productDAO.close();
        }

        if (product == null) {
            if (session != null) {
                session.setAttribute("error", "San pham khong ton tai hoac ban khong co quyen chinh sua.");
            }
            resp.sendRedirect(req.getContextPath() + "/products");
            return;
        }

        CategoryDAO categoryDAO = new CategoryDAO();
        List<Category> categories;
        try {
            categories = categoryDAO.getAllCategories(false);
        } catch (RuntimeException e) {
            System.err.println("[EditProductServlet] Failed to load categories: " + e.getMessage());
            categories = java.util.Collections.emptyList();
            if (session != null) {
                session.setAttribute("error", "Khong the tai danh muc. Vui long thu lai sau.");
            }
        } finally {
            categoryDAO.close();
        }

        ProductDAO productDAO2 = new ProductDAO();
        List<String> currentImages;
        try {
            currentImages = productDAO2.getProductImageUrls(productId);
        } finally {
            productDAO2.close();
        }

        req.setAttribute("product", product);
        req.setAttribute("categories", categories);
        req.setAttribute("currentImages", currentImages);
        System.out.println("[EditProductServlet] Forwarding to edit-product.jsp (productId="
            + productId + ", images=" + currentImages.size() + ")");
        req.getRequestDispatcher("/seller/edit-product.jsp").forward(req, resp);
    }

    // ===== POST: xu ly cap nhat san pham =====
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);

        String productIdStr = req.getParameter("productId");
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            if (session != null) {
                session.setAttribute("error", "Truy cap khong hop le: thieu ma san pham.");
            }
            resp.sendRedirect(req.getContextPath() + "/products");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            if (session != null) {
                session.setAttribute("error", "Ma san pham khong hop le.");
            }
            resp.sendRedirect(req.getContextPath() + "/products");
            return;
        }

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
                System.out.println("[EditProductServlet] Shop not found, using default shopId=1");
            }
        } catch (Exception e) {
            System.out.println("[EditProductServlet] Shop lookup failed: " + e.getMessage());
            shop = new Shop();
            shop.setId(1);
        } finally {
            shopDAO.close();
        }

        int shopId = shop.getId();

        // Ownership check
        ProductDAO checkDAO = new ProductDAO();
        Product existing = null;
        try {
            existing = checkDAO.getProductByIdForEdit(productId, shopId);
        } finally {
            checkDAO.close();
        }

        if (existing == null) {
            if (session != null) {
                session.setAttribute("error", "San pham khong ton tai hoac ban khong co quyen chinh sua.");
            }
            resp.sendRedirect(req.getContextPath() + "/products");
            return;
        }

        // Parse parameters
        String title = req.getParameter("title");
        String description = req.getParameter("description");
        String unit = req.getParameter("unit");
        String stockStr = req.getParameter("stockQuantity");
        String originalPriceStr = req.getParameter("originalPrice");
        String salePriceStr = req.getParameter("salePrice");
        String categoryIdStr = req.getParameter("categoryId");
        String expiredDateStr = req.getParameter("expiredDate");
        String statusStr = req.getParameter("status");
        String replaceImagesStr = req.getParameter("replaceImages");

        System.out.println("[EditProductServlet.doPost] productId=" + productId + ", replaceImages=" + replaceImagesStr);

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
            resp.sendRedirect(req.getContextPath() + "/edit-product?id=" + productId);
            return;
        }

        int stockQuantity;
        double originalPrice;
        double salePrice;
        int categoryId;
        int status;
        Timestamp expiredDate = null;

        try {
            stockQuantity = Integer.parseInt(stockStr.trim());
            originalPrice = Double.parseDouble(originalPriceStr.trim());
            salePrice = Double.parseDouble(salePriceStr.trim());
            categoryId = Integer.parseInt(categoryIdStr.trim());
            status = (statusStr != null && !statusStr.trim().isEmpty())
                    ? Integer.parseInt(statusStr.trim()) : existing.getStatus();
        } catch (NumberFormatException e) {
            if (session != null) {
                session.setAttribute("error", "Du lieu so khong hop le.");
            }
            resp.sendRedirect(req.getContextPath() + "/edit-product?id=" + productId);
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
                resp.sendRedirect(req.getContextPath() + "/edit-product?id=" + productId);
                return;
            }
        }

        // Build updated product
        Product product = new Product();
        product.setId(productId);
        product.setTitle(title.trim());
        product.setDescription(description.trim());
        product.setUnit(unit.trim());
        product.setStockQuantity(stockQuantity);
        product.setOriginalPrice(originalPrice);
        product.setSalePrice(salePrice);
        product.setCategoryId(categoryId);
        product.setShopId(shopId);
        product.setSellerId(ownerId);
        product.setExpiredDate(expiredDate);
        product.setStatus(status);

        List<String> newImageUrls = null;
        if ("true".equalsIgnoreCase(replaceImagesStr)) {
            List<Part> fileParts;
            try {
                fileParts = req.getParts().stream()
                        .filter(p -> p.getName().equals("images") && p.getContentType() != null)
                        .toList();
            } catch (Exception e) {
                if (session != null) {
                    session.setAttribute("error", "Loi khi doc file upload: " + e.getMessage());
                }
                resp.sendRedirect(req.getContextPath() + "/edit-product?id=" + productId);
                return;
            }

            boolean uploadError = false;
            String uploadErrorMsg = null;
            for (Part part : fileParts) {
                if (part.getSize() > 0) {
                    try {
                        String imagePath = FileUploadUtil.saveProductImage(part, String.valueOf(shopId), getServletContext());
                        newImageUrls = (newImageUrls == null) ? new ArrayList<>() : newImageUrls;
                        newImageUrls.add(imagePath);
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
                resp.sendRedirect(req.getContextPath() + "/edit-product?id=" + productId);
                return;
            }
        }

        ProductDAO productDAO = new ProductDAO();
        try {
            boolean success = productDAO.updateProduct(product, newImageUrls);
            if (success) {
                if (session != null) {
                    session.setAttribute("message", "San pham da duoc cap nhat thanh cong!");
                }
                resp.sendRedirect(req.getContextPath() + "/products");
            } else {
                if (session != null) {
                    session.setAttribute("error", "Khong the cap nhat san pham. Vui long thu lai.");
                }
                resp.sendRedirect(req.getContextPath() + "/edit-product?id=" + productId);
            }
        } finally {
            productDAO.close();
        }
    }
}

 