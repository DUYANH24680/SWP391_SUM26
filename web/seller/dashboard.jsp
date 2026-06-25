<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Shop" %>
<%@ page import="model.Order" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    Account Account = (Account) session.getAttribute("Account");
    if (Account == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String avatarUrl = Account.getAvatar();
    if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
        String fullname = Account.getFullname() != null ? Account.getFullname() : Account.getUsername();
        avatarUrl = "https://ui-avatars.com/api/?name="
                  + java.net.URLEncoder.encode(fullname, "UTF-8")
                  + "&background=4caf50&color=fff&size=80&bold=true&rounded=true";
    }

    Shop shop = (Shop) request.getAttribute("shop");
    Boolean shopNotApproved = (Boolean) request.getAttribute("shopNotApproved");
    String shopNotApprovedMsg = (String) request.getAttribute("shopNotApprovedMsg");

    Integer totalProducts = (Integer) request.getAttribute("totalProducts");
    Integer totalOrders = (Integer) request.getAttribute("totalOrders");
    Integer pendingOrders = (Integer) request.getAttribute("pendingOrders");
    Double totalRevenue = (Double) request.getAttribute("totalRevenue");
    List<Order> orders = (List<Order>) request.getAttribute("orders");

    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");

    NumberFormat nf = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seller Dashboard | Sena Shop</title>
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
            --blue:        #2196f3;
            --blue-light:  #e3f2fd;
            --orange:      #ff9800;
            --orange-light: #fff3e0;
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
            white-space: nowrap;
            letter-spacing: -0.01em;
        }
        .nav-logo i { color: var(--green); font-size: 1.15rem; }

        .nav-links {
            display: flex;
            gap: 0.25rem;
            margin-left: 1rem;
        }
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

        .nav-right {
            margin-left: auto;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        .nav-avatar {
            width: 38px; height: 38px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--green);
        }

        /* ======= LAYOUT ======= */
        .layout {
            display: flex;
            flex: 1;
            max-width: 1280px;
            width: 100%;
            margin: 1.5rem auto;
            padding: 0 1.5rem;
            gap: 1.5rem;
            align-items: flex-start;
        }

        /* ======= SIDEBAR ======= */
        .sidebar {
            width: 200px;
            flex-shrink: 0;
            background: var(--white);
            border-radius: var(--radius);
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--gray-200);
            overflow: hidden;
            position: sticky;
            top: 76px;
        }
        .sidebar-nav { padding: 0.5rem; }
        .sidebar-nav a {
            display: flex;
            align-items: center;
            gap: 0.65rem;
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
            transition: all 0.15s;
        }
        .sidebar-nav a:hover { background: var(--green-light); color: var(--green-dark); }
        .sidebar-nav a.active {
            background: var(--green);
            color: #fff;
            font-weight: 600;
        }
        .sidebar-nav a.logout { color: #e53e3e; }
        .sidebar-nav a.logout:hover { background: #fff5f5; color: #c53030; }

        /* ======= MAIN CONTENT ======= */
        .main { flex: 1; display: flex; flex-direction: column; gap: 1.5rem; min-width: 0; }

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
        .alert-success { background: #dcfce7; border: 1px solid #bbf7d0; color: #15803d; }
        .alert-danger { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }
        .alert-warning { background: #fef9c3; border: 1px solid #fde68a; color: #92400e; }

        /* ======= WELCOME HERO ======= */
        .hero {
            background: linear-gradient(135deg, #4caf50 0%, #2e7d32 100%);
            border-radius: var(--radius);
            padding: 2.25rem 2.5rem;
            color: #white;
            color: white;
            box-shadow: var(--shadow);
            position: relative;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .hero::before {
            content: '';
            position: absolute;
            top: -20%; right: -10%;
            width: 250px; height: 250px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(255,255,255,0.15) 0%, transparent 60%);
        }
        .hero-text h1 {
            font-size: 1.75rem;
            font-weight: 800;
            margin-bottom: 0.5rem;
        }
        .hero-text p {
            font-size: 0.95rem;
            opacity: 0.9;
        }

        /* ======= STATS GRID ======= */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 1.25rem;
        }
        .stat-card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            padding: 1.5rem;
            display: flex;
            align-items: center;
            gap: 1.25rem;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow);
        }
        .stat-icon {
            width: 48px; height: 48px;
            border-radius: var(--radius-sm);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.35rem;
        }
        .stat-icon.revenue { background: var(--green-light); color: var(--green-dark); }
        .stat-icon.orders { background: var(--blue-light); color: var(--blue); }
        .stat-icon.pending { background: var(--orange-light); color: var(--orange); }
        .stat-icon.products { background: var(--green-light); color: var(--green); }
        .stat-info { display: flex; flex-direction: column; gap: 0.25rem; }
        .stat-label { font-size: 0.8rem; font-weight: 600; color: var(--gray-400); text-transform: uppercase; letter-spacing: 0.02em;}
        .stat-value { font-size: 1.4rem; font-weight: 800; color: var(--gray-800); }

        /* ======= PANELS ======= */
        .panel {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            padding: 1.5rem;
        }
        .panel-title {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--gray-800);
            margin-bottom: 1.25rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .panel-title i { color: var(--green); }

        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
        }
        .action-card {
            border: 1.5px solid var(--gray-100);
            border-radius: var(--radius-sm);
            padding: 1.1rem;
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            text-decoration: none;
            color: inherit;
            transition: all 0.2s;
        }
        .action-card:hover {
            border-color: var(--green);
            background: var(--green-light);
        }
        .action-title { font-weight: 700; font-size: 0.92rem; color: var(--gray-800); display: flex; align-items: center; gap: 0.4rem;}
        .action-title i { color: var(--green); }
        .action-desc { font-size: 0.8rem; color: var(--gray-600); line-height: 1.4; }

        /* Badge status colors */
        .badge {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.25rem 0.75rem;
            border-radius: 100px;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
        }
        .badge-green  { background: #dcfce7; color: #166534; }
        .badge-yellow { background: #fef9c3; color: #854d0e; }
        .badge-red    { background: #fee2e2; color: #991b1b; }
        .badge-blue   { background: #dbeafe; color: #1e40af; }
        .badge-gray   { background: var(--gray-100); color: var(--gray-600); }

        /* Order Tracking breakdown styles */
        .tracking-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 1rem;
            margin-bottom: 0.5rem;
        }
        .tracking-card {
            background: var(--gray-50);
            border: 1px solid var(--gray-100);
            border-radius: var(--radius-sm);
            padding: 1rem;
            text-align: center;
            transition: all 0.2s;
            text-decoration: none;
            color: inherit;
        }
        .tracking-card:hover {
            border-color: var(--green-mid);
            background: #fff;
            transform: translateY(-2px);
            box-shadow: var(--shadow-sm);
        }
        .tracking-num {
            font-size: 1.6rem;
            font-weight: 800;
            margin-bottom: 0.25rem;
        }
        .tracking-lbl {
            font-size: 0.75rem;
            font-weight: 600;
            color: var(--gray-600);
            text-transform: uppercase;
        }
        .tracking-lbl.pending { color: #854d0e; }
        .tracking-lbl.confirmed { color: #1e40af; }
        .tracking-lbl.shipping { color: #854d0e; }
        .tracking-lbl.delivered { color: #166534; }
        .tracking-lbl.canceled { color: #991b1b; }

        /* Recent orders table styles */
        .orders-table-wrapper {
            overflow-x: auto;
            margin-top: 0.5rem;
        }
        .orders-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            font-size: 0.875rem;
        }
        .orders-table th, .orders-table td {
            padding: 0.75rem 1rem;
            border-bottom: 1px solid var(--gray-100);
        }
        .orders-table th {
            font-weight: 700;
            color: var(--gray-600);
            background: var(--gray-50);
        }
        .orders-table tr:hover td {
            background: var(--gray-50);
        }
        .orders-table td a {
            color: var(--green-dark);
            text-decoration: none;
            font-weight: 600;
        }
        .orders-table td a:hover {
            text-decoration: underline;
        }

        /* ======= RESPONSIVE ======= */
        @media (max-width: 900px) {
            .layout { flex-direction: column; }
            .sidebar { width: 100%; position: static; }
            .sidebar-nav { display: flex; flex-wrap: wrap; gap: 0.25rem; }
            .sidebar-nav a { width: auto; }
        }
    </style>
</head>
<body>

    <!-- Topnav -->
    <nav class="topnav">
        <a href="../home.jsp" class="nav-logo">
            <i class="fa-solid fa-apple-whole"></i> Sena Shop
        </a>
        <div class="nav-links">
            <a href="../home.jsp">Trang Chủ</a>
            <a href="../products">Sản Phẩm</a>
        </div>
        <div class="nav-right" style="display:flex;align-items:center;gap:0.5rem;">
            <% if (shop != null) { %>
                <span class="badge" style="background:#dcfce7; color:#166534; padding:0.25rem 0.75rem; border-radius:100px; font-size:0.75rem; font-weight:700;"><%= shop.getName() %></span>
            <% } %>
            <img class="nav-avatar" src="<%= avatarUrl %>" alt="avatar">
        </div>
    </nav>

    <!-- Layout Container -->
    <div class="layout">
        
        <!-- Sidebar -->
        <aside class="sidebar">
            <div class="sidebar-nav">
                <a href="dashboard" class="active"><i class="fa-solid fa-gauge"></i> Dashboard</a>
                <a href="../profile"><i class="fa-regular fa-Account"></i> Hồ Sơ</a>
                <a href="../products"><i class="fa-brands fa-opencart"></i> Sản Phẩm</a>
                <a href="orders"><i class="fa-solid fa-basket-shopping"></i> Đơn Hàng</a>
                <a href="../logout" class="logout"><i class="fa-solid fa-right-from-bracket"></i> Đăng Xuất</a>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="main">
            
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

            <% if (shopNotApproved != null && shopNotApproved) { %>
                <div class="alert alert-warning">
                    <i class="fa-solid fa-shop-slash"></i>
                    <span><strong>Không thể truy cập:</strong> <%= shopNotApprovedMsg %></span>
                </div>
            <% } else { %>

                <!-- Hero Section -->
                <div class="hero">
                    <div class="hero-text">
                        <h1>Xin chào, <%= Account.getFullname() %>!</h1>
                        <p>Chào mừng bạn trở lại trang quản lý cửa hàng <strong><%= shop.getName() %></strong>. Hãy theo dõi các thông số bán hàng của bạn.</p>
                    </div>
                </div>

                <!-- Stats Cards -->
                <div class="stats-grid">
                    <!-- Revenue -->
                    <div class="stat-card">
                        <div class="stat-icon revenue">
                            <i class="fa-solid fa-hand-holding-dollar"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-label">Doanh thu thực thu</span>
                            <span class="stat-value"><%= nf.format(totalRevenue) %> đ</span>
                        </div>
                    </div>

                    <!-- Total Orders -->
                    <div class="stat-card">
                        <div class="stat-icon orders">
                            <i class="fa-solid fa-receipt"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-label">Tổng đơn hàng</span>
                            <span class="stat-value"><%= totalOrders %></span>
                        </div>
                    </div>

                    <!-- Pending Orders -->
                    <div class="stat-card">
                        <div class="stat-icon pending">
                            <i class="fa-solid fa-clock-rotate-left"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-label">Đơn hàng chờ duyệt</span>
                            <span class="stat-value"><%= pendingOrders %></span>
                        </div>
                    </div>

                    <!-- Total Products -->
                    <div class="stat-card">
                        <div class="stat-icon products">
                            <i class="fa-solid fa-boxes-stacked"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-label">Số sản phẩm</span>
                            <span class="stat-value"><%= totalProducts %></span>
                        </div>
                    </div>
                </div>

                <%
                    // Calculate order status distribution
                    int statusPending = 0;
                    int statusConfirmed = 0;
                    int statusShipping = 0;
                    int statusDelivered = 0;
                    int statusCanceled = 0;
                    if (orders != null) {
                        for (Order o : orders) {
                            switch (o.getStatus()) {
                                case 1: statusPending++; break;
                                case 2: statusConfirmed++; break;
                                case 3: statusShipping++; break;
                                case 4: statusDelivered++; break;
                                case 5: statusCanceled++; break;
                            }
                        }
                    }
                %>
                <!-- Order Tracking Breakdown -->
                <div class="panel">
                    <div class="panel-title">
                        <i class="fa-solid fa-truck-fast"></i> Tracking Trạng Thái Đơn Hàng
                    </div>
                    <div class="tracking-grid">
                        <a href="orders" class="tracking-card">
                            <div class="tracking-num" style="color: #ff9800;"><%= statusPending %></div>
                            <div class="tracking-lbl pending">Chờ xác nhận</div>
                        </a>
                        <a href="orders" class="tracking-card">
                            <div class="tracking-num" style="color: #2196f3;"><%= statusConfirmed %></div>
                            <div class="tracking-lbl confirmed">Đã xác nhận</div>
                        </a>
                        <a href="orders" class="tracking-card">
                            <div class="tracking-num" style="color: #ff9800;"><%= statusShipping %></div>
                            <div class="tracking-lbl shipping">Đang giao</div>
                        </a>
                        <a href="orders" class="tracking-card">
                            <div class="tracking-num" style="color: #4caf50;"><%= statusDelivered %></div>
                            <div class="tracking-lbl delivered">Đã giao</div>
                        </a>
                        <a href="orders" class="tracking-card">
                            <div class="tracking-num" style="color: #f44336;"><%= statusCanceled %></div>
                            <div class="tracking-lbl canceled">Đã hủy</div>
                        </a>
                    </div>
                </div>

                <!-- Recent Orders Table -->
                <div class="panel">
                    <div class="panel-title">
                        <i class="fa-solid fa-list-check"></i> Đơn Hàng Mới Nhận Gần Đây
                    </div>
                    <div class="orders-table-wrapper">
                        <% if (orders != null && !orders.isEmpty()) { %>
                            <table class="orders-table">
                                <thead>
                                    <tr>
                                        <th>Mã Đơn</th>
                                        <th>Khách Hàng</th>
                                        <th>Ngày Đặt</th>
                                        <th>Thực Thu</th>
                                        <th>Trạng Thái</th>
                                        <th>Hành Động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        // Show up to 5 recent orders
                                        int count = 0;
                                        for (Order o : orders) {
                                            if (count >= 5) break;
                                            count++;
                                            String dateStr = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(o.getOrderDate());
                                    %>
                                        <tr>
                                            <td><strong>#<%= o.getId() %></strong></td>
                                            <td><%= o.getRecipientName() != null ? o.getRecipientName() : "Khách vãng lai" %></td>
                                            <td><%= dateStr %></td>
                                            <td><span style="color: var(--green-dark); font-weight: 700;"><%= nf.format((long) o.getFinalCost()) %> đ</span></td>
                                            <td><span class="badge <%= o.getStatusClass() %>"><%= o.getStatusLabel() %></span></td>
                                            <td><a href="orders"><i class="fa-solid fa-eye"></i> Chi tiết</a></td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        <% } else { %>
                            <p style="font-size: 0.875rem; color: var(--gray-600); text-align: center; padding: 1.5rem;">Không có đơn hàng nào.</p>
                        <% } %>
                    </div>
                </div>

                <!-- Panel Quick Actions -->
                <div class="panel">
                    <div class="panel-title">
                        <i class="fa-solid fa-compass"></i> Thao tác nhanh
                    </div>
                    <div class="quick-actions">
                        <a href="orders" class="action-card">
                            <span class="action-title"><i class="fa-solid fa-receipt"></i> Quản lý đơn hàng</span>
                            <span class="action-desc">Xem, duyệt hoặc hủy các đơn đặt hàng từ khách hàng của bạn.</span>
                        </a>

                        <a href="../products" class="action-card">
                            <span class="action-title"><i class="fa-brands fa-opencart"></i> Quản lý sản phẩm</span>
                            <span class="action-desc">Thêm sản phẩm mới, cập nhật giá bán, số lượng tồn kho của shop.</span>
                        </a>

                        <a href="../profile" class="action-card">
                            <span class="action-title"><i class="fa-regular fa-Account"></i> Hồ sơ cá nhân</span>
                            <span class="action-desc">Thay đổi thông tin liên hệ, mật khẩu, và thông tin tài khoản của bạn.</span>
                        </a>
                    </div>
                </div>

            <% } %>

        </main>
    </div>

</body>
</html>

