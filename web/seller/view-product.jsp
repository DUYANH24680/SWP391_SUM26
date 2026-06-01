<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Product" %>
<%@ page import="model.Category" %>
<%@ page import="model.Customer" %>
<%@ page import="model.Seller" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    Object sessionAccount = session.getAttribute("account");
    Object sessionUser = session.getAttribute("user");

    Object user = null;
    if (sessionAccount instanceof Seller) {
        user = (Seller) sessionAccount;
    } else if (sessionUser instanceof Seller) {
        user = (Seller) sessionUser;
    } else if (sessionUser instanceof Customer) {
        user = (Customer) sessionUser;
    }

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String displayName = "";
    String avatarUrl = "";
    if (user instanceof Seller) {
        Seller seller = (Seller) user;
        displayName = seller.getFullname();
        avatarUrl = seller.getAvatar();
    } else if (user instanceof Customer) {
        Customer customer = (Customer) user;
        displayName = customer.getFullname();
        avatarUrl = customer.getAvatar();
    }

    if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
        avatarUrl = "https://ui-avatars.com/api/?name="
                  + java.net.URLEncoder.encode(displayName, "UTF-8")
                  + "&background=4caf50&color=fff&size=160&bold=true&rounded=true";
    }

    Product product = (Product) request.getAttribute("product");
    Category category = (Category) request.getAttribute("category");

    Locale localeVN = new Locale("vi", "VN");
    NumberFormat nf = NumberFormat.getCurrencyInstance(localeVN);

    String statusBadge = "";
    String statusClass = "";
    if (product != null) {
        switch (product.getStatus()) {
            case 0: statusBadge = "Cho Duyet"; statusClass = "badge-pending"; break;
            case 1: statusBadge = "Hien Thi";  statusClass = "badge-active";  break;
            case 2: statusBadge = "An";        statusClass = "badge-hidden";  break;
        }
    }

    String stockClass = "";
    if (product != null) {
        if (product.getStockQuantity() == 0) stockClass = "stock-out";
        else if (product.getStockQuantity() < 10) stockClass = "stock-low";
        else stockClass = "stock-ok";
    }

    java.math.BigDecimal displayPrice = (product != null && product.getSalePrice() != null)
            ? product.getSalePrice() : (product != null ? product.getOriginalPrice() : null);
    boolean hasDiscount = product != null && product.getSalePrice() != null
            && product.getSalePrice().compareTo(product.getOriginalPrice()) < 0;
    int discountPercent = 0;
    if (hasDiscount) {
        java.math.BigDecimal diff = product.getOriginalPrice().subtract(product.getSalePrice());
        discountPercent = diff.multiply(java.math.BigDecimal.valueOf(100))
                .divide(product.getOriginalPrice(), 0, java.math.RoundingMode.HALF_UP).intValue();
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= product != null ? product.getTitle() : "San Pham" %> | Sena Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/seller.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/view-product.css">
</head>
<body>

<!-- ====== TOPNAV ====== -->
<nav class="topnav">
    <a href="<%= request.getContextPath() %>/home.jsp" class="nav-logo">
        <i class="fa-solid fa-apple-whole"></i> Sena Shop
    </a>
    <div class="nav-links">
        <a href="<%= request.getContextPath() %>/home.jsp">Trang Chu</a>
        <a href="#">San Pham</a>
        <a href="#">Don Hang</a>
        <a href="#" class="active">Quan Ly</a>
    </div>
    <div class="nav-right">
        <button class="nav-icon-btn" title="Thong bao"><i class="fa-regular fa-bell"></i></button>
        <a href="<%= request.getContextPath() %>/profile">
            <img class="nav-avatar" src="<%= avatarUrl %>" alt="avatar">
        </a>
    </div>
</nav>

<!-- ====== LAYOUT ====== -->
<div class="layout">

    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-user">
            <div class="sidebar-user-row">
                <img class="sidebar-user-avatar" src="<%= avatarUrl %>" alt="avatar">
                <div>
                    <div class="sidebar-welcome"><%= displayName.split(" ")[displayName.split(" ").length - 1] %></div>
                </div>
            </div>
            <div class="sidebar-role-text">Nhan Vien Ban Hang</div>
        </div>

        <div class="sidebar-nav">
            <a href="<%= request.getContextPath() %>/seller/dashboard">
                <i class="fa-solid fa-chart-line"></i> Tong Quan
            </a>
            <a href="<%= request.getContextPath() %>/seller/add-product">
                <i class="fa-solid fa-plus-circle"></i> Them San Pham
            </a>
            <a href="<%= request.getContextPath() %>/seller/products" class="active">
                <i class="fa-solid fa-box-open"></i> Quan Ly San Pham
            </a>
            <a href="<%= request.getContextPath() %>/seller/orders">
                <i class="fa-solid fa-receipt"></i> Don Hang
            </a>
            <a href="<%= request.getContextPath() %>/profile">
                <i class="fa-regular fa-user"></i> Ho So
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="main">

        <!-- Back button + breadcrumb -->
        <div style="margin-bottom:1rem;">
            <a href="<%= request.getContextPath() %>/seller/products" class="btn btn-outline btn-sm">
                <i class="fa-solid fa-arrow-left"></i> Quay Lai
            </a>
        </div>

        <% if (product == null) { %>
        <div class="alert alert-danger">
            <i class="fa-solid fa-circle-exclamation"></i>
            <span>San pham khong ton tai hoac da bi xoa.</span>
        </div>
        <% } else { %>

        <div class="view-product-grid">

            <!-- Left: Image -->
            <div class="view-product-image-card">
                <div class="view-image-wrap">
                    <% if (product.getImage() != null && !product.getImage().isEmpty()) { %>
                    <img src="<%= product.getImage() %>" alt="<%= product.getTitle() %>" class="view-main-image">
                    <% } else { %>
                    <div class="view-image-placeholder">
                        <i class="fa-solid fa-image"></i>
                        <span>Chua co hinh anh</span>
                    </div>
                    <% } %>

                    <% if (product.isIsFeatured()) { %>
                    <div class="view-badge-featured">
                        <i class="fa-solid fa-star"></i> Noi Bat
                    </div>
                    <% } %>
                </div>

                <div class="view-product-stats">
                    <div class="view-stat-item">
                        <div class="view-stat-label">Da Ban</div>
                        <div class="view-stat-value"><%= product.getSoldQuantity() %></div>
                    </div>
                    <div class="view-stat-item">
                        <div class="view-stat-label">Ton Kho</div>
                        <div class="view-stat-value <%= stockClass %>"><%= product.getStockQuantity() %></div>
                    </div>
                    <div class="view-stat-item">
                        <div class="view-stat-label">Danh Gia</div>
                        <div class="view-stat-value">
                            <%= product.getAverageRating() != null ? product.getAverageRating() + " / 5" : "Chua co" %>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right: Details -->
            <div class="view-product-detail-card">

                <!-- Header -->
                <div class="view-detail-header">
                    <div>
                        <div class="view-badges">
                            <span class="badge <%= statusClass %>"><%= statusBadge %></span>
                            <% if (category != null) { %>
                            <span class="badge badge-category"><%= category.getName() %></span>
                            <% } %>
                        </div>
                        <h1 class="view-product-title"><%= product.getTitle() %></h1>
                    </div>
                    <div class="view-actions-top">
                        <a href="<%= request.getContextPath() %>/seller/edit-product?id=<%= product.getId() %>"
                           class="btn btn-green btn-sm">
                            <i class="fa-solid fa-pen-to-square"></i> Chinh Sua
                        </a>
                    </div>
                </div>

                <!-- Price -->
                <div class="view-price-section">
                    <div class="view-current-price">
                        <%= nf.format(displayPrice) %>
                    </div>
                    <% if (hasDiscount) { %>
                    <div class="view-price-row">
                        <span class="view-original-price"><%= nf.format(product.getOriginalPrice()) %></span>
                        <span class="view-discount-badge">
                            -<%= discountPercent %>% giam
                        </span>
                    </div>
                    <% } %>
                </div>

                <!-- Unit -->
                <div class="view-info-row">
                    <i class="fa-solid fa-scale-balanced"></i>
                    <span>Don vi: <strong><%= product.getUnit() %></strong></span>
                </div>

                <!-- Expired -->
                <% if (product.getExpiredDate() != null) { %>
                <div class="view-info-row">
                    <i class="fa-solid fa-calendar-xmark"></i>
                    <span>Han su dung: <strong><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(product.getExpiredDate()) %></strong></span>
                </div>
                <% } %>

                <!-- Description -->
                <div class="view-description-section">
                    <h3 class="view-section-title">Mo Ta San Pham</h3>
                    <div class="view-description-text">
                        <%= product.getDescription() != null && !product.getDescription().trim().isEmpty()
                            ? product.getDescription()
                            : "<em style=\"color:var(--gray-400)\">Chua co mo ta.</em>" %>
                    </div>
                </div>

                <!-- Meta info -->
                <div class="view-meta-grid">
                    <div class="view-meta-item">
                        <div class="view-meta-label">ID San Pham</div>
                        <div class="view-meta-value">#<%= product.getId() %></div>
                    </div>
                    <div class="view-meta-item">
                        <div class="view-meta-label">Ngay Tao</div>
                        <div class="view-meta-value">
                            <%= product.getCreatedAt() != null
                                ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(product.getCreatedAt())
                                : "Khong ro" %>
                        </div>
                    </div>
                    <div class="view-meta-item">
                        <div class="view-meta-label">Nguoi Ban</div>
                        <div class="view-meta-value">Seller #<%= product.getSellerId() %></div>
                    </div>
                    <div class="view-meta-item">
                        <div class="view-meta-label">Danh Muc</div>
                        <div class="view-meta-value"><%= category != null ? category.getName() : "Khong ro" %></div>
                    </div>
                </div>

            </div>
        </div>

        <% } %>

    </main>
</div><!-- /layout -->

<!-- ====== FOOTER ====== -->
<footer class="footer">
    <a href="<%= request.getContextPath() %>/home.jsp" class="footer-logo"><i class="fa-solid fa-apple-whole"></i> Sena Shop</a>
    <span class="footer-copy">&copy; 2024 Sena Shop. Trai cay tuoi ngon moi ngay.</span>
</footer>

<script>
    // No JS needed for view page
</script>

</body>
</html>
