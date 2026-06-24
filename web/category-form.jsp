<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer" %>
<%@ page import="model.Category" %>
<%
    Object rawUser = session.getAttribute("user");
    Customer user = (Customer) rawUser;
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String role = (String) session.getAttribute("role");
    if (role == null || (!role.equals("admin") && !role.equals("seller"))) {
        response.sendRedirect(request.getContextPath() + "/home.jsp");
        return;
    }

    String avatarUrl = user.getAvatar();
    if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
        String fullname = user.getFullname() != null ? user.getFullname() : user.getUsername();
        avatarUrl = "https://ui-avatars.com/api/?name="
                  + java.net.URLEncoder.encode(fullname, "UTF-8")
                  + "&background=4caf50&color=fff&size=80&bold=true&rounded=true";
    }

    Category category = (Category) request.getAttribute("category");
    String formError = (String) request.getAttribute("formError");
    boolean isEdit = (category != null);
    String pageTitle = isEdit ? "Sửa Danh Mục" : "Thêm Danh Mục Mới";
    String actionUrl = isEdit
            ? request.getContextPath() + "/category/update"
            : request.getContextPath() + "/category/create";

    // ---- Image URL helper ----
    java.util.function.Function<String, String> imgUrl = (String path) -> {
        if (path == null || path.trim().isEmpty()) return null;
        String trimmed = path.trim();
        if (trimmed.startsWith("uploads/")) {
            return request.getContextPath() + "/image?path=" + java.net.URLEncoder.encode(trimmed);
        }
        return trimmed;
    };
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> | Sena Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --green:       #4caf50;
            --green-dark:  #388e3c;
            --green-light: #e8f5e9;
            --green-mid:   #c8e6c9;
            --bg:          #f0f4f1;
            --white:       #ffffff;
            --gray-50:     #f8fafb;
            --gray-100:    #eef1ee;
            --gray-200:    #dde5dd;
            --gray-400:    #9aaa9a;
            --gray-600:    #5a6a5a;
            --gray-800:    #2d3d2d;
            --shadow-sm:   0 1px 3px rgba(0,0,0,.08);
            --shadow:      0 4px 12px rgba(0,0,0,.08);
            --radius:      14px;
            --radius-sm:   8px;
        }

        html, body {
            min-height: 100vh;
            font-family: 'Inter', sans-serif;
            color: var(--gray-800);
            background: var(--bg);
        }

        body { display: flex; flex-direction: column; }

        /* ======= TOPNAV ======= */
        .topnav {
            background: var(--white);
            border-bottom: 1px solid var(--gray-200);
            height: 60px;
            display: flex;
            align-items: center;
            padding: 0 2rem;
            gap: 2rem;
            position: sticky;
            top: 0;
            z-index: 100;
            box-shadow: var(--shadow-sm);
        }

        .nav-logo {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 1.3rem;
            font-weight: 800;
            color: var(--green-dark);
            text-decoration: none;
            white-space: nowrap;
            letter-spacing: -0.01em;
        }

        .nav-logo i { color: var(--green); font-size: 1.15rem; }

        .nav-links {
            display: flex;
            gap: 0.25rem;
            margin-left: 1rem;
        }

        .nav-links a {
            padding: 0.4rem 0.85rem;
            border-radius: 6px;
            font-size: 0.875rem;
            font-weight: 500;
            color: var(--gray-600);
            text-decoration: none;
            transition: all 0.15s;
        }

        .nav-links a:hover { background: var(--green-light); color: var(--green-dark); }

        .nav-right {
            margin-left: auto;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .nav-icon-btn {
            width: 38px; height: 38px;
            border-radius: 50%;
            background: var(--gray-100);
            border: none;
            display: flex; align-items: center; justify-content: center;
            color: var(--gray-600);
            cursor: pointer;
            font-size: 0.95rem;
            transition: background 0.15s;
        }

        .nav-icon-btn:hover { background: var(--green-light); color: var(--green-dark); }

        .nav-avatar {
            width: 38px; height: 38px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--green);
            cursor: pointer;
        }

        /* ======= LAYOUT ======= */
        .layout {
            display: flex;
            flex: 1;
            max-width: 1280px;
            width: 100%;
            margin: 1.5rem auto;
            padding: 0 1.5rem;
            gap: 1.5rem;
            align-items: flex-start;
        }

        /* ======= SIDEBAR ======= */
        .sidebar {
            width: 200px;
            flex-shrink: 0;
            background: var(--white);
            border-radius: var(--radius);
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--gray-200);
            overflow: hidden;
            position: sticky;
            top: 76px;
        }

        .sidebar-nav { padding: 0.5rem; }

        .sidebar-nav a,
        .sidebar-nav button {
            display: flex;
            align-items: center;
            gap: 0.65rem;
            width: 100%;
            padding: 0.65rem 0.9rem;
            border-radius: var(--radius-sm);
            font-size: 0.875rem;
            font-weight: 500;
            color: var(--gray-600);
            border: none;
            background: transparent;
            cursor: pointer;
            font-family: 'Inter', sans-serif;
            text-align: left;
            text-decoration: none;
            transition: all 0.15s;
        }

        .sidebar-nav a:hover { background: var(--green-light); color: var(--green-dark); }
        .sidebar-nav a.active { background: var(--green); color: #fff; font-weight: 600; }
        .sidebar-nav a.logout { color: #e53e3e; }
        .sidebar-nav a.logout:hover { background: #fff5f5; color: #c53030; }

        /* ======= MAIN ======= */
        .main { flex: 1; display: flex; flex-direction: column; gap: 1.25rem; min-width: 0; }

        /* ======= ALERTS ======= */
        .alert {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.9rem 1.2rem;
            border-radius: var(--radius-sm);
            font-size: 0.875rem;
            font-weight: 500;
        }

        .alert-success { background: #dcfce7; border: 1px solid #bbf7d0; color: #166534; }
        .alert-danger  { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }
        .alert-success i, .alert-danger i { flex-shrink: 0; }

        /* ======= CARD ======= */
        .card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
        }

        .card-header {
            display: flex;
            align-items: center;
            gap: 0.6rem;
            padding: 1.1rem 1.5rem;
            border-bottom: 1px solid var(--gray-100);
        }

        .card-title {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--gray-800);
        }

        .card-title i { color: var(--green); }

        .card-body { padding: 1.5rem; }

        /* ======= BREADCRUMB ======= */
        .breadcrumb {
            display: flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 0.82rem;
            color: var(--gray-400);
        }

        .breadcrumb a { color: var(--green); text-decoration: none; font-weight: 500; }
        .breadcrumb a:hover { text-decoration: underline; }
        .breadcrumb span { color: var(--gray-600); font-weight: 500; }

        /* ======= FORM ======= */
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.25rem;
        }

        .form-group { display: flex; flex-direction: column; gap: 0.4rem; }
        .form-group.full { grid-column: span 2; }

        .form-label {
            font-size: 0.78rem;
            font-weight: 600;
            color: var(--gray-600);
            display: flex;
            align-items: center;
            gap: 0.3rem;
        }

        .form-label .required { color: #dc2626; font-size: 0.7rem; }

        .form-control {
            background: var(--gray-50);
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            padding: 0.7rem 0.9rem;
            font-size: 0.875rem;
            font-family: 'Inter', sans-serif;
            color: var(--gray-800);
            outline: none;
            transition: all 0.18s;
            width: 100%;
        }

        .form-control:focus {
            border-color: var(--green);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(76,175,80,0.12);
        }

        .form-control::placeholder { color: var(--gray-400); }

        .form-hint {
            font-size: 0.72rem;
            color: var(--gray-400);
            margin-top: 0.2rem;
        }

        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 0.75rem;
            padding: 1.25rem 1.5rem;
            border-top: 1px solid var(--gray-100);
            background: var(--gray-50);
        }

        /* ======= IMAGE UPLOAD ======= */
        .image-upload-area {
            border: 2px dashed var(--gray-200);
            border-radius: var(--radius);
            padding: 1.5rem;
            text-align: center;
            cursor: pointer;
            transition: all 0.18s;
            background: var(--gray-50);
        }

        .image-upload-area:hover {
            border-color: var(--green);
            background: var(--green-light);
        }

        .image-upload-icon {
            font-size: 2rem;
            color: var(--gray-400);
            margin-bottom: 0.5rem;
        }

        .image-upload-text {
            font-size: 0.82rem;
            color: var(--gray-400);
            line-height: 1.5;
        }

        .image-upload-text strong { color: var(--green); }
        .image-upload-text span { display: block; margin-top: 0.2rem; font-size: 0.72rem; }

        .image-preview {
            margin-top: 0.75rem;
            position: relative;
            display: none;
        }

        .image-preview img {
            width: 120px;
            height: 120px;
            object-fit: cover;
            border-radius: var(--radius-sm);
            border: 1.5px solid var(--gray-200);
        }

        .image-preview-label {
            font-size: 0.75rem;
            color: var(--green-dark);
            font-weight: 600;
            margin-top: 0.4rem;
            display: flex;
            align-items: center;
            gap: 0.3rem;
        }

        .image-preview-label i { font-size: 0.7rem; }

        /* ======= INFO BOX ======= */
        .info-box {
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            border-radius: var(--radius-sm);
            padding: 0.9rem 1.1rem;
            font-size: 0.82rem;
            color: #1e40af;
            display: flex;
            align-items: flex-start;
            gap: 0.6rem;
            line-height: 1.5;
        }

        .info-box i { color: #3b82f6; margin-top: 0.1rem; flex-shrink: 0; }

        /* ======= BUTTONS ======= */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.45rem;
            padding: 0.7rem 1.4rem;
            border-radius: var(--radius-sm);
            font-size: 0.875rem;
            font-weight: 600;
            font-family: 'Inter', sans-serif;
            cursor: pointer;
            border: none;
            text-decoration: none;
            transition: all 0.18s ease;
            white-space: nowrap;
        }

        .btn-green {
            background: var(--green);
            color: #fff;
            box-shadow: 0 2px 8px rgba(76,175,80,0.3);
        }

        .btn-green:hover {
            background: var(--green-dark);
            box-shadow: 0 4px 14px rgba(56,142,60,0.35);
            transform: translateY(-1px);
        }

        .btn-outline {
            background: var(--white);
            color: var(--gray-600);
            border: 1.5px solid var(--gray-200);
        }

        .btn-outline:hover {
            background: var(--gray-50);
            border-color: var(--gray-400);
            color: var(--gray-800);
        }

        /* ======= FOOTER ======= */
        .footer {
            background: var(--white);
            border-top: 1px solid var(--gray-200);
            padding: 1.2rem 2rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .footer-logo {
            display: flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 0.9rem;
            font-weight: 700;
            color: var(--green-dark);
            text-decoration: none;
        }

        .footer-logo i { color: var(--green); }
        .footer-copy { font-size: 0.78rem; color: var(--gray-400); }

        /* ======= RESPONSIVE ======= */
        @media (max-width: 900px) {
            .layout { flex-direction: column; padding: 0 1rem; }
            .sidebar { width: 100%; position: static; }
            .sidebar-nav { display: flex; flex-wrap: wrap; gap: 0.25rem; }
            .sidebar-nav a { width: auto; }
        }

        @media (max-width: 640px) {
            .form-grid { grid-template-columns: 1fr; }
            .form-group.full { grid-column: span 1; }
            .layout { padding: 0 1rem; }
            .topnav { padding: 0 1rem; }
            .nav-links { display: none; }
        }
    </style>
</head>
<body>

<!-- ====== TOPNAV ====== -->
<nav class="topnav">
    <a href="home.jsp" class="nav-logo">
        <i class="fa-solid fa-apple-whole"></i> Sena Shop
    </a>
    <div class="nav-links">
        <a href="home.jsp">Trang Chủ</a>
        <a href="products">Sản Phẩm</a>
    </div>
    <div class="nav-right">
        <button class="nav-icon-btn" title="Giỏ hàng"><i class="fa-solid fa-basket-shopping"></i></button>
        <img class="nav-avatar" src="<%= avatarUrl %>" alt="avatar">
    </div>
</nav>

<!-- ====== LAYOUT ====== -->
<div class="layout">

    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-nav">
            <a href="profile"><i class="fa-regular fa-user"></i> Hồ Sơ</a>
            <a href="products"><i class="fa-brands fa-opencart"></i> Sản Phẩm</a>
            <a href="add-product"><i class="fa-solid fa-plus"></i> Thêm Sản Phẩm</a>
            <a href="category" class="active"><i class="fa-solid fa-layer-group"></i> Danh Mục</a>
            <a href="#"><i class="fa-solid fa-basket-shopping"></i> Đơn Hàng</a>
            <a href="#"><i class="fa-regular fa-heart"></i> Yêu Thích</a>
            <a href="logout" class="logout" style="margin-top:0.5rem;"><i class="fa-solid fa-right-from-bracket"></i> Đăng Xuất</a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="main">

        <!-- Breadcrumb -->
        <div class="breadcrumb">
            <a href="category"><i class="fa-solid fa-layer-group"></i> Danh Mục</a>
            <i class="fa-solid fa-chevron-right" style="font-size:0.6rem;color:var(--gray-400);"></i>
            <span><%= pageTitle %></span>
        </div>

        <!-- Alerts -->
        <% if (formError != null) { %>
        <div class="alert alert-danger">
            <i class="fa-solid fa-circle-exclamation"></i>
            <span><%= formError %></span>
        </div>
        <% } %>

        <!-- Info box -->
        <div class="info-box">
            <i class="fa-solid fa-circle-info"></i>
            <span>Tên danh mục phải là duy nhất trong hệ thống. Ảnh đại diện là tùy chọn — nếu không upload, ảnh cũ sẽ được giữ nguyên (khi chỉnh sửa).</span>
        </div>

        <!-- Form -->
        <form action="<%= actionUrl %>" method="POST" enctype="multipart/form-data">

            <% if (isEdit) { %>
            <input type="hidden" name="id" value="<%= category.getId() %>">
            <% } %>

            <!-- Thong tin danh muc -->
            <div class="card">
                <div class="card-header">
                    <i class="fa-solid fa-info-circle" style="color:var(--green);font-size:1rem;"></i>
                    <div class="card-title">Thông Tin Danh Mục</div>
                </div>
                <div class="card-body">
                    <div class="form-grid">

                        <div class="form-group">
                            <label class="form-label" for="name">
                                Tên danh mục <span class="required">*</span>
                            </label>
                            <input type="text" name="name" class="form-control"
                                   placeholder="VD: Trái Cây Tươi"
                                   value="<%= isEdit && category.getName() != null ? category.getName().replace("\"", "&quot;") : "" %>"
                                   maxlength="100"
                                   required>
                            <span class="form-hint">Tối đa 100 ký tự, không trùng với danh mục khác.</span>
                        </div>

                    </div>
                </div>
            </div>

            <!-- Hinh anh -->
            <div class="card" style="margin-top:1.25rem;">
                <div class="card-header">
                    <i class="fa-solid fa-images" style="color:var(--green);font-size:1rem;"></i>
                    <div class="card-title">Hình Ảnh Danh Mục</div>
                </div>
                <div class="card-body">

                    <div class="form-group">
                        <label class="form-label">Ảnh đại diện</label>
                        <div class="image-upload-area" id="imageUploadArea">
                            <div class="image-upload-icon"><i class="fa-solid fa-cloud-arrow-up"></i></div>
                            <div class="image-upload-text">
                                <strong>Click để chọn ảnh</strong>
                                <span>JPG, JPEG, PNG, WEBP &bull; Tối đa 5MB</span>
                            </div>
                            <input type="file" name="image" id="imageInput"
                                   accept=".jpg,.jpeg,.png,.webp"
                                   aria-label="Chọn ảnh đại diện danh mục"
                                   style="display:block;margin:0.75rem auto 0;cursor:pointer;">
                        </div>
                        <span class="form-hint">Để trống nếu không muốn thay đổi ảnh.</span>

                        <% if (isEdit && category.getImage() != null && !category.getImage().trim().isEmpty()) { %>
                        <div class="image-preview" id="currentImagePreview">
                            <img src="<%= imgUrl.apply(category.getImage()) %>" alt="Ảnh hiện tại" id="currentImg">
                            <div class="image-preview-label">
                                <i class="fa-solid fa-check-circle"></i>
                                Ảnh hiện tại — sẽ được thay thế nếu bạn chọn ảnh mới
                            </div>
                        </div>
                        <% } %>

                        <div class="image-preview" id="newImagePreview" style="display:none;">
                            <img src="" alt="Ảnh mới" id="newImg">
                            <div class="image-preview-label" style="color:var(--green);">
                                <i class="fa-solid fa-check-circle"></i>
                                Ảnh mới sẽ được lưu
                            </div>
                        </div>
                    </div>

                </div>
            </div>

            <!-- Actions -->
            <div class="form-actions">
                <a href="category" class="btn btn-outline">
                    <i class="fa-solid fa-arrow-left"></i> Quay Lại
                </a>
                <button type="submit" class="btn btn-green">
                    <i class="fa-solid fa-floppy-disk"></i>
                    <%= isEdit ? "Lưu Thay Đổi" : "Tạo Danh Mục" %>
                </button>
            </div>

        </form>

    </main>
</div><!-- /layout -->

<!-- ====== FOOTER ====== -->
<footer class="footer">
    <a href="home.jsp" class="footer-logo"><i class="fa-solid fa-apple-whole"></i> Sena Shop</a>
    <span class="footer-copy">&copy; 2024 Sena Shop. Trái cây tươi ngon mỗi ngày.</span>
</footer>

<script>
    // Preview new image when selected
    const imageInput = document.getElementById('imageInput');
    const newImagePreview = document.getElementById('newImagePreview');
    const newImg = document.getElementById('newImg');

    if (imageInput) {
        imageInput.addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(ev) {
                    if (newImg && newImagePreview) {
                        newImg.src = ev.target.result;
                        newImagePreview.style.display = 'block';
                    }
                    // Hide "current image" label when new image selected
                    const currentPreview = document.getElementById('currentImagePreview');
                    if (currentPreview) currentPreview.style.display = 'none';
                };
                reader.readAsDataURL(file);
            }
        });
    }
</script>

</body>
</html>



