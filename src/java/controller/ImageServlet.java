package controller;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Servlet phuc vu anh tu thu muc uploads nam ngoai webapp.
 *
 *  Browser goi: <img src="image?path=uploads/products/1/xxx.jpg">
 *  Servlet doc:  {uploadRoot}/uploads/products/1/xxx.jpg
 *  Luu vao DB:   uploads/products/1/xxx.jpg
 *
 *  upload.external.path mac dinh: D:/uploads
 */
@WebServlet(name = "ImageServlet", urlPatterns = {"/image"})
public class ImageServlet extends HttpServlet {

    private static final int BUFFER_SIZE = 8192;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String relativePath = req.getParameter("path");
        System.out.println("[ImageServlet] === REQUEST ===");
        System.out.println("[ImageServlet] path param: '" + relativePath + "'");

        if (relativePath == null || relativePath.trim().isEmpty()) {
            System.err.println("[ImageServlet] ERROR: path param is null or empty");
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thieu tham so path.");
            return;
        }

        // Bao mat: chan path traversal
        String safePath = relativePath.replace("..", "").replace("\\", "/").trim();
        if (safePath.contains("..") || safePath.startsWith("/")) {
            System.err.println("[ImageServlet] ERROR: path traversal attempt: " + relativePath);
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Duong dan khong hop le.");
            return;
        }

        ServletContext ctx = getServletContext();

        // Lay thu muc goc upload
        String uploadRoot = resolveUploadRoot(ctx);
        System.out.println("[ImageServlet] uploadRoot: " + uploadRoot);

        if (uploadRoot == null) {
            System.err.println("[ImageServlet] ERROR: uploadRoot is null");
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Khong tim thay thu muc upload. Cau hinh upload.external.path trong web.xml.");
            return;
        }

        // DB luu: uploads/1/xxx.jpg
        // uploadRoot: D:/uploads
        // Bang cach strip prefix "uploads/" → fileRelPath = 1/xxx.jpg
        // new File(uploadRoot, fileRelPath) = D:/uploads/1/xxx.jpg  ← dung!
        String fileRelPath = safePath;
        if (safePath.startsWith("uploads/") || safePath.startsWith("uploads\\")) {
            fileRelPath = safePath.substring("uploads/".length());
        }

        System.out.println("[ImageServlet] fileRelPath: " + fileRelPath);

        File imageFile = new File(uploadRoot, fileRelPath);
        System.out.println("[ImageServlet] absolute path: " + imageFile.getAbsolutePath());
        System.out.println("[ImageServlet] file exists: " + imageFile.exists());

        if (!imageFile.exists() || !imageFile.isFile()) {
            System.err.println("[ImageServlet] ERROR: File not found: " + imageFile.getAbsolutePath());
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Anh khong ton tai.");
            return;
        }

        // Security: dam bao file nam trong uploadRoot
        try {
            Path uploadRootPath = Paths.get(uploadRoot).toRealPath();
            Path imageFilePath = imageFile.toPath().toRealPath();
            if (!imageFilePath.startsWith(uploadRootPath)) {
                System.err.println("[ImageServlet] ERROR: path outside upload root!");
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Truy cap bi chan.");
                return;
            }
        } catch (Exception e) {
            System.err.println("[ImageServlet] ERROR during path validation: " + e.getMessage());
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Loi xac thuc duong dan.");
            return;
        }

        // Xac dinh content-type
        String fileName = imageFile.getName().toLowerCase();
        String contentType;
        if (fileName.endsWith(".png")) {
            contentType = "image/png";
        } else if (fileName.endsWith(".webp")) {
            contentType = "image/webp";
        } else if (fileName.endsWith(".gif")) {
            contentType = "image/gif";
        } else if (fileName.endsWith(".jpg") || fileName.endsWith(".jpeg")) {
            contentType = "image/jpeg";
        } else {
            contentType = "application/octet-stream";
        }

        System.out.println("[ImageServlet] contentType: " + contentType + ", size: " + imageFile.length());

        // Tra anh ve browser
        resp.setContentType(contentType);
        resp.setContentLengthLong(imageFile.length());
        resp.setHeader("Cache-Control", "max-age=31536000, public");

        try (FileInputStream fis = new FileInputStream(imageFile);
             OutputStream os = resp.getOutputStream()) {
            byte[] buffer = new byte[BUFFER_SIZE];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }
            System.out.println("[ImageServlet] SUCCESS: sent " + imageFile.length() + " bytes");
        }
    }

    /**
     * Xac dinh thu muc goc chua anh upload.
     *  - upload.external.path  →  tra ve tuyệt đối folder goc (VD: D:/uploads)
     *  - Fallback: getRealPath/../../../uploads/
     */
    private String resolveUploadRoot(ServletContext ctx) {
        // Uu tien 1: external path tu web.xml
        String externalPath = ctx.getInitParameter("upload.external.path");
        if (externalPath != null && !externalPath.trim().isEmpty()) {
            System.out.println("[ImageServlet] Using EXTERNAL PATH from web.xml: " + externalPath.trim());
            return externalPath.trim();
        }

        // Uu tien 2: thu muc nam ngoai build/
        String webappRoot = ctx.getRealPath("/");
        System.out.println("[ImageServlet] getRealPath: " + webappRoot);

        if (webappRoot == null) {
            System.err.println("[ImageServlet] getRealPath returned null");
            return null;
        }

        // Chuan hoa
        if (webappRoot.endsWith(File.separator) || webappRoot.endsWith("/")) {
            webappRoot = webappRoot.substring(0, webappRoot.length() - 1);
        }

        Path webappPath = Paths.get(webappRoot).normalize();
        Path parentPath = webappPath.getParent();

        if (parentPath != null) {
            String uploadPath = parentPath.resolve("uploads").toAbsolutePath().toString();
            System.out.println("[ImageServlet] computed uploadRoot: " + uploadPath);
            return uploadPath;
        }

        String uploadPath = webappPath.resolve("uploads").toAbsolutePath().toString();
        System.out.println("[ImageServlet] WARNING: using FALLBACK uploadRoot: " + uploadPath);
        return uploadPath;
    }
}
