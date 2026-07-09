package Utils;

import jakarta.servlet.jsp.PageContext;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Helper de build URL cho anh tai len qua ImageServlet.
 *
 * JSP su dung:
 *   <%@ page import="Utils.ImageUrlUtil" %>
 *   <img src="<%= ImageUrlUtil.resolve(product.getImage(), pageContext) %>">
 *
 * Ho tro:
 *   - Duong dan local: uploads/products/1/xxx.jpg  ->  /context/image?path=uploads/products/1/xxx.jpg
 *   - URL day du: https://...  ->  tra ve nguyen
 *   - Null/empty: tra ve null
 */
public class ImageUrlUtil {

    private static final String IMAGE_SERVLET = "/image";

    public static String resolve(String path, PageContext pageContext) {
        if (path == null || path.trim().isEmpty()) {
            return null;
        }
        String trimmed = path.trim();

        // URL day du (Google Drive, CDN, ...) -> tra ve nguyen
        if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
            return trimmed;
        }

        String ctx = pageContext.getServletContext().getContextPath();

        if (trimmed.startsWith("uploads/")) {
            return ctx + IMAGE_SERVLET + "?path=" + encode(trimmed);
        }

        // Khong co prefix -> them "uploads/"
        return ctx + IMAGE_SERVLET + "?path=" + encode("uploads/" + trimmed);
    }

    /**
     * Overload khong can PageContext (tuong thich JSP scriptlet cu).
     * Can truyen request.getContextPath() lam tham so.
     */
    public static String resolve(String path, String contextPath) {
        if (path == null || path.trim().isEmpty()) {
            return null;
        }
        String trimmed = path.trim();

        if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
            return trimmed;
        }

        if (trimmed.startsWith("uploads/")) {
            return contextPath + IMAGE_SERVLET + "?path=" + encode(trimmed);
        }

        return contextPath + IMAGE_SERVLET + "?path=" + encode("uploads/" + trimmed);
    }

    private static String encode(String s) {
        try {
            return URLEncoder.encode(s, StandardCharsets.UTF_8.toString());
        } catch (Exception e) {
            return s;
        }
    }
}
