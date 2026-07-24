<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Category" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%!
    // Helper: chuyen duong dan image thanh URL hop le (di qua ImageServlet neu la uploads/)
    public static String imgUrl(String path, String contextPath) {
        if (path == null || path.trim().isEmpty()) return null;
        String trimmed = path.trim();
        if (trimmed.startsWith("uploads/")) {
            try {
                return contextPath + "/image?path=" + java.net.URLEncoder.encode(trimmed, "UTF-8");
            } catch (java.io.UnsupportedEncodingException e) { return trimmed; }
        }
        return trimmed;
    }
%>
<%
    Object rawUser = session.getAttribute("Account");
    Account user = (Account) rawUser;
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String role = (String) session.getAttribute("role");
    if (role == null || (!role.equals("admin") && !role.equals("seller"))) {
        response.sendRedirect(request.getContextPath() + "/home.jsp");
        return;
    }

    String avatarUrl = user.getAvatar();
    if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
        String fullname = user.getFullname() != null ? user.getFullname() : user.getUsername();
        try {
            avatarUrl = "https://ui-avatars.com/api/?name="
                      + java.net.URLEncoder.encode(fullname, "UTF-8")
                      + "&background=4caf50&color=fff&size=80&bold=true&rounded=true";
        } catch (java.io.UnsupportedEncodingException e) {
            avatarUrl = "https://ui-avatars.com/api/?name=" + fullname
                      + "&background=4caf50&color=fff&size=80&bold=true&rounded=true";
        }
    }

    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");

    List<Category> categories = (List<Category>) request.getAttribute("categories");
    if (categories == null) categories = java.util.Collections.emptyList();


%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Danh Mục | SenaFruit</title>
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

        .sidebar-nav a,
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
            text-decoration: none;
            transition: all 0.15s;
        }

        .sidebar-nav a:hover { background: var(--green-light); color: var(--green-dark); }
        .sidebar-nav a.active { background: var(--green); color: #fff; font-weight: 600; }
        .sidebar-nav a.logout { color: #e53e3e; }
        .sidebar-nav a.logout:hover { background: #fff5f5; color: #c53030; }

        /* ======= MAIN ======= */
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
        .alert-success i, .alert-danger i { flex-shrink: 0; }

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

        /* ======= BREADCRUMB ======= */
        .breadcrumb {
            display: flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 0.82rem;
            color: var(--gray-400);
        }

        .breadcrumb a { color: var(--green); text-decoration: none; font-weight: 500; }
        .breadcrumb a:hover { text-decoration: underline; }
        .breadcrumb span { color: var(--gray-600); font-weight: 500; }

        /* ======= TABLE ======= */
        .table-wrap { overflow-x: auto; }

        .cat-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.875rem;
        }

        .cat-table thead th {
            background: var(--gray-50);
            padding: 0.85rem 1.25rem;
            text-align: left;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--gray-600);
            border-bottom: 2px solid var(--gray-200);
            white-space: nowrap;
        }

        .cat-table tbody tr {
            border-bottom: 1px solid var(--gray-100);
            transition: background 0.12s;
        }

        .cat-table tbody tr:hover { background: var(--green-light); }

        .cat-table tbody td {
            padding: 0.9rem 1.25rem;
            color: var(--gray-800);
            vertical-align: middle;
        }

        /* Category image */
        .cat-img {
            width: 52px;
            height: 52px;
            border-radius: 10px;
            object-fit: cover;
            border: 1.5px solid var(--gray-200);
            background: var(--gray-50);
            overflow: hidden;
            display: block;
        }

        .cat-img-placeholder {
            width: 52px;
            height: 52px;
            border-radius: 10px;
            background: linear-gradient(135deg, #e8f5e9, #c8e6c9);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
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
        .badge-red    { background: #fee2e2; color: #991b1b; }

        /* Action buttons */
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

        .btn-edit {
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

        .btn-edit:hover {
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

        /* ======= MODAL ======= */
        .modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.45);
            z-index: 200;
            align-items: center;
            justify-content: center;
        }

        .modal-overlay.active { display: flex; }

        .modal-box {
            background: var(--white);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            padding: 2rem;
            max-width: 420px;
            width: 90%;
            text-align: center;
            animation: modalIn 0.2s ease;
        }

        @keyframes modalIn {
            from { opacity: 0; transform: scale(0.92); }
            to   { opacity: 1; transform: scale(1); }
        }

        .modal-icon {
            width: 56px; height: 56px;
            border-radius: 50%;
            background: #fee2e2;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.2rem;
            font-size: 1.5rem;
            color: #dc2626;
        }

        .modal-title {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--gray-800);
            margin-bottom: 0.6rem;
        }

        .modal-text {
            font-size: 0.875rem;
            color: var(--gray-600);
            line-height: 1.6;
            margin-bottom: 1.75rem;
        }

        .modal-actions {
            display: flex;
            gap: 0.75rem;
            justify-content: center;
        }

        .modal-actions .btn {
            min-width: 110px;
        }

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
            .sidebar-nav a { width: auto; }
        }

        @media (max-width: 600px) {
            .topnav { padding: 0 1rem; }
            .nav-links { display: none; }
        }
    </style>
</head>
<body>

<jsp:include page="/sidebar.jsp">
    <jsp:param name="activePage" value="category"/>
</jsp:include>

    <!-- MAIN -->
    <main class="sena-main">

        <!-- Breadcrumb -->
        <div class="breadcrumb">
            <a href="products"><i class="fa-solid fa-box"></i> Sản Phẩm</a>
            <i class="fa-solid fa-chevron-right" style="font-size:0.6rem;color:var(--gray-400);"></i>
            <span>Quản Lý Danh Mục</span>
        </div>

        <!-- Alerts -->
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

        <!-- Main card -->
        <div class="card">
            <div class="card-header">
                <div class="card-title">
                    <i class="fa-solid fa-layer-group"></i>
                    Danh Sách Danh Mục
                </div>
                <a href="category/add" class="btn btn-green btn-sm">
                    <i class="fa-solid fa-plus"></i> Thêm Danh Mục
                </a>
            </div>

            <!-- Table -->
            <div class="table-wrap">
                <table class="cat-table">
                    <thead>
                        <tr>
                            <th style="width:60px;">ID</th>
                            <th style="width:80px;">Ảnh</th>
                            <th>Tên Danh Mục</th>
                            <th style="width:110px;">Trạng Thái</th>
                            <th style="width:160px;">Hành Động</th>
                        </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${not empty categories}">
                            <c:forEach var="c" items="${categories}">
                                <tr>
                                    <td style="font-weight:600;color:var(--gray-600);">#${c.id}</td>

                                    <!-- Hinh anh -->
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty c.image}">
                                                <c:url value="/image" var="imgSrc">
                                                    <c:param name="path" value="${c.image}" />
                                                </c:url>
                                                <img class="cat-img" src="${imgSrc}" alt="${c.name}"
                                                     onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
                                                <div class="cat-img-placeholder" style="display:none;">
                                                    <i class="fa-solid fa-layer-group" style="color:var(--green);font-size:1.2rem;"></i>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="cat-img-placeholder">
                                                    <i class="fa-solid fa-layer-group" style="color:var(--green);font-size:1.2rem;"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Ten danh muc -->
                                    <td>
                                        <span style="font-weight:600;color:var(--gray-800);">${c.name}</span>
                                    </td>

                                    <!-- Trang thai -->
                                    <td>
                                        <c:choose>
                                            <c:when test="${!c.isDelete}">
                                                <span class="badge badge-green">
                                                    <i class="fa-solid fa-circle" style="font-size:0.45rem;"></i> Hoạt Động
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-red">
                                                    <i class="fa-solid fa-circle" style="font-size:0.45rem;"></i> Đã Xóa
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Hanh dong -->
                                    <td>
                                        <a href="category/edit/${c.id}" class="btn-edit">
                                            <i class="fa-solid fa-pen-to-square"></i> Sửa
                                        </a>
                                        <button type="button" class="btn-delete"
                                                onclick="openDeleteModal(${c.id}, '${c.name}')">
                                            <i class="fa-solid fa-trash"></i> Xóa
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="5">
                                    <div class="empty-state">
                                        <i class="fa-solid fa-layer-group" style="color:var(--gray-400);"></i>
                                        <p>Chưa có danh mục nào. <a href="category/add" style="color:var(--green);font-weight:600;">Thêm danh mục đầu tiên</a>.</p>
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

<!-- ====== DELETE CONFIRM MODAL ====== -->
<div class="modal-overlay" id="deleteModal">
    <div class="modal-box">
        <div class="modal-icon">
            <i class="fa-solid fa-trash"></i>
        </div>
        <div class="modal-title">Xác nhận xóa danh mục</div>
        <div class="modal-text" id="modalText">
            Bạn có chắc muốn xóa danh mục này không? Hành động này sẽ không xóa sản phẩm liên quan.
        </div>
        <div class="modal-actions">
            <a href="#" class="btn btn-outline" id="modalCancel">
                <i class="fa-solid fa-xmark"></i> Hủy
            </a>
            <a href="#" class="btn btn-delete" id="modalConfirm" style="background:#dc2626;color:#fff;border-color:#dc2626;">
                <i class="fa-solid fa-trash"></i> Xóa
            </a>
        </div>
    </div>
</div>



<script>
    const modal = document.getElementById('deleteModal');
    const modalConfirm = document.getElementById('modalConfirm');
    const modalCancel  = document.getElementById('modalCancel');

    function openDeleteModal(id, name) {
        document.getElementById('modalText').innerHTML =
            'Bạn có chắc muốn xóa danh mục <strong>"' + name + '"</strong> không?<br>' +
            '<span style="font-size:0.8rem;color:var(--gray-600);">Hành động này chỉ đánh dấu xóa — danh mục sẽ bị ẩn khỏi danh sách.</span>';
        modalConfirm.href = 'category/delete?id=' + id;
        modal.classList.add('active');
    }

    modalCancel.addEventListener('click', function(e) {
        e.preventDefault();
        modal.classList.remove('active');
    });

    modal.addEventListener('click', function(e) {
        if (e.target === modal) {
            modal.classList.remove('active');
        }
    });

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            modal.classList.remove('active');
        }
    });
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

