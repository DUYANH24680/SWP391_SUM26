<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="model.Customer" %>
<%@ page import="model.Seller" %>
<%
    Object sessionAccount = session.getAttribute("account");
    Object sessionUser = session.getAttribute("user");

    Object user = null;
    boolean isSeller = false;

    if (sessionAccount instanceof Seller) {
        user = (Seller) sessionAccount;
        isSeller = true;
    } else if (sessionUser instanceof Seller) {
        user = (Seller) sessionUser;
        isSeller = true;
    } else if (sessionUser instanceof Customer) {
        user = (Customer) sessionUser;
        isSeller = false;
    }

    String userDisplayName = "";
    String userEmail = "";
    if (user instanceof Customer) {
        Customer c = (Customer) user;
        userDisplayName = c.getFullname() != null ? c.getFullname() : c.getUsername();
        userEmail = c.getEmail() != null ? c.getEmail() : "";
    } else if (user instanceof Seller) {
        Seller s = (Seller) user;
        userDisplayName = s.getFullname() != null ? s.getFullname() : s.getUsername();
        userEmail = s.getEmail() != null ? s.getEmail() : "";
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sena Shop - Trái Cây Tươi Ngon Mỗi Ngày</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/variables.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/base.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/home.css">
</head>
<body>

<!-- ====================================================== TOPNAV -->
<nav class="topnav">
    <a href="home.jsp" class="nav-logo">
        <i class="fa-solid fa-apple-whole"></i> Sena Shop
    </a>

    <div class="nav-search">
        <i class="fa-solid fa-magnifying-glass"></i>
        <input type="text" placeholder="Tìm kiếm trái cây, rau củ...">
    </div>

    <div class="nav-links">
        <a href="#" class="active">Trang Chủ</a>
        <a href="#">Trái Cây</a>
        <a href="#">Rau Củ</a>
        <a href="#">Nhập Khẩu</a>
        <a href="#">Khuyến Mãi</a>
    </div>

    <div class="nav-right">
        <button class="nav-icon-btn" title="Giỏ hàng">
            <i class="fa-solid fa-basket-shopping"></i>
            <span class="cart-badge">3</span>
        </button>
        <button class="nav-icon-btn" title="Thông báo">
            <i class="fa-regular fa-bell"></i>
        </button>

            <% if (user != null) { %>
            <!-- Avatar with dropdown -->
            <div class="avatar-wrap">
                <img class="nav-avatar"
                     src="https://ui-avatars.com/api/?name=<%= userDisplayName.replace(" ", "+") %>&background=4caf50&color=fff&size=80&bold=true"
                     alt="avatar">
                <div class="avatar-dropdown">
                    <div class="avatar-dropdown-inner">
                        <div class="dropdown-header">
                            <strong><%= userDisplayName %></strong>
                            <span><%= userEmail %></span>
                        </div>
                        <div class="dropdown-menu">
                            <a class="dropdown-item" href="profile?tab=profile">
                                <i class="fa-regular fa-user"></i> Hồ Sơ Của Tôi
                            </a>
                            <a class="dropdown-item" href="profile?tab=security">
                                <i class="fa-solid fa-shield-halved"></i> Bảo Mật
                            </a>
                            <% if (isSeller) { %>
                            <div class="dropdown-divider"></div>
                            <a class="dropdown-item" href="seller/dashboard">
                                <i class="fa-solid fa-store"></i> Khu Vực Seller
                            </a>
                            <a class="dropdown-item" href="seller/add-product">
                                <i class="fa-solid fa-plus-circle"></i> Them San Pham
                            </a>
                            <a class="dropdown-item" href="seller/products">
                                <i class="fa-solid fa-box-open"></i> Quan Ly San Pham
                            </a>
                            <% } %>
                            <div class="dropdown-divider"></div>
                            <a class="dropdown-item danger" href="logout">
                                <i class="fa-solid fa-right-from-bracket"></i> Đăng Xuất
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        <% } else { %>
            <!-- Auth Buttons -->
            <div class="auth-buttons">
                <a href="login.jsp" class="auth-btn auth-btn-outline">Đăng Nhập</a>
                <a href="login.jsp" class="auth-btn auth-btn-solid">Đăng Ký</a>
            </div>
        <% } %>
    </div>
</nav>

<!-- ====================================================== HERO SLIDER -->
<section class="hero">
    <div class="slider-track" id="sliderTrack">

        <!-- Slide 1 -->
        <div class="slide slide-1">
            <div class="slide-decor slide-decor-1"></div>
            <div class="slide-decor slide-decor-2"></div>
            <div class="slide-content">
                <div class="slide-tag"><i class="fa-solid fa-fire"></i> Sản Phẩm Hot Nhất</div>
                <h1 class="slide-title">Trái Cây<br>Nhap Khau Cao Cap</h1>
                <p class="slide-sub">Chọn lọc từ những vườn cây tốt nhất thế giới.<br>Giao tận tay trong ngày.</p>
                <div class="slide-actions">
                    <a href="#" class="btn btn-white"><i class="fa-solid fa-bag-shopping"></i> Mua Ngay</a>
                    <a href="#" class="btn btn-white-outline">Xem Tất Cả</a>
                </div>
            </div>
            <div class="slide-emoji">🍎</div>
        </div>

        <!-- Slide 2 -->
        <div class="slide slide-2">
            <div class="slide-decor slide-decor-1"></div>
            <div class="slide-decor slide-decor-2"></div>
            <div class="slide-content">
                <div class="slide-tag"><i class="fa-solid fa-tag"></i> Giảm Giá Đến 30%</div>
                <h1 class="slide-title">Trái Cây<br>Huu Co Sach</h1>
                <p class="slide-sub">Trồng theo tiêu chuẩn hữu cơ quốc tế.<br>An toàn cho cả gia đình.</p>
                <div class="slide-actions">
                    <a href="#" class="btn btn-white"><i class="fa-solid fa-leaf"></i> Kham Pha</a>
                    <a href="#" class="btn btn-white-outline">Ưu Đãi Hôm Nay</a>
                </div>
            </div>
            <div class="slide-emoji">🍊</div>
        </div>

        <!-- Slide 3 -->
        <div class="slide slide-3">
            <div class="slide-decor slide-decor-1"></div>
            <div class="slide-decor slide-decor-2"></div>
            <div class="slide-content">
                <div class="slide-tag"><i class="fa-solid fa-star"></i> Đặc Sản Miền Nam</div>
                <h1 class="slide-title">Trái Cây<br>Noi Dia Tuoi Ngon</h1>
                <p class="slide-sub">Tháng này: Xoài cát Hòa Lộc, Sầu riêng, Mít.<br>Thơm ngon đúng mùa.</p>
                <div class="slide-actions">
                    <a href="#" class="btn btn-white"><i class="fa-solid fa-box-open"></i> Dat Hang</a>
                    <a href="#" class="btn btn-white-outline">Xem Bộ Sưu Tập</a>
                </div>
            </div>
            <div class="slide-emoji">🥭</div>
        </div>
    </div>

    <!-- Arrows -->
    <button class="slider-arrow prev" onclick="changeSlide(-1)">
        <i class="fa-solid fa-chevron-left"></i>
    </button>
    <button class="slider-arrow next" onclick="changeSlide(1)">
        <i class="fa-solid fa-chevron-right"></i>
    </button>

    <!-- Dots -->
    <div class="slider-dots">
        <div class="dot active" onclick="goSlide(0)"></div>
        <div class="dot" onclick="goSlide(1)"></div>
        <div class="dot" onclick="goSlide(2)"></div>
    </div>
</section>

<!-- ====================================================== MAIN CONTENT -->
<div class="page-wrap">

    <!-- Promo Info Row -->
    <div class="promo-row" style="margin-top: 1.5rem;">
        <div class="promo-card promo-1">
            <div class="promo-icon">🚚</div>
            <div class="promo-text">
                <strong>Miễn Phí Vận Chuyển</strong>
                <span>Đơn hàng từ 200.000 VNĐ trở lên</span>
            </div>
        </div>
        <div class="promo-card promo-2">
            <div class="promo-icon">✅</div>
            <div class="promo-text">
                <strong>Chất Lượng Đảm Bảo</strong>
                <span>Kiểm tra 100% trước khi giao hàng</span>
            </div>
        </div>
        <div class="promo-card promo-3">
            <div class="promo-icon">🔄</div>
            <div class="promo-text">
                <strong>Đổi Trả Dễ Dàng</strong>
                <span>Hoàn tiền 100% nếu sản phẩm hỏng</span>
            </div>
        </div>
    </div>

    <!-- ──── CATEGORIES ──── -->
    <div class="section-head" style="margin-top:2rem;">
        <div class="section-title">
            <span class="title-icon-green">🏷️</span>
            Danh Mục Sản Phẩm
        </div>
        <a href="#" class="see-all">Xem tất cả <i class="fa-solid fa-arrow-right"></i></a>
    </div>

    <div class="categories-grid">
        <a href="#" class="category-card active">
            <div class="cat-emoji">✈️🍎</div>
            <div class="cat-name">Trái Cây Nhập Khẩu</div>
            <div class="cat-count">12 sản phẩm</div>
        </a>
        <a href="#" class="category-card">
            <div class="cat-emoji">🇻🇳🥭</div>
            <div class="cat-name">Trái Cây Nội Địa</div>
            <div class="cat-count">24 sản phẩm</div>
        </a>
        <a href="#" class="category-card">
            <div class="cat-emoji">🌿🍋</div>
            <div class="cat-name">Trái Cây Hữu Cơ</div>
            <div class="cat-count">8 sản phẩm</div>
        </a>
        <a href="#" class="category-card">
            <div class="cat-emoji">👑🍇</div>
            <div class="cat-name">Trái Cây Cao Cấp</div>
            <div class="cat-count">6 sản phẩm</div>
        </a>
    </div>

    <!-- ──── FEATURED BANNER ──── -->
    <div class="featured-banner">
        <div class="featured-text">
            <div class="featured-tag"><i class="fa-solid fa-star"></i> Sản Phẩm Nổi Bật</div>
            <div class="featured-title">Bộ Sưu Tập Đặc Biệt Tháng Này</div>
            <div class="featured-sub">Nhung sản phẩm duoc lua chon thu cong boi doi ngu chuyen gia</div>
        </div>
        <div class="featured-emojis">🍓 🫐 🍑 🍒 🥝</div>
    </div>

    <!-- ──── SHOP LAYOUT (FILTER + PRODUCTS) ──── -->
    <div class="section-head">
        <div class="section-title">
            <span class="title-icon-green">🛍️</span>
            Tất Cả Sản Phẩm
        </div>
        <a href="#" class="see-all">Xem thêm <i class="fa-solid fa-arrow-right"></i></a>
    </div>

    <div class="shop-layout">

        <!-- FILTER SIDEBAR -->
        <aside class="filter-sidebar">

            <!-- Category filter -->
            <div class="filter-card">
                <div class="filter-header">
                    <div class="filter-title"><i class="fa-solid fa-list"></i> Danh Mục</div>
                </div>
                <div class="filter-body" style="display:flex;flex-direction:column;gap:0.1rem;">
                    <div class="filter-check">
                        <div class="filter-check-left">
                            <div class="check-box checked"></div>
                            <span class="check-label">Nhập Khẩu</span>
                        </div>
                        <span class="check-num">12</span>
                    </div>
                    <div class="filter-check">
                        <div class="filter-check-left">
                            <div class="check-box"></div>
                            <span class="check-label">Noi Dia</span>
                        </div>
                        <span class="check-num">24</span>
                    </div>
                    <div class="filter-check">
                        <div class="filter-check-left">
                            <div class="check-box"></div>
                            <span class="check-label">Huu Co</span>
                        </div>
                        <span class="check-num">8</span>
                    </div>
                    <div class="filter-check">
                        <div class="filter-check-left">
                            <div class="check-box"></div>
                            <span class="check-label">Cao Cap</span>
                        </div>
                        <span class="check-num">6</span>
                    </div>
                </div>
            </div>

            <!-- Price filter -->
            <div class="filter-card">
                <div class="filter-header">
                    <div class="filter-title"><i class="fa-solid fa-tag"></i> Khoảng Giá (VND)</div>
                </div>
                <div class="filter-body">
                    <div class="price-inputs">
                        <input type="text" class="price-input" placeholder="Từ 0">
                        <input type="text" class="price-input" placeholder="Đến 500k">
                    </div>
                    <button style="width:100%;padding:0.5rem;background:var(--green);color:#fff;border:none;border-radius:var(--radius-xs);font-size:0.8rem;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;">
                        Ap Dung
                    </button>
                </div>
            </div>

            <!-- Rating filter -->
            <div class="filter-card">
                <div class="filter-header">
                    <div class="filter-title"><i class="fa-solid fa-star"></i> Đánh Giá</div>
                </div>
                <div class="filter-body" style="display:flex;flex-direction:column;gap:0.35rem;">
                    <div class="rating-row">
                        <div class="check-box checked" style="width:15px;height:15px;border-radius:3px;"></div>
                        <div class="stars-static">
                            <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                            <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                            <i class="fa-solid fa-star"></i>
                        </div>
                        <span class="rating-label" style="font-size:0.78rem;color:var(--gray-400);">(5 sao)</span>
                    </div>
                    <div class="rating-row">
                        <div class="check-box"></div>
                        <div class="stars-static">
                            <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                            <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                            <i class="fa-regular fa-star empty"></i>
                        </div>
                        <span class="rating-label" style="font-size:0.78rem;color:var(--gray-400);">trở lên</span>
                    </div>
                    <div class="rating-row">
                        <div class="check-box"></div>
                        <div class="stars-static">
                            <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                            <i class="fa-solid fa-star"></i>
                            <i class="fa-regular fa-star empty"></i><i class="fa-regular fa-star empty"></i>
                        </div>
                        <span class="rating-label" style="font-size:0.78rem;color:var(--gray-400);">trở lên</span>
                    </div>
                </div>
            </div>

            <!-- Availability filter -->
            <div class="filter-card">
                <div class="filter-header">
                    <div class="filter-title"><i class="fa-solid fa-box"></i> Tình Trạng</div>
                </div>
                <div class="filter-body">
                    <div class="filter-check">
                        <div class="filter-check-left">
                            <div class="check-box checked"></div>
                            <span class="check-label">Còn Hàng</span>
                        </div>
                    </div>
                    <div class="filter-check">
                        <div class="filter-check-left">
                            <div class="check-box"></div>
                            <span class="check-label">Hết Hàng</span>
                        </div>
                    </div>
                </div>
            </div>
        </aside>

        <!-- PRODUCTS AREA -->
        <div class="products-area">

            <!-- Sort bar -->
            <div class="sort-bar">
                <div class="sort-bar-left">Hiển thị <strong>12</strong> / 50 sản phẩm</div>
                <div class="sort-tabs">
                    <span style="font-size:0.8rem;color:var(--gray-400);margin-right:0.3rem;">Sắp xếp:</span>
                    <button class="sort-tab active">Phổ Biến</button>
                    <button class="sort-tab">Mới Nhất</button>
                    <button class="sort-tab">Giá Tăng</button>
                    <button class="sort-tab">Giá Giảm</button>
                    <button class="sort-tab">Đánh Giá</button>
                </div>
            </div>

            <!-- Product grid -->
            <div class="products-grid">

                <!-- Product 1 -->
                <div class="product-card">
                    <div class="product-image-wrap">
                        <div class="product-emoji">🍎</div>
                        <div class="product-badge badge-sale">-18%</div>
                        <button class="product-wishlist"><i class="fa-regular fa-heart"></i></button>
                    </div>
                    <div class="product-info">
                        <div class="product-category">Nhập Khẩu</div>
                        <div class="product-name">Táo Mỹ Fuji Tươi Giòn</div>
                        <div class="product-rating">
                            <div class="stars">
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                <i class="fa-solid fa-star"></i>
                            </div>
                            <span class="rating-count">4.9 (128)</span>
                        </div>
                        <div class="product-price">
                            <span class="price-current">99.000 d</span>
                            <span class="price-original">120.000 d</span>
                            <span class="price-pct">-18%</span>
                        </div>
                    </div>
                    <div class="product-footer">
                        <div class="product-unit"><i class="fa-solid fa-scale-balanced"></i> Con 100 kg</div>
                        <button class="btn-cart"><i class="fa-solid fa-plus"></i> Thêm</button>
                    </div>
                </div>

                <!-- Product 2 -->
                <div class="product-card">
                    <div class="product-image-wrap">
                        <div class="product-emoji">🍇</div>
                        <div class="product-badge badge-sale">-17%</div>
                        <button class="product-wishlist"><i class="fa-regular fa-heart"></i></button>
                    </div>
                    <div class="product-info">
                        <div class="product-category">Nhập Khẩu</div>
                        <div class="product-name">Nho Úc Không Hạt Tươi</div>
                        <div class="product-rating">
                            <div class="stars">
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                <i class="fa-solid fa-star-half-stroke"></i>
                            </div>
                            <span class="rating-count">4.7 (89)</span>
                        </div>
                        <div class="product-price">
                            <span class="price-current">150.000 d</span>
                            <span class="price-original">180.000 d</span>
                            <span class="price-pct">-17%</span>
                        </div>
                    </div>
                    <div class="product-footer">
                        <div class="product-unit"><i class="fa-solid fa-scale-balanced"></i> Con 80 kg</div>
                        <button class="btn-cart"><i class="fa-solid fa-plus"></i> Thêm</button>
                    </div>
                </div>

                <!-- Product 3 -->
                <div class="product-card">
                    <div class="product-image-wrap">
                        <div class="product-emoji">🥭</div>
                        <div class="product-badge badge-new">Mới</div>
                        <button class="product-wishlist"><i class="fa-regular fa-heart"></i></button>
                    </div>
                    <div class="product-info">
                        <div class="product-category">Noi Dia</div>
                        <div class="product-name">Xoài Cát Hòa Lộc Đặc Sản</div>
                        <div class="product-rating">
                            <div class="stars">
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                <i class="fa-solid fa-star"></i>
                            </div>
                            <span class="rating-count">5.0 (201)</span>
                        </div>
                        <div class="product-price">
                            <span class="price-current">65.000 d</span>
                        </div>
                    </div>
                    <div class="product-footer">
                        <div class="product-unit"><i class="fa-solid fa-scale-balanced"></i> Con 150 kg</div>
                        <button class="btn-cart"><i class="fa-solid fa-plus"></i> Thêm</button>
                    </div>
                </div>

                <!-- Product 4 -->
                <div class="product-card">
                    <div class="product-image-wrap">
                        <div class="product-emoji">🍊</div>
                        <div class="product-badge badge-organic">Huu Co</div>
                        <button class="product-wishlist"><i class="fa-regular fa-heart"></i></button>
                    </div>
                    <div class="product-info">
                        <div class="product-category">Huu Co</div>
                        <div class="product-name">Cam Hữu Cơ Đà Lạt Tươi</div>
                        <div class="product-rating">
                            <div class="stars">
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                <i class="fa-regular fa-star empty"></i>
                            </div>
                            <span class="rating-count">4.2 (67)</span>
                        </div>
                        <div class="product-price">
                            <span class="price-current">45.000 d</span>
                            <span class="price-original">55.000 d</span>
                            <span class="price-pct">-18%</span>
                        </div>
                    </div>
                    <div class="product-footer">
                        <div class="product-unit"><i class="fa-solid fa-scale-balanced"></i> Con 120 kg</div>
                        <button class="btn-cart"><i class="fa-solid fa-plus"></i> Thêm</button>
                    </div>
                </div>

                <!-- Product 5 -->
                <div class="product-card">
                    <div class="product-image-wrap">
                        <div class="product-emoji">🍑</div>
                        <div class="product-badge badge-hot">Hot</div>
                        <button class="product-wishlist"><i class="fa-regular fa-heart"></i></button>
                    </div>
                    <div class="product-info">
                        <div class="product-category">Nhập Khẩu</div>
                        <div class="product-name">Đào Mỹ Vàng Giòn Ngọt</div>
                        <div class="product-rating">
                            <div class="stars">
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                <i class="fa-solid fa-star-half-stroke"></i>
                            </div>
                            <span class="rating-count">4.6 (45)</span>
                        </div>
                        <div class="product-price">
                            <span class="price-current">135.000 d</span>
                        </div>
                    </div>
                    <div class="product-footer">
                        <div class="product-unit"><i class="fa-solid fa-scale-balanced"></i> Con 60 kg</div>
                        <button class="btn-cart"><i class="fa-solid fa-plus"></i> Thêm</button>
                    </div>
                </div>

                <!-- Product 6 - Out of stock -->
                <div class="product-card out-of-stock">
                    <div class="product-image-wrap">
                        <div class="product-emoji">🍈</div>
                        <button class="product-wishlist"><i class="fa-regular fa-heart"></i></button>
                    </div>
                    <div class="product-info">
                        <div class="product-category">Cao Cap</div>
                        <div class="product-name">Sầu Riêng Musang King</div>
                        <div class="product-rating">
                            <div class="stars">
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                <i class="fa-solid fa-star"></i>
                            </div>
                            <span class="rating-count">4.9 (310)</span>
                        </div>
                        <div class="product-price">
                            <span class="price-current">320.000 d</span>
                            <span class="price-original">350.000 d</span>
                        </div>
                    </div>
                    <div class="product-footer">
                        <div class="product-unit" style="color:var(--orange);"><i class="fa-solid fa-circle-xmark"></i> Hết hàng</div>
                        <button class="btn-cart" disabled><i class="fa-solid fa-ban"></i> Het</button>
                    </div>
                </div>

            </div><!-- /products-grid -->

            <!-- Pagination -->
            <div class="pagination">
                <button class="page-btn" disabled><i class="fa-solid fa-chevron-left"></i></button>
                <button class="page-btn active">1</button>
                <button class="page-btn">2</button>
                <button class="page-btn">3</button>
                <span style="color:var(--gray-400);font-size:0.85rem;padding:0 0.3rem;">...</span>
                <button class="page-btn">8</button>
                <button class="page-btn"><i class="fa-solid fa-chevron-right"></i></button>
            </div>
        </div>
    </div><!-- /shop-layout -->

    <!-- ──── BEST SELLERS ──── -->
    <div class="section-head">
        <div class="section-title">
            <span class="title-icon-orange">🏆</span>
            Bán Chạy Nhất
        </div>
        <a href="#" class="see-all">Xem tất cả <i class="fa-solid fa-arrow-right"></i></a>
    </div>

    <div class="bestsellers-grid">
        <div class="bestseller-card">
            <div class="rank-badge rank-1">1</div>
            <div class="bs-emoji">🥭</div>
            <div class="bs-name">Xoai Cat Hoa Loc</div>
            <div class="bs-sold">Bán: 1.240 kg</div>
            <div class="bs-price">65.000 d/kg</div>
        </div>
        <div class="bestseller-card">
            <div class="rank-badge rank-2">2</div>
            <div class="bs-emoji">🍎</div>
            <div class="bs-name">Tao My Fuji</div>
            <div class="bs-sold">Bán: 980 kg</div>
            <div class="bs-price">99.000 d/kg</div>
        </div>
        <div class="bestseller-card">
            <div class="rank-badge rank-3">3</div>
            <div class="bs-emoji">🍊</div>
            <div class="bs-name">Cam Huu Co Da Lat</div>
            <div class="bs-sold">Bán: 756 kg</div>
            <div class="bs-price">45.000 d/kg</div>
        </div>
        <div class="bestseller-card">
            <div class="rank-badge rank-n">4</div>
            <div class="bs-emoji">🍇</div>
            <div class="bs-name">Nho Uc Khong Hat</div>
            <div class="bs-sold">Bán: 612 kg</div>
            <div class="bs-price">150.000 d/kg</div>
        </div>
        <div class="bestseller-card">
            <div class="rank-badge rank-n">5</div>
            <div class="bs-emoji">🍑</div>
            <div class="bs-name">Dao My Vang</div>
            <div class="bs-sold">Bán: 430 kg</div>
            <div class="bs-price">135.000 d/kg</div>
        </div>
    </div>

    <!-- ──── BLOGS ──── -->
    <div class="section-head">
        <div class="section-title">
            <span class="title-icon-blue">📖</span>
            Bài Viết Nổi Bật
        </div>
        <a href="#" class="see-all">Xem tất cả <i class="fa-solid fa-arrow-right"></i></a>
    </div>

    <div class="blog-grid">
        <div class="blog-card">
            <div class="blog-thumb blog-thumb-1">🍎🥝🍓</div>
            <div class="blog-info">
                <div class="blog-tag">Sức Khỏe</div>
                <div class="blog-title">5 Loại Trái Cây Tốt Nhất Cho Sức Khỏe</div>
                <div class="blog-desc">Khám phá những loại trái cây bổ dưỡng nhất bạn nên ăn mỗi ngày để tăng cường sức đề kháng và năng lượng.</div>
            </div>
            <div class="blog-footer">
                <span><i class="fa-regular fa-calendar" style="margin-right:0.3rem;"></i> 20/05/2024</span>
                <span><i class="fa-regular fa-eye" style="margin-right:0.3rem;"></i> 2.4k lượt xem</span>
            </div>
        </div>
        <div class="blog-card">
            <div class="blog-thumb blog-thumb-2">🥭🍊🍋</div>
            <div class="blog-info">
                <div class="blog-tag">Mẹo Hay</div>
                <div class="blog-title">Hướng Dẫn Bảo Quản Trái Cây Đúng Cách</div>
                <div class="blog-desc">Mẹo hay để giữ trái cây tươi lâu hơn trong tủ lạnh và nhiệt độ phòng, giúp tiết kiệm chi phí mua sắm.</div>
            </div>
            <div class="blog-footer">
                <span><i class="fa-regular fa-calendar" style="margin-right:0.3rem;"></i> 18/05/2024</span>
                <span><i class="fa-regular fa-eye" style="margin-right:0.3rem;"></i> 1.8k lượt xem</span>
            </div>
        </div>
        <div class="blog-card">
            <div class="blog-thumb blog-thumb-3">🌿🍏🫐</div>
            <div class="blog-info">
                <div class="blog-tag">Kiến Thức</div>
                <div class="blog-title">Phan Biet Trái Cây Hữu Cơ Va Thuong Thuong</div>
                <div class="blog-desc">Nhung diem khac biet quan trong giup ban chon duoc sản phẩm huu co that su, an toan cho gia dinh.</div>
            </div>
            <div class="blog-footer">
                <span><i class="fa-regular fa-calendar" style="margin-right:0.3rem;"></i> 15/05/2024</span>
                <span><i class="fa-regular fa-eye" style="margin-right:0.3rem;"></i> 1.2k lượt xem</span>
            </div>
        </div>
    </div>

</div><!-- /page-wrap -->

<!-- ====================================================== FOOTER -->
<footer>
    <div class="footer-top" style="max-width:1280px;margin:0 auto;">
        <div class="footer-brand">
            <a href="#" class="footer-logo"><i class="fa-solid fa-apple-whole"></i> Sena Shop</a>
            <p class="footer-desc">Chuyên cung cấp trái cây tươi ngon, chất lượng cao từ các vườn trồng uy tín trong nước và quốc tế. Giao hàng tận nơi, uy tín hàng đầu.</p>
            <div class="footer-socials">
                <a href="#" class="social-btn"><i class="fa-brands fa-facebook-f"></i></a>
                <a href="#" class="social-btn"><i class="fa-brands fa-instagram"></i></a>
                <a href="#" class="social-btn"><i class="fa-brands fa-tiktok"></i></a>
                <a href="#" class="social-btn"><i class="fa-brands fa-youtube"></i></a>
            </div>
        </div>
        <div class="footer-col">
            <h4>San Pham</h4>
            <ul>
                <li><a href="#">Trái Cây Nhập Khẩu</a></li>
                <li><a href="#">Trái Cây Nội Địa</a></li>
                <li><a href="#">Trái Cây Hữu Cơ</a></li>
                <li><a href="#">Trái Cây Cao Cấp</a></li>
                <li><a href="#">San Pham Hot</a></li>
            </ul>
        </div>
        <div class="footer-col">
            <h4>Hỗ Trợ</h4>
            <ul>
                <li><a href="#">Chính Sách Đổi Trả</a></li>
                <li><a href="#">Chính Sách Giao Hàng</a></li>
                <li><a href="#">Hướng Dẫn Đặt Hàng</a></li>
                <li><a href="#">Câu Hỏi Thường Gặp</a></li>
            </ul>
        </div>
        <div class="footer-col">
            <h4>Liên Hệ</h4>
            <ul>
                <li><a href="#"><i class="fa-solid fa-phone" style="width:14px;"></i> 1800 xxxx</a></li>
                <li><a href="#"><i class="fa-regular fa-envelope" style="width:14px;"></i> senashop@gmail.com</a></li>
                <li><a href="#"><i class="fa-solid fa-location-dot" style="width:14px;"></i> Ha Noi, Viet Nam</a></li>
            </ul>
        </div>
    </div>
    <div class="footer-bottom" style="max-width:1280px;margin:0 auto;">
        <span>&copy; 2024 Sena Shop. Trái cây tươi ngon mỗi ngày.</span>
        <div class="footer-bottom-links">
            <a href="#">Privacy</a>
            <a href="#">Terms</a>
            <a href="#">Sitemap</a>
        </div>
    </div>
</footer>

<script>
    // ── Slider ──
    var currentSlide = 0;
    var totalSlides  = 3;
    var autoSlide;

    function updateSlider() {
        document.getElementById('sliderTrack').style.transform = 'translateX(-' + (currentSlide * 100) + '%)';
        document.querySelectorAll('.dot').forEach(function(d, i) {
            d.classList.toggle('active', i === currentSlide);
        });
    }

    function changeSlide(dir) {
        currentSlide = (currentSlide + dir + totalSlides) % totalSlides;
        updateSlider();
        resetAuto();
    }

    function goSlide(idx) {
        currentSlide = idx;
        updateSlider();
        resetAuto();
    }

    function resetAuto() {
        clearInterval(autoSlide);
        autoSlide = setInterval(function() { changeSlide(1); }, 5000);
    }

    autoSlide = setInterval(function() { changeSlide(1); }, 5000);

    // ── Sort tabs ──
    document.querySelectorAll('.sort-tab').forEach(function(btn) {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.sort-tab').forEach(function(b) { b.classList.remove('active'); });
            btn.classList.add('active');
        });
    });

    // ── Category cards ──
    document.querySelectorAll('.category-card').forEach(function(card) {
        card.addEventListener('click', function(e) {
            e.preventDefault();
            document.querySelectorAll('.category-card').forEach(function(c) { c.classList.remove('active'); });
            card.classList.add('active');
        });
    });

    // ── Go to Profile tab ──
    function goToProfile() {
        localStorage.setItem('senaPanel', 'profile');
        window.location.href = 'profile';
    }

    // ── Go to Security tab ──
    function goToSecurity() {
        localStorage.setItem('senaPanel', 'security');
        window.location.href = 'profile';
    }
</script>

</body>
</html>
