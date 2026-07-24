<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Wishlist" %>
<%@ page import="model.WishlistItem" %>
<%@ page import="Utils.ImageUrlUtil" %>
<%@ page import="model.Account" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    Account Account = (Account) session.getAttribute("Account");
    if (Account == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    Wishlist wishlist = (Wishlist) request.getAttribute("wishlist");
    if (wishlist == null) {
        wishlist = new Wishlist();
    }

    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");

    NumberFormat nf = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi"));
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yêu Thích | SenaFruit</title>
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

        /* PAGE */
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
        .alert-info    { background: #dbeafe; border: 1px solid #bfdbfe; color: #1e40af; }

        /* WISHLIST CARD */
        .wishlist-card {
            background: var(--white);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            overflow: hidden;
        }

        /* SELECT ALL BAR */
        .select-all-bar {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1rem 1.5rem;
            background: var(--gray-50);
            border-bottom: 1px solid var(--gray-100);
        }

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

        .select-all-bar .select-info {
            font-size: 0.875rem;
            color: var(--gray-600);
            font-weight: 500;
        }

        .select-all-bar .select-info strong {
            color: var(--gray-800);
        }

        /* WISHLIST ITEM */
        .wishlist-item {
            display: grid;
            grid-template-columns: 50px 100px 1fr 140px 200px;
            gap: 1rem;
            align-items: center;
            padding: 1.1rem 1.5rem;
            border-bottom: 1px solid var(--gray-100);
        }

        .wishlist-item:last-child { border-bottom: none; }

        /* CUSTOM CHECKBOX (item) */
        .item-checkbox {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .item-image {
            width: 100px;
            height: 100px;
            border-radius: var(--radius-sm);
            overflow: hidden;
            background: var(--gray-50);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .item-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .item-details { display: grid; gap: 0.35rem; }

        .item-title {
            font-size: 1rem;
            font-weight: 700;
            color: var(--gray-800);
            text-decoration: none;
        }

        .item-title:hover { color: var(--green); }

        .item-meta { color: var(--gray-400); font-size: 0.875rem; }

        .item-price {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--gray-800);
        }

        /* STOCK BADGE */
        .stock-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            padding: 0.25rem 0.6rem;
            border-radius: 6px;
            font-size: 0.72rem;
            font-weight: 700;
        }

        .stock-available { background: #dcfce7; color: #166534; }
        .stock-low { background: #fef9c3; color: #854d0e; }
        .stock-out { background: #fee2e2; color: #991b1b; }

        /* ITEM ACTIONS */
        .item-actions { display: flex; gap: 0.5rem; align-items: center; }

        /* BOTTOM ACTION BAR */
        .bottom-bar {
            padding: 1.25rem 1.5rem;
            background: var(--white);
            border-top: 1.5px solid var(--gray-200);
            display: flex;
            align-items: center;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .bottom-bar .left-info {
            font-size: 0.875rem;
            color: var(--gray-600);
            font-weight: 500;
        }

        .bottom-bar .left-info strong {
            color: var(--gray-800);
        }

        .bottom-bar .right-actions {
            margin-left: auto;
            display: flex;
            gap: 0.75rem;
            flex-wrap: wrap;
        }

        /* BUTTONS */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.4rem;
            padding: 0.75rem 1.25rem;
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
        }

        .btn-orange {
            background: var(--orange);
            color: #fff;
            box-shadow: 0 2px 8px rgba(243,156,18,0.3);
        }

        .btn-orange:hover {
            background: var(--orange-dark);
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

        .btn-disabled {
            background: var(--gray-100);
            color: var(--gray-400);
            cursor: not-allowed;
            border: 2px solid var(--gray-200);
            padding: 0.6rem 1rem;
            opacity: 0.7;
        }

        /* EMPTY STATE */
        .empty-state {
            text-align: center;
            padding: 3.5rem 1rem;
        }

        .empty-state-icon { font-size: 4.5rem; color: var(--gray-200); margin-bottom: 1rem; }
        .empty-state h2 { font-size: 1.5rem; margin-bottom: 0.5rem; }
        .empty-state p { color: var(--gray-400); margin-bottom: 1.5rem; }

        /* RESPONSIVE */
        @media (max-width: 900px) {
            .wishlist-item {
                grid-template-columns: 40px 80px 1fr 140px;
            }
            .item-actions { flex-direction: column; align-items: flex-end; gap: 0.4rem; }
        }

        @media (max-width: 640px) {
            .page-wrap { padding: 1rem; }
            .wishlist-item { padding: 1rem; grid-template-columns: 40px 80px 1fr; }
            .item-price { display: none; }
            .bottom-bar { flex-direction: column; align-items: stretch; }
            .bottom-bar .right-actions { margin-left: 0; }
        }
    </style>
</head>
<body>

<nav class="topnav">
    <a href="home.jsp" class="nav-logo">
        <i class="fa-solid fa-apple-whole"></i> SenaFruit
    </a>
    <div class="nav-right">
        <a href="wishlist" class="nav-icon-btn" title="Yêu Thích" style="background: #fff5f5; color: var(--red);">
            <i class="fa-solid fa-heart"></i>
            <% Integer wlCount = (Integer) session.getAttribute("wishlistCount"); %>
            <% if (wlCount != null && wlCount > 0) { %>
            <span class="wishlist-badge"><%= wlCount %></span>
            <% } %>
        </a>
        <img class="nav-avatar" src="<%= Account.getAvatar() != null ? Account.getAvatar() : "https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(Account.getFullname(), "UTF-8") + "&background=4caf50&color=fff&size=80&bold=true&rounded=true" %>" alt="avatar">
    </div>
</nav>

<div class="page-wrap">
    <div class="breadcrumb">
        <a href="home.jsp">Trang Chủ</a> / Yêu Thích
    </div>

    <h1 class="page-title">Sản Phẩm Yêu Thích</h1>

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

    <div class="wishlist-card">
        <% if (wishlist.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-state-icon"><i class="fa-solid fa-heart"></i></div>
                <h2>Wishlist Dang Trong</h2>
                <p>Hay them san pham yeu thich de luu lai va chuyen vao gio hang sau.</p>
                <a href="home.jsp" class="btn btn-green" style="display:inline-flex; margin-top: 0.5rem;">
                    <i class="fa-solid fa-basket-shopping"></i> Kham Pha Sản Phẩm
                </a>
            </div>
        <% } else { %>

           
            <div class="select-all-bar">
                <label class="custom-checkbox" id="selectAllLabel">
                    <input type="checkbox" id="selectAllCheckbox" onchange="toggleSelectAll()">
                    <span class="checkmark">
                        <i class="fa-solid fa-check"></i>
                    </span>
                    <span class="select-info" style="margin-left:0.5rem;">Chon Tat Ca</span>
                </label>
                <span class="select-info" id="selectedCountInfo">
                    Da chon <strong id="selectedCountNum">0</strong> / <%= wishlist.getTotalItems() %> san pham
                </span>
            </div>

            <% for (WishlistItem item : wishlist.getItems()) {
                boolean isOutOfStock = item.getStockQuantity() <= 0;
                boolean isLowStock = item.getStockQuantity() > 0 && item.getStockQuantity() <= 20;
            %>
            <div class="wishlist-item"
                 data-product-id="<%= item.getProductId() %>"
                 data-in-stock="<%= !isOutOfStock %>">

       
                <div class="item-checkbox">
                    <% if (!isOutOfStock) { %>
                    <label class="custom-checkbox">
                        <input type="checkbox" class="product-checkbox"
                               value="<%= item.getProductId() %>"
                               onchange="onItemCheckChange()">
                        <span class="checkmark">
                            <i class="fa-solid fa-check"></i>
                        </span>
                    </label>
                    <% } else { %>
                    <span title="San pham het hang" style="color:var(--gray-400); font-size:0.8rem;">
                        <i class="fa-solid fa-ban"></i>
                    </span>
                    <% } %>
                </div>

                <!-- Image -->
                <div class="item-image">
                    <% if (item.getImage() != null && !item.getImage().trim().isEmpty()) { %>
                        <img src="<%= ImageUrlUtil.resolve(item.getImage(), request.getContextPath()) %>" alt="<%= item.getTitle() %>">
                    <% } else { %>
                        <span style="font-size: 2rem;">&#127822;</span>
                    <% } %>
                </div>

               
                <div class="item-details">
                    <a href="info?id=<%= item.getProductId() %>" class="item-title">
                        <%= item.getTitle() != null ? item.getTitle() : "San pham" %>
                    </a>
                    <div class="item-meta">
                        Don gia: <strong><%= nf.format((long) item.getUnitPrice()) %> d</strong>
                        &bull;
                        Don vi: <%= item.getUnit() != null ? item.getUnit() : "-" %>
                    </div>
                    <div class="item-meta">
                        <% if (isOutOfStock) { %>
                            <span class="stock-badge stock-out">
                                <i class="fa-solid fa-circle-xmark"></i> Het Hang
                            </span>
                        <% } else if (isLowStock) { %>
                            <span class="stock-badge stock-low">
                                <i class="fa-solid fa-circle-exclamation"></i> Chi con <%= item.getStockQuantity() %>
                            </span>
                        <% } else { %>
                            <span class="stock-badge stock-available">
                                <i class="fa-solid fa-check-circle"></i> Con <%= item.getStockQuantity() %>
                            </span>
                        <% } %>
                    </div>
                </div>

            
                <div class="item-price">
                    <%= nf.format((long) item.getUnitPrice()) %> d
                </div>

               
                <div class="item-actions">
                   
                    <form action="remove-wishlist" method="POST" style="display:inline;" onsubmit="return confirm('Xoa san pham nay khoi wishlist?')">
                        <input type="hidden" name="productId" value="<%= item.getProductId() %>">
                        <button type="submit" class="btn btn-danger" title="Xoa khoi wishlist">
                            <i class="fa-solid fa-trash"></i>
                        </button>
                    </form>
                </div>
            </div>
            <% } %>

         
            <div class="bottom-bar">
                <div class="left-info">
                    Da chon <strong id="summarySelectedCount">0</strong> san pham
                </div>
                <div class="right-actions">
                    <a href="home.jsp" class="btn btn-secondary">
                        <i class="fa-solid fa-arrow-left"></i> Tiep Tuc Mua Sắm
                    </a>
                    <form id="moveToCartForm" action="move-wishlist-to-cart-redirect" method="POST" style="display:inline;">
                        <input type="hidden" id="selectedProductIds" name="productIds" value="">
                        <button type="button" class="btn btn-green" id="moveSelectedBtn" onclick="moveSelectedToCart()" disabled>
                            Chuyen vao gio hang (<span id="moveSelectedCount">0</span>)
                        </button>
                    </form>
                    <button type="button" class="btn btn-orange" id="buySelectedBtn" onclick="buySelected()" disabled>
                        <i class="fa-solid fa-credit-card"></i> Mua Hang (<span id="buySelectedCount">0</span>)
                    </button>
                    <form id="buyForm" action="move-wishlist-to-cart-redirect" method="POST" style="display:none;">
                        <input type="hidden" id="buyProductIds" name="productIds" value="">
                    </form>
                </div>
            </div>
        <% } %>
    </div>
</div>

<script>
    const totalItems = <%= wishlist.isEmpty() ? 0 : wishlist.getTotalItems() %>;

  
    function toggleSelectAll() {
        const selectAll = document.getElementById('selectAllCheckbox');
        const checked = selectAll.checked;

        document.querySelectorAll('.product-checkbox').forEach(function(cb) {
            cb.checked = checked;
        });

        recalcUI();
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

    function onItemCheckChange() {
        updateAllSelectAllState();
        recalcUI();
    }

    function recalcUI() {
        const checkedBoxes = document.querySelectorAll('.product-checkbox:checked');
        const count = checkedBoxes.length;

        document.getElementById('selectedCountNum').textContent = count;
        document.getElementById('summarySelectedCount').textContent = count;
        document.getElementById('moveSelectedCount').textContent = count;
        document.getElementById('buySelectedCount').textContent = count;

        const moveBtn = document.getElementById('moveSelectedBtn');
        const buyBtn = document.getElementById('buySelectedBtn');

        if (count === 0) {
            moveBtn.disabled = true;
            moveBtn.style.opacity = '0.5';
            moveBtn.style.cursor = 'not-allowed';
            buyBtn.disabled = true;
            buyBtn.style.opacity = '0.5';
            buyBtn.style.cursor = 'not-allowed';
        } else {
            moveBtn.disabled = false;
            moveBtn.style.opacity = '1';
            moveBtn.style.cursor = 'pointer';
            buyBtn.disabled = false;
            buyBtn.style.opacity = '1';
            buyBtn.style.cursor = 'pointer';
        }

        updateAllSelectAllState();
    }

 
    function buySelected() {
        const checkedBoxes = document.querySelectorAll('.product-checkbox:checked');
        if (checkedBoxes.length === 0) return;

        const selectedIds = Array.from(checkedBoxes).map(function(cb) { return cb.value; });

        // Chuyen tat ca vao gio hang roi chuyen den trang gio hang
        document.getElementById('buyProductIds').value = selectedIds.join(',');
        document.getElementById('buyForm').submit();
    }


    function moveSelectedToCart() {
        const checkedBoxes = document.querySelectorAll('.product-checkbox:checked');
        if (checkedBoxes.length === 0) return;

        const selectedIds = Array.from(checkedBoxes).map(function(cb) { return cb.value; });
        document.getElementById('selectedProductIds').value = selectedIds.join(',');
        document.getElementById('moveToCartForm').submit();
    }


    document.addEventListener('DOMContentLoaded', function() {
        updateAllSelectAllState();
        recalcUI();
    });
</script>

</body>
</html>

