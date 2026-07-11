<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="model.Account, model.Category, model.Product, java.util.List" %>
        <%! public static String imgUrl(String path, String contextPath) { if (path==null || path.trim().isEmpty())
            return null; String trimmed=path.trim(); if (trimmed.startsWith("uploads/")) { try { return contextPath
            + "/image?path=" + java.net.URLEncoder.encode(trimmed, "UTF-8" ); } catch
            (java.io.UnsupportedEncodingException e) { return trimmed; } } return trimmed; } public static String
            formatPrice(double price) { return String.format("%,.0f₫", price); } %>
            <% Account user=(Account) session.getAttribute("user"); String avatarUrl=null; if (user !=null) {
                avatarUrl=user.getAvatar(); if (avatarUrl==null || avatarUrl.trim().isEmpty()) { String
                fn=user.getFullname() !=null ? user.getFullname() : user.getUsername();
                avatarUrl="https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(fn, "UTF-8" )
                + "&background=4caf50&color=fff&size=80&bold=true&rounded=true" ; } } List<Category> categories = (List
                <Category>) request.getAttribute("categories");
                    List<Product> products = (List<Product>) request.getAttribute("products");
                            Integer selectedCategoryId = (Integer) request.getAttribute("selectedCategoryId");
                            String selectedCategoryName = (String) request.getAttribute("selectedCategoryName");
                            String errorMsg = (String) request.getAttribute("error");
                            %>
                            <!DOCTYPE html>
                            <html lang="vi">

                            <head>
                                <meta charset="UTF-8">
                                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                <title>Danh Mục Sản Phẩm | Sena Shop</title>
                                <meta name="description"
                                    content="Khám phá tất cả danh mục sản phẩm tươi ngon tại Sena Shop – trái cây, rau củ, thực phẩm nhập khẩu và nhiều hơn nữa.">
                                <link
                                    href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
                                    rel="stylesheet">
                                <link rel="stylesheet"
                                    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
                                <style>
                                    *,
                                    *::before,
                                    *::after {
                                        box-sizing: border-box;
                                        margin: 0;
                                        padding: 0;
                                    }

                                    :root {
                                        --green: #4caf50;
                                        --green-dark: #388e3c;
                                        --green-light: #e8f5e9;
                                        --green-mid: #c8e6c9;
                                        --bg: #f0f4f1;
                                        --white: #ffffff;
                                        --gray-50: #f8fafb;
                                        --gray-100: #eef1ee;
                                        --gray-200: #dde5dd;
                                        --gray-400: #9aaa9a;
                                        --gray-600: #5a6a5a;
                                        --gray-800: #2d3d2d;
                                        --shadow-sm: 0 1px 3px rgba(0, 0, 0, .07);
                                        --shadow: 0 4px 16px rgba(0, 0, 0, .09);
                                        --shadow-lg: 0 8px 32px rgba(0, 0, 0, .12);
                                        --radius: 16px;
                                        --radius-sm: 10px;
                                        --transition: 0.2s ease;
                                    }

                                    html,
                                    body {
                                        min-height: 100vh;
                                        font-family: 'Inter', sans-serif;
                                        color: var(--gray-800);
                                        background: var(--bg);
                                    }

                                    /* ===== TOPNAV ===== */
                                    .topnav {
                                        background: var(--white);
                                        border-bottom: 1px solid var(--gray-200);
                                        height: 62px;
                                        display: flex;
                                        align-items: center;
                                        padding: 0 2rem;
                                        gap: 1.5rem;
                                        position: sticky;
                                        top: 0;
                                        z-index: 100;
                                        box-shadow: var(--shadow-sm);
                                    }

                                    .nav-logo {
                                        display: flex;
                                        align-items: center;
                                        gap: 0.5rem;
                                        font-size: 1.25rem;
                                        font-weight: 800;
                                        color: var(--green-dark);
                                        text-decoration: none;
                                        white-space: nowrap;
                                    }

                                    .nav-logo i {
                                        color: var(--green);
                                    }

                                    .nav-links {
                                        display: flex;
                                        gap: 0.25rem;
                                    }

                                    .nav-links a {
                                        padding: 0.4rem 0.85rem;
                                        border-radius: 6px;
                                        font-size: 0.875rem;
                                        font-weight: 500;
                                        color: var(--gray-600);
                                        text-decoration: none;
                                        transition: all var(--transition);
                                    }

                                    .nav-links a:hover {
                                        background: var(--green-light);
                                        color: var(--green-dark);
                                    }

                                    .nav-links a.active {
                                        background: var(--green-light);
                                        color: var(--green-dark);
                                        font-weight: 700;
                                    }

                                    .nav-right {
                                        margin-left: auto;
                                        display: flex;
                                        align-items: center;
                                        gap: 0.75rem;
                                    }

                                    .nav-avatar {
                                        width: 36px;
                                        height: 36px;
                                        border-radius: 50%;
                                        object-fit: cover;
                                        border: 2px solid var(--green);
                                    }

                                    .nav-icon-btn {
                                        background: none;
                                        border: none;
                                        width: 38px;
                                        height: 38px;
                                        border-radius: 50%;
                                        cursor: pointer;
                                        color: var(--gray-600);
                                        display: flex;
                                        align-items: center;
                                        justify-content: center;
                                        font-size: 1.1rem;
                                        transition: all var(--transition);
                                        text-decoration: none;
                                    }

                                    .nav-icon-btn:hover {
                                        background: var(--green-light);
                                        color: var(--green-dark);
                                    }

                                    /* ===== HERO BANNER ===== */
                                    .hero {
                                        background: linear-gradient(135deg, #1b5e20 0%, #2e7d32 40%, #43a047 100%);
                                        color: var(--white);
                                        padding: 3.5rem 2rem 3rem;
                                        text-align: center;
                                        position: relative;
                                        overflow: hidden;
                                    }

                                    .hero::before {
                                        content: '';
                                        position: absolute;
                                        inset: 0;
                                        background: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.04'%3E%3Ccircle cx='30' cy='30' r='20'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
                                        pointer-events: none;
                                    }

                                    .hero-title {
                                        font-size: 2.4rem;
                                        font-weight: 800;
                                        letter-spacing: -0.02em;
                                        margin-bottom: 0.5rem;
                                        position: relative;
                                    }

                                    .hero-subtitle {
                                        font-size: 1rem;
                                        opacity: 0.85;
                                        position: relative;
                                    }

                                    .hero-badge {
                                        display: inline-flex;
                                        align-items: center;
                                        gap: 0.4rem;
                                        background: rgba(255, 255, 255, 0.15);
                                        backdrop-filter: blur(8px);
                                        border: 1px solid rgba(255, 255, 255, 0.25);
                                        padding: 0.35rem 1rem;
                                        border-radius: 100px;
                                        font-size: 0.82rem;
                                        font-weight: 600;
                                        margin-bottom: 1rem;
                                        position: relative;
                                    }

                                    /* ===== LAYOUT ===== */
                                    .layout {
                                        max-width: 1300px;
                                        margin: 0 auto;
                                        padding: 2rem 1.5rem;
                                    }

                                    /* ===== CATEGORY GRID ===== */
                                    .section-title {
                                        font-size: 1.2rem;
                                        font-weight: 800;
                                        color: var(--gray-800);
                                        margin-bottom: 1.25rem;
                                        display: flex;
                                        align-items: center;
                                        gap: 0.5rem;
                                    }

                                    .section-title i {
                                        color: var(--green);
                                    }

                                    .category-grid {
                                        display: grid;
                                        grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
                                        gap: 1rem;
                                        margin-bottom: 2.5rem;
                                    }

                                    .cat-card {
                                        background: var(--white);
                                        border: 2px solid transparent;
                                        border-radius: var(--radius);
                                        padding: 1.4rem 1rem 1.1rem;
                                        text-align: center;
                                        cursor: pointer;
                                        text-decoration: none;
                                        color: var(--gray-800);
                                        transition: all var(--transition);
                                        box-shadow: var(--shadow-sm);
                                        display: block;
                                        position: relative;
                                        overflow: hidden;
                                    }

                                    .cat-card::before {
                                        content: '';
                                        position: absolute;
                                        inset: 0;
                                        background: linear-gradient(135deg, var(--green-light), transparent);
                                        opacity: 0;
                                        transition: opacity var(--transition);
                                    }

                                    .cat-card:hover {
                                        border-color: var(--green);
                                        box-shadow: var(--shadow);
                                        transform: translateY(-3px);
                                    }

                                    .cat-card:hover::before {
                                        opacity: 1;
                                    }

                                    .cat-card.active {
                                        border-color: var(--green);
                                        background: var(--green-light);
                                        box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.2), var(--shadow);
                                        transform: translateY(-3px);
                                    }

                                    .cat-card.active .cat-name {
                                        color: var(--green-dark);
                                        font-weight: 700;
                                    }

                                    .cat-img-wrap {
                                        width: 64px;
                                        height: 64px;
                                        border-radius: 50%;
                                        margin: 0 auto 0.65rem;
                                        overflow: hidden;
                                        background: var(--green-light);
                                        display: flex;
                                        align-items: center;
                                        justify-content: center;
                                        border: 2px solid var(--green-mid);
                                        transition: transform var(--transition);
                                    }

                                    .cat-card:hover .cat-img-wrap,
                                    .cat-card.active .cat-img-wrap {
                                        transform: scale(1.08);
                                    }

                                    .cat-img-wrap img {
                                        width: 100%;
                                        height: 100%;
                                        object-fit: cover;
                                    }

                                    .cat-img-wrap i {
                                        font-size: 1.8rem;
                                        color: var(--green);
                                    }

                                    .cat-name {
                                        font-size: 0.85rem;
                                        font-weight: 600;
                                        line-height: 1.3;
                                        position: relative;
                                    }

                                    .cat-check {
                                        position: absolute;
                                        top: 8px;
                                        right: 8px;
                                        background: var(--green);
                                        color: white;
                                        border-radius: 50%;
                                        width: 20px;
                                        height: 20px;
                                        display: none;
                                        align-items: center;
                                        justify-content: center;
                                        font-size: 0.65rem;
                                    }

                                    .cat-card.active .cat-check {
                                        display: flex;
                                    }

                                    /* ===== FILTER BAR ===== */
                                    .filter-bar {
                                        background: var(--white);
                                        border-radius: var(--radius);
                                        border: 1px solid var(--gray-200);
                                        padding: 1rem 1.25rem;
                                        display: flex;
                                        align-items: center;
                                        gap: 1rem;
                                        margin-bottom: 1.5rem;
                                        box-shadow: var(--shadow-sm);
                                        flex-wrap: wrap;
                                    }

                                    .filter-label {
                                        font-size: 0.875rem;
                                        font-weight: 600;
                                        color: var(--gray-600);
                                        white-space: nowrap;
                                    }

                                    .filter-selected {
                                        display: flex;
                                        align-items: center;
                                        gap: 0.5rem;
                                        background: var(--green-light);
                                        border: 1.5px solid var(--green-mid);
                                        border-radius: 100px;
                                        padding: 0.35rem 0.9rem;
                                        font-size: 0.82rem;
                                        font-weight: 700;
                                        color: var(--green-dark);
                                    }

                                    .filter-clear {
                                        margin-left: auto;
                                        display: inline-flex;
                                        align-items: center;
                                        gap: 0.35rem;
                                        padding: 0.4rem 1rem;
                                        border-radius: 100px;
                                        background: #fee2e2;
                                        color: #dc2626;
                                        font-size: 0.8rem;
                                        font-weight: 600;
                                        border: none;
                                        cursor: pointer;
                                        text-decoration: none;
                                        transition: all var(--transition);
                                    }

                                    .filter-clear:hover {
                                        background: #fecaca;
                                    }

                                    /* ===== PRODUCT GRID ===== */
                                    .products-header {
                                        display: flex;
                                        justify-content: space-between;
                                        align-items: center;
                                        margin-bottom: 1.25rem;
                                        flex-wrap: wrap;
                                        gap: 0.5rem;
                                    }

                                    .product-count {
                                        font-size: 0.875rem;
                                        color: var(--gray-600);
                                    }

                                    .product-count strong {
                                        color: var(--green-dark);
                                        font-weight: 700;
                                    }

                                    .product-grid {
                                        display: grid;
                                        grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
                                        gap: 1.25rem;
                                    }

                                    .prod-card {
                                        background: var(--white);
                                        border-radius: var(--radius);
                                        box-shadow: var(--shadow-sm);
                                        border: 1px solid var(--gray-200);
                                        overflow: hidden;
                                        transition: all var(--transition);
                                        display: flex;
                                        flex-direction: column;
                                        text-decoration: none;
                                        color: inherit;
                                    }

                                    .prod-card:hover {
                                        box-shadow: var(--shadow-lg);
                                        transform: translateY(-4px);
                                        border-color: var(--green-mid);
                                    }

                                    .prod-img-wrap {
                                        position: relative;
                                        aspect-ratio: 1/1;
                                        overflow: hidden;
                                        background: var(--gray-50);
                                    }

                                    .prod-img-wrap img {
                                        width: 100%;
                                        height: 100%;
                                        object-fit: cover;
                                        transition: transform 0.3s ease;
                                    }

                                    .prod-card:hover .prod-img-wrap img {
                                        transform: scale(1.06);
                                    }

                                    .prod-placeholder {
                                        width: 100%;
                                        height: 100%;
                                        display: flex;
                                        align-items: center;
                                        justify-content: center;
                                        font-size: 3rem;
                                        color: var(--gray-200);
                                    }

                                    .prod-badge {
                                        position: absolute;
                                        top: 10px;
                                        left: 10px;
                                        background: #ef4444;
                                        color: white;
                                        font-size: 0.72rem;
                                        font-weight: 700;
                                        padding: 0.2rem 0.55rem;
                                        border-radius: 100px;
                                    }

                                    .prod-badge.in-stock {
                                        background: var(--green);
                                    }

                                    .prod-body {
                                        padding: 0.9rem;
                                        flex: 1;
                                        display: flex;
                                        flex-direction: column;
                                        gap: 0.35rem;
                                    }

                                    .prod-title {
                                        font-size: 0.9rem;
                                        font-weight: 700;
                                        line-height: 1.4;
                                        color: var(--gray-800);
                                        display: -webkit-box;
                                        -webkit-line-clamp: 2;
                                        -webkit-box-orient: vertical;
                                        overflow: hidden;
                                    }

                                    .prod-shop {
                                        font-size: 0.75rem;
                                        color: var(--gray-400);
                                    }

                                    .prod-price-row {
                                        display: flex;
                                        align-items: center;
                                        gap: 0.5rem;
                                        margin-top: auto;
                                        padding-top: 0.5rem;
                                    }

                                    .prod-sale-price {
                                        font-size: 1.05rem;
                                        font-weight: 800;
                                        color: var(--green-dark);
                                    }

                                    .prod-orig-price {
                                        font-size: 0.78rem;
                                        color: var(--gray-400);
                                        text-decoration: line-through;
                                    }

                                    .prod-unit {
                                        font-size: 0.72rem;
                                        color: var(--gray-400);
                                        margin-left: auto;
                                    }

                                    .prod-rating {
                                        display: flex;
                                        align-items: center;
                                        gap: 0.25rem;
                                        font-size: 0.75rem;
                                        color: #f59e0b;
                                    }

                                    .prod-rating span {
                                        color: var(--gray-500);
                                    }

                                    .prod-footer {
                                        padding: 0 0.9rem 0.9rem;
                                    }

                                    .btn-add-cart {
                                        width: 100%;
                                        padding: 0.6rem;
                                        background: var(--green);
                                        color: white;
                                        border: none;
                                        border-radius: var(--radius-sm);
                                        font-size: 0.82rem;
                                        font-weight: 700;
                                        cursor: pointer;
                                        transition: background var(--transition);
                                        display: flex;
                                        align-items: center;
                                        justify-content: center;
                                        gap: 0.4rem;
                                        text-decoration: none;
                                    }

                                    .btn-add-cart:hover {
                                        background: var(--green-dark);
                                    }

                                    /* ===== EMPTY STATE ===== */
                                    .empty-state {
                                        text-align: center;
                                        padding: 4rem 2rem;
                                        color: var(--gray-400);
                                        background: var(--white);
                                        border-radius: var(--radius);
                                        border: 1px solid var(--gray-200);
                                    }

                                    .empty-state .icon {
                                        font-size: 3.5rem;
                                        margin-bottom: 1rem;
                                        color: var(--gray-200);
                                    }

                                    .empty-state h3 {
                                        font-size: 1.1rem;
                                        color: var(--gray-600);
                                        margin-bottom: 0.5rem;
                                    }

                                    .empty-state p {
                                        font-size: 0.875rem;
                                    }

                                    /* ===== PLACEHOLDER PROMPT ===== */
                                    .pick-prompt {
                                        text-align: center;
                                        padding: 3rem 2rem;
                                        color: var(--gray-400);
                                    }

                                    .pick-prompt i {
                                        font-size: 3rem;
                                        margin-bottom: 0.75rem;
                                        display: block;
                                        color: var(--green-mid);
                                    }

                                    .pick-prompt p {
                                        font-size: 0.95rem;
                                        font-weight: 500;
                                    }

                                    /* ===== RESPONSIVE ===== */
                                    @media (max-width: 768px) {
                                        .hero-title {
                                            font-size: 1.7rem;
                                        }

                                        .category-grid {
                                            grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
                                        }

                                        .product-grid {
                                            grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
                                        }
                                    }
                                </style>
                            </head>

                            <body>

                                <!-- ===== TOPNAV ===== -->
                                <nav class="topnav">
                                    <a href="home.jsp" class="nav-logo">
                                        <i class="fa-solid fa-apple-whole"></i> Sena Shop
                                    </a>
                                    <div class="nav-links">
                                        <a href="home.jsp">Trang Chủ</a>
                                        <a href="<%= request.getContextPath() %>/danh-muc" class="active">Danh Mục</a>
                                        <a href="products">Sản Phẩm</a>
                                    </div>
                                    <div class="nav-right">
                                        <a href="view-cart" class="nav-icon-btn" title="Giỏ hàng">
                                            <i class="fa-solid fa-basket-shopping"></i>
                                        </a>
                                        <% if (user !=null) { %>
                                            <a href="<%= request.getContextPath() %>/profile">
                                                <img class="nav-avatar" src="<%= avatarUrl %>" alt="avatar">
                                            </a>
                                            <% } else { %>
                                                <a href="<%= request.getContextPath() %>/login" class="nav-icon-btn"
                                                    title="Đăng nhập">
                                                    <i class="fa-solid fa-right-to-bracket"></i>
                                                </a>
                                                <% } %>
                                    </div>
                                </nav>

                                <!-- ===== HERO ===== -->
                                <div class="hero">
                                    <div class="hero-badge"><i class="fa-solid fa-tags"></i> Khám phá danh mục</div>
                                    <h1 class="hero-title">Danh Mục Sản Phẩm</h1>
                                    <p class="hero-subtitle">Chọn danh mục để xem các sản phẩm tươi ngon phù hợp với bạn
                                    </p>
                                </div>

                                <!-- ===== MAIN LAYOUT ===== -->
                                <div class="layout">

                                    <% if (errorMsg !=null) { %>
                                        <div
                                            style="background:#fee2e2;border:1px solid #fecaca;color:#991b1b;padding:0.9rem 1.2rem;border-radius:10px;margin-bottom:1.25rem;font-size:0.875rem;">
                                            <i class="fa-solid fa-circle-exclamation"></i>
                                            <%= errorMsg %>
                                        </div>
                                        <% } %>

                                            <!-- CATEGORIES SECTION -->
                                            <h2 class="section-title">
                                                <i class="fa-solid fa-layer-group"></i> Tất Cả Danh Mục
                                            </h2>

                                            <% if (categories==null || categories.isEmpty()) { %>
                                                <div class="empty-state" style="margin-bottom:2rem;">
                                                    <div class="icon"><i class="fa-solid fa-folder-open"></i></div>
                                                    <h3>Chưa có danh mục nào</h3>
                                                    <p>Hãy quay lại sau nhé!</p>
                                                </div>
                                                <% } else { %>
                                                    <div class="category-grid">
                                                        <% for (Category cat : categories) { %>
                                                            <% boolean isSelected=selectedCategoryId !=null &&
                                                                selectedCategoryId==cat.getId(); String catImgUrl=null;
                                                                if (cat.getImage() !=null &&
                                                                !cat.getImage().trim().isEmpty()) {
                                                                catImgUrl=imgUrl(cat.getImage(),
                                                                request.getContextPath()); } %>
                                                                <a href="<%= request.getContextPath() %>/danh-muc?categoryId=<%= cat.getId() %>"
                                                                    class="cat-card <%= isSelected ? " active" : "" %>">
                                                                    <div class="cat-check"><i
                                                                            class="fa-solid fa-check"></i></div>
                                                                    <div class="cat-img-wrap">
                                                                        <% if (catImgUrl !=null) { %>
                                                                            <img src="<%= catImgUrl %>"
                                                                                alt="<%= cat.getName() %>"
                                                                                onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                                                                            <i class="fa-solid fa-leaf"
                                                                                style="display:none;"></i>
                                                                            <% } else { %>
                                                                                <i class="fa-solid fa-leaf"></i>
                                                                                <% } %>
                                                                    </div>
                                                                    <div class="cat-name">
                                                                        <%= cat.getName() %>
                                                                    </div>
                                                                </a>
                                                                <% } %>
                                                    </div>
                                                    <% } %>

                                                        <!-- PRODUCTS SECTION -->
                                                        <% if (selectedCategoryId !=null) { %>
                                                            <!-- Filter bar -->
                                                            <div class="filter-bar">
                                                                <span class="filter-label"><i
                                                                        class="fa-solid fa-filter"></i> Lọc theo:</span>
                                                                <span class="filter-selected">
                                                                    <i class="fa-solid fa-tag"></i>
                                                                    <%= selectedCategoryName !=null ?
                                                                        selectedCategoryName : "Danh mục #" +
                                                                        selectedCategoryId %>
                                                                </span>
                                                                <a href="<%= request.getContextPath() %>/danh-muc"
                                                                    class="filter-clear">
                                                                    <i class="fa-solid fa-xmark"></i> Xóa lọc
                                                                </a>
                                                            </div>

                                                            <!-- Products header -->
                                                            <div class="products-header">
                                                                <h2 class="section-title" style="margin-bottom:0;">
                                                                    <i class="fa-solid fa-box-open"></i>
                                                                    Sản phẩm: <%= selectedCategoryName !=null ?
                                                                        selectedCategoryName : "" %>
                                                                </h2>
                                                                <% if (products !=null) { %>
                                                                    <div class="product-count">
                                                                        <strong>
                                                                            <%= products.size() %>
                                                                        </strong> sản phẩm tìm thấy
                                                                    </div>
                                                                    <% } %>
                                                            </div>

                                                            <!-- Products grid -->
                                                            <% if (products==null || products.isEmpty()) { %>
                                                                <div class="empty-state">
                                                                    <div class="icon"><i
                                                                            class="fa-solid fa-box-open"></i></div>
                                                                    <h3>Chưa có sản phẩm nào trong danh mục này</h3>
                                                                    <p>Hãy chọn danh mục khác hoặc quay lại sau!</p>
                                                                </div>
                                                                <% } else { %>
                                                                    <div class="product-grid">
                                                                        <% for (Product p : products) { String
                                                                            pImgUrl=imgUrl(p.getImage(),
                                                                            request.getContextPath()); double
                                                                            discount=p.getDiscountPercent(); boolean
                                                                            inStock=p.isInStock(); %>
                                                                            <a href="<%= request.getContextPath() %>/product-info?id=<%= p.getId() %>"
                                                                                class="prod-card">
                                                                                <div class="prod-img-wrap">
                                                                                    <% if (pImgUrl !=null) { %>
                                                                                        <img src="<%= pImgUrl %>"
                                                                                            alt="<%= p.getTitle() %>"
                                                                                            onerror="this.style.display='none';this.parentElement.querySelector('.prod-placeholder').style.display='flex'">
                                                                                        <div class="prod-placeholder"
                                                                                            style="display:none;">
                                                                                            <i
                                                                                                class="fa-solid fa-image"></i>
                                                                                        </div>
                                                                                        <% } else { %>
                                                                                            <div
                                                                                                class="prod-placeholder">
                                                                                                <i
                                                                                                    class="fa-solid fa-image"></i>
                                                                                            </div>
                                                                                            <% } %>
                                                                                                <% if (discount> 0) { %>
                                                                                                    <span
                                                                                                        class="prod-badge">-
                                                                                                        <%= (int)
                                                                                                            discount %>
                                                                                                            %</span>
                                                                                                    <% } else if
                                                                                                        (inStock) { %>
                                                                                                        <span
                                                                                                            class="prod-badge in-stock">Còn
                                                                                                            hàng</span>
                                                                                                        <% } %>
                                                                                </div>
                                                                                <div class="prod-body">
                                                                                    <div class="prod-title">
                                                                                        <%= p.getTitle() %>
                                                                                    </div>
                                                                                    <% if (p.getShopName() !=null) { %>
                                                                                        <div class="prod-shop"><i
                                                                                                class="fa-solid fa-store"
                                                                                                style="font-size:0.7rem;"></i>
                                                                                            <%= p.getShopName() %>
                                                                                        </div>
                                                                                        <% } %>
                                                                                            <% if (p.getAverageRating()>
                                                                                                0) { %>
                                                                                                <div
                                                                                                    class="prod-rating">
                                                                                                    <i
                                                                                                        class="fa-solid fa-star"></i>
                                                                                                    <%= String.format("%.1f",
                                                                                                        p.getAverageRating())
                                                                                                        %>
                                                                                                        <span>(<%=
                                                                                                                p.getSoldQuantity()
                                                                                                                %> đã
                                                                                                                bán)</span>
                                                                                                </div>
                                                                                                <% } %>
                                                                                                    <div
                                                                                                        class="prod-price-row">
                                                                                                        <span
                                                                                                            class="prod-sale-price">
                                                                                                            <%= formatPrice(p.getSalePrice())
                                                                                                                %>
                                                                                                        </span>
                                                                                                        <% if
                                                                                                            (p.getOriginalPrice()>
                                                                                                            p.getSalePrice())
                                                                                                            { %>
                                                                                                            <span
                                                                                                                class="prod-orig-price">
                                                                                                                <%= formatPrice(p.getOriginalPrice())
                                                                                                                    %>
                                                                                                            </span>
                                                                                                            <% } %>
                                                                                                                <span
                                                                                                                    class="prod-unit">/
                                                                                                                    <%= p.getUnit()
                                                                                                                        !=null
                                                                                                                        ?
                                                                                                                        p.getUnit()
                                                                                                                        : "cái"
                                                                                                                        %>
                                                                                                                        </span>
                                                                                                    </div>
                                                                                </div>
                                                                                <div class="prod-footer">
                                                                                    <% if (inStock) { %>
                                                                                        <span class="btn-add-cart"
                                                                                            onclick="event.preventDefault(); addToCart(<%= p.getId() %>)">
                                                                                            <i
                                                                                                class="fa-solid fa-cart-plus"></i>
                                                                                            Thêm vào giỏ
                                                                                        </span>
                                                                                        <% } else { %>
                                                                                            <span class="btn-add-cart"
                                                                                                style="background:var(--gray-400);cursor:not-allowed;">
                                                                                                <i
                                                                                                    class="fa-solid fa-ban"></i>
                                                                                                Hết hàng
                                                                                            </span>
                                                                                            <% } %>
                                                                                </div>
                                                                            </a>
                                                                            <% } %>
                                                                    </div>
                                                                    <% } %>

                                                                        <% } else { %>
                                                                            <!-- Prompt user to pick a category -->
                                                                            <div class="pick-prompt">
                                                                                <i class="fa-solid fa-hand-pointer"></i>
                                                                                <p>Hãy chọn một danh mục bên trên để xem
                                                                                    sản phẩm!</p>
                                                                            </div>
                                                                            <% } %>

                                </div><!-- /layout -->

                                <script>
                                    function addToCart(productId) {
                                        fetch('<%= request.getContextPath() %>/add-to-cart', {
                                            method: 'POST',
                                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                                            body: 'productId=' + productId + '&quantity=1'
                                        })
                                            .then(r => {
                                                if (r.ok || r.redirected) {
                                                    showToast('Đã thêm vào giỏ hàng! 🛒');
                                                } else {
                                                    showToast('Vui lòng đăng nhập để thêm vào giỏ!', true);
                                                }
                                            })
                                            .catch(() => {
                                                window.location.href = '<%= request.getContextPath() %>/add-to-cart?productId=' + productId + '&quantity=1';
                                            });
                                    }

                                    function showToast(msg, isError = false) {
                                        const t = document.createElement('div');
                                        t.textContent = msg;
                                        Object.assign(t.style, {
                                            position: 'fixed', bottom: '2rem', left: '50%', transform: 'translateX(-50%)',
                                            background: isError ? '#ef4444' : '#2e7d32',
                                            color: 'white', padding: '0.75rem 1.5rem',
                                            borderRadius: '100px', fontWeight: '600', fontSize: '0.875rem',
                                            boxShadow: '0 4px 20px rgba(0,0,0,0.15)', zIndex: '9999',
                                            opacity: '0', transition: 'opacity 0.3s ease'
                                        });
                                        document.body.appendChild(t);
                                        requestAnimationFrame(() => t.style.opacity = '1');
                                        setTimeout(() => { t.style.opacity = '0'; setTimeout(() => t.remove(), 300); }, 2500);
                                    }
                                </script>

                            </body>

                            </html>