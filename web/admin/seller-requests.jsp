<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.ShopRequest" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Account user = (Account) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<ShopRequest> requests = (List<ShopRequest>) request.getAttribute("requests");
    String currentFilter = (String) request.getAttribute("currentFilter");
    if (currentFilter == null) currentFilter = "pending";

    String message = (String) session.getAttribute("message");
    String error   = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Duyệt Đăng Ký Seller | SenaFruit</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --green:      #4caf50;
            --green-dark: #388e3c;
            --green-light:#e8f5e9;
            --bg:         #f0f4f1;
            --white:      #ffffff;
            --gray-50:    #f8fafb;
            --gray-100:   #eef1ee;
            --gray-200:   #dde5dd;
            --gray-400:   #9aaa9a;
            --gray-600:   #5a6a5a;
            --gray-800:   #2d3d2d;
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

        .nav-links { display: flex; gap: 0.25rem; }
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

        .nav-right { margin-left: auto; display: flex; align-items: center; gap: 0.75rem; }
        .nav-avatar {
            width: 38px; height: 38px; border-radius: 50%;
            object-fit: cover; border: 2px solid var(--green);
        }
        .nav-username { font-size: 0.875rem; font-weight: 600; color: var(--gray-800); }

        /* ======= LAYOUT ======= */
        .layout {
            max-width: 1200px;
            margin: 1.5rem auto;
            padding: 0 1.5rem;
        }

        /* ======= ALERTS ======= */
        .alert {
            display: flex; align-items: center; gap: 0.75rem;
            padding: 0.9rem 1.2rem; border-radius: var(--radius-sm);
            font-size: 0.875rem; font-weight: 500; margin-bottom: 1.25rem;
        }
        .alert-success { background: #dcfce7; border: 1px solid #bbf7d0; color: #15803d; }
        .alert-danger  { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }

        /* ======= PAGE HEADER ======= */
        .page-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 1.5rem; gap: 1rem; flex-wrap: wrap;
        }
        .page-title {
            font-size: 1.5rem; font-weight: 800; color: var(--gray-800);
            display: flex; align-items: center; gap: 0.5rem;
        }
        .page-title i { color: var(--green); }
        .stat-badge {
            background: var(--green-light); color: var(--green-dark);
            padding: 0.25rem 0.75rem; border-radius: 100px;
            font-size: 0.8rem; font-weight: 700;
        }

        /* ======= FILTER TABS ======= */
        .filter-tabs {
            display: flex; gap: 0.5rem; background: var(--white);
            border: 1px solid var(--gray-200); border-radius: var(--radius);
            padding: 0.35rem; margin-bottom: 1.25rem; width: fit-content;
            box-shadow: var(--shadow-sm);
        }
        .filter-tabs a {
            padding: 0.45rem 1rem; border-radius: 6px;
            font-size: 0.85rem; font-weight: 600;
            color: var(--gray-600); text-decoration: none;
            transition: all 0.15s;
        }
        .filter-tabs a:hover { background: var(--gray-100); color: var(--gray-800); }
        .filter-tabs a.active {
            background: var(--green); color: var(--white);
        }

        /* ======= CARD + TABLE ======= */
        .card {
            background: var(--white); border-radius: var(--radius);
            border: 1px solid var(--gray-200); box-shadow: var(--shadow-sm); overflow: hidden;
        }
        .table-wrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
        thead { background: var(--gray-50); }
        th {
            padding: 0.8rem 1rem; text-align: left; font-weight: 700;
            font-size: 0.78rem; color: var(--gray-600);
            text-transform: uppercase; letter-spacing: 0.04em;
            border-bottom: 2px solid var(--gray-200); white-space: nowrap;
        }
        td {
            padding: 0.85rem 1rem; border-bottom: 1px solid var(--gray-100);
            color: var(--gray-800); vertical-align: middle;
        }
        tbody tr:last-child td { border-bottom: none; }
        tbody tr:hover { background: var(--gray-50); }

        /* ======= STATUS BADGE ======= */
        .status-badge {
            display: inline-flex; align-items: center; gap: 0.35rem;
            padding: 0.22rem 0.7rem; border-radius: 100px;
            font-size: 0.75rem; font-weight: 700;
        }
        .status-pending  { background: #fef3c7; color: #92400e; }
        .status-approved { background: #dcfce7; color: #166534; }
        .status-rejected { background: #fee2e2; color: #991b1b; }

        /* ======= ACTION BUTTONS ======= */
        .action-btn {
            display: inline-flex; align-items: center; gap: 0.3rem;
            padding: 0.4rem 0.75rem; border-radius: var(--radius-sm);
            font-size: 0.8rem; font-weight: 600;
            border: none; cursor: pointer; text-decoration: none;
            transition: all 0.15s;
        }
        .btn-approve {
            background: #dcfce7; color: #15803d;
        }
        .btn-approve:hover { background: #bbf7d0; }
        .btn-reject {
            background: #fee2e2; color: #dc2626;
        }
        .btn-reject:hover { background: #fecaca; }
        .btn-view {
            background: var(--gray-100); color: var(--gray-600);
        }
        .btn-view:hover { background: var(--gray-200); }

        /* ======= EMPTY STATE ======= */
        .empty-state {
            text-align: center; padding: 4rem 2rem; color: var(--gray-400);
        }
        .empty-state i { font-size: 3rem; margin-bottom: 0.75rem; display: block; color: var(--gray-200); }
        .empty-state p { font-size: 0.95rem; }

        /* ======= RESPONSIVE ======= */
        @media (max-width: 768px) {
            .page-header { flex-direction: column; align-items: flex-start; }
        }
    </style>
</head>
<body>

    <jsp:include page="/admin/admin-topnav.jsp">
        <jsp:param name="activePage" value="seller-requests" />
    </jsp:include>

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
                <i class="fa-solid fa-store"></i>
                Duyệt Đăng Ký Seller
                <% long pendingCount = requests != null ? requests.stream().filter(ShopRequest::isPending).count() : 0; %>
                <span class="stat-badge">
                    <%= pendingCount %> chờ duyệt
                </span>
            </h1>
        </div>

        <!-- Filter Tabs -->
        <div class="filter-tabs">
            <a href="?filter=pending"
               class="<%= "pending".equals(currentFilter) ? "active" : "" %>">
                <i class="fa-solid fa-clock"></i> Chờ Duyệt
            </a>
            <a href="?filter=all"
               class="<%= "all".equals(currentFilter) ? "active" : "" %>">
                <i class="fa-solid fa-list"></i> Tất Cả
            </a>
        </div>

        <!-- Requests Table -->
        <div class="card">
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Người yêu cầu</th>
                            <th>Tên cửa hàng</th>
                            <th>Địa chỉ</th>
                            <th>Mô tả</th>
                            <th>Trạng thái</th>
                            <th>Ngày gửi</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        if (requests != null && !requests.isEmpty()) {
                            int idx = 1;
                            for (ShopRequest r : requests) {
                    %>
                        <tr>
                            <td><%= idx++ %></td>
                            <!-- Requester info -->
                            <td>
                                <div style="font-weight: 600;">
                                    <%= r.getAccountFullname() != null ? r.getAccountFullname() : "—" %>
                                </div>
                                <div style="font-size: 0.78rem; color: var(--gray-400);">
                                    <%= r.getAccountEmail() != null ? r.getAccountEmail() : "" %>
                                </div>
                                <div style="font-size: 0.78rem; color: var(--gray-400);">
                                    <%= r.getAccountPhone() != null ? r.getAccountPhone() : "" %>
                                </div>
                            </td>
                            <!-- Shop name -->
                            <td style="font-weight: 600; color: var(--green-dark);">
                                <%= r.getShopName() %>
                            </td>
                            <!-- Address -->
                            <td><%= r.getAddress() != null ? r.getAddress() : "—" %></td>
                            <!-- Description -->
                            <td>
                                <% if (r.getDescription() != null && !r.getDescription().isEmpty()) { %>
                                    <span title="<%= r.getDescription() %>">
                                        <%= r.getDescription().length() > 50
                                               ? r.getDescription().substring(0, 50) + "…"
                                               : r.getDescription() %>
                                    </span>
                                <% } else { %>
                                    <span style="color: var(--gray-400);">—</span>
                                <% } %>
                            </td>
                            <!-- Status -->
                            <td>
                                <% if (r.isPending()) { %>
                                    <span class="status-badge status-pending">
                                        <i class="fa-solid fa-clock"></i> <%= r.getStatusLabel() %>
                                    </span>
                                <% } else if (r.isApproved()) { %>
                                    <span class="status-badge status-approved">
                                        <i class="fa-solid fa-check-circle"></i> <%= r.getStatusLabel() %>
                                    </span>
                                <% } else { %>
                                    <span class="status-badge status-rejected">
                                        <i class="fa-solid fa-xmark-circle"></i> <%= r.getStatusLabel() %>
                                    </span>
                                <% } %>
                            </td>
                            <!-- Date -->
                            <td>
                                <%= r.getCreatedAt() != null ? sdf.format(r.getCreatedAt()) : "—" %>
                            </td>
                            <!-- Actions -->
                            <td>
                                <% if (r.isPending()) { %>
                                    <form method="post" action="<%= request.getContextPath() %>/admin/seller-requests"
                                          style="display:inline;"
                                          onsubmit="return confirm('Phê duyệt yêu cầu của [<%= r.getAccountFullname() %>]?');">
                                        <input type="hidden" name="action" value="approve">
                                        <input type="hidden" name="id" value="<%= r.getId() %>">
                                        <input type="hidden" name="filter" value="<%= currentFilter %>">
                                        <button type="submit" class="action-btn btn-approve" title="Phê duyệt">
                                            <i class="fa-solid fa-check"></i> Duyệt
                                        </button>
                                    </form>

                                    <form method="post" action="<%= request.getContextPath() %>/admin/seller-requests"
                                          style="display:inline;"
                                          onsubmit="return confirm('Từ chối yêu cầu của [<%= r.getAccountFullname() %>]?');">
                                        <input type="hidden" name="action" value="reject">
                                        <input type="hidden" name="id" value="<%= r.getId() %>">
                                        <input type="hidden" name="filter" value="<%= currentFilter %>">
                                        <button type="submit" class="action-btn btn-reject" title="Từ chối">
                                            <i class="fa-solid fa-xmark"></i> Từ chối
                                        </button>
                                    </form>
                                <% } else { %>
                                    <span style="color: var(--gray-400); font-size: 0.8rem;">Đã xử lý</span>
                                <% } %>
                            </td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr>
                            <td colspan="8">
                                <div class="empty-state">
                                    <i class="fa-solid fa-inbox"></i>
                                    <p>Không có yêu cầu nào<%= "pending".equals(currentFilter) ? " chờ duyệt" : "" %>.</p>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</body>
</html>
