package controller;

import dao.ProductDAO;
import model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * SearchSuggestServlet
 * URL: /search-suggest?q=keyword
 * Trả về JSON array các sản phẩm phù hợp, dùng cho autocomplete trên trang chủ.
 */
@WebServlet("/search-suggest")
public class SearchSuggestServlet extends HttpServlet {

    private static final int MAX_SUGGESTIONS = 8;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        // Cho phép cache phía client 5 giây để giảm request liên tục
        response.setHeader("Cache-Control", "max-age=5");

        String q = request.getParameter("q");

        PrintWriter out = response.getWriter();

        // Không có keyword -> trả mảng rỗng
        if (q == null || q.trim().isEmpty()) {
            out.print("[]");
            return;
        }

        q = q.trim();

        try {
            ProductDAO dao = new ProductDAO();
            List<Product> products = dao.searchProducts(q);

            StringBuilder json = new StringBuilder("[");
            int count = 0;
            for (Product p : products) {
                if (count >= MAX_SUGGESTIONS) break;
                if (count > 0) json.append(",");
                json.append("{");
                json.append("\"id\":").append(p.getId()).append(",");
                json.append("\"title\":\"").append(escapeJson(p.getTitle())).append("\",");
                json.append("\"salePrice\":").append(p.getSalePrice()).append(",");
                json.append("\"image\":\"").append(escapeJson(p.getImage() != null ? p.getImage() : "")).append("\"");
                json.append("}");
                count++;
            }
            json.append("]");

            out.print(json.toString());

        } catch (Exception e) {
            System.err.println("[SearchSuggestServlet] Error: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("[]");
        }
    }

    /**
     * Escape các ký tự đặc biệt trong JSON string
     */
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
