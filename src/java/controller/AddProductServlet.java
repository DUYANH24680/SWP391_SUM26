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
import service.CategoryService;
import service.ProductService;
import model.Product;
import model.Category;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.sql.Date;
import java.util.List;

@WebServlet("/seller/add-product")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 10 * 1024 * 1024
)
public class AddProductServlet extends HttpServlet {

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

        List<Category> categories = categoryService.getAllActiveCategories();
        request.setAttribute("categories", categories);

        request.getRequestDispatcher("/seller/add-product.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isSellerLoggedIn(session)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Seller seller = (Seller) session.getAttribute("account");
        if (seller == null) {
            seller = (Seller) session.getAttribute("user");
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

        List<Category> categories = categoryService.getAllActiveCategories();
        request.setAttribute("categories", categories);

        StringBuilder errors = new StringBuilder();
        if (isEmpty(title) || title.trim().length() < 3) {
            errors.append("Ten san pham phai tu 3 ky tu tro len. ");
        } else if (title.trim().length() > 255) {
            errors.append("Ten san pham khong duoc qua 255 ky tu. ");
        }
        if (isEmpty(categoryIdStr)) {
            errors.append("Vui lòng chọn danh mục. ");
        }
        if (isEmpty(originalPriceStr)) {
            errors.append("Giá gốc không được để trống. ");
        }
        if (isEmpty(unit)) {
            errors.append("Đơn vị tính không được để trống. ");
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
            request.setAttribute("error", errors.toString().trim());
            request.getRequestDispatcher("/seller/add-product.jsp").forward(request, response);
            return;
        }

        int categoryId;
        try {
            categoryId = Integer.parseInt(categoryIdStr);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Danh mục không hợp lệ.");
            request.getRequestDispatcher("/seller/add-product.jsp").forward(request, response);
            return;
        }

        BigDecimal originalPrice;
        try {
            originalPrice = new BigDecimal(originalPriceStr);
            if (originalPrice.compareTo(BigDecimal.ZERO) <= 0) {
                request.setAttribute("error", "Giá gốc phải lớn hơn 0.");
                request.getRequestDispatcher("/seller/add-product.jsp").forward(request, response);
                return;
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Giá gốc không hợp lệ.");
            request.getRequestDispatcher("/seller/add-product.jsp").forward(request, response);
            return;
        }

        BigDecimal salePrice = null;
        if (!isEmpty(salePriceStr)) {
            try {
                salePrice = new BigDecimal(salePriceStr);
                if (salePrice.compareTo(BigDecimal.ZERO) < 0) {
                    request.setAttribute("error", "Giá bán không được là số âm.");
                    request.getRequestDispatcher("/seller/add-product.jsp").forward(request, response);
                    return;
                }
                if (salePrice.compareTo(originalPrice) > 0) {
                    request.setAttribute("error", "Giá bán không được lớn hơn giá gốc.");
                    request.getRequestDispatcher("/seller/add-product.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Giá bán không hợp lệ.");
                request.getRequestDispatcher("/seller/add-product.jsp").forward(request, response);
                return;
            }
        }

        int stockQuantity;
        try {
            stockQuantity = Integer.parseInt(stockStr);
            if (stockQuantity < 0) {
                request.setAttribute("error", "Số lượng tồn kho không được là số âm.");
                request.getRequestDispatcher("/seller/add-product.jsp").forward(request, response);
                return;
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Số lượng tồn kho không hợp lệ.");
            request.getRequestDispatcher("/seller/add-product.jsp").forward(request, response);
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
                request.setAttribute("error", "Ngày hết hạn không hợp lệ.");
                request.getRequestDispatcher("/seller/add-product.jsp").forward(request, response);
                return;
            }
        }

        String imageUrl = null;
        Part filePart = request.getPart("image");
        if (filePart != null && filePart.getSize() > 0) {
            String contentType = filePart.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                request.setAttribute("error", "Chỉ chấp nhận file hình ảnh.");
                request.getRequestDispatcher("/seller/add-product.jsp").forward(request, response);
                return;
            }
            if (filePart.getSize() > MAX_FILE_SIZE) {
                request.setAttribute("error", "Kích thước file ảnh không được vượt quá 5MB.");
                request.getRequestDispatcher("/seller/add-product.jsp").forward(request, response);
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
                request.setAttribute("error", "Định dạng ảnh không hỗ trợ. Chỉ chấp nhận: JPG, PNG, WEBP, GIF.");
                request.getRequestDispatcher("/seller/add-product.jsp").forward(request, response);
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
                request.setAttribute("error", "Lỗi khi lưu ảnh. Vui lòng thử lại.");
                request.getRequestDispatcher("/seller/add-product.jsp").forward(request, response);
                return;
            }
        }

        Product product = new Product();
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

        String error = productService.addProductWithValidation(product);
        if (error != null) {
            request.setAttribute("error", error);
            request.getRequestDispatcher("/seller/add-product.jsp").forward(request, response);
            return;
        }

        session.setAttribute("message", "Thêm sản phẩm thành công!");
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

    private boolean isEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }
}
