<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="model.Account" %>
        <%@ page import="model.Shop" %>
            <%-- SHARED SIDEBAR - Dung chung cho tat ca trang co sidebar Cach dung: <jsp:include page="/sidebar.jsp">
                <jsp:param name="activePage" value="dashboard" />
                </jsp:include>
                <main class="sena-main">
                    ...noi dung trang...
                </main>
                </div><!-- close .sena-layout -->

                activePage values:
                customer: customer-dashboard | orders | wishlist | profile | address | security
                seller: dashboard | revenue | orders | products | profile | address
                admin: orders | profile | address | security
                --%>
                <% Account sidebarUser=(Account) session.getAttribute("Account"); String sidebarRole=(String)
                    session.getAttribute("role"); String activePage=request.getParameter("activePage"); if
                    (activePage==null) activePage="" ; String sidebarFullname="" ; String sidebarAvatarUrl="" ; String
                    sidebarRoleLabel="Thanh Vien" ; if (sidebarUser !=null) { sidebarFullname=sidebarUser.getFullname()
                    !=null ? sidebarUser.getFullname() : sidebarUser.getUsername(); if (sidebarFullname==null)
                    sidebarFullname="User" ; sidebarAvatarUrl=sidebarUser.getAvatar(); if (sidebarAvatarUrl==null ||
                    sidebarAvatarUrl.trim().isEmpty()) { sidebarAvatarUrl="https://ui-avatars.com/api/?name=" +
                    java.net.URLEncoder.encode(sidebarFullname, "UTF-8" )
                    + "&background=4caf50&color=fff&size=80&bold=true&rounded=true" ; } if
                    ("admin".equalsIgnoreCase(sidebarRole)) sidebarRoleLabel="Quan Tri Vien" ; else if
                    ("seller".equalsIgnoreCase(sidebarRole)) sidebarRoleLabel="Nguoi Ban Hang" ; else if
                    ("delivery".equalsIgnoreCase(sidebarRole)) sidebarRoleLabel="Shipper" ; else if
                    ("staff".equalsIgnoreCase(sidebarRole)) sidebarRoleLabel="Nhan Vien" ; else
                    sidebarRoleLabel="Thanh Vien" ; } Shop sidebarShop=(Shop) session.getAttribute("shop"); if
                    (sidebarShop==null) sidebarShop=(Shop) request.getAttribute("shop"); String shopBadge=(sidebarShop
                    !=null) ? sidebarShop.getShopName() : null; String ctx=request.getContextPath(); boolean
                    isSeller="seller" .equalsIgnoreCase(sidebarRole); boolean isAdmin="admin"
                    .equalsIgnoreCase(sidebarRole); boolean isCustomer=!isSeller && !isAdmin; %>
                    <link
                        href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
                    <style>
                        /* ====================================================================
   SENA SHOP — SHARED SIDEBAR STYLESHEET v2.0
   Dung chung cho tat ca trang co sidebar (customer + seller + admin)
   ==================================================================== */

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
                            --bg: #f0f4f1;
                            --white: #ffffff;
                            --gray-50: #f8fafb;
                            --gray-100: #eef1ee;
                            --gray-200: #dde5dd;
                            --gray-300: #c5d1c5;
                            --gray-400: #9aaa9a;
                            --gray-500: #7a8a7a;
                            --gray-600: #5a6a5a;
                            --gray-700: #3d4d3d;
                            --gray-800: #2d3d2d;
                            --red: #ef4444;
                            --red-light: #fee2e2;
                            --shadow-xs: 0 1px 2px rgba(0, 0, 0, .06);
                            --shadow-sm: 0 1px 4px rgba(0, 0, 0, .08);
                            --shadow: 0 4px 12px rgba(0, 0, 0, .08);
                            --shadow-md: 0 8px 24px rgba(0, 0, 0, .10);
                            --radius: 16px;
                            --radius-md: 12px;
                            --radius-sm: 8px;
                            --radius-xs: 6px;
                            --sidebar-w: 230px;
                            --topnav-h: 64px;
                            --transition: all 0.18s cubic-bezier(0.4, 0, 0.2, 1);
                        }

                        html,
                        body {
                            min-height: 100vh;
                            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
                            color: var(--gray-800);
                            background: var(--bg);
                        }

                        body {
                            display: flex;
                            flex-direction: column;
                        }

                        /* ==================== TOPNAV ==================== */
                        .sena-topnav {
                            position: sticky;
                            top: 0;
                            z-index: 100;
                            height: var(--topnav-h);
                            background: var(--white);
                            border-bottom: 1px solid var(--gray-200);
                            display: flex;
                            align-items: center;
                            padding: 0 2rem;
                            gap: 1.5rem;
                            box-shadow: var(--shadow-sm);
                        }

                        .sena-nav-logo {
                            display: flex;
                            align-items: center;
                            gap: 0.55rem;
                            font-size: 1.25rem;
                            font-weight: 800;
                            color: var(--green-dark);
                            text-decoration: none;
                            white-space: nowrap;
                            letter-spacing: -0.02em;
                            flex-shrink: 0;
                        }

                        .sena-nav-logo i {
                            color: var(--green);
                            font-size: 1.1rem;
                        }

                        .sena-nav-links {
                            display: flex;
                            gap: 0.15rem;
                            margin-left: 0.5rem;
                        }

                        .sena-nav-links a {
                            padding: 0.4rem 0.9rem;
                            border-radius: var(--radius-xs);
                            font-size: 0.875rem;
                            font-weight: 500;
                            color: var(--gray-600);
                            text-decoration: none;
                            transition: var(--transition);
                        }

                        .sena-nav-links a:hover {
                            background: var(--green-light);
                            color: var(--green-dark);
                        }

                        .sena-nav-right {
                            margin-left: auto;
                            display: flex;
                            align-items: center;
                            gap: 0.75rem;
                        }

                        .sena-shop-badge {
                            background: linear-gradient(135deg, var(--green-light) 0%, #d0f0d4 100%);
                            color: var(--green-dark);
                            border: 1px solid var(--green-mid);
                            padding: 0.3rem 0.8rem;
                            border-radius: 100px;
                            font-size: 0.75rem;
                            font-weight: 700;
                            max-width: 160px;
                            overflow: hidden;
                            text-overflow: ellipsis;
                            white-space: nowrap;
                        }

                        .sena-nav-avatar {
                            width: 38px;
                            height: 38px;
                            border-radius: 50%;
                            object-fit: cover;
                            border: 2.5px solid var(--green);
                            cursor: pointer;
                            transition: var(--transition);
                            box-shadow: 0 2px 8px rgba(76, 175, 80, 0.25);
                        }

                        .sena-nav-avatar:hover {
                            transform: scale(1.08);
                            border-color: var(--green-dark);
                        }

                        /* ==================== LAYOUT WRAPPER ==================== */
                        .sena-layout {
                            display: flex;
                            flex: 1;
                            max-width: 1360px;
                            width: 100%;
                            margin: 1.5rem auto;
                            padding: 0 1.5rem;
                            gap: 1.5rem;
                            align-items: flex-start;
                        }

                        /* ==================== SIDEBAR ==================== */
                        .sena-sidebar {
                            width: var(--sidebar-w);
                            flex-shrink: 0;
                            background: var(--white);
                            border-radius: var(--radius);
                            border: 1px solid var(--gray-200);
                            box-shadow: var(--shadow-sm);
                            overflow: hidden;
                            position: sticky;
                            top: calc(var(--topnav-h) + 1.5rem);
                        }

                        /* User card */
                        .sena-sb-user {
                            background: linear-gradient(160deg, #f2faf2 0%, #e8f5e9 100%);
                            padding: 1.25rem 1rem 1rem;
                            border-bottom: 1px solid var(--gray-200);
                        }

                        .sena-sb-user-row {
                            display: flex;
                            align-items: center;
                            gap: 0.75rem;
                            margin-bottom: 0.6rem;
                        }

                        .sena-sb-avatar {
                            width: 44px;
                            height: 44px;
                            border-radius: 50%;
                            object-fit: cover;
                            border: 2px solid var(--white);
                            box-shadow: 0 2px 8px rgba(76, 175, 80, 0.2);
                            flex-shrink: 0;
                        }

                        .sena-sb-name {
                            font-weight: 700;
                            font-size: 0.9rem;
                            color: var(--gray-800);
                            line-height: 1.25;
                            overflow: hidden;
                            text-overflow: ellipsis;
                            white-space: nowrap;
                            max-width: 140px;
                        }

                        .sena-sb-role {
                            display: inline-flex;
                            align-items: center;
                            gap: 0.3rem;
                            background: rgba(255, 255, 255, 0.8);
                            border: 1px solid var(--green-mid);
                            color: var(--green-dark);
                            padding: 0.18rem 0.6rem;
                            border-radius: 100px;
                            font-size: 0.68rem;
                            font-weight: 700;
                            letter-spacing: 0.04em;
                            text-transform: uppercase;
                        }

                        /* Section labels */
                        .sena-nav-section {
                            padding: 0.65rem 1rem 0.2rem;
                            font-size: 0.64rem;
                            font-weight: 700;
                            text-transform: uppercase;
                            letter-spacing: 0.07em;
                            color: var(--gray-400);
                        }

                        /* Nav container */
                        .sena-sb-nav {
                            padding: 0.5rem;
                        }

                        /* Nav items */
                        .sena-nav-item {
                            display: flex;
                            align-items: center;
                            gap: 0.7rem;
                            width: 100%;
                            padding: 0.65rem 0.9rem;
                            border-radius: var(--radius-sm);
                            font-size: 0.875rem;
                            font-weight: 500;
                            color: var(--gray-600);
                            border: none;
                            background: transparent;
                            cursor: pointer;
                            text-align: left;
                            text-decoration: none;
                            transition: var(--transition);
                            position: relative;
                            margin-bottom: 2px;
                        }

                        .sena-nav-item i:first-child {
                            width: 18px;
                            text-align: center;
                            font-size: 0.88rem;
                            flex-shrink: 0;
                        }

                        .sena-nav-item:hover {
                            background: var(--green-light);
                            color: var(--green-dark);
                            transform: translateX(3px);
                        }

                        .sena-nav-item.active {
                            background: linear-gradient(135deg, var(--green) 0%, #43a047 100%);
                            color: #fff;
                            font-weight: 600;
                            box-shadow: 0 3px 10px rgba(76, 175, 80, 0.30);
                        }

                        .sena-nav-item.active i {
                            color: rgba(255, 255, 255, 0.9);
                        }

                        .sena-nav-item.active:hover {
                            transform: translateX(3px);
                        }

                        .sena-nav-item.sena-logout {
                            color: var(--red);
                        }

                        .sena-nav-item.sena-logout:hover {
                            background: var(--red-light);
                            color: #c53030;
                            transform: translateX(3px);
                        }

                        /* Divider */
                        .sena-nav-divider {
                            height: 1px;
                            background: var(--gray-100);
                            margin: 0.35rem 0.75rem;
                        }

                        /* ==================== MAIN CONTENT AREA ==================== */
                        .sena-main {
                            flex: 1;
                            display: flex;
                            flex-direction: column;
                            gap: 1.5rem;
                            min-width: 0;
                        }

                        /* ==================== ALERTS ==================== */
                        .sena-alert {
                            display: flex;
                            align-items: center;
                            gap: 0.75rem;
                            padding: 0.9rem 1.2rem;
                            border-radius: var(--radius-sm);
                            font-size: 0.875rem;
                            font-weight: 500;
                        }

                        .sena-alert-success {
                            background: #dcfce7;
                            border: 1px solid #bbf7d0;
                            color: #166534;
                        }

                        .sena-alert-danger {
                            background: #fee2e2;
                            border: 1px solid #fecaca;
                            color: #991b1b;
                        }

                        .sena-alert-warning {
                            background: #fef9c3;
                            border: 1px solid #fde68a;
                            color: #92400e;
                        }

                        /* ==================== RESPONSIVE ==================== */
                        @media (max-width: 900px) {
                            .sena-layout {
                                flex-direction: column;
                                margin: 1rem auto;
                            }

                            .sena-sidebar {
                                width: 100%;
                                position: static;
                                top: auto;
                            }

                            .sena-sb-nav {
                                display: grid;
                                grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
                                gap: 0.2rem;
                            }

                            .sena-nav-section,
                            .sena-nav-divider {
                                display: none;
                            }

                            .sena-nav-item {
                                flex-direction: column;
                                gap: 0.2rem;
                                padding: 0.6rem 0.4rem;
                                font-size: 0.72rem;
                                text-align: center;
                            }

                            .sena-nav-item i:first-child {
                                width: auto;
                                font-size: 1rem;
                            }

                            .sena-sb-user {
                                display: none;
                            }

                            .sena-nav-links {
                                display: none;
                            }
                        }
                    </style>

                    <!-- ==================== TOPNAV ==================== -->
                    <nav class="sena-topnav">
                        <a href="<%= ctx %>/home.jsp" class="sena-nav-logo">
                            <i class="fa-solid fa-apple-whole"></i> Sena Shop
                        </a>
                        <div class="sena-nav-links">
                            <a href="<%= ctx %>/home.jsp">Trang Chu</a>
                            <a href="<%= ctx %>/products">San Pham</a>
                        </div>
                        <div class="sena-nav-right">
                            <% if (shopBadge !=null) { %>
                                <span class="sena-shop-badge">
                                    <i class="fa-solid fa-store"
                                        style="color:var(--green);margin-right:0.3rem;font-size:0.7rem;"></i>
                                    <%= shopBadge %>
                                </span>
                                <% } %>
                                    <img class="sena-nav-avatar" src="<%= sidebarAvatarUrl %>" alt="avatar">
                        </div>
                    </nav>

                    <!-- ==================== LAYOUT START ==================== -->
                    <div class="sena-layout">

                        <!-- SIDEBAR -->
                        <aside class="sena-sidebar">

                            <!-- User info card -->
                            <div class="sena-sb-user">
                                <div class="sena-sb-user-row">
                                    <img class="sena-sb-avatar" src="<%= sidebarAvatarUrl %>" alt="avatar">
                                    <div class="sena-sb-name">
                                        <%= sidebarFullname %>
                                    </div>
                                </div>
                                <span class="sena-sb-role">
                                    <i class="fa-solid fa-circle" style="font-size:0.4rem;color:var(--green);"></i>
                                    <%= sidebarRoleLabel %>
                                </span>
                            </div>

                            <div class="sena-sb-nav">

                                <% if (isSeller) { %>
                                    <!-- ===== SELLER MENU ===== -->
                                    <div class="sena-nav-section">Quan ly Shop</div>

                                    <a href="<%= ctx %>/seller/dashboard" class="sena-nav-item <%="dashboard".equals(activePage) ? "active" : "" %>">
                                        <i class="fa-solid fa-gauge-high"></i> Dashboard
                                    </a>
                                    <a href="<%= ctx %>/seller/revenue" class="sena-nav-item <%="revenue".equals(activePage) ? "active" : "" %>">
                                        <i class="fa-solid fa-chart-line"></i> Doanh Thu
                                    </a>
                                    <a href="<%= ctx %>/seller/orders" class="sena-nav-item <%="orders".equals(activePage) ? "active" : "" %>">
                                        <i class="fa-solid fa-basket-shopping"></i> Don Hang
                                    </a>
                                    <a href="<%= ctx %>/products" class="sena-nav-item <%="products".equals(activePage) ? "active" : "" %>">
                                        <i class="fa-brands fa-opencart"></i> San Pham
                                    </a>
                                    <a href="<%= ctx %>/category" class="sena-nav-item <%="category".equals(activePage) ? "active" : "" %>">
                                        <i class="fa-solid fa-layer-group"></i> Danh Muc
                                    </a>

                                    <button class="sena-nav-item <%= " inventory".equals(activePage) ? "active" : "" %>"
                                        onclick="document.getElementById('sena-inv-menu-seller').style.display =
                                        document.getElementById('sena-inv-menu-seller').style.display === 'none' ?
                                        'flex' : 'none'">
                                        <i class="fa-solid fa-warehouse"></i> Kho <i class="fa-solid fa-chevron-down"
                                            style="margin-left:auto; font-size:0.7rem;"></i>
                                    </button>
                                    <div id="sena-inv-menu-seller"
                                        style="display:none; flex-direction:column; gap:2px; padding-left:1.5rem;">
                                        <a href="<%= ctx %>/inventory-import" class="sena-nav-item"
                                            style="padding:0.4rem 0.8rem; font-size:0.8rem;">
                                            <i class="fa-solid fa-arrow-down"></i> Nhap Kho
                                        </a>
                                        <a href="<%= ctx %>/inventory-export" class="sena-nav-item"
                                            style="padding:0.4rem 0.8rem; font-size:0.8rem;">
                                            <i class="fa-solid fa-arrow-up"></i> Xuat Kho
                                        </a>
                                    </div>
                                    <div class="sena-nav-divider"></div>
                                    <div class="sena-nav-section">Tai Khoan</div>

                                    <a href="<%= ctx %>/profile" class="sena-nav-item <%= " profile".equals(activePage)
                                        ? "active" : "" %>">
                                        <i class="fa-regular fa-user"></i> Ho So
                                    </a>
                                    <a href="<%= ctx %>/address" class="sena-nav-item <%= " address".equals(activePage)
                                        ? "active" : "" %>">
                                        <i class="fa-solid fa-map-location-dot"></i> So Dia Chi
                                    </a>

                                    <div class="sena-nav-divider"></div>
                                    <a href="<%= ctx %>/logout" class="sena-nav-item sena-logout">
                                        <i class="fa-solid fa-right-from-bracket"></i> Dang Xuat
                                    </a>

                                    <% } else if (isAdmin) { %>
                                        <!-- ===== ADMIN MENU ===== -->
                                        <div class="sena-nav-section">Quan Tri</div>

                                        <a href="<%= ctx %>/admin/orders" class="sena-nav-item <%="orders".equals(activePage) ? "active" : "" %>">
                                            <i class="fa-solid fa-basket-shopping"></i> Don Hang
                                        </a>
                                        <a href="<%= ctx %>/products" class="sena-nav-item <%="products".equals(activePage) ? "active" : "" %>">
                                            <i class="fa-brands fa-opencart"></i> San Pham
                                        </a>
                                        <a href="<%= ctx %>/category" class="sena-nav-item <%="category".equals(activePage) ? "active" : "" %>">
                                            <i class="fa-solid fa-layer-group"></i> Danh Muc
                                        </a>
                                        <div class="sena-nav-divider"></div>
                                        <div class="sena-nav-section">Tai Khoan</div>

                                        <a href="<%= ctx %>/profile" class="sena-nav-item <%="profile".equals(activePage) ? "active" : "" %>">
                                            <i class="fa-regular fa-user"></i> Ho So
                                        </a>
                                        <a href="<%= ctx %>/address" class="sena-nav-item <%="address".equals(activePage) ? "active" : "" %>">
                                            <i class="fa-solid fa-map-location-dot"></i> So Dia Chi
                                        </a>
                                        <a href="<%= ctx %>/profile?tab=security" class="sena-nav-item <%="security".equals(activePage) ? "active" : "" %>">
                                            <i class="fa-solid fa-shield-halved"></i> Bao Mat
                                        </a>

                                        <div class="sena-nav-divider"></div>
                                        <a href="<%= ctx %>/logout" class="sena-nav-item sena-logout">
                                            <i class="fa-solid fa-right-from-bracket"></i> Dang Xuat
                                        </a>

                                        <% } else { %>
                                            <!-- ===== CUSTOMER MENU ===== -->
                                            <div class="sena-nav-section">Mua Sam</div>

                                            <a href="<%= ctx %>/customer-dashboard" class="sena-nav-item <%="customer-dashboard".equals(activePage) ? "active" : "" %>">
                                                <i class="fa-solid fa-gauge-high"></i> Dashboard
                                            </a>
                                            <a href="<%= ctx %>/my-orders" class="sena-nav-item <%="orders".equals(activePage) ? "active" : "" %>">
                                                <i class="fa-solid fa-basket-shopping"></i> Don Hang
                                            </a>
                                            <a href="<%= ctx %>/wishlist" class="sena-nav-item <%="wishlist".equals(activePage) ? "active" : "" %>">
                                                <i class="fa-solid fa-heart"></i> Yeu Thich
                                            </a>

                                            <div class="sena-nav-divider"></div>
                                            <div class="sena-nav-section">Tai Khoan</div>

                                            <a href="<%= ctx %>/profile" class="sena-nav-item <%="profile".equals(activePage) ? "active" : "" %>">
                                                <i class="fa-regular fa-user"></i> Ho So
                                            </a>
                                            <a href="<%= ctx %>/address" class="sena-nav-item <%="address".equals(activePage) ? "active" : "" %>">
                                                <i class="fa-solid fa-map-location-dot"></i> So Dia Chi
                                            </a>
                                            <a href="<%= ctx %>/profile?tab=security" class="sena-nav-item <%="security".equals(activePage) ? "active" : "" %>">
                                                <i class="fa-solid fa-shield-halved"></i> Bao Mat
                                            </a>

                                            <div class="sena-nav-divider"></div>
                                            <a href="<%= ctx %>/logout" class="sena-nav-item sena-logout">
                                                <i class="fa-solid fa-right-from-bracket"></i> Dang Xuat
                                            </a>

                                            <% } %>

                            </div><!-- end sena-sb-nav -->
                        </aside><!-- end sena-sidebar -->

                        <!-- NOTE: Sau include, trang tu mo:
     <main class="sena-main">
         ...noi dung...
     </main>
     </div>  ← dong sena-layout
-->