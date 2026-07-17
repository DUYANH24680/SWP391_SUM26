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
                sendJson(resp, false, "Vui lòng đăng nhập để đánh giá sản phẩm.");
            } else {
                session = req.getSession();
                session.setAttribute("error", "Vui lòng đăng nhập để đánh giá sản phẩm.");
                resp.sendRedirect(req.getContextPath() + "/login");
            }
            return;
        }

        Account account = (Account) session.getAttribute("Account");
        
        try {
            // DuyAnhNgo- Nhận ID sản phẩm, Số sao (rating) và Nội dung bình luận từ form gửi lên
            int productId = Integer.parseInt(req.getParameter("productId"));
            int rating = Integer.parseInt(req.getParameter("rating"));
            String comment = req.getParameter("comment");

            if (rating < 1 || rating > 5) {
                if (isAjax) {
                    sendJson(resp, false, "Số sao không hợp lệ.");
                } else {
                    session.setAttribute("error", "Số sao không hợp lệ.");
                    resp.sendRedirect(req.getContextPath() + "/info?id=" + productId);
                }
                return;
            }

            boolean success = false;
            String message = "";
            ProductReviewDAO dao = new ProductReviewDAO();
            try {
                // DuyAnhNgo- Gọi ProductReviewDAO (hàm addReview) thực thi lệnh INSERT để lưu bình luận này vào bảng ProductReviews
                success = dao.addReview(productId, account.getId(), rating, comment);
                if (success) {
                    // DuyAnhNgo- QUAN TRỌNG: Sau khi thêm bình luận thành công, phải gọi ProductReviewDAO (hàm updateProductAverageRating) tính toán lại "Điểm Đánh Giá Trung Bình" của cả sản phẩm
                    dao.updateProductAverageRating(productId);
                    message = "Cảm ơn bạn đã gửi đánh giá!";
                    session.setAttribute("success", message);
                } else {
                    message = "Có lỗi xảy ra khi lưu đánh giá.";
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