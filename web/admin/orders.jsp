<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Order" %>
<%@ page import="model.OrderDetail" %>
<%@ page import="model.Shop" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    Account user = (Account) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<Order> orders = (List<Order>) request.getAttribute("orders");
    Map<Integer, List<OrderDetail>> detailsMap = (Map<Integer, List<OrderDetail>>) request.getAttribute("detailsMap");
    List<Shop> shops = (List<Shop>) request.getAttribute("shops");

    String filterStatus = (String) request.getAttribute("filterStatus");
    String filterShopId = (String) request.getAttribute("filterShopId");
    String filterFromDate = (String) request.getAttribute("filterFromDate");
    String filterToDate = (String) request.getAttribute("filterToDate");
    String filterMinValue = (String) request.getAttribute("filterMinValue");
    String filterMaxValue = (String) request.getAttribute("filterMaxValue");

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    NumberFormat nf = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Monitor Đơn Hàng | Admin Dashboard</title>
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

        /* ======= TOPNAV ======= */
        .topnav {
            background: var(--white);
            border-bottom: 1px solid var(--gray-200);
            height: 60px;
            display: flex;
            align-items: center;
            padding: 0 2rem;
            gap: 1.5rem;
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
        .nav-links {
            display: flex;
            gap: 0.25rem;
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
        .nav-links a.active { background: var(--green-light); color: var(--green-dark); font-weight: 600; }
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
        .nav-username {
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--gray-800);
        }

        /* ======= LAYOUT ======= */
        .layout {
            max-width: 1280px;
            margin: 1.5rem auto;
            padding: 0 1.5rem;
            display: flex;
            flex-direction: column;
            gap: 1.25rem;
        }

        /* ======= PAGE HEADER ======= */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 1rem;
            flex-wrap: wrap;
        }
        .page-title {
            font-size: 1.5rem;
            font-weight: 800;
            color: var(--gray-800);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .page-title i { color: var(--green); }

        /* ======= FILTER CARD ======= */
        .filter-card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            padding: 1.25rem 1.5rem;
        }
        .filter-title {
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--gray-600);
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .filter-title i { color: var(--green); }
        .filter-row {
            display: flex;
            flex-wrap: wrap;
            gap: 0.75rem;
            align-items: flex-end;
        }
        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 0.25rem;
        }
        .filter-label {
            font-size: 0.72rem;
            font-weight: 600;
            color: var(--gray-600);
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        .filter-input, .filter-select {
            padding: 0.5rem 0.75rem;
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-size: 0.85rem;
            font-family: inherit;
            color: var(--gray-800);
            background: var(--white);
            outline: none;
            transition: border-color 0.15s;
        }
        .filter-input:focus, .filter-select:focus { border-color: var(--green); }
        .filter-select { min-width: 160px; }
        .filter-input[type="number"] { width: 130px; }
        .filter-input[type="date"] { width: 155px; }

        .btn {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.5rem 1rem;
            border-radius: var(--radius-sm);
            font-size: 0.82rem;
            font-weight: 600;
            border: none;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.15s;
            white-space: nowrap;
        }
        .btn-green {
            background: var(--green);
            color: white;
            box-shadow: 0 2px 6px rgba(76,175,80,0.25);
        }
        .btn-green:hover {
            background: var(--green-dark);
            transform: translateY(-1px);
        }
        .btn-gray {
            background: var(--gray-100);
            color: var(--gray-600);
        }
        .btn-gray:hover { background: var(--gray-200); }

        /* ======= STATS BAR ======= */
        .stats-bar {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
        }
        .stat-card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            padding: 1rem 1.25rem;
            flex: 1;
            min-width: 160px;
            display: flex;
            flex-direction: column;
            gap: 0.25rem;
        }
        .stat-label {
            font-size: 0.72rem;
            font-weight: 600;
            color: var(--gray-400);
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        .stat-value {
            font-size: 1.5rem;
            font-weight: 800;
            color: var(--gray-800);
        }
        .stat-value.green { color: var(--green-dark); }
        .stat-value.red { color: #dc2626; }
        .stat-value.yellow { color: #d97706; }

        /* ======= TABS ======= */
        .tabs-card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            padding: 0.4rem;
            display: flex;
            gap: 0.25rem;
            overflow-x: auto;
            flex-wrap: wrap;
        }
        .tab-btn {
            padding: 0.55rem 1.1rem;
            border-radius: var(--radius-sm);
            font-size: 0.82rem;
            font-weight: 600;
            border: none;
            background: transparent;
            color: var(--gray-600);
            cursor: pointer;
            transition: all 0.15s;
            white-space: nowrap;
        }
        .tab-btn:hover { background: var(--gray-50); color: var(--gray-800); }
        .tab-btn.active { background: var(--green-light); color: var(--green-dark); }

        /* ======= ORDER TABLE ======= */
        .card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
        }
        .table-wrap { overflow-x: auto; }
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.875rem;
        }
        thead { background: var(--gray-50); }
        th {
            padding: 0.8rem 1rem;
            text-align: left;
            font-weight: 700;
            font-size: 0.78rem;
            color: var(--gray-600);
            text-transform: uppercase;
            letter-spacing: 0.04em;
            border-bottom: 2px solid var(--gray-200);
            white-space: nowrap;
        }
        td {
            padding: 0.85rem 1rem;
            border-bottom: 1px solid var(--gray-100);
            color: var(--gray-800);
            vertical-align: middle;
        }
        tbody tr:last-child td { border-bottom: none; }
        tbody tr:hover { background: var(--gray-50); }

        .badge {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.2rem 0.65rem;
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

        .shop-badge {
            background: var(--green-light);
            color: var(--green-dark);
            font-weight: 600;
            font-size: 0.78rem;
            padding: 0.2rem 0.55rem;
            border-radius: 6px;
        }

        .cost-info { font-size: 0.82rem; color: var(--gray-600); }
        .cost-total { font-weight: 700; color: var(--green-dark); }

        /* Empty state */
        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            color: var(--gray-400);
        }
        .empty-state i { font-size: 3rem; color: var(--gray-200); margin-bottom: 0.75rem; display: block; }
        .empty-state p { font-size: 0.95rem; }

        @media (max-width: 768px) {
            .filter-row { flex-direction: column; }
            .filter-select, .filter-input[type="number"], .filter-input[type="date"] { width: 100%; }
        }

        /* ======= PAGINATION ======= */
        .pagination-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            padding: 1rem 1.5rem;
            flex-wrap: wrap;
            gap: 1rem;
        }
        .pagination-info {
            font-size: 0.875rem;
            color: var(--gray-600);
            font-weight: 500;
        }
        .pagination {
            display: flex;
            align-items: center;
            gap: 0.35rem;
        }
        .page-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 36px;
            height: 36px;
            padding: 0 0.5rem;
            border-radius: var(--radius-sm);
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--gray-600);
            text-decoration: none;
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            transition: all 0.15s;
        }
        .page-btn:hover:not(.disabled):not(.active) {
            background: var(--green-light);
            color: var(--green-dark);
            border-color: var(--green-mid);
        }
        .page-btn.active {
            background: var(--green);
            color: white;
            border-color: var(--green);
        }
        .page-btn.disabled {
            opacity: 0.4;
            cursor: not-allowed;
            pointer-events: none;
        }
        .page-ellipsis {
            color: var(--gray-400);
            padding: 0 0.25rem;
            font-size: 0.85rem;
        }
    </style>
</head>
<body>

    <!-- Topnav -->
    <nav class="topnav">
        <a href="<%= request.getContextPath() %>/home.jsp" class="nav-logo">
            <i class="fa-solid fa-apple-whole"></i> Sena Shop
        </a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/home.jsp">Trang Chủ</a>
            <a href="<%= request.getContextPath() %>/products">Sản Phẩm</a>
            <a href="<%= request.getContextPath() %>/admin/customers">
                <i class="fa-solid fa-users"></i> Khách Hàng
            </a>
            <a href="<%= request.getContextPath() %>/admin/orders" class="active">
                <i class="fa-solid fa-chart-line"></i> Monitor Đơn Hàng
            </a>
                            <a href="<%= request.getContextPath() %>/admin/seller-requests">
                <i class="fa-solid fa-store"></i> Duyệt Seller
            </a>
        </div>
        <div class="nav-right">
            <span class="nav-username">Admin: <%= user.getFullname() != null ? user.getFullname() : user.getUsername() %></span>
            <% String navAvatar = user.getAvatar();
               if (navAvatar == null || navAvatar.trim().isEmpty()) {
                   String fn = user.getFullname() != null ? user.getFullname() : user.getUsername();
                   navAvatar = "https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(fn, "UTF-8") + "&background=4caf50&color=fff&size=80&bold=true&rounded=true";
               }
            %>
            <img class="nav-avatar" src="<%= navAvatar %>" alt="avatar">
        </div>
    </nav>

    <div class="layout">

        <!-- Page Header -->
        <div class="page-header">
            <h1 class="page-title">
                <i class="fa-solid fa-chart-line"></i>
                Monitor Đơn Hàng Toàn Hệ Thống
            </h1>
        </div>

        <!-- Filter Form -->
        <form id="filterForm" method="get" action="orders">
            <div class="filter-card">
                <div class="filter-title">
                    <i class="fa-solid fa-filter"></i> Bộ lọc
                </div>
                <div class="filter-row">

                    <div class="filter-group">
                        <label class="filter-label">Cửa hàng</label>
                        <select name="shopId" class="filter-select">
                            <option value="">Tất cả cửa hàng</option>
                            <% if (shops != null) {
                                for (Shop s : shops) { %>
                                <option value="<%= s.getId() %>" <%= ("" + s.getId()).equals(filterShopId) ? "selected" : "" %>>
                                    <%= s.getShopName() != null ? s.getShopName() : "Shop #" + s.getId() %>
                                </option>
                            <% } } %>
                        </select>
                    </div>

                    <div class="filter-group">
                        <label class="filter-label">Trạng thái</label>
                        <select name="status" class="filter-select" id="statusSelect">
                            <option value="">Tất cả</option>
                            <option value="1" <%= "1".equals(filterStatus) ? "selected" : "" %>>Chờ xác nhận</option>
                            <option value="2" <%= "2".equals(filterStatus) ? "selected" : "" %>>Đã xác nhận</option>
                            <option value="3" <%= "3".equals(filterStatus) ? "selected" : "" %>>Đang giao</option>
                            <option value="4" <%= "4".equals(filterStatus) ? "selected" : "" %>>Đã giao</option>
                            <option value="5" <%= "5".equals(filterStatus) ? "selected" : "" %>>Đã hủy</option>
                        </select>
                    </div>

                    <div class="filter-group">
                        <label class="filter-label">Từ ngày</label>
                        <input type="date" name="fromDate" class="filter-input" value="<%= filterFromDate != null ? filterFromDate : "" %>">
                    </div>

                    <div class="filter-group">
                        <label class="filter-label">Đến ngày</label>
                        <input type="date" name="toDate" class="filter-input" value="<%= filterToDate != null ? filterToDate : "" %>">
                    </div>

                    <div class="filter-group">
                        <label class="filter-label">Giá trị từ (đ)</label>
                        <input type="number" name="minValue" class="filter-input" placeholder="0" min="0" step="1000"
                               value="<%= filterMinValue != null ? filterMinValue : "" %>">
                    </div>

                    <div class="filter-group">
                        <label class="filter-label">Đến (đ)</label>
                        <input type="number" name="maxValue" class="filter-input" placeholder="∞" min="0" step="1000"
                               value="<%= filterMaxValue != null ? filterMaxValue : "" %>">
                    </div>

                    <div style="display:flex;gap:0.5rem;align-items:center;">
                        <button type="submit" class="btn btn-green">
                            <i class="fa-solid fa-magnifying-glass"></i> Lọc
                        </button>
                        <a href="<%= request.getContextPath() %>/admin/orders" class="btn btn-gray">
                            <i class="fa-solid fa-rotate-left"></i> Reset
                        </a>
                    </div>
                </div>
            </div>
        </form>

        <!-- Stats Bar -->
        <%
            if (orders != null && !orders.isEmpty()) {
                long totalRevenue = 0;
                long pendingCount = 0;
                long completedCount = 0;
                long cancelledCount = 0;
                for (Order o : orders) {
                    totalRevenue += (long) o.getFinalCost();
                    if (o.getStatus() == 1) pendingCount++;
                    else if (o.getStatus() == 4) completedCount++;
                    else if (o.getStatus() == 5) cancelledCount++;
                }
        %>
        <div class="stats-bar">
            <div class="stat-card">
                <div class="stat-label">Tổng đơn (lọc)</div>
                <div class="stat-value green"><%= orders.size() %></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Chờ xác nhận</div>
                <div class="stat-value yellow"><%= pendingCount %></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Đã giao</div>
                <div class="stat-value green"><%= completedCount %></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Đã hủy</div>
                <div class="stat-value red"><%= cancelledCount %></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Doanh thu (lọc)</div>
                <div class="stat-value" style="font-size:1.1rem;"><%= nf.format(totalRevenue) %> đ</div>
            </div>
        </div>
        <% } %>

        <!-- Tab Filter -->
        <div class="tabs-card">
            <button class="tab-btn active" onclick="filterByStatus('')">Tất cả</button>
            <button class="tab-btn" onclick="filterByStatus('1')">Chờ xác nhận</button>
            <button class="tab-btn" onclick="filterByStatus('2')">Đã xác nhận</button>
            <button class="tab-btn" onclick="filterByStatus('3')">Đang giao</button>
            <button class="tab-btn" onclick="filterByStatus('4')">Đã giao</button>
            <button class="tab-btn" onclick="filterByStatus('5')">Đã hủy</button>
        </div>

        <!-- Orders Table -->
        <div class="card">
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Mã Đơn</th>
                            <th>Khách Hàng</th>
                            <th>Cửa Hàng</th>
                            <th>Ngày đặt</th>
                            <th>Thanh Toán</th>
                            <th>Tổng Giá Trị</th>
                            <th>Trạng Thái</th>
                        </tr>
                    </thead>
                    <tbody id="ordersTableBody">
                    <%
                        if (orders != null && !orders.isEmpty()) {
                            int idx = 1;
                            for (Order o : orders) {
                                List<OrderDetail> details = detailsMap.get(o.getId());
                    %>
                        <tr data-status="<%= o.getStatus() %>">
                            <td style="color:var(--gray-400); font-size:0.78rem;"><%= idx++ %></td>
                            <td>
                                <strong style="color:var(--gray-800);">#<%= o.getId() %></strong>
                            </td>
                            <td>
                                <div style="font-weight:600;"><%= o.getCustomerName() != null ? o.getCustomerName() : "Khách vãng lai" %></div>
                                <div style="font-size:0.75rem;color:var(--gray-400);"><%= o.getRecipientPhone() != null ? o.getRecipientPhone() : "" %></div>
                            </td>
                            <td>
                                <% if (o.getShopName() != null) { %>
                                    <span class="shop-badge">
                                        <i class="fa-solid fa-shop"></i> <%= o.getShopName() %>
                                    </span>
                                <% } else { %>
                                    <span style="color:var(--gray-400);font-size:0.78rem;">—</span>
                                <% } %>
                            </td>
                            <td>
                                <div style="font-size:0.82rem;"><%= o.getOrderDate() != null ? sdf.format(o.getOrderDate()) : "—" %></div>
                            </td>
                            <td>
                                <div style="font-size:0.82rem;"><%= o.getPaymentMethod() != null ? o.getPaymentMethod() : "—" %></div>
                                <div style="font-size:0.72rem;color:<%= o.getPaymentStatus() == 1 ? "#166534" : o.getPaymentStatus() == 2 ? "#1e40af" : "var(--gray-400)" %>;">
                                    <%= o.getPaymentStatusLabel() %>
                                </div>
                            </td>
                            <td>
                                <div class="cost-total"><%= nf.format((long) o.getFinalCost()) %> đ</div>
                                <div class="cost-info">
                                    Tiền hàng: <%= nf.format((long) o.getTotalCost()) %> đ
                                    <% if (o.getDiscountAmount() > 0) { %>
                                        | Giảm: <span style="color:#dc2626;">-<%= nf.format((long) o.getDiscountAmount()) %> đ</span>
                                    <% } %>
                                </div>
                            </td>
                            <td>
                                <span class="badge <%= o.getStatusClass() %>">
                                    <%= o.getStatusLabel() %>
                                </span>
                            </td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr>
                            <td colspan="8">
                                <div class="empty-state">
                                    <i class="fa-solid fa-receipt"></i>
                                    <p>Không tìm thấy đơn hàng nào phù hợp với bộ lọc.</p>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <!-- Pagination -->
    <%
        Integer currentPage = (Integer) request.getAttribute("currentPage");
        Integer totalPages = (Integer) request.getAttribute("totalPages");
        Integer totalOrders = (Integer) request.getAttribute("totalOrders");
        if (currentPage == null) currentPage = 1;
        if (totalPages == null) totalPages = 1;
        if (totalOrders == null) totalOrders = 0;

        StringBuilder paginationParams = new StringBuilder();
        if (filterStatus != null && !filterStatus.isEmpty()) paginationParams.append("&status=").append(filterStatus);
        if (filterShopId != null && !filterShopId.isEmpty()) paginationParams.append("&shopId=").append(filterShopId);
        if (filterFromDate != null && !filterFromDate.isEmpty()) paginationParams.append("&fromDate=").append(filterFromDate);
        if (filterToDate != null && !filterToDate.isEmpty()) paginationParams.append("&toDate=").append(filterToDate);
        if (filterMinValue != null && !filterMinValue.isEmpty()) paginationParams.append("&minValue=").append(filterMinValue);
        if (filterMaxValue != null && !filterMaxValue.isEmpty()) paginationParams.append("&maxValue=").append(filterMaxValue);
        String extraParams = paginationParams.toString();
    %>
    <% if (totalPages > 1 || totalOrders > 0) { %>
    <div class="pagination-container">
        <div class="pagination-info">
            Hiển thị <%= (currentPage - 1) * 15 + 1 %> - <%= Math.min(currentPage * 15, totalOrders) %> trong tổng số <%= totalOrders %> đơn hàng
        </div>
        <div class="pagination">
            <% if (currentPage > 1) { %>
                <a href="?page=<%= currentPage - 1 %><%= extraParams %>" class="page-btn">
                    <i class="fa-solid fa-chevron-left"></i>
                </a>
            <% } else { %>
                <span class="page-btn disabled"><i class="fa-solid fa-chevron-left"></i></span>
            <% } %>

            <%
                int startPage = Math.max(1, currentPage - 2);
                int endPage = Math.min(totalPages, currentPage + 2);

                if (startPage > 1) {
            %>
                <a href="?page=1<%= extraParams %>" class="page-btn">1</a>
                <% if (startPage > 2) { %>
                    <span class="page-ellipsis">...</span>
                <% } %>
            <% } %>

            <% for (int i = startPage; i <= endPage; i++) { %>
                <% if (i == currentPage) { %>
                    <span class="page-btn active"><%= i %></span>
                <% } else { %>
                    <a href="?page=<%= i %><%= extraParams %>" class="page-btn"><%= i %></a>
                <% } %>
            <% } %>

            <%
                if (endPage < totalPages) {
                    if (endPage < totalPages - 1) {
            %>
                <span class="page-ellipsis">...</span>
            <% } %>
                <a href="?page=<%= totalPages %><%= extraParams %>" class="page-btn"><%= totalPages %></a>
            <% } %>

            <% if (currentPage < totalPages) { %>
                <a href="?page=<%= currentPage + 1 %><%= extraParams %>" class="page-btn">
                    <i class="fa-solid fa-chevron-right"></i>
                </a>
            <% } else { %>
                <span class="page-btn disabled"><i class="fa-solid fa-chevron-right"></i></span>
            <% } %>
        </div>
    </div>
    <% } %>

    <script>
        // Sync tab active state with current filter
        (function() {
            var currentStatus = '<%= filterStatus != null ? filterStatus : "" %>';
            var buttons = document.querySelectorAll('.tab-btn');
            buttons.forEach(function(btn) {
                btn.classList.remove('active');
                var onclick = btn.getAttribute('onclick') || '';
                var match = currentStatus === '' ? onclick.indexOf("filterByStatus('')") !== -1 : onclick.indexOf("'" + currentStatus + "'") !== -1;
                if (match) btn.classList.add('active');
            });
        })();

        // Tab filter: update select + form submit for server-side filter
        function filterByStatus(status) {
            var form = document.getElementById('filterForm');
            var select = document.getElementById('statusSelect');
            if (select) select.value = status;
            // Reset page to 1 when filter changes
            var pageInput = document.getElementById('pageInput');
            if (pageInput) pageInput.value = '1';
            if (form) form.submit();
        }

        // Preserve page param in form
        (function() {
            var form = document.getElementById('filterForm');
            if (!form) return;
            var pageInput = document.createElement('input');
            pageInput.type = 'hidden';
            pageInput.name = 'page';
            pageInput.id = 'pageInput';
            pageInput.value = '<%= currentPage %>';
            form.appendChild(pageInput);
        })();
    </script>
    <!-- Floating Report Button -->
    <a href="<%= request.getContextPath() %>/admin/reports" class="floating-report-btn" title="Kiểm tra báo cáo">
        <i class="fa-solid fa-flag"></i>
    </a>
    <style>
        .floating-report-btn {
            position: fixed;
            bottom: 30px;
            right: 30px;
            background-color: #ef4444;
            color: white;
            width: 60px;
            height: 60px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            cursor: pointer;
            z-index: 1000;
            text-decoration: none;
            transition: all 0.3s ease;
        }
        .floating-report-btn:hover {
            transform: translateY(-5px);
            background-color: #dc2626;
            color: white;
            box-shadow: 0 6px 16px rgba(0,0,0,0.2);
        }
    </style>
</body>
</html>
