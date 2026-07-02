<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Product" %>
<%@ page import="model.Shop" %>
<%@ page import="model.Wishlist" %>
<%@ page import="Utils.ImageUrlUtil" %>
<%@ page import="model.Cart" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="dao.ShopDAO" %>
<%@ page import="service.WishlistService" %>
<%@ page import="service.CartService" %>
<%@ page import="java.util.List" %>
<%
    // ---- Auth guard ----
    Account Account = (Account) session.getAttribute("Account");
    if (Account == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    // ---- Product ----
    Product product = (Product) request.getAttribute("product");
    if (product == null) {
        session.setAttribute("error", "San pham khong ton tai hoac da bi xoa.");
        response.sendRedirect(request.getContextPath() + "/products");
        return;
    }

    // ---- Current session info ----
    String role = (String) session.getAttribute("role");
    Integer sessionShopIdObj = (Integer) session.getAttribute("shopId");
    int sessionShopId = (sessionShopIdObj != null) ? sessionShopIdObj : 0;

    // ---- Is owner of this product's shop? ----
    boolean isOwner = false;
    if ("seller".equals(role) && sessionShopId > 0 && sessionShopId == product.getShopId()) {
        isOwner = true;
    }

    // ---- Check if product is in wishlist ----
    boolean inWishlist = false;
    int wishlistCount = 0;
    WishlistService wishlistService = null;
    try {
        wishlistService = new WishlistService();
        inWishlist = wishlistService.isInWishlist(Account.getId(), product.getId());
        wishlistCount = wishlistService.getWishlistCount(Account.getId());
        if (session.getAttribute("wishlistCount") != null) {
            wishlistCount = (Integer) session.getAttribute("wishlistCount");
        }
    } catch (Exception e) {
        System.err.println("[product-detail.jsp] wishlist error: " + e.getMessage());
        inWishlist = false;
    } finally {
        if (wishlistService != null) wishlistService.close();
    }

    // ---- Cart count ----
    int cartCount = 0;
    CartService cartService = null;
    try {
        cartService = new CartService();
        Cart cart = cartService.getCartByCustomerId(Account.getId());
        if (cart != null) cartCount = cart.getTotalQuantity();
        if (session.getAttribute("cartCount") != null) {
            cartCount = (Integer) session.getAttribute("cartCount");
        }
    } catch (Exception ignored) {}
    finally {
        if (cartService != null) cartService.close();
    }

    // ---- Category name ----
    String categoryName = (String) request.getAttribute("categoryName");
    if (categoryName == null || categoryName.trim().isEmpty()) {
        categoryName = "-";
    }

    // ---- Shop info ----
    Shop shopInfo = (Shop) request.getAttribute("shopInfo");
    if (shopInfo == null) {
        shopInfo = new Shop();
        shopInfo.setShopName(product.getShopName() != null ? product.getShopName() : "-");
    }

    // ---- Avatar ----
    String avatarUrl = Account.getAvatar();
    if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
        String fullname = Account.getFullname() != null ? Account.getFullname() : Account.getUsername();
        avatarUrl = "https://ui-avatars.com/api/?name="
                  + java.net.URLEncoder.encode(fullname, "UTF-8")
                  + "&background=4caf50&color=fff&size=80&bold=true&rounded=true";
    }

    // ---- Flash messages ----
    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");

    // ---- Price helpers ----
    double originalPrice = product.getOriginalPrice();
    double salePrice = product.getSalePrice();
    boolean hasDiscount = salePrice > 0 && salePrice < originalPrice;
    int discountPercent = (int) Math.round(product.getDiscountPercent());
    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(java.util.Locale.forLanguageTag("vi"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= product.getTitle() %> | Sena Shop</title>
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

        /* TOPNAV */
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
            position: relative;
            width: 38px; height: 38px;
            border-radius: 50%;
            background: var(--gray-100);
            border: none;
            display: flex; align-items: center; justify-content: center;
            color: var(--gray-600);
            cursor: pointer;
            font-size: 0.95rem;
            transition: background 0.15s;
            text-decoration: none;
        }

        .nav-icon-btn:hover { background: var(--green-light); color: var(--green-dark); }

        .nav-icon-btn .badge {
            position: absolute;
            top: -4px;
            right: -4px;
            min-width: 18px;
            height: 18px;
            background: #ef4444;
            color: #fff;
            font-size: 0.65rem;
            font-weight: 700;
            border-radius: 999px;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 0 4px;
        }

        .cart-badge {
            position: absolute;
            top: -4px;
            right: -4px;
            min-width: 18px;
            height: 18px;
            background: var(--orange);
            color: #fff;
            font-size: 0.62rem;
            font-weight: 700;
            border-radius: 999px;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 0 4px;
        }

        .wishlist-badge {
            position: absolute;
            top: -4px;
            right: -4px;
            min-width: 18px;
            height: 18px;
            background: #ef4444;
            color: #fff;
            font-size: 0.62rem;
            font-weight: 700;
            border-radius: 999px;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 0 4px;
        }

        .nav-avatar {
            width: 38px; height: 38px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--green);
            cursor: pointer;
        }

        /* LAYOUT */
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

        /* SIDEBAR */
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

        /* MAIN */
        .main { flex: 1; display: flex; flex-direction: column; gap: 1.25rem; min-width: 0; }

        /* ALERTS */
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

        /* CARD */
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

        /* BREADCRUMB */
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

        /* DETAIL GRID */
        .detail-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
        }

        /* Product image */
        .product-image-wrap {
            border-radius: var(--radius);
            overflow: hidden;
            background: var(--gray-50);
            border: 1.5px solid var(--gray-200);
            aspect-ratio: 1 / 1;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .product-image-wrap img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .product-image-placeholder {
            font-size: 4rem;
            text-align: center;
        }

        /* Info panel */
        .info-panel { display: flex; flex-direction: column; gap: 1.25rem; }

        .product-title {
            font-size: 1.35rem;
            font-weight: 800;
            color: var(--gray-800);
            line-height: 1.3;
        }

        /* Price block */
        .price-block {
            background: var(--green-light);
            border: 1px solid var(--green-mid);
            border-radius: var(--radius-sm);
            padding: 1rem 1.25rem;
            display: flex;
            align-items: baseline;
            gap: 1rem;
        }

        .price-sale {
            font-size: 1.6rem;
            font-weight: 800;
            color: #dc2626;
        }

        .price-original {
            font-size: 1rem;
            color: var(--gray-400);
            text-decoration: line-through;
        }

        .price-discount {
            background: #dc2626;
            color: #fff;
            font-size: 0.72rem;
            font-weight: 700;
            padding: 0.2rem 0.5rem;
            border-radius: 4px;
        }

        /* Meta list */
        .meta-list {
            display: flex;
            flex-direction: column;
            gap: 0.65rem;
        }

        .meta-item {
            display: flex;
            align-items: flex-start;
            gap: 0.65rem;
            font-size: 0.875rem;
        }

        .meta-item i {
            color: var(--green);
            margin-top: 0.1rem;
            width: 14px;
            text-align: center;
            flex-shrink: 0;
        }

        .meta-label { color: var(--gray-400); font-weight: 500; min-width: 100px; }
        .meta-value { color: var(--gray-800); font-weight: 500; }

        /* Badges */
        .badge {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            padding: 0.2rem 0.6rem;
            border-radius: 100px;
            font-size: 0.72rem;
            font-weight: 700;
            white-space: nowrap;
        }

        .badge-green  { background: #dcfce7; color: #166534; }
        .badge-yellow { background: #fef9c3; color: #854d0e; }
        .badge-red    { background: #fee2e2; color: #991b1b; }
        .badge-gray   { background: var(--gray-100); color: var(--gray-600); }

        /* Rating stars */
        .rating-stars { color: #f59e0b; font-size: 0.875rem; }
        .rating-stars .empty { color: var(--gray-200); }

        /* Section label */
        .section-label {
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: var(--gray-400);
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            gap: 0.4rem;
        }

        /* Shop card */
        .shop-card {
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-sm);
            padding: 1rem 1.25rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .shop-avatar {
            width: 44px; height: 44px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--green);
            flex-shrink: 0;
        }

        .shop-avatar-placeholder {
            width: 44px; height: 44px;
            border-radius: 50%;
            background: linear-gradient(135deg, #e8f5e9, #c8e6c9);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            flex-shrink: 0;
        }

        .shop-info { display: flex; flex-direction: column; gap: 0.2rem; }
        .shop-name { font-size: 0.9rem; font-weight: 700; color: var(--gray-800); }
        .shop-meta { font-size: 0.78rem; color: var(--gray-400); }

        /* Action buttons */
        .action-buttons {
            display: flex;
            gap: 0.75rem;
            flex-wrap: wrap;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.45rem;
            padding: 0.75rem 1.5rem;
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

        /* Wishlist button styles */
        .btn-wishlist {
            background: var(--white);
            color: var(--gray-600);
            border: 1.5px solid var(--gray-200);
            padding: 0.75rem 1.2rem;
        }

        .btn-wishlist:hover {
            background: #fff5f5;
            border-color: #ef4444;
            color: #ef4444;
        }

        .btn-wishlist.in-wishlist {
            background: #fff5f5;
            border-color: #ef4444;
            color: #ef4444;
        }

        .btn-wishlist.in-wishlist i {
            color: #ef4444;
        }

        /* Size selector */
        .size-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 44px;
            height: 44px;
            border: 2px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--gray-600);
            transition: all 0.15s;
        }

        .size-option input:checked + .size-btn {
            border-color: var(--green);
            background: var(--green-light);
            color: var(--green-dark);
        }

        .size-option:hover .size-btn {
            border-color: var(--green);
            color: var(--green-dark);
        }

        /* Toast notification */
        .toast {
            position: fixed;
            top: 80px;
            right: 20px;
            background: var(--green);
            color: #fff;
            padding: 0.85rem 1.25rem;
            border-radius: var(--radius-sm);
            font-size: 0.875rem;
            font-weight: 600;
            box-shadow: 0 4px 16px rgba(0,0,0,.15);
            z-index: 9999;
            opacity: 0;
            transform: translateX(20px);
            transition: all 0.3s ease;
        }

        .toast.show { opacity: 1; transform: translateX(0); }
        .toast.error { background: var(--red); }

        /* FOOTER */
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

        /* RESPONSIVE */
        @media (max-width: 900px) {
            .layout { flex-direction: column; padding: 0 1rem; }
            .sidebar { width: 100%; position: static; }
            .sidebar-nav { display: flex; flex-wrap: wrap; gap: 0.25rem; }
            .sidebar-nav a { width: auto; }
            .detail-grid { grid-template-columns: 1fr; }
        }

        @media (max-width: 640px) {
            .layout { padding: 0 1rem; }
            .topnav { padding: 0 1rem; }
            .nav-links { display: none; }
            .action-buttons { flex-direction: column; }
        }
    </style>
</head>
<body>

<!-- TOPNAV -->
<nav class="topnav">
    <a href="home.jsp" class="nav-logo">
        <i class="fa-solid fa-apple-whole"></i> Sena Shop
    </a>
    <div class="nav-links">
        <a href="home.jsp">Trang Chu</a>
        <a href="products">San Pham</a>
    </div>
    <div class="nav-right">
        <a href="wishlist" class="nav-icon-btn" title="Yeu Thich">
            <i class="fa-solid fa-heart"></i>
            <span class="wishlist-badge"><%= wishlistCount %></span>
        </a>
        <a href="cart" class="nav-icon-btn" title="Gio hang">
            <i class="fa-solid fa-basket-shopping"></i>
            <span class="cart-badge"><%= cartCount %></span>
        </a>
        <img class="nav-avatar" src="<%= avatarUrl %>" alt="avatar">
    </div>
</nav>

<!-- LAYOUT -->
<div class="layout">

    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-nav">
            <a href="profile"><i class="fa-regular fa-user"></i> Ho So</a>
            <a href="products"><i class="fa-brands fa-opencart"></i> San Pham</a>
            <a href="add-product"><i class="fa-solid fa-plus"></i> Them San Pham</a>
            <a href="<%= "seller".equals(role) ? "seller/orders" : "my-orders" %>"><i class="fa-solid fa-basket-shopping"></i> Don Hang</a>
            <a href="wishlist" class="active" style="color: #ef4444;"><i class="fa-regular fa-heart"></i> Yeu Thich</a>
            <a href="logout" class="logout" style="margin-top:0.5rem;">
                <i class="fa-solid fa-right-from-bracket"></i> Dang Xuat
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="main">

        <!-- Breadcrumb -->
        <div class="breadcrumb">
            <a href="products"><i class="fa-solid fa-box"></i> San Pham</a>
            <i class="fa-solid fa-chevron-right" style="font-size:0.6rem;color:var(--gray-400);"></i>
            <span><%= product.getTitle() %></span>
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

        <!-- Detail card -->
        <div class="card">
            <div class="card-header">
                <i class="fa-solid fa-circle-info" style="color:var(--green);font-size:1rem;"></i>
                <div class="card-title">Chi Tiet San Pham</div>
            </div>
            <div class="card-body">

                <div class="detail-grid">

                    <!-- LEFT: Product image -->
                    <div>
                        <% if (product.getImage() != null && !product.getImage().trim().isEmpty()) { %>
                        <div class="product-image-wrap">
                            <img src="<%= ImageUrlUtil.resolve(product.getImage(), request.getContextPath()) %>"
                                 alt="<%= product.getTitle() %>"
                                 onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
                            <div class="product-image-placeholder" style="display:none;">🍎</div>
                        </div>
                        <% } else { %>
                        <div class="product-image-wrap">
                            <div class="product-image-placeholder">🍎</div>
                        </div>
                        <% } %>
                    </div>

                    <!-- RIGHT: Info panel -->
                    <div class="info-panel">

                        <div>
                            <h1 class="product-title"><%= product.getTitle() %></h1>
                        </div>

                        <!-- Price -->
                        <div class="price-block">
                            <span class="price-sale">
                                <%= nf.format((long) salePrice) %> d
                            </span>
                            <% if (hasDiscount) { %>
                            <span class="price-original">
                                <%= nf.format((long) originalPrice) %> d
                            </span>
                            <span class="price-discount">-<%= discountPercent %>%</span>
                            <% } %>
                        </div>

                        <!-- Meta info -->
                        <div class="meta-list">

                            <div class="meta-item">
                                <i class="fa-solid fa-tag"></i>
                                <span class="meta-label">Danh muc:</span>
                                <span class="meta-value"><%= categoryName %></span>
                            </div>

                            <div class="meta-item">
                                <i class="fa-solid fa-cube"></i>
                                <span class="meta-label">Don vi:</span>
                                <span class="meta-value"><%= product.getUnit() != null ? product.getUnit() : "-" %></span>
                            </div>

                            <div class="meta-item">
                                <i class="fa-solid fa-boxes-stacked"></i>
                                <span class="meta-label">Ton kho:</span>
                                <span class="meta-value">
                                    <% if (product.getStockQuantity() <= 0) { %>
                                        <span class="badge badge-red">
                                            <i class="fa-solid fa-circle-xmark"></i> Het Hang
                                        </span>
                                    <% } else if (product.getStockQuantity() <= 20) { %>
                                        <span class="badge badge-yellow">
                                            <i class="fa-solid fa-circle-exclamation"></i>
                                            <%= product.getStockQuantity() %> con lai
                                        </span>
                                    <% } else { %>
                                        <span class="badge badge-green">
                                            <i class="fa-solid fa-check-circle"></i>
                                            <%= product.getStockQuantity() %> san pham
                                        </span>
                                    <% } %>
                                </span>
                            </div>

                            <div class="meta-item">
                                <i class="fa-solid fa-calendar-xmark"></i>
                                <span class="meta-label">Han su dung:</span>
                                <span class="meta-value">
                                    <% if (product.getExpiredDate() != null) { %>
                                        <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(product.getExpiredDate()) %>
                                        <% long now = System.currentTimeMillis();
                                           long exp = product.getExpiredDate().getTime();
                                           if (exp < now) { %>
                                            <span class="badge badge-red" style="margin-left:0.4rem;">Da het han</span>
                                        <% } else if (exp - now < 7 * 24 * 3600 * 1000L) { %>
                                            <span class="badge badge-yellow" style="margin-left:0.4rem;">Sap het han</span>
                                        <% } %>
                                    <% } else { %>
                                        Khong co han
                                    <% } %>
                                </span>
                            </div>

                            <div class="meta-item">
                                <i class="fa-solid fa-chart-line"></i>
                                <span class="meta-label">Da ban:</span>
                                <span class="meta-value"><%= product.getSoldQuantity() %> san pham</span>
                            </div>

                            <div class="meta-item">
                                <i class="fa-solid fa-star"></i>
                                <span class="meta-label">Danh gia:</span>
                                <span class="meta-value">
                                    <% if (product.getAverageRating() > 0) { %>
                                        <span class="rating-stars">
                                            <% int full = (int) Math.round(product.getAverageRating());
                                               for (int i = 0; i < 5; i++) {
                                                   if (i < full) { %>
                                                   <i class="fa-solid fa-star"></i>
                                               <% } else { %>
                                                   <i class="fa-solid fa-star empty"></i>
                                               <% } %>
                                           <% } %>
                                        </span>
                                        <span style="font-size:0.82rem;color:var(--gray-600);margin-left:0.25rem;">
                                            (<%= String.format(java.util.Locale.US, "%.1f", product.getAverageRating()) %>)
                                        </span>
                                    <% } else { %>
                                        Chua co danh gia
                                    <% } %>
                                </span>
                            </div>

                            <div class="meta-item">
                                <i class="fa-solid fa-toggle-on"></i>
                                <span class="meta-label">Trang thai:</span>
                                <span class="meta-value">
                                    <% if (product.isActive()) { %>
                                        <span class="badge badge-green">
                                            <i class="fa-solid fa-circle" style="font-size:0.45rem;"></i> Hoat dong
                                        </span>
                                    <% } else { %>
                                        <span class="badge badge-gray">
                                            <i class="fa-solid fa-circle" style="font-size:0.45rem;"></i> Khong hoat dong
                                        </span>
                                    <% } %>
                                </span>
                            </div>

                        </div>

                        <!-- Shop info -->
                        <div>
                            <div class="section-label" style="margin-bottom:0.6rem;">
                                <i class="fa-solid fa-shop" style="font-size:0.75rem;color:var(--green);"></i>
                                Cua Hang Ban
                            </div>
                            <div class="shop-card">
                                <% if (shopInfo.getLogo() != null && !shopInfo.getLogo().trim().isEmpty()) { %>
                                <img class="shop-avatar" src="<%= ImageUrlUtil.resolve(shopInfo.getLogo(), request.getContextPath()) %>"
                                     alt="<%= shopInfo.getShopName() %>"
                                     onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
                                <div class="shop-avatar-placeholder" style="display:none;">&#127974;</div>
                                <% } else { %>
                                <div class="shop-avatar-placeholder">&#127974;</div>
                                <% } %>
                                <div class="shop-info">
                                    <div class="shop-name">
                                        <%= shopInfo.getShopName() != null ? shopInfo.getShopName() : "-" %>
                                    </div>
                                    <div class="shop-meta">
                                        <% if (shopInfo.getAddress() != null && !shopInfo.getAddress().isEmpty()) { %>
                                            <%= shopInfo.getAddress() %>
                                        <% } else { %>
                                            Dia chi chua cap nhat
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Action buttons -->
                        <div class="action-buttons">
                            <% if (product.isActive() && product.getStockQuantity() > 0) { %>

                                <form action="add-to-cart" method="POST" id="addToCartForm" style="display:inline;">
                                    <input type="hidden" name="productId" value="<%= product.getId() %>">
                                    <input type="hidden" name="quantity" id="quantityInput" value="1">
                                    <button type="submit" class="btn btn-green" id="addToCartBtn">
                                        <i class="fa-solid fa-basket-shopping"></i>
                                        Them Vao Gio Hang
                                    </button>
                                </form>
                            <% } else if (product.getStockQuantity() <= 0) { %>
                                <button class="btn btn-secondary" disabled>
                                    <i class="fa-solid fa-ban"></i> Het Hang
                                </button>
                            <% } else { %>
                                <button class="btn btn-secondary" disabled>
                                    <i class="fa-solid fa-ban"></i> Khong Hoat Dong
                                </button>
                            <% } %>

                            <% if (product.isActive()) { %>
                                <button type="button" id="wishlistBtn"
                                        class="btn btn-wishlist <%= inWishlist ? "in-wishlist" : "" %>"
                                        onclick="toggleWishlist(<%= product.getId() %>, this)">
                                    <i class="fa-<%= inWishlist ? "solid" : "regular" %> fa-heart"></i>
                                    <span id="wishlistLabel"><%= inWishlist ? "Da Yeu Thich" : "Yeu Thich" %></span>
                                </button>
                            <% } %>

                            <% if (isOwner) { %>
                            <a href="edit-product?id=<%= product.getId() %>" class="btn btn-outline">
                                <i class="fa-solid fa-pen-to-square"></i>
                                Chinh Sua
                            </a>
                            <% } %>

                            <a href="products" class="btn btn-outline">
                                <i class="fa-solid fa-arrow-left"></i>
                                Quay Lai
                            </a>
                        </div>

                    </div>

                </div>

            </div>
        </div>

        <!-- Description card -->
        <div class="card">
            <div class="card-header">
                <i class="fa-solid fa-align-left" style="color:var(--green);font-size:1rem;"></i>
                <div class="card-title">Mo Ta San Pham</div>
            </div>
            <div class="card-body">
                <% if (product.getDescription() != null && !product.getDescription().trim().isEmpty()) { %>
                <div style="font-size:0.9rem;line-height:1.75;color:var(--gray-800);white-space:pre-wrap;">
                    <%= product.getDescription() %>
                </div>
                <% } else { %>
                <p style="color:var(--gray-400);font-size:0.875rem;font-style:italic;">
                    San pham nay chua co mo ta chi tiet.
                </p>
                <% } %>
            </div>
        </div>

    </main>
</div>

<!-- FOOTER -->
<footer class="footer">
    <a href="home.jsp" class="footer-logo"><i class="fa-solid fa-apple-whole"></i> Sena Shop</a>
    <span class="footer-copy">&copy; 2024 Sena Shop. Trai cay tuoi ngon moi ngay.</span>
</footer>

<!-- TOAST -->
<div id="toast" class="toast"></div>

<script>
    // ---- Hien thi thong bao ----
    function showToast(message, isError) {
        var toast = document.getElementById('toast');
        toast.textContent = message;
        toast.className = 'toast' + (isError ? ' error' : '');
        toast.classList.add('show');
        setTimeout(function() {
            toast.classList.remove('show');
        }, 3000);
    }

    // ---- Set size truoc khi submit ----
    var addToCartForm = document.getElementById('addToCartForm');
    if (addToCartForm) {
        addToCartForm.addEventListener('submit', function(e) {
            var sizeInputs = document.getElementsByName('selectedSize');
            if (sizeInputs.length > 0) {
                for (var i = 0; i < sizeInputs.length; i++) {
                    if (sizeInputs[i].checked) {
                        document.getElementById('selectedSizeInput').value = sizeInputs[i].value;
                        break;
                    }
                }
            }
        });
    }

    // ---- AJAX Toggle Wishlist ----
    function toggleWishlist(productId, btn) {
        fetch('add-to-wishlist', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'productId=' + productId
        })
        .then(function(response) {
            if (response.status === 401) {
                window.location.href = '<%= request.getContextPath() %>/login';
                return null;
            }
            return response.text();
        })
        .then(function(data) {
            if (data === null) return;

            var icon = btn.querySelector('i');
            var label = btn.getAttribute('id') === 'wishlistBtn' ? document.getElementById('wishlistLabel') : null;

            if (btn.classList.contains('in-wishlist')) {
                btn.classList.remove('in-wishlist');
                icon.className = 'fa-regular fa-heart';
                if (label) label.textContent = 'Yeu Thich';
                showToast('Da xoa san pham khoi wishlist.');
            } else {
                btn.classList.add('in-wishlist');
                icon.className = 'fa-solid fa-heart';
                if (label) label.textContent = 'Da Yeu Thich';
                showToast('Da them san pham vao wishlist!');
            }
        })
        .catch(function(error) {
            showToast('Loi khi cap nhat wishlist. Vui long thu lai.', true);
        });
    }
</script>

</body>
</html>


