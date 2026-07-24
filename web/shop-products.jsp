<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Product" %>
<%@ page import="model.Shop" %>
<%@ page import="java.util.List" %>
<%
    Account user = (Account) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Shop shop = (Shop) request.getAttribute("shop");
    List<Product> products = (List<Product>) request.getAttribute("products");
    Integer totalProducts = (Integer) request.getAttribute("totalProducts");
    String searchKey = (String) request.getAttribute("searchKey");
    String currentSort = (String) request.getAttribute("currentSort");
    String avatarUrl = (String) request.getAttribute("avatarUrl");

    String error = (String) session.getAttribute("error");
    session.removeAttribute("error");

    String ctx = request.getContextPath();
    String currentUrl = ctx + "/shop-products?shopId=" + shop.getId()
        + (searchKey != null && !searchKey.isEmpty() ? "&search=" + java.net.URLEncoder.encode(searchKey, "UTF-8") : "")
        + (currentSort != null && !currentSort.isEmpty() ? "&sort=" + currentSort : "");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= shop.getShopName() %> | SenaFruit</title>
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
            --shadow-md:   0 8px 24px rgba(0,0,0,.10);
            --radius:      14px;
            --radius-sm:   8px;
            --orange:      #ff9800;
            --yellow:      #ffc107;
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
            font-size: 1.3rem;
            font-weight: 800;
            color: var(--green-dark);
            text-decoration: none;
            white-space: nowrap;
        }
        .nav-logo i { color: var(--green); }

        .nav-links { display: flex; gap: 0.25rem; }
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

        .nav-search {
            flex: 1;
            max-width: 420px;
            position: relative;
        }
        .nav-search input {
            width: 100%;
            height: 40px;
            border: 1.5px solid var(--gray-200);
            border-radius: 100px;
            padding: 0 1rem 0 2.75rem;
            font-size: 0.875rem;
            background: var(--gray-50);
            color: var(--gray-800);
            outline: none;
            transition: all 0.2s;
        }
        .nav-search input:focus {
            border-color: var(--green);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.1);
        }
        .nav-search i {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--gray-400);
            font-size: 0.85rem;
        }
        .nav-search form {
            display: flex;
            align-items: center;
        }
        .nav-search .search-btn {
            position: absolute;
            right: 4px;
            top: 3px;
            bottom: 3px;
            background: var(--green);
            color: white;
            border: none;
            border-radius: 100px;
            padding: 0 1rem;
            font-size: 0.8rem;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s;
        }
        .nav-search .search-btn:hover { background: var(--green-dark); }

        .nav-right { margin-left: auto; display: flex; align-items: center; gap: 0.75rem; }
        .nav-avatar {
            width: 38px; height: 38px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--green);
        }

        /* ======= LAYOUT ======= */
        .page-wrapper {
            max-width: 1280px;
            width: 100%;
            margin: 1.5rem auto;
            padding: 0 1.5rem;
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
            flex: 1;
        }

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
        .alert-danger { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }

        /* ======= SHOP HEADER ======= */
        .shop-header {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            padding: 1.5rem 2rem;
            display: flex;
            align-items: center;
            gap: 1.25rem;
        }
        .shop-avatar {
            width: 64px; height: 64px;
            border-radius: var(--radius-sm);
            object-fit: cover;
            border: 2px solid var(--green-mid);
            background: var(--green-light);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            flex-shrink: 0;
        }
        .shop-info { flex: 1; }
        .shop-name {
            font-size: 1.25rem;
            font-weight: 800;
            color: var(--gray-800);
            margin-bottom: 0.2rem;
        }
        .shop-meta {
            font-size: 0.82rem;
            color: var(--gray-400);
            display: flex;
            gap: 1rem;
        }
        .shop-badge-active {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            background: var(--green-light);
            color: var(--green-dark);
            padding: 0.2rem 0.6rem;
            border-radius: 100px;
            font-size: 0.72rem;
            font-weight: 700;
            text-transform: uppercase;
        }

        /* ======= SEARCH + SORT BAR ======= */
        .controls-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            padding: 0.75rem 1.25rem;
        }
        .search-wrap {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            flex: 1;
            max-width: 400px;
        }
        .search-wrap input {
            flex: 1;
            height: 38px;
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            padding: 0 0.85rem;
            font-size: 0.85rem;
            outline: none;
            transition: border-color 0.2s;
        }
        .search-wrap input:focus { border-color: var(--green); }
        .search-wrap button {
            height: 38px;
            padding: 0 1rem;
            background: var(--green);
            color: white;
            border: none;
            border-radius: var(--radius-sm);
            font-size: 0.82rem;
            font-weight: 600;
            cursor: pointer;
            white-space: nowrap;
        }
        .search-wrap button:hover { background: var(--green-dark); }

        .sort-tabs { display: flex; gap: 0.35rem; align-items: center; }
        .sort-tab {
            padding: 0.35rem 0.85rem;
            border-radius: 100px;
            font-size: 0.8rem;
            font-weight: 500;
            border: 1.5px solid var(--gray-200);
            background: var(--white);
            color: var(--gray-600);
            cursor: pointer;
            text-decoration: none;
            transition: all 0.15s;
            white-space: nowrap;
            font-family: 'Inter', sans-serif;
        }
        .sort-tab:hover { background: var(--green-light); color: var(--green-dark); border-color: var(--green); }
        .sort-tab.active { background: var(--green); color: #fff; border-color: var(--green); }

        /* ======= PRODUCTS GRID ======= */
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
            gap: 1.25rem;
        }

        .product-card {
            background: var(--white);
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius);
            overflow: hidden;
            cursor: pointer;
            transition: all 0.22s ease;
            display: flex;
            flex-direction: column;
        }
        .product-card:hover {
            border-color: var(--green-mid);
            box-shadow: var(--shadow-md);
            transform: translateY(-4px);
        }

        .product-image-wrap {
            position: relative;
            background: linear-gradient(135deg, #f1f8e9, #e8f5e9);
            height: 180px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }
        .product-emoji {
            font-size: 5rem;
            filter: drop-shadow(0 6px 12px rgba(0,0,0,0.12));
            transition: transform 0.3s ease;
        }
        .product-card:hover .product-emoji { transform: scale(1.08) rotate(-3deg); }

        .product-badge {
            position: absolute;
            top: 0.75rem;
            left: 0.75rem;
            padding: 0.2rem 0.6rem;
            border-radius: 100px;
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
        }
        .badge-sale { background: var(--orange); color: #fff; }
        .badge-hot { background: #c62828; color: #fff; }

        .product-wishlist {
            position: absolute;
            top: 0.75rem;
            right: 0.75rem;
            width: 32px; height: 32px;
            border-radius: 50%;
            background: rgba(255,255,255,0.9);
            border: none;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--gray-400);
            cursor: pointer;
            font-size: 0.9rem;
            transition: all 0.2s;
            box-shadow: var(--shadow-sm);
        }
        .product-wishlist:hover { color: #e53935; background: #fff; }

        .product-info { padding: 1rem; flex: 1; display: flex; flex-direction: column; gap: 0.4rem; }
        .product-name {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--gray-800);
            line-height: 1.3;
        }
        .product-rating { display: flex; align-items: center; gap: 0.35rem; }
        .stars i { font-size: 0.72rem; color: var(--yellow); }
        .stars.good i:not(.empty) { color: var(--green); }
        .stars i.empty { color: var(--gray-200); }
        .rating-count { font-size: 0.73rem; color: var(--gray-400); }

        .product-price {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-top: auto;
        }
        .price-current { font-size: 1.1rem; font-weight: 800; color: var(--green-dark); }
        .price-original { font-size: 0.82rem; color: var(--gray-400); text-decoration: line-through; }

        .product-footer {
            padding: 0.75rem 1rem;
            border-top: 1px solid var(--gray-100);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.5rem;
        }
        .product-unit {
            font-size: 0.78rem;
            color: var(--gray-600);
            display: flex;
            align-items: center;
            gap: 0.3rem;
        }
        .btn-cart {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.45rem 0.9rem;
            background: var(--green);
            color: white;
            border: none;
            border-radius: var(--radius-sm);
            font-size: 0.8rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.15s;
            text-decoration: none;
            font-family: 'Inter', sans-serif;
        }
        .btn-cart:hover { background: var(--green-dark); transform: translateY(-1px); }
        .btn-cart.out-of-stock {
            background: var(--gray-200);
            color: var(--gray-400);
            cursor: not-allowed;
        }

        /* ======= EMPTY STATE ======= */
        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            color: var(--gray-400);
            box-shadow: var(--shadow-sm);
        }
        .empty-state i { font-size: 3.5rem; color: var(--gray-200); margin-bottom: 1rem; display: block; }
        .empty-state p { font-size: 0.95rem; color: var(--gray-600); }

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
            display: flex; align-items: center; gap: 0.4rem;
            font-size: 0.9rem; font-weight: 700; color: var(--green-dark); text-decoration: none;
        }
        .footer-logo i { color: var(--green); }
        .footer-copy { font-size: 0.78rem; color: var(--gray-400); }

        @media (max-width: 768px) {
            .nav-search { display: none; }
            .controls-bar { flex-direction: column; align-items: stretch; }
            .search-wrap { max-width: 100%; }
            .sort-tabs { flex-wrap: wrap; }
            .products-grid { grid-template-columns: repeat(2, 1fr); }
            .shop-header { flex-direction: column; text-align: center; }
        }
    </style>
</head>
<body>

    <!-- Topnav -->
    <nav class="topnav">
        <a href="<%= ctx %>/home.jsp" class="nav-logo">
            <i class="fa-solid fa-apple-whole"></i> SenaFruit
        </a>
        <div class="nav-links">
            <a href="<%= ctx %>/home.jsp">Trang Chủ</a>
            <a href="<%= ctx %>/products">Sản Phẩm</a>
        </div>
        <div class="nav-search">
            <i class="fa-solid fa-magnifying-glass"></i>
            <form action="<%= ctx %>/shop-products" method="get">
                <input type="hidden" name="shopId" value="<%= shop.getId() %>">
                <input type="text" name="search" placeholder="Tìm kiếm trong cửa hàng..." value="<%= searchKey != null ? searchKey : "" %>">
                <button type="submit" class="search-btn">Tìm</button>
            </form>
        </div>
        <div class="nav-right">
            <img class="nav-avatar" src="<%= avatarUrl %>" alt="avatar">
        </div>
    </nav>

    <!-- Page Content -->
    <div class="page-wrapper">

        <% if (error != null) { %>
            <div class="alert alert-danger">
                <i class="fa-solid fa-circle-exclamation"></i>
                <span><%= error %></span>
            </div>
        <% } %>

        <!-- Shop Header -->
        <div class="shop-header">
            <% if (shop.getLogo() != null && !shop.getLogo().isEmpty()) { %>
                <img src="<%= shop.getLogo() %>" alt="logo" class="shop-avatar">
            <% } else { %>
                <div class="shop-avatar"><i class="fa-solid fa-store" style="color:var(--green);"></i></div>
            <% } %>
            <div class="shop-info">
                <div class="shop-name"><%= shop.getShopName() %></div>
                <div class="shop-meta">
                    <span><i class="fa-solid fa-box"></i> <%= totalProducts %> sản phẩm</span>
                    <% if (shop.getAddress() != null && !shop.getAddress().isEmpty()) { %>
                        <span><i class="fa-solid fa-location-dot"></i> <%= shop.getAddress() %></span>
                    <% } %>
                </div>
            </div>
            <span class="shop-badge-active"><i class="fa-solid fa-circle-check"></i> Đang hoạt động</span>
        </div>

        <!-- Search + Sort -->
        <div class="controls-bar">
            <div class="search-wrap">
                <form action="<%= ctx %>/shop-products" method="get" style="display:flex;gap:0.5rem;flex:1;max-width:400px;">
                    <input type="hidden" name="shopId" value="<%= shop.getId() %>">
                    <input type="text" name="search" placeholder="Tìm kiếm sản phẩm trong cửa hàng..." value="<%= searchKey != null ? searchKey : "" %>">
                    <button type="submit"><i class="fa-solid fa-magnifying-glass"></i> Tìm</button>
                </form>
            </div>
            <div class="sort-tabs">
                <a href="<%= ctx %>/shop-products?shopId=<%= shop.getId() %><%= searchKey != null && !searchKey.isEmpty() ? "&search=" + java.net.URLEncoder.encode(searchKey, "UTF-8") : "" %>&sort=popular"
                   class="sort-tab <%= (currentSort == null || "popular".equals(currentSort)) ? "active" : "" %>">
                    Phổ Biến
                </a>
                <a href="<%= ctx %>/shop-products?shopId=<%= shop.getId() %><%= searchKey != null && !searchKey.isEmpty() ? "&search=" + java.net.URLEncoder.encode(searchKey, "UTF-8") : "" %>&sort=newest"
                   class="sort-tab <%= "newest".equals(currentSort) ? "active" : "" %>">
                    Mới Nhất
                </a>
                <a href="<%= ctx %>/shop-products?shopId=<%= shop.getId() %><%= searchKey != null && !searchKey.isEmpty() ? "&search=" + java.net.URLEncoder.encode(searchKey, "UTF-8") : "" %>&sort=price_asc"
                   class="sort-tab <%= "price_asc".equals(currentSort) ? "active" : "" %>">
                    Giá Tăng
                </a>
                <a href="<%= ctx %>/shop-products?shopId=<%= shop.getId() %><%= searchKey != null && !searchKey.isEmpty() ? "&search=" + java.net.URLEncoder.encode(searchKey, "UTF-8") : "" %>&sort=price_desc"
                   class="sort-tab <%= "price_desc".equals(currentSort) ? "active" : "" %>">
                    Giá Giảm
                </a>
                <a href="<%= ctx %>/shop-products?shopId=<%= shop.getId() %><%= searchKey != null && !searchKey.isEmpty() ? "&search=" + java.net.URLEncoder.encode(searchKey, "UTF-8") : "" %>&sort=rating"
                   class="sort-tab <%= "rating".equals(currentSort) ? "active" : "" %>">
                    Đánh Giá
                </a>
            </div>
        </div>

        <!-- Products Grid -->
        <% if (products != null && !products.isEmpty()) { %>
            <div class="products-grid">
                <% for (Product p : products) { %>
                    <div class="product-card" onclick="window.location.href='<%= ctx %>/product-info?id=<%= p.getId() %>'" style="cursor:pointer;">
                        <div class="product-image-wrap">
                            <%
                                String imgStr = p.getImage() != null && !p.getImage().isEmpty() ? p.getImage() : "🍎";
                                boolean isImage = imgStr.toLowerCase().endsWith(".png") || imgStr.toLowerCase().endsWith(".jpg")
                                              || imgStr.toLowerCase().endsWith(".jpeg") || imgStr.toLowerCase().endsWith(".gif")
                                              || imgStr.contains("/");
                                if (isImage) {
                            %>
                                <img src="<%= imgStr %>" alt="<%= p.getTitle() %>" style="width:100%;height:100%;object-fit:cover;">
                            <% } else { %>
                                <div class="product-emoji"><%= imgStr %></div>
                            <% } %>

                            <% if (p.getSalePrice() < p.getOriginalPrice()) {
                                int pct = (int) Math.round((1 - p.getSalePrice() / p.getOriginalPrice()) * 100);
                            %>
                                <div class="product-badge badge-sale">-<%= pct %>%</div>
                            <% } else if (p.isIsFeatured()) { %>
                                <div class="product-badge badge-hot">Hot</div>
                            <% } %>

                            <button class="product-wishlist" onclick="event.stopPropagation();"><i class="fa-regular fa-heart"></i></button>
                        </div>

                        <div class="product-info">
                            <div class="product-name"><%= p.getTitle() %></div>
                            <div class="product-rating">
                                <% double avg = p.getAverageRating(); %>
                                <div class="stars <%= avg >= 4.0 ? "good" : "" %>">
                                    <%
                                        int fullStars = (int) avg;
                                        boolean hasHalfStar = (avg - fullStars) >= 0.5;
                                        for (int i = 1; i <= 5; i++) {
                                            if (i <= fullStars) {
                                    %>
                                        <i class="fa-solid fa-star"></i>
                                    <%      } else if (i == fullStars + 1 && hasHalfStar) { %>
                                        <i class="fa-solid fa-star-half-stroke half"></i>
                                    <%      } else { %>
                                        <i class="fa-regular fa-star empty"></i>
                                    <%      }
                                        }
                                    %>
                                </div>
                                <span class="rating-count"><%= String.format("%.1f", p.getAverageRating()) %> (<%= p.getSoldQuantity() %>)</span>
                            </div>
                            <div class="product-price">
                                <span class="price-current"><%= String.format("%,.0f", p.getSalePrice()) %> đ</span>
                                <% if (p.getSalePrice() < p.getOriginalPrice()) { %>
                                    <span class="price-original"><%= String.format("%,.0f", p.getOriginalPrice()) %> đ</span>
                                <% } %>
                            </div>
                        </div>

                        <div class="product-footer">
                            <div class="product-unit">
                                <i class="fa-solid fa-scale-balanced"></i> Còn <%= p.getStockQuantity() %> <%= p.getUnit() != null ? p.getUnit() : "kg" %>
                            </div>
                            <% if (p.getStockQuantity() > 0) { %>
                                <a href="<%= ctx %>/checkout?productId=<%= p.getId() %>&quantity=1" class="btn-cart" onclick="event.stopPropagation();">
                                    <i class="fa-solid fa-basket-shopping"></i> Mua ngay
                                </a>
                            <% } else { %>
                                <span class="btn-cart out-of-stock"><i class="fa-solid fa-ban"></i> Hết hàng</span>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="empty-state">
                <i class="fa-solid fa-store-slash"></i>
                <p><%= searchKey != null && !searchKey.isEmpty()
                        ? "Không tìm thấy sản phẩm nào cho từ khóa \"" + searchKey + "\"."
                        : "Cửa hàng này hiện chưa có sản phẩm nào." %></p>
            </div>
        <% } %>

    </div>

    <!-- Footer -->
    <footer class="footer">
        <a href="<%= ctx %>/home.jsp" class="footer-logo">
            <i class="fa-solid fa-apple-whole"></i> SenaFruit
        </a>
        <span class="footer-copy">&copy; 2024 SenaFruit. Trái cây tươi ngon mỗi ngày.</span>
    </footer>

</body>
</html>
