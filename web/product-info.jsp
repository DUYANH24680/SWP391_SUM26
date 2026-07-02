//Duy Anh
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Product" %>
<%@ page import="model.Shop" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="Utils.ImageUrlUtil" %>
<%@ page import="dao.ShopDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.ProductReview" %>
<%
    // No auth guard for viewing product

    // ---- Product ----
    Product product = (Product) request.getAttribute("product");
    if (product == null) {
        session.setAttribute("error", "San pham khong ton tai hoac da bi xoa.");
        response.sendRedirect(request.getContextPath() + "/home.jsp");
        return;
    }

    // ---- Current session info ----
    String role = (String) session.getAttribute("role");
    Integer sessionShopIdObj = (Integer) session.getAttribute("shopId");
    int sessionShopId = (sessionShopIdObj != null) ? sessionShopIdObj : 0;
    boolean isOwner = false;
    if ("seller".equals(role) && sessionShopId > 0 && sessionShopId == product.getShopId()) {
        isOwner = true;
    }

    String categoryName = (String) request.getAttribute("categoryName");
    if (categoryName == null || categoryName.trim().isEmpty()) {
        categoryName = "-";
    }

    Shop shopInfo = (Shop) request.getAttribute("shopInfo");
    if (shopInfo == null) {
        shopInfo = new Shop();
        shopInfo.setShopName(product.getShopName() != null ? product.getShopName() : "-");
    }

    double originalPrice = product.getOriginalPrice();
    double salePrice = product.getSalePrice();
    boolean hasDiscount = salePrice > 0 && salePrice < originalPrice;
    int discountPercent = (int) Math.round(product.getDiscountPercent());
    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(java.util.Locale.forLanguageTag("vi"));

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
    <title><%= product.getTitle() %> | Chi tiết sản phẩm</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --green: #4caf50;
            --green-dark: #388e3c;
            --green-light: #e8f5e9;
            --green-mid: #c8e6c9;
            --gray-50: #f8fafb;
            --gray-100: #eef1ee;
            --gray-200: #dde5dd;
            --gray-400: #9aaa9a;
            --gray-600: #5a6a5a;
            --gray-800: #2d3d2d;
            --radius: 14px;
            --radius-sm: 8px;
        }
        body {
            font-family: 'Inter', sans-serif;
            background: rgba(31, 41, 55, 0.95); /* Dark overlay */
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            padding: 2rem;
            color: var(--gray-800);
        }
        .close-btn {
            position: fixed;
            top: 20px;
            right: 30px;
            background: rgba(255, 255, 255, 0.1);
            color: #fff;
            border: none;
            width: 44px;
            height: 44px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s;
            z-index: 1000;
        }
        .close-btn:hover {
            background: rgba(255, 255, 255, 0.2);
            transform: scale(1.05);
        }
        .modal-container {
            background: #fff;
            border-radius: var(--radius);
            width: 100%;
            max-width: 1000px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            padding: 2rem;
            position: relative;
        }
        /* Tùy chỉnh thanh cuộn cho modal-container */
        .modal-container::-webkit-scrollbar { width: 8px; }
        .modal-container::-webkit-scrollbar-track { background: #f1f1f1; border-radius: var(--radius); }
        .modal-container::-webkit-scrollbar-thumb { background: #ccc; border-radius: var(--radius); }
        .modal-container::-webkit-scrollbar-thumb:hover { background: #bbb; }

        .breadcrumb {
            display: flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 0.85rem;
            color: var(--gray-400);
            margin-bottom: 1.5rem;
        }
        .breadcrumb a { color: var(--green); text-decoration: none; font-weight: 600; }
        .breadcrumb span { color: var(--gray-600); font-weight: 500; }
        
        .card-header {
            display: flex;
            align-items: center;
            gap: 0.6rem;
            margin-bottom: 1.5rem;
        }
        .card-title {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--gray-800);
        }
        
        .detail-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2rem;
        }
        @media (max-width: 768px) {
            .detail-grid { grid-template-columns: 1fr; }
            .modal-container { padding: 1.5rem; }
            body { padding: 1rem; }
            .close-btn { top: 10px; right: 10px; }
        }
        
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
        .product-image-wrap img { width: 100%; height: 100%; object-fit: cover; }
        .product-image-placeholder { font-size: 5rem; text-align: center; }
        
        .info-panel { display: flex; flex-direction: column; gap: 1.25rem; }
        .product-title { font-size: 1.5rem; font-weight: 800; line-height: 1.3; }
        
        .price-block {
            background: var(--green-light);
            border: 1px solid var(--green-mid);
            border-radius: var(--radius-sm);
            padding: 1rem 1.25rem;
            display: flex;
            align-items: baseline;
            gap: 1rem;
        }
        .price-sale { font-size: 1.6rem; font-weight: 800; color: #dc2626; }
        .price-original { font-size: 1rem; color: var(--gray-400); text-decoration: line-through; }
        .price-discount { background: #dc2626; color: #fff; font-size: 0.75rem; font-weight: 700; padding: 0.2rem 0.5rem; border-radius: 4px; }
        
        .meta-list { display: flex; flex-direction: column; gap: 0.65rem; }
        .meta-item { display: flex; align-items: flex-start; gap: 0.65rem; font-size: 0.9rem; }
        .meta-item i { color: var(--green); margin-top: 0.1rem; width: 16px; text-align: center; }
        .meta-label { color: var(--gray-400); font-weight: 500; min-width: 110px; }
        .meta-value { color: var(--gray-800); font-weight: 500; }
        
        .badge {
            display: inline-flex; align-items: center; gap: 0.3rem; padding: 0.2rem 0.6rem;
            border-radius: 100px; font-size: 0.75rem; font-weight: 700; white-space: nowrap;
        }
        .badge-green { background: #dcfce7; color: #166534; }
        .badge-yellow { background: #fef9c3; color: #854d0e; }
        .badge-red { background: #fee2e2; color: #991b1b; }
        .badge-gray { background: var(--gray-100); color: var(--gray-600); }
        
        .section-label { font-size: 0.75rem; font-weight: 700; text-transform: uppercase; color: var(--gray-400); margin-bottom: 0.5rem; }
        
        .shop-card {
            background: var(--gray-50); border: 1px solid var(--gray-200);
            border-radius: var(--radius-sm); padding: 1rem 1.25rem;
            display: flex; align-items: center; gap: 0.75rem;
        }
        .shop-avatar { width: 44px; height: 44px; border-radius: 50%; object-fit: cover; border: 2px solid var(--green); }
        .shop-avatar-placeholder { width: 44px; height: 44px; border-radius: 50%; background: var(--green-light); display: flex; align-items: center; justify-content: center; font-size: 1.2rem; }
        .shop-name { font-size: 0.95rem; font-weight: 700; color: var(--gray-800); }
        .shop-meta { font-size: 0.8rem; color: var(--gray-400); }

        /* ===== PRODUCT CODE ===== */
        .product-code-box {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-sm);
            padding: 0.75rem 1rem;
            font-family: 'Courier New', monospace;
            font-weight: 600;
            font-size: 0.9rem;
            color: var(--gray-800);
        }
        .code-text { flex: 1; }
        .btn-copy {
            background: none;
            border: none;
            color: var(--green);
            cursor: pointer;
            padding: 0.4rem;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
            font-size: 1rem;
        }
        .btn-copy:hover { color: var(--green-dark); transform: scale(1.1); }

        /* ===== QUANTITY CONTROL ===== */
        .quantity-control {
            display: flex;
            align-items: center;
            gap: 0;
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-sm);
            width: fit-content;
        }
        .qty-btn {
            background: none;
            border: none;
            color: var(--gray-600);
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s;
            font-size: 0.9rem;
        }
        .qty-btn:hover { color: var(--green); background: rgba(76, 175, 80, 0.1); }
        .qty-input {
            width: 60px;
            border: none;
            background: transparent;
            text-align: center;
            font-weight: 600;
            font-size: 1rem;
            color: var(--gray-800);
            outline: none;
        }
        .qty-input::-webkit-outer-spin-button,
        .qty-input::-webkit-inner-spin-button { -webkit-appearance: none; margin: 0; }
        .qty-input[type=number] { -moz-appearance: textfield; }

        /* ===== DISCOUNT CODE ===== */
        .discount-input-group {
            display: flex;
            gap: 0.5rem;
        }
        .discount-input {
            flex: 1;
            padding: 0.75rem 1rem;
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-size: 0.9rem;
            outline: none;
            transition: border-color 0.2s;
            background: var(--gray-50);
        }
        .discount-input:focus {
            border-color: var(--green);
            background: #fff;
        }
        .btn-apply-code {
            padding: 0.75rem 1.25rem;
            background: var(--gray-100);
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-sm);
            color: var(--gray-600);
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.2s;
            white-space: nowrap;
        }
        .btn-apply-code:hover {
            background: var(--gray-50);
            color: var(--green);
            border-color: var(--green);
        }
        #discountMessage {
            font-weight: 600;
            border-radius: 6px;
        }
        #discountMessage.success {
            background: #dcfce7;
            color: #166534;
            border-left: 3px solid var(--green);
            padding-left: 0.75rem;
        }
        #discountMessage.error {
            background: #fee2e2;
            color: #991b1b;
            border-left: 3px solid #dc2626;
            padding-left: 0.75rem;
        }

        /* ===== NOTES TEXTAREA ===== */
        .notes-textarea {
            width: 100%;
            padding: 0.75rem 1rem;
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-family: inherit;
            font-size: 0.9rem;
            resize: vertical;
            min-height: 80px;
            outline: none;
            transition: border-color 0.2s;
            background: var(--gray-50);
            color: var(--gray-800);
        }
        .notes-textarea:focus {
            border-color: var(--green);
            background: #fff;
        }
        .notes-textarea::placeholder {
            color: var(--gray-400);
        }

        /* ===== ORDER SUMMARY ===== */
        .order-summary {
            background: var(--green-light);
            border: 1px solid var(--green-mid);
            border-radius: var(--radius-sm);
            padding: 1rem 1.25rem;
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }
        .summary-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--gray-800);
        }
        .summary-price {
            font-size: 1.3rem;
            color: #dc2626;
            font-weight: 800;
        }
        .discount-row {
            color: var(--green-dark);
            font-size: 0.85rem;
        }
        .summary-saving {
            color: var(--green-dark);
        }
        
        .action-buttons { display: flex; gap: 0.75rem; margin-top: 0.5rem; flex-wrap: wrap;}
        .btn {
            display: inline-flex; align-items: center; justify-content: center; gap: 0.5rem;
            padding: 0.75rem 1.5rem; border-radius: var(--radius-sm); font-size: 0.9rem; font-weight: 600;
            cursor: pointer; border: none; text-decoration: none; transition: all 0.2s ease;
        }
        .btn-green { background: var(--green); color: #fff; }
        .btn-green:hover { background: var(--green-dark); transform: translateY(-1px); }
        .btn-outline { background: #fff; color: var(--gray-600); border: 1.5px solid var(--gray-200); }
        .btn-outline:hover { background: var(--gray-50); color: var(--gray-800); }

        /* ================= REVIEW SECTION (PREMIUM) ================= */
        .reviews-section {
            margin-top: 3rem;
            padding-top: 2.5rem;
            border-top: 1px solid var(--gray-200);
        }
        .reviews-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 2rem;
        }
        .reviews-title {
            font-size: 1.4rem;
            font-weight: 800;
            color: var(--gray-800);
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        .reviews-title i {
            color: var(--green);
            font-size: 1.6rem;
        }
        .reviews-summary {
            display: flex;
            align-items: center;
            gap: 3rem;
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            padding: 2rem 2.5rem;
            border-radius: var(--radius-lg);
            margin-bottom: 2.5rem;
            box-shadow: 0 4px 15px rgba(0,0,0,0.03);
            border: 1px solid rgba(226, 232, 240, 0.8);
        }
        .summary-score {
            text-align: center;
            padding-right: 3rem;
            border-right: 2px dashed var(--gray-300);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }
        .summary-score h2 {
            font-size: 4rem;
            font-weight: 900;
            color: #f59e0b;
            line-height: 1;
            text-shadow: 0 2px 4px rgba(245, 158, 11, 0.2);
            margin-bottom: 0.5rem;
        }
        .summary-score .stars-display {
            color: #f59e0b;
            font-size: 1.3rem;
            margin-bottom: 0.5rem;
            letter-spacing: 2px;
        }
        .summary-score p {
            font-size: 0.95rem;
            color: var(--gray-500);
            font-weight: 500;
        }
        .summary-stars {
            display: flex;
            flex-direction: column;
            gap: 0.6rem;
            flex: 1;
            max-width: 350px;
        }
        .star-row {
            display: flex;
            align-items: center;
            gap: 1rem;
            font-size: 0.9rem;
            color: var(--gray-600);
            font-weight: 600;
        }
        .star-bar {
            flex: 1;
            height: 10px;
            background: var(--gray-200);
            border-radius: 5px;
            overflow: hidden;
            box-shadow: inset 0 1px 2px rgba(0,0,0,0.05);
        }
        .star-fill {
            height: 100%;
            background: linear-gradient(90deg, #fbbf24 0%, #f59e0b 100%);
            border-radius: 5px;
            transition: width 1s ease-out;
        }
        
        .comment-list {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }
        .comment-item {
            display: flex;
            gap: 1.5rem;
            padding: 1.5rem;
            background: #fff;
            border-radius: var(--radius-md);
            border: 1px solid var(--gray-200);
            box-shadow: 0 2px 8px rgba(0,0,0,0.02);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .comment-item:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(0,0,0,0.05);
        }
        .comment-avatar {
            width: 52px;
            height: 52px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--green-light) 0%, #dcfce7 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--green-dark);
            font-weight: 800;
            font-size: 1.4rem;
            flex-shrink: 0;
            border: 3px solid #fff;
            box-shadow: 0 2px 6px rgba(34, 197, 94, 0.2);
        }
        .comment-content {
            flex: 1;
        }
        .comment-user {
            font-weight: 800;
            font-size: 1.05rem;
            color: var(--gray-800);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .comment-date {
            font-size: 0.85rem;
            color: var(--gray-400);
            font-weight: 500;
        }
        .comment-stars {
            color: #f59e0b;
            font-size: 0.95rem;
            margin: 0.4rem 0 0.8rem 0;
            letter-spacing: 1px;
        }
        .comment-text {
            font-size: 1rem;
            color: var(--gray-700);
            line-height: 1.6;
            background: #f8fafc;
            padding: 1rem 1.25rem;
            border-radius: var(--radius-sm);
            border-left: 4px solid var(--green);
        }
        
        .add-comment-form {
            margin-top: 3rem;
            background: #fff;
            padding: 2.5rem;
            border-radius: var(--radius-lg);
            border: 1px solid var(--gray-200);
            box-shadow: 0 8px 24px rgba(0,0,0,0.04);
            position: relative;
            overflow: hidden;
        }
        .add-comment-form::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 5px;
            background: linear-gradient(90deg, var(--green-light) 0%, var(--green) 100%);
        }
        .form-title {
            font-size: 1.3rem;
            font-weight: 800;
            margin-bottom: 1.5rem;
            color: var(--gray-800);
        }
        .rating-input {
            display: flex;
            align-items: center;
            gap: 0.6rem;
            margin-bottom: 1.5rem;
            font-size: 1.6rem;
            background: #f8fafc;
            padding: 0.75rem 1.25rem;
            border-radius: var(--radius-sm);
            width: max-content;
            border: 1px solid var(--gray-200);
        }
        .rating-input span {
            font-size: 0.95rem;
            color: var(--gray-600);
            font-weight: 600;
            margin-right: 0.75rem;
        }
        .rating-input i { 
            color: var(--gray-300); 
            cursor: pointer; 
            transition: all 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275); 
        }
        .rating-input i:hover {
            transform: scale(1.15);
            color: #fbbf24;
        }
        .rating-input i.active { 
            color: #f59e0b; 
            text-shadow: 0 0 10px rgba(245, 158, 11, 0.3);
        }
        
        .comment-textarea {
            width: 100%;
            padding: 1.25rem;
            border: 2px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-family: inherit;
            font-size: 1rem;
            resize: vertical;
            min-height: 140px;
            margin-bottom: 1.5rem;
            outline: none;
            transition: all 0.3s ease;
            background: #f8fafc;
            color: var(--gray-800);
        }
        .comment-textarea:focus {
            border-color: var(--green);
            background: #fff;
            box-shadow: 0 0 0 4px rgba(34, 197, 94, 0.1);
        }
        .btn-submit-review {
            width: 100%;
            padding: 1rem;
            font-size: 1.1rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            border-radius: var(--radius-md);
        }
    </style>
</head>
<body>

    <a href="home.jsp" class="close-btn" title="Đóng"><i class="fa-solid fa-xmark"></i></a>

    <div class="modal-container">
        <!-- Breadcrumb -->
        <div class="breadcrumb">
            <a href="home.jsp"><i class="fa-solid fa-box"></i> San Pham</a>
            <i class="fa-solid fa-chevron-right" style="font-size:0.6rem;"></i>
            <span><%= product.getTitle() %></span>
        </div>

        <div class="card-header">
            <i class="fa-solid fa-circle-info" style="color:var(--green);font-size:1.2rem;"></i>
            <div class="card-title">Chi Tiet San Pham</div>
        </div>

        <div class="detail-grid">
            <!-- LEFT: Product image -->
            <div>
                <% if (product.getImage() != null && !product.getImage().trim().isEmpty()) { %>
                <div class="product-image-wrap">
                    <img src="<%= ImageUrlUtil.resolve(product.getImage(), request.getContextPath()) %>" alt="<%= product.getTitle() %>" onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
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
                <h1 class="product-title"><%= product.getTitle() %></h1>

                <div class="price-block">
                    <span class="price-sale"><%= nf.format((long) salePrice) %> d</span>
                    <% if (hasDiscount) { %>
                    <span class="price-original"><%= nf.format((long) originalPrice) %> d</span>
                    <span class="price-discount">-<%= discountPercent %>%</span>
                    <% } %>
                </div>

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
                                <span class="badge badge-red"><i class="fa-solid fa-circle-xmark"></i> Het Hang</span>
                            <% } else { %>
                                <span class="badge badge-green"><i class="fa-solid fa-check-circle"></i> <%= product.getStockQuantity() %> san pham</span>
                            <% } %>
                        </span>
                    </div>
                    <div class="meta-item">
                        <i class="fa-solid fa-calendar-xmark"></i>
                        <span class="meta-label">Han su dung:</span>
                        <span class="meta-value">
                            <% if (product.getExpiredDate() != null) { %>
                                <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(product.getExpiredDate()) %>
                            <% } else { %>Khong co han<% } %>
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
                                <%= String.format(java.util.Locale.US, "%.1f", product.getAverageRating()) %> sao
                            <% } else { %>Chua co danh gia<% } %>
                        </span>
                    </div>
                    <div class="meta-item">
                        <i class="fa-solid fa-toggle-on"></i>
                        <span class="meta-label">Trang thai:</span>
                        <span class="meta-value">
                            <% if (product.isActive()) { %>
                                <span class="badge badge-green">Hoat dong</span>
                            <% } else { %>
                                <span class="badge badge-gray">Khong hoat dong</span>
                            <% } %>
                        </span>
                    </div>
                </div>

                <!-- Shop info -->
                <div>
                    <div class="section-label"><i class="fa-solid fa-shop" style="color:var(--green);"></i> Cua Hang Ban</div>
                    <div class="shop-card">
                        <% if (shopInfo.getLogo() != null && !shopInfo.getLogo().trim().isEmpty()) { %>
                        <img class="shop-avatar" src="<%= ImageUrlUtil.resolve(shopInfo.getLogo(), request.getContextPath()) %>" alt="<%= shopInfo.getShopName() %>" onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
                        <div class="shop-avatar-placeholder" style="display:none;">&#127974;</div>
                        <% } else { %><div class="shop-avatar-placeholder">&#127974;</div><% } %>
                        <div class="shop-info">
                            <div class="shop-name"><%= shopInfo.getShopName() != null ? shopInfo.getShopName() : "-" %></div>
                            <div class="shop-meta">Dia chi: <%= shopInfo.getAddress() != null && !shopInfo.getAddress().isEmpty() ? shopInfo.getAddress() : "Chua cap nhat" %></div>
                        </div>
                    </div>
                </div>

                <!-- Product Code -->
                <div>
                    <div class="section-label">Mã Sản Phẩm</div>
                    <div class="product-code-box">
                        <span class="code-text"><%= product.getId() %></span>
                        <button class="btn-copy" onclick="copyToClipboard('<%= product.getId() %>')" title="Sao chép">
                            <i class="fa-solid fa-copy"></i>
                        </button>
                    </div>
                </div>

                <!-- Quantity Input -->
                <div>
                    <div class="section-label">Số Lượng</div>
                    <div class="quantity-control">
                        <button class="qty-btn" id="decreaseQty" onclick="decreaseQuantity()">
                            <i class="fa-solid fa-minus"></i>
                        </button>
                        <input type="number" id="quantityInput" class="qty-input" value="1" min="1" max="999">
                        <button class="qty-btn" id="increaseQty" onclick="increaseQuantity()">
                            <i class="fa-solid fa-plus"></i>
                        </button>
                    </div>
                </div>

                <!-- Discount Code -->
                <div>
                    <div class="section-label">Mã Giảm Giá (Tùy Chọn)</div>
                    <div class="discount-input-group">
                        <input type="text" id="discountCode" class="discount-input" placeholder="Nhập mã giảm giá...">
                        <button class="btn-apply-code" onclick="applyDiscountCode()">
                            <i class="fa-solid fa-tag"></i> Áp Dụng
                        </button>
                    </div>
                    <div id="discountMessage" style="display:none; margin-top:0.5rem; font-size:0.85rem; padding:0.5rem 0.75rem; border-radius:6px;"></div>
                </div>

                <!-- Notes -->
                <div>
                    <div class="section-label">Ghi Chú Đơn Hàng (Tùy Chọn)</div>
                    <textarea id="orderNotes" class="notes-textarea" placeholder="Ví dụ: Không cắt mở gói, Giao vào buổi sáng..."></textarea>
                </div>

                <!-- Order Summary -->
                <div class="order-summary">
                    <div class="summary-row">
                        <span>Thành tiền:</span>
                        <span class="summary-price" id="totalPrice"><%= nf.format((long) salePrice) %> đ</span>
                    </div>
                    <% if (hasDiscount) { %>
                    <div class="summary-row discount-row">
                        <span>Tiết kiệm:</span>
                        <span class="summary-saving"><%= nf.format((long) (originalPrice - salePrice)) %> đ</span>
                    </div>
                    <% } %>
                </div>

                <!-- Action buttons -->
                <div class="action-buttons">
                    <button class="btn btn-green" onclick="alert('Chuc nang them vao gio hang chua duoc trien khai.')">
                        <i class="fa-solid fa-basket-shopping"></i> Them Vao Gio Hang
                    </button>
                    <a href="home.jsp" class="btn btn-outline">
                        <i class="fa-solid fa-arrow-left"></i> Quay Lai
                    </a>
                </div>
                <form id="cartForm" action="cart" method="post" style="display:none;">
                    <input type="hidden" id="cartAction" name="action" value="add">
                    <input type="hidden" name="productId" value="<%= product.getId() %>">
                    <input type="hidden" id="cartQty" name="quantity" value="1">
                    <input type="hidden" id="cartDiscountCode" name="discountCode" value="">
                    <input type="hidden" id="cartNote" name="note" value="">
                </form>
            </div>
        </div>

        <!-- REVIEWS SECTION -->
        <div class="reviews-section">
            <div class="reviews-header">
                <div class="reviews-title"><i class="fa-regular fa-comments"></i> Đánh giá & Bình luận</div>
            </div>

            <% 
                List<ProductReview> reviews = (List<ProductReview>) request.getAttribute("reviews");
                Map<String, Object> ratingStats = (Map<String, Object>) request.getAttribute("ratingStats");
                
                int totalRev = ratingStats != null ? (Integer) ratingStats.get("total") : 0;
                double avgRev = ratingStats != null ? (Double) ratingStats.get("avg") : 0.0;
                int s5 = ratingStats != null ? (Integer) ratingStats.get("star5") : 0;
                int s4 = ratingStats != null ? (Integer) ratingStats.get("star4") : 0;
                int s3 = ratingStats != null ? (Integer) ratingStats.get("star3") : 0;
                int s2 = ratingStats != null ? (Integer) ratingStats.get("star2") : 0;
                int s1 = ratingStats != null ? (Integer) ratingStats.get("star1") : 0;
                
                int pct5 = totalRev > 0 ? (s5 * 100 / totalRev) : 0;
                int pct4 = totalRev > 0 ? (s4 * 100 / totalRev) : 0;
                int pct3 = totalRev > 0 ? (s3 * 100 / totalRev) : 0;
                int pct2 = totalRev > 0 ? (s2 * 100 / totalRev) : 0;
                int pct1 = totalRev > 0 ? (s1 * 100 / totalRev) : 0;
            %>

            <div class="reviews-summary">
                <div class="summary-score">
                    <h2><%= String.format(java.util.Locale.US, "%.1f", avgRev > 0 ? avgRev : 5.0) %></h2>
                    <div style="color:#f59e0b; font-size:1.1rem; margin-top:0.3rem;">
                        <% for (int i = 1; i <= 5; i++) { 
                            if (i <= Math.round(avgRev)) { %>
                                <i class="fa-solid fa-star"></i>
                        <% } else { %>
                                <i class="fa-regular fa-star"></i>
                        <% } 
                        } %>
                    </div>
                    <p>Dựa trên <%= totalRev %> đánh giá</p>
                </div>
                <div class="summary-stars">
                    <div class="star-row"><span>5 Sao</span> <div class="star-bar"><div class="star-fill" style="width: <%= pct5 %>%;"></div></div> <span><%= s5 %></span></div>
                    <div class="star-row"><span>4 Sao</span> <div class="star-bar"><div class="star-fill" style="width: <%= pct4 %>%;"></div></div> <span><%= s4 %></span></div>
                    <div class="star-row"><span>3 Sao</span> <div class="star-bar"><div class="star-fill" style="width: <%= pct3 %>%;"></div></div> <span><%= s3 %></span></div>
                    <div class="star-row"><span>2 Sao</span> <div class="star-bar"><div class="star-fill" style="width: <%= pct2 %>%;"></div></div> <span><%= s2 %></span></div>
                    <div class="star-row"><span>1 Sao</span> <div class="star-bar"><div class="star-fill" style="width: <%= pct1 %>%;"></div></div> <span><%= s1 %></span></div>
                </div>
            </div>

            <div class="comment-list">
                <% if (reviews != null && !reviews.isEmpty()) { 
                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
                    for (ProductReview rev : reviews) { 
                        String name = rev.getFullname() != null && !rev.getFullname().isEmpty() ? rev.getFullname() : rev.getUsername();
                        String initial = name.substring(0, 1).toUpperCase();
                %>
                <div class="comment-item">
                    <div class="comment-avatar"><%= initial %></div>
                    <div class="comment-content">
                        <div class="comment-user"><%= name %> <span class="comment-date"><%= sdf.format(rev.getCreatedAt()) %></span></div>
                        <div class="comment-stars">
                            <% for (int i = 1; i <= 5; i++) { 
                                if (i <= rev.getRating()) { %>
                                    <i class="fa-solid fa-star"></i>
                            <% } else { %>
                                    <i class="fa-regular fa-star"></i>
                            <% } 
                            } %>
                        </div>
                        <div class="comment-text"><%= rev.getComment() != null ? rev.getComment() : "" %></div>
                    </div>
                </div>
                <% } 
                } else { %>
                    <div style="text-align: center; color: var(--gray-400); padding: 2rem;">Chưa có đánh giá nào cho sản phẩm này. Hãy là người đầu tiên!</div>
                <% } %>
            </div>

            <!-- Form Add Comment -->
            <% if (session.getAttribute("user") == null) { %>
                <div class="add-comment-form" style="text-align:center;">
                    <p style="margin-bottom: 1rem; color: var(--gray-600);">Bạn cần đăng nhập để đánh giá sản phẩm.</p>
                    <a href="<%= request.getContextPath() %>/login" class="btn btn-green">Đăng Nhập Ngay</a>
                </div>
            <% } else { 
                model.Account curUser = (model.Account) session.getAttribute("user");
                String curName = curUser.getFullname() != null && !curUser.getFullname().isEmpty() ? curUser.getFullname() : curUser.getUsername();
            %>
                <div class="add-comment-form">
                    <div class="form-title">Gửi đánh giá của bạn</div>
                    <form id="reviewForm" onsubmit="submitReview(event)">
                        <input type="hidden" name="productId" value="<%= product.getId() %>">
                        <input type="hidden" name="rating" id="ratingValue" value="5">
                        
                        <div class="rating-input" id="ratingInput">
                            <span style="font-size:0.9rem;color:var(--gray-600);margin-right:0.5rem;">Đánh giá sao:</span>
                            <i class="fa-solid fa-star active" data-val="1"></i>
                            <i class="fa-solid fa-star active" data-val="2"></i>
                            <i class="fa-solid fa-star active" data-val="3"></i>
                            <i class="fa-solid fa-star active" data-val="4"></i>
                            <i class="fa-solid fa-star active" data-val="5"></i>
                        </div>
                        <textarea name="comment" class="comment-textarea" placeholder="Chia sẻ trải nghiệm của bạn về sản phẩm này... (Không bắt buộc)"></textarea>
                        <button type="submit" class="btn btn-green btn-submit-review">Gửi Đánh Giá</button>
                    </form>
                </div>
                <script>
                    const CURRENT_USER_NAME = "<%= curName %>";
                </script>
            <% } %>
        </div>
        <!-- END REVIEWS SECTION -->
    </div>

    <script>
        // ===== QUANTITY CONTROL =====
        function decreaseQuantity() {
            const input = document.getElementById('quantityInput');
            const val = parseInt(input.value);
            if (val > 1) input.value = val - 1;
        }
        function increaseQuantity() {
            const input = document.getElementById('quantityInput');
            const val = parseInt(input.value);
            if (val < 999) input.value = val + 1;
        }

        // ===== DISCOUNT CODE =====
        function applyDiscountCode() {
            const code = document.getElementById('discountCode').value.trim();
            const msg = document.getElementById('discountMessage');
            
            if (!code) {
                msg.textContent = 'Vui lòng nhập mã giảm giá';
                msg.className = 'error';
                msg.style.display = 'block';
                return;
            }
            
            // Mock validation - replace with actual API call
            if (code.toUpperCase() === 'SAVE10') {
                msg.textContent = '✓ Mã giảm giá "SAVE10" đã được áp dụng! Giảm 10%';
                msg.className = 'success';
                msg.style.display = 'block';
            } else if (code.toUpperCase() === 'SAVE20') {
                msg.textContent = '✓ Mã giảm giá "SAVE20" đã được áp dụng! Giảm 20%';
                msg.className = 'success';
                msg.style.display = 'block';
            } else {
                msg.textContent = '✗ Mã giảm giá không hợp lệ hoặc đã hết hạn';
                msg.className = 'error';
                msg.style.display = 'block';
            }
        }

        // ===== COPY PRODUCT CODE =====
        function copyToClipboard(text) {
            navigator.clipboard.writeText(text).then(() => {
                alert('Đã sao chép mã sản phẩm: ' + text);
            }).catch(() => {
                alert('Không thể sao chép');
            });
        }

        // ===== ADD TO CART =====
        function addToCart() {
            const qty = parseInt(document.getElementById('quantityInput').value) || 1;
            const notes = document.getElementById('orderNotes').value;
            const code = document.getElementById('discountCode').value;

            document.getElementById('cartQty').value = qty;
            document.getElementById('cartNote').value = notes;
            document.getElementById('cartDiscountCode').value = code;
            document.getElementById('cartAction').value = 'add';
            document.getElementById('cartForm').submit();
        }

        // ===== BUY NOW =====
        function buyNow() {
            const qty = parseInt(document.getElementById('quantityInput').value) || 1;
            const notes = document.getElementById('orderNotes').value;
            const code = document.getElementById('discountCode').value;

            document.getElementById('cartQty').value = qty;
            document.getElementById('cartNote').value = notes;
            document.getElementById('cartDiscountCode').value = code;
            document.getElementById('cartAction').value = 'buyNow';
            document.getElementById('cartForm').submit();
        }

        // ===== SUBMIT REVIEW (AJAX) =====
        function submitReview(event) {
            event.preventDefault();
            const form = event.target;
            const commentText = form.querySelector('.comment-textarea').value.trim();
            const rating = parseInt(document.getElementById('ratingValue').value) || 5;
            
            const params = new URLSearchParams();
            params.append("productId", form.querySelector('input[name="productId"]').value);
            params.append("rating", rating);
            params.append("comment", commentText);
            params.append("ajax", "true");

            fetch("<%= request.getContextPath() %>/review", {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded",
                    "X-Requested-With": "XMLHttpRequest"
                },
                body: params
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    const commentList = document.querySelector('.comment-list');
                    if (commentList.innerHTML.includes("Chưa có đánh giá")) {
                        commentList.innerHTML = "";
                    }
                    
                    let starsHtml = "";
                    for (let i = 1; i <= 5; i++) {
                        if (i <= rating) {
                            starsHtml += '<i class="fa-solid fa-star"></i>';
                        } else {
                            starsHtml += '<i class="fa-regular fa-star"></i>';
                        }
                    }

                    const initial = CURRENT_USER_NAME.charAt(0).toUpperCase();
                    const now = new Date();
                    const dateStr = String(now.getDate()).padStart(2, '0') + '/' + 
                                    String(now.getMonth() + 1).padStart(2, '0') + '/' + 
                                    now.getFullYear() + ' ' + 
                                    String(now.getHours()).padStart(2, '0') + ':' + 
                                    String(now.getMinutes()).padStart(2, '0');

                    const newComment = document.createElement('div');
                    newComment.className = 'comment-item';
                    newComment.innerHTML = `
                        <div class="comment-avatar">${initial}</div>
                        <div class="comment-content">
                            <div class="comment-user">${CURRENT_USER_NAME} <span class="comment-date">${dateStr}</span></div>
                            <div class="comment-stars">${starsHtml}</div>
                            <div class="comment-text">${commentText}</div>
                        </div>
                    `;
                    
                    commentList.insertBefore(newComment, commentList.firstChild);
                    form.reset();
                    document.getElementById('ratingValue').value = 5;
                    const stars = document.querySelectorAll('#ratingInput i');
                    stars.forEach(s => s.classList.add('active'));
                    
                    alert("Cảm ơn bạn đã gửi đánh giá!");
                } else {
                    alert("Lỗi: " + data.message);
                }
            })
            .catch(err => {
                console.error(err);
                alert("Có lỗi xảy ra khi gửi bình luận.");
            });
        }

        // ===== RATING STARS =====
        const stars = document.querySelectorAll('#ratingInput i');
        const ratingValue = document.getElementById('ratingValue');
        if (stars && ratingValue) {
            stars.forEach(star => {
                star.addEventListener('click', function() {
                    const val = this.getAttribute('data-val');
                    ratingValue.value = val;
                    stars.forEach(s => {
                        if (parseInt(s.getAttribute('data-val')) <= parseInt(val)) {
                            s.classList.add('active');
                        } else {
                            s.classList.remove('active');
                        }
                    });
                });
            });
        }
    </script>
</body>
</html>