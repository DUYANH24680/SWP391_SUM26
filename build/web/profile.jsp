<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%
    Account user = (Account) session.getAttribute("user");
    String role   = (String) session.getAttribute("role");

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/profile");
        return;
    }

    String roleDisplay = "Member";
    if ("admin".equalsIgnoreCase(role))         roleDisplay = "Quản Trị Viên";
    else if ("seller".equalsIgnoreCase(role))   roleDisplay = "Nhân Viên Bán Hàng";
    else if ("delivery".equalsIgnoreCase(role)) roleDisplay = "Nhân Viên Giao Hàng";

    String fullname    = user.getFullname();
    String username    = user.getUsername();
    String email       = user.getEmail();
    String phone       = user.getPhone();
    String address     = user.getAddress();
    String genderStr   = "Chưa cập nhật";
    if (user.getGender() != null) genderStr = user.getGender() ? "Nam" : "Nu";

    String avatarUrl = user.getAvatar();
    String createdAtStr = "";
    if (user.getCreatedAt() != null)
        createdAtStr = new java.text.SimpleDateFormat("dd/MM/yyyy").format(user.getCreatedAt());

    if (phone   == null || phone.trim().isEmpty())   phone   = "Chưa cập nhật";
    if (address == null || address.trim().isEmpty()) address = "Chưa cập nhật";
    if (avatarUrl == null || avatarUrl.trim().isEmpty())
        avatarUrl = "https://ui-avatars.com/api/?name="
                  + java.net.URLEncoder.encode(fullname, "UTF-8")
                  + "&background=4caf50&color=fff&size=160&bold=true&rounded=true";

    String message = (String) session.getAttribute("message");
    String error   = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ Sơ Cá Nhân | Sena Shop</title>
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

        body {
            display: flex;
            flex-direction: column;
        }

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

        .nav-icon-btn {
            width: 38px; height: 38px;
            border-radius: 50%;
            background: var(--gray-100);
            border: none;
            display: flex; align-items: center; justify-content: center;
            color: var(--gray-600);
            cursor: pointer;
            font-size: 0.95rem;
            transition: background 0.15s;
        }

        .nav-icon-btn:hover { background: var(--green-light); color: var(--green-dark); }

        .nav-avatar {
            width: 38px; height: 38px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--green);
            cursor: pointer;
        }

        /* ======= MAIN LAYOUT ======= */
        .layout {
            display: flex;
            flex: 1;
            max-width: 1080px;
            width: 100%;
            margin: 2rem auto;
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

        .sidebar-user {
            padding: 1.25rem 1rem;
            border-bottom: 1px solid var(--gray-100);
        }

        .sidebar-user-row {
            display: flex;
            align-items: center;
            gap: 0.65rem;
            margin-bottom: 0.3rem;
        }

        .sidebar-user-avatar {
            width: 34px; height: 34px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--green);
        }

        .sidebar-welcome {
            font-size: 0.8rem;
            font-weight: 700;
            color: var(--gray-800);
            line-height: 1.2;
        }

        .sidebar-role-text {
            font-size: 0.72rem;
            color: var(--gray-400);
            padding-left: 0.1rem;
        }

        .sidebar-nav { padding: 0.5rem; }

        .sidebar-nav button {
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
            font-family: 'Inter', sans-serif;
            text-align: left;
            transition: all 0.15s;
        }

        .sidebar-nav button:hover { background: var(--green-light); color: var(--green-dark); }

        .sidebar-nav button.active {
            background: var(--green);
            color: #fff;
            font-weight: 600;
        }

        /* ======= MAIN CONTENT ======= */
        .main { flex: 1; display: flex; flex-direction: column; gap: 1.25rem; min-width: 0; }

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

        .alert-success { background: #dcfce7; border: 1px solid #bbf7d0; color: #166534; }
        .alert-danger  { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }

        /* ======= HERO CARD ======= */
        .hero-card {
            background: linear-gradient(135deg, #e8f5e9 0%, #f1f8f1 60%, #ffffff 100%);
            border-radius: var(--radius);
            border: 1px solid var(--green-mid);
            padding: 2rem 2rem 1.75rem;
            display: flex;
            align-items: center;
            gap: 2rem;
            box-shadow: var(--shadow-sm);
            position: relative;
            overflow: hidden;
        }

        .hero-card::before {
            content: '';
            position: absolute;
            top: -50px; right: -50px;
            width: 180px; height: 180px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(76,175,80,0.1) 0%, transparent 70%);
        }

        .hero-avatar-wrap { position: relative; flex-shrink: 0; }

        .hero-avatar {
            width: 120px; height: 120px;
            border-radius: 50%;
            object-fit: cover;
            border: 4px solid var(--white);
            box-shadow: var(--shadow-md);
            display: block;
        }

        .hero-avatar-edit {
            position: absolute;
            bottom: 4px; right: 4px;
            width: 28px; height: 28px;
            border-radius: 50%;
            background: var(--green);
            color: #fff;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.7rem;
            border: 2px solid #fff;
            cursor: pointer;
            box-shadow: var(--shadow-sm);
        }

        .hero-info { flex: 1; }

        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            font-size: 0.68rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.07em;
            color: var(--green-dark);
            border: 1.5px solid var(--green);
            border-radius: 100px;
            padding: 0.2rem 0.7rem;
            margin-bottom: 0.5rem;
        }

        .hero-name {
            font-size: 1.9rem;
            font-weight: 800;
            color: var(--gray-800);
            line-height: 1.1;
            margin-bottom: 0.35rem;
            letter-spacing: -0.02em;
        }

        .hero-sub {
            font-size: 0.85rem;
            color: var(--gray-600);
            margin-bottom: 1.25rem;
        }

        .hero-actions { display: flex; gap: 0.75rem; flex-wrap: wrap; }

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

        .card-body { padding: 1.25rem 1.5rem; }

        /* ======= FIELD GRID (view mode) ======= */
        .field-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.85rem;
        }

        .field-box {
            background: var(--gray-50);
            border: 1px solid var(--gray-100);
            border-radius: var(--radius-sm);
            padding: 0.85rem 1rem;
            transition: border-color 0.15s;
        }

        .field-box:hover { border-color: var(--green-mid); }
        .field-box.full  { grid-column: span 2; }

        .field-lbl {
            font-size: 0.7rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--gray-400);
            margin-bottom: 0.3rem;
            display: flex;
            align-items: center;
            gap: 0.35rem;
        }

        .field-val {
            font-size: 0.9rem;
            font-weight: 500;
            color: var(--gray-800);
            display: flex;
            align-items: center;
            gap: 0.4rem;
        }

        .field-val i { color: var(--green); font-size: 0.78rem; }

        /* ======= FORM ======= */
        .form-section-lbl {
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: var(--gray-400);
            margin-bottom: 1rem;
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.85rem;
        }

        .form-group { display: flex; flex-direction: column; gap: 0.35rem; }
        .form-group.full { grid-column: span 2; }

        .form-label {
            font-size: 0.78rem;
            font-weight: 600;
            color: var(--gray-600);
        }

        .form-control {
            background: var(--gray-50);
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            padding: 0.7rem 0.9rem;
            font-size: 0.875rem;
            font-family: 'Inter', sans-serif;
            color: var(--gray-800);
            outline: none;
            transition: all 0.18s;
            width: 100%;
        }

        .form-control:focus {
            border-color: var(--green);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(76,175,80,0.12);
        }

        .form-control::placeholder { color: var(--gray-400); }

        textarea.form-control { resize: vertical; min-height: 72px; }
        select.form-control option { background: var(--white); }

        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 0.65rem;
            margin-top: 1.25rem;
            padding-top: 1.25rem;
            border-top: 1px solid var(--gray-100);
        }

        .pw-hint { font-size: 0.72rem; color: var(--gray-400); margin-top: 0.2rem; }

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

        /* ======= SECURITY ACTION ======= */
        .security-desc {
            font-size: 0.85rem;
            color: var(--gray-600);
            line-height: 1.6;
            margin-bottom: 1.25rem;
        }

        .security-join {
            display: flex;
            align-items: center;
            gap: 0.6rem;
            font-size: 0.8rem;
            color: var(--gray-600);
            padding-top: 1.25rem;
            margin-top: 1.25rem;
            border-top: 1px solid var(--gray-100);
        }

        .security-join i { color: #e53935; }

        /* ======= MODAL ======= */
        .modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.3);
            backdrop-filter: blur(4px);
            z-index: 200;
            align-items: center;
            justify-content: center;
        }

        .modal-overlay.open { display: flex; animation: fadeBg 0.2s ease; }

        @keyframes fadeBg { from { opacity: 0; } to { opacity: 1; } }

        .modal-box {
            background: var(--white);
            border-radius: var(--radius);
            padding: 2rem;
            width: 90%;
            max-width: 480px;
            box-shadow: var(--shadow-md);
            animation: slideUp 0.25s cubic-bezier(0.34,1.56,0.64,1);
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(20px) scale(0.97); }
            to   { opacity: 1; transform: translateY(0)   scale(1); }
        }

        .modal-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1.5rem;
        }

        .modal-title {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--gray-800);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .modal-title i { color: var(--green); }

        .modal-close {
            width: 30px; height: 30px;
            border-radius: 50%;
            border: none;
            background: var(--gray-100);
            color: var(--gray-600);
            cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.85rem;
            transition: all 0.15s;
        }

        .modal-close:hover { background: #fee2e2; color: #ef4444; }

        /* ======= FOOTER ======= */
        .footer {
            background: var(--white);
            border-top: 1px solid var(--gray-200);
            padding: 1.2rem 2rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-top: auto;
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

        .footer-links { display: flex; gap: 1.25rem; }

        .footer-links a {
            font-size: 0.78rem;
            color: var(--gray-400);
            text-decoration: none;
            transition: color 0.15s;
        }

        .footer-links a:hover { color: var(--green-dark); }

        /* ======= RESPONSIVE ======= */
        @media (max-width: 768px) {
            .layout { flex-direction: column; padding: 0 1rem; }
            .sidebar { width: 100%; position: static; }
            .field-grid, .form-grid { grid-template-columns: 1fr; }
            .field-box.full, .form-group.full { grid-column: span 1; }
            .hero-card { flex-direction: column; text-align: center; }
            .hero-actions { justify-content: center; }
            .topnav { padding: 0 1rem; }
            .nav-links { display: none; }
        }
    </style>
</head>
<body>

<!-- ====== TOPNAV ====== -->
<nav class="topnav">
    <a href="home.jsp" class="nav-logo">
        <i class="fa-solid fa-apple-whole"></i> Sena Shop
    </a>
    <div class="nav-links">
        <a href="home.jsp">Trang Chủ</a>
        <a href="danh-muc">Danh Mục</a>
        <a href="products">Sản Phẩm</a>
    </div>
    <div class="nav-right">
        <button class="nav-icon-btn" title="Gio hang"><i class="fa-solid fa-basket-shopping"></i></button>
        <img class="nav-avatar" src="<%= avatarUrl %>" alt="avatar">
    </div>
</nav>

<!-- ====== LAYOUT ====== -->
<div class="layout">

    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-user">
            <div class="sidebar-user-row">
                <img class="sidebar-user-avatar" src="<%= avatarUrl %>" alt="avatar">
                <div>
                    <div class="sidebar-welcome"><%= fullname.split(" ")[fullname.split(" ").length - 1] %></div>
                </div>
            </div>
            <div class="sidebar-role-text"><%= roleDisplay %></div>
        </div>

        <div class="sidebar-nav">
            <button class="active" id="nav-profile" onclick="showPanel('profile')">
                <i class="fa-regular fa-user"></i> Ho So
            </button>
            <a href="address" style="display:flex; align-items:center; gap:0.65rem; width:100%; padding:0.65rem 0.9rem; border-radius:var(--radius-sm); font-size:0.875rem; font-weight:500; color:var(--gray-600); border:none; background:transparent; cursor:pointer; text-decoration:none; transition:all 0.15s;" onmouseover="this.style.background='var(--green-light)'; this.style.color='var(--green-dark)';" onmouseout="this.style.background='transparent'; this.style.color='var(--gray-600)';">
                <i class="fa-solid fa-map-location-dot"></i> Sổ Địa Chỉ
            </a>
            <button id="nav-security" onclick="showPanel('security')">
                <i class="fa-solid fa-shield-halved"></i> Bảo Mật
            </button>
            <% if ("admin".equalsIgnoreCase(role) || "seller".equalsIgnoreCase(role)) { %>
            <a href="category" style="display:flex; align-items:center; gap:0.65rem; width:100%; padding:0.65rem 0.9rem; border-radius:var(--radius-sm); font-size:0.875rem; font-weight:500; color:var(--gray-600); border:none; background:transparent; cursor:pointer; text-decoration:none; transition:all 0.15s;" onmouseover="this.style.background='var(--green-light)'; this.style.color='var(--green-dark)';" onmouseout="this.style.background='transparent'; this.style.color='var(--gray-600)';">
                <i class="fa-solid fa-layer-group"></i> Quản Lý Danh Mục
            </a>
            <% } %>
            <% if ("admin".equalsIgnoreCase(role) || "seller".equalsIgnoreCase(role)) { %>
            <a href="products" style="display:flex; align-items:center; gap:0.65rem; width:100%; padding:0.65rem 0.9rem; border-radius:var(--radius-sm); font-size:0.875rem; font-weight:500; color:var(--gray-600); border:none; background:transparent; cursor:pointer; text-decoration:none; transition:all 0.15s;" onmouseover="this.style.background='var(--green-light)'; this.style.color='var(--green-dark)';" onmouseout="this.style.background='transparent'; this.style.color='var(--gray-600)';">
                <i class="fa-brands fa-opencart"></i> Quản Lý Sản Phẩm
            </a>
            <% } %>
            <a href="logout" style="text-decoration:none; display:flex; align-items:center; gap:0.75rem; padding:12px 16px; border-radius:12px; color:#e53e3e; font-weight:600; font-size:0.95rem; margin-bottom:8px; border:1px solid transparent; transition:all 0.2s;" onmouseover="this.style.background='#fff5f5'; this.style.borderColor='#fed7d7';" onmouseout="this.style.background='transparent'; this.style.borderColor='transparent';">
                <i class="fa-solid fa-right-from-bracket" style="width:20px;text-align:center;"></i> Đăng Xuất
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="main">

        <!-- Flash messages -->
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

        <!-- ====== PANEL: HO SO ====== -->
        <div id="panel-profile" style="display:flex; flex-direction:column; gap:1.25rem;">

            <!-- Hero card -->
            <div class="hero-card">
                <div class="hero-avatar-wrap">
                    <img class="hero-avatar" src="<%= avatarUrl %>" alt="Avatar">
                    <div class="hero-avatar-edit" onclick="openEdit()" title="Chinh sua anh dai dien">
                        <i class="fa-solid fa-gear"></i>
                    </div>
                </div>
                <div class="hero-info">
                    <div class="hero-badge">
                        <i class="fa-solid fa-circle-dot" style="font-size:0.5rem;"></i>
                        <%= roleDisplay.toUpperCase() %>
                    </div>
                    <h1 class="hero-name"><%= fullname %></h1>
                    <div class="hero-sub">
                        @<%= username %>
                        <% if (!createdAtStr.isEmpty()) { %>
                          &nbsp;&bull;&nbsp; Tham gia tu <%= createdAtStr %>
                        <% } %>
                    </div>
                    <div class="hero-actions">
                        <button class="btn btn-green btn-sm" onclick="openEdit()">
                            <i class="fa-solid fa-pencil"></i> Chinh Sua Ho So
                        </button>
                    </div>
                </div>
            </div>

            <!-- Personal Information card (full width, no security card here) -->
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <i class="fa-regular fa-address-card"></i> Thong Tin Ca Nhan
                    </div>
                </div>
                <div class="card-body">
                    <div class="field-grid">
                        <div class="field-box">
                            <div class="field-lbl"><i class="fa-regular fa-user"></i> Ho va Ten</div>
                            <div class="field-val"><%= fullname %></div>
                        </div>
                        <div class="field-box">
                            <div class="field-lbl"><i class="fa-solid fa-venus-mars"></i> Gioi Tinh</div>
                            <div class="field-val"><%= genderStr %></div>
                        </div>
                        <div class="field-box">
                            <div class="field-lbl"><i class="fa-regular fa-envelope"></i> Dia Chi Email</div>
                            <div class="field-val"><%= email %></div>
                        </div>
                        <div class="field-box">
                            <div class="field-lbl"><i class="fa-solid fa-phone"></i> So Dien Thoai</div>
                            <div class="field-val"><%= phone %></div>
                        </div>
                        <div class="field-box full">
                            <div class="field-lbl"><i class="fa-solid fa-location-dot"></i> Dia Chi Mac Dinh</div>
                            <div class="field-val"><i class="fa-solid fa-map-pin"></i> <%= address %></div>
                        </div>
                    </div>
                </div>
            </div>

        </div><!-- /panel-profile -->

        <!-- ====== PANEL: BAO MAT ====== -->
        <div id="panel-security" style="display:none; flex-direction:column; gap:1.25rem;">

            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <i class="fa-solid fa-shield-halved"></i> Bảo Mật Tai Khoan
                    </div>
                </div>
                <div class="card-body">
                    <p class="security-desc">
                        Giu tai khoan cua ban luon an toan bang cach cap nhat mat khau dinh ky.
                        Su dung mat khau manh voi it nhat 6 ky tu.
                    </p>
                    <form action="profile" method="POST">
                        <input type="hidden" name="action" value="changePassword">
                        <div class="form-section-lbl">Thay Đổi Mật Khẩu</div>
                        <div class="form-grid">
                            <div class="form-group full">
                                <label class="form-label">Mật khẩu hiện tại</label>
                                <input type="password" name="currentPassword" class="form-control"
                                       placeholder="Nhap mat khau hien tai" required>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Mật khẩu mới</label>
                                <input type="password" name="newPassword" class="form-control"
                                       placeholder="Mật khẩu mới" required>
                                <span class="pw-hint">Toi thieu 6 ky tu</span>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Xác nhận mật khẩu mới</label>
                                <input type="password" name="confirmPassword" class="form-control"
                                       placeholder="Nhap lai mat khau moi" required>
                            </div>
                        </div>
                        <div class="form-actions">
                            <button type="submit" class="btn btn-green">
                                <i class="fa-solid fa-shield-halved"></i> Cập Nhật Mật Khẩu
                            </button>
                        </div>
                    </form>

                    <% if (!createdAtStr.isEmpty()) { %>
                    <div class="security-join">
                        <i class="fa-regular fa-calendar"></i>
                        Tham gia Sena Shop tu ngay <strong style="margin-left:0.2rem;"><%= createdAtStr %></strong>
                    </div>
                    <% } %>
                </div>
            </div>

        </div><!-- /panel-security -->

    </main>
</div><!-- /layout -->

<!-- ====== FOOTER ====== -->
<footer class="footer">
    <a href="home.jsp" class="footer-logo"><i class="fa-solid fa-apple-whole"></i> Sena Shop</a>
    <span class="footer-copy">&copy; 2024 Sena Shop. Trái cây tươi ngon mỗi ngày.</span>
    <div class="footer-links">
        <a href="#">Privacy</a>
        <a href="#">Terms</a>
        <a href="#">Lien He</a>
    </div>
</footer>

<!-- ====== MODAL: CHINH SUA HO SO ====== -->
<div class="modal-overlay" id="editModal">
    <div class="modal-box">
        <div class="modal-header">
            <div class="modal-title"><i class="fa-regular fa-pen-to-square"></i> Chinh Sua Ho So</div>
            <button class="modal-close" onclick="closeEdit()"><i class="fa-solid fa-xmark"></i></button>
        </div>
        <form action="profile" method="POST">
            <input type="hidden" name="action" value="updateProfile">
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Ho va ten</label>
                    <input type="text" name="fullname" class="form-control" value="<%= fullname %>" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Email</label>
                    <input type="email" name="email" class="form-control" value="<%= email %>" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Số điện thoại</label>
                    <input type="text" name="phone" class="form-control"
                           value="<%= "Chưa cập nhật".equals(phone) ? "" : phone %>"
                           placeholder="Nhap so dien thoai">
                </div>
                <div class="form-group">
                    <label class="form-label">Giới tính</label>
                    <select name="gender" class="form-control">
                        <option value="" <%= user.getGender() == null ? "selected" : "" %>>Chua chon</option>
                        <option value="1" <%= (user.getGender() != null && user.getGender())  ? "selected" : "" %>>Nam</option>
                        <option value="0" <%= (user.getGender() != null && !user.getGender()) ? "selected" : "" %>>Nữ</option>
                    </select>
                </div>
                <div class="form-group full">
                    <label class="form-label">Dia chi</label>
                    <textarea name="address" class="form-control"
                              placeholder="Nhap dia chi"><%= "Chưa cập nhật".equals(address) ? "" : address %></textarea>
                </div>
                <div class="form-group full">
                    <label class="form-label">Avatar URL</label>
                    <input type="text" name="avatar" class="form-control"
                           value="<%= user.getAvatar() != null ? user.getAvatar() : "" %>"
                           placeholder="https://...">
                </div>
            </div>
            <div class="form-actions">
                <button type="button" class="btn btn-outline" onclick="closeEdit()">Huy</button>
                <button type="submit" class="btn btn-green">
                    <i class="fa-solid fa-floppy-disk"></i> Lưu Thay Đổi
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    // Panel switching
    function showPanel(name) {
        var profile  = document.getElementById('panel-profile');
        var security = document.getElementById('panel-security');
        var btnP     = document.getElementById('nav-profile');
        var btnS     = document.getElementById('nav-security');

        if (name === 'profile') {
            profile.style.display  = 'flex';
            security.style.display = 'none';
            btnP.classList.add('active');
            btnS.classList.remove('active');
        } else {
            profile.style.display  = 'none';
            security.style.display = 'flex';
            btnP.classList.remove('active');
            btnS.classList.add('active');
        }
        localStorage.setItem('senaPanel', name);
    }

    // Restore last panel
    window.addEventListener('DOMContentLoaded', function() {
        var urlParams = new URLSearchParams(window.location.search);
        var tabFromUrl = urlParams.get('tab');
        var saved = tabFromUrl || localStorage.getItem('senaPanel') || 'profile';
        
        // Remove param from URL to prevent sticking on reload
        if (tabFromUrl) {
            window.history.replaceState({}, document.title, window.location.pathname);
        }
        
        showPanel(saved);
    });

    // Edit profile modal
    function openEdit() {
        document.getElementById('editModal').classList.add('open');
        document.body.style.overflow = 'hidden';
    }

    function closeEdit() {
        document.getElementById('editModal').classList.remove('open');
        document.body.style.overflow = '';
    }

    // Close on overlay click
    document.getElementById('editModal').addEventListener('click', function(e) {
        if (e.target === this) closeEdit();
    });

    // Escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeEdit();
    });
</script>
</body>
</html>
