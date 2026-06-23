package Utils;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

/**
 * Tiện ích upload file cho ứng dụng web.
 * Ảnh được lưu ra thư mục ngoài build/ (tránh bị xóa khi Clean and Build).
 * Đường dẫn upload có thể cấu hình qua context-param "upload.external.path"
 * trong web.xml, hoặc mặc định dùng getRealPath("/") + /uploads (nằm ngoài build/).
 */
public class FileUploadUtil {

    private static final long MAX_FILE_SIZE = 5L * 1024 * 1024; // 5 MB

    private static final String[] ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"};

    /**
     * Lưu file ảnh upload vào thư mục ngoài build/.
     *
     * Thứ tự ưu tiên chọn thư mục lưu:
     *  1. Tham số context-param "upload.external.path" trong web.xml
     *  2. Thư mục cha của webapp: {parentOfWebapp}/uploads/{contextPath}/
     *     (tránh bị xóa khi Clean and Build trong NetBeans)
     *
     * @param part             Part chứa dữ liệu file từ HttpServletRequest
     * @param subFolder        Thư mục con (thường là shopId hoặc "category")
     * @param servletContext   ServletContext để lấy contextPath và getRealPath
     * @return Đường dẫn relative để lưu vào DB và truy cập qua browser, ví dụ: uploads/products/1/1749567890123_42.jpg
     * @throws ServletException nếu extension không hợp lệ, file quá lớn, hoặc file rỗng
     * @throws IOException      nếu lỗi ghi file
     */
    public static String saveProductImage(jakarta.servlet.http.Part part, String subFolder,
                                          ServletContext servletContext)
            throws ServletException, IOException {

        // Lấy tên file gốc từ Content-Disposition header
        String rawFileName = extractFileName(part);
        String extension = getFileExtension(rawFileName).toLowerCase();

        // Chặn extension không cho phép
        boolean validExtension = false;
        for (String allowed : ALLOWED_EXTENSIONS) {
            if (allowed.equals("." + extension)) {
                validExtension = true;
                break;
            }
        }
        if (!validExtension) {
            throw new ServletException(
                    "Loại file không được hỗ trợ. Chỉ chấp nhận: jpg, jpeg, png, webp.");
        }

        // Kiểm tra kích thước file
        long fileSize = part.getSize();
        if (fileSize > MAX_FILE_SIZE) {
            throw new ServletException("Kích thước file vượt quá giới hạn 5 MB.");
        }
        if (fileSize == 0) {
            throw new ServletException("File rỗng.");
        }

        // Tạo tên file an toàn: timestamp + số ngẫu nhiên + extension
        String safeFileName = System.currentTimeMillis()
                + "_" + (int) (Math.random() * 10000)
                + "." + extension;

        // Xác định thư mục lưu (ưu tiên external path để tránh bị xóa khi rebuild)
        String uploadDirPath = resolveUploadDir(servletContext, subFolder);

        File uploadDir = new File(uploadDirPath);
        if (!uploadDir.exists()) {
            System.out.println("[FileUploadUtil] Creating directory: " + uploadDir.getAbsolutePath());
            try {
                java.nio.file.attribute.FileAttribute<?>[] attrs = {};
                Files.createDirectories(uploadDir.toPath(), attrs);
            } catch (java.io.IOException e) {
                System.err.println("[FileUploadUtil] FATAL createDirectories FAILED: " + e.getClass().getName() + " — " + e.getMessage());
                System.err.println("[FileUploadUtil]   parent exists: " + uploadDir.getParentFile().exists());
                System.err.println("[FileUploadUtil]   parent canWrite: " + uploadDir.getParentFile().canWrite());
                System.err.println("[FileUploadUtil]   parent isDirectory: " + uploadDir.getParentFile().isDirectory());
                throw new ServletException(
                    "Khong the tao thu muc: " + uploadDir.getAbsolutePath()
                    + " | Loi: " + e.getClass().getSimpleName() + " — " + e.getMessage());
            }
            if (!uploadDir.exists()) {
                throw new ServletException(
                    "Khong the tao thu muc: " + uploadDir.getAbsolutePath());
            }
        }

        // Ghi file
        Path targetPath = Paths.get(uploadDirPath, safeFileName);
        System.out.println("[FileUploadUtil] Writing to: " + targetPath);
        try (InputStream input = part.getInputStream()) {
            Files.copy(input, targetPath, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            System.err.println("[FileUploadUtil] FAIL write: " + e.getMessage());
            throw new ServletException("Loi ghi file: " + e.getMessage());
        }
        System.out.println("[FileUploadUtil] Saved: " + targetPath + " (" + Files.size(targetPath) + " bytes)");

        // Trả về đường dẫn relative để lưu vào DB và truy cập qua <img src="...">
        return "uploads/" + subFolder + "/" + safeFileName;
    }

    /**
     * Xác định thư mục upload vật lý.
     *
     * Thứ tự:
     * 1. upload.external.path (từ web.xml context-param) — dùng tuyệt đối nếu bắt đầu bằng /
     * 2. getRealPath("/") + ../uploads/{contextPath}/{subFolder}  — nằm ngoài thư mục build
     */
    private static String resolveUploadDir(ServletContext servletContext, String subFolder)
            throws ServletException {
        // Ưu tiên 1: đường dẫn tuyệt đối từ context-param
        String externalPath = servletContext.getInitParameter("upload.external.path");
        if (externalPath != null && !externalPath.trim().isEmpty()) {
            String absPath = externalPath.trim()
                    + File.separator + subFolder;
            System.out.println("[FileUploadUtil] Using external upload path: " + absPath);
            return absPath;
        }

        // Ưu tiên 2: getRealPath (webapp gốc)
        String webappRoot = servletContext.getRealPath("/");
        if (webappRoot == null) {
            throw new ServletException(
                "Không thể xác định thư mục gốc của webapp. "
              + "Vui lòng khai báo <context-param><param-name>upload.external.path</param-name> trong web.xml");
        }

        // Chuẩn hóa: loại bỏ trailing separator
        if (webappRoot.endsWith(File.separator) || webappRoot.endsWith("/")) {
            webappRoot = webappRoot.substring(0, webappRoot.length() - 1);
        }

        // Lấy context path để tạo thư mục riêng cho mỗi app (tránh trùng nếu nhiều app dùng chung thư mục uploads)
        String contextPath = servletContext.getContextPath();
        if (contextPath == null || contextPath.isEmpty() || contextPath.equals("/")) {
            contextPath = "app";
        } else {
            contextPath = contextPath.replace("/", "");
        }

        // Đặt thư mục uploads ở bên ngoài thư mục build của NetBeans
        // getRealPath("/") = .../build/web/  → parent = .../build/
        // uploads nằm cùng cấp build: .../build/../../../uploads/
        // Hoặc dùng getParent để ra khỏi thư mục webapp
        Path webappPath = Paths.get(webappRoot).normalize();
        Path parentPath = webappPath.getParent(); // lùi 1 cấp ra khỏi thư mục web

        String uploadDirPath;
        if (parentPath != null) {
            uploadDirPath = parentPath.resolve("uploads")
                    + File.separator + contextPath
                    + File.separator + subFolder;
        } else {
            // Fallback: dùng thư mục con trong webapp (vẫn hoạt động, nhưng sẽ bị xóa khi rebuild)
            uploadDirPath = webappPath.resolve("uploads")
                    + File.separator + contextPath
                    + File.separator + subFolder;
        }

        System.out.println("[FileUploadUtil] Webapp root: " + webappPath);
        System.out.println("[FileUploadUtil] Using upload dir: " + uploadDirPath);
        return uploadDirPath;
    }

    /**
     * Trích xuất tên file từ Part header "content-disposition".
     * Xử lý cả định dạng "filename=value" lẫn "filename*=" (RFC 5987).
     */
    private static String extractFileName(jakarta.servlet.http.Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null) {
            return "";
        }

        for (String token : contentDisp.split(";")) {
            token = token.trim();
            // Ưu tiên filename* (RFC 5987 encoding)
            if (token.startsWith("filename*")) {
                return parseFilenameStar(token);
            }
            // Fallback filename=
            if (token.startsWith("filename")) {
                String fileName = token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
                int lastSep = Math.max(fileName.lastIndexOf('/'), fileName.lastIndexOf('\\'));
                if (lastSep >= 0) {
                    fileName = fileName.substring(lastSep + 1);
                }
                return fileName;
            }
        }
        return "";
    }

    /**
     * Parse phần filename*= chứa RFC 5987 encoded value: filename*=''tên%20file.jpg
     */
    private static String parseFilenameStar(String token) {
        int eq = token.indexOf('=');
        if (eq < 0) return "";
        String encoded = token.substring(eq + 1).trim();
        int secondQuote = encoded.indexOf('\'');
        if (secondQuote >= 0) {
            int thirdQuote = encoded.indexOf('\'', secondQuote + 1);
            if (thirdQuote >= 0) {
                encoded = encoded.substring(thirdQuote + 1);
            } else {
                encoded = encoded.substring(secondQuote + 1);
            }
        }
        try {
            return java.net.URLDecoder.decode(encoded, "UTF-8");
        } catch (Exception e) {
            return encoded;
        }
    }

    /**
     * Lấy phần mở rộng của tên file (không có dấu chấm).
     */
    private static String getFileExtension(String fileName) {
        int lastDot = fileName.lastIndexOf('.');
        if (lastDot < 0) {
            return "";
        }
        return fileName.substring(lastDot + 1);
    }
}
