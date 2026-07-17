<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Account user = (Account) session.getAttribute("Account");
    if (user == null || !"admin".equals(user.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<Account> customers = (List<Account>) request.getAttribute("customers");
    String keyword = (String) request.getAttribute("searchKeyword");
    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Khách Hàng | Sena Shop</title>
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
        }

        /* ======= ALERTS ======= */
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
        .alert-success { background: #dcfce7; border: 1px solid #bbf7d0; color: #15803d; }
        .alert-danger  { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }

        /* ======= PAGE HEADER ======= */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
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
        .stat-badge {
            background: var(--green-light);
            color: var(--green-dark);
            padding: 0.25rem 0.75rem;
            border-radius: 100px;
            font-size: 0.8rem;
            font-weight: 700;
        }

        /* ======= SEARCH BAR ======= */
        .toolbar {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            padding: 1rem 1.25rem;
            display: flex;
            gap: 0.75rem;
            align-items: center;
            margin-bottom: 1.25rem;
            flex-wrap: wrap;
        }
        .search-form {
            display: flex;
            gap: 0.5rem;
            flex: 1;
            min-width: 280px;
        }
        .search-input {
            flex: 1;
            padding: 0.55rem 0.9rem;
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-size: 0.875rem;
            font-family: inherit;
            outline: none;
            transition: border-color 0.15s;
        }
        .search-input:focus { border-color: var(--green); }

        /* ======= TABLE ======= */
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
            font-size: 0.8rem;
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

        .customer-info {
            display: flex;
            align-items: center;
            gap: 0.65rem;
        }
        .avatar-sm {
            width: 36px; height: 36px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--green-mid);
            background: var(--green-light);
            flex-shrink: 0;
        }
        .customer-name { font-weight: 600; color: var(--gray-800); }
        .customer-username { font-size: 0.78rem; color: var(--gray-400); }

        .badge {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.2rem 0.65rem;
            border-radius: 100px;
            font-size: 0.75rem;
            font-weight: 700;
        }
        .badge-green { background: #dcfce7; color: #166534; }
        .badge-red   { background: #fee2e2; color: #991b1b; }
        .badge-gray  { background: var(--gray-100); color: var(--gray-600); }

        .order-count-badge {
            background: var(--green-light);
            color: var(--green-dark);
            font-weight: 700;
            padding: 0.2rem 0.55rem;
            border-radius: 100px;
            font-size: 0.78rem;
        }

        .action-btn {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            padding: 0.4rem 0.75rem;
            border-radius: var(--radius-sm);
            font-size: 0.8rem;
            font-weight: 600;
            border: none;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.15s;
        }
        .btn-history {
            background: var(--green-light);
            color: var(--green-dark);
        }
        .btn-history:hover { background: #c8e6c9; }
        .btn-block {
            background: #fee2e2;
            color: #dc2626;
        }
        .btn-block:hover { background: #fecaca; }
        .btn-unblock {
            background: #dcfce7;
            color: #15803d;
        }
        .btn-unblock:hover { background: #bbf7d0; }

        /* Empty state */
        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            color: var(--gray-400);
        }
        .empty-state i { font-size: 3rem; margin-bottom: 0.75rem; display: block; color: var(--gray-200); }
        .empty-state p { font-size: 0.95rem; }

        /* ======= RESPONSIVE ======= */
        @media (max-width: 768px) {
            .toolbar { flex-direction: column; align-items: stretch; }
            .search-form { min-width: 0; }
            .page-header { flex-direction: column; align-items: flex-start; }
        }
    </style>
</head>
<body>

    <!-- Topnav -->
    <nav class="topnav">
        <a href="<%= request.getContextPath() %>/admin/orders" class="nav-logo">
            <i class="fa-solid fa-shield-halved"></i> Admin Panel
        </a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/admin/customers" class="active">
                <i class="fa-solid fa-users"></i> Khách Hàng
            </a>
            <a href="<%= request.getContextPath() %>/admin/orders">
                <i class="fa-solid fa-chart-line"></i> Monitor Đơn Hàng
            </a>
            <a href="<%= request.getContextPath() %>/admin/seller-requests">
                <i class="fa-solid fa-store"></i> Duyệt Seller
            </a>
        </div>
        <div class="nav-right">
            <span class="nav-username">Admin: <%= user.getFullname() != null ? user.getFullname() : user.getUsername() %></span>
            <a href="<%= request.getContextPath() %>/logout" class="btn btn-sm" style="background: #fee2e2; color: #991b1b; text-decoration: none;">Đăng Xuất</a>
        </div>
    </nav>

    <div class="layout">
        <% if (message != null) { %>
            <div class="alert alert-success">
                <i class="fa-solid fa-circle-check"></i> <%= message %>
            </div>
        <% } %>
        <% if (error != null) { %>
            <div class="alert alert-danger">
                <i class="fa-solid fa-circle-exclamation"></i> <%= error %>
            </div>
        <% } %>

        <!-- Page Header -->
        <div class="page-header">
            <h1 class="page-title">
                <i class="fa-solid fa-users"></i>
                Quản Lý Khách Hàng
                <span class="stat-badge">
                    <%= request.getAttribute("totalCount") != null ? request.getAttribute("totalCount") : 0 %> khách hàng
                </span>
            </h1>
        </div>

        <!-- Search Toolbar -->
        <div class="toolbar">
            <form class="search-form" method="get" action="<%= request.getContextPath() %>/admin/customers">
                <input type="text" name="search" class="search-input"
                       placeholder="Tìm theo tên, tài khoản, email, số điện thoại..."
                       value="<%= keyword != null ? keyword : "" %>">
                <button type="submit" class="action-btn btn-history" style="padding: 0.55rem 1rem;">
                    <i class="fa-solid fa-magnifying-glass"></i> Tìm
                </button>
                <% if (keyword != null && !keyword.isEmpty()) { %>
                    <a href="<%= request.getContextPath() %>/admin/customers"
                       class="action-btn btn-block" style="padding: 0.55rem 1rem;">
                        <i class="fa-solid fa-xmark"></i> Xóa lọc
                    </a>
                <% } %>
            </form>
        </div>

        <!-- Customer Table -->
        <div class="card">
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>Khách hàng</th>
                            <th>Email</th>
                            <th>Điện thoại</th>
                            <th>Đơn hàng</th>
                            <th>Trạng thái</th>
                            <th>Ngày tham gia</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        if (customers != null && !customers.isEmpty()) {
                            for (Account c : customers) {
                                int status = c.getStatus();
                                int orderCount = (Integer) c.getExtra().getOrDefault("orderCount", 0);
                    %>
                        <tr>
                            <!-- Avatar + name -->
                            <td>
                                <div class="customer-info">
                                    <%
                                        String cAvatar = c.getAvatar();
                                        if (cAvatar == null || cAvatar.trim().isEmpty()) {
                                            String cFn = c.getFullname() != null ? c.getFullname() : c.getUsername();
                                            cAvatar = "https://ui-avatars.com/api/?name="
                                                    + java.net.URLEncoder.encode(cFn, "UTF-8")
                                                    + "&background=e8f5e9&color=4caf50&size=80&bold=true&rounded=true";
                                        }
                                    %>
                                    <img src="<%= cAvatar %>" alt="avatar" class="avatar-sm"
                                         onerror="this.style.display='none'">
                                    <div>
                                        <div class="customer-name">
                                            <%= c.getFullname() != null ? c.getFullname() : "<em>Chưa có tên</em>" %>
                                        </div>
                                        <div class="customer-username">@<%= c.getUsername() %></div>
                                    </div>
                                </div>
                            </td>
                            <!-- Email -->
                            <td><%= c.getEmail() != null ? c.getEmail() : "—" %></td>
                            <!-- Phone -->
                            <td><%= c.getPhone() != null ? c.getPhone() : "—" %></td>
                            <!-- Order count -->
                            <td>
                                <span class="order-count-badge">
                                    <i class="fa-solid fa-basket-shopping"></i> <%= orderCount %>
                                </span>
                            </td>
                            <!-- Status -->
                            <td>
                                <% if (status == 1) { %>
                                    <span class="badge badge-green">
                                        <i class="fa-solid fa-circle"></i> Hoạt động
                                    </span>
                                <% } else { %>
                                    <span class="badge badge-red">
                                        <i class="fa-solid fa-ban"></i> Đã khóa
                                    </span>
                                <% } %>
                            </td>
                            <!-- Joined date -->
                            <td>
                                <%= c.getCreatedAt() != null ? sdf.format(c.getCreatedAt()) : "—" %>
                            </td>
                            <!-- Actions -->
                            <td>
                                <a href="<%= request.getContextPath() %>/admin/customers?action=viewOrders&id=<%= c.getId() %>"
                                   class="action-btn btn-history" title="Xem lịch sử đơn hàng">
                                    <i class="fa-solid fa-clock-rotate-left"></i> Lịch sử
                                </a>

                                <% if (status == 1) { %>
                                    <form method="post" action="<%= request.getContextPath() %>/admin/customers" style="display:inline;"
                                          onsubmit="return confirm('Khóa tài khoản của <%= c.getUsername() %>?');">
                                        <input type="hidden" name="action" value="toggleStatus">
                                        <input type="hidden" name="id" value="<%= c.getId() %>">
                                        <input type="hidden" name="searchKeyword" value="<%= keyword != null ? keyword : "" %>">
                                        <button type="submit" class="action-btn btn-block" title="Khóa tài khoản">
                                            <i class="fa-solid fa-ban"></i> Khóa
                                        </button>
                                    </form>
                                <% } else { %>
                                    <form method="post" action="<%= request.getContextPath() %>/admin/customers" style="display:inline;"
                                          onsubmit="return confirm('Mở khóa tài khoản của <%= c.getUsername() %>?');">
                                        <input type="hidden" name="action" value="toggleStatus">
                                        <input type="hidden" name="id" value="<%= c.getId() %>">
                                        <input type="hidden" name="searchKeyword" value="<%= keyword != null ? keyword : "" %>">
                                        <button type="submit" class="action-btn btn-unblock" title="Mở khóa tài khoản">
                                            <i class="fa-solid fa-unlock"></i> Mở khóa
                                        </button>
                                    </form>
                                <% } %>
                            </td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr>
                            <td colspan="7">
                                <div class="empty-state">
                                    <i class="fa-solid fa-users-slash"></i>
                                    <p>Không tìm thấy khách hàng nào.</p>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

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

