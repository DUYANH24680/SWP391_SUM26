<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer" %>
<%@ page import="model.Product" %>
<%@ page import="java.util.List" %>
<%
    Object rawUser = session.getAttribute("user");
    Object rawUserId = session.getAttribute("userId");

    Customer user = (Customer) rawUser;
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
                  + "&background=ef4444&color=fff&size=80&bold=true&rounded=true";
    }

    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");

    List<Product> products = (List<Product>) request.getAttribute("products");
    if (products == null) products = java.util.Collections.emptyList();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xuất Kho | Sena Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --red:        #ef4444;
            --red-dark:    #dc2626;
            --red-light:   #fef2f2;
            --red-mid:     #fecaca;
            --bg:          #f8f4f4;
            --white:       #ffffff;
            --gray-50:     #f8fafb;
            --gray-100:     #f1f1f1;
            --gray-200:     #e2e2e2;
            --gray-400:     #a8a8a8;
            --gray-600:     #6a6a6a;
            --gray-800:     #3d3d3d;
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
            color: var(--red-dark);
            text-decoration: none;
            white-space: nowrap;
            letter-spacing: -0.01em;
        }

        .nav-logo i { color: var(--red); font-size: 1.15rem; }

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

        .nav-links a:hover { background: var(--red-light); color: var(--red-dark); }

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

        .nav-icon-btn:hover { background: var(--red-light); color: var(--red-dark); }

        .nav-avatar {
            width: 38px; height: 38px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--red);
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

        .sidebar-nav a:hover { background: var(--red-light); color: var(--red-dark); }
        .sidebar-nav a.active { background: var(--red); color: #fff; font-weight: 600; }
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

        .card-title i { color: var(--red); }

        .card-body { padding: 1.5rem; }

        /* ======= BREADCRUMB ======= */
        .breadcrumb {
            display: flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 0.82rem;
            color: var(--gray-400);
        }

        .breadcrumb a { color: var(--red); text-decoration: none; font-weight: 500; }
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
            border-color: var(--red);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(239,68,68,0.12);
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

        .btn-red {
            background: var(--red);
            color: #fff;
            box-shadow: 0 2px 8px rgba(239,68,68,0.3);
        }

        .btn-red:hover {
            background: var(--red-dark);
            box-shadow: 0 4px 14px rgba(220,38,38,0.35);
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

        /* ======= INFO BOX ======= */
        .info-box {
            background: #fff7ed;
            border: 1px solid #fed7aa;
            border-radius: var(--radius-sm);
            padding: 0.9rem 1.1rem;
            font-size: 0.82rem;
            color: #7c2d12;
            display: flex;
            align-items: flex-start;
            gap: 0.6rem;
            line-height: 1.5;
        }

        .info-box i { color: #ea580c; margin-top: 0.1rem; flex-shrink: 0; }

        /* ======= STOCK BADGE ======= */
        .stock-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.2rem 0.55rem;
            border-radius: 20px;
            font-size: 0.72rem;
            font-weight: 600;
        }

        .stock-badge.low  { background: #fff7ed; color: #c2410c; border: 1px solid #fed7aa; }
        .stock-badge.ok   { background: #dcfce7; color: #166534;  border: 1px solid #bbf7d0; }
        .stock-badge.zero { background: #fee2e2; color: #991b1b;  border: 1px solid #fecaca; }

        /* ======= PRODUCT SUMMARY ======= */
        .product-summary {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1rem;
            background: var(--gray-50);
            border-radius: var(--radius-sm);
            border: 1px solid var(--gray-200);
            margin-bottom: 0.5rem;
        }

        .product-summary-img {
            width: 56px;
            height: 56px;
            border-radius: var(--radius-sm);
            object-fit: cover;
            border: 1px solid var(--gray-200);
            flex-shrink: 0;
        }

        .product-summary-img-placeholder {
            width: 56px;
            height: 56px;
            border-radius: var(--radius-sm);
            background: var(--gray-200);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--gray-400);
            font-size: 1.4rem;
            flex-shrink: 0;
        }

        .product-summary-info { flex: 1; min-width: 0; }

        .product-summary-name {
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--gray-800);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .product-summary-meta {
            font-size: 0.72rem;
            color: var(--gray-400);
            margin-top: 0.2rem;
            display: flex;
            gap: 0.75rem;
            flex-wrap: wrap;
        }

        /* ======= STOCK PREVIEW ======= */
        .stock-preview {
            background: var(--red-light);
            border: 1px solid var(--red-mid);
            border-radius: var(--radius-sm);
            padding: 0.9rem 1.1rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-top: 0.5rem;
        }

        .stock-preview i { color: var(--red-dark); font-size: 1rem; flex-shrink: 0; }

        .stock-preview-text {
            font-size: 0.82rem;
            color: var(--red-dark);
            line-height: 1.5;
        }

        .stock-preview-text strong { font-weight: 700; }

        .stock-arrow { color: var(--red); font-weight: 700; margin: 0 0.3rem; }

        .stock-error {
            background: #fff7ed;
            border: 1px solid #fed7aa;
            border-radius: var(--radius-sm);
            padding: 0.75rem 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-top: 0.5rem;
            font-size: 0.8rem;
            color: #c2410c;
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
            color: var(--red-dark);
            text-decoration: none;
        }

        .footer-logo i { color: var(--red); }
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
            <a href="inventory-import"><i class="fa-solid fa-arrow-down"></i> Nhập Kho</a>
            <a href="#" class="active"><i class="fa-solid fa-arrow-up"></i> Xuất Kho</a>
            <a href="#"><i class="fa-solid fa-basket-shopping"></i> Đơn Hàng</a>
            <a href="logout" class="logout" style="margin-top:0.5rem;"><i class="fa-solid fa-right-from-bracket"></i> Đăng Xuất</a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="main">

        <!-- Breadcrumb -->
        <div class="breadcrumb">
            <a href="products"><i class="fa-solid fa-box"></i> Sản Phẩm</a>
            <i class="fa-solid fa-chevron-right" style="font-size:0.6rem;color:var(--gray-400);"></i>
            <span>Xuất Kho</span>
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
            <span>Chức năng <strong>Xuất Kho</strong> cho phép bạn ghi nhận số lượng sản phẩm xuất bán hoặc hao hụt. Tồn kho sẽ được trừ tự động và ghi vào lịch sử giao dịch kho.</span>
        </div>

        <!-- Form -->
        <form action="inventory-export" method="POST" id="exportForm" onsubmit="return validateExport();">
            <!-- Chon san pham -->
            <div class="card">
                <div class="card-header">
                    <i class="fa-solid fa-boxes-packing" style="color:var(--red);font-size:1rem;"></i>
                    <div class="card-title">Chọn Sản Phẩm Xuất Kho</div>
                </div>
                <div class="card-body">
                    <div class="section-label">
                        <i class="fa-solid fa-asterisk" style="font-size:0.5rem;color:var(--red);"></i>
                        Thong tin san pham
                    </div>

                    <div class="form-group">
                        <label class="form-label">Sản phẩm <span class="required">*</span></label>
                        <select name="productId" id="productSelect" class="form-control" required onchange="onProductChange()">
                            <option value="">-- Chọn sản phẩm --</option>
                            <% for (Product p : products) { %>
                            <option value="<%= p.getId() %>"
                                    data-stock="<%= p.getStockQuantity() %>"
                                    data-unit="<%= p.getUnit() != null ? p.getUnit() : "" %>"
                                    data-title="<%= p.getTitle() != null ? p.getTitle() : "" %>"
                                    data-image="<%= p.getImage() != null ? p.getImage() : "" %>">
                                <%= p.getTitle() %> (Tồn kho: <%= p.getStockQuantity() %><%= p.getUnit() != null ? " " + p.getUnit() : "" %>)
                            </option>
                            <% } %>
                        </select>
                        <span class="form-hint">Chỉ hiển thị sản phẩm thuộc cửa hàng của bạn.</span>
                    </div>

                    <!-- Product summary -->
                    <div id="productSummary" class="product-summary" style="display:none;">
                        <img id="summaryImg" class="product-summary-img" src="" alt="product">
                        <div id="summaryImgPlaceholder" class="product-summary-img-placeholder" style="display:none;">
                            <i class="fa-solid fa-image"></i>
                        </div>
                        <div class="product-summary-info">
                            <div class="product-summary-name" id="summaryName"></div>
                            <div class="product-summary-meta">
                                <span>Đơn vị: <strong id="summaryUnit"></strong></span>
                                <span>Tồn kho hiện tại: <strong id="summaryStock"></strong></span>
                                <span id="summaryBadge"></span>
                            </div>
                        </div>
                    </div>

                    <!-- Stock preview -->
                    <div id="stockPreview" class="stock-preview" style="display:none;">
                        <i class="fa-solid fa-arrow-right-arrow-left"></i>
                        <div class="stock-preview-text" id="stockPreviewText"></div>
                    </div>

                    <!-- Stock error -->
                    <div id="stockError" class="stock-error" style="display:none;">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        <span id="stockErrorText"></span>
                    </div>
                </div>
            </div>

            <!-- Thong tin xuat kho -->
            <div class="card">
                <div class="card-header">
                    <i class="fa-solid fa-warehouse" style="color:var(--red);font-size:1rem;"></i>
                    <div class="card-title">Thông Tin Xuất Kho</div>
                </div>
                <div class="card-body">
                    <div class="section-label">
                        <i class="fa-solid fa-asterisk" style="font-size:0.5rem;color:var(--red);"></i>
                        So luong & ghi chu
                    </div>
                    <div class="form-grid">

                        <div class="form-group">
                            <label class="form-label">Số lượng xuất <span class="required">*</span></label>
                            <input type="number" name="quantity" id="quantityInput" class="form-control"
                                   placeholder="VD: 10" min="1" step="1" required oninput="updateStockPreview()">
                            <span class="form-hint">Số lượng phải lớn hơn 0 và không vượt quá tồn kho.</span>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Ghi chú</label>
                            <input type="text" name="note" id="noteInput" class="form-control"
                                   placeholder="VD: Bán cho khách hàng A">
                            <span class="form-hint">Không bắt buộc. Giúp bạn ghi nhận lý do xuất kho.</span>
                        </div>

                    </div>
                </div>
            </div>

            <!-- Actions -->
            <div class="form-actions">
                <a href="products" class="btn btn-outline">
                    <i class="fa-solid fa-arrow-left"></i> Quay Lại
                </a>
                <button type="submit" class="btn btn-red" id="btnSubmit">
                    <i class="fa-solid fa-floppy-disk"></i> Xác Nhận Xuất Kho
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
(function() {
    var productSelect  = document.getElementById('productSelect');
    var quantityInput  = document.getElementById('quantityInput');
    var productSummary = document.getElementById('productSummary');
    var summaryImg     = document.getElementById('summaryImg');
    var summaryImgPlaceholder = document.getElementById('summaryImgPlaceholder');
    var summaryName    = document.getElementById('summaryName');
    var summaryUnit    = document.getElementById('summaryUnit');
    var summaryStock   = document.getElementById('summaryStock');
    var summaryBadge   = document.getElementById('summaryBadge');
    var stockPreview   = document.getElementById('stockPreview');
    var stockPreviewText = document.getElementById('stockPreviewText');
    var stockError     = document.getElementById('stockError');
    var stockErrorText = document.getElementById('stockErrorText');
    var btnSubmit      = document.getElementById('btnSubmit');
    var exportForm     = document.getElementById('exportForm');

    window.onProductChange = function() {
        var selected = productSelect.options[productSelect.selectedIndex];
        var stock = parseInt(selected.getAttribute('data-stock') || '0');
        var unit  = selected.getAttribute('data-unit') || '';
        var title = selected.getAttribute('data-title') || '';
        var image = selected.getAttribute('data-image') || '';

        if (!title) {
            productSummary.style.display = 'none';
            stockPreview.style.display   = 'none';
            stockError.style.display     = 'none';
            return;
        }

        productSummary.style.display = 'flex';
        summaryName.textContent = title;
        summaryUnit.textContent = unit;
        summaryStock.textContent = stock + (unit ? ' ' + unit : '');

        if (stock <= 0) {
            summaryBadge.className = 'stock-badge zero';
            summaryBadge.innerHTML = '<i class="fa-solid fa-circle-exclamation"></i> Hết hàng';
        } else if (stock <= 20) {
            summaryBadge.className = 'stock-badge low';
            summaryBadge.innerHTML = '<i class="fa-solid fa-circle-exclamation"></i> Sắp hết';
        } else {
            summaryBadge.className = 'stock-badge ok';
            summaryBadge.innerHTML = '<i class="fa-solid fa-check-circle"></i> Còn hàng';
        }

        if (image) {
            summaryImg.style.display = 'block';
            summaryImg.src = image;
            summaryImg.onerror = function() {
                summaryImg.style.display = 'none';
                summaryImgPlaceholder.style.display = 'flex';
            };
            summaryImgPlaceholder.style.display = 'none';
        } else {
            summaryImg.style.display = 'none';
            summaryImgPlaceholder.style.display = 'flex';
        }

        updateStockPreview();
    };

    window.updateStockPreview = function() {
        var selected = productSelect.options[productSelect.selectedIndex];
        if (!selected || !selected.value) {
            stockPreview.style.display = 'none';
            stockError.style.display   = 'none';
            return;
        }

        var currentStock = parseInt(selected.getAttribute('data-stock') || '0');
        var qty = parseInt(quantityInput.value || '0');
        var unit = selected.getAttribute('data-unit') || '';

        stockError.style.display = 'none';

        if (qty > 0) {
            if (qty > currentStock) {
                stockPreview.style.display = 'none';
                stockError.style.display = 'flex';
                stockErrorText.textContent = 'Số lượng xuất (' + qty + ') vượt quá tồn kho hiện có (' + currentStock + '). Vui lòng nhập số nhỏ hơn.';
                btnSubmit.disabled = true;
            } else {
                var newStock = currentStock - qty;
                stockPreview.style.display = 'flex';
                stockPreviewText.innerHTML =
                    'Tồn kho hiện tại: <strong>' + currentStock + (unit ? ' ' + unit : '') + '</strong>'
                    + ' <span class="stock-arrow">→</span> '
                    + 'Sau khi xuất: <strong style="color:var(--red-dark);">' + newStock + (unit ? ' ' + unit : '') + '</strong>'
                    + ' <span style="color:var(--red);">(-' + qty + ')</span>';
                btnSubmit.disabled = false;
            }
        } else {
            stockPreview.style.display = 'none';
            btnSubmit.disabled = false;
        }
    };

    window.validateExport = function() {
        var selected = productSelect.options[productSelect.selectedIndex];
        var currentStock = parseInt(selected.getAttribute('data-stock') || '0');
        var qty = parseInt(quantityInput.value || '0');

        if (!selected || !selected.value) {
            alert('Vui lòng chọn sản phẩm.');
            return false;
        }
        if (qty <= 0) {
            alert('Số lượng xuất kho phải lớn hơn 0.');
            return false;
        }
        if (qty > currentStock) {
            alert('Số lượng xuất vượt quá tồn kho hiện có. Tồn kho hiện tại: ' + currentStock);
            return false;
        }

        btnSubmit.disabled = true;
        btnSubmit.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang xử lý...';
        return true;
    };
})();
</script>

</body>
</html>
