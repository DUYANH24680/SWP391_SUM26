<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- Trigger recompile --%>
<%@ page import="model.Account" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    Account acc = (Account) session.getAttribute("Account");
    if (acc == null) {
        response.sendRedirect(request.getContextPath() + "/profile");
        return;
    }

    String avatarUrl = acc.getAvatar();
    if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
        String fullname = acc.getFullname() != null ? acc.getFullname() : acc.getUsername();
        avatarUrl = "https://ui-avatars.com/api/?name="
                  + java.net.URLEncoder.encode(fullname, "UTF-8")
                  + "&background=4caf50&color=fff&size=80&bold=true&rounded=true";
    }

   

    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh Sách Sản Phẩm | Sena Shop</title>
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
        }

        html, body {
            min-height: 100vh;
            font-family: 'Inter', sans-serif;
            color: var(--gray-800);
            background: var(--bg);
        }

        /* ======= MAIN CONTENT ======= */
        .sena-main { flex: 1; display: flex; flex-direction: column; gap: 1.25rem; min-width: 0; }

        /* ======= ALERT ======= */
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
        .alert-warning { background: #fef9c3; border: 1px solid #fde68a; color: #92400e; }

        /* ======= CARD ======= */
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
            justify-content: space-between;
            padding: 1.1rem 1.5rem;
            border-bottom: 1px solid var(--gray-100);
        }

        .card-title {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--gray-800);
        }

        .card-title i { color: var(--green); }

        /* ======= SEARCH BAR ======= */
        .search-bar {
            padding: 1.1rem 1.5rem;
            border-bottom: 1px solid var(--gray-100);
            background: var(--gray-50);
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .search-form {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            flex: 1;
            max-width: 480px;
        }

        .search-input-wrap {
            position: relative;
            flex: 1;
        }

        .search-input-wrap i {
            position: absolute;
            left: 0.9rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--gray-400);
            font-size: 0.85rem;
            pointer-events: none;
        }

        .search-input {
            width: 100%;
            height: 40px;
            padding: 0 0.9rem 0 2.6rem;
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-size: 0.875rem;
            font-family: 'Inter', sans-serif;
            color: var(--gray-800);
            background: var(--white);
            outline: none;
            transition: all 0.18s;
        }

        .search-input:focus {
            border-color: var(--green);
            box-shadow: 0 0 0 3px rgba(76,175,80,0.12);
        }

        .search-input::placeholder { color: var(--gray-400); }

        /* ======= BUTTONS ======= */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.45rem;
            padding: 0.65rem 1.3rem;
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

        .btn-sm { padding: 0.5rem 1rem; font-size: 0.82rem; }

        /* ======= TABLE ======= */
        .table-wrap { overflow-x: auto; }

        .product-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.875rem;
        }

        .product-table thead th {
            background: var(--gray-50);
            padding: 0.85rem 1rem;
            text-align: left;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--gray-600);
            border-bottom: 2px solid var(--gray-200);
            white-space: nowrap;
        }

        .product-table tbody tr {
            border-bottom: 1px solid var(--gray-100);
            transition: background 0.12s;
        }

        .product-table tbody tr:hover { background: var(--green-light); }

        .product-table tbody td {
            padding: 0.85rem 1rem;
            color: var(--gray-800);
            vertical-align: middle;
        }

        /* Product image */
        .product-img {
            width: 52px;
            height: 52px;
            border-radius: 10px;
            object-fit: cover;
            border: 1.5px solid var(--gray-200);
            background: var(--gray-50);
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }

        .product-img img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .product-img-placeholder {
            width: 52px;
            height: 52px;
            border-radius: 10px;
            background: linear-gradient(135deg, #e8f5e9, #c8e6c9);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }

        /* Product title */
        .product-title {
            font-weight: 600;
            color: var(--gray-800);
            max-width: 220px;
            line-height: 1.35;
        }

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
        .badge-blue   { background: #dbeafe; color: #1e40af; }
        .badge-gray   { background: var(--gray-100); color: var(--gray-600); }

        /* Price display */
        .price-original {
            font-size: 0.82rem;
            color: var(--gray-400);
            text-decoration: line-through;
            display: block;
        }

        .price-sale {
            font-size: 0.9rem;
            font-weight: 700;
            color: #dc2626;
            display: block;
        }

        .price-unit {
            font-size: 0.75rem;
            color: var(--gray-400);
            display: block;
            margin-top: 0.1rem;
        }

        /* Action button */
        .btn-detail {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            padding: 0.4rem 0.85rem;
            border-radius: var(--radius-sm);
            font-size: 0.8rem;
            font-weight: 600;
            font-family: 'Inter', sans-serif;
            cursor: pointer;
            border: 1.5px solid var(--green);
            background: transparent;
            color: var(--green-dark);
            text-decoration: none;
            transition: all 0.15s;
        }

        .btn-detail:hover {
            background: var(--green);
            color: #fff;
        }

        .btn-delete {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            padding: 0.4rem 0.85rem;
            border-radius: var(--radius-sm);
            font-size: 0.8rem;
            font-weight: 600;
            font-family: 'Inter', sans-serif;
            cursor: pointer;
            border: 1.5px solid #dc2626;
            background: transparent;
            color: #dc2626;
            text-decoration: none;
            transition: all 0.15s;
        }

        .btn-delete:hover {
            background: #dc2626;
            color: #fff;
        }

        /* Empty state */
        .empty-state {
            text-align: center;
            padding: 3rem 1.5rem;
            color: var(--gray-400);
        }

        .empty-state i { font-size: 3rem; margin-bottom: 0.75rem; display: block; }
        .empty-state p { font-size: 0.9rem; }

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

        /* ======= RESPONSIVE ======= */
        @media (max-width: 900px) {
            .layout { flex-direction: column; padding: 0 1rem; }
            .sidebar { width: 100%; position: static; }
            .sidebar-nav { display: flex; flex-wrap: wrap; gap: 0.25rem; }
            .sidebar-nav a, .sidebar-nav button { width: auto; }
        }

        @media (max-width: 600px) {
            .topnav { padding: 0 1rem; }
            .nav-links { display: none; }
            .product-table thead th:nth-child(n+6),
            .product-table tbody td:nth-child(n+6) { display: none; }
        }
    </style>
</head>
<body>

<jsp:include page="/sidebar.jsp">
    <jsp:param name="activePage" value="products"/>
</jsp:include>

    <!-- MAIN -->
    <main class="sena-main">

        <% if (error != null) { %>
        <div class="alert alert-danger">
            <i class="fa-solid fa-circle-exclamation"></i>
            <span><%= error %></span>
        </div>
        <% } %>

        <% Boolean shopNotApproved = (Boolean) request.getAttribute("shopNotApproved");
           String shopNotApprovedMsg = (String) request.getAttribute("shopNotApprovedMsg");
           if (shopNotApproved != null && shopNotApproved) { %>
        <div class="alert alert-warning" style="background:#fef9c3;border:1px solid #fde68a;color:#92400e;">
            <i class="fa-solid fa-shop-slash"></i>
            <div>
                <strong>Cua hang chua duoc phe duyet</strong>
                <p style="margin:0.25rem 0 0;font-size:0.82rem;">
                    <%= shopNotApprovedMsg != null ? shopNotApprovedMsg : "Cua hang cua ban chua duoc phe duyet. Vui long cho admin xac nhan." %>
                </p>
                <p style="margin:0.25rem 0 0;font-size:0.82rem;">
                    Neu chua co cua hang, <a href="create-shop" style="color:#15803d;font-weight:600;">ban yeu cau mo cua hang tai day</a>.
                </p>
            </div>
        </div>
        <% } %>

        <%-- Debug info (chi hien thi khi co error hoac trong moi truong dev) --%>
        <% String debugRole = (String) request.getAttribute("debugRole");
           String debugEnv = System.getProperty("Account.name") != null ? "debug" : "";
           if (debugRole != null && (error != null || "debug".equals(System.getProperty("debug.mode")))) { %>
        <div class="alert" style="background:#f0f9ff;border:1px solid #bae6fd;color:#0c4a6e;font-size:0.78rem;">
            <i class="fa-solid fa-bug"></i>
            <span><strong>[DEBUG]</strong> role=<%= debugRole %>, sessionId=<%= session.getId() %></span>
        </div>
        <% } %>

        <!-- Page header card -->
        <div class="card">
            <div class="card-header">
                <div class="card-title">
                    <i class="fa-brands fa-opencart"></i> Danh Sach San Pham
                </div>
                <c:if test="${sessionScope.role == 'admin' || sessionScope.role == 'seller'}">
                    <a href="add-product" class="btn btn-green btn-sm">
                        <i class="fa-solid fa-plus"></i> Them San Pham
                    </a>
                </c:if>
            </div>

            <!-- Search bar -->
            <form method="get" action="products" class="search-bar">
                <!-- Search bar -->
<form method="get" action="products" class="search-bar">

    <div class="search-form"
         style="display:flex;align-items:center;gap:10px;max-width:none;">

        <!-- Tìm kiếm -->
        <div class="search-input-wrap" style="width:350px;">
            <i class="fa-solid fa-magnifying-glass"></i>
            <input type="text"
                   name="search"
                   class="search-input"
                   placeholder="Tìm kiếm sản phẩm..."
                   value="${param.search}">
        </div>

        <!-- Giá từ -->
        <!-- Dropdown sắp xếp -->
<select name="sort"
        class="search-input"
        style="width:180px;padding-left:12px;">

    <option value="">Sắp xếp giá</option>

    <option value="asc"
        <c:if test="${param.sort == 'asc'}">selected</c:if>>
        Giá tăng dần
    </option>

    <option value="desc"
        <c:if test="${param.sort == 'desc'}">selected</c:if>>
        Giá giảm dần
    </option>

</select>
        <!-- Nút tìm -->
        <button type="submit" class="btn btn-green btn-sm">
            <i class="fa-solid fa-search"></i> Tìm
        </button>

        <!-- Reset -->
        <c:if test="${not empty param.search || not empty param.minPrice || not empty param.maxPrice}">
            <a href="products" class="btn btn-outline btn-sm">
                <i class="fa-solid fa-xmark"></i> Xóa
            </a>
        </c:if>

    </div>

    <span style="font-size:0.82rem;color:var(--gray-400);margin-left:auto;">
        <c:choose>
            <c:when test="${totalProductCount > 0}">
                <span style="font-weight:600;color:var(--green);">
                    ${products.size()}
                </span>
                / ${totalProductCount} sản phẩm
            </c:when>
            <c:otherwise>
                0 sản phẩm
            </c:otherwise>
        </c:choose>
    </span>

</form>
                <span style="font-size:0.82rem;color:var(--gray-400);margin-left:auto;">
                    <c:choose>
                        <c:when test="${totalProductCount > 0}">
                            <span style="font-weight:600;color:var(--green);">${products.size()}</span> / ${totalProductCount} san pham
                        </c:when>
                        <c:when test="${empty products && empty error && empty shopNotApproved}">
                            0 san pham
                        </c:when>
                    </c:choose>
                </span>
            </form>

            <!-- Table -->
            <div class="table-wrap">
                <table class="product-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Hinh Anh</th>
                            <th>Ten San Pham</th>
                            <th>Cua Hang</th>
                            <th>Don Vi</th>
                            <th>So Luong</th>
                            <th>Da Ban</th>
                            <th>Gia</th>
                            <th>Trang Thai</th>
                            <th>Ngay Tao</th>
                            <c:if test="${sessionScope.role == 'admin' || sessionScope.role == 'seller'}">
                                <th>Hanh Dong</th>
                            </c:if>
                        </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${not empty products}">
                            <c:forEach var="p" items="${products}">
                                <tr>
                                    <td style="font-weight:600;color:var(--gray-600);">#${p.id}</td>

                                    <!-- Hinh anh -->
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty p.image}">
                                                <div class="product-img">
                                                    <img data-img-src="${p.image}" alt="${p.title}" onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
                                                    <div class="product-img-placeholder" style="display:none;">🍎</div>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="product-img-placeholder">🍎</div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Ten san pham -->
                                    <td>
                                        <div class="product-title">${p.title}</div>
                                    </td>

                                    <!-- Cua hang -->
                                    <td>
                                        <span class="badge badge-green">${not empty p.shopName ? p.shopName : '-'}</span>
                                    </td>

                                    <!-- Don vi -->
                                    <td>
                                        <span class="badge badge-gray">${not empty p.unit ? p.unit : '-'}</span>
                                    </td>

                                    <!-- So luong / stock badge -->
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.stockQuantity <= 0}">
                                                <span class="badge badge-red">
                                                    <i class="fa-solid fa-circle-xmark"></i> Het Hang
                                                </span>
                                            </c:when>
                                            <c:when test="${p.stockQuantity <= 20}">
                                                <span class="badge badge-yellow">
                                                    <i class="fa-solid fa-circle-exclamation"></i> ${p.stockQuantity}
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-green">
                                                    <i class="fa-solid fa-check-circle"></i> ${p.stockQuantity}
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Da ban -->
                                    <td style="text-align:center;">${p.soldQuantity}</td>

                                    <!-- Gia -->
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.salePrice < p.originalPrice}">
                                                <span class="price-original">
                                                    <fmt:formatNumber value="${p.originalPrice}" pattern="#,##0" /> d
                                                </span>
                                                <span class="price-sale">
                                                    <fmt:formatNumber value="${p.salePrice}" pattern="#,##0" /> d
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="font-weight:700;color:var(--green-dark);">
                                                    <fmt:formatNumber value="${p.originalPrice}" pattern="#,##0" /> d
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Trang thai -->
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.status == 1}">
                                                <span class="badge badge-green">
                                                    <i class="fa-solid fa-circle" style="font-size:0.45rem;"></i> Active
                                                </span>
                                            </c:when>
                                            <c:when test="${p.status == 0}">
                                                <span class="badge badge-yellow" style="background:#fef3c7;color:#92400e;border:1px solid #fde68a;">
                                                    <i class="fa-solid fa-clock" style="font-size:0.65rem;"></i> Chờ duyệt
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-gray">
                                                    <i class="fa-solid fa-circle" style="font-size:0.45rem;"></i> Inactive
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Ngay tao -->
                                    <td>
                                        <c:if test="${not empty p.createdAt}">
                                            <fmt:formatDate value="${p.createdAt}" pattern="dd/MM/yyyy" />
                                        </c:if>
                                    </td>

                                    <!-- Hanh dong -->
                                    <c:if test="${sessionScope.role == 'admin' || sessionScope.role == 'seller'}">
                                    <td>
                                        <a href="${pageContext.request.contextPath}/products?id=${p.id}" class="btn-detail">
                                            <i class="fa-regular fa-eye"></i> Chi Tiet
                                        </a>
                                        <c:if test="${sessionScope.role == 'admin' || (sessionScope.role == 'seller' && p.shopId == sessionScope.shopId)}">
                                            <a href="${pageContext.request.contextPath}/edit-product?id=${p.id}"
                                               class="btn-detail" style="border-color:#f59e0b;color:#92400e;">
                                                <i class="fa-solid fa-pen-to-square"></i> Sua
                                            </a>
                                            <a href="${pageContext.request.contextPath}/delete-product?id=${p.id}"
                                               class="btn-delete"
                                               onclick="return confirm('Ban co chắc muon xoa san pham \u2018${p.title}\u2019 khong?')">
                                                <i class="fa-solid fa-trash"></i> Xoa
                                            </a>
                                        </c:if>
                                    </td>
                                    </c:if>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="${sessionScope.role == 'admin' || sessionScope.role == 'seller' ? 11 : 10}">
                                    <div class="empty-state">
                                        <i class="fa-regular fa-face-frown"></i>
                                        <c:choose>
                                            <c:when test="${not empty error}">
                                                <p style="color:#991b1b;font-weight:500;">Loi tai san pham. Vui long thu lai sau.</p>
                                            </c:when>
                                            <c:when test="${shopNotApproved}">
                                                <p>Cua hang cua ban chua co san pham nao.</p>
                                            </c:when>
                                            <c:when test="${not empty searchKeyword}">
                                                <p>Khong tim thay san pham nao voi tu khoa "<strong>${searchKeyword}</strong>".</p>
                                            </c:when>
                                            <c:when test="${debugRole == 'seller'}">
                                                <p>Ban chua co san pham nao. <a href="add-product" style="color:var(--green);font-weight:600;">Them san pham dau tien</a>.</p>
                                            </c:when>
                                            <c:otherwise>
                                                <p>Hien chua co san pham nao.</p>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>
        </div><!-- /card -->

    </main>
</div><!-- /layout -->

<!-- ====== FOOTER ====== -->
<footer class="footer">
    <a href="home.jsp" class="footer-logo"><i class="fa-solid fa-apple-whole"></i> Sena Shop</a>
    <span class="footer-copy">&copy; 2024 Sena Shop. Trai cay tuoi ngon moi ngay.</span>
</footer>

<script>
(function() {
    var path = window.location.pathname;
    var subItems = document.querySelectorAll('#inventory-submenu .submenu-item');
    subItems.forEach(function(item) {
        if (item.getAttribute('href') === path) item.classList.add('active');
    });

    // Rewrite local image src to ImageServlet (run immediately on page load)
    var ctxt2 = window.location.pathname.split('/')[1] || '';
    document.querySelectorAll('img[data-img-src]').forEach(function(img) {
        var raw = img.getAttribute('data-img-src');
        if (raw && !raw.startsWith('http')) {
            img.src = '/' + ctxt2 + '/image?path=' + encodeURIComponent(raw);
        } else if (raw) {
            img.src = raw;
        }
    });
})();

function toggleInventoryMenu() {
    var sub = document.getElementById('inventory-submenu');
    var chev = document.getElementById('inventory-chevron');
    if (sub.style.display === 'none' || sub.style.display === '') {
        sub.style.display = 'flex';
        chev.style.transform = 'rotate(180deg)';
    } else {
        sub.style.display = 'none';
        chev.style.transform = '';
    }
}
</script>

</body>
</html>

