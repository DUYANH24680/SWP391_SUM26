package Utils;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Helper de build URL cho anh tai len qua ImageServlet.
 *
 * JSP su dung:
 *   <%@ page import="Utils.ImageUrlUtil" %>
 *   <img src="<%= ImageUrlUtil.resolve(product.getImage(), request.getContextPath()) %>">
 *
 * Ho tro:
 *   - Duong dan local: uploads/products/1/xxx.jpg  ->  /context/image?path=uploads/products/1/xxx.jpg
 *   - URL day du: https://...  ->  tra ve nguyen
 *   - Null/empty: tra ve null
 */
public class ImageUrlUtil {

    private static final String IMAGE_SERVLET = "/image";

    public static String resolve(String path, Object pageContextOrCtx) {
        if (path == null || path.trim().isEmpty()) {
            return null;
        }
        String trimmed = path.trim();

        // URL day du (Google Drive, CDN, ...) -> tra ve nguyen
        if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
            return trimmed;
        }

        String ctx = "";
        if (pageContextOrCtx instanceof String) {
            ctx = (String) pageContextOrCtx;
        } else if (pageContextOrCtx != null) {
            try {
                Object sc = pageContextOrCtx.getClass().getMethod("getServletContext").invoke(pageContextOrCtx);
                ctx = (String) sc.getClass().getMethod("getContextPath").invoke(sc);
            } catch (Exception e) {
                ctx = "";
            }
        }

        if (trimmed.startsWith("uploads/")) {
            return ctx + IMAGE_SERVLET + "?path=" + encode(trimmed);
        }

        // Khong co prefix -> them "uploads/"
        return ctx + IMAGE_SERVLET + "?path=" + encode("uploads/" + trimmed);
    }

    public static String resolve(String path, String contextPath) {
        return resolve(path, (Object) contextPath);
    }

    /**
     * Alias method for resolve/getImageUrl.
     */
    public static String getImageUrl(String path) {
        if (path == null || path.trim().isEmpty()) {
            return "";
        }
        String trimmed = path.trim();
        if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
            return trimmed;
        }
        if (trimmed.startsWith("uploads/")) {
            return "image?path=" + encode(trimmed);
        }
        return "image?path=" + encode("uploads/" + trimmed);
    }

    public static String getImageUrl(String path, String contextPath) {
        return resolve(path, contextPath);
    }

    private static String encode(String s) {
        try {
            return URLEncoder.encode(s, StandardCharsets.UTF_8.toString());
        } catch (Exception e) {
            return s;
        }
    }
}
