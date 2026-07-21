//Duy Anh
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
import model.ProductReview;
import java.util.Map;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ProductInfoServlet", urlPatterns = {"/info", "/product-info"})
public class ProductInfoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);

        String idParam = req.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        int productId;
        try {
            // DuyAnhNgo- Bước 1: Lấy ID sản phẩm từ URL (ví dụ /info?id=3 thì lấy số 3)
            productId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID sản phẩm không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        ProductDAO productDAO = new ProductDAO();
        try {
            // DuyAnhNgo- Bước 2: Dùng ID đó gọi ProductDAO (hàm getProductById) để truy xuất toàn bộ chi tiết sản phẩm từ Database
            Product product = productDAO.getProductById(productId);

            if (product == null || product.isIsDelete()) {
                session.setAttribute("error", "Sản phẩm không tồn tại hoặc đã bị xóa.");
                resp.sendRedirect(req.getContextPath() + "/home.jsp");
                return;
            }

            // DuyAnhNgo- Bước 3: Lấy tên Danh mục (để hiển thị breadcrumb: Trang chủ > Trái cây nội địa) bằng cách gọi CategoryDAO (hàm getAllActiveCategories)
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
                System.err.println("[ProductInfoServlet] load category name failed: " + ex.getMessage());
            }

            // DuyAnhNgo- Bước 4: Lấy thông tin Shop bán sản phẩm này (nếu có) bằng cách gọi ShopDAO (hàm getShopById)
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
                    System.err.println("[ProductInfoServlet] load shop info failed: " + ex.getMessage());
                }
            }

            req.setAttribute("product", product);
            req.setAttribute("categoryName", categoryName);
            if (shopInfo != null) {
                req.setAttribute("shopInfo", shopInfo);
            }

            // DuyAnhNgo- Bước 5: KHU VỰC BÌNH LUẬN & ĐÁNH GIÁ (Rate vs Comment)
            // Lấy toàn bộ danh sách bình luận (reviews) và thống kê số sao (ratingStats) bằng cách gọi ProductReviewDAO (hàm getReviewsByProductId và getRatingSummary)
            try {
                dao.ProductReviewDAO reviewDAO = new dao.ProductReviewDAO();
                try {
                    java.util.List<ProductReview> reviews = reviewDAO.getReviewsByProductId(productId);
                    Map<String, Object> ratingStats = reviewDAO.getRatingSummary(productId);
                    req.setAttribute("reviews", reviews);
                    req.setAttribute("ratingStats", ratingStats);

                    // DuyAnhNgo- Bước 5b: Kiểm tra quyền đánh giá sản phẩm
                    boolean canReview = false;
                    if (session != null && session.getAttribute("user") != null) {
                        model.Account curUser = (model.Account) session.getAttribute("user");
                        String userRole = (String) session.getAttribute("role");
                        
                        // DuyAnhNgo- Quyền Admin: Tự do bình luận không bị hạn chế (không cần mua hàng)
                        if ("admin".equals(userRole)) {
                            canReview = true;
                        } else {
                            // DuyAnhNgo- Người dùng thường: Phải có đơn hàng đã giao thành công mới được bình luận
                            canReview = reviewDAO.hasPurchasedProduct(curUser.getId(), productId);
                        }
                    }
                    req.setAttribute("canReview", canReview);
                } finally {
                    reviewDAO.close();
                }
            } catch (Exception e) {
                System.err.println("[ProductInfoServlet] load reviews failed: " + e.getMessage());
            }

            req.getRequestDispatcher("/product-info.jsp").forward(req, resp);

        } catch (Exception e) {
            System.err.println("[ProductInfoServlet] error: " + e.getMessage());
            e.printStackTrace();
            if (session != null) {
                session.setAttribute("error", "Không thể tải chi tiết sản phẩm: " + e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
        } finally {
            productDAO.close();
        }
    }
}

