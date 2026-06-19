<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer" %>
<%@ page import="model.Category" %>
<%@ page import="model.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Object rawUser = session.getAttribute("user");
    Object rawUserId = session.getAttribute("userId");

    Customer user = (Customer) rawUser;
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String avatarUrl = user.getAvatar();
    if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
        String fullname = user.getFullname() != null ? user.getFullname() : user.getUsername();
        avatarUrl = "https://ui-avatars.com/api/?name="
                  + java.net.URLEncoder.encode(fullname, "UTF-8")
                  + "&background=4caf50&color=fff&size=80&bold=true&rounded=true";
    }

    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");

    Product product = (Product) request.getAttribute("product");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<String> currentImages = (List<String>) request.getAttribute("currentImages");
    if (categories == null) categories = java.util.Collections.emptyList();
    if (currentImages == null) currentImages = java.util.Collections.emptyList();

    SimpleDateFormat dbDateFormat = new SimpleDateFormat("yyyy-MM-dd");
    String expiredDateValue = "";
    if (product != null && product.getExpiredDate() != null) {
        expiredDateValue = dbDateFormat.format(product.getExpiredDate());
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh Sửa Sản Phẩm | Sena Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --green:       #4caf50;
            --green-dark:  #388e3c;
            --green-light: #e8f5e9;
            --green-mid:   #c8e6c9;
            --amber:       #f59e0b;
            --amber-light: #fffbeb;
            --bg:          #f0f4f1;
            --white:       #ffffff;
            --gray-50:     #f8fafb;
            --gray-100:    #eef1ee;
            --gray-200:    #dde5dd;
            --gray-400:    #9aaa9a;
            --gray-600:    #5a6a5a;
            --gray-800:    #2d3d2d;
            --shadow-sm:   0 1px 3px rgba(0,0,0,.08);
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

        /* ======= SECTION LABEL ======= */
        .section-label {
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: var(--gray-400);
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.4rem;
        }

        /* ======= FORM ======= */
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
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
        textarea.form-control { resize: vertical; min-height: 100px; }
        select.form-control option { background: var(--white); }

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

        /* ======= CURRENT IMAGES ======= */
        .current-images-section { margin-bottom: 1.25rem; }

        .current-images-grid {
            display: flex;
            flex-wrap: wrap;
            gap: 0.75rem;
            margin-top: 0.75rem;
        }

        .current-image-thumb {
            width: 90px;
            height: 90px;
            border-radius: 10px;
            object-fit: cover;
            border: 2px solid var(--gray-200);
            position: relative;
        }

        .current-image-thumb.is-cover {
            border-color: var(--green);
            box-shadow: 0 0 0 2px var(--green-mid);
        }

        .image-cover-badge {
            position: absolute;
            bottom: 4px;
            left: 4px;
            background: var(--green);
            color: #fff;
            font-size: 0.6rem;
            font-weight: 700;
            padding: 1px 5px;
            border-radius: 4px;
        }

        /* ======= REPLACE IMAGES TOGGLE ======= */
        .replace-images-toggle {
            display: flex;
            align-items: center;
            gap: 0.6rem;
            padding: 0.8rem 1rem;
            background: var(--amber-light);
            border: 1.5px solid #fde68a;
            border-radius: var(--radius-sm);
            margin-bottom: 1rem;
            font-size: 0.875rem;
            color: #92400e;
            cursor: pointer;
        }

        .replace-images-toggle input[type="checkbox"] {
            width: 16px;
            height: 16px;
            accent-color: var(--amber);
            cursor: pointer;
        }

        .replace-images-panel {
            display: none;
        }

        .replace-images-panel.active {
            display: block;
        }

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
            <a href="#" class="active"><i class="fa-solid fa-pen-to-square"></i> Chỉnh Sửa</a>
            <a href="#"><i class="fa-solid fa-basket-shopping"></i> Đơn Hàng</a>
            <a href="#"><i class="fa-regular fa-heart"></i> Yêu Thích</a>
            <a href="logout" class="logout" style="margin-top:0.5rem;"><i class="fa-solid fa-right-from-bracket"></i> Đăng Xuất</a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="main">

        <!-- Breadcrumb -->
        <div class="breadcrumb">
            <a href="products"><i class="fa-solid fa-box"></i> Sản Phẩm</a>
            <i class="fa-solid fa-chevron-right" style="font-size:0.6rem;color:var(--gray-400);"></i>
            <span>Chỉnh Sửa Sản Phẩm</span>
        </div>

        <!-- Alerts -->
        <% if (message != null) { %>
        <div class="alert alert-success">
            <i class="fa-solid fa-circle-check"></i>
            <span><%= message %></span>
        </div>
        <% } %>
        <% if (error != null) { %>
        <div class="alert alert-danger">
            <i class="fa-solid fa-circle-exclamation"></i>
            <span><%= error %></span>
        </div>
        <% } %>

        <!-- Info box -->
        <div class="info-box">
            <i class="fa-solid fa-circle-info"></i>
            <span>Bỏ trống phần ảnh nếu bạn muốn giữ nguyên ảnh hiện tại. Tick chọn <strong>Thay đổi ảnh</strong> để tải lên ảnh mới.</span>
        </div>

    <!-- Form -->
    <% if (product != null) { %>
    <form action="edit-product" method="POST" enctype="multipart/form-data">
    <input type="hidden" name="productId" value="<%= product.getId() %>">
    <input type="hidden" name="action" value="update">

            <!-- Thong tin co ban -->
            <div class="card">
                <div class="card-header">
                    <i class="fa-solid fa-info-circle" style="color:var(--green);font-size:1rem;"></i>
                    <div class="card-title">Thông Tin Cơ Bản</div>
                </div>
                <div class="card-body">
                    <div class="section-label">
                        <i class="fa-solid fa-asterisk" style="font-size:0.5rem;color:var(--green);"></i>
                        Thông tin sản phẩm
                    </div>
                    <div class="form-grid">

                        <div class="form-group full">
                            <label class="form-label">Tên sản phẩm <span class="required">*</span></label>
                            <input type="text" name="title" class="form-control"
                                   value="<%= product.getTitle() != null ? product.getTitle() : "" %>"
                                   placeholder="VD: Cam Vinh ruot do late 5kg" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Danh mục <span class="required">*</span></label>
                            <select name="categoryId" class="form-control" required>
                                <option value="">-- Chọn danh mục --</option>
                                <% for (Category c : categories) { %>
                                <option value="<%= c.getId() %>"
                                    <%= (product.getCategoryId() == c.getId()) ? "selected" : "" %>>
                                    <%= c.getName() %>
                                </option>
                                <% } %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Đơn vị tính <span class="required">*</span></label>
                            <input type="text" name="unit" class="form-control"
                                   value="<%= product.getUnit() != null ? product.getUnit() : "" %>"
                                   placeholder="VD: kg, tan, qua" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Giá gốc (VNĐ) <span class="required">*</span></label>
                            <input type="number" name="originalPrice" class="form-control"
                                   value="<%= product.getOriginalPrice() %>"
                                   placeholder="VD: 150000" min="0" step="1000" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Giá bán (VNĐ) <span class="required">*</span></label>
                            <input type="number" name="salePrice" class="form-control"
                                   value="<%= product.getSalePrice() %>"
                                   placeholder="VD: 120000" min="0" step="1000" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Số lượng trong kho <span class="required">*</span></label>
                            <input type="number" name="stockQuantity" class="form-control"
                                   value="<%= product.getStockQuantity() %>"
                                   placeholder="VD: 100" min="0" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Ngày hết hạn</label>
                            <input type="date" name="expiredDate" class="form-control"
                                   value="<%= expiredDateValue %>">
                            <span class="form-hint">Để trống nếu không có hạn sử dụng</span>
                        </div>

                        <div class="form-group full">
                            <label class="form-label">Mô tả sản phẩm <span class="required">*</span></label>
                            <textarea name="description" class="form-control"
                                      placeholder="Mô tả chi tiết về sản phẩm: xuất xứ, cách bảo quản, ưu điểm..."
                                      required><%= product.getDescription() != null ? product.getDescription() : "" %></textarea>
                        </div>

                    </div>
                </div>
            </div>

            <!-- Hinh anh -->
            <div class="card">
                <div class="card-header">
                    <i class="fa-solid fa-images" style="color:var(--green);font-size:1rem;"></i>
                    <div class="card-title">Hình Ảnh Sản Phẩm</div>
                </div>
                <div class="card-body">
                    <div class="section-label">
                        <i class="fa-solid fa-asterisk" style="font-size:0.5rem;color:var(--green);"></i>
                        Ảnh hiện tại
                    </div>

                    <% if (!currentImages.isEmpty()) { %>
                    <div class="current-images-grid">
                        <% for (int i = 0; i < currentImages.size(); i++) { %>
                        <div style="position:relative;display:inline-block;">
                            <img src="<%= currentImages.get(i) %>" alt="Ảnh <%= i + 1 %>"
                                 class="current-image-thumb <%= i == 0 ? "is-cover" : "" %>">
                            <% if (i == 0) { %>
                            <span class="image-cover-badge">Cover</span>
                            <% } %>
                        </div>
                        <% } %>
                    </div>
                    <% } else { %>
                    <p style="font-size:0.82rem;color:var(--gray-400);margin-top:0.5rem;">Chưa có ảnh nào.</p>
                    <% } %>

                    <!-- Toggle thay doi anh -->
                    <label class="replace-images-toggle" for="replaceImagesCheck" style="margin-top:1.25rem;">
                        <input type="checkbox" id="replaceImagesCheck" name="replaceImages" value="true"
                               onchange="toggleImagePanel(this.checked)">
                        <strong><i class="fa-solid fa-pen"></i> Thay đổi ảnh</strong>
                        &mdash; Bỏ chọn để giữ nguyên ảnh hiện tại
                    </label>

                    <!-- Panel upload anh moi -->
                    <div id="imagePanel" class="replace-images-panel">
                        <div class="form-group" style="margin-bottom:1.25rem;">
                            <label class="form-label">Ảnh chính</label>
                            <div class="image-upload-area">
                                <div class="image-upload-icon"><i class="fa-solid fa-cloud-arrow-up"></i></div>
                                <div class="image-upload-text">
                                    <strong>Click để chọn ảnh chính</strong>
                                    <span>JPG, JPEG, PNG, WEBP &bull; Tối đa 5MB</span>
                                </div>
                                <input type="file" name="images" accept=".jpg,.jpeg,.png,.webp"
                                       style="display:block;margin:0.75rem auto 0;cursor:pointer;">
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Ảnh phụ</label>
                            <div class="image-upload-area">
                                <div class="image-upload-icon"><i class="fa-solid fa-images"></i></div>
                                <div class="image-upload-text">
                                    <strong>Click để chọn nhiều ảnh phụ</strong>
                                    <span>JPG, JPEG, PNG, WEBP &bull; Tối đa 5MB mỗi ảnh</span>
                                </div>
                                <input type="file" name="images" accept=".jpg,.jpeg,.png,.webp"
                                       multiple style="display:block;margin:0.75rem auto 0;cursor:pointer;">
                            </div>
                            <span class="form-hint">Có thể chọn nhiều ảnh cùng lúc. Ảnh đầu tiên sẽ là ảnh chính.</span>
                        </div>
                    </div>

                </div>
            </div>

            <!-- Actions -->
            <div class="form-actions">
                <a href="products" class="btn btn-outline">
                    <i class="fa-solid fa-xmark"></i> Hủy
                </a>
                <button type="submit" class="btn btn-green">
                    <i class="fa-solid fa-floppy-disk"></i> Cập Nhật
                </button>
            </div>

        </form>
        <% } else { %>
        <div class="alert alert-danger">
            <i class="fa-solid fa-circle-exclamation"></i>
            <span>Không tìm thấy sản phẩm. <a href="products">Quay lại danh sách.</a></span>
        </div>
        <% } %>

    </main>
</div><!-- /layout -->

<!-- ====== FOOTER ====== -->
<footer class="footer">
    <a href="home.jsp" class="footer-logo"><i class="fa-solid fa-apple-whole"></i> Sena Shop</a>
    <span class="footer-copy">&copy; 2024 Sena Shop. Trái cây tươi ngon mỗi ngày.</span>
</footer>

<script>
    function toggleImagePanel(checked) {
        var panel = document.getElementById('imagePanel');
        if (checked) {
            panel.classList.add('active');
        } else {
            panel.classList.remove('active');
        }
    }
</script>

</body>
</html>
