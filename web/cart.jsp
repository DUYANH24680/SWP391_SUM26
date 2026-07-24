<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Cart" %>
<%@ page import="model.CartItem" %>
<%@ page import="model.Account" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="Utils.ImageUrlUtil" %>
<%@ page import="java.util.Locale" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<%
    Account Account = (Account) session.getAttribute("Account");
    if (Account == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    Cart cart = (Cart) request.getAttribute("cart");
    if (cart == null) {
        cart = new Cart();
    }

    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");

    NumberFormat nf = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi"));
    Double cartTotalAttr = (Double) session.getAttribute("cartTotal");
    double cartTotalDisplay = cartTotalAttr != null ? cartTotalAttr : 0;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Giỏ Hàng | SenaFruit</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --green:       #4caf50;
            --green-dark:  #388e3c;
            --green-light: #e8f5e9;
            --green-mid:   #c8e6c9;
            --orange:      #f39c12;
            --orange-dark: #e67e22;
            --red:         #dc3545;
            --bg:          #f0f4f1;
            --white:       #ffffff;
            --gray-50:     #f8fafb;
            --gray-100:    #eef1ee;
            --gray-200:    #dde5dd;
            --gray-400:    #9aaa9a;
            --gray-600:    #5a6a5a;
            --gray-800:    #2d3d2d;
            --shadow-sm:   0 1px 3px rgba(0,0,0,.08);
            --shadow:      0 4px 16px rgba(0,0,0,.1);
            --radius:      14px;
            --radius-sm:   8px;
        }

        html, body {
            min-height: 100vh;
            font-family: 'Inter', sans-serif;
            color: var(--gray-800);
            background: var(--bg);
        }

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
        }

        .nav-logo i { color: var(--green); }

        .nav-right { margin-left: auto; display: flex; align-items: center; gap: 0.75rem; }

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

        .cart-badge {
            position: absolute; top: -4px; right: -4px;
            min-width: 18px; height: 18px;
            background: var(--orange); color: #fff;
            font-size: 0.62rem; font-weight: 700;
            border-radius: 999px;
            display: flex; align-items: center; justify-content: center;
            padding: 0 4px;
        }

        .wishlist-badge {
            position: absolute; top: -4px; right: -4px;
            min-width: 18px; height: 18px;
            background: var(--red); color: #fff;
            font-size: 0.62rem; font-weight: 700;
            border-radius: 999px;
            display: flex; align-items: center; justify-content: center;
            padding: 0 4px;
        }

        .nav-avatar {
            width: 38px; height: 38px; border-radius: 50%; object-fit: cover;
            border: 2px solid var(--green); cursor: pointer;
        }

        /* LAYOUT */
        .page-wrap {
            max-width: 1100px;
            margin: 0 auto;
            padding: 2rem 1.5rem;
        }

        .page-title {
            font-size: 2rem;
            font-weight: 800;
            margin-bottom: 0.25rem;
        }

        .breadcrumb {
            margin-bottom: 1.5rem;
            color: var(--gray-400);
            font-size: 0.875rem;
        }

        .breadcrumb a { color: var(--green); text-decoration: none; }
        .breadcrumb a:hover { text-decoration: underline; }

        /* ALERTS */
        .alert {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.9rem 1.2rem;
            border-radius: var(--radius-sm);
            font-size: 0.875rem;
            font-weight: 500;
            margin-bottom: 1.25rem;
        }

        .alert-success { background: #dcfce7; border: 1px solid #bbf7d0; color: #166534; }
        .alert-danger  { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }

        /* CART CARD */
        .cart-card {
            background: var(--white);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            padding: 1.5rem;
            margin-bottom: 1.5rem;
        }

        /* SELECT ALL BAR */
        .select-all-bar {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid var(--gray-100);
            margin-bottom: 0.5rem;
        }

        .select-all-bar .select-info {
            font-size: 0.875rem;
            color: var(--gray-600);
            font-weight: 500;
        }

        .select-all-bar .select-info strong {
            color: var(--gray-800);
        }

        /* CUSTOM CHECKBOX */
        .custom-checkbox {
            position: relative;
            display: inline-flex;
            cursor: pointer;
        }

        .custom-checkbox input {
            position: absolute;
            opacity: 0;
            width: 0;
            height: 0;
        }

        .checkmark {
            width: 22px;
            height: 22px;
            border: 2px solid var(--gray-200);
            border-radius: 6px;
            background: var(--white);
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .custom-checkbox input:checked ~ .checkmark {
            background: var(--green);
            border-color: var(--green);
        }

        .checkmark i {
            color: #fff;
            font-size: 0.7rem;
            opacity: 0;
            transition: opacity 0.15s;
        }

        .custom-checkbox input:checked ~ .checkmark i {
            opacity: 1;
        }

        /* TABLE */
        .cart-table { width: 100%; border-collapse: collapse; }

        .cart-table th,
        .cart-table td {
            padding: 1rem 0.75rem;
            border-bottom: 1px solid var(--gray-100);
            vertical-align: middle;
        }

        .cart-table th {
            text-align: left;
            font-size: 0.82rem;
            font-weight: 700;
            color: var(--gray-400);
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        /* CART ITEM */
        .cart-item {
            display: flex;
            gap: 1rem;
            align-items: center;
        }

        .cart-item-image {
            width: 88px;
            height: 88px;
            border-radius: var(--radius-sm);
            overflow: hidden;
            background: var(--gray-50);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .cart-item-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .cart-item-details { display: grid; gap: 0.3rem; }

        .cart-item-title {
            font-size: 1rem;
            font-weight: 700;
            color: var(--gray-800);
        }

        .cart-item-meta { font-size: 0.875rem; color: var(--gray-400); }

        /* QUANTITY CONTROL */
        .quantity-control {
            display: inline-flex;
            align-items: center;
            background: var(--gray-50);
            border: 1.5px solid var(--gray-200);
            border-radius: 10px;
            overflow: hidden;
        }

        .quantity-btn {
            background: transparent;
            border: none;
            width: 34px;
            height: 34px;
            font-size: 1.1rem;
            color: var(--green);
            cursor: pointer;
            transition: background 0.15s;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .quantity-btn:hover { background: var(--green-light); }

        .quantity-input {
            width: 50px;
            text-align: center;
            border: none;
            background: transparent;
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--gray-800);
            padding: 0;
        }

        .quantity-input:focus { outline: none; }

        /* BUTTONS */
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

        .btn:hover { transform: translateY(-1px); }

        .btn-green {
            background: var(--green);
            color: #fff;
            box-shadow: 0 2px 8px rgba(76,175,80,0.3);
        }

        .btn-green:hover {
            background: var(--green-dark);
            box-shadow: 0 4px 14px rgba(56,142,60,0.35);
        }

        .btn-orange {
            background: var(--orange);
            color: #fff;
            box-shadow: 0 2px 8px rgba(243,156,18,0.3);
        }

        .btn-orange:hover {
            background: var(--orange-dark);
            box-shadow: 0 4px 14px rgba(230,126,34,0.35);
        }

        .btn-secondary {
            background: var(--gray-100);
            color: var(--gray-600);
        }

        .btn-secondary:hover { background: var(--gray-200); color: var(--gray-800); }

        .btn-danger {
            background: transparent;
            color: var(--red);
            border: 2px solid var(--red);
            padding: 0.6rem 1rem;
        }

        .btn-danger:hover {
            background: var(--red);
            color: #fff;
        }

        /* MODAL */
        .modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.45);
            z-index: 1000;
            justify-content: center;
            align-items: center;
            animation: fadeIn 0.2s ease;
        }

        .modal-overlay.active {
            display: flex;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .modal-box {
            background: var(--white);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            width: 480px;
            max-width: 95vw;
            max-height: 90vh;
            overflow-y: auto;
            animation: slideUp 0.25s ease;
        }

        @keyframes slideUp {
            from { transform: translateY(20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        .modal-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid var(--gray-100);
        }

        .modal-header h3 {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--gray-800);
        }

        .modal-close {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            border: none;
            background: var(--gray-100);
            color: var(--gray-600);
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.9rem;
            transition: background 0.15s;
        }

        .modal-close:hover {
            background: var(--gray-200);
            color: var(--gray-800);
        }

        .modal-body {
            padding: 1.5rem;
        }

        .modal-product-info {
            display: flex;
            gap: 1rem;
            align-items: center;
            padding: 0.75rem 1rem;
            background: var(--gray-50);
            border-radius: var(--radius-sm);
            margin-bottom: 1.25rem;
        }

        .modal-product-img {
            width: 60px;
            height: 60px;
            border-radius: var(--radius-sm);
            object-fit: cover;
            background: var(--gray-100);
        }

        .modal-product-name {
            font-weight: 700;
            font-size: 0.95rem;
            color: var(--gray-800);
            margin-bottom: 0.2rem;
        }

        .modal-product-price {
            font-size: 0.875rem;
            color: var(--green-dark);
            font-weight: 600;
        }

        .form-group {
            margin-bottom: 1rem;
        }

        .form-label {
            display: block;
            font-size: 0.82rem;
            font-weight: 600;
            color: var(--gray-600);
            text-transform: uppercase;
            letter-spacing: 0.04em;
            margin-bottom: 0.4rem;
        }

        .form-input, .form-select, .form-textarea {
            width: 100%;
            padding: 0.6rem 0.85rem;
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-size: 0.9rem;
            font-family: 'Inter', sans-serif;
            color: var(--gray-800);
            background: var(--white);
            transition: border-color 0.15s;
        }

        .form-input:focus, .form-select:focus, .form-textarea:focus {
            outline: none;
            border-color: var(--green);
        }

        .form-textarea {
            resize: vertical;
            min-height: 70px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }

        .modal-error {
            color: var(--red);
            font-size: 0.82rem;
            margin-top: 0.25rem;
        }

        .modal-footer {
            padding: 1rem 1.5rem;
            border-top: 1px solid var(--gray-100);
            display: flex;
            gap: 0.75rem;
            justify-content: flex-end;
        }

        .modal-success {
            color: var(--green);
            font-size: 0.82rem;
            margin-top: 0.25rem;
        }

        /* SUMMARY BOX */
        .summary-box {
            background: var(--white);
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius);
            padding: 1.5rem;
            margin-top: 1.25rem;
        }

        .summary-divider {
            border: none;
            border-top: 1px dashed var(--gray-200);
            margin: 1rem 0;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 1rem;
            margin-bottom: 0.6rem;
            font-size: 1rem;
        }

        .summary-row .label {
            color: var(--gray-600);
            font-weight: 500;
        }

        .summary-row .value {
            font-weight: 700;
            color: var(--gray-800);
        }

        .summary-row.total-row {
            margin-top: 0.5rem;
            margin-bottom: 0;
        }

        .summary-row.total-row .label {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--gray-800);
        }

        .summary-row.total-row .value {
            font-size: 1.5rem;
            font-weight: 800;
            color: var(--red);
        }

        .summary-selected-info {
            font-size: 0.875rem;
            color: var(--gray-400);
            text-align: right;
            margin-bottom: 0.75rem;
        }

        .summary-selected-info strong {
            color: var(--green-dark);
            font-weight: 700;
        }

        .cart-actions {
            display: flex;
            gap: 0.75rem;
            flex-wrap: wrap;
            margin-top: 1rem;
        }

        /* EMPTY STATE */
        .empty-cart {
            text-align: center;
            padding: 3rem 1rem;
        }

        .empty-cart-icon { font-size: 4.5rem; color: var(--gray-200); margin-bottom: 1rem; }
        .empty-cart h2 { font-size: 1.5rem; margin-bottom: 0.5rem; }
        .empty-cart p { color: var(--gray-400); margin-bottom: 1.5rem; }

        @media (max-width: 768px) {
            .cart-table th:nth-child(3),
            .cart-table td:nth-child(3) { display: none; }
        }

        @media (max-width: 640px) {
            .page-wrap { padding: 1rem; }
            .cart-card { padding: 1rem; }
        }
    </style>
</head>
<body>

<!-- TOPNAV -->
<nav class="topnav">
    <a href="home.jsp" class="nav-logo">
        <i class="fa-solid fa-apple-whole"></i> SenaFruit
    </a>
    <div class="nav-right">
        <a href="wishlist" class="nav-icon-btn" title="Yêu Thích">
            <i class="fa-regular fa-heart"></i>
            <% Integer wlCount = (Integer) session.getAttribute("wishlistCount"); %>
            <% if (wlCount != null && wlCount > 0) { %>
            <span class="wishlist-badge"><%= wlCount %></span>
            <% } %>
        </a>
        <a href="view-cart" class="nav-icon-btn" title="Gio hang" style="background: var(--green-light); color: var(--green-dark);">
            <i class="fa-solid fa-basket-shopping"></i>
            <% Integer cartCount = (Integer) session.getAttribute("cartCount"); %>
            <% if (cartCount != null && cartCount > 0) { %>
            <span class="cart-badge"><%= cartCount %></span>
            <% } %>
        </a>
        <img class="nav-avatar" src="<%= Account.getAvatar() != null ? Account.getAvatar() : "https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(Account.getFullname(), "UTF-8") + "&background=4caf50&color=fff&size=80&bold=true&rounded=true" %>" alt="avatar">
    </div>
</nav>

<div class="page-wrap">
    <div class="breadcrumb">
        <a href="home.jsp">Trang Chủ</a> / Giỏ Hàng
    </div>

    <h1 class="page-title">Giỏ Hàng Cua Ban</h1>

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

    <div class="cart-card">
        <% if (cart.isEmpty()) { %>
            <div class="empty-cart">
                <div class="empty-cart-icon"><i class="fa-solid fa-cart-shopping"></i></div>
                <h2>Giỏ Hàng Dang Trong</h2>
                <p>Hay chon san pham ban yeu thich va them vao gio hang.</p>
                <a href="home.jsp" class="btn btn-green">
                    <i class="fa-solid fa-basket-shopping"></i> Tiep Tuc Mua Sắm
                </a>
            </div>
        <% } else { %>
            <!-- ===== SELECT ALL BAR ===== -->
            <div class="select-all-bar">
                <label class="custom-checkbox" id="selectAllLabel">
                    <input type="checkbox" id="selectAllCheckbox" onchange="toggleSelectAll()">
                    <span class="checkmark">
                        <i class="fa-solid fa-check"></i>
                    </span>
                    <span class="select-info" style="margin-left:0.5rem;">Chon Tat Ca</span>
                </label>
                <span class="select-info" id="selectedCountInfo">
                    Da chon <strong id="selectedCountNum">0</strong> / <%= cart.getItems().size() %> san pham
                </span>
            </div>

            <form id="checkoutForm" action="checkout-cart" method="GET">
                <input type="hidden" name="selectedProducts" id="selectedProducts">

                <table class="cart-table">
                    <thead>
                        <tr>
                            <th style="width: 50px;"></th>
                            <th>Sản Phẩm</th>
                            <th>Anh</th>
                            <th>Don Gia</th>
                            <th>So Luong</th>
                            <th>Tam Tinh</th>
                            <th style="width: 140px;"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (CartItem item : cart.getItems()) { %>
                        <tr                             data-product-id="<%= item.getProductId() %>"
                            data-price="<%= item.getUnitPrice() %>">

                            <td>
                                <label class="custom-checkbox item-checkbox-label">
                                    <input type="checkbox" class="product-checkbox"
                                           value="<%= item.getProductId() %>"
                                           data-price="<%= item.getUnitPrice() %>"
                                           data-quantity="<%= item.getQuantity() %>"
                                           <%= item.isSelected() ? "checked" : "" %>
                                           onchange="onItemCheckChange()">
                                    <span class="checkmark">
                                        <i class="fa-solid fa-check"></i>
                                    </span>
                                </label>
                            </td>

                            <td>
                                <div class="cart-item">
                                    <div class="cart-item-image">
                                        <% if (item.getImage() != null && !item.getImage().trim().isEmpty()) { %>
                                            <img src="<%= ImageUrlUtil.resolve(item.getImage(), request.getContextPath()) %>" alt="<%= item.getTitle() %>">
                                        <% } else { %>
                                            <span style="font-size: 1.5rem;">🍎</span>
                                        <% } %>
                                    </div>
                                    <div class="cart-item-details">
                                        <div class="cart-item-title"><%= item.getTitle() %></div>
                                        <div class="cart-item-meta">
                                            <% if (item.getSize() != null && !item.getSize().isEmpty()) { %>
                                                <span>Kich co: <strong><%= item.getSize() %></strong></span>
                                            <% } %>
                                        </div>
                                        <% if (item.getDiscountCode() != null && !item.getDiscountCode().isEmpty()) { %>
                                            <div style="font-size: 0.8rem; color: var(--gray-600); margin-top: 0.25rem;">Ma giam gia: <strong><%= item.getDiscountCode() %></strong></div>
                                        <% } %>
                                    </div>
                                </div>
                            </td>

                            <td>
                                <div class="cart-item-image" style="width: 60px; height: 60px;">
                                    <% if (item.getImage() != null && !item.getImage().trim().isEmpty()) { %>
                                        <img src="<%= ImageUrlUtil.resolve(item.getImage(), request.getContextPath()) %>" alt="<%= item.getTitle() %>">
                                    <% } else { %>
                                        <span style="font-size: 1.2rem;">🍎</span>
                                    <% } %>
                                </div>
                            </td>

                            <td style="font-weight: 600; color: var(--gray-800);">
                                <%= nf.format((long) item.getUnitPrice()) %> d
                            </td>

                            <td>
                                <div class="quantity-control">
                                    <button type="button" class="quantity-btn minus-btn"
                                            onclick="changeQty(this, -1, '<%= item.getProductId() %>', '<%= item.getQuantity() %>')">
                                        <i class="fa-solid fa-minus"></i>
                                    </button>
                                    <input type="text" class="quantity-input"
                                           value="<%= item.getQuantity() %>"
                                           data-product-id="<%= item.getProductId() %>"
                                           readonly>
                                    <button type="button" class="quantity-btn plus-btn"
                                            onclick="changeQty(this, 1, '<%= item.getProductId() %>', '<%= item.getQuantity() %>')">
                                        <i class="fa-solid fa-plus"></i>
                                    </button>
                                </div>
                            </td>

                            <td style="font-weight: 700; color: var(--green-dark);">
                                <span class="item-total">
                                    <%= nf.format((long) item.getSubtotal()) %> d
                                </span>
                            </td>

                            <td>
                                <button type="button" class="btn btn-danger btn-sm"
                                        onclick="confirmRemove('<%= item.getProductId() %>')">
                                    <i class="fa-solid fa-trash"></i>
                                </button>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>

                <!-- ===== SUMMARY BOX ===== -->
                <div class="summary-box">
                    <div class="summary-selected-info">
                        <i class="fa-solid fa-check-circle" style="color:var(--green);"></i>
                        Da chon <strong id="summarySelectedCount">0</strong> san pham
                    </div>

                    <div class="summary-row">
                        <span class="label">Tong san pham:</span>
                        <span class="value" id="summaryItemCount">0 san pham</span>
                    </div>

                    <hr class="summary-divider">

                    <div class="summary-row total-row">
                        <span class="label">Tong tien (da chon):</span>
                        <span class="value" id="selectedTotalDisplay">0 d</span>
                    </div>

                    <div class="cart-actions">
                        <a href="home.jsp" class="btn btn-secondary">
                            <i class="fa-solid fa-arrow-left"></i> Tiep Tuc Mua Sắm
                        </a>
                        <button type="button" class="btn btn-danger" onclick="confirmClearCart()">
                            <i class="fa-solid fa-trash"></i> Xoa Giỏ Hàng
                        </button>
                        <button type="submit" class="btn btn-orange" id="checkoutBtn">
                            <i class="fa-solid fa-credit-card"></i> Mua Hang
                        </button>
                    </div>
                </div>
            </form>
        <% } %>
    </div>
</div>

<script>
    const formatter = new Intl.NumberFormat('vi-VN', {
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    });

    const totalItems = <%= cart.isEmpty() ? 0 : cart.getItems().size() %>;

    // ---- Xoa san pham ----
    function confirmRemove(productId) {
        if (confirm('Ban co chan chan muon xoa san pham nay khoi gio hang?')) {
            window.location.href = 'remove-from-cart?productId=' + productId;
        }
    }

    // ---- Xoa toan bo gio hang ----
    function confirmClearCart() {
        if (confirm('Ban co chan chan muon xoa toan bo gio hang?')) {
            window.location.href = '<%= request.getContextPath() %>/cart?action=clear';
        }
    }

    // ---- Thay doi so luong ----
    function changeQty(btn, delta, productId, currentQty) {
        const row = btn.closest('tr');
        const input = row.querySelector('.quantity-input');
        let value = parseInt(input.value);

        if (delta > 0) {
            value++;
        } else if (value > 1) {
            value--;
        } else {
            if (confirm('Ban co chan chan muon xoa san pham nay khoi gio hang?')) {
                window.location.href = 'remove-from-cart?productId=' + productId;
            }
            return;
        }

        input.value = value;

        // Cap nhat data-quantity tren checkbox
        const checkbox = row.querySelector('.product-checkbox');
        if (checkbox) {
            checkbox.setAttribute('data-quantity', value);
        }

        // Cap nhat tong tien tren dong
        const price = parseFloat(row.dataset.price);
        const newTotal = price * value;
        row.querySelector('.item-total').textContent = formatter.format(Math.round(newTotal)) + ' d';

        // Gui AJAX cap nhat so luong
        updateCartQuantity(productId, value);

        // Tinh lai tong tien + cap nhat select all
        recalcUI();
    }

    // ---- Gui AJAX cap nhat so luong ----
    function updateCartQuantity(productId, quantity) {
        const data = new URLSearchParams();
        data.append('productId', productId);
        data.append('quantity', quantity);

        fetch('update-cart', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: data
        })
        .then(response => response.text())
        .then(() => {})
        .catch(error => console.error('Loi cap nhat gio hang:', error));
    }

    // ---- Checkbox thay doi ----
    function onItemCheckChange() {
        updateAllSelectAllState();
        recalcUI();

        // Gui AJAX cap nhat trang thai chon
        document.querySelectorAll('.product-checkbox').forEach(function(checkbox) {
            updateItemSelection(checkbox.value, checkbox.checked);
        });
    }

    function updateItemSelection(productId, selected) {
        const data = new URLSearchParams();
        data.append('productId', productId);
        data.append('selected', selected);

        fetch('update-cart', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: data
        })
        .then(response => response.text())
        .then(() => {})
        .catch(error => console.error('Loi cap nhat trang thai:', error));
    }

    // ---- Chon / bo chon tat ca ----
    function toggleSelectAll() {
        const selectAll = document.getElementById('selectAllCheckbox');
        const checked = selectAll.checked;

        document.querySelectorAll('.product-checkbox').forEach(function(cb) {
            cb.checked = checked;
        });

        recalcUI();

        // Gui AJAX cho tat ca items
        document.querySelectorAll('.product-checkbox').forEach(function(cb) {
            updateItemSelection(cb.value, checked);
        });
    }

    function updateAllSelectAllState() {
        const allCheckboxes = document.querySelectorAll('.product-checkbox');
        if (allCheckboxes.length === 0) return;

        const allChecked = Array.from(allCheckboxes).every(function(cb) { return cb.checked; });
        const someChecked = Array.from(allCheckboxes).some(function(cb) { return cb.checked; });

        const selectAll = document.getElementById('selectAllCheckbox');
        selectAll.checked = allChecked;
        selectAll.indeterminate = someChecked && !allChecked;
    }

    // ---- Tinh lai UI: dem + tong tien ----
    function recalcUI() {
        const checkedBoxes = document.querySelectorAll('.product-checkbox:checked');
        const selectedCount = checkedBoxes.length;

        // Cap nhat so luong da chon
        document.getElementById('selectedCountNum').textContent = selectedCount;
        document.getElementById('summarySelectedCount').textContent = selectedCount;
        document.getElementById('summaryItemCount').textContent = selectedCount + ' san pham';

        // Tinh tong tien chi cua san pham da chon
        let total = 0;
        checkedBoxes.forEach(function(checkbox) {
            const row = checkbox.closest('tr');
            const totalText = row.querySelector('.item-total').textContent;
            const raw = parseFloat(totalText.replace(/[^\d]/g, '')) || 0;
            total += raw;
        });

        document.getElementById('selectedTotalDisplay').textContent = formatter.format(Math.round(total)) + ' d';

        // Cap nhat trang thai select all
        updateAllSelectAllState();
    }

    // ---- Form submit (mua hang) ----
    document.getElementById('checkoutForm').addEventListener('submit', function(event) {
        const checkboxes = document.querySelectorAll('.product-checkbox:checked');
        if (checkboxes.length === 0) {
            event.preventDefault();
            alert('Vui long chon it nhat mot san pham de mua hang.');
            return;
        }

        const selectedIds = Array.from(checkboxes).map(function(cb) { return cb.value; });
        document.getElementById('selectedProducts').value = selectedIds.join(',');
    });

    // ---- Khoi tao khi load trang ----
    document.addEventListener('DOMContentLoaded', function() {
        updateAllSelectAllState();
        recalcUI();
    });
</script>

</body>
</html>

