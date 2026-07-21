package controller;

import dao.ProductReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;

import java.io.IOException;

@WebServlet("/review")
public class ProductReviewServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        boolean isAjax = "XMLHttpRequest".equals(req.getHeader("X-Requested-With")) || "true".equals(req.getParameter("ajax"));
        
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            if (isAjax) {
                sendJson(resp, false, "Vui lòng đăng nhập để thao tác.");
            } else {
                session = req.getSession();
                session.setAttribute("error", "Vui lòng đăng nhập để thao tác.");
                resp.sendRedirect(req.getContextPath() + "/login");
            }
            return;
        }

        Account account = (Account) session.getAttribute("Account");
        
        try {
            String action = req.getParameter("action");
            if (action == null || action.trim().isEmpty()) {
                action = "add";
            }
            
            int productId = Integer.parseInt(req.getParameter("productId"));
            boolean success = false;
            String message = "";
            
            ProductReviewDAO dao = new ProductReviewDAO();
            try {
                if ("add".equals(action)) {
                    // DuyAnhNgo- Hành động Thêm mới bình luận
                    int rating = Integer.parseInt(req.getParameter("rating"));
                    String comment = req.getParameter("comment");
                    if (rating < 1 || rating > 5) {
                        message = "Số sao không hợp lệ.";
                    } else {
                        success = dao.addReview(productId, account.getId(), rating, comment);
                        if (success) {
                            dao.updateProductAverageRating(productId);
                            message = "Cảm ơn bạn đã gửi đánh giá!";
                        } else {
                            message = "Có lỗi xảy ra khi lưu đánh giá.";
                        }
                    }
                } else if ("edit".equals(action)) {
                    // DuyAnhNgo- Hành động Sửa bình luận (Chỉ cập nhật đánh giá của chính người dùng)
                    int reviewId = Integer.parseInt(req.getParameter("reviewId"));
                    int rating = Integer.parseInt(req.getParameter("rating"));
                    String comment = req.getParameter("comment");
                    if (rating < 1 || rating > 5) {
                        message = "Số sao không hợp lệ.";
                    } else {
                        success = dao.updateReview(reviewId, account.getId(), rating, comment);
                        if (success) {
                            dao.updateProductAverageRating(productId);
                            message = "Đánh giá đã được cập nhật!";
                        } else {
                            message = "Cập nhật thất bại hoặc bạn không có quyền.";
                        }
                    }
                } else if ("delete".equals(action)) {
                    // DuyAnhNgo- Hành động Xóa bình luận
                    int reviewId = Integer.parseInt(req.getParameter("reviewId"));
                    String role = (String) session.getAttribute("role");
                    if ("admin".equals(role)) {
                        // DuyAnhNgo- Quyền Admin: Xóa tự do không kiểm tra Account ID
                        success = dao.deleteReviewByAdmin(reviewId);
                    } else {
                        // DuyAnhNgo- Người dùng thường: Chỉ xóa bình luận của mình
                        success = dao.deleteReview(reviewId, account.getId());
                    }
                    if (success) {
                        dao.updateProductAverageRating(productId);
                        message = "Đánh giá đã được xóa!";
                    } else {
                        message = "Xóa thất bại hoặc bạn không có quyền.";
                    }
                } else if ("reply".equals(action)) {
                    // DuyAnhNgo- Hành động Trả lời bình luận (Dành cho Admin/Seller)
                    int reviewId = Integer.parseInt(req.getParameter("reviewId"));
                    String replyText = req.getParameter("replyText");
                    String role = account.getRoleName();
                    
                    if ("admin".equalsIgnoreCase(role) || "seller".equalsIgnoreCase(role)) {
                        if (replyText == null || replyText.trim().isEmpty()) {
                            message = "Nội dung trả lời không được để trống.";
                        } else {
                            success = dao.addReply(reviewId, replyText);
                            if (success) {
                                message = "Đã gửi câu trả lời!";
                            } else {
                                message = "Có lỗi xảy ra khi lưu câu trả lời.";
                            }
                        }
                    } else {
                        message = "Bạn không có quyền thực hiện hành động này.";
                    }
                } else {
                    message = "Hành động không hợp lệ.";
                }
                
                if (success) {
                    session.setAttribute("success", message);
                } else if (!isAjax) {
                    session.setAttribute("error", message);
                }
            } finally {
                dao.close();
            }

            if (isAjax) {
                sendJson(resp, success, message);
            } else {
                resp.sendRedirect(req.getContextPath() + "/info?id=" + productId);
            }

        } catch (Exception e) {
            if (isAjax) {
                sendJson(resp, false, "Yêu cầu không hợp lệ.");
            } else {
                session.setAttribute("error", "Yêu cầu không hợp lệ.");
                resp.sendRedirect(req.getContextPath() + "/home.jsp");
            }
        }
    }

    private void sendJson(HttpServletResponse resp, boolean success, String message) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.getWriter().write("{\"success\":" + success + ",\"message\":\"" + message.replace("\"", "\\\"") + "\"}");
    }
}