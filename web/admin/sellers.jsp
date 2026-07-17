<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Shop" %>
<%@ page import="model.UserReport" %>
<%@ page import="model.SellerAction" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    Account user = (Account) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String message = (String) session.getAttribute("message");
    String error   = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");

    // ---- LIST VIEW DATA ----
    List<Map<String, Object>> dashboardList = (List<Map<String, Object>>) request.getAttribute("dashboardList");
    String keyword = (String) request.getAttribute("keyword");
    String filter  = (String) request.getAttribute("filter");
    if (filter == null) filter = "all";

    // ---- DETAIL VIEW DATA ----
    Shop detailShop = (Shop) request.getAttribute("detailShop");
    Integer productCount = (Integer) request.getAttribute("productCount");
    Integer orderCount  = (Integer) request.getAttribute("orderCount");
    Double totalRevenue = (Double) request.getAttribute("totalRevenue");
    List<UserReport> reports = (List<UserReport>) request.getAttribute("reports");
    List<SellerAction> actionHistory = (List<SellerAction>) request.getAttribute("actionHistory");
    Integer pendingReports = (Integer) request.getAttribute("pendingReports");
    Integer warnCount = (Integer) request.getAttribute("warnCount");
    Integer blockCount = (Integer) request.getAttribute("blockCount");
    Boolean isSuspended = (Boolean) request.getAttribute("isSuspended");
    SellerAction latestAction = (SellerAction) request.getAttribute("latestAction");
    if (productCount == null) productCount = 0;
    if (orderCount == null) orderCount = 0;
    if (totalRevenue == null) totalRevenue = 0.0;
    if (pendingReports == null) pendingReports = 0;
    if (warnCount == null) warnCount = 0;
    if (blockCount == null) blockCount = 0;
    if (isSuspended == null) isSuspended = false;

    boolean isDetail = detailShop != null;

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    SimpleDateFormat sdfDate = new SimpleDateFormat("dd/MM/yyyy");
    DecimalFormat df = new DecimalFormat("#,###");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isDetail ? "Chi Tiết Seller" : "Quản Lý Sellers" %> | Sena Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --green: #4caf50; --green-dark: #2e7d32; --green-light: #e8f5e9;
            --bg: #f0f4f1; --white: #ffffff;
            --gray-50: #f8fafb; --gray-100: #eef1ee; --gray-200: #dde5dd;
            --gray-400: #9aaa9a; --gray-600: #5a6a5a; --gray-800: #2d3d2d;
            --red: #dc2626; --red-light: #fee2e2; --red-dark: #991b1b;
            --orange: #d97706; --orange-light: #fffbeb;
            --purple: #7c3aed; --purple-light: #f5f3ff;
            --radius: 14px; --radius-sm: 8px;
            --shadow: 0 4px 12px rgba(0,0,0,.08); --shadow-sm: 0 1px 3px rgba(0,0,0,.06);
        }
        html, body { min-height: 100vh; font-family: 'Inter', sans-serif; color: var(--gray-800); background: var(--bg); }

        /* ======= TOPNAV ======= */
        .topnav {
            background: var(--white); border-bottom: 1px solid var(--gray-200);
            height: 60px; display: flex; align-items: center;
            padding: 0 2rem; gap: 1.5rem; position: sticky; top: 0; z-index: 100; box-shadow: var(--shadow-sm);
        }
        .nav-logo { display:flex; align-items:center; gap:.5rem; font-size:1.3rem; font-weight:800;
            color:var(--green-dark); text-decoration:none; white-space:nowrap; }
        .nav-logo i { color:var(--green); }
        .nav-links { display:flex; gap:.25rem; }
        .nav-links a { padding:.4rem .85rem; border-radius:6px; font-size:.875rem; font-weight:500;
            color:var(--gray-600); text-decoration:none; transition:all .15s; }
        .nav-links a:hover { background:var(--green-light); color:var(--green-dark); }
        .nav-links a.active { background:var(--green-light); color:var(--green-dark); font-weight:600; }
        .nav-right { margin-left:auto; display:flex; align-items:center; gap:.75rem; }
        .nav-avatar { width:38px; height:38px; border-radius:50%; object-fit:cover; border:2px solid var(--green); }
        .nav-username { font-size:.875rem; font-weight:600; }

        /* ======= LAYOUT ======= */
        .layout { max-width: 1320px; margin: 1.5rem auto; padding: 0 1.5rem; }

        /* ======= ALERTS ======= */
        .alert { display:flex; align-items:center; gap:.75rem; padding:.9rem 1.2rem;
            border-radius:var(--radius-sm); font-size:.875rem; font-weight:500; margin-bottom:1.25rem; }
        .alert-success { background:#dcfce7; border:1px solid #bbf7d0; color:#15803d; }
        .alert-danger  { background:#fee2e2; border:1px solid #fecaca; color:#991b1b; }
        .alert-warning { background:#fffbeb; border:1px solid #fde68a; color:#92400e; }

        /* ======= PAGE HEADER ======= */
        .page-header { display:flex; justify-content:space-between; align-items:center;
            margin-bottom:1.5rem; gap:1rem; flex-wrap:wrap; }
        .page-title { font-size:1.5rem; font-weight:800; display:flex; align-items:center; gap:.5rem; }
        .page-title i { color:var(--green); }

        /* ======= STAT CARDS ======= */
        .stat-row { display:grid; grid-template-columns:repeat(auto-fit, minmax(180px,1fr)); gap:.85rem; margin-bottom:1.5rem; }
        .stat-card { background:var(--white); border-radius:var(--radius); border:1px solid var(--gray-200);
            padding:1rem 1.15rem; box-shadow:var(--shadow-sm); display:flex; align-items:center; gap:.85rem; }
        .stat-icon { width:44px; height:44px; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:1.1rem; flex-shrink:0; }
        .stat-icon.total  { background:var(--green-light); color:var(--green); }
        .stat-icon.active { background:#dcfce7; color:#166534; }
        .stat-icon.blocked { background:var(--red-light); color:var(--red); }
        .stat-icon.report { background:var(--orange-light); color:var(--orange); }
        .stat-icon.warn   { background:var(--purple-light); color:var(--purple); }
        .stat-value { font-size:1.5rem; font-weight:800; line-height:1; }
        .stat-label { font-size:.75rem; color:var(--gray-400); font-weight:500; margin-top:.2rem; }

        /* ======= TOOLBAR ======= */
        .toolbar { background:var(--white); border-radius:var(--radius); border:1px solid var(--gray-200);
            box-shadow:var(--shadow-sm); padding:.85rem 1.25rem; display:flex; gap:.75rem;
            align-items:center; margin-bottom:1.25rem; flex-wrap:wrap; }
        .search-form { display:flex; gap:.5rem; flex:1; min-width:260px; }
        .search-input { flex:1; padding:.55rem .9rem; border:1.5px solid var(--gray-200); border-radius:var(--radius-sm);
            font-size:.875rem; font-family:inherit; outline:none; transition:border-color .15s; }
        .search-input:focus { border-color:var(--green); }

        /* Filter tabs */
        .filter-tabs { display:flex; gap:.25rem; background:var(--gray-100); border-radius:var(--radius-sm); padding:.2rem; }
        .filter-tab { padding:.35rem .9rem; border-radius:6px; font-size:.8rem; font-weight:600;
            color:var(--gray-600); text-decoration:none; cursor:pointer; border:none; background:transparent; transition:all .15s; }
        .filter-tab:hover { background:var(--white); color:var(--gray-800); }
        .filter-tab.active { background:var(--green); color:white; box-shadow:0 2px 6px rgba(76,175,80,.3); }

        /* ======= BACK BUTTON ======= */
        .back-btn { display:inline-flex; align-items:center; gap:.4rem; padding:.45rem .9rem;
            background:var(--white); border:1.5px solid var(--gray-200); border-radius:var(--radius-sm);
            font-size:.85rem; font-weight:600; color:var(--gray-600); text-decoration:none;
            transition:all .15s; margin-bottom:1rem; }
        .back-btn:hover { background:var(--gray-50); color:var(--green-dark); border-color:var(--green); }

        /* ======= SELLER CARDS ======= */
        .seller-grid { display:grid; grid-template-columns:repeat(auto-fill, minmax(320px,1fr)); gap:1rem; }
        .seller-card { background:var(--white); border-radius:var(--radius); border:1px solid var(--gray-200);
            box-shadow:var(--shadow-sm); padding:1.25rem; transition:box-shadow .2s; }
        .seller-card:hover { box-shadow:var(--shadow); }
        .seller-card-header { display:flex; align-items:center; gap:.85rem; margin-bottom:1rem; }
        .seller-avatar { width:50px; height:50px; border-radius:10px; background:var(--green-light);
            border:2px solid var(--green); display:flex; align-items:center; justify-content:center;
            font-size:1.4rem; color:var(--green); flex-shrink:0; overflow:hidden; }
        .seller-avatar img { width:100%; height:100%; object-fit:cover; }
        .seller-info { flex:1; min-width:0; }
        .seller-name { font-weight:700; color:var(--green-dark); font-size:.95rem; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .seller-owner { font-size:.78rem; color:var(--gray-400); margin-top:.1rem; }

        .seller-status { display:inline-flex; align-items:center; gap:.3rem; padding:.18rem .65rem; border-radius:100px; font-size:.72rem; font-weight:700; }
        .status-active   { background:#dcfce7; color:#166534; }
        .status-blocked  { background:var(--red-light); color:var(--red); }
        .status-suspended { background:var(--orange-light); color:#92400e; }

        .seller-stats { display:grid; grid-template-columns:repeat(2,1fr); gap:.5rem; margin:.85rem 0; }
        .mini-stat { background:var(--gray-50); border-radius:6px; padding:.5rem .65rem; }
        .mini-stat-value { font-weight:700; font-size:1rem; color:var(--gray-800); }
        .mini-stat-label { font-size:.7rem; color:var(--gray-400); margin-top:.1rem; }
        .mini-stat.red .mini-stat-value { color:var(--red); }
        .mini-stat.orange .mini-stat-value { color:var(--orange); }
        .mini-stat.purple .mini-stat-value { color:var(--purple); }

        .seller-actions { display:flex; gap:.4rem; margin-top:.85rem; flex-wrap:wrap; }
        .action-btn { display:inline-flex; align-items:center; gap:.3rem; padding:.4rem .75rem;
            border-radius:var(--radius-sm); font-size:.78rem; font-weight:600; border:none;
            cursor:pointer; text-decoration:none; transition:all .15s; white-space:nowrap; }
        .btn-detail   { background:var(--green-light); color:var(--green-dark); }
        .btn-detail:hover { background:#c8e6c9; }
        .btn-warn     { background:#fff3e0; color:#e65100; }
        .btn-warn:hover { background:#ffe0b2; }
        .btn-suspend  { background:var(--orange-light); color:#92400e; }
        .btn-suspend:hover { background:#fde68a; }
        .btn-block    { background:var(--red-light); color:var(--red); }
        .btn-block:hover { background:#fecaca; }
        .btn-unblock  { background:#dcfce7; color:#15803d; }
        .btn-unblock:hover { background:#bbf7d0; }
        .btn-lift     { background:#e0f2fe; color:#0369a1; }
        .btn-lift:hover { background:#bae6fd; }

        /* ======= BADGE ======= */
        .badge-red { background:var(--red-light); color:var(--red); padding:.1rem .45rem; border-radius:100px; font-size:.7rem; font-weight:700; }

        /* ======= ACTION MODAL ======= */
        .modal-overlay { display:none; position:fixed; inset:0; background:rgba(0,0,0,.5); z-index:200;
            align-items:center; justify-content:center; padding:1rem; }
        .modal-overlay.show { display:flex; }
        .modal { background:var(--white); border-radius:var(--radius); max-width:500px; width:100%; overflow:hidden;
            animation:slideIn .2s ease; }
        @keyframes slideIn { from { transform:translateY(-20px); opacity:0; } to { transform:translateY(0); opacity:1; } }
        .modal-header { background:var(--green-light); padding:1rem 1.25rem; border-bottom:1px solid var(--gray-200);
            display:flex; align-items:center; gap:.5rem; }
        .modal-header h3 { font-size:1rem; font-weight:700; color:var(--green-dark); }
        .modal-header i { color:var(--green); }
        .modal-body { padding:1.25rem; }
        .modal-body label { display:block; font-size:.85rem; font-weight:600; margin-bottom:.3rem; }
        .modal-body input, .modal-body textarea, .modal-body select
            { width:100%; padding:.55rem .8rem; border:1.5px solid var(--gray-200); border-radius:var(--radius-sm);
              font-size:.875rem; font-family:inherit; outline:none; margin-bottom:.85rem; }
        .modal-body textarea { resize:vertical; min-height:80px; }
        .modal-body input:focus, .modal-body textarea:focus, .modal-body select:focus { border-color:var(--green); }
        .suspend-days-row { display:flex; align-items:center; gap:.5rem; margin-bottom:.85rem; }
        .suspend-days-row label { margin-bottom:0; white-space:nowrap; }
        .suspend-days-row input { margin-bottom:0; width:80px; flex-shrink:0; }
        .modal-footer { padding:.85rem 1.25rem; border-top:1px solid var(--gray-200);
            display:flex; gap:.5rem; justify-content:flex-end; }
        .modal-cancel { padding:.5rem 1rem; border:1.5px solid var(--gray-200); border-radius:var(--radius-sm);
            background:transparent; font-size:.85rem; font-weight:600; cursor:pointer; color:var(--gray-600); }
        .modal-cancel:hover { background:var(--gray-100); }
        .modal-confirm { padding:.5rem 1.25rem; border:none; border-radius:var(--radius-sm);
            font-size:.85rem; font-weight:600; cursor:pointer; color:white; }
        .modal-confirm.red   { background:var(--red); }
        .modal-confirm.red:hover { background:var(--red-dark); }
        .modal-confirm.orange { background:var(--orange); }
        .modal-confirm.orange:hover { background:#b45309; }
        .modal-confirm.purple { background:var(--purple); }
        .modal-confirm.purple:hover { background:#6d28d9; }
        .modal-confirm.green  { background:var(--green); }
        .modal-confirm.green:hover { background:var(--green-dark); }

        /* ======= DETAIL PAGE ======= */
        .detail-grid { display:grid; grid-template-columns:1fr 1fr; gap:1.25rem; }
        @media(max-width:900px) { .detail-grid { grid-template-columns:1fr; } }

        .detail-card { background:var(--white); border-radius:var(--radius); border:1px solid var(--gray-200);
            box-shadow:var(--shadow-sm); overflow:hidden; }
        .detail-card-header { background:var(--green-light); padding:.85rem 1.25rem;
            border-bottom:1px solid var(--gray-200); display:flex; align-items:center; gap:.5rem; }
        .detail-card-header h3 { font-size:.95rem; font-weight:700; color:var(--green-dark); }
        .detail-card-header i { color:var(--green); }
        .detail-card-body { padding:1.25rem; }

        /* Profile */
        .profile-header { display:flex; align-items:center; gap:1rem; margin-bottom:1.25rem; }
        .profile-avatar { width:64px; height:64px; border-radius:12px; background:var(--green-light);
            border:3px solid var(--green); display:flex; align-items:center; justify-content:center;
            font-size:1.8rem; color:var(--green); flex-shrink:0; overflow:hidden; }
        .profile-avatar img { width:100%; height:100%; object-fit:cover; }
        .profile-name { font-size:1.15rem; font-weight:800; color:var(--gray-800); }
        .profile-sub { font-size:.8rem; color:var(--gray-400); margin-top:.2rem; }
        .profile-row { display:flex; align-items:center; gap:.5rem; padding:.5rem 0;
            border-bottom:1px solid var(--gray-100); font-size:.85rem; }
        .profile-row:last-child { border-bottom:none; }
        .profile-row i { width:18px; color:var(--gray-400); text-align:center; flex-shrink:0; }
        .profile-row span { color:var(--gray-600); }

        /* Detail stat */
        .dstat-row { display:grid; grid-template-columns:repeat(3,1fr); gap:.75rem; margin-top:.85rem; }
        .dstat { text-align:center; background:var(--gray-50); border-radius:8px; padding:.65rem; }
        .dstat-val { font-size:1.3rem; font-weight:800; color:var(--gray-800); }
        .dstat-val.red { color:var(--red); }
        .dstat-lbl { font-size:.72rem; color:var(--gray-400); margin-top:.1rem; }

        /* Reports table */
        .table-wrap { overflow-x:auto; }
        table { width:100%; border-collapse:collapse; font-size:.875rem; }
        thead { background:var(--gray-50); }
        th { padding:.7rem .9rem; text-align:left; font-weight:700; font-size:.75rem;
            color:var(--gray-600); text-transform:uppercase; letter-spacing:.04em;
            border-bottom:2px solid var(--gray-200); white-space:nowrap; }
        td { padding:.75rem .9rem; border-bottom:1px solid var(--gray-100); vertical-align:middle; }
        tbody tr:last-child td { border-bottom:none; }
        tbody tr:hover { background:var(--gray-50); }

        .badge { display:inline-flex; align-items:center; gap:.3rem; padding:.18rem .6rem;
            border-radius:100px; font-size:.72rem; font-weight:700; }
        .badge-pending   { background:var(--orange-light); color:#92400e; }
        .badge-reviewed  { background:#e0f2fe; color:#0369a1; }
        .badge-resolved  { background:#dcfce7; color:#166534; }
        .badge-dismissed { background:var(--gray-100); color:var(--gray-600); }
        .badge-low       { background:#f0fdf4; color:#166534; }
        .badge-medium    { background:var(--orange-light); color:#92400e; }
        .badge-high      { background:#fef2f2; color:#991b1b; }
        .badge-critical  { background:var(--purple-light); color:#5b21b6; }

        /* Action history */
        .timeline { }
        .timeline-item { display:flex; gap:.85rem; padding:.85rem 0; border-bottom:1px solid var(--gray-100); }
        .timeline-item:last-child { border-bottom:none; }
        .timeline-dot { width:36px; height:36px; border-radius:50%; display:flex; align-items:center; justify-content:center;
            flex-shrink:0; font-size:.9rem; }
        .dot-warn       { background:#fff3e0; color:#e65100; }
        .dot-suspend    { background:var(--orange-light); color:#92400e; }
        .dot-suspend-end { background:#e0f2fe; color:#0369a1; }
        .dot-block      { background:var(--red-light); color:var(--red); }
        .dot-unblock    { background:#dcfce7; color:#15803d; }
        .timeline-content { flex:1; }
        .timeline-title { font-weight:700; font-size:.875rem; color:var(--gray-800); }
        .timeline-reason { font-size:.8rem; color:var(--gray-600); margin-top:.15rem; line-height:1.4; }
        .timeline-meta { font-size:.72rem; color:var(--gray-400); margin-top:.2rem; display:flex; gap:.5rem; flex-wrap:wrap; }
        .timeline-suspend { display:inline-block; background:var(--orange-light); color:#92400e;
            padding:.1rem .45rem; border-radius:100px; font-size:.7rem; font-weight:700; margin-top:.2rem; }

        /* Empty state */
        .empty-state { text-align:center; padding:3rem 2rem; color:var(--gray-400); }
        .empty-state i { font-size:2.5rem; margin-bottom:.75rem; display:block; color:var(--gray-200); }

        /* Responsive */
        @media(max-width:768px) {
            .toolbar { flex-direction:column; align-items:stretch; }
            .filter-tabs { flex-wrap:wrap; }
            .seller-grid { grid-template-columns:1fr; }
            .stat-row { grid-template-columns:repeat(2,1fr); }
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
        <a href="<%= request.getContextPath() %>/admin/orders">
            <i class="fa-solid fa-chart-line"></i> Monitor Đơn Hàng
        </a>
        <a href="<%= request.getContextPath() %>/admin/customers">
            <i class="fa-solid fa-users"></i> Khách Hàng
        </a>
        <a href="<%= request.getContextPath() %>/admin/seller-requests">
            <i class="fa-solid fa-store"></i> Duyệt Seller
        </a>
        <a href="<%= request.getContextPath() %>/admin/sellers" class="active">
            <i class="fa-solid fa-store"></i> Quản Lý Sellers
        </a>
    </div>
    <div class="nav-right">
        <span class="nav-username">Admin: <%= user.getFullname()!=null?user.getFullname():user.getUsername() %></span>
        <a href="<%= request.getContextPath() %>/logout" class="btn btn-sm" style="background: #fee2e2; color: #991b1b; text-decoration: none;">Đăng Xuất</a>
    </div>
</nav>

<div class="layout">

    <% if (message != null) { %>
        <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> <%= message %></div>
    <% } %>
    <% if (error != null) { %>
        <div class="alert alert-danger"><i class="fa-solid fa-circle-exclamation"></i> <%= error %></div>
    <% } %>

    <!-- ==================== LIST VIEW ==================== -->
    <% if (!isDetail) { %>

        <div class="page-header">
            <h1 class="page-title">
                <i class="fa-solid fa-store"></i> Quản Lý Sellers
            </h1>
        </div>

        <!-- Summary stats -->
        <div class="stat-row">
            <% long totalSellers = dashboardList != null ? dashboardList.size() : 0;
               long activeCount = dashboardList != null ? dashboardList.stream().filter(m -> {
                   Shop s = (Shop)m.get("shop"); return s.isActive(); }).count() : 0;
               long blockedCount = dashboardList != null ? dashboardList.stream().filter(m -> {
                   Shop s = (Shop)m.get("shop"); return s.isBlocked(); }).count() : 0;
               long pendingReportCount = dashboardList != null ? dashboardList.stream().filter(m -> {
                   return ((Integer)m.getOrDefault("pendingReports",0)) > 0; }).count() : 0;
            %>
            <div class="stat-card">
                <div class="stat-icon total"><i class="fa-solid fa-store"></i></div>
                <div><div class="stat-value"><%= totalSellers %></div><div class="stat-label">Tổng Sellers</div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon active"><i class="fa-solid fa-circle-check"></i></div>
                <div><div class="stat-value"><%= activeCount %></div><div class="stat-label">Đang hoạt động</div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon blocked"><i class="fa-solid fa-ban"></i></div>
                <div><div class="stat-value"><%= blockedCount %></div><div class="stat-label">Bị khóa</div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon report"><i class="fa-solid fa-flag"></i></div>
                <div><div class="stat-value"><%= pendingReportCount %></div><div class="stat-label">Có khiếu nại</div></div>
            </div>
        </div>

        <!-- Toolbar -->
        <div class="toolbar">
            <form class="search-form" method="get" action="<%= request.getContextPath() %>/admin/sellers">
                <input type="text" name="search" class="search-input"
                       placeholder="Tìm theo tên shop, chủ shop, email, phone..."
                       value="<%= keyword != null ? keyword : "" %>">
                <button type="submit" style="padding:.55rem 1rem; background:var(--green-light); color:var(--green-dark);
                        border:none; border-radius:var(--radius-sm); font-size:.875rem; font-weight:600; cursor:pointer;
                        display:flex; align-items:center; gap:.3rem;">
                    <i class="fa-solid fa-magnifying-glass"></i> Tìm
                </button>
                <% if (keyword != null && !keyword.isEmpty()) { %>
                    <a href="<%= request.getContextPath() %>/admin/sellers" style="padding:.55rem .9rem; background:var(--gray-100);
                       color:var(--gray-600); border-radius:var(--radius-sm); font-size:.875rem; font-weight:600;
                       display:flex; align-items:center; gap:.3rem; text-decoration:none;">
                        <i class="fa-solid fa-xmark"></i> Xóa lọc
                    </a>
                <% } %>
            </form>
            <div class="filter-tabs">
                <a href="?filter=all"      class="filter-tab <%= "all".equals(filter)?"active":"" %>">Tất cả</a>
                <a href="?filter=active"  class="filter-tab <%= "active".equals(filter)?"active":"" %>">Hoạt động</a>
                <a href="?filter=blocked"  class="filter-tab <%= "blocked".equals(filter)?"active":"" %>">Bị khóa</a>
                <a href="?filter=suspended" class="filter-tab <%= "suspended".equals(filter)?"active":"" %>">Tạm khóa</a>
            </div>
        </div>

        <!-- Seller cards -->
        <% if (dashboardList != null && !dashboardList.isEmpty()) { %>
            <div class="seller-grid">
            <% for (Map<String, Object> item : dashboardList) {
                   Shop shop = (Shop) item.get("shop");
                   int pc = (Integer) item.getOrDefault("productCount", 0);
                   int oc = (Integer) item.getOrDefault("orderCount", 0);
                   int pr = (Integer) item.getOrDefault("pendingReports", 0);
                   int wc = (Integer) item.getOrDefault("warnCount", 0);
                   int bc = (Integer) item.getOrDefault("blockCount", 0);
                   boolean sus = (Boolean) item.getOrDefault("isSuspended", false);
                   boolean shopActive = shop.isActive();
                   boolean shopBlocked = shop.isBlocked();
            %>
                <div class="seller-card">
                    <!-- Header -->
                    <div class="seller-card-header">
                        <div class="seller-avatar">
                            <% if (shop.getLogo() != null && !shop.getLogo().isEmpty()) { %>
                                <img src="<%= shop.getLogo() %>" alt="logo">
                            <% } else { %>
                                <i class="fa-solid fa-store"></i>
                            <% } %>
                        </div>
                        <div class="seller-info">
                            <div class="seller-name"><%= shop.getName() %></div>
                            <div class="seller-owner"><%= shop.getOwnerFullname()!=null?shop.getOwnerFullname():"—" %></div>
                        </div>
                        <% if (shopBlocked) { %>
                            <span class="seller-status status-blocked"><i class="fa-solid fa-ban"></i> Bị khóa</span>
                        <% } else if (sus) { %>
                            <span class="seller-status status-suspended"><i class="fa-solid fa-clock"></i> Tạm khóa</span>
                        <% } else { %>
                            <span class="seller-status status-active"><i class="fa-solid fa-circle"></i> Hoạt động</span>
                        <% } %>
                    </div>

                    <!-- Stats -->
                    <div class="seller-stats">
                        <div class="mini-stat">
                            <div class="mini-stat-value"><%= pc %></div>
                            <div class="mini-stat-label">Sản phẩm</div>
                        </div>
                        <div class="mini-stat">
                            <div class="mini-stat-value"><%= oc %></div>
                            <div class="mini-stat-label">Đơn hàng</div>
                        </div>
                        <div class="mini-stat <%= pr>0?"red":"" %>">
                            <div class="mini-stat-value"><%= pr %></div>
                            <div class="mini-stat-label">Khiếu nại</div>
                        </div>
                        <div class="mini-stat <%= wc>0?"purple":"" %>">
                            <div class="mini-stat-value"><%= wc %></div>
                            <div class="mini-stat-label">Cảnh cáo</div>
                        </div>
                    </div>

                    <!-- Actions -->
                    <div class="seller-actions">
                        <a href="?detail=<%= shop.getId() %>" class="action-btn btn-detail">
                            <i class="fa-solid fa-eye"></i> Chi tiết
                        </a>
                        <button class="action-btn btn-warn" onclick="openModal('warn','<%= shop.getId() %>','<%= shop.getName().replace("'","\\'") %>')">
                            <i class="fa-solid fa-bullhorn"></i> Cảnh cáo
                        </button>
                        <% if (sus) { %>
                            <button class="action-btn btn-lift" onclick="openModal('lift_suspend','<%= shop.getId() %>','<%= shop.getName().replace("'","\\'") %>')">
                                <i class="fa-solid fa-unlock"></i> Mở khóa
                            </button>
                        <% } else if (!shopBlocked) { %>
                            <button class="action-btn btn-suspend" onclick="openModal('temp_suspend','<%= shop.getId() %>','<%= shop.getName().replace("'","\\'") %>')">
                                <i class="fa-solid fa-clock"></i> Tạm khóa
                            </button>
                        <% } %>
                        <% if (shopBlocked || bc > 0) { %>
                            <button class="action-btn btn-unblock" onclick="openModal('unblock','<%= shop.getId() %>','<%= shop.getName().replace("'","\\'") %>')">
                                <i class="fa-solid fa-lock-open"></i> Mở khóa
                            </button>
                        <% } else { %>
                            <button class="action-btn btn-block" onclick="openModal('block','<%= shop.getId() %>','<%= shop.getName().replace("'","\\'") %>')">
                                <i class="fa-solid fa-ban"></i> Khóa
                            </button>
                        <% } %>
                    </div>
                </div>
            <% } %>
            </div>
        <% } else { %>
            <div class="empty-state" style="background:var(--white);border-radius:var(--radius);border:1px solid var(--gray-200);padding:4rem 2rem;">
                <i class="fa-solid fa-store-slash"></i>
                <p>Không tìm thấy seller nào.</p>
            </div>
        <% } %>

    <% } %>

    <!-- ==================== DETAIL VIEW ==================== -->
    <% if (isDetail) { %>

        <a href="<%= request.getContextPath() %>/admin/sellers" class="back-btn">
            <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
        </a>

        <!-- Page header -->
        <div class="page-header">
            <h1 class="page-title">
                <i class="fa-solid fa-user-shield"></i> Chi Tiết Seller
                <span style="font-size:1rem;font-weight:500;color:var(--gray-400);">— <%= detailShop.getName() %></span>
            </h1>
        </div>

        <!-- Summary stats -->
        <div class="stat-row">
            <div class="stat-card">
                <div class="stat-icon total"><i class="fa-solid fa-box"></i></div>
                <div><div class="stat-value"><%= productCount %></div><div class="stat-label">Sản phẩm</div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon active"><i class="fa-solid fa-receipt"></i></div>
                <div><div class="stat-value"><%= orderCount %></div><div class="stat-label">Đơn hàng</div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon report"><i class="fa-solid fa-money-bill-wave"></i></div>
                <div><div class="stat-value"><%= df.format(totalRevenue) %></div><div class="stat-label">Doanh thu (VNĐ)</div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon warn"><i class="fa-solid fa-flag"></i></div>
                <div><div class="stat-value"><%= pendingReports %></div><div class="stat-label">Khiếu nại chờ xử lý</div></div>
            </div>
        </div>

        <div class="detail-grid">
            <!-- LEFT COLUMN -->
            <!-- Profile -->
            <div class="detail-card">
                <div class="detail-card-header">
                    <i class="fa-solid fa-user"></i>
                    <h3>Hồ Sơ Shop</h3>
                </div>
                <div class="detail-card-body">
                    <div class="profile-header">
                        <div class="profile-avatar">
                            <% if (detailShop.getLogo()!=null&&!detailShop.getLogo().isEmpty()) { %>
                                <img src="<%= detailShop.getLogo() %>" alt="logo">
                            <% } else { %>
                                <i class="fa-solid fa-store"></i>
                            <% } %>
                        </div>
                        <div>
                            <div class="profile-name"><%= detailShop.getName() %></div>
                            <div class="profile-sub">#<%= detailShop.getId() %> &bull; <%= detailShop.getOwnerFullname()!=null?detailShop.getOwnerFullname():"—" %></div>
                            <% if (detailShop.isBlocked()) { %>
                                <span class="seller-status status-blocked" style="margin-top:.3rem;display:inline-flex;">
                                    <i class="fa-solid fa-ban"></i> Bị khóa
                                </span>
                            <% } else if (isSuspended) { %>
                                <span class="seller-status status-suspended" style="margin-top:.3rem;display:inline-flex;">
                                    <i class="fa-solid fa-clock"></i> Tạm khóa
                                </span>
                            <% } else { %>
                                <span class="seller-status status-active" style="margin-top:.3rem;display:inline-flex;">
                                    <i class="fa-solid fa-circle"></i> Hoạt động
                                </span>
                            <% } %>
                        </div>
                    </div>
                    <div class="profile-row">
                        <i class="fa-solid fa-user"></i><span><%= detailShop.getOwnerFullname()!=null?detailShop.getOwnerFullname():"—" %></span>
                    </div>
                    <div class="profile-row">
                        <i class="fa-solid fa-envelope"></i><span><%= detailShop.getOwnerEmail()!=null?detailShop.getOwnerEmail():"—" %></span>
                    </div>
                    <div class="profile-row">
                        <i class="fa-solid fa-phone"></i><span><%= detailShop.getOwnerPhone()!=null?detailShop.getOwnerPhone():"—" %></span>
                    </div>
                    <div class="profile-row">
                        <i class="fa-solid fa-location-dot"></i>
                        <span><%= detailShop.getAddress()!=null&&!detailShop.getAddress().isEmpty()?detailShop.getAddress():"Chưa cập nhật" %></span>
                    </div>
                    <div class="profile-row">
                        <i class="fa-solid fa-calendar"></i>
                        <span>Ngày tạo: <%= detailShop.getCreatedAt()!=null?sdf.format(detailShop.getCreatedAt()):"—" %></span>
                    </div>
                    <div class="dstat-row">
                        <div class="dstat">
                            <div class="dstat-val <%= warnCount>0?"red":"" %>"><%= warnCount %></div>
                            <div class="dstat-lbl">Cảnh cáo</div>
                        </div>
                        <div class="dstat">
                            <div class="dstat-val <%= blockCount>0?"red":"" %>"><%= blockCount %></div>
                            <div class="dstat-lbl">Lần khóa</div>
                        </div>
                        <div class="dstat">
                            <div class="dstat-val <%= pendingReports>0?"red":"" %>"><%= pendingReports %></div>
                            <div class="dstat-lbl">Khiếu nại</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="detail-card">
                <div class="detail-card-header">
                    <i class="fa-solid fa-gavel"></i>
                    <h3>Hành Động Nhanh</h3>
                </div>
                <div class="detail-card-body">
                    <div style="display:flex;flex-direction:column;gap:.6rem;">
                        <button class="action-btn btn-warn" style="width:100%;justify-content:center;padding:.65rem;"
                                onclick="openModal('warn','<%= detailShop.getId() %>','<%= detailShop.getName().replace("'","\\'") %>')">
                            <i class="fa-solid fa-bullhorn"></i> Gửi Cảnh Cáo
                            <span style="font-size:.72rem;opacity:.7;margin-left:.3rem;">— không khóa tài khoản</span>
                        </button>
                        <% if (isSuspended) { %>
                            <button class="action-btn btn-lift" style="width:100%;justify-content:center;padding:.65rem;"
                                    onclick="openModal('lift_suspend','<%= detailShop.getId() %>','<%= detailShop.getName().replace("'","\\'") %>')">
                                <i class="fa-solid fa-unlock"></i> Kết Thúc Tạm Khóa
                            </button>
                        <% } else if (!detailShop.isBlocked()) { %>
                            <button class="action-btn btn-suspend" style="width:100%;justify-content:center;padding:.65rem;"
                                    onclick="openModal('temp_suspend','<%= detailShop.getId() %>','<%= detailShop.getName().replace("'","\\'") %>')">
                                <i class="fa-solid fa-clock"></i> Tạm Khóa Shop
                            </button>
                        <% } %>
                        <% if (detailShop.isBlocked() || blockCount > 0) { %>
                            <button class="action-btn btn-unblock" style="width:100%;justify-content:center;padding:.65rem;"
                                    onclick="openModal('unblock','<%= detailShop.getId() %>','<%= detailShop.getName().replace("'","\\'") %>')">
                                <i class="fa-solid fa-lock-open"></i> Mở Khóa Shop
                            </button>
                        <% } else { %>
                            <button class="action-btn btn-block" style="width:100%;justify-content:center;padding:.65rem;"
                                    onclick="openModal('block','<%= detailShop.getId() %>','<%= detailShop.getName().replace("'","\\'") %>')">
                                <i class="fa-solid fa-ban"></i> Khóa Vĩnh Viễn
                            </button>
                        <% } %>
                    </div>
                    <% if (latestAction != null) { %>
                        <div style="margin-top:1rem;padding:.75rem;background:var(--gray-50);border-radius:8px;border-left:3px solid var(--green);">
                            <div style="font-size:.75rem;font-weight:700;color:var(--gray-600);margin-bottom:.2rem;">HÀNH ĐỘNG GẦN NHẤT</div>
                            <div style="font-size:.82rem;font-weight:600;color:var(--gray-800);"><%= latestAction.getActionTypeLabel() %></div>
                            <div style="font-size:.78rem;color:var(--gray-600);margin-top:.2rem;"><%= latestAction.getReason() %></div>
                            <div style="font-size:.72rem;color:var(--gray-400);margin-top:.3rem;">
                                <%= latestAction.getCreatedAt()!=null?sdf.format(latestAction.getCreatedAt()):"" %> &bull; by <%= latestAction.getAdminFullname()!=null?latestAction.getAdminFullname():"Admin" %>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>

            <!-- Reports -->
            <div class="detail-card" style="grid-column:1/-1;">
                <div class="detail-card-header">
                    <i class="fa-solid fa-flag"></i>
                    <h3>Lịch Sử Khiếu Nại (<%= reports!=null?reports.size():0 %>)</h3>
                </div>
                <div class="detail-card-body" style="padding:0;">
                    <% if (reports!=null && !reports.isEmpty()) { %>
                        <div class="table-wrap">
                            <table>
                                <thead>
                                    <tr>
                                        <th>ID</th><th>Người gửi</th><th>Loại</th><th>Mô tả</th>
                                        <th>Đơn hàng</th><th>Ưu tiên</th><th>Trạng thái</th><th>Ngày gửi</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <% for (UserReport r : reports) { %>
                                    <tr>
                                        <td style="font-weight:700;">#<%= r.getId() %></td>
                                        <td>
                                            <div style="font-weight:600;"><%= r.getReporterFullname()!=null?r.getReporterFullname():"—" %></div>
                                            <div style="font-size:.72rem;color:var(--gray-400);"><%= r.getReporterEmail()!=null?r.getReporterEmail():"—" %></div>
                                        </td>
                                        <td><span style="font-weight:600;"><%= r.getReportTypeLabel() %></span></td>
                                        <td style="max-width:200px;">
                                            <div style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:200px;" title="<%= r.getDescription() %>">
                                                <%= r.getDescription() %>
                                            </div>
                                        </td>
                                        <td style="font-weight:700;">
                                            <% if (r.getOrderId()!=null) { %>
                                                <a href="#" style="color:var(--green);font-weight:700;">#<%= r.getOrderId() %></a>
                                            <% } else { %>—<% } %>
                                        </td>
                                        <td>
                                            <span class="badge badge-<%= r.getPriorityCssClass().replace("priority-","") %>">
                                                <%= r.getPriorityLabel() %>
                                            </span>
                                        </td>
                                        <td>
                                            <span class="badge badge-<%= r.getStatusCssClass().replace("status-","") %>">
                                                <%= r.getStatusLabel() %>
                                            </span>
                                            <% if (r.getAdminNote()!=null&&!r.getAdminNote().isEmpty()) { %>
                                                <div style="font-size:.72rem;color:var(--gray-400);margin-top:.2rem;" title="<%= r.getAdminNote() %>">
                                                    <i class="fa-solid fa-note-styling"></i> <%= r.getAdminNote().length()>30?r.getAdminNote().substring(0,30)+"…":r.getAdminNote() %>
                                                </div>
                                            <% } %>
                                        </td>
                                        <td style="font-size:.78rem;color:var(--gray-400);"><%= r.getCreatedAt()!=null?sdf.format(r.getCreatedAt()):"—" %></td>
                                    </tr>
                                <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } else { %>
                        <div class="empty-state"><i class="fa-solid fa-check-circle"></i><p>Không có khiếu nại nào.</p></div>
                    <% } %>
                </div>
            </div>

            <!-- Action History -->
            <div class="detail-card" style="grid-column:1/-1;">
                <div class="detail-card-header">
                    <i class="fa-solid fa-clock-rotate-left"></i>
                    <h3>Lịch Sử Hành Động Của Admin (<%= actionHistory!=null?actionHistory.size():0 %>)</h3>
                </div>
                <div class="detail-card-body">
                    <% if (actionHistory!=null && !actionHistory.isEmpty()) { %>
                        <div class="timeline">
                        <% for (SellerAction a : actionHistory) {
                               String dotClass = "";
                               switch(a.getActionType()) {
                                   case "warn":              dotClass="dot-warn"; break;
                                   case "temp_suspend":      dotClass="dot-suspend"; break;
                                   case "temp_suspend_end":  dotClass="dot-suspend-end"; break;
                                   case "block":             dotClass="dot-block"; break;
                                   case "unblock":           dotClass="dot-unblock"; break;
                               }
                               String icon = "";
                               switch(a.getActionType()) {
                                   case "warn":              icon="fa-bullhorn"; break;
                                   case "temp_suspend":      icon="fa-clock"; break;
                                   case "temp_suspend_end":  icon="fa-unlock"; break;
                                   case "block":             icon="fa-ban"; break;
                                   case "unblock":           icon="fa-lock-open"; break;
                               }
                        %>
                            <div class="timeline-item">
                                <div class="timeline-dot <%= dotClass %>">
                                    <i class="fa-solid <%= icon %>"></i>
                                </div>
                                <div class="timeline-content">
                                    <div class="timeline-title">
                                        <%= a.getActionTypeLabel() %>
                                        <span style="font-weight:400;font-size:.8rem;color:var(--gray-400);">
                                            bởi <%= a.getAdminFullname()!=null?a.getAdminFullname():"Admin" %>
                                        </span>
                                    </div>
                                    <div class="timeline-reason"><%= a.getReason() %></div>
                                    <% if (a.getSuspendUntil()!=null) { %>
                                        <span class="timeline-suspend">
                                            <i class="fa-solid fa-clock"></i> Đến <%= sdfDate.format(a.getSuspendUntil()) %>
                                        </span>
                                    <% } %>
                                    <% if (a.getNote()!=null&&!a.getNote().isEmpty()) { %>
                                        <div style="font-size:.78rem;color:var(--gray-600);margin-top:.2rem;"><em>Ghi chú: <%= a.getNote() %></em></div>
                                    <% } %>
                                    <div class="timeline-meta">
                                        <span><i class="fa-solid fa-calendar"></i> <%= a.getCreatedAt()!=null?sdf.format(a.getCreatedAt()):"—" %></span>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                        </div>
                    <% } else { %>
                        <div class="empty-state"><i class="fa-solid fa-clipboard-list"></i><p>Chưa có hành động nào.</p></div>
                    <% } %>
                </div>
            </div>
        </div>

    <% } %>

</div><!-- .layout -->

<!-- ==================== ACTION MODAL ==================== -->
<div class="modal-overlay" id="actionModal">
    <div class="modal">
        <div class="modal-header" id="modalHeader">
            <i class="fa-solid fa-gavel"></i>
            <h3 id="modalTitle">Hành Động</h3>
        </div>
        <form method="post" action="<%= request.getContextPath() %>/admin/sellers" id="modalForm">
            <input type="hidden" name="action" id="modalAction">
            <input type="hidden" name="shopId" id="modalShopId">
            <% if (isDetail) { %>
                <input type="hidden" name="detailShopId" value="<%= detailShop.getId() %>">
            <% } %>
            <div class="modal-body">
                <div id="modalConfirmMsg" style="margin-bottom:1rem;font-size:.875rem;color:var(--gray-600);"></div>
                <div id="suspendDaysRow" style="display:none;">
                    <label>Số ngày khóa tạm</label>
                    <div class="suspend-days-row">
                        <input type="number" name="suspendDays" id="suspendDaysInput" value="7" min="1" max="90">
                        <span style="font-size:.875rem;color:var(--gray-600);">ngày (1–90)</span>
                    </div>
                </div>
                <label>Lý do <span style="color:var(--red);">*</span></label>
                <textarea name="reason" id="modalReason" placeholder="Nhập lý do hành động..." required minlength="5" maxlength="1000"></textarea>
                <label>Ghi chú thêm (tùy chọn)</label>
                <textarea name="note" placeholder="Ghi chú nội bộ (không hiển thị với seller)..." maxlength="1000"></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="modal-cancel" onclick="closeModal()">Hủy</button>
                <button type="submit" class="modal-confirm" id="modalConfirmBtn">Xác nhận</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openModal(action, shopId, shopName) {
        document.getElementById('modalAction').value = action;
        document.getElementById('modalShopId').value = shopId;
        document.getElementById('modalReason').value = '';
        document.getElementById('suspendDaysRow').style.display = 'none';

        var title = document.getElementById('modalTitle');
        var confirmMsg = document.getElementById('modalConfirmMsg');
        var confirmBtn = document.getElementById('modalConfirmBtn');
        var header = document.getElementById('modalHeader');

        header.className = 'modal-header';
        confirmBtn.className = 'modal-confirm';
        confirmBtn.textContent = 'Xác nhận';

        switch(action) {
            case 'warn':
                title.textContent = 'Gửi Cảnh Cáo';
                confirmMsg.textContent = 'Gửi cảnh cáo đến shop "' + shopName + '". Tài khoản sẽ không bị khóa.';
                header.style.background = '#fff3e0'; header.style.color = '#e65100';
                confirmBtn.classList.add('orange');
                break;
            case 'temp_suspend':
                title.textContent = 'Tạm Khóa Shop';
                confirmMsg.textContent = 'Tạm khóa shop "' + shopName + '" trong thời gian nhất định. Tài khoản seller cũng bị khóa.';
                header.style.background = '#fffbeb'; header.style.color = '#92400e';
                document.getElementById('suspendDaysRow').style.display = 'block';
                confirmBtn.classList.add('orange');
                break;
            case 'lift_suspend':
                title.textContent = 'Kết Thúc Tạm Khóa';
                confirmMsg.textContent = 'Mở khóa tài khoản và shop "' + shopName + '".';
                header.style.background = '#e0f2fe'; header.style.color = '#0369a1';
                confirmBtn.classList.add('green');
                break;
            case 'block':
                title.textContent = 'Khóa Vĩnh Viễn';
                confirmMsg.innerHTML = '<span style="color:#991b1b;font-weight:700;">Cảnh báo:</span> Khóa vĩnh viễn shop "' + shopName + '". Tài khoản seller cũng bị khóa. Hành động này có thể hoàn tác.';
                header.style.background = '#fee2e2'; header.style.color = '#991b1b';
                confirmBtn.classList.add('red');
                break;
            case 'unblock':
                title.textContent = 'Mở Khóa Shop';
                confirmMsg.textContent = 'Mở khóa shop "' + shopName + '" và tài khoản seller.';
                header.style.background = '#dcfce7'; header.style.color = '#15803d';
                confirmBtn.classList.add('green');
                break;
        }

        document.getElementById('actionModal').classList.add('show');
    }

    function closeModal() {
        document.getElementById('actionModal').classList.remove('show');
    }

    document.getElementById('actionModal').addEventListener('click', function(e) {
        if (e.target === this) closeModal();
    });
</script>

</body>
</html>
