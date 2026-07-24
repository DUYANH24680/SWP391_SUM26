<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Category" %>
<%@ page import="java.util.List" %>
<%
    Object rawUser = session.getAttribute("Account");
    Object rawUserId = session.getAttribute("userId");
    System.out.println("[add-product.jsp] rawUser=" + rawUser + " type=" + (rawUser != null ? rawUser.getClass().getName() : "null"));
    System.out.println("[add-product.jsp] rawUserId=" + rawUserId + " type=" + (rawUserId != null ? rawUserId.getClass().getName() : "null"));

    Account user = (Account) rawUser;
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String role = (String) session.getAttribute("role");
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

    List<Category> categories = (List<Category>) request.getAttribute("categories");
    if (categories == null) categories = java.util.Collections.emptyList();
    System.out.println("[add-product.jsp] categories size from request: " + categories.size());
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thêm Sản Phẩm | SenaFruit</title>
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

        /* ======= VARIANT TABLE ======= */
        .variant-table-wrap {
            overflow-x: auto;
            border-radius: var(--radius-sm);
            border: 1.5px solid var(--gray-200);
        }

        .variant-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.875rem;
        }

        .variant-table thead th {
            background: var(--gray-50);
            color: var(--gray-600);
            font-weight: 600;
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            padding: 0.7rem 0.85rem;
            text-align: left;
            white-space: nowrap;
        }

        .variant-table tbody tr {
            border-top: 1px solid var(--gray-100);
        }

        .variant-table tbody td {
            padding: 0.5rem 0.85rem;
            vertical-align: middle;
        }

        .variant-table input,
        .variant-table select {
            width: 100%;
            background: var(--gray-50);
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            padding: 0.5rem 0.65rem;
            font-size: 0.82rem;
            font-family: 'Inter', sans-serif;
            color: var(--gray-800);
            outline: none;
            transition: border-color 0.18s;
        }

        .variant-table input:focus,
        .variant-table select:focus {
            border-color: var(--green);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(76,175,80,0.12);
        }

        .variant-table input[type="number"] {
            -moz-appearance: textfield;
        }

        .variant-table input::-webkit-outer-spin-button,
        .variant-table input::-webkit-inner-spin-button {
            -webkit-appearance: none;
        }

        .col-weight { width: 130px; }
        .col-unit   { width: 100px; }
        .col-price  { width: 140px; }
        .col-stock  { width: 120px; }
        .col-action { width: 50px; text-align: center; }

        .btn-remove-variant {
            background: #fee2e2;
            border: 1.5px solid #fecaca;
            color: #dc2626;
            width: 32px;
            height: 32px;
            border-radius: var(--radius-sm);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.15s;
            font-size: 0.8rem;
        }

        .btn-remove-variant:hover {
            background: #fecaca;
            border-color: #fca5a5;
        }

        .btn-add-variant {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.55rem 1rem;
            border-radius: var(--radius-sm);
            font-size: 0.82rem;
            font-weight: 600;
            font-family: 'Inter', sans-serif;
            cursor: pointer;
            border: none;
            background: var(--green-light);
            color: var(--green-dark);
            border: 1.5px solid var(--green-mid);
            transition: all 0.15s;
            margin-top: 0.75rem;
        }

        .btn-add-variant:hover {
            background: var(--green-mid);
            border-color: var(--green);
        }

        .variant-hint {
            font-size: 0.72rem;
            color: var(--gray-400);
            margin-top: 0.6rem;
            display: flex;
            align-items: center;
            gap: 0.35rem;
        }

        .variant-hint i { color: var(--green); }
    </style>
</head>
<body>

<!-- ====== TOPNAV ====== -->
<nav class="topnav">
    <a href="home.jsp" class="nav-logo">
        <i class="fa-solid fa-apple-whole"></i> SenaFruit
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
        <% if ("customer".equalsIgnoreCase(role)) { %>
        <a href="customer-dashboard"><i class="fa-solid fa-gauge"></i> Dashboard</a>
        <% } else if ("seller".equalsIgnoreCase(role)) { %>
        <a href="seller/dashboard"><i class="fa-solid fa-gauge"></i> Dashboard</a>
        <% } %>
        <a href="profile"><i class="fa-regular fa-user"></i> Hồ Sơ</a>
            <a href="products"><i class="fa-brands fa-opencart"></i> Sản Phẩm</a>
            <a href="#" class="active"><i class="fa-solid fa-plus"></i> Thêm Sản Phẩm</a>
            <% if ("customer".equalsIgnoreCase(role)) { %>
            <a href="my-orders"><i class="fa-solid fa-basket-shopping"></i> Đơn Hàng</a>
            <% } else if ("seller".equalsIgnoreCase(role)) { %>
            <a href="seller/orders"><i class="fa-solid fa-basket-shopping"></i> Đơn Hàng</a>
            <% } else if ("admin".equalsIgnoreCase(role)) { %>
            <a href="admin/orders"><i class="fa-solid fa-basket-shopping"></i> Đơn Hàng</a>
            <% } %>
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
            <span>Thêm Sản Phẩm Mới</span>
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
            <span>Sản phẩm sau khi tạo sẽ có trạng thái <strong>Chờ duyệt</strong> (status = 0). Bạn chỉ có thể thêm sản phẩm khi cửa hàng đã được phê duyệt.</span>
        </div>

    <!-- Form -->
    <form action="add-product" method="POST" enctype="multipart/form-data">
    <input type="hidden" name="shopId" value="<%= session.getAttribute("shopId") != null ? session.getAttribute("shopId") : 1 %>">

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
                                   placeholder="VD: Cam Vinh ruot do late 5kg" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Danh mục <span class="required">*</span></label>
                            <select name="categoryId" class="form-control" required>
                                <option value="">-- Chọn danh mục --</option>
                                <% for (Category c : categories) { %>
                                <option value="<%= c.getId() %>"><%= c.getName() %></option>
                                <% } %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Đơn vị tính <span class="required">*</span></label>
                            <input type="text" name="unit" class="form-control"
                                   placeholder="VD: kg, tan, qua" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Giá gốc (VNĐ) <span class="required">*</span></label>
                            <input type="number" name="originalPrice" class="form-control"
                                   placeholder="VD: 150000" min="0" step="1000" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Giá bán (VNĐ) <span class="required">*</span></label>
                            <input type="number" name="salePrice" class="form-control"
                                   placeholder="VD: 120000" min="0" step="1000" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Số lượng trong kho <span class="required">*</span></label>
                            <input type="number" name="stockQuantity" class="form-control"
                                   placeholder="VD: 100" min="0" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Ngày hết hạn</label>
                            <input type="date" name="expiredDate" class="form-control">
                            <span class="form-hint">Để trống nếu không có hạn sử dụng</span>
                        </div>

                        <div class="form-group full">
                            <label class="form-label">Mô tả sản phẩm <span class="required">*</span></label>
                            <textarea name="description" class="form-control"
                                      placeholder="Mô tả chi tiết về sản phẩm: xuất xứ, cách bảo quản, ưu điểm..."
                                      required></textarea>
                        </div>

                    </div>
                </div>
            </div>

            <!-- Variants theo trong luong -->
            <div class="card">
                <div class="card-header">
                    <i class="fa-solid fa-scale-balanced" style="color:var(--green);font-size:1rem;"></i>
                    <div class="card-title">Variants theo Trọng Lượng</div>
                </div>
                <div class="card-body">
                    <div class="section-label">
                        <i class="fa-solid fa-plus" style="font-size:0.5rem;color:var(--green);"></i>
                        Khai bao cac tuy chon trong luong (khong bat buoc)
                    </div>

                    <div class="variant-table-wrap">
                        <table class="variant-table" id="variantTable">
                            <thead>
                                <tr>
                                    <th class="col-weight">Trọng lượng</th>
                                    <th class="col-unit">Đơn vị</th>
                                    <th class="col-price">Giá bán (VNĐ)</th>
                                    <th class="col-stock">Stock</th>
                                    <th class="col-action"></th>
                                </tr>
                            </thead>
                            <tbody id="variantTableBody">
                                <!-- Dynamic rows inserted by JS -->
                            </tbody>
                        </table>
                    </div>

                    <button type="button" class="btn-add-variant" id="btnAddVariant">
                        <i class="fa-solid fa-plus"></i> Thêm Variant
                    </button>

                    <div class="variant-hint">
                        <i class="fa-solid fa-circle-info"></i>
                        Bo trong tat ca neu san pham khong co tuy chon trong luong. Gia salePrice ben duoi se duoc su dung lam gia mac dinh.
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
                        Upload ảnh sản phẩm
                    </div>

                    <div class="form-group" style="margin-bottom:1.25rem;">
                        <label class="form-label">Ảnh chính <span class="required">*</span></label>
                        <div class="image-upload-area">
                            <div class="image-upload-icon"><i class="fa-solid fa-cloud-arrow-up"></i></div>
                            <div class="image-upload-text">
                                <strong>Click để chọn ảnh chính</strong>
                                <span>JPG, JPEG, PNG, WEBP &bull; Tối đa 5MB</span>
                            </div>
                            <input type="file" name="images" accept=".jpg,.jpeg,.png,.webp"
                                   style="display:block;margin:0.75rem auto 0;cursor:pointer;" required>
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

            <!-- Actions -->
            <div class="form-actions">
                <a href="products" class="btn btn-outline">
                    <i class="fa-solid fa-arrow-left"></i> Quay Lại
                </a>
                <button type="submit" class="btn btn-green">
                    <i class="fa-solid fa-floppy-disk"></i> Tạo Sản Phẩm
                </button>
            </div>

        </form>

    </main>
</div><!-- /layout -->

<!-- ====== FOOTER ====== -->
<footer class="footer">
    <a href="home.jsp" class="footer-logo"><i class="fa-solid fa-apple-whole"></i> SenaFruit</a>
    <span class="footer-copy">&copy; 2024 SenaFruit. Trái cây tươi ngon mỗi ngày.</span>
</footer>

<script>
(function() {
    const tableBody = document.getElementById('variantTableBody');
    const btnAdd   = document.getElementById('btnAddVariant');

    function buildRow(weightVal, unitVal, priceVal, stockVal) {
        const tr = document.createElement('tr');

        const tdWeight = document.createElement('td');
        tdWeight.innerHTML = '<input type="number" name="variantWeight" '
            + 'placeholder="VD: 500" min="1" step="1" value="' + (weightVal || '') + '">';

        const tdUnit = document.createElement('td');
        tdUnit.innerHTML = '<select name="variantUnit" class="form-control">'
            + '<option value="kg"' + (unitVal === 'kg' ? ' selected' : '') + '>kg</option>'
            + '<option value="g"'  + (unitVal === 'g'  ? ' selected' : '') + '>g</option>'
            + '<option value="ml"' + (unitVal === 'ml' ? ' selected' : '') + '>ml</option>'
            + '<option value="l"'  + (unitVal === 'l'  ? ' selected' : '') + '>l</option>'
            + '</select>';

        const tdPrice = document.createElement('td');
        tdPrice.innerHTML = '<input type="number" name="variantPrice" '
            + 'placeholder="VD: 120000" min="0" step="1000" value="' + (priceVal || '') + '">';

        const tdStock = document.createElement('td');
        tdStock.innerHTML = '<input type="number" name="variantStock" '
            + 'placeholder="VD: 50" min="0" value="' + (stockVal || '') + '">';

        const tdAction = document.createElement('td');
        tdAction.className = 'col-action';
        tdAction.innerHTML = '<button type="button" class="btn-remove-variant" '
            + 'onclick="this.closest(\'tr\').remove()" title="Xoa variant">'
            + '<i class="fa-solid fa-trash-can"></i></button>';

        tr.appendChild(tdWeight);
        tr.appendChild(tdUnit);
        tr.appendChild(tdPrice);
        tr.appendChild(tdStock);
        tr.appendChild(tdAction);

        return tr;
    }

    btnAdd.addEventListener('click', function() {
        tableBody.appendChild(buildRow());
    });

    // Optional: start with one empty row so the user sees the table
    tableBody.appendChild(buildRow());
})();
</script>

</body>
</html>
