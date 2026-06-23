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
 * Hiện hỗ trợ upload hình ảnh sản phẩm qua jakarta.servlet.http.Part.
 */
public class FileUploadUtil {

    private static final long MAX_FILE_SIZE = 5L * 1024 * 1024; // 5 MB

    private static final String[] ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"};

    /**
     * Lưu file ảnh upload vào thư mục web/uploads/products/[subFolder]/.
     * Tên file được đổi thành timestamp + số ngẫu nhiên để tránh trùng lặp.
     *
     * @param part       Part chứa dữ liệu file từ HttpServletRequest
     * @param subFolder  Thư mục con bên trong products (ví dụ: "1", "temp")
     * @param servletContext ServletContext để lấy đường dẫn thực của webapp
     * @return Đường dẫn tương đối để lưu vào database, ví dụ: uploads/products/1/1749567890123_42.jpg
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

        // Xác định đường dẫn tuyệt đối trên disk
        // getRealPath("/") trả về thư mục gốc của webapp (hoạt động đúng cả NetBeans lẫn production)
        String webappRoot = servletContext.getRealPath("/");
        if (webappRoot == null) {
            throw new ServletException(
                "Không thể xác định thư mục gốc của webapp. Vui long cau hinh server dung cach.");
        }

        // Chuẩn hóa: loại bỏ trailing separator nếu có
        if (webappRoot.endsWith(File.separator) || webappRoot.endsWith("/")) {
            webappRoot = webappRoot.substring(0, webappRoot.length() - 1);
        }

        String uploadDirPath = webappRoot
                + File.separator + "uploads"
                + File.separator + "products"
                + File.separator + subFolder;

        File uploadDir = new File(uploadDirPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        // Ghi file
        Path targetPath = Paths.get(uploadDirPath, safeFileName);
        try (InputStream input = part.getInputStream()) {
            Files.copy(input, targetPath, StandardCopyOption.REPLACE_EXISTING);
        }

        // Trả về đường dẫn relative để lưu vào DB và truy cập qua <img src="...">
        return "uploads/products/" + subFolder + "/" + safeFileName;
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
        // format: filename*=''path hoặc filename*=UTF-8''path
        int eq = token.indexOf('=');
        if (eq < 0) return "";
        String encoded = token.substring(eq + 1).trim();
        // Bỏ prefix encoding ('' hoặc UTF-8'' hoặc UTF-8'''')
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
     * Trả về chuỗi rỗng nếu không có dấu chấm.
     */
    private static String getFileExtension(String fileName) {
        int lastDot = fileName.lastIndexOf('.');
        if (lastDot < 0) {
            return "";
        }
        return fileName.substring(lastDot + 1);
    }
}
