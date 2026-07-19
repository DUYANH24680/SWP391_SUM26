<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Shop" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    Account user = (Account) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String avatarUrl = user.getAvatar();
    if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
        String fullname = user.getFullname() != null ? user.getFullname() : user.getUsername();
        avatarUrl = "https://ui-avatars.com/api/?name="
                  + java.net.URLEncoder.encode(fullname, "UTF-8")
                  + "&background=4caf50&color=fff&size=80&bold=true&rounded=true";
    }

    Shop shop = (Shop) request.getAttribute("shop");
    Boolean shopNotApproved = (Boolean) request.getAttribute("shopNotApproved");
    String shopNotApprovedMsg = (String) request.getAttribute("shopNotApprovedMsg");

    Double totalRevenue = (Double) request.getAttribute("totalRevenue");
    Integer totalOrders = (Integer) request.getAttribute("totalOrders");
    Integer completedOrders = (Integer) request.getAttribute("completedOrders");

    String error = (String) session.getAttribute("error");
    if (error == null) {
        error = (String) request.getAttribute("error");
    }
    session.removeAttribute("error");

    NumberFormat nf = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doanh Thu | Sena Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --green:       #4caf50;
            --green-dark:  #388e3c;
            --green-light: #e8f5e9;
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
            --radius:      14px;
            --radius-sm:   8px;
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
        }
        .nav-logo i { color: var(--green); }
        .nav-links { display: flex; gap: 0.25rem; margin-left: 1rem; }
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
        .nav-right { margin-left: auto; display: flex; align-items: center; gap: 0.75rem; }
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
        .sidebar-nav a.logout { color: var(--red); }
        .sidebar-nav a.logout:hover { background: var(--red-light); color: var(--red); }

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
        .alert-danger { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }
        .alert-warning { background: #fef9c3; border: 1px solid #fde68a; color: #92400e; }

        /* ======= HERO REVENUE ======= */
        .hero-revenue {
            background: linear-gradient(135deg, #4caf50 0%, #2e7d32 100%);
            border-radius: var(--radius);
            padding: 2.5rem 3rem;
            color: white;
            box-shadow: var(--shadow);
            position: relative;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .hero-revenue::before {
            content: '';
            position: absolute;
            top: -30%; right: -5%;
            width: 300px; height: 300px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(255,255,255,0.12) 0%, transparent 65%);
        }
        .hero-revenue .icon-circle {
            width: 80px; height: 80px;
            background: rgba(255,255,255,0.18);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.2rem;
            position: relative;
            z-index: 1;
        }
        .hero-text { position: relative; z-index: 1; }
        .hero-text .label {
            font-size: 0.875rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            opacity: 0.85;
            margin-bottom: 0.4rem;
        }
        .hero-text .value {
            font-size: 2.8rem;
            font-weight: 800;
            line-height: 1;
            margin-bottom: 0.5rem;
        }
        .hero-text .subtitle {
            font-size: 0.95rem;
            opacity: 0.8;
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
        .stat-icon.orders   { background: #e3f2fd; color: #1976d2; }
        .stat-icon.done    { background: #e8f5e9; color: #388e3c; }
        .stat-info { display: flex; flex-direction: column; gap: 0.25rem; }
        .stat-label { font-size: 0.8rem; font-weight: 600; color: var(--gray-400); text-transform: uppercase; }
        .stat-value { font-size: 1.4rem; font-weight: 800; color: var(--gray-800); }

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

        @media (max-width: 900px) {
            .layout { flex-direction: column; }
            .sidebar { width: 100%; position: static; }
            .sidebar-nav { display: flex; flex-wrap: wrap; gap: 0.25rem; }
            .sidebar-nav a { width: auto; }
            .hero-revenue { flex-direction: column; text-align: center; gap: 1.5rem; }
        }
    </style>
</head>
<body>

    <jsp:include page="/sidebar.jsp">
        <jsp:param name="activePage" value="revenue"/>
    </jsp:include>

        <!-- Main Content -->
        <main class="sena-main">

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
            <% } else if (shop != null) { %>

                <!-- Hero Revenue -->
                <div class="hero-revenue">
                    <div class="icon-circle">
                        <i class="fa-solid fa-chart-line"></i>
                    </div>
                    <div class="hero-text">
                        <div class="label">Tổng Doanh Thu Thực Thu</div>
                        <div class="value"><%= nf.format((long) (totalRevenue != null ? totalRevenue : 0)) %> đ</div>
                        <div class="subtitle">Từ tất cả đơn hàng đã giao thành công</div>
                    </div>
                </div>

                <!-- Stats Cards -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon revenue">
                            <i class="fa-solid fa-hand-holding-dollar"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-label">Tổng doanh thu</span>
                            <span class="stat-value"><%= nf.format((long) (totalRevenue != null ? totalRevenue : 0)) %> đ</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon orders">
                            <i class="fa-solid fa-receipt"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-label">Tổng đơn hàng</span>
                            <span class="stat-value"><%= totalOrders != null ? totalOrders : 0 %></span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon done">
                            <i class="fa-solid fa-circle-check"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-label">Đơn đã giao</span>
                            <span class="stat-value"><%= completedOrders != null ? completedOrders : 0 %></span>
                        </div>
                    </div>
                </div>

            <% } %>

        </main>
    </div><!-- end sena-layout -->

    <!-- Footer -->
    <footer class="footer">
        <a href="<%= request.getContextPath() %>/home.jsp" class="footer-logo">
            <i class="fa-solid fa-apple-whole"></i> Sena Shop
        </a>
        <span class="footer-copy">&copy; 2024 Sena Shop. Trái cây tươi ngon mỗi ngày.</span>
    </footer>

</body>
</html>
