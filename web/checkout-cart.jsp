<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.CartItem" %>
<%@ page import="model.DeliveryAddress" %>
<%@ page import="Utils.ImageUrlUtil" %>
<%@ page import="model.Voucher" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    Account Account = (Account) session.getAttribute("Account");
    if (Account == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<CartItem> selectedItems = (List<CartItem>) request.getAttribute("selectedItems");
    if (selectedItems == null || selectedItems.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/view-cart");
        return;
    }

    List<DeliveryAddress> addresses = (List<DeliveryAddress>) request.getAttribute("addresses");
    List<Voucher> vouchers = (List<Voucher>) request.getAttribute("vouchers");
    List<Integer> selectedProductIds = (List<Integer>) request.getAttribute("selectedProductIds");
    java.util.Map<Integer, model.Shop> shopMap = (java.util.Map<Integer, model.Shop>) request.getAttribute("shopMap");

    // Group items by shop id
    java.util.Map<Integer, List<CartItem>> itemsByShop = new java.util.HashMap<>();
    for (CartItem item : selectedItems) {
        int shopId = item.getShopId();
        itemsByShop.computeIfAbsent(shopId, k -> new java.util.ArrayList<>()).add(item);
    }

    double totalCost = 0;
    double shippingFee = 0;
    
    // Calculate totalCost and shippingFee per shop
    java.util.Map<Integer, Double> shopSubtotalMap = new java.util.HashMap<>();
    java.util.Map<Integer, Double> shopShippingMap = new java.util.HashMap<>();
    
    for (java.util.Map.Entry<Integer, List<CartItem>> entry : itemsByShop.entrySet()) {
        int shopId = entry.getKey();
        double subtotal = 0;
        for (CartItem item : entry.getValue()) {
            subtotal += item.getUnitPrice() * item.getQuantity();
        }
        shopSubtotalMap.put(shopId, subtotal);
        totalCost += subtotal;
        
        double ship = subtotal >= 200000 ? 0.0 : 20000.0;
        shopShippingMap.put(shopId, ship);
        shippingFee += ship;
    }

    double finalCost = totalCost + shippingFee;

    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(java.util.Locale.forLanguageTag("vi"));

    StringBuilder selectedProductsBuilder = new StringBuilder();
    for (int i = 0; i < selectedProductIds.size(); i++) {
        if (i > 0) selectedProductsBuilder.append(",");
        selectedProductsBuilder.append(selectedProductIds.get(i));
    }
    String selectedProductsStr = selectedProductsBuilder.toString();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác nhận đặt hàng | Sena Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --green: #4caf50;
            --green-dark: #388e3c;
            --green-light: #e8f5e9;
            --green-mid: #c8e6c9;
            --bg: #f4f6f4;
            --white: #ffffff;
            --gray-100: #eef1ee;
            --gray-200: #dde5dd;
            --gray-400: #9aaa9a;
            --gray-600: #5a6a5a;
            --gray-800: #2d3d2d;
            --shadow: 0 4px 16px rgba(0,0,0,.08);
            --shadow-md: 0 10px 30px rgba(0,0,0,.1);
            --radius: 16px;
            --radius-sm: 10px;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg);
            color: var(--gray-800);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .topnav {
            background: var(--white);
            border-bottom: 1px solid var(--gray-200);
            height: 60px;
            display: flex;
            align-items: center;
            padding: 0 2rem;
            position: sticky;
            top: 0;
            z-index: 100;
            box-shadow: 0 1px 3px rgba(0,0,0,.05);
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

        .container {
            max-width: 1100px;
            width: 100%;
            margin: 2rem auto;
            padding: 0 1.5rem;
            flex: 1;
        }

        .breadcrumb {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.85rem;
            color: var(--gray-400);
            margin-bottom: 1.5rem;
        }
        .breadcrumb a { color: var(--green); text-decoration: none; font-weight: 600; }
        .breadcrumb span { color: var(--gray-600); }

        .checkout-grid {
            display: grid;
            grid-template-columns: 1.6fr 1fr;
            gap: 2rem;
            align-items: flex-start;
        }
        @media (max-width: 850px) {
            .checkout-grid { grid-template-columns: 1fr; }
        }

        .card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow);
            padding: 1.75rem;
            margin-bottom: 1.5rem;
        }
        .card-title {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--gray-800);
            margin-bottom: 1.25rem;
            display: flex;
            align-items: center;
            gap: 0.65rem;
            border-bottom: 1px solid var(--gray-100);
            padding-bottom: 0.75rem;
        }
        .card-title i { color: var(--green); }

        .form-group {
            margin-bottom: 1.25rem;
            display: flex;
            flex-direction: column;
            gap: 0.4rem;
        }
        .form-label {
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--gray-600);
        }
        .form-select, .form-input, .form-textarea {
            width: 100%;
            padding: 0.75rem 1rem;
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-family: inherit;
            font-size: 0.9rem;
            outline: none;
            transition: all 0.15s ease;
            color: var(--gray-800);
            background: var(--white);
        }
        .form-select:focus, .form-input:focus, .form-textarea:focus {
            border-color: var(--green);
            box-shadow: 0 0 0 3px rgba(76,175,80,0.1);
        }
        .address-suggestion {
            background: var(--green-light);
            border: 1.5px dashed var(--green-mid);
            border-radius: var(--radius-sm);
            padding: 0.85rem 1.1rem;
            font-size: 0.8rem;
            color: var(--green-dark);
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .product-list {
            display: flex;
            flex-direction: column;
            gap: 1rem;
            max-height: 360px;
            overflow-y: auto;
            padding-right: 0.25rem;
        }
        .product-summary {
            display: flex;
            gap: 1rem;
            align-items: center;
            background: var(--gray-50);
            padding: 1rem;
            border-radius: var(--radius-sm);
            border: 1px solid var(--gray-100);
        }
        .product-img {
            width: 64px;
            height: 64px;
            border-radius: var(--radius-sm);
            object-fit: cover;
            border: 1px solid var(--gray-200);
        }
        .product-details { flex: 1; }
        .product-name {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--gray-800);
            margin-bottom: 0.25rem;
        }
        .product-qty-price {
            font-size: 0.85rem;
            color: var(--gray-600);
        }

        .voucher-input-group {
            display: flex;
            gap: 0.5rem;
        }
        .btn-apply {
            padding: 0.75rem 1.25rem;
            background: var(--gray-800);
            color: #fff;
            border: none;
            border-radius: var(--radius-sm);
            font-weight: 600;
            cursor: pointer;
            transition: background 0.15s;
            font-size: 0.9rem;
        }
        .btn-apply:hover { background: #1e2b1e; }
        .voucher-msg {
            font-size: 0.8rem;
            margin-top: 0.4rem;
            font-weight: 500;
        }
        .voucher-msg.success { color: var(--green-dark); }
        .voucher-msg.error { color: #dc2626; }

        /* ======= VOUCHER TRIGGER BUTTON ======= */
        .voucher-trigger-btn {
            flex: 1;
            display: flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.6rem 0.85rem;
            background: var(--white);
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-size: 0.8rem;
            font-weight: 600;
            color: var(--gray-600);
            cursor: pointer;
            transition: all 0.15s;
            font-family: inherit;
        }
        .voucher-trigger-btn:hover {
            border-color: var(--green);
            color: var(--green-dark);
            background: var(--green-light);
        }
        .voucher-trigger-btn .voucher-arrow {
            margin-left: auto;
            font-size: 0.75rem;
            opacity: 0.5;
            transition: transform 0.15s;
        }
        .voucher-trigger-btn:hover .voucher-arrow { opacity: 0.8; }

        /* ======= VOUCHER MODAL POPUP ======= */
        .voucher-modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.45);
            z-index: 1000;
            justify-content: center;
            align-items: center;
            padding: 1rem;
        }
        .voucher-modal-overlay.active { display: flex; }

        .voucher-modal {
            background: var(--white);
            border-radius: var(--radius);
            width: 100%;
            max-width: 480px;
            max-height: 80vh;
            display: flex;
            flex-direction: column;
            box-shadow: var(--shadow-md);
            animation: modalSlideIn 0.2s ease;
        }
        @keyframes modalSlideIn {
            from { transform: translateY(20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        .voucher-modal-header {
            padding: 1.1rem 1.25rem;
            border-bottom: 1px solid var(--gray-200);
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: var(--green-light);
            border-radius: var(--radius) var(--radius) 0 0;
        }
        .voucher-modal-header h3 {
            font-size: 1rem;
            font-weight: 700;
            color: var(--green-dark);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .voucher-modal-close {
            background: none;
            border: none;
            font-size: 1.2rem;
            color: var(--gray-400);
            cursor: pointer;
            padding: 0.25rem;
            line-height: 1;
            border-radius: 50%;
            transition: background 0.15s;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .voucher-modal-close:hover { background: var(--gray-100); color: var(--gray-800); }

        .voucher-modal-body {
            flex: 1;
            overflow-y: auto;
            padding: 0.75rem;
        }
        .voucher-modal-section-title {
            font-size: 0.72rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--gray-400);
            padding: 0.5rem 0.5rem 0.4rem;
            display: flex;
            align-items: center;
            gap: 0.4rem;
        }
        .voucher-modal-item {
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            padding: 0.85rem 1rem;
            margin-bottom: 0.6rem;
            cursor: pointer;
            transition: all 0.15s;
            display: flex;
            flex-direction: column;
            gap: 0.3rem;
            background: var(--gray-50);
        }
        .voucher-modal-item:last-child { margin-bottom: 0; }
        .voucher-modal-item:hover { border-color: var(--green); background: var(--green-light); }
        .voucher-modal-item.selected { border-color: var(--green); background: var(--green-light); box-shadow: 0 0 0 2px rgba(76,175,80,0.15); }
        .voucher-modal-item.disabled { opacity: 0.45; cursor: not-allowed; }
        .voucher-modal-item.disabled:hover { border-color: var(--gray-200); background: var(--gray-50); }
        .voucher-modal-item .voucher-modal-top {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            flex-wrap: wrap;
        }
        .voucher-modal-item .voucher-badge {
            font-size: 0.68rem;
            font-weight: 700;
            padding: 0.15rem 0.45rem;
            border-radius: 5px;
            text-transform: uppercase;
            letter-spacing: 0.02em;
        }
        .voucher-modal-item .voucher-badge.discount { background: #fff3e0; color: #e65100; }
        .voucher-modal-item .voucher-badge.freeship { background: #e3f2fd; color: #1565c0; }
        .voucher-modal-item .voucher-modal-code {
            font-family: 'Courier New', monospace;
            font-weight: 700;
            font-size: 0.88rem;
            color: var(--green-dark);
            letter-spacing: 0.04em;
        }
        .voucher-modal-item .voucher-modal-desc {
            font-size: 0.78rem;
            color: var(--gray-600);
            display: flex;
            align-items: center;
            gap: 0.3rem;
        }
        .voucher-modal-item .voucher-modal-meta {
            font-size: 0.72rem;
            color: var(--gray-400);
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
        }
        .voucher-modal-item .voucher-modal-meta .low { color: #f57c00; }
        .voucher-modal-empty {
            text-align: center;
            padding: 2rem 1rem;
            color: var(--gray-400);
            font-size: 0.85rem;
        }
        .voucher-modal-empty i { font-size: 2rem; display: block; margin-bottom: 0.5rem; opacity: 0.35; }
        .voucher-modal-footer {
            padding: 0.85rem 1.25rem;
            border-top: 1px solid var(--gray-200);
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: var(--gray-50);
            border-radius: 0 0 var(--radius) var(--radius);
        }
        .voucher-modal-selected-info {
            font-size: 0.8rem;
            color: var(--gray-600);
        }
        .voucher-modal-actions { display: flex; gap: 0.5rem; }
        .voucher-modal-btn-cancel {
            padding: 0.5rem 1rem;
            border: 1.5px solid var(--gray-200);
            background: var(--white);
            border-radius: var(--radius-sm);
            font-size: 0.82rem;
            font-weight: 600;
            color: var(--gray-600);
            cursor: pointer;
            transition: all 0.15s;
        }
        .voucher-modal-btn-cancel:hover { border-color: var(--gray-400); color: var(--gray-800); }
        .voucher-modal-btn-apply {
            padding: 0.5rem 1.25rem;
            background: var(--green);
            border: none;
            border-radius: var(--radius-sm);
            font-size: 0.82rem;
            font-weight: 700;
            color: #fff;
            cursor: pointer;
            transition: background 0.15s;
        }
        .voucher-modal-btn-apply:hover { background: var(--green-dark); }
        .voucher-modal-btn-apply:disabled { background: var(--gray-300); cursor: not-allowed; }

        .bill-row {
            display: flex;
            justify-content: space-between;
            font-size: 0.875rem;
            color: var(--gray-600);
            margin-bottom: 0.75rem;
        }
        .bill-row.total {
            border-top: 1px solid var(--gray-100);
            padding-top: 0.75rem;
            font-weight: 800;
            color: var(--gray-800);
            font-size: 1.05rem;
            margin-top: 0.5rem;
        }
        .bill-row.discount {
            color: #dc2626;
        }

        .payment-option {
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            padding: 0.9rem 1.1rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            cursor: pointer;
            transition: all 0.18s;
            margin-bottom: 0.75rem;
        }
        .payment-option:hover {
            background: var(--green-light);
            border-color: var(--green-mid);
        }
        .payment-option.active {
            border-color: var(--green);
            background: var(--green-light);
        }
        .payment-option input { accent-color: var(--green); }
        .payment-option i {
            font-size: 1.15rem;
            color: var(--green-dark);
            width: 20px;
            text-align: center;
        }

        .btn-checkout {
            width: 100%;
            padding: 0.9rem;
            background: var(--green);
            color: #fff;
            border: none;
            border-radius: var(--radius-sm);
            font-weight: 700;
            font-size: 1rem;
            cursor: pointer;
            box-shadow: 0 4px 14px rgba(76,175,80,0.3);
            transition: all 0.18s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
        }
        .btn-checkout:hover {
            background: var(--green-dark);
            box-shadow: 0 6px 18px rgba(56,142,60,0.35);
            transform: translateY(-1px);
        }

        .footer {
            background: var(--white);
            border-top: 1px solid var(--gray-200);
            padding: 1.5rem 2rem;
            text-align: center;
            font-size: 0.8rem;
            color: var(--gray-400);
            margin-top: auto;
        }
    </style>
</head>
<body>

    <nav class="topnav">
        <a href="home.jsp" class="nav-logo">
            <i class="fa-solid fa-apple-whole"></i> Sena Shop
        </a>
    </nav>

    <div class="container">

        <div class="breadcrumb">
            <a href="home.jsp">Trang Chủ</a>
            <i class="fa-solid fa-chevron-right" style="font-size:0.6rem;"></i>
            <a href="view-cart">Giỏ hàng</a>
            <i class="fa-solid fa-chevron-right" style="font-size:0.6rem;"></i>
            <span>Đặt hàng</span>
        </div>

        <c:if test="${not empty error}">
            <div style="background:#fee2e2; border: 1px solid #fecaca; color:#991b1b; padding:0.9rem 1.2rem; border-radius:var(--radius-sm); font-size:0.875rem; margin-bottom:1.5rem;">
                <i class="fa-solid fa-circle-exclamation" style="margin-right:0.5rem;"></i> ${error}
            </div>
        </c:if>

        <form method="post" action="checkout-cart" id="checkoutForm">
            <input type="hidden" name="selectedProducts" value="<%= selectedProductsStr %>">

            <div class="checkout-grid">
                <div class="checkout-left">
                    <div class="card">
                        <div class="card-title">
                            <i class="fa-solid fa-truck-ramp-box"></i> Thông Tin Nhận Hàng
                        </div>

                        <% 
                            if (addresses != null && !addresses.isEmpty()) { 
                                int selectedIndex = 0;
                                for (int i = 0; i < addresses.size(); i++) {
                                    if (addresses.get(i).isIsDefault()) {
                                        selectedIndex = i;
                                        break;
                                    }
                                }
                        %>
                            <div class="form-group">
                                <label class="form-label" for="savedAddressSelect">Chọn địa chỉ đã lưu</label>
                                <select class="form-select" id="savedAddressSelect" onchange="fillAddressFields()">
                                    <% 
                                        for (int i = 0; i < addresses.size(); i++) {
                                            DeliveryAddress addr = addresses.get(i);
                                            String selectedStr = (i == selectedIndex) ? "selected" : "";
                                    %>
                                        <option value="<%= addr.getId() %>" 
                                                data-name="<%= addr.getRecipientName() %>"
                                                data-phone="<%= addr.getRecipientPhone() %>"
                                                data-address="<%= addr.getAddress() %>"
                                                <%= selectedStr %>>
                                            <%= addr.getRecipientName() %> - <%= addr.getRecipientPhone() %> (<%= addr.getAddress() %>) <%= addr.isIsDefault() ? "[Mặc định]" : "" %>
                                        </option>
                                    <% } %>
                                    <option value="new">-- Nhập địa chỉ mới --</option>
                                </select>
                            </div>
                        <% } else { %>
                            <div class="address-suggestion">
                                <i class="fa-solid fa-circle-info"></i> Bạn chưa lưu địa chỉ nào. Hệ thống đã tự động điền thông tin tài khoản của bạn.
                            </div>
                        <% } %>

                        <div class="form-group">
                            <label class="form-label" for="recipientName">Tên người nhận <span style="color:#e53e3e;">*</span></label>
                            <input type="text" class="form-input" id="recipientName" name="recipientName" required placeholder="Ví dụ: Nguyễn Văn A" value="<%= Account.getFullname() != null ? Account.getFullname() : "" %>">
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="recipientPhone">Số điện thoại nhận hàng <span style="color:#e53e3e;">*</span></label>
                            <input type="tel" class="form-input" id="recipientPhone" name="recipientPhone" required placeholder="Ví dụ: 0987654321" pattern="[0-9]{9,11}" value="<%= Account.getPhone() != null ? Account.getPhone() : "" %>">
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="address">Địa chỉ giao hàng <span style="color:#e53e3e;">*</span></label>
                            <input type="text" class="form-input" id="address" name="address" required placeholder="Số nhà, ngõ, đường, phường/xã, quận/huyện, tỉnh thành" value="<%= Account.getAddress() != null ? Account.getAddress() : "" %>">
                        </div>

                        <div class="form-group" style="margin-bottom:0;">
                            <label class="form-label" for="note">Ghi chú cho shipper (nếu có)</label>
                            <textarea class="form-textarea" id="note" name="note" rows="2" placeholder="Ví dụ: Giao ngoài giờ hành chính, gọi trước 15 phút..."></textarea>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-title">
                            <i class="fa-regular fa-credit-card"></i> Phương Thức Thanh Toán
                        </div>

                        <label class="payment-option active">
                            <input type="radio" name="paymentMethod" value="COD" checked>
                            <i class="fa-solid fa-hand-holding-dollar"></i>
                            <div>
                                <strong style="display:block; font-size:0.875rem;">Thanh toán khi nhận hàng (COD)</strong>
                                <span style="font-size:0.75rem; color:var(--gray-600);">Thanh toán bằng tiền mặt khi shipper giao hàng tới nơi.</span>
                            </div>
                        </label>

                        <label class="payment-option" style="opacity: 0.6; cursor: not-allowed;" onclick="alert('Thanh toán ví điện tử MoMo đang được tích hợp.'); return false;">
                            <input type="radio" name="paymentMethod" value="Momo" disabled>
                            <i class="fa-solid fa-wallet" style="color:var(--gray-400);"></i>
                            <div>
                                <strong style="display:block; font-size:0.875rem; color:var(--gray-600);">Thanh toán qua ví MoMo (Bảo trì)</strong>
                                <span style="font-size:0.75rem; color:var(--gray-400);">Sử dụng ví MoMo để quét mã thanh toán trực tuyến.</span>
                            </div>
                        </label>

                        <label class="payment-option" style="opacity: 0.6; cursor: not-allowed;" onclick="alert('Thanh toán VNPay đang được tích hợp.'); return false;">
                            <input type="radio" name="paymentMethod" value="VNPay" disabled>
                            <i class="fa-solid fa-credit-card" style="color:var(--gray-400);"></i>
                            <div>
                                <strong style="display:block; font-size:0.875rem; color:var(--gray-600);">Thanh toán qua VNPay (Bảo trì)</strong>
                                <span style="font-size:0.75rem; color:var(--gray-400);">Liên kết thẻ ngân hàng ATM/Visa/MasterCard qua cổng VNPay.</span>
                            </div>
                        </label>
                    </div>
                </div>

                <div class="checkout-right">
                    <div class="card">
                        <div class="card-title">
                            <i class="fa-solid fa-basket-shopping"></i> Tóm Tắt Đơn Hàng
                        </div>

                        <div class="product-list" style="margin-bottom:1.25rem;">
                            <%
                                for (java.util.Map.Entry<Integer, List<CartItem>> entry : itemsByShop.entrySet()) {
                                    int shopId = entry.getKey();
                                    List<CartItem> shopItems = entry.getValue();
                                    model.Shop shop = shopMap != null ? shopMap.get(shopId) : null;
                                    String shopName = shop != null ? shop.getShopName() : "Cửa hàng #" + shopId;
                                    double shopSubtotal = shopSubtotalMap.get(shopId);
                                    double shopShip = shopShippingMap.get(shopId);
                            %>
                                <div style="margin-bottom: 1.5rem; border: 1px solid var(--gray-200); border-radius: var(--radius-sm); padding: 1rem; background: var(--gray-50);">
                                    <div style="font-weight: 700; color: var(--green-dark); margin-bottom: 0.75rem; display: flex; align-items: center; gap: 0.5rem; border-bottom: 1px solid var(--gray-200); padding-bottom: 0.5rem;">
                                        <i class="fa-solid fa-store"></i> <span id="shopName_<%= shopId %>"><%= shopName %></span>
                                    </div>
                                    <div style="display: flex; flex-direction: column; gap: 0.75rem;">
                                        <%
                                            for (CartItem item : shopItems) {
                                                double itemTotal = item.getUnitPrice() * item.getQuantity();
                                        %>
                                            <div class="product-summary" style="border: none; padding: 0; background: transparent;">
                                                <% if (item.getImage() != null && !item.getImage().trim().isEmpty()) { %>
                                                    <img src="<%= ImageUrlUtil.resolve(item.getImage(), request.getContextPath()) %>" alt="<%= item.getTitle() %>" class="product-img" onerror="this.src='https://ui-avatars.com/api/?name=F&background=4caf50&color=fff&size=80&bold=true';">
                                                <% } else { %>
                                                    <div class="product-img" style="background:var(--green-light); display:flex; align-items:center; justify-content:center; font-size:1.8rem;">🍎</div>
                                                <% } %>
                                                <div class="product-details">
                                                    <div class="product-name"><%= item.getTitle() %></div>
                                                    <div class="product-qty-price">Số lượng: <strong><%= item.getQuantity() %></strong> &times; <%= nf.format((long) item.getUnitPrice()) %> đ</div>
                                                    <div class="product-qty-price">Tạm tính: <strong><%= nf.format((long) itemTotal) %> đ</strong></div>
                                                </div>
                                            </div>
                                        <% } %>
                                    </div>
                                    <div style="display: flex; justify-content: space-between; font-size: 0.8rem; color: var(--gray-600); margin-top: 0.75rem; border-top: 1px dashed var(--gray-200); padding-top: 0.5rem;">
                                        <span>Phí vận chuyển shop:</span>
                                        <strong><%= shopShip == 0 ? "Miễn phí" : nf.format((long) shopShip) + " đ" %></strong>
                                    </div>
                                    <!-- Voucher per shop -->
                                    <div style="margin-top: 0.75rem; padding-top: 0.75rem; border-top: 1px dashed var(--gray-200);">
                                        <div style="display: flex; gap: 0.4rem; align-items: center;">
                                            <button type="button" class="voucher-trigger-btn" onclick="openShopVoucherModal('<%= shopId %>')">
                                                <i class="fa-solid fa-tag"></i> Chọn mã giảm giá <span class="voucher-arrow">></span>
                                            </button>
                                            <button type="button" class="btn-apply" style="font-size: 0.8rem; padding: 0.5rem 0.85rem;" onclick="applyVouchers()">Áp dụng</button>
                                        </div>
                                        <input type="hidden" id="shopVoucher_<%= shopId %>" name="shopVoucher_<%= shopId %>" value="">
                                        <div class="voucher-msg" id="shopVoucherMsg_<%= shopId %>" style="font-size: 0.75rem;"></div>
                                        <div id="shopDiscount_<%= shopId %>" style="font-size: 0.78rem; color: #dc2626; font-weight: 600; display: none; margin-top: 0.25rem;"></div>
                                    </div>
                                </div>
                            <% } %>
                        </div>

                        <!-- Voucher Sàn -->
                        <div class="form-group" style="margin-bottom: 1.25rem;">
                            <label class="form-label" for="platformVoucherCode">Mã giảm giá Sàn</label>
                            <div style="display: flex; gap: 0.4rem; align-items: center;">
                                <button type="button" class="voucher-trigger-btn" onclick="openPlatformVoucherModal()" style="flex:1;">
                                    <i class="fa-solid fa-shield-halved"></i> Chọn mã Sàn <span class="voucher-arrow">></span>
                                </button>
                                <button type="button" class="btn-apply" style="font-size: 0.8rem; padding: 0.5rem 0.85rem;" onclick="applyVouchers()">Áp dụng</button>
                            </div>
                            <input type="text" class="form-input" id="platformVoucherCode" name="platformVoucherCode" placeholder="Hoặc nhập mã thủ công (VD: WELCOME50)"
                                   style="font-size: 0.8rem; padding: 0.5rem 0.75rem; margin-top: 0.4rem;"
                                   onkeydown="if(event.key==='Enter'){event.preventDefault();applyVouchers();}">
                            <div class="voucher-msg" id="platformVoucherMessage"></div>
                        </div>

                        <div style="border-top:1px solid var(--gray-100); padding-top:1rem;">
                            <div class="bill-row">
                                <span>Tiền hàng:</span>
                                <strong id="totalCostValue"><%= nf.format((long) totalCost) %> đ</strong>
                            </div>
                            <!-- Tổng shop discount -->
                            <div class="bill-row discount" id="totalShopDiscountRow" style="display:none;">
                                <span>Tổng giảm Shop:</span>
                                <strong id="totalShopDiscountValue">-0 đ</strong>
                            </div>
                            <div class="bill-row discount" id="platformDiscountRow" style="display:none;">
                                <span>Giảm Sàn:</span>
                                <strong id="platformDiscountValue">-0 đ</strong>
                            </div>
                            <!-- Per-shop discount breakdown -->
                            <div id="perShopDiscountContainer"></div>
                            <div class="bill-row discount" id="totalDiscountRow" style="display:none;">
                                <span>Tổng giảm:</span>
                                <strong id="totalDiscountValue">-0 đ</strong>
                            </div>
                            <div class="bill-row">
                                <span>Phí vận chuyển:</span>
                                <strong id="shippingFeeValue"><%= nf.format((long) shippingFee) %> đ</strong>
                            </div>

                            <% if (shippingFee == 0) { %>
                                <div style="font-size:0.75rem; color:var(--green-dark); font-weight:600; text-align:right; margin-bottom:0.5rem; margin-top:-0.25rem;">
                                    <i class="fa-solid fa-circle-check"></i> Được miễn phí vận chuyển (đơn trên 200k)
                                </div>
                            <% } %>

                            <div class="bill-row total">
                                <span>Tổng cộng:</span>
                                <span id="finalCostValue" style="color:var(--green-dark);"><%= nf.format((long) finalCost) %> đ</span>
                            </div>
                        </div>
                    </div>

                    <button type="submit" class="btn-checkout">
                        <i class="fa-solid fa-shield-check"></i> Xác Nhận Mua Hàng
                    </button>

                    <a href="view-cart" style="display:block; text-align:center; font-size:0.85rem; color:var(--gray-600); text-decoration:none; margin-top:1rem; font-weight:600;">
                        <i class="fa-solid fa-chevron-left" style="font-size:0.75rem;"></i> Quay lại giỏ hàng
                    </a>
                </div>
            </div>
        </form>

    </div>

    <footer class="footer">
        &copy; 2026 Sena Shop. Hệ thống mua bán trái cây tươi ngon - chất lượng cao.
    </footer>

    <script>
        function fillAddressFields() {
            var select = document.getElementById("savedAddressSelect");
            if (!select) return;

            var selectedOption = select.options[select.selectedIndex];

            var nameField = document.getElementById("recipientName");
            var phoneField = document.getElementById("recipientPhone");
            var addrField = document.getElementById("address");

            if (selectedOption.value === "new") {
                nameField.value = "";
                phoneField.value = "";
                addrField.value = "";
            } else {
                nameField.value = selectedOption.getAttribute("data-name") || "";
                phoneField.value = selectedOption.getAttribute("data-phone") || "";
                addrField.value = selectedOption.getAttribute("data-address") || "";
            }
        }

        window.addEventListener("DOMContentLoaded", function() {
            fillAddressFields();
        });

        // Dual voucher AJAX
        var originalTotal = <%= totalCost %>;
        var originalShipping = <%= shippingFee %>;
        var appliedShopVouchers = {};   // shopId -> voucherId
        var appliedPlatformVoucherId = null;
        var lastShopSubtotals = null;
        var lastShopDiscounts = {};     // shopId -> discount amount

        // ======= VOUCHER DROPDOWN DATA =======
        // Shop vouchers: shopId -> array of voucher objects
        var shopVouchersMap = {};
        <%
        if (vouchers != null) {
            // Group shop vouchers by shopId
            java.util.Map<Integer, java.util.List<Voucher>> shopVoucherGroups = new java.util.HashMap<>();
            for (Voucher v : vouchers) {
                if (v.getShopId() != null) {
                    shopVoucherGroups.computeIfAbsent(v.getShopId(), k -> new java.util.ArrayList<>()).add(v);
                }
            }
            for (java.util.Map.Entry<Integer, java.util.List<Voucher>> entry : shopVoucherGroups.entrySet()) {
                int sid = entry.getKey();
        %>
        shopVouchersMap["<%= sid %>"] = [
            <%
            java.util.List<Voucher> vList = entry.getValue();
            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
            for (int i = 0; i < vList.size(); i++) {
                Voucher v = vList.get(i);
                boolean isFreeship = "FREESHIP".equalsIgnoreCase(v.getType());
                String endStr = v.getEndDate() != null ? sdf.format(v.getEndDate()) : "Không giới hạn";
                int remaining = v.getQuantity() - v.getUsedCount();
            %>
            {code: "<%= v.getCode() %>", type: "<%= v.getType() %>", discPct: <%= v.getDiscountPercent() %>, maxDisc: <%= v.getMaxDiscount() %>, minOrder: <%= (long) v.getMinimumOrder() %>, endDate: "<%= endStr %>", remaining: <%= remaining %>, remainingPct: <%= v.getQuantity() > 0 ? (remaining * 100.0 / v.getQuantity()) : 0 %>}<%= i < vList.size() - 1 ? "," : "" %>
            <% } %>
        ];
        <%
            }
        }
        %>

        // Platform vouchers (shopId == null)
        var platformVouchers = [
            <%
            if (vouchers != null) {
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                boolean first = true;
                for (Voucher v : vouchers) {
                    if (v.getShopId() == null) {
                        String endStr = v.getEndDate() != null ? sdf.format(v.getEndDate()) : "Không giới hạn";
                        int remaining = v.getQuantity() - v.getUsedCount();
                        if (!first) out.print(",");
            %>
            {code: "<%= v.getCode() %>", type: "<%= v.getType() %>", discPct: <%= v.getDiscountPercent() %>, maxDisc: <%= v.getMaxDiscount() %>, minOrder: <%= (long) v.getMinimumOrder() %>, endDate: "<%= endStr %>", remaining: <%= remaining %>, remainingPct: <%= v.getQuantity() > 0 ? (remaining * 100.0 / v.getQuantity()) : 0 %>}
            <%
                        first = false;
                    }
                }
            }
            %>
        ];

        // ======= POPULATE SHOP VOUCHER DROPDOWNS =======
        function populateShopVoucherDropdown(shopId) {
            var listEl = document.getElementById("voucherList_" + shopId);
            if (!listEl) return;
            var vouchers = shopVouchersMap[shopId] || [];
            var currentCode = document.getElementById("shopVoucher_" + shopId).value.trim();
            var shopSubtotal = getShopSubtotals()[shopId] || 0;

            if (vouchers.length === 0) {
                listEl.innerHTML = '<div class="voucher-dropdown-empty"><i class="fa-solid fa-ticket-simple"></i>Không có mã giảm giá cho shop này</div>';
                return;
            }

            var html = '';
            for (var i = 0; i < vouchers.length; i++) {
                var v = vouchers[i];
                var isEligible = shopSubtotal >= v.minOrder;
                var typeLabel = v.type === "FREESHIP" ? "Freeship" : "Giảm " + v.discPct + "%";
                var typeClass = v.type === "FREESHIP" ? "freeship" : "discount";
                var isSelected = currentCode === v.code;

                html += '<div class="voucher-dropdown-item' + (isSelected ? ' selected' : '') + '" '
                    + 'onclick="selectShopVoucher(\'' + shopId + '\', \'' + v.code + '\')" '
                    + (isEligible ? '' : 'style="opacity:0.5;cursor:not-allowed;" title="Đơn hàng chưa đạt mức tối thiểu ' + formatCurrency(v.minOrder) + '"') + '>'
                    + '<div class="voucher-item-code">'
                    + '<span class="voucher-item-type ' + typeClass + '">' + typeLabel + '</span>'
                    + v.code
                    + '</div>'
                    + '<div class="voucher-item-desc">' + (v.type === "FREESHIP" ? "Miễn phí vận chuyển" : "Giảm tối đa " + formatCurrency(v.maxDisc)) + '</div>'
                    + '<div class="voucher-item-min">Đơn tối thiểu: ' + formatCurrency(v.minOrder) + '</div>'
                    + '<div class="voucher-item-remaining' + (v.remainingPct < 20 ? ' low' : '') + '">Còn ' + v.remaining + ' lượt · HSD: ' + v.endDate + '</div>'
                    + '</div>';
            }
            listEl.innerHTML = html;
        }

        // Populate all shop voucher dropdowns on load
        document.addEventListener("DOMContentLoaded", function() {
            <%
            for (java.util.Map.Entry<Integer, List<CartItem>> entry : itemsByShop.entrySet()) {
                int sid = entry.getKey();
            %>
            populateShopVoucherDropdown("<%= sid %>");
            <% } %>
            populatePlatformVoucherDropdown();

            // Close dropdowns when clicking outside
            document.addEventListener("click", function(e) {
                if (!e.target.closest(".voucher-select-wrapper")) {
                    closeAllVoucherDropdowns();
                }
            });
        });

        function closeAllVoucherDropdowns() {
            document.querySelectorAll(".voucher-select-wrapper.open").forEach(function(el) {
                el.classList.remove("open");
            });
        }

        function toggleVoucherDropdown(shopId) {
            var wrapper = document.getElementById("voucherWrapper_" + shopId);
            if (wrapper.classList.contains("open")) {
                wrapper.classList.remove("open");
            } else {
                closeAllVoucherDropdowns();
                populateShopVoucherDropdown(shopId);
                wrapper.classList.add("open");
            }
        }

        function selectShopVoucher(shopId, code) {
            document.getElementById("shopVoucher_" + shopId).value = code;
            updateShopVoucherDisplay(shopId, code);
            closeAllVoucherDropdowns();
            applyVouchers();
        }

        function clearShopVoucher(shopId) {
            document.getElementById("shopVoucher_" + shopId).value = "";
            updateShopVoucherDisplay(shopId, "");
            delete appliedShopVouchers[shopId];
            delete lastShopDiscounts[shopId];
            applyVouchers();
        }

        function updateShopVoucherDisplay(shopId, code) {
            var wrapper = document.getElementById("voucherWrapper_" + shopId);
            var display = document.getElementById("voucherDisplay_" + shopId);
            if (!wrapper || !display) return;
            if (code && code.trim() !== "") {
                wrapper.classList.add("has-value");
                display.classList.add("selected");
                display.classList.remove("voucher-placeholder");
                display.innerHTML = '<span class="voucher-code-text"><i class="fa-solid fa-tag" style="margin-right:0.3rem;font-size:0.7rem;"></i>' + code.toUpperCase() + '</span><i class="fa-solid fa-chevron-right voucher-select-arrow"></i>';
            } else {
                wrapper.classList.remove("has-value");
                display.classList.remove("selected");
                display.innerHTML = '<span class="voucher-placeholder"><i class="fa-solid fa-tag" style="margin-right:0.3rem;opacity:0.5;"></i> Chọn mã giảm giá</span><i class="fa-solid fa-chevron-right voucher-select-arrow"></i>';
            }
        }

        // ======= PLATFORM VOUCHER DROPDOWN =======
        function populatePlatformVoucherDropdown() {
            var listEl = document.getElementById("platformVoucherList");
            if (!listEl) return;
            var currentCode = document.getElementById("platformVoucherCode").value.trim();
            var totalAfterShop = originalTotal;

            if (platformVouchers.length === 0) {
                listEl.innerHTML = '<div class="voucher-dropdown-empty"><i class="fa-solid fa-shield-halved"></i>Không có mã giảm giá Sàn</div>';
                return;
            }

            var html = '';
            for (var i = 0; i < platformVouchers.length; i++) {
                var v = platformVouchers[i];
                var isEligible = totalAfterShop >= v.minOrder;
                var typeLabel = v.type === "FREESHIP" ? "Freeship" : "Giảm " + v.discPct + "%";
                var typeClass = v.type === "FREESHIP" ? "freeship" : "discount";
                var isSelected = currentCode === v.code;

                html += '<div class="voucher-dropdown-item' + (isSelected ? ' selected' : '') + '" '
                    + 'onclick="selectPlatformVoucher(\'' + v.code + '\')" '
                    + (isEligible ? '' : 'style="opacity:0.5;cursor:not-allowed;" title="Đơn hàng chưa đạt mức tối thiểu ' + formatCurrency(v.minOrder) + '"') + '>'
                    + '<div class="voucher-item-code">'
                    + '<span class="voucher-item-type ' + typeClass + '">' + typeLabel + '</span>'
                    + v.code
                    + '</div>'
                    + '<div class="voucher-item-desc">' + (v.type === "FREESHIP" ? "Miễn phí vận chuyển" : "Giảm tối đa " + formatCurrency(v.maxDisc)) + '</div>'
                    + '<div class="voucher-item-min">Đơn tối thiểu: ' + formatCurrency(v.minOrder) + '</div>'
                    + '<div class="voucher-item-remaining' + (v.remainingPct < 20 ? ' low' : '') + '">Còn ' + v.remaining + ' lượt · HSD: ' + v.endDate + '</div>'
                    + '</div>';
            }
            listEl.innerHTML = html;
        }

        function togglePlatformVoucherDropdown() {
            var wrapper = document.getElementById("platformVoucherWrapper");
            if (wrapper.classList.contains("open")) {
                wrapper.classList.remove("open");
            } else {
                closeAllVoucherDropdowns();
                populatePlatformVoucherDropdown();
                wrapper.classList.add("open");
            }
        }

        function selectPlatformVoucher(code) {
            document.getElementById("platformVoucherCode").value = code;
            updatePlatformVoucherDisplay(code);
            closeAllVoucherDropdowns();
            applyVouchers();
        }

        function clearPlatformVoucher() {
            document.getElementById("platformVoucherCode").value = "";
            updatePlatformVoucherDisplay("");
            appliedPlatformVoucherId = null;
            applyVouchers();
        }

        function updatePlatformVoucherDisplay(code) {
            var wrapper = document.getElementById("platformVoucherWrapper");
            var display = document.getElementById("platformVoucherDisplay");
            if (!wrapper || !display) return;
            if (code && code.trim() !== "") {
                wrapper.classList.add("has-value");
                display.classList.add("selected");
                display.classList.remove("voucher-placeholder");
                display.innerHTML = '<span class="voucher-code-text"><i class="fa-solid fa-shield-halved" style="margin-right:0.3rem;font-size:0.7rem;"></i>' + code.toUpperCase() + '</span><i class="fa-solid fa-chevron-right voucher-select-arrow"></i>';
            } else {
                wrapper.classList.remove("has-value");
                display.classList.remove("selected");
                display.innerHTML = '<span class="voucher-placeholder"><i class="fa-solid fa-shield-halved" style="margin-right:0.3rem;opacity:0.5;"></i> Chọn mã Sàn</span><i class="fa-solid fa-chevron-right voucher-select-arrow"></i>';
            }
        }

        function formatCurrency(number) {
            return new Intl.NumberFormat('vi-VN').format(number) + " đ";
        }

        function getShopSubtotals() {
            var shopSubtotals = {};
            <%
            for (java.util.Map.Entry<Integer, Double> entry : shopSubtotalMap.entrySet()) {
            %>
                shopSubtotals["<%= entry.getKey() %>"] = <%= entry.getValue() %>;
            <%
            }
            %>
            return shopSubtotals;
        }

        function getShopVoucherCodes() {
            var codes = {};
            var inputs = document.querySelectorAll("input[name^='shopVoucher_']");
            inputs.forEach(function(input) {
                var name = input.name; // shopVoucher_123
                var shopId = name.replace("shopVoucher_", "");
                codes[shopId] = input.value.trim();
            });
            return codes;
        }

        function applyVouchers() {
            var platformCode = document.getElementById("platformVoucherCode").value.trim();
            var shopCodes = getShopVoucherCodes();
            var hasShopCode = Object.values(shopCodes).some(function(v) { return v !== ""; });

            if (!hasShopCode && platformCode === "") {
                clearVoucherDisplay();
                return;
            }

            var shopSubtotals = getShopSubtotals();
            lastShopSubtotals = shopSubtotals;

            var url = "<%= request.getContextPath() %>/checkout?action=checkVouchers";
            var params = "platformVoucherCode=" + encodeURIComponent(platformCode)
                       + "&totalSubtotal=" + originalTotal
                       + "&shopSubtotals=" + encodeURIComponent(JSON.stringify(shopSubtotals));

            // Append each shop voucher code
            for (var shopId in shopCodes) {
                params += "&shopVoucher_" + shopId + "=" + encodeURIComponent(shopCodes[shopId]);
            }

            fetch(url, {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: params
            })
                .then(response => response.json())
                .then(data => {
                    // Update per-shop voucher messages
                    for (var shopId in shopCodes) {
                        var msgDiv = document.getElementById("shopVoucherMsg_" + shopId);
                        var discountDiv = document.getElementById("shopDiscount_" + shopId);
                        var input = document.getElementById("shopVoucher_" + shopId);
                        if (!msgDiv) continue;

                        var shopDiscountKey = "shop_" + shopId + "_discount";
                        var shopMsgKey = "shop_" + shopId + "_msg";

                        if (shopCodes[shopId] !== "") {
                            if (data[shopDiscountKey] && data[shopDiscountKey] > 0) {
                                msgDiv.className = "voucher-msg success";
                                msgDiv.innerHTML = '<i class="fa-solid fa-circle-check"></i> Áp dụng thành công!';
                                discountDiv.style.display = "block";
                                discountDiv.innerHTML = '<i class="fa-solid fa-tag"></i> Giảm: -' + formatCurrency(data[shopDiscountKey]);
                                appliedShopVouchers[shopId] = data["shop_" + shopId + "_id"];
                                lastShopDiscounts[shopId] = data[shopDiscountKey];
                            } else if (data[shopMsgKey]) {
                                msgDiv.className = "voucher-msg error";
                                msgDiv.innerHTML = '<i class="fa-solid fa-circle-xmark"></i> ' + data[shopMsgKey];
                                discountDiv.style.display = "none";
                                delete appliedShopVouchers[shopId];
                                delete lastShopDiscounts[shopId];
                            } else {
                                msgDiv.className = "voucher-msg error";
                                msgDiv.innerHTML = '<i class="fa-solid fa-circle-xmark"></i> Mã không hợp lệ';
                                discountDiv.style.display = "none";
                                delete appliedShopVouchers[shopId];
                                delete lastShopDiscounts[shopId];
                            }
                        } else {
                            msgDiv.className = "voucher-msg";
                            msgDiv.innerText = "";
                            discountDiv.style.display = "none";
                            delete appliedShopVouchers[shopId];
                            delete lastShopDiscounts[shopId];
                        }
                    }

                    // Platform voucher message
                    var platformMsgDiv = document.getElementById("platformVoucherMessage");
                    platformMsgDiv.className = "voucher-msg";
                    platformMsgDiv.innerText = "";
                    if (platformCode !== "") {
                        if (data.platformDiscount > 0) {
                            platformMsgDiv.className = "voucher-msg success";
                            platformMsgDiv.innerHTML = '<i class="fa-solid fa-circle-check"></i> Áp dụng thành công!';
                            appliedPlatformVoucherId = data.platformVoucherId;
                        } else if (data.platformVoucherError) {
                            platformMsgDiv.className = "voucher-msg error";
                            platformMsgDiv.innerHTML = '<i class="fa-solid fa-circle-xmark"></i> ' + data.platformVoucherError;
                            appliedPlatformVoucherId = null;
                        } else if (!data.success) {
                            platformMsgDiv.className = "voucher-msg error";
                            platformMsgDiv.innerHTML = '<i class="fa-solid fa-circle-xmark"></i> ' + (data.message || "Mã không hợp lệ");
                            appliedPlatformVoucherId = null;
                        }
                    } else {
                        appliedPlatformVoucherId = null;
                    }

                    updateBillDisplay(data);
                })
                .catch(err => {
                    console.error("Lỗi AJAX voucher:", err);
                    var platformMsgDiv = document.getElementById("platformVoucherMessage");
                    platformMsgDiv.className = "voucher-msg error";
                    platformMsgDiv.innerText = "Lỗi khi kiểm tra mã giảm giá.";
                    clearVoucherDisplay();
                });
        }

        function updateBillDisplay(data) {
            var totalShopDiscount = data.totalShopDiscount || 0;
            var platformDiscount = data.platformDiscount || 0;
            var totalDiscount = data.totalDiscount || 0;
            var finalTotal = data.finalTotal || originalTotal;

            // Total shop discount row
            var totalShopRow = document.getElementById("totalShopDiscountRow");
            var totalShopVal = document.getElementById("totalShopDiscountValue");
            if (totalShopDiscount > 0) {
                totalShopRow.style.display = "flex";
                totalShopVal.innerText = "-" + formatCurrency(totalShopDiscount);
            } else {
                totalShopRow.style.display = "none";
            }

            // Per-shop discount breakdown
            var container = document.getElementById("perShopDiscountContainer");
            container.innerHTML = "";
            if (lastShopDiscounts) {
                for (var shopId in lastShopDiscounts) {
                    var discount = lastShopDiscounts[shopId];
                    if (discount && discount > 0) {
                        var div = document.createElement("div");
                        div.className = "bill-row discount";
                        div.style.display = "flex";
                        div.innerHTML = '<span style="font-size:0.78rem; color:var(--gray-600); padding-left:0.5rem;">◦ Shop #' + shopId + ':</span><strong>-' + formatCurrency(discount) + '</strong>';
                        container.appendChild(div);
                    }
                }
            }

            // Platform discount row
            var platformRow = document.getElementById("platformDiscountRow");
            var platformVal = document.getElementById("platformDiscountValue");
            if (platformDiscount > 0) {
                platformRow.style.display = "flex";
                platformVal.innerText = "-" + formatCurrency(platformDiscount);
            } else {
                platformRow.style.display = "none";
            }

            // Total discount
            var totalRow = document.getElementById("totalDiscountRow");
            var totalVal = document.getElementById("totalDiscountValue");
            if (totalDiscount > 0) {
                totalRow.style.display = "flex";
                totalVal.innerText = "-" + formatCurrency(totalDiscount);
            } else {
                totalRow.style.display = "none";
            }

            // Final total
            var finalCostVal = document.getElementById("finalCostValue");
            finalCostVal.innerText = formatCurrency(finalTotal + originalShipping);
        }

        function clearVoucherDisplay() {
            document.getElementById("totalShopDiscountRow").style.display = "none";
            document.getElementById("platformDiscountRow").style.display = "none";
            document.getElementById("totalDiscountRow").style.display = "none";
            document.getElementById("perShopDiscountContainer").innerHTML = "";
            document.getElementById("finalCostValue").innerText = formatCurrency(originalTotal + originalShipping);
            appliedShopVouchers = {};
            appliedPlatformVoucherId = null;
            lastShopDiscounts = {};

            // Clear per-shop messages
            var msgDivs = document.querySelectorAll("[id^='shopVoucherMsg_']");
            msgDivs.forEach(function(div) { div.className = "voucher-msg"; div.innerText = ""; });
            var discountDivs = document.querySelectorAll("[id^='shopDiscount_']");
            discountDivs.forEach(function(div) { div.style.display = "none"; });

            document.getElementById("platformVoucherMessage").className = "voucher-msg";
            document.getElementById("platformVoucherMessage").innerText = "";
        }

        document.getElementById("checkoutForm").addEventListener("submit", function(e) {
            // Voucher codes are already in the form inputs, no hidden fields needed
        });

        // ======= VOUCHER MODAL SYSTEM =======
        // Shop vouchers: shopId -> array of voucher objects
        var shopVouchersMap = {};
        <%
        if (vouchers != null) {
            java.util.Map<Integer, java.util.List<Voucher>> shopVoucherGroups = new java.util.HashMap<>();
            for (Voucher v : vouchers) {
                if (v.getShopId() != null) {
                    shopVoucherGroups.computeIfAbsent(v.getShopId(), k -> new java.util.ArrayList<>()).add(v);
                }
            }
            for (java.util.Map.Entry<Integer, java.util.List<Voucher>> entry : shopVoucherGroups.entrySet()) {
                int sid = entry.getKey();
        %>
        shopVouchersMap["<%= sid %>"] = [
            <%
            java.util.List<Voucher> vList = entry.getValue();
            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
            for (int i = 0; i < vList.size(); i++) {
                Voucher v = vList.get(i);
                String endStr = v.getEndDate() != null ? sdf.format(v.getEndDate()) : "Không giới hạn";
                int remaining = v.getQuantity() - v.getUsedCount();
            %>
            {code: "<%= v.getCode() %>", type: "<%= v.getType() %>", discPct: <%= v.getDiscountPercent() %>, maxDisc: <%= v.getMaxDiscount() %>, minOrder: <%= (long) v.getMinimumOrder() %>, endDate: "<%= endStr %>", remaining: <%= remaining %>, remainingPct: <%= v.getQuantity() > 0 ? (remaining * 100.0 / v.getQuantity()) : 0 %>}<%= i < vList.size() - 1 ? "," : "" %>
            <% } %>
        ];
        <%
            }
        }
        %>

        // Platform vouchers (shopId == null)
        var platformVouchers = [
            <%
            if (vouchers != null) {
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                boolean first = true;
                for (Voucher v : vouchers) {
                    if (v.getShopId() == null) {
                        String endStr = v.getEndDate() != null ? sdf.format(v.getEndDate()) : "Không giới hạn";
                        int remaining = v.getQuantity() - v.getUsedCount();
                        if (!first) out.print(",");
            %>
            {code: "<%= v.getCode() %>", type: "<%= v.getType() %>", discPct: <%= v.getDiscountPercent() %>, maxDisc: <%= v.getMaxDiscount() %>, minOrder: <%= (long) v.getMinimumOrder() %>, endDate: "<%= endStr %>", remaining: <%= remaining %>, remainingPct: <%= v.getQuantity() > 0 ? (remaining * 100.0 / v.getQuantity()) : 0 %>}
            <%
                        first = false;
                    }
                }
            }
            %>
        ];

        // Modal state
        var platformModalSelectedCode = "";
        window.currentShopVoucherModal = null;
        window.shopModalSelectedCode = "";

        // ======= PLATFORM VOUCHER MODAL =======
        function openPlatformVoucherModal() {
            platformModalSelectedCode = (document.getElementById("platformVoucherCode") || {value:""}).value.trim();
            renderPlatformVoucherModal();
            document.getElementById("platformVoucherModal").classList.add("active");
        }
        function closePlatformVoucherModal() {
            document.getElementById("platformVoucherModal").classList.remove("active");
        }
        function renderPlatformVoucherModal() {
            var body = document.getElementById("platformVoucherModalBody");
            var footer = document.getElementById("platformVoucherModalFooter");
            var totalAfterShop = originalTotal;
            if (platformVouchers.length === 0) {
                body.innerHTML = '<div class="voucher-modal-empty"><i class="fa-solid fa-ticket-simple"></i>Không có mã giảm giá Sàn nào khả dụng</div>';
                footer.style.display = "none";
                return;
            }
            footer.style.display = "flex";
            var html = '<div class="voucher-modal-section-title"><i class="fa-solid fa-shield-halved"></i> Mã giảm giá Sàn khả dụng</div>';
            for (var i = 0; i < platformVouchers.length; i++) {
                var v = platformVouchers[i];
                var isEligible = totalAfterShop >= v.minOrder;
                var typeLabel = v.type === "FREESHIP" ? "Freeship" : "Giảm " + v.discPct + "%";
                var typeClass = v.type === "FREESHIP" ? "freeship" : "discount";
                var isSelected = platformModalSelectedCode === v.code;
                var titleAttr = isEligible ? '' : ' title="Đơn hàng chưa đạt mức tối thiểu ' + formatCurrency(v.minOrder) + '"';
                html += '<div class="voucher-modal-item' + (isSelected ? ' selected' : '') + (!isEligible ? ' disabled' : '') + '" data-code="' + v.code + '"' + titleAttr + '>'
                    + '<div class="voucher-modal-top">'
                    + '<span class="voucher-badge ' + typeClass + '">' + typeLabel + '</span>'
                    + '<span class="voucher-modal-code">' + v.code + '</span>'
                    + '</div>'
                    + '<div class="voucher-modal-desc"><i class="fa-solid fa-tag"></i> ' + (v.type === "FREESHIP" ? "Miễn phí vận chuyển" : "Giảm tối đa " + formatCurrency(v.maxDisc)) + '</div>'
                    + '<div class="voucher-modal-meta"><span>Đơn tối thiểu: ' + formatCurrency(v.minOrder) + '</span><span class="' + (v.remainingPct < 20 ? 'low' : '') + '">Còn ' + v.remaining + ' lượt</span><span>HSD: ' + v.endDate + '</span></div>'
                    + '</div>';
            }
            body.innerHTML = html;
            var infoEl = document.getElementById("platformModalSelectedInfo");
            var applyBtn = document.getElementById("platformModalApplyBtn");
            if (platformModalSelectedCode) {
                infoEl.textContent = 'Đã chọn: ' + platformModalSelectedCode;
                applyBtn.disabled = false;
            } else {
                infoEl.textContent = "Chưa chọn mã nào";
                applyBtn.disabled = true;
            }
            // Bind click events using addEventListener
            var items = body.querySelectorAll(".voucher-modal-item:not(.disabled)");
            items.forEach(function(item) {
                item.addEventListener("click", function() {
                    var code = this.getAttribute("data-code");
                    selectPlatformVoucherInModal(code);
                });
            });
        }
        function selectPlatformVoucherInModal(code) {
            platformModalSelectedCode = code;
            renderPlatformVoucherModal();
        }
        function confirmPlatformVoucherFromModal() {
            var input = document.getElementById("platformVoucherCode");
            if (input) input.value = platformModalSelectedCode;
            closePlatformVoucherModal();
            applyVouchers();
        }

        // ======= SHOP VOUCHER MODAL =======
        function openShopVoucherModal(shopId) {
            window.currentShopVoucherModal = shopId;
            var input = document.getElementById("shopVoucher_" + shopId);
            window.shopModalSelectedCode = input ? input.value.trim() : "";
            renderShopVoucherModal(shopId);
            document.getElementById("shopVoucherModal").classList.add("active");
        }
        function closeShopVoucherModal() {
            document.getElementById("shopVoucherModal").classList.remove("active");
        }
        function renderShopVoucherModal(shopId) {
            var body = document.getElementById("shopVoucherModalBody");
            var footer = document.getElementById("shopVoucherModalFooter");
            var vouchers = shopVouchersMap[shopId] || [];
            var shopSubtotal = getShopSubtotals()[shopId] || 0;
            var titleEl = document.getElementById("shopVoucherModalTitle");
            if (titleEl) {
                var shopTitleEl = document.getElementById("shopName_" + shopId);
                var shopName = shopTitleEl ? shopTitleEl.textContent : ("Shop #" + shopId);
                titleEl.innerHTML = '<i class="fa-solid fa-tag"></i> Mã giảm giá - ' + shopName;
            }
            if (vouchers.length === 0) {
                body.innerHTML = '<div class="voucher-modal-empty"><i class="fa-solid fa-ticket-simple"></i>Không có mã giảm giá cho cửa hàng này</div>';
                footer.style.display = "none";
                return;
            }
            footer.style.display = "flex";
            var html = '<div class="voucher-modal-section-title"><i class="fa-solid fa-store"></i> Mã giảm giá cửa hàng khả dụng</div>';
            for (var i = 0; i < vouchers.length; i++) {
                var v = vouchers[i];
                var isEligible = shopSubtotal >= v.minOrder;
                var typeLabel = v.type === "FREESHIP" ? "Freeship" : "Giảm " + v.discPct + "%";
                var typeClass = v.type === "FREESHIP" ? "freeship" : "discount";
                var isSelected = window.shopModalSelectedCode === v.code;
                var titleAttr = isEligible ? '' : ' title="Đơn hàng chưa đạt mức tối thiểu ' + formatCurrency(v.minOrder) + '"';
                html += '<div class="voucher-modal-item' + (isSelected ? ' selected' : '') + (!isEligible ? ' disabled' : '') + '" data-shopid="' + shopId + '" data-code="' + v.code + '"' + titleAttr + '>'
                    + '<div class="voucher-modal-top">'
                    + '<span class="voucher-badge ' + typeClass + '">' + typeLabel + '</span>'
                    + '<span class="voucher-modal-code">' + v.code + '</span>'
                    + '</div>'
                    + '<div class="voucher-modal-desc"><i class="fa-solid fa-tag"></i> ' + (v.type === "FREESHIP" ? "Miễn phí vận chuyển" : "Giảm tối đa " + formatCurrency(v.maxDisc)) + '</div>'
                    + '<div class="voucher-modal-meta"><span>Đơn tối thiểu: ' + formatCurrency(v.minOrder) + '</span><span class="' + (v.remainingPct < 20 ? 'low' : '') + '">Còn ' + v.remaining + ' lượt</span><span>HSD: ' + v.endDate + '</span></div>'
                    + '</div>';
            }
            body.innerHTML = html;
            var infoEl = document.getElementById("shopModalSelectedInfo");
            var applyBtn = document.getElementById("shopModalApplyBtn");
            if (window.shopModalSelectedCode) {
                infoEl.textContent = 'Đã chọn: ' + window.shopModalSelectedCode;
                applyBtn.disabled = false;
            } else {
                infoEl.textContent = "Chưa chọn mã nào";
                applyBtn.disabled = true;
            }
            // Bind click events using addEventListener
            var items = body.querySelectorAll(".voucher-modal-item:not(.disabled)");
            items.forEach(function(item) {
                item.addEventListener("click", function() {
                    var sid = this.getAttribute("data-shopid");
                    var code = this.getAttribute("data-code");
                    selectShopVoucherInModal(sid, code);
                });
            });
        }
        function selectShopVoucherInModal(shopId, code) {
            window.shopModalSelectedCode = code;
            renderShopVoucherModal(shopId);
        }
        function confirmShopVoucherFromModal() {
            var shopId = window.currentShopVoucherModal;
            var input = document.getElementById("shopVoucher_" + shopId);
            if (input) input.value = window.shopModalSelectedCode;
            closeShopVoucherModal();
            applyVouchers();
        }

        // ======= TRIGGER BUTTONS =======
        function toggleVoucherDropdown(shopId) { openShopVoucherModal(shopId); }
        function togglePlatformVoucherDropdown() { openPlatformVoucherModal(); }

        // Close on ESC
        document.addEventListener("keydown", function(e) {
            if (e.key === "Escape") {
                closePlatformVoucherModal();
                closeShopVoucherModal();
            }
        });
    </script>

    <!-- ========== VOUCHER MODALS ========== -->
    <div class="voucher-modal-overlay" id="platformVoucherModal" onclick="if(event.target===this)closePlatformVoucherModal()">
        <div class="voucher-modal">
            <div class="voucher-modal-header">
                <h3><i class="fa-solid fa-shield-halved"></i> Mã Giảm Giá Sàn</h3>
                <button class="voucher-modal-close" onclick="closePlatformVoucherModal()"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="voucher-modal-body" id="platformVoucherModalBody"></div>
            <div class="voucher-modal-footer" id="platformVoucherModalFooter">
                <span class="voucher-modal-selected-info" id="platformModalSelectedInfo">Chưa chọn mã nào</span>
                <div class="voucher-modal-actions">
                    <button class="voucher-modal-btn-cancel" onclick="closePlatformVoucherModal()">Đóng</button>
                    <button class="voucher-modal-btn-apply" id="platformModalApplyBtn" onclick="confirmPlatformVoucherFromModal()" disabled>Áp dụng mã</button>
                </div>
            </div>
        </div>
    </div>

    <div class="voucher-modal-overlay" id="shopVoucherModal" onclick="if(event.target===this)closeShopVoucherModal()">
        <div class="voucher-modal">
            <div class="voucher-modal-header">
                <h3 id="shopVoucherModalTitle"><i class="fa-solid fa-tag"></i> Mã Giảm Giá Shop</h3>
                <button class="voucher-modal-close" onclick="closeShopVoucherModal()"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="voucher-modal-body" id="shopVoucherModalBody"></div>
            <div class="voucher-modal-footer" id="shopVoucherModalFooter">
                <span class="voucher-modal-selected-info" id="shopModalSelectedInfo">Chưa chọn mã nào</span>
                <div class="voucher-modal-actions">
                    <button class="voucher-modal-btn-cancel" onclick="closeShopVoucherModal()">Đóng</button>
                    <button class="voucher-modal-btn-apply" id="shopModalApplyBtn" onclick="confirmShopVoucherFromModal()" disabled>Áp dụng mã</button>
                </div>
            </div>
        </div>
    </div>

</body>
</html>

