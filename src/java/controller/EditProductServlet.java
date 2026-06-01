package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.Seller;
import model.Product;
import model.Category;
import service.CategoryService;
import service.ProductService;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.sql.Date;
import java.util.List;

@WebServlet("/seller/edit-product")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 10 * 1024 * 1024
)
public class EditProductServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "images" + File.separator + "products";
    private static final String[] ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".gif"};
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024;

    private final CategoryService categoryService = new CategoryService();
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
            session.setAttribute("message", "San pham khong ton tai.");
            response.sendRedirect(request.getContextPath() + "/seller/products");
            return;
        }

        if (product.getSellerId() != seller.getId()) {
            session.setAttribute("message", "Ban khong co quyen chinh sua san pham nay.");
            response.sendRedirect(request.getContextPath() + "/seller/products");
            return;
        }

        List<Category> categories = categoryService.getAllActiveCategories();
        request.setAttribute("categories", categories);
        request.setAttribute("product", product);

        if (request.getAttribute("error") != null) {
            request.setAttribute("product", product);
        }

        request.getRequestDispatcher("/seller/edit-product.jsp").forward(request, response);
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

        Product existing = productService.getById(productId);
        if (existing == null) {
            session.setAttribute("message", "San pham khong ton tai.");
            response.sendRedirect(request.getContextPath() + "/seller/products");
            return;
        }

        if (existing.getSellerId() != seller.getId()) {
            session.setAttribute("message", "Ban khong co quyen chinh sua san pham nay.");
            response.sendRedirect(request.getContextPath() + "/seller/products");
            return;
        }

        String title = request.getParameter("title");
        String desc = request.getParameter("description");
        String unit = request.getParameter("unit");
        String stockStr = request.getParameter("stockQuantity");
        String originalPriceStr = request.getParameter("originalPrice");
        String salePriceStr = request.getParameter("salePrice");
        String expiredDateStr = request.getParameter("expiredDate");
        String categoryIdStr = request.getParameter("categoryId");
        String statusStr = request.getParameter("status");
        String isFeaturedStr = request.getParameter("isFeatured");
        String keepImageStr = request.getParameter("keepImage");

        List<Category> categories = categoryService.getAllActiveCategories();
        request.setAttribute("categories", categories);

        StringBuilder errors = new StringBuilder();
        if (isEmpty(title) || title.trim().length() < 3) {
            errors.append("Ten san pham phai tu 3 ky tu tro len. ");
        } else if (title.trim().length() > 255) {
            errors.append("Ten san pham khong duoc qua 255 ky tu. ");
        }
        if (isEmpty(categoryIdStr)) {
            errors.append("Vui long chon danh muc. ");
        }
        if (isEmpty(originalPriceStr)) {
            errors.append("Gia goc khong duoc de trong. ");
        }
        if (isEmpty(unit)) {
            errors.append("Don vi tinh khong duoc de trong. ");
        }
        if (isEmpty(stockStr)) {
            errors.append("So luong ton kho khong duoc de trong. ");
        } else {
            try {
                int stockQty = Integer.parseInt(stockStr);
                if (stockQty < 0) {
                    errors.append("So luong ton kho phai lon hon hoac bang 0. ");
                } else if (stockQty > 99999) {
                    errors.append("So luong ton kho khong duoc vuot qua 99.999. ");
                }
            } catch (NumberFormatException e) {
                errors.append("So luong ton kho khong hop le. ");
            }
        }

        if (errors.length() > 0) {
            Product p = buildProductFromParams(request, productId, seller.getId());
            request.setAttribute("error", errors.toString().trim());
            request.setAttribute("product", p);
            request.getRequestDispatcher("/seller/edit-product.jsp").forward(request, response);
            return;
        }

        int categoryId;
        try {
            categoryId = Integer.parseInt(categoryIdStr);
        } catch (NumberFormatException e) {
            Product p = buildProductFromParams(request, productId, seller.getId());
            request.setAttribute("error", "Danh muc khong hop le.");
            request.setAttribute("product", p);
            request.getRequestDispatcher("/seller/edit-product.jsp").forward(request, response);
            return;
        }

        BigDecimal originalPrice;
        try {
            originalPrice = new BigDecimal(originalPriceStr);
            if (originalPrice.compareTo(BigDecimal.ZERO) <= 0) {
                Product p = buildProductFromParams(request, productId, seller.getId());
                request.setAttribute("error", "Gia goc phai lon hon 0.");
                request.setAttribute("product", p);
                request.getRequestDispatcher("/seller/edit-product.jsp").forward(request, response);
                return;
            }
        } catch (NumberFormatException e) {
            Product p = buildProductFromParams(request, productId, seller.getId());
            request.setAttribute("error", "Gia goc khong hop le.");
            request.setAttribute("product", p);
            request.getRequestDispatcher("/seller/edit-product.jsp").forward(request, response);
            return;
        }

        BigDecimal salePrice = null;
        if (!isEmpty(salePriceStr)) {
            try {
                salePrice = new BigDecimal(salePriceStr);
                if (salePrice.compareTo(BigDecimal.ZERO) < 0) {
                    Product p = buildProductFromParams(request, productId, seller.getId());
                    request.setAttribute("error", "Gia ban khong duoc la so am.");
                    request.setAttribute("product", p);
                    request.getRequestDispatcher("/seller/edit-product.jsp").forward(request, response);
                    return;
                }
                if (salePrice.compareTo(originalPrice) > 0) {
                    Product p = buildProductFromParams(request, productId, seller.getId());
                    request.setAttribute("error", "Gia ban khong duoc lon hon gia goc.");
                    request.setAttribute("product", p);
                    request.getRequestDispatcher("/seller/edit-product.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                Product p = buildProductFromParams(request, productId, seller.getId());
                request.setAttribute("error", "Gia ban khong hop le.");
                request.setAttribute("product", p);
                request.getRequestDispatcher("/seller/edit-product.jsp").forward(request, response);
                return;
            }
        }

        int stockQuantity;
        try {
            stockQuantity = Integer.parseInt(stockStr);
            if (stockQuantity < 0) {
                Product p = buildProductFromParams(request, productId, seller.getId());
                request.setAttribute("error", "So luong ton kho khong duoc la so am.");
                request.setAttribute("product", p);
                request.getRequestDispatcher("/seller/edit-product.jsp").forward(request, response);
                return;
            }
        } catch (NumberFormatException e) {
            Product p = buildProductFromParams(request, productId, seller.getId());
            request.setAttribute("error", "So luong ton kho khong hop le.");
            request.setAttribute("product", p);
            request.getRequestDispatcher("/seller/edit-product.jsp").forward(request, response);
            return;
        }

        int status = 0;
        if (!isEmpty(statusStr)) {
            try {
                status = Integer.parseInt(statusStr);
                if (status < 0 || status > 2) {
                    status = 0;
                }
            } catch (NumberFormatException e) {
                status = 0;
            }
        }

        boolean isFeatured = "1".equals(isFeaturedStr);

        Date expiredDate = null;
        if (!isEmpty(expiredDateStr)) {
            try {
                expiredDate = Date.valueOf(expiredDateStr);
            } catch (IllegalArgumentException e) {
                Product p = buildProductFromParams(request, productId, seller.getId());
                request.setAttribute("error", "Ngay het han khong hop le.");
                request.setAttribute("product", p);
                request.getRequestDispatcher("/seller/edit-product.jsp").forward(request, response);
                return;
            }
        }

        String imageUrl = existing.getImage();
        if (!"true".equals(keepImageStr)) {
            Part filePart = request.getPart("image");
            if (filePart != null && filePart.getSize() > 0) {
                String contentType = filePart.getContentType();
                if (contentType == null || !contentType.startsWith("image/")) {
                    Product p = buildProductFromParams(request, productId, seller.getId());
                    request.setAttribute("error", "Chi chap nhan file hinh anh.");
                    request.setAttribute("product", p);
                    request.getRequestDispatcher("/seller/edit-product.jsp").forward(request, response);
                    return;
                }
                if (filePart.getSize() > MAX_FILE_SIZE) {
                    Product p = buildProductFromParams(request, productId, seller.getId());
                    request.setAttribute("error", "Kich thuoc file khong duoc vuot qua 5MB.");
                    request.setAttribute("product", p);
                    request.getRequestDispatcher("/seller/edit-product.jsp").forward(request, response);
                    return;
                }

                String originalFilename = Paths.get(filePart.getSubmittedFileName()).getFileName().toString().toLowerCase();
                String ext = "";
                for (String allowed : ALLOWED_EXTENSIONS) {
                    if (originalFilename.endsWith(allowed)) {
                        ext = allowed;
                        break;
                    }
                }
                if (ext.isEmpty()) {
                    Product p = buildProductFromParams(request, productId, seller.getId());
                    request.setAttribute("error", "Dinh dang anh khong ho tro. Chi chap nhan: JPG, PNG, WEBP, GIF.");
                    request.setAttribute("product", p);
                    request.getRequestDispatcher("/seller/edit-product.jsp").forward(request, response);
                    return;
                }

                String savedFileName = System.currentTimeMillis() + "_" + System.nanoTime() + ext;
                String uploadPath = getServletContext().getRealPath("/") + UPLOAD_DIR;
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                String savedPath = uploadPath + File.separator + savedFileName;
                try {
                    filePart.write(savedPath);
                    imageUrl = request.getContextPath() + "/images/products/" + savedFileName;
                } catch (IOException e) {
                    Product p = buildProductFromParams(request, productId, seller.getId());
                    request.setAttribute("error", "Loi khi luu anh. Vui long thu lai.");
                    request.setAttribute("product", p);
                    request.getRequestDispatcher("/seller/edit-product.jsp").forward(request, response);
                    return;
                }
            }
        }

        Product product = new Product();
        product.setId(productId);
        product.setCategoryId(categoryId);
        product.setSellerId(seller.getId());
        product.setTitle(title.trim());
        product.setImage(imageUrl);
        product.setDescription(desc != null ? desc.trim() : null);
        product.setUnit(unit.trim());
        product.setStockQuantity(stockQuantity);
        product.setOriginalPrice(originalPrice);
        product.setSalePrice(salePrice);
        product.setExpiredDate(expiredDate);
        product.setStatus(status);
        product.setIsFeatured(isFeatured);

        String error = productService.updateProduct(product);
        if (error != null) {
            request.setAttribute("error", error);
            request.setAttribute("product", product);
            request.getRequestDispatcher("/seller/edit-product.jsp").forward(request, response);
            return;
        }

        session.setAttribute("message", "Cap nhat san pham thanh cong!");
        response.sendRedirect(request.getContextPath() + "/seller/products");
    }

    private Product buildProductFromParams(HttpServletRequest request, int productId, int sellerId) {
        Product p = new Product();
        p.setId(productId);
        p.setSellerId(sellerId);
        p.setTitle(request.getParameter("title"));
        p.setDescription(request.getParameter("description"));
        p.setUnit(request.getParameter("unit"));
        try { p.setStockQuantity(Integer.parseInt(request.getParameter("stockQuantity"))); } catch (Exception e) { }
        try { p.setOriginalPrice(new BigDecimal(request.getParameter("originalPrice"))); } catch (Exception e) { }
        try { p.setSalePrice(new BigDecimal(request.getParameter("salePrice"))); } catch (Exception e) { }
        try { p.setCategoryId(Integer.parseInt(request.getParameter("categoryId"))); } catch (Exception e) { }
        try { p.setStatus(Integer.parseInt(request.getParameter("status"))); } catch (Exception e) { }
        p.setIsFeatured("1".equals(request.getParameter("isFeatured")));
        try { p.setExpiredDate(Date.valueOf(request.getParameter("expiredDate"))); } catch (Exception e) { }
        return p;
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

    private boolean isEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }
}
