<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="model.User" %>
<%@ page import="model.Product" %>
<%@ page import="model.Cart" %>
<%@ page import="java.util.List" %>
<%@ page import="dao.ProductDAO" %>
<%@ page import="Utils.ProductSorter" %>
<% 
    User user = (User) session.getAttribute("user"); 
    Cart cart = (Cart) session.getAttribute("cart");
    int cartCount = cart != null ? cart.getTotalQuantity() : 0;
    ProductDAO dao = new ProductDAO();
    List<Product> productsList = dao.getAllProducts();
    String sort = request.getParameter("sort");
    if (sort != null) {
        ProductSorter.sortProducts(productsList, sort);
    }
%>
<!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Sena Shop - Trái Cây Tươi Ngon Mỗi Ngày</title>
                <link
                    href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap"
                    rel="stylesheet">
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
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
                        --green-deep: #2e7d32;
                        --orange: #ff7043;
                        --orange-light: #fff3e0;
                        --yellow: #ffc107;
                        --bg: #f5f7f5;
                        --white: #ffffff;
                        --gray-50: #f8fafb;
                        --gray-100: #eef1ee;
                        --gray-200: #dde5dd;
                        --gray-400: #9aaa9a;
                        --gray-600: #5a6a5a;
                        --gray-800: #1e2b1e;
                        --shadow-sm: 0 1px 4px rgba(0, 0, 0, .07);
                        --shadow: 0 4px 16px rgba(0, 0, 0, .09);
                        --shadow-md: 0 8px 30px rgba(0, 0, 0, .12);
                        --radius: 16px;
                        --radius-sm: 10px;
                        --radius-xs: 6px;
                    }

                    html {
                        scroll-behavior: smooth;
                    }

                    body {
                        font-family: 'Inter', sans-serif;
                        background: var(--bg);
                        color: var(--gray-800);
                        min-height: 100vh;
                        display: flex;
                        flex-direction: column;
                    }

                    /* ======================================================
           TOPNAV
        ====================================================== */
                    .topnav {
                        background: var(--white);
                        border-bottom: 1px solid var(--gray-200);
                        height: 64px;
                        display: flex;
                        align-items: center;
                        padding: 0 2.5rem;
                        gap: 2rem;
                        position: sticky;
                        top: 0;
                        z-index: 200;
                        box-shadow: var(--shadow-sm);
                    }

                    .nav-logo {
                        display: flex;
                        align-items: center;
                        gap: 0.5rem;
                        font-size: 1.4rem;
                        font-weight: 800;
                        color: var(--green-deep);
                        text-decoration: none;
                        white-space: nowrap;
                        letter-spacing: -0.02em;
                    }

                    .nav-logo i {
                        color: var(--green);
                        font-size: 1.2rem;
                    }

                    .nav-search {
                        flex: 1;
                        max-width: 440px;
                        position: relative;
                    }

                    .nav-search input {
                        width: 100%;
                        height: 40px;
                        border: 1.5px solid var(--gray-200);
                        border-radius: 100px;
                        padding: 0 1rem 0 2.8rem;
                        font-size: 0.875rem;
                        font-family: 'Inter', sans-serif;
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

                    .nav-links {
                        display: flex;
                        gap: 0.25rem;
                    }

                    .nav-links a {
                        padding: 0.4rem 0.85rem;
                        border-radius: var(--radius-xs);
                        font-size: 0.875rem;
                        font-weight: 500;
                        color: var(--gray-600);
                        text-decoration: none;
                        transition: all 0.15s;
                        white-space: nowrap;
                    }

                    .nav-links a:hover {
                        background: var(--green-light);
                        color: var(--green-dark);
                    }

                    .nav-links a.active {
                        background: var(--green-light);
                        color: var(--green-dark);
                        font-weight: 600;
                    }

                    .nav-right {
                        margin-left: auto;
                        display: flex;
                        align-items: center;
                        gap: 0.75rem;
                    }

                    .nav-icon-btn {
                        width: 40px;
                        height: 40px;
                        border-radius: 50%;
                        background: var(--gray-100);
                        border: none;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: var(--gray-600);
                        cursor: pointer;
                        font-size: 1rem;
                        transition: all 0.15s;
                        position: relative;
                    }

                    .nav-icon-btn:hover {
                        background: var(--green-light);
                        color: var(--green-dark);
                    }

                    .cart-badge {
                        position: absolute;
                        top: -3px;
                        right: -3px;
                        width: 18px;
                        height: 18px;
                        background: var(--orange);
                        color: #fff;
                        border-radius: 50%;
                        font-size: 0.62rem;
                        font-weight: 700;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                    }

                    .nav-avatar {
                        width: 38px;
                        height: 38px;
                        border-radius: 50%;
                        object-fit: cover;
                        border: 2px solid var(--green);
                        cursor: pointer;
                        display: block;
                    }

                    /* Avatar dropdown */
                    .avatar-wrap {
                        position: relative;
                        /* Bridge padding prevents gap between avatar and dropdown */
                        padding-bottom: 10px;
                    }

                    .avatar-dropdown {
                        display: none;
                        position: absolute;
                        top: 100%;
                        right: 0;
                        padding-top: 10px;
                        background: transparent;
                        z-index: 999;
                    }

                    .avatar-dropdown-inner {
                        background: var(--white);
                        border: 1px solid var(--gray-200);
                        border-radius: var(--radius-sm);
                        box-shadow: var(--shadow-md);
                        min-width: 190px;
                        overflow: hidden;
                        animation: dropDown 0.18s ease;
                    }

                    @keyframes dropDown {
                        from {
                            opacity: 0;
                            transform: translateY(-6px);
                        }

                        to {
                            opacity: 1;
                            transform: translateY(0);
                        }
                    }

                    .avatar-wrap:hover .avatar-dropdown {
                        display: block;
                    }

                    .dropdown-header {
                        padding: 0.85rem 1rem;
                        border-bottom: 1px solid var(--gray-100);
                        background: var(--gray-50);
                    }

                    .dropdown-header strong {
                        display: block;
                        font-size: 0.875rem;
                        font-weight: 700;
                        color: var(--gray-800);
                    }

                    .dropdown-header span {
                        font-size: 0.75rem;
                        color: var(--gray-400);
                    }

                    .dropdown-menu {
                        padding: 0.4rem 0;
                    }

                    .dropdown-item {
                        display: flex;
                        align-items: center;
                        gap: 0.65rem;
                        padding: 0.6rem 1rem;
                        font-size: 0.855rem;
                        font-weight: 500;
                        color: var(--gray-600);
                        text-decoration: none;
                        transition: all 0.15s;
                        cursor: pointer;
                    }

                    .dropdown-item:hover {
                        background: var(--green-light);
                        color: var(--green-dark);
                    }

                    .dropdown-item i {
                        width: 16px;
                        text-align: center;
                        color: var(--green);
                        font-size: 0.85rem;
                    }

                    .dropdown-item.danger {
                        color: #e53935;
                    }

                    .dropdown-item.danger i {
                        color: #e53935;
                    }

                    .dropdown-item.danger:hover {
                        background: #fee2e2;
                    }

                    .dropdown-divider {
                        height: 1px;
                        background: var(--gray-100);
                        margin: 0.3rem 0;
                    }

                    /* ======================================================
           HERO SLIDER
        ====================================================== */
                    .hero {
                        position: relative;
                        overflow: hidden;
                        height: 440px;
                    }

                    .slider-track {
                        display: flex;
                        transition: transform 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94);
                    }

                    .slide {
                        min-width: 100%;
                        height: 440px;
                        display: flex;
                        align-items: center;
                        padding: 0 10%;
                        position: relative;
                        overflow: hidden;
                    }

                    .slide-1 {
                        background: linear-gradient(120deg, #1b5e20 0%, #2e7d32 40%, #43a047 70%, #66bb6a 100%);
                    }

                    .slide-2 {
                        background: linear-gradient(120deg, #e65100 0%, #ef6c00 40%, #f57c00 70%, #ffa726 100%);
                    }

                    .slide-3 {
                        background: linear-gradient(120deg, #6a1b9a 0%, #7b1fa2 40%, #9c27b0 70%, #ce93d8 100%);
                    }

                    .slide-decor {
                        position: absolute;
                        border-radius: 50%;
                        opacity: 0.1;
                    }

                    .slide-decor-1 {
                        width: 350px;
                        height: 350px;
                        background: #fff;
                        top: -80px;
                        right: 15%;
                    }

                    .slide-decor-2 {
                        width: 200px;
                        height: 200px;
                        background: #fff;
                        bottom: -60px;
                        right: 30%;
                    }

                    .slide-content {
                        position: relative;
                        z-index: 2;
                        max-width: 520px;
                    }

                    .slide-tag {
                        display: inline-flex;
                        align-items: center;
                        gap: 0.4rem;
                        background: rgba(255, 255, 255, 0.2);
                        color: #fff;
                        border: 1px solid rgba(255, 255, 255, 0.3);
                        border-radius: 100px;
                        padding: 0.3rem 0.9rem;
                        font-size: 0.75rem;
                        font-weight: 700;
                        text-transform: uppercase;
                        letter-spacing: 0.07em;
                        margin-bottom: 1rem;
                        backdrop-filter: blur(8px);
                    }

                    .slide-title {
                        font-size: 3rem;
                        font-weight: 900;
                        color: #fff;
                        line-height: 1.05;
                        letter-spacing: -0.03em;
                        margin-bottom: 0.75rem;
                    }

                    .slide-sub {
                        font-size: 1rem;
                        color: rgba(255, 255, 255, 0.8);
                        margin-bottom: 1.75rem;
                        line-height: 1.5;
                    }

                    .slide-actions {
                        display: flex;
                        gap: 1rem;
                        align-items: center;
                    }

                    .slide-emoji {
                        position: absolute;
                        right: 12%;
                        font-size: 9rem;
                        bottom: -10px;
                        filter: drop-shadow(0 10px 30px rgba(0, 0, 0, 0.3));
                        animation: float 4s ease-in-out infinite;
                        z-index: 2;
                    }

                    @keyframes float {

                        0%,
                        100% {
                            transform: translateY(0);
                        }

                        50% {
                            transform: translateY(-16px);
                        }
                    }

                    .slider-dots {
                        position: absolute;
                        bottom: 1.25rem;
                        left: 50%;
                        transform: translateX(-50%);
                        display: flex;
                        gap: 0.5rem;
                        z-index: 10;
                    }

                    .dot {
                        width: 8px;
                        height: 8px;
                        border-radius: 50%;
                        background: rgba(255, 255, 255, 0.5);
                        cursor: pointer;
                        transition: all 0.3s;
                    }

                    .dot.active {
                        width: 24px;
                        border-radius: 4px;
                        background: #fff;
                    }

                    .slider-arrow {
                        position: absolute;
                        top: 50%;
                        transform: translateY(-50%);
                        z-index: 10;
                        width: 44px;
                        height: 44px;
                        border-radius: 50%;
                        background: rgba(255, 255, 255, 0.2);
                        border: 1.5px solid rgba(255, 255, 255, 0.3);
                        color: #fff;
                        font-size: 0.95rem;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        cursor: pointer;
                        backdrop-filter: blur(8px);
                        transition: all 0.2s;
                    }

                    .slider-arrow:hover {
                        background: rgba(255, 255, 255, 0.35);
                    }

                    .slider-arrow.prev {
                        left: 1.5rem;
                    }

                    .slider-arrow.next {
                        right: 1.5rem;
                    }

                    /* ======================================================
           MAIN WRAPPER
        ====================================================== */
                    .page-wrap {
                        max-width: 1280px;
                        width: 100%;
                        margin: 0 auto;
                        padding: 2rem 1.5rem;
                        flex: 1;
                    }

                    /* ======================================================
           SECTION HEADING
        ====================================================== */
                    .section-head {
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        margin-bottom: 1.25rem;
                    }

                    .section-title {
                        display: flex;
                        align-items: center;
                        gap: 0.6rem;
                        font-size: 1.25rem;
                        font-weight: 800;
                        color: var(--gray-800);
                        letter-spacing: -0.01em;
                    }

                    .section-title span {
                        display: inline-flex;
                        align-items: center;
                        justify-content: center;
                        width: 32px;
                        height: 32px;
                        border-radius: 8px;
                        font-size: 1rem;
                    }

                    .title-icon-green {
                        background: var(--green-light);
                    }

                    .title-icon-orange {
                        background: #fff3e0;
                    }

                    .title-icon-yellow {
                        background: #fffde7;
                    }

                    .title-icon-blue {
                        background: #e3f2fd;
                    }

                    .see-all {
                        font-size: 0.84rem;
                        font-weight: 600;
                        color: var(--green-dark);
                        text-decoration: none;
                        display: flex;
                        align-items: center;
                        gap: 0.3rem;
                        transition: gap 0.2s;
                    }

                    .see-all:hover {
                        gap: 0.55rem;
                    }

                    /* ======================================================
           CATEGORIES
        ====================================================== */
                    .categories-grid {
                        display: grid;
                        grid-template-columns: repeat(4, 1fr);
                        gap: 1rem;
                        margin-bottom: 2.5rem;
                    }

                    .category-card {
                        background: var(--white);
                        border: 1.5px solid var(--gray-200);
                        border-radius: var(--radius);
                        padding: 1.5rem 1rem;
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        gap: 0.75rem;
                        cursor: pointer;
                        transition: all 0.22s ease;
                        text-decoration: none;
                    }

                    .category-card:hover {
                        border-color: var(--green);
                        box-shadow: var(--shadow);
                        transform: translateY(-3px);
                    }

                    .category-card.active {
                        border-color: var(--green);
                        background: var(--green-light);
                    }

                    .cat-emoji {
                        font-size: 2.8rem;
                        line-height: 1;
                        filter: drop-shadow(0 3px 6px rgba(0, 0, 0, 0.12));
                    }

                    .cat-name {
                        font-size: 0.9rem;
                        font-weight: 700;
                        color: var(--gray-800);
                        text-align: center;
                    }

                    .cat-count {
                        font-size: 0.75rem;
                        color: var(--gray-400);
                        background: var(--gray-100);
                        border-radius: 100px;
                        padding: 0.15rem 0.6rem;
                        font-weight: 500;
                    }

                    /* ======================================================
           FILTER + PRODUCT LAYOUT
        ====================================================== */
                    .shop-layout {
                        display: grid;
                        grid-template-columns: 240px 1fr;
                        gap: 1.5rem;
                        margin-bottom: 2.5rem;
                    }

                    /* Sidebar filter */
                    .filter-sidebar {
                        display: flex;
                        flex-direction: column;
                        gap: 1rem;
                    }

                    .filter-card {
                        background: var(--white);
                        border: 1px solid var(--gray-200);
                        border-radius: var(--radius-sm);
                        overflow: hidden;
                        box-shadow: var(--shadow-sm);
                    }

                    .filter-header {
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        padding: 0.9rem 1.1rem;
                        border-bottom: 1px solid var(--gray-100);
                    }

                    .filter-title {
                        font-size: 0.85rem;
                        font-weight: 700;
                        color: var(--gray-800);
                        display: flex;
                        align-items: center;
                        gap: 0.4rem;
                    }

                    .filter-title i {
                        color: var(--green);
                        font-size: 0.8rem;
                    }

                    .filter-body {
                        padding: 0.9rem 1.1rem;
                    }

                    /* Category filter */
                    .filter-check {
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        padding: 0.4rem 0;
                        cursor: pointer;
                    }

                    .filter-check-left {
                        display: flex;
                        align-items: center;
                        gap: 0.55rem;
                    }

                    .check-box {
                        width: 17px;
                        height: 17px;
                        border: 2px solid var(--gray-200);
                        border-radius: 4px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        transition: all 0.15s;
                        flex-shrink: 0;
                    }

                    .check-box.checked {
                        background: var(--green);
                        border-color: var(--green);
                    }

                    .check-box.checked::after {
                        content: '';
                        width: 8px;
                        height: 5px;
                        border-left: 2px solid #fff;
                        border-bottom: 2px solid #fff;
                        transform: rotate(-45deg) translate(1px, -1px);
                    }

                    .check-label {
                        font-size: 0.84rem;
                        color: var(--gray-600);
                        font-weight: 500;
                    }

                    .check-num {
                        font-size: 0.72rem;
                        color: var(--gray-400);
                        background: var(--gray-100);
                        border-radius: 100px;
                        padding: 0.1rem 0.45rem;
                    }

                    /* Price range */
                    .price-inputs {
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                        gap: 0.5rem;
                        margin-bottom: 0.75rem;
                    }

                    .price-input {
                        background: var(--gray-50);
                        border: 1.5px solid var(--gray-200);
                        border-radius: var(--radius-xs);
                        padding: 0.5rem 0.65rem;
                        font-size: 0.8rem;
                        font-family: 'Inter', sans-serif;
                        color: var(--gray-800);
                        outline: none;
                        width: 100%;
                        transition: border-color 0.15s;
                    }

                    .price-input:focus {
                        border-color: var(--green);
                    }

                    /* Rating filter */
                    .rating-row {
                        display: flex;
                        align-items: center;
                        gap: 0.5rem;
                        padding: 0.35rem 0;
                        cursor: pointer;
                    }

                    .stars-static {
                        display: flex;
                        gap: 1px;
                    }

                    .stars-static i {
                        font-size: 0.78rem;
                        color: var(--yellow);
                    }

                    .stars-static i.empty {
                        color: var(--gray-200);
                    }

                    .rating-label {
                        font-size: 0.82rem;
                        color: var(--gray-600);
                    }

                    /* Sort bar */
                    .sort-bar {
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        background: var(--white);
                        border: 1px solid var(--gray-200);
                        border-radius: var(--radius-sm);
                        padding: 0.7rem 1.1rem;
                        margin-bottom: 1rem;
                        box-shadow: var(--shadow-sm);
                    }

                    .sort-bar-left {
                        font-size: 0.84rem;
                        color: var(--gray-600);
                    }

                    .sort-bar-left strong {
                        color: var(--gray-800);
                    }

                    .sort-tabs {
                        display: flex;
                        gap: 0.35rem;
                        align-items: center;
                    }

                    .sort-tab {
                        padding: 0.35rem 0.85rem;
                        border-radius: 100px;
                        font-size: 0.8rem;
                        font-weight: 500;
                        color: var(--gray-600);
                        cursor: pointer;
                        border: 1px solid transparent;
                        transition: all 0.15s;
                        background: transparent;
                        font-family: 'Inter', sans-serif;
                    }

                    .sort-tab:hover {
                        background: var(--green-light);
                        color: var(--green-dark);
                    }

                    .sort-tab.active {
                        background: var(--green);
                        color: #fff;
                        border-color: var(--green);
                        font-weight: 600;
                    }

                    /* ======================================================
           PRODUCT GRID
        ====================================================== */
                    .products-area {
                        display: flex;
                        flex-direction: column;
                        gap: 1rem;
                    }

                    .products-grid {
                        display: grid;
                        grid-template-columns: repeat(3, 1fr);
                        gap: 1rem;
                    }

                    .product-card {
                        background: var(--white);
                        border: 1.5px solid var(--gray-200);
                        border-radius: var(--radius);
                        overflow: hidden;
                        cursor: pointer;
                        transition: all 0.22s ease;
                        position: relative;
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
                        filter: drop-shadow(0 6px 12px rgba(0, 0, 0, 0.12));
                        transition: transform 0.3s ease;
                    }

                    .product-card:hover .product-emoji {
                        transform: scale(1.08) rotate(-3deg);
                    }

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

                    .badge-sale {
                        background: var(--orange);
                        color: #fff;
                    }

                    .badge-new {
                        background: #1565c0;
                        color: #fff;
                    }

                    .badge-hot {
                        background: #c62828;
                        color: #fff;
                    }

                    .badge-organic {
                        background: var(--green-deep);
                        color: #fff;
                    }

                    .product-wishlist {
                        position: absolute;
                        top: 0.75rem;
                        right: 0.75rem;
                        width: 32px;
                        height: 32px;
                        border-radius: 50%;
                        background: rgba(255, 255, 255, 0.9);
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

                    .product-wishlist:hover {
                        color: #e53935;
                        background: #fff;
                    }

                    .product-info {
                        padding: 1rem;
                        flex: 1;
                        display: flex;
                        flex-direction: column;
                        gap: 0.4rem;
                    }

                    .product-category {
                        font-size: 0.7rem;
                        color: var(--green-dark);
                        font-weight: 600;
                        text-transform: uppercase;
                        letter-spacing: 0.05em;
                    }

                    .product-name {
                        font-size: 0.95rem;
                        font-weight: 700;
                        color: var(--gray-800);
                        line-height: 1.3;
                    }

                    .product-rating {
                        display: flex;
                        align-items: center;
                        gap: 0.35rem;
                    }

                    .stars {
                        display: flex;
                        gap: 1px;
                    }

                    .stars i {
                        font-size: 0.72rem;
                        color: var(--yellow);
                    }

                    .stars i.half {
                        color: var(--yellow);
                    }

                    .stars i.empty {
                        color: var(--gray-200);
                    }

                    .rating-count {
                        font-size: 0.73rem;
                        color: var(--gray-400);
                    }

                    .product-price {
                        display: flex;
                        align-items: center;
                        gap: 0.5rem;
                        margin-top: auto;
                    }

                    .price-current {
                        font-size: 1.1rem;
                        font-weight: 800;
                        color: var(--green-dark);
                    }

                    .price-original {
                        font-size: 0.82rem;
                        color: var(--gray-400);
                        text-decoration: line-through;
                    }

                    .price-pct {
                        font-size: 0.7rem;
                        font-weight: 700;
                        color: var(--orange);
                        background: var(--orange-light);
                        padding: 0.1rem 0.4rem;
                        border-radius: 100px;
                    }

                    .product-footer {
                        padding: 0.75rem 1rem;
                        border-top: 1px solid var(--gray-100);
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        gap: 0.5rem;
                    }

                    .product-unit {
                        font-size: 0.75rem;
                        color: var(--gray-400);
                        display: flex;
                        align-items: center;
                        gap: 0.3rem;
                    }

                    .btn-cart {
                        display: inline-flex;
                        align-items: center;
                        gap: 0.4rem;
                        padding: 0.45rem 0.9rem;
                        background: var(--green);
                        color: #fff;
                        border: none;
                        border-radius: 100px;
                        font-size: 0.8rem;
                        font-weight: 600;
                        cursor: pointer;
                        font-family: 'Inter', sans-serif;
                        transition: all 0.18s;
                    }

                    .btn-cart:hover {
                        background: var(--green-dark);
                        transform: scale(1.04);
                    }

                    /* Out of stock overlay */
                    .out-of-stock .product-image-wrap::after {
                        content: 'Het Hang';
                        position: absolute;
                        inset: 0;
                        background: rgba(0, 0, 0, 0.42);
                        color: #fff;
                        font-size: 0.9rem;
                        font-weight: 700;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        letter-spacing: 0.05em;
                    }

                    .out-of-stock .btn-cart {
                        background: var(--gray-200);
                        color: var(--gray-400);
                        cursor: not-allowed;
                    }

                    /* Pagination */
                    .pagination {
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        gap: 0.4rem;
                        margin-top: 1.5rem;
                    }

                    .page-btn {
                        width: 36px;
                        height: 36px;
                        border-radius: 8px;
                        border: 1.5px solid var(--gray-200);
                        background: var(--white);
                        color: var(--gray-600);
                        font-size: 0.85rem;
                        font-weight: 500;
                        cursor: pointer;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-family: 'Inter', sans-serif;
                        transition: all 0.15s;
                    }

                    .page-btn:hover {
                        border-color: var(--green);
                        color: var(--green-dark);
                    }

                    .page-btn.active {
                        background: var(--green);
                        border-color: var(--green);
                        color: #fff;
                        font-weight: 700;
                    }

                    .page-btn:disabled {
                        opacity: 0.4;
                        cursor: not-allowed;
                    }

                    /* ======================================================
           BEST SELLERS SECTION
        ====================================================== */
                    .bestsellers-grid {
                        display: grid;
                        grid-template-columns: repeat(5, 1fr);
                        gap: 1rem;
                        margin-bottom: 2.5rem;
                    }

                    .bestseller-card {
                        background: var(--white);
                        border: 1.5px solid var(--gray-200);
                        border-radius: var(--radius-sm);
                        padding: 1rem;
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        gap: 0.5rem;
                        cursor: pointer;
                        text-align: center;
                        position: relative;
                        transition: all 0.2s;
                    }

                    .bestseller-card:hover {
                        border-color: var(--green-mid);
                        box-shadow: var(--shadow);
                        transform: translateY(-2px);
                    }

                    .rank-badge {
                        position: absolute;
                        top: 0.6rem;
                        left: 0.6rem;
                        width: 22px;
                        height: 22px;
                        border-radius: 50%;
                        font-size: 0.68rem;
                        font-weight: 800;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                    }

                    .rank-1 {
                        background: #ffd700;
                        color: #5d4037;
                    }

                    .rank-2 {
                        background: #c0c0c0;
                        color: #37474f;
                    }

                    .rank-3 {
                        background: #cd7f32;
                        color: #fff;
                    }

                    .rank-n {
                        background: var(--gray-100);
                        color: var(--gray-600);
                    }

                    .bs-emoji {
                        font-size: 3.2rem;
                    }

                    .bs-name {
                        font-size: 0.82rem;
                        font-weight: 700;
                        color: var(--gray-800);
                        line-height: 1.3;
                    }

                    .bs-sold {
                        font-size: 0.72rem;
                        color: var(--gray-400);
                    }

                    .bs-price {
                        font-size: 0.9rem;
                        font-weight: 800;
                        color: var(--green-dark);
                    }

                    /* ======================================================
           FEATURED PRODUCTS BANNER
        ====================================================== */
                    .featured-banner {
                        background: linear-gradient(135deg, #1b5e20 0%, #2e7d32 50%, #43a047 100%);
                        border-radius: var(--radius);
                        padding: 2rem 2.5rem;
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        margin-bottom: 1.5rem;
                        position: relative;
                        overflow: hidden;
                    }

                    .featured-banner::before {
                        content: '';
                        position: absolute;
                        top: -60px;
                        right: -60px;
                        width: 250px;
                        height: 250px;
                        border-radius: 50%;
                        background: rgba(255, 255, 255, 0.06);
                    }

                    .featured-banner::after {
                        content: '';
                        position: absolute;
                        bottom: -40px;
                        left: 30%;
                        width: 180px;
                        height: 180px;
                        border-radius: 50%;
                        background: rgba(255, 255, 255, 0.04);
                    }

                    .featured-text {
                        z-index: 2;
                    }

                    .featured-tag {
                        display: inline-flex;
                        align-items: center;
                        gap: 0.35rem;
                        background: rgba(255, 255, 255, 0.15);
                        color: rgba(255, 255, 255, 0.9);
                        border-radius: 100px;
                        padding: 0.25rem 0.8rem;
                        font-size: 0.72rem;
                        font-weight: 700;
                        text-transform: uppercase;
                        letter-spacing: 0.07em;
                        margin-bottom: 0.6rem;
                    }

                    .featured-title {
                        font-size: 1.6rem;
                        font-weight: 800;
                        color: #fff;
                        margin-bottom: 0.4rem;
                    }

                    .featured-sub {
                        font-size: 0.9rem;
                        color: rgba(255, 255, 255, 0.75);
                    }

                    .featured-emojis {
                        display: flex;
                        gap: 0.5rem;
                        font-size: 2.8rem;
                        z-index: 2;
                    }

                    /* ======================================================
           BLOG SECTION
        ====================================================== */
                    .blog-grid {
                        display: grid;
                        grid-template-columns: 1fr 1fr 1fr;
                        gap: 1rem;
                        margin-bottom: 2.5rem;
                    }

                    .blog-card {
                        background: var(--white);
                        border: 1.5px solid var(--gray-200);
                        border-radius: var(--radius);
                        overflow: hidden;
                        cursor: pointer;
                        transition: all 0.2s;
                    }

                    .blog-card:hover {
                        border-color: var(--green-mid);
                        box-shadow: var(--shadow);
                        transform: translateY(-3px);
                    }

                    .blog-thumb {
                        height: 160px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 4.5rem;
                        position: relative;
                    }

                    .blog-thumb-1 {
                        background: linear-gradient(135deg, #e8f5e9, #c8e6c9);
                    }

                    .blog-thumb-2 {
                        background: linear-gradient(135deg, #fff3e0, #ffe0b2);
                    }

                    .blog-thumb-3 {
                        background: linear-gradient(135deg, #e3f2fd, #bbdefb);
                    }

                    .blog-info {
                        padding: 1.1rem;
                    }

                    .blog-tag {
                        display: inline-block;
                        font-size: 0.68rem;
                        font-weight: 700;
                        text-transform: uppercase;
                        letter-spacing: 0.06em;
                        color: var(--green-dark);
                        background: var(--green-light);
                        border-radius: 100px;
                        padding: 0.15rem 0.55rem;
                        margin-bottom: 0.5rem;
                    }

                    .blog-title {
                        font-size: 0.95rem;
                        font-weight: 700;
                        color: var(--gray-800);
                        line-height: 1.35;
                        margin-bottom: 0.4rem;
                    }

                    .blog-desc {
                        font-size: 0.82rem;
                        color: var(--gray-600);
                        line-height: 1.5;
                        display: -webkit-box;
                        -webkit-line-clamp: 2;
                        -webkit-box-orient: vertical;
                        overflow: hidden;
                    }

                    .blog-footer {
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        padding: 0.75rem 1.1rem;
                        border-top: 1px solid var(--gray-100);
                        font-size: 0.75rem;
                        color: var(--gray-400);
                    }

                    /* ======================================================
           INFO SIDEBAR ROW (Voucher banner)
        ====================================================== */
                    .promo-row {
                        display: grid;
                        grid-template-columns: repeat(3, 1fr);
                        gap: 1rem;
                        margin-bottom: 2.5rem;
                    }

                    .promo-card {
                        border-radius: var(--radius-sm);
                        padding: 1.25rem 1.5rem;
                        display: flex;
                        align-items: center;
                        gap: 1rem;
                    }

                    .promo-1 {
                        background: linear-gradient(120deg, #e8f5e9, #f1f8f1);
                        border: 1.5px solid var(--green-mid);
                    }

                    .promo-2 {
                        background: linear-gradient(120deg, #fff3e0, #fff8f1);
                        border: 1.5px solid #ffe0b2;
                    }

                    .promo-3 {
                        background: linear-gradient(120deg, #e3f2fd, #f1f8ff);
                        border: 1.5px solid #bbdefb;
                    }

                    .promo-icon {
                        width: 48px;
                        height: 48px;
                        border-radius: 12px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 1.4rem;
                        flex-shrink: 0;
                    }

                    .promo-1 .promo-icon {
                        background: var(--green-light);
                    }

                    .promo-2 .promo-icon {
                        background: #fff3e0;
                    }

                    .promo-3 .promo-icon {
                        background: #e3f2fd;
                    }

                    .promo-text strong {
                        display: block;
                        font-size: 0.9rem;
                        font-weight: 700;
                        color: var(--gray-800);
                        margin-bottom: 0.15rem;
                    }

                    .promo-text span {
                        font-size: 0.78rem;
                        color: var(--gray-600);
                    }

                    /* ======================================================
           BUTTONS GLOBAL
        ====================================================== */
                    .btn {
                        display: inline-flex;
                        align-items: center;
                        justify-content: center;
                        gap: 0.4rem;
                        padding: 0.65rem 1.4rem;
                        border-radius: var(--radius-sm);
                        font-size: 0.875rem;
                        font-weight: 600;
                        font-family: 'Inter', sans-serif;
                        cursor: pointer;
                        border: none;
                        text-decoration: none;
                        transition: all 0.18s ease;
                    }

                    .btn-white {
                        background: #fff;
                        color: var(--green-dark);
                    }

                    .btn-white:hover {
                        background: var(--green-light);
                    }

                    .btn-white-outline {
                        background: transparent;
                        color: #fff;
                        border: 1.5px solid rgba(255, 255, 255, 0.5);
                    }

                    .btn-white-outline:hover {
                        background: rgba(255, 255, 255, 0.12);
                    }

                    /* ======================================================
           FOOTER
        ====================================================== */
                    footer {
                        background: var(--gray-800);
                        color: rgba(255, 255, 255, 0.7);
                        padding: 3rem 2.5rem 1.5rem;
                        margin-top: auto;
                    }

                    .footer-top {
                        display: grid;
                        grid-template-columns: 2fr 1fr 1fr 1fr;
                        gap: 2rem;
                        margin-bottom: 2rem;
                        padding-bottom: 2rem;
                        border-bottom: 1px solid rgba(255, 255, 255, 0.08);
                    }

                    .footer-brand {}

                    .footer-logo {
                        display: flex;
                        align-items: center;
                        gap: 0.5rem;
                        font-size: 1.3rem;
                        font-weight: 800;
                        color: #fff;
                        text-decoration: none;
                        margin-bottom: 0.75rem;
                    }

                    .footer-logo i {
                        color: var(--green);
                    }

                    .footer-desc {
                        font-size: 0.84rem;
                        line-height: 1.6;
                        margin-bottom: 1rem;
                    }

                    .footer-socials {
                        display: flex;
                        gap: 0.6rem;
                    }

                    .social-btn {
                        width: 34px;
                        height: 34px;
                        border-radius: 8px;
                        background: rgba(255, 255, 255, 0.08);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: rgba(255, 255, 255, 0.6);
                        font-size: 0.85rem;
                        text-decoration: none;
                        transition: all 0.15s;
                    }

                    .social-btn:hover {
                        background: var(--green);
                        color: #fff;
                    }

                    .footer-col h4 {
                        font-size: 0.875rem;
                        font-weight: 700;
                        color: #fff;
                        margin-bottom: 1rem;
                    }

                    .footer-col ul {
                        list-style: none;
                        display: flex;
                        flex-direction: column;
                        gap: 0.55rem;
                    }

                    .footer-col ul li a {
                        font-size: 0.82rem;
                        color: rgba(255, 255, 255, 0.55);
                        text-decoration: none;
                        transition: color 0.15s;
                    }

                    .footer-col ul li a:hover {
                        color: var(--green);
                    }

                    .footer-bottom {
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        font-size: 0.78rem;
                        color: rgba(255, 255, 255, 0.35);
                    }

                    .footer-bottom-links {
                        display: flex;
                        gap: 1rem;
                    }

                    .footer-bottom-links a {
                        color: rgba(255, 255, 255, 0.35);
                        text-decoration: none;
                    }

                    .footer-bottom-links a:hover {
                        color: rgba(255, 255, 255, 0.7);
                    }

                    /* ======================================================
           RESPONSIVE
        ====================================================== */
                    @media (max-width: 1024px) {
                        .shop-layout {
                            grid-template-columns: 200px 1fr;
                        }

                        .bestsellers-grid {
                            grid-template-columns: repeat(4, 1fr);
                        }

                        .footer-top {
                            grid-template-columns: 1fr 1fr;
                        }
                    }

                    @media (max-width: 768px) {
                        .topnav {
                            padding: 0 1rem;
                        }

                        .nav-links {
                            display: none;
                        }

                        .nav-search {
                            display: none;
                        }

                        .slide-title {
                            font-size: 1.8rem;
                        }

                        .slide-emoji {
                            display: none;
                        }

                        .categories-grid {
                            grid-template-columns: repeat(2, 1fr);
                        }

                        .shop-layout {
                            grid-template-columns: 1fr;
                        }

                        .filter-sidebar {
                            display: none;
                        }

                        .products-grid {
                            grid-template-columns: repeat(2, 1fr);
                        }

                        .bestsellers-grid {
                            grid-template-columns: repeat(2, 1fr);
                        }

                        .blog-grid {
                            grid-template-columns: 1fr;
                        }

                        .promo-row {
                            grid-template-columns: 1fr;
                        }

                        .footer-top {
                            grid-template-columns: 1fr;
                        }

                        .page-wrap {
                            padding: 1rem;
                        }
                    }

                    /* Restored Avatar CSS */
                    .nav-avatar {
                        width: 38px;
                        height: 38px;
                        border-radius: 50%;
                        object-fit: cover;
                        border: 2px solid var(--green);
                        cursor: pointer;
                        display: block;
                    }

                    .avatar-wrap {
                        position: relative;
                        padding-bottom: 10px;
                    }

                    .avatar-dropdown {
                        display: none;
                        position: absolute;
                        top: 100%;
                        right: 0;
                        padding-top: 10px;
                        background: transparent;
                        z-index: 999;
                    }

                    .avatar-dropdown-inner {
                        background: var(--white);
                        border: 1px solid var(--gray-200);
                        border-radius: var(--radius-sm);
                        box-shadow: var(--shadow-md);
                        min-width: 190px;
                        overflow: hidden;
                        animation: dropDown 0.18s ease;
                    }

                    @keyframes dropDown {
                        from {
                            opacity: 0;
                            transform: translateY(-6px);
                        }

                        to {
                            opacity: 1;
                            transform: translateY(0);
                        }
                    }

                    .avatar-wrap:hover .avatar-dropdown {
                        display: block;
                    }

                    .dropdown-header {
                        padding: 0.85rem 1rem;
                        border-bottom: 1px solid var(--gray-100);
                        background: var(--gray-50);
                    }

                    .dropdown-header strong {
                        display: block;
                        font-size: 0.875rem;
                        font-weight: 700;
                        color: var(--gray-800);
                    }

                    .dropdown-header span {
                        font-size: 0.75rem;
                        color: var(--gray-400);
                    }

                    .dropdown-menu {
                        padding: 0.4rem 0;
                    }

                    .dropdown-item {
                        display: flex;
                        align-items: center;
                        gap: 0.65rem;
                        padding: 0.6rem 1rem;
                        font-size: 0.855rem;
                        font-weight: 500;
                        color: var(--gray-600);
                        text-decoration: none;
                        transition: all 0.15s;
                        cursor: pointer;
                    }

                    .dropdown-item:hover {
                        background: var(--green-light);
                        color: var(--green-dark);
                    }

                    .dropdown-item i {
                        width: 16px;
                        text-align: center;
                        color: var(--green);
                    }

                    .dropdown-divider {
                        height: 1px;
                        background: var(--gray-100);
                        margin: 0.4rem 0;
                    }
                </style>
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
                        <a href="cart" class="nav-icon-btn" title="Giỏ hàng">
                            <i class="fa-solid fa-basket-shopping"></i>
                            <span class="cart-badge"><%= cartCount %></span>
                        </a>
                        <button class="nav-icon-btn" title="Thông báo">
                            <i class="fa-regular fa-bell"></i>
                        </button>

                        <% if (user !=null) { %>
                            <!-- Avatar with dropdown -->
                            <div class="avatar-wrap">
                                <img class="nav-avatar"
                                    src="https://ui-avatars.com/api/?name=<%= user.getFullname() != null ? user.getFullname().replace(" ", "+") : "User" %>&background=4caf50&color=fff&size=80&bold=true"
                                alt="avatar">
                                <div class="avatar-dropdown">
                                    <div class="avatar-dropdown-inner">
                                        <div class="dropdown-header">
                                            <strong>
                                                <%= user.getFullname() !=null ? user.getFullname() : user.getUsername()
                                                    %>
                                            </strong>
                                            <span>
                                                <%= user.getEmail() !=null ? user.getEmail() : user.getUsername() %>
                                            </span>
                                        </div>
                                        <div class="dropdown-menu">
                                            <a class="dropdown-item" href="profile?tab=profile">
                                                <i class="fa-regular fa-user"></i> Hồ Sơ Của Tôi
                                            </a>
                                            <a class="dropdown-item" href="profile?tab=security">
                                                <i class="fa-solid fa-shield-halved"></i> Bảo Mật
                                            </a>
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
                                <p class="slide-sub">Chọn lọc từ những vườn cây tốt nhất thế giới.<br>Giao tận tay trong
                                    ngày.</p>
                                <div class="slide-actions">
                                    <a href="#" class="btn btn-white"><i class="fa-solid fa-bag-shopping"></i> Mua
                                        Ngay</a>
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
                                <p class="slide-sub">Trồng theo tiêu chuẩn hữu cơ quốc tế.<br>An toàn cho cả gia đình.
                                </p>
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
                                <p class="slide-sub">Tháng này: Xoài cát Hòa Lộc, Sầu riêng, Mít.<br>Thơm ngon đúng mùa.
                                </p>
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
                                    <button
                                        style="width:100%;padding:0.5rem;background:var(--green);color:#fff;border:none;border-radius:var(--radius-xs);font-size:0.8rem;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;">
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
                                        <div class="check-box checked"
                                            style="width:15px;height:15px;border-radius:3px;"></div>
                                        <div class="stars-static">
                                            <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                            <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                            <i class="fa-solid fa-star"></i>
                                        </div>
                                        <span class="rating-label" style="font-size:0.78rem;color:var(--gray-400);">(5
                                            sao)</span>
                                    </div>
                                    <div class="rating-row">
                                        <div class="check-box"></div>
                                        <div class="stars-static">
                                            <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                            <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                            <i class="fa-regular fa-star empty"></i>
                                        </div>
                                        <span class="rating-label" style="font-size:0.78rem;color:var(--gray-400);">trở
                                            lên</span>
                                    </div>
                                    <div class="rating-row">
                                        <div class="check-box"></div>
                                        <div class="stars-static">
                                            <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                            <i class="fa-solid fa-star"></i>
                                            <i class="fa-regular fa-star empty"></i><i
                                                class="fa-regular fa-star empty"></i>
                                        </div>
                                        <span class="rating-label" style="font-size:0.78rem;color:var(--gray-400);">trở
                                            lên</span>
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
                                    <span style="font-size:0.8rem;color:var(--gray-400);margin-right:0.3rem;">Sắp
                                        xếp:</span>
                                    <button class="sort-tab <%= "popular".equals(sort) || sort == null ? "active" : "" %>" data-sort="popular">Phổ Biến</button>
                                    <button class="sort-tab <%= "newest".equals(sort) ? "active" : "" %>" data-sort="newest">Mới Nhất</button>
                                    <button class="sort-tab <%= "price_asc".equals(sort) ? "active" : "" %>" data-sort="price_asc">Giá Tăng</button>
                                    <button class="sort-tab <%= "price_desc".equals(sort) ? "active" : "" %>" data-sort="price_desc">Giá Giảm</button>
                                    <button class="sort-tab <%= "rating".equals(sort) ? "active" : "" %>" data-sort="rating">Đánh Giá</button>
                                </div>
                            </div>

                            <!-- Product grid -->
                            <div class="products-grid">
                            <% for (Product p : productsList) { %>
                                <div class="product-card <%= p.getStockQuantity() <= 0 ? "out-of-stock" : "" %>" data-id="<%= p.getId() %>" style="cursor:pointer;">
                                    <div class="product-image-wrap">
                                        <%
                                            String imgStr = p.getImage() != null && !p.getImage().isEmpty() ? p.getImage() : "🍎";
                                            if (imgStr.toLowerCase().endsWith(".png") || imgStr.toLowerCase().endsWith(".jpg") || imgStr.toLowerCase().endsWith(".jpeg") || imgStr.toLowerCase().endsWith(".gif") || imgStr.contains("/")) {
                                        %>
                                            <img src="<%= imgStr %>" alt="<%= p.getTitle() %>" style="width:100%; height:100%; object-fit:cover; border-radius:var(--radius-md);">
                                        <%  } else { %>
                                            <div class="product-emoji"><%= imgStr %></div>
                                        <%  } %>
                                        <% if (p.getSalePrice() < p.getOriginalPrice()) { 
                                            int pct = (int) Math.round((1 - p.getSalePrice()/p.getOriginalPrice()) * 100);
                                        %>
                                            <div class="product-badge badge-sale">-<%= pct %>%</div>
                                        <% } else if (p.isIsFeatured()) { %>
                                            <div class="product-badge badge-hot">Hot</div>
                                        <% } %>
                                        <button class="product-wishlist" data-wishlist-action="add" data-product-id="<%= p.getId() %>"><i class="fa-regular fa-heart"></i></button>
                                    </div>
                                    <div class="product-info">
                                        <div class="product-category"><%= p.getShopName() != null ? p.getShopName() : "Chung" %></div>
                                        <div class="product-name"><%= p.getTitle() %></div>
                                        <div class="product-rating">
                                            <div class="stars">
                                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                                <i class="fa-solid fa-star"></i>
                                            </div>
                                            <span class="rating-count"><%= String.format("%.1f", p.getAverageRating()) %> (<%= p.getSoldQuantity() %>)</span>
                                        </div>
                                        <div class="product-price">
                                            <span class="price-current"><%= String.format("%,.0f", p.getSalePrice()) %> d</span>
                                            <% if (p.getSalePrice() < p.getOriginalPrice()) { %>
                                                <span class="price-original"><%= String.format("%,.0f", p.getOriginalPrice()) %> d</span>
                                            <% } %>
                                        </div>
                                    </div>
                                    <div class="product-footer">
                                        <% if (p.getStockQuantity() > 0) { %>
                                            <div class="product-unit"><i class="fa-solid fa-scale-balanced"></i> Con <%= p.getStockQuantity() %> <%= p.getUnit() %></div>
                                            <button class="btn-cart" onclick="window.location.href='cart?action=add&productId=<%= p.getId() %>'"><i class="fa-solid fa-plus"></i> Thêm</button>
                                        <% } else { %>
                                            <div class="product-unit" style="color:var(--orange);"><i class="fa-solid fa-circle-xmark"></i> Hết hàng</div>
                                            <button class="btn-cart" disabled><i class="fa-solid fa-ban"></i> Het</button>
                                        <% } %>
                                    </div>
                                </div>
                            <% } %>
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


                </div><!-- /page-wrap -->

                <!-- ====================================================== FOOTER -->
                <footer>
                    <div class="footer-top" style="max-width:1280px;margin:0 auto;">
                        <div class="footer-brand">
                            <a href="#" class="footer-logo"><i class="fa-solid fa-apple-whole"></i> Sena Shop</a>
                            <p class="footer-desc">Chuyên cung cấp trái cây tươi ngon, chất lượng cao từ các vườn trồng
                                uy tín trong nước và quốc tế. Giao hàng tận nơi, uy tín hàng đầu.</p>
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
                                <li><a href="#"><i class="fa-regular fa-envelope" style="width:14px;"></i>
                                        senashop@gmail.com</a></li>
                                <li><a href="#"><i class="fa-solid fa-location-dot" style="width:14px;"></i> Ha Noi,
                                        Viet Nam</a></li>
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
                    var totalSlides = 3;
                    var autoSlide;

                    function updateSlider() {
                        document.getElementById('sliderTrack').style.transform = 'translateX(-' + (currentSlide * 100) + '%)';
                        document.querySelectorAll('.dot').forEach(function (d, i) {
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
                        autoSlide = setInterval(function () { changeSlide(1); }, 5000);
                    }

                    autoSlide = setInterval(function () { changeSlide(1); }, 5000);

                    // ── Sort tabs ──
                    document.querySelectorAll('.sort-tab').forEach(function (btn) {
                        btn.addEventListener('click', function () {
                            document.querySelectorAll('.sort-tab').forEach(function (b) { b.classList.remove('active'); });
                            btn.classList.add('active');
                        });
                    });

                    // ── Category cards ──
                    document.querySelectorAll('.category-card').forEach(function (card) {
                        card.addEventListener('click', function (e) {
                            e.preventDefault();
                            document.querySelectorAll('.category-card').forEach(function (c) { c.classList.remove('active'); });
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

                    // ── Mở Modal Chi Tiết Sản Phẩm khi bấm vào thẻ sản phẩm (Hỗ trợ AJAX) ──
                    const productsGrid = document.querySelector('.products-grid');
                    if (productsGrid) {
                        productsGrid.addEventListener('click', function (e) {
                            const card = e.target.closest('.product-card');
                            if (!card) return;
                            // Không chuyển trang nếu người dùng bấm vào nút Wishlist hoặc Thêm Giỏ Hàng
                            if (e.target.closest('.product-wishlist') || e.target.closest('.btn-cart')) return;
                            
                            const productId = card.getAttribute('data-id');
                            if (productId) window.location.href = 'info?id=' + productId;
                        });
                    }

                    // ── AJAX Lọc/Sắp Xếp Sản Phẩm Không Reload Trang ──
                    document.querySelectorAll('.sort-tab').forEach(function(tab) {
                        tab.addEventListener('click', function(e) {
                            e.preventDefault();
                            var sortType = this.getAttribute('data-sort');
                            if (!sortType) return;
                            
                            // Đổi màu tab
                            document.querySelectorAll('.sort-tab').forEach(t => t.classList.remove('active'));
                            this.classList.add('active');
                            
                            // Gọi backend lấy danh sách mới
                            fetch('home.jsp?sort=' + sortType)
                                .then(res => res.text())
                                .then(html => {
                                    const parser = new DOMParser();
                                    const doc = parser.parseFromString(html, 'text/html');
                                    const newGrid = doc.querySelector('.products-grid');
                                    if (newGrid && productsGrid) {
                                        productsGrid.innerHTML = newGrid.innerHTML;
                                    }
                                })
                                .catch(err => console.error("Lỗi AJAX Sắp xếp:", err));
                        });
                    });
                </script>
            </body>
            </html>