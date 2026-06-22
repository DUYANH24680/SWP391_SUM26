package controller;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.Category;
import Utils.FileUploadUtil;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "CategoryServlet", urlPatterns = {"/category/*"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 20 * 1024 * 1024
)
public class CategoryServlet extends HttpServlet {

    private static final String ROLE_ADMIN = "admin";
    private static final String ROLE_SELLER = "seller";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String pathInfo = req.getPathInfo();

        if (!isAuthorized(session)) {
            session = req.getSession(true);
            session.setAttribute("error", "Ban khong co quyen truy cap trang nay.");
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if (pathInfo == null || pathInfo.equals("/") || pathInfo.equals("/list")) {
            forwardCategoryList(req, resp);
        } else if (pathInfo.equals("/add")) {
            forwardCategoryForm(req, resp, null, null);
        } else if (pathInfo.startsWith("/edit/")) {
            String idStr = pathInfo.substring("/edit/".length());
            forwardCategoryEdit(req, resp, idStr);
        } else if (pathInfo.equals("/delete")) {
            forwardDeleteCategory(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/category");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String pathInfo = req.getPathInfo();

        if (!isAuthorized(session)) {
            session = req.getSession(true);
            session.setAttribute("error", "Ban khong co quyen thuc hien thao tac nay.");
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if (pathInfo == null) {
            resp.sendRedirect(req.getContextPath() + "/category");
            return;
        }

        switch (pathInfo) {
            case "/create" -> handleCreate(req, resp);
            case "/update" -> handleUpdate(req, resp);
            default -> resp.sendRedirect(req.getContextPath() + "/category");
        }
    }

    private void forwardCategoryList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        CategoryDAO dao = new CategoryDAO();
        try {
            List<Category> categories = dao.getAllCategories(false);
            req.setAttribute("categories", categories);
        } catch (RuntimeException e) {
            System.err.println("[CategoryServlet] load categories error: " + e.getMessage());
            req.setAttribute("categories", java.util.Collections.emptyList());
            HttpSession session = req.getSession(false);
            if (session != null) {
                session.setAttribute("error", "Khong the tai danh sach danh muc. Vui long thu lai sau.");
            }
        } finally {
            dao.close();
        }
        req.getRequestDispatcher("/admin/categories.jsp").forward(req, resp);
    }

    private void forwardCategoryForm(HttpServletRequest req, HttpServletResponse resp,
            Category category, String error)
            throws ServletException, IOException {
        req.setAttribute("category", category);
        req.setAttribute("formError", error);
        req.getRequestDispatcher("/category-form.jsp").forward(req, resp);
    }

    private void forwardCategoryEdit(HttpServletRequest req, HttpServletResponse resp, String idStr)
            throws ServletException, IOException {
        int id;
        try {
            id = Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            HttpSession session = req.getSession(false);
            if (session != null) {
                session.setAttribute("error", "ID danh muc khong hop le.");
            }
            resp.sendRedirect(req.getContextPath() + "/category");
            return;
        }

        CategoryDAO dao = new CategoryDAO();
        try {
            Category category = dao.getCategoryById(id);
            if (category == null) {
                HttpSession session = req.getSession(false);
                if (session != null) {
                    session.setAttribute("error", "Danh muc khong ton tai.");
                }
                resp.sendRedirect(req.getContextPath() + "/category");
            } else {
                forwardCategoryForm(req, resp, category, null);
            }
        } catch (RuntimeException e) {
            System.err.println("[CategoryServlet] load category error: " + e.getMessage());
            HttpSession session = req.getSession(false);
            if (session != null) {
                session.setAttribute("error", "Loi khi tai danh muc. Vui long thu lai.");
            }
            resp.sendRedirect(req.getContextPath() + "/category");
        } finally {
            dao.close();
        }
    }

    private void forwardDeleteCategory(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String idStr = req.getParameter("id");
        System.out.println("[CategoryServlet] forwardDeleteCategory: idStr=" + idStr);

        if (idStr == null || idStr.trim().isEmpty()) {
            if (session != null) {
                session.setAttribute("error", "ID danh muc khong hop le.");
            }
            resp.sendRedirect(req.getContextPath() + "/category");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            System.err.println("[CategoryServlet] forwardDeleteCategory: invalid id=" + idStr);
            if (session != null) {
                session.setAttribute("error", "ID danh muc khong hop le.");
            }
            resp.sendRedirect(req.getContextPath() + "/category");
            return;
        }

        CategoryDAO dao = new CategoryDAO();
        try {
            boolean success = dao.softDeleteCategory(id);
            System.out.println("[CategoryServlet] softDeleteCategory(" + id + ") = " + success);
            if (session != null) {
                if (success) {
                    session.setAttribute("message", "Xoa danh muc thanh cong!");
                } else {
                    session.setAttribute("error", "Danh muc khong ton tai hoac da bi xoa.");
                }
            }
        } finally {
            dao.close();
        }
        resp.sendRedirect(req.getContextPath() + "/category");
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String name = req.getParameter("name");

        if (name == null || name.trim().isEmpty()) {
            session.setAttribute("error", "Ten danh muc khong duoc de trong.");
            resp.sendRedirect(req.getContextPath() + "/category/add");
            return;
        }
        name = name.trim();

        if (name.length() > 100) {
            session.setAttribute("error", "Ten danh muc khong duoc qua 100 ky tu.");
            resp.sendRedirect(req.getContextPath() + "/category/add");
            return;
        }

        CategoryDAO dao = new CategoryDAO();
        try {
            if (dao.isNameExists(name, 0)) {
                session.setAttribute("error", "Ten danh muc da ton tai.");
                resp.sendRedirect(req.getContextPath() + "/category/add");
                return;
            }

            String imageUrl = extractAndSaveImage(req, "categories");

            boolean success = dao.createCategory(name, imageUrl);
            if (success) {
                session.setAttribute("message", "Tao danh muc thanh cong!");
            } else {
                session.setAttribute("error", "Khong the tao danh muc. Vui long thu lai.");
            }
        } finally {
            dao.close();
        }
        resp.sendRedirect(req.getContextPath() + "/category");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String idStr = req.getParameter("id");
        String name = req.getParameter("name");

        if (idStr == null || idStr.trim().isEmpty()) {
            session.setAttribute("error", "ID danh muc khong hop le.");
            resp.sendRedirect(req.getContextPath() + "/category");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID danh muc khong hop le.");
            resp.sendRedirect(req.getContextPath() + "/category");
            return;
        }

        if (name == null || name.trim().isEmpty()) {
            session.setAttribute("error", "Ten danh muc khong duoc de trong.");
            resp.sendRedirect(req.getContextPath() + "/category/edit/" + id);
            return;
        }
        name = name.trim();

        if (name.length() > 100) {
            session.setAttribute("error", "Ten danh muc khong duoc qua 100 ky tu.");
            resp.sendRedirect(req.getContextPath() + "/category/edit/" + id);
            return;
        }

        CategoryDAO dao = new CategoryDAO();
        try {
            Category existing = dao.getCategoryById(id);
            if (existing == null) {
                session.setAttribute("error", "Danh muc khong ton tai.");
                resp.sendRedirect(req.getContextPath() + "/category");
                return;
            }

            if (dao.isNameExists(name, id)) {
                session.setAttribute("error", "Ten danh muc da ton tai.");
                resp.sendRedirect(req.getContextPath() + "/category/edit/" + id);
                return;
            }

            String imageUrl = extractAndSaveImage(req, "categories");
            if (imageUrl == null || imageUrl.isEmpty()) {
                imageUrl = existing.getImage();
            }

            boolean success = dao.updateCategory(id, name, imageUrl);
            if (success) {
                session.setAttribute("message", "Cap nhat danh muc thanh cong!");
            } else {
                session.setAttribute("error", "Khong the cap nhat danh muc. Vui long thu lai.");
            }
        } finally {
            dao.close();
        }
        resp.sendRedirect(req.getContextPath() + "/category");
    }

    private String extractAndSaveImage(HttpServletRequest req, String subFolder) {
        try {
            Part filePart = req.getPart("image");
            if (filePart != null && filePart.getSize() > 0) {
                return FileUploadUtil.saveProductImage(filePart, subFolder);
            }
        } catch (Exception e) {
            System.err.println("[CategoryServlet] image upload error: " + e.getMessage());
        }
        return null;
    }

    private boolean isAuthorized(HttpSession session) {
        if (session == null) {
            return false;
        }
        String role = (String) session.getAttribute("role");
        return ROLE_ADMIN.equals(role) || ROLE_SELLER.equals(role);
    }
}
