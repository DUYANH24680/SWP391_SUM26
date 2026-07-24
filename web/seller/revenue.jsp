<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Shop" %>
<%@ page import="model.Order" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%
    Account user = (Account) session.getAttribute("Account");
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
    Double todayRevenue = (Double) request.getAttribute("todayRevenue");
    Double monthRevenue = (Double) request.getAttribute("monthRevenue");
    Double avgOrderValue = (Double) request.getAttribute("avgOrderValue");
    Integer totalOrders = (Integer) request.getAttribute("totalOrders");
    Integer completedOrders = (Integer) request.getAttribute("completedOrders");
    Integer todayOrderCount = (Integer) request.getAttribute("todayOrderCount");
    List<String[]> revenueByDay = (List<String[]>) request.getAttribute("revenueByDay");
    List<Order> filteredOrders = (List<Order>) request.getAttribute("filteredOrders");
    Double filteredRevenue = (Double) request.getAttribute("filteredRevenue");

    String dateFrom = (String) request.getAttribute("dateFrom");
    String dateTo = (String) request.getAttribute("dateTo");
    String statusParam = (String) request.getAttribute("statusParam");

    String error = (String) session.getAttribute("error");
    if (error == null) {
        error = (String) request.getAttribute("error");
    }
    session.removeAttribute("error");

    NumberFormat nf = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi"));
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat sdfInput = new SimpleDateFormat("yyyy-MM-dd");

    // Build chart JSON
    String chartLabels = "[]";
    String chartData = "[]";
    if (revenueByDay != null && !revenueByDay.isEmpty()) {
        StringBuilder labels = new StringBuilder("[");
        StringBuilder data = new StringBuilder("[");
        for (int i = 0; i < revenueByDay.size(); i++) {
            String[] row = revenueByDay.get(i);
            String label = row[0];
            if (label != null && label.contains("-")) {
                try {
                    java.util.Date d = new SimpleDateFormat("yyyy-MM-dd").parse(label);
                    label = new SimpleDateFormat("dd/MM").format(d);
                } catch (Exception e) {}
            }
            labels.append("\"").append(label != null ? label : "").append("\"");
            data.append(row[1] != null ? row[1] : "0");
            if (i < revenueByDay.size() - 1) {
                labels.append(",");
                data.append(",");
            }
        }
        labels.append("]");
        data.append("]");
        chartLabels = labels.toString();
        chartData = data.toString();
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doanh Thu | Sena Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
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
            --orange:      #ff7043;
            --yellow:      #ffc107;
            --blue:        #1976d2;
            --red:         #e53935;
            --red-light:   #ffebee;
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
            display: flex; align-items: center; gap: 0.5rem;
            font-size: 1.3rem; font-weight: 800;
            color: var(--green-dark); text-decoration: none; white-space: nowrap;
        }
        .nav-logo i { color: var(--green); }
        .nav-links { display: flex; gap: 0.25rem; margin-left: 1rem; }
        .nav-links a {
            padding: 0.4rem 0.85rem; border-radius: 6px;
            font-size: 0.875rem; font-weight: 500;
            color: var(--gray-600); text-decoration: none; transition: all 0.15s;
        }
        .nav-links a:hover { background: var(--green-light); color: var(--green-dark); }
        .nav-right { margin-left: auto; display: flex; align-items: center; gap: 0.75rem; }
        .nav-avatar { width: 38px; height: 38px; border-radius: 50%; object-fit: cover; border: 2px solid var(--green); }

        /* ======= LAYOUT ======= */
        .layout {
            display: flex; flex: 1;
            max-width: 1280px; width: 100%;
            margin: 1.5rem auto; padding: 0 1.5rem;
            gap: 1.5rem; align-items: flex-start;
        }

        /* ======= SIDEBAR ======= */
        .sidebar {
            width: 200px; flex-shrink: 0;
            background: var(--white); border-radius: var(--radius);
            box-shadow: var(--shadow-sm); border: 1px solid var(--gray-200);
            overflow: hidden; position: sticky; top: 76px;
        }
        .sidebar-nav { padding: 0.5rem; }
        .sidebar-nav a {
            display: flex; align-items: center; gap: 0.65rem;
            width: 100%; padding: 0.65rem 0.9rem;
            border-radius: var(--radius-sm);
            font-size: 0.875rem; font-weight: 500;
            color: var(--gray-600); border: none;
            background: transparent; cursor: pointer;
            text-align: left; text-decoration: none; transition: all 0.15s;
        }
        .sidebar-nav a:hover { background: var(--green-light); color: var(--green-dark); }
        .sidebar-nav a.active { background: var(--green); color: #fff; font-weight: 600; }
        .sidebar-nav a.logout { color: var(--red); }
        .sidebar-nav a.logout:hover { background: var(--red-light); color: var(--red); }

        /* ======= MAIN ======= */
        .main { flex: 1; display: flex; flex-direction: column; gap: 1.5rem; min-width: 0; }

        /* ======= ALERTS ======= */
        .alert {
            display: flex; align-items: center; gap: 0.75rem;
            padding: 0.9rem 1.2rem; border-radius: var(--radius-sm);
            font-size: 0.875rem; font-weight: 500;
        }
        .alert-danger { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }
        .alert-warning { background: #fef9c3; border: 1px solid #fde68a; color: #92400e; }

        /* ======= STATS GRID ======= */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1rem;
        }
        .stat-card {
            background: var(--white); border-radius: var(--radius);
            border: 1px solid var(--gray-200); box-shadow: var(--shadow-sm);
            padding: 1.25rem 1.5rem;
            display: flex; align-items: center; gap: 1rem;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .stat-card:hover { transform: translateY(-2px); box-shadow: var(--shadow); }
        .stat-icon {
            width: 44px; height: 44px; border-radius: var(--radius-sm);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.2rem; flex-shrink: 0;
        }
        .icon-green  { background: var(--green-light); color: var(--green-dark); }
        .icon-orange { background: #fff3e0; color: #e65100; }
        .icon-blue   { background: #e3f2fd; color: var(--blue); }
        .icon-yellow { background: #fff8e1; color: #f57f17; }
        .icon-red    { background: var(--red-light); color: var(--red); }
        .icon-purple { background: #f3e5f5; color: #6a1b9a; }

        .stat-info { display: flex; flex-direction: column; gap: 0.15rem; min-width: 0; }
        .stat-label { font-size: 0.75rem; font-weight: 700; color: var(--gray-400); text-transform: uppercase; letter-spacing: 0.03em; }
        .stat-value { font-size: 1.25rem; font-weight: 800; color: var(--gray-800); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .stat-value.currency::after { content: ' đ'; font-size: 0.8em; font-weight: 600; color: var(--gray-600); }
        .stat-sub { font-size: 0.72rem; color: var(--gray-400); }

        /* ======= CHART CARD ======= */
        .chart-card {
            background: var(--white); border-radius: var(--radius);
            border: 1px solid var(--gray-200); box-shadow: var(--shadow-sm);
            overflow: hidden;
        }
        .chart-header {
            display: flex; align-items: center; justify-content: space-between;
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid var(--gray-100);
        }
        .chart-title { font-size: 1rem; font-weight: 700; color: var(--gray-800); display: flex; align-items: center; gap: 0.5rem; }
        .chart-title i { color: var(--green); }
        .chart-badge { font-size: 0.72rem; font-weight: 700; background: var(--green-light); color: var(--green-dark); padding: 0.2rem 0.6rem; border-radius: 100px; }
        .chart-body { padding: 1.25rem 1.5rem; height: 260px; }
        .chart-body canvas { width: 100% !important; height: 100% !important; }

        /* ======= FILTER BAR ======= */
        .filter-bar {
            background: var(--white); border-radius: var(--radius);
            border: 1px solid var(--gray-200); box-shadow: var(--shadow-sm);
            padding: 1rem 1.5rem;
            display: flex; align-items: flex-end; gap: 1rem; flex-wrap: wrap;
        }
        .filter-group { display: flex; flex-direction: column; gap: 0.35rem; }
        .filter-label { font-size: 0.75rem; font-weight: 700; color: var(--gray-400); text-transform: uppercase; letter-spacing: 0.03em; }
        .filter-input {
            height: 38px; border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm); padding: 0 0.85rem;
            font-size: 0.85rem; font-family: 'Inter', sans-serif;
            color: var(--gray-800); background: var(--gray-50);
            outline: none; transition: border-color 0.2s;
        }
        .filter-input:focus { border-color: var(--green); background: var(--white); }
        .filter-select {
            height: 38px; border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm); padding: 0 0.85rem;
            font-size: 0.85rem; font-family: 'Inter', sans-serif;
            color: var(--gray-800); background: var(--gray-50);
            outline: none; cursor: pointer; transition: border-color 0.2s;
        }
        .filter-select:focus { border-color: var(--green); background: var(--white); }
        .filter-actions { display: flex; gap: 0.5rem; align-items: flex-end; }
        .btn {
            display: inline-flex; align-items: center; justify-content: center; gap: 0.4rem;
            padding: 0.55rem 1.1rem; border-radius: var(--radius-sm);
            font-size: 0.82rem; font-weight: 600; cursor: pointer;
            border: none; text-decoration: none; transition: all 0.2s;
            font-family: 'Inter', sans-serif;
        }
        .btn-green { background: var(--green); color: #fff; }
        .btn-green:hover { background: var(--green-dark); }
        .btn-outline { background: var(--white); color: var(--gray-600); border: 1.5px solid var(--gray-200); }
        .btn-outline:hover { background: var(--gray-50); color: var(--gray-800); }

        /* ======= FILTERED SUMMARY ======= */
        .filter-summary {
            background: var(--green-light); border: 1px solid var(--green-mid);
            border-radius: var(--radius-sm); padding: 0.75rem 1.25rem;
            display: flex; align-items: center; justify-content: space-between;
            font-size: 0.85rem;
        }
        .filter-summary-text { color: var(--green-dark); font-weight: 600; }
        .filter-summary-rev { font-size: 1.1rem; font-weight: 800; color: var(--green-dark); }

        /* ======= TABLE ======= */
        .table-card {
            background: var(--white); border-radius: var(--radius);
            border: 1px solid var(--gray-200); box-shadow: var(--shadow-sm);
            overflow: hidden;
        }
        .table-header {
            display: flex; align-items: center; justify-content: space-between;
            padding: 1rem 1.5rem; border-bottom: 1px solid var(--gray-100);
        }
        .table-title { font-size: 0.95rem; font-weight: 700; color: var(--gray-800); }
        .table-count { font-size: 0.78rem; font-weight: 600; background: var(--gray-100); color: var(--gray-600); padding: 0.2rem 0.6rem; border-radius: 100px; }

        .table-wrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; }
        thead th {
            padding: 0.75rem 1rem;
            text-align: left;
            font-size: 0.72rem; font-weight: 700;
            color: var(--gray-400); text-transform: uppercase;
            letter-spacing: 0.05em;
            background: var(--gray-50);
            border-bottom: 1px solid var(--gray-200);
            white-space: nowrap;
        }
        tbody tr { border-bottom: 1px solid var(--gray-100); transition: background 0.15s; }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: var(--gray-50); }
        tbody td {
            padding: 0.85rem 1rem;
            font-size: 0.85rem; color: var(--gray-800);
            vertical-align: middle;
        }
        .order-id { font-weight: 700; color: var(--green-dark); font-size: 0.82rem; }
        .order-customer { font-weight: 600; }
        .order-date { color: var(--gray-400); font-size: 0.78rem; white-space: nowrap; }
        .order-total { font-weight: 700; color: var(--gray-800); white-space: nowrap; }
        .order-total small { font-size: 0.72rem; color: var(--gray-400); font-weight: 400; }

        .badge {
            display: inline-flex; align-items: center; gap: 0.3rem;
            padding: 0.2rem 0.65rem; border-radius: 100px;
            font-size: 0.72rem; font-weight: 700; white-space: nowrap;
        }
        .badge-yellow { background: #fef9c3; color: #854d0e; }
        .badge-blue   { background: #dbeafe; color: #1e40af; }
        .badge-orange { background: #fff3e0; color: #e65100; }
        .badge-green  { background: #dcfce7; color: #166534; }
        .badge-red    { background: #fee2e2; color: #991b1b; }
        .badge-gray   { background: var(--gray-100); color: var(--gray-600); }

        .payment-badge {
            display: inline-flex; align-items: center; gap: 0.3rem;
            padding: 0.2rem 0.6rem; border-radius: 6px;
            font-size: 0.72rem; font-weight: 700;
        }
        .pay-cod    { background: #fce4ec; color: #880e4f; }
        .pay-paid   { background: #dcfce7; color: #166534; }
        .pay-unpaid { background: #fee2e2; color: #991b1b; }

        .empty-state {
            text-align: center; padding: 3rem 2rem;
            color: var(--gray-400);
        }
        .empty-state i { font-size: 3rem; color: var(--gray-200); margin-bottom: 0.75rem; display: block; }
        .empty-state p { font-size: 0.9rem; }

        /* ======= FOOTER ======= */
        .footer {
            background: var(--white); border-top: 1px solid var(--gray-200);
            padding: 1.2rem 2rem; display: flex;
            align-items: center; justify-content: space-between;
        }
        .footer-logo { display: flex; align-items: center; gap: 0.4rem; font-size: 0.9rem; font-weight: 700; color: var(--green-dark); text-decoration: none; }
        .footer-logo i { color: var(--green); }
        .footer-copy { font-size: 0.78rem; color: var(--gray-400); }

        @media (max-width: 1024px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
        }
        @media (max-width: 900px) {
            .layout { flex-direction: column; }
            .sidebar { width: 100%; position: static; }
            .sidebar-nav { display: flex; flex-wrap: wrap; gap: 0.25rem; }
            .sidebar-nav a { width: auto; }
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
            .filter-bar { flex-direction: column; align-items: stretch; }
            .filter-actions { justify-content: flex-end; }
        }
        @media (max-width: 600px) {
            .stats-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

    <jsp:include page="/sidebar.jsp">
        <jsp:param name="activePage" value="revenue" />
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

                <!-- Stats Grid -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon icon-orange">
                            <i class="fa-solid fa-calendar-day"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-label">Doanh thu hôm nay</span>
                            <span class="stat-value currency"><%= nf.format((long)(todayRevenue != null ? todayRevenue : 0)) %></span>
                            <span class="stat-sub"><%= todayOrderCount != null ? todayOrderCount : 0 %> đơn hôm nay</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon icon-green">
                            <i class="fa-solid fa-calendar-month"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-label">Doanh thu tháng này</span>
                            <span class="stat-value currency"><%= nf.format((long)(monthRevenue != null ? monthRevenue : 0)) %></span>
                            <span class="stat-sub">Tháng <%= new java.text.SimpleDateFormat("MM/yyyy").format(new java.util.Date()) %></span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon icon-blue">
                            <i class="fa-solid fa-receipt"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-label">Tổng đơn hàng</span>
                            <span class="stat-value"><%= totalOrders != null ? totalOrders : 0 %></span>
                            <span class="stat-sub">Tất cả đơn hàng</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon icon-purple">
                            <i class="fa-solid fa-chart-simple"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-label">Giá trị TB / đơn</span>
                            <span class="stat-value currency"><%= nf.format((long)(avgOrderValue != null ? avgOrderValue : 0)) %></span>
                            <span class="stat-sub">Trung bình 1 đơn</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon icon-green">
                            <i class="fa-solid fa-sack-dollar"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-label">Tổng doanh thu</span>
                            <span class="stat-value currency"><%= nf.format((long)(totalRevenue != null ? totalRevenue : 0)) %></span>
                            <span class="stat-sub">Tất cả đơn giao thành công</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon icon-yellow">
                            <i class="fa-solid fa-circle-check"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-label">Đơn đã giao</span>
                            <span class="stat-value"><%= completedOrders != null ? completedOrders : 0 %></span>
                            <span class="stat-sub">Giao thành công</span>
                        </div>
                    </div>
                </div>

                <!-- Revenue Chart -->
                <div class="chart-card">
                    <div class="chart-header">
                        <div class="chart-title">
                            <i class="fa-solid fa-chart-area"></i> Biểu Đồ Doanh Thu
                        </div>
                        <span class="chart-badge">14 ngày gần nhất</span>
                    </div>
                    <div class="chart-body">
                        <canvas id="revenueChart"></canvas>
                    </div>
                </div>

                <!-- Filter Bar -->
                <form method="get" action="<%= request.getContextPath() %>/seller/revenue" style="display:contents;">
                    <div class="filter-bar">
                        <div class="filter-group">
                            <label class="filter-label"><i class="fa-solid fa-calendar"></i> Từ ngày</label>
                            <input type="date" name="dateFrom" class="filter-input" value="<%= dateFrom != null ? dateFrom : "" %>" max="<%= java.time.LocalDate.now() %>">
                        </div>
                        <div class="filter-group">
                            <label class="filter-label"><i class="fa-solid fa-calendar"></i> Đến ngày</label>
                            <input type="date" name="dateTo" class="filter-input" value="<%= dateTo != null ? dateTo : "" %>" max="<%= java.time.LocalDate.now() %>">
                        </div>
                        <div class="filter-group">
                            <label class="filter-label"><i class="fa-solid fa-flag"></i> Trạng thái</label>
                            <select name="status" class="filter-select">
                                <option value="">-- Tất cả --</option>
                                <option value="1" <%= "1".equals(statusParam) ? "selected" : "" %>>Chờ xác nhận</option>
                                <option value="2" <%= "2".equals(statusParam) ? "selected" : "" %>>Đã xác nhận</option>
                                <option value="3" <%= "3".equals(statusParam) ? "selected" : "" %>>Đang giao hàng</option>
                                <option value="4" <%= "4".equals(statusParam) ? "selected" : "" %>>Đã giao</option>
                                <option value="5" <%= "5".equals(statusParam) ? "selected" : "" %>>Đã hủy</option>
                            </select>
                        </div>
                        <div class="filter-actions">
                            <button type="submit" class="btn btn-green">
                                <i class="fa-solid fa-filter"></i> Lọc
                            </button>
                            <a href="<%= request.getContextPath() %>/seller/revenue" class="btn btn-outline">
                                <i class="fa-solid fa-rotate-left"></i> Reset
                            </a>
                        </div>
                    </div>
                </form>

                <% if (dateFrom != null || dateTo != null || (statusParam != null && !statusParam.isEmpty())) { %>
                <div class="filter-summary">
                    <span class="filter-summary-text">
                        Kết quả lọc: <%= filteredOrders != null ? filteredOrders.size() : 0 %> đơn hàng
                        <% if (dateFrom != null && !dateFrom.isEmpty()) { %> từ <%= dateFrom %> <% } %>
                        <% if (dateTo != null && !dateTo.isEmpty()) { %> đến <%= dateTo %> <% } %>
                        <% if (statusParam != null && !statusParam.isEmpty()) { %>
                            — trạng thái: <strong><%
                                if ("1".equals(statusParam)) out.print("Chờ xác nhận");
                                else if ("2".equals(statusParam)) out.print("Đã xác nhận");
                                else if ("3".equals(statusParam)) out.print("Đang giao hàng");
                                else if ("4".equals(statusParam)) out.print("Đã giao");
                                else if ("5".equals(statusParam)) out.print("Đã hủy");
                            %></strong><% } %>
                    </span>
                    <span class="filter-summary-rev">
                        DT lọc: <%= nf.format((long)(filteredRevenue != null ? filteredRevenue : 0)) %> đ
                    </span>
                </div>
                <% } %>

                <!-- Orders Table -->
                <div class="table-card">
                    <div class="table-header">
                        <span class="table-title">
                            <i class="fa-solid fa-list" style="color:var(--green);margin-right:0.4rem;"></i>
                            Danh Sách Đơn Hàng
                        </span>
                        <span class="table-count">
                            <%= filteredOrders != null ? filteredOrders.size() : 0 %> đơn
                        </span>
                    </div>
                    <div class="table-wrap">
                        <table>
                            <thead>
                                <tr>
                                    <th>Mã ĐH</th>
                                    <th>Khách hàng</th>
                                    <th>Ngày đặt</th>
                                    <th>Trạng thái</th>
                                    <!-- <th>Thanh toán</th> -->
                                    <th>Tổng tiền</th>
                                    <th>Voucher</th>
                                </tr>
                            </thead>
                            <tbody>
                            <%
                                List<Order> displayOrders = filteredOrders;
                                if (displayOrders == null || displayOrders.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="7">
                                        <div class="empty-state">
                                            <i class="fa-solid fa-inbox"></i>
                                            <p>Không có đơn hàng nào phù hợp với bộ lọc.</p>
                                        </div>
                                    </td>
                                </tr>
                            <%
                                } else {
                                    for (Order o : displayOrders) {
                                        String statusLabel, statusClass;
                                        switch (o.getStatus()) {
                                            case 1: statusLabel = "Chờ xác nhận"; statusClass = "badge-yellow"; break;
                                            case 2: statusLabel = "Đã xác nhận"; statusClass = "badge-blue"; break;
                                            case 3: statusLabel = "Đang giao"; statusClass = "badge-orange"; break;
                                            case 4: statusLabel = "Đã giao"; statusClass = "badge-green"; break;
                                            case 5: statusLabel = "Đã hủy"; statusClass = "badge-red"; break;
                                            default: statusLabel = "Không rõ"; statusClass = "badge-gray";
                                        }

                                        String paymentLabel, paymentClass;
                                        if (o.getPaymentStatus() == 1) {
                                            paymentLabel = "Đã thanh toán"; paymentClass = "pay-paid";
                                        } else if (o.getPaymentStatus() == 2) {
                                            paymentLabel = "Hoàn tiền"; paymentClass = "pay-unpaid";
                                        } else {
                                            paymentLabel = "Chưa thanh toán"; paymentClass = "pay-unpaid";
                                        }

                                        String orderDateStr = "";
                                        if (o.getOrderDate() != null) {
                                            orderDateStr = sdf.format(o.getOrderDate());
                                        }
                            %>
                                <tr>
                                    <td><span class="order-id">#<%= o.getId() %></span></td>
                                    <td>
                                        <div class="order-customer"><%= o.getRecipientName() != null ? o.getRecipientName() : (o.getCustomerName() != null ? o.getCustomerName() : "-") %></div>
                                        <div style="font-size:0.72rem;color:var(--gray-400);"><%= o.getRecipientPhone() != null ? o.getRecipientPhone() : "" %></div>
                                    </td>
                                    <td class="order-date"><%= orderDateStr %></td>
                                    <td><span class="badge <%= statusClass %>"><%= statusLabel %></span></td>
                                    <!-- <td><span class="payment-badge <%= paymentClass %>"><i class="fa-solid fa-circle" style="font-size:0.4rem;"></i> <%= paymentLabel %></span></td> -->
                                    <td class="order-total"><%= nf.format((long)o.getFinalCost()) %> đ</td>
                                    <td style="font-size:0.78rem;color:var(--gray-400);"><%= o.getVoucherCode() != null ? o.getVoucherCode() : "—" %></td>
                                </tr>
                            <%
                                    }
                                }
                            %>
                            </tbody>
                        </table>
                    </div>
                </div>

            <% } %>

        </main>
    </div>

    <!-- Footer -->
    <footer class="footer">
        <a href="<%= request.getContextPath() %>/home.jsp" class="footer-logo">
            <i class="fa-solid fa-apple-whole"></i> Sena Shop
        </a>
        <span class="footer-copy">&copy; 2024 Sena Shop. Trái cây tươi ngon mỗi ngày.</span>
    </footer>

    <script>
        const chartLabels = <%= chartLabels %>;
        const chartData   = <%= chartData %>;

        if (chartLabels.length > 0) {
            const ctx = document.getElementById('revenueChart').getContext('2d');
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: chartLabels,
                    datasets: [{
                        label: 'Doanh thu (đ)',
                        data: chartData,
                        borderColor: '#4caf50',
                        backgroundColor: 'rgba(76, 175, 80, 0.08)',
                        borderWidth: 2.5,
                        pointBackgroundColor: '#4caf50',
                        pointBorderColor: '#fff',
                        pointBorderWidth: 2,
                        pointRadius: 4,
                        pointHoverRadius: 6,
                        fill: true,
                        tension: 0.35
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: {
                                label: function(ctx) {
                                    return ctx.parsed.y.toLocaleString('vi') + ' đ';
                                }
                            }
                        }
                    },
                    scales: {
                        x: {
                            grid: { display: false },
                            ticks: { font: { size: 11 }, color: '#9aaa9a' }
                        },
                        y: {
                            grid: { color: 'rgba(0,0,0,0.04)' },
                            ticks: {
                                font: { size: 11 },
                                color: '#9aaa9a',
                                callback: function(val) {
                                    if (val >= 1000000) return (val/1000000).toFixed(1) + 'M';
                                    if (val >= 1000) return (val/1000).toFixed(0) + 'K';
                                    return val;
                                }
                            }
                        }
                    }
                }
            });
        }
    </script>

</body>
</html>
