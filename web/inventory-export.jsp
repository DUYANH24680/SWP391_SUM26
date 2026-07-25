<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="model.Account" %>
        <%@ page import="model.Product" %>
            <%@ page import="Utils.ImageUrlUtil" %>
                <%@ page import="java.util.List" %>
                    <% Object rawUser=session.getAttribute("Account"); Object rawUserId=session.getAttribute("userId");
                        Account user=(Account) rawUser; if (user==null) { response.sendRedirect(request.getContextPath()
                        + "/login" ); return; } String role=(String) session.getAttribute("role"); String
                        avatarUrl=user.getAvatar(); if (avatarUrl==null || avatarUrl.trim().isEmpty()) { String
                        fullname=user.getFullname() !=null ? user.getFullname() : user.getUsername();
                        avatarUrl="https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(fullname, "UTF-8" )
                        + "&background=ef4444&color=fff&size=80&bold=true&rounded=true" ; } String message=(String)
                        session.getAttribute("message"); String error=(String) session.getAttribute("error");
                            session.removeAttribute("message"); session.removeAttribute("error");
                            
                            List<java.util.Map<String, Object>> batches = (List<java.util.Map<String, Object>>) request.getAttribute("batches");
                                if (batches == null) batches = java.util.Collections.emptyList();

                                        java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
                                        java.text.SimpleDateFormat sdfExp = new
                                        java.text.SimpleDateFormat("dd/MM/yyyy");
                                        java.text.SimpleDateFormat sdfSql = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                                                %>
                                    <!DOCTYPE html>
                                    <html lang="vi">

                                    <head>
                                        <meta charset="UTF-8">
                                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                        <title>Xuất Kho | SenaFruit</title>
                                        <link
                                            href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
                                            rel="stylesheet">
                                        <link rel="stylesheet"
                                            href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
                                        <style>
                                            *,
                                            *::before,
                                            *::after {
                                                box-sizing: border-box;
                                                margin: 0;
                                                padding: 0;
                                            }

                                            :root {
                                                --red: #ef4444;
                                                --red-dark: #dc2626;
                                                --red-light: #fef2f2;
                                                --red-mid: #fecaca;
                                                --bg: #f8f4f4;
                                                --white: #ffffff;
                                                --gray-50: #f8fafb;
                                                --gray-100: #f1f1f1;
                                                --gray-200: #e2e2e2;
                                                --gray-400: #a8a8a8;
                                                --gray-600: #6a6a6a;
                                                --gray-800: #3d3d3d;
                                                --shadow-sm: 0 1px 3px rgba(0, 0, 0, .08);
                                                --shadow: 0 4px 12px rgba(0, 0, 0, .08);
                                                --radius: 14px;
                                                --radius-sm: 8px;
                                            }

                                            html,
                                            body {
                                                min-height: 100vh;
                                                font-family: 'Inter', sans-serif;
                                                color: var(--gray-800);
                                                background: var(--bg);
                                            }

                                            /* ======= MAIN ======= */
                                            .main {
                                                flex: 1;
                                                display: flex;
                                                flex-direction: column;
                                                gap: 1.25rem;
                                                min-width: 0;
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
                                            }

                                            .alert-success {
                                                background: #dcfce7;
                                                border: 1px solid #bbf7d0;
                                                color: #166534;
                                            }

                                            .alert-danger {
                                                background: #fee2e2;
                                                border: 1px solid #fecaca;
                                                color: #991b1b;
                                            }

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
                                                gap: 0.6rem;
                                                padding: 1.1rem 1.5rem;
                                                border-bottom: 1px solid var(--gray-100);
                                            }

                                            .card-title {
                                                font-size: 0.95rem;
                                                font-weight: 700;
                                                color: var(--gray-800);
                                            }

                                            .card-title i {
                                                color: var(--red);
                                            }

                                            .card-body {
                                                padding: 1.5rem;
                                            }

                                            /* ======= BREADCRUMB ======= */
                                            .breadcrumb {
                                                display: flex;
                                                align-items: center;
                                                gap: 0.4rem;
                                                font-size: 0.82rem;
                                                color: var(--gray-400);
                                            }

                                            .breadcrumb a {
                                                color: var(--red);
                                                text-decoration: none;
                                                font-weight: 500;
                                            }

                                            .breadcrumb a:hover {
                                                text-decoration: underline;
                                            }

                                            .breadcrumb span {
                                                color: var(--gray-600);
                                                font-weight: 500;
                                            }

                                            /* ======= SECTION LABEL ======= */
                                            .section-label {
                                                font-size: 0.7rem;
                                                font-weight: 700;
                                                text-transform: uppercase;
                                                letter-spacing: 0.06em;
                                                color: var(--gray-400);
                                                margin-bottom: 1rem;
                                                display: flex;
                                                align-items: center;
                                                gap: 0.4rem;
                                            }

                                            /* ======= FORM ======= */
                                            .form-grid {
                                                display: grid;
                                                grid-template-columns: 1fr 1fr;
                                                gap: 1rem;
                                            }

                                            .form-group {
                                                display: flex;
                                                flex-direction: column;
                                                gap: 0.4rem;
                                            }

                                            .form-group.full {
                                                grid-column: span 2;
                                            }

                                            .form-label {
                                                font-size: 0.78rem;
                                                font-weight: 600;
                                                color: var(--gray-600);
                                                display: flex;
                                                align-items: center;
                                                gap: 0.3rem;
                                            }

                                            .form-label .required {
                                                color: #dc2626;
                                                font-size: 0.7rem;
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
                                                border-color: var(--red);
                                                background: var(--white);
                                                box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.12);
                                            }

                                            .form-control::placeholder {
                                                color: var(--gray-400);
                                            }

                                            textarea.form-control {
                                                resize: vertical;
                                                min-height: 100px;
                                            }

                                            select.form-control option {
                                                background: var(--white);
                                            }

                                            .form-hint {
                                                font-size: 0.72rem;
                                                color: var(--gray-400);
                                                margin-top: 0.2rem;
                                            }

                                            .form-actions {
                                                display: flex;
                                                justify-content: flex-end;
                                                gap: 0.75rem;
                                                padding: 1.25rem 1.5rem;
                                                border-top: 1px solid var(--gray-100);
                                                background: var(--gray-50);
                                            }

                                            /* ======= BUTTONS ======= */
                                            .btn {
                                                display: inline-flex;
                                                align-items: center;
                                                justify-content: center;
                                                gap: 0.45rem;
                                                padding: 0.7rem 1.4rem;
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

                                            .btn-red {
                                                background: var(--red);
                                                color: #fff;
                                                box-shadow: 0 2px 8px rgba(239, 68, 68, 0.3);
                                            }

                                            .btn-red:hover {
                                                background: var(--red-dark);
                                                box-shadow: 0 4px 14px rgba(220, 38, 38, 0.35);
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

                                            /* ======= INFO BOX ======= */
                                            .info-box {
                                                background: #fff7ed;
                                                border: 1px solid #fed7aa;
                                                border-radius: var(--radius-sm);
                                                padding: 0.9rem 1.1rem;
                                                font-size: 0.82rem;
                                                color: #7c2d12;
                                                display: flex;
                                                align-items: flex-start;
                                                gap: 0.6rem;
                                                line-height: 1.5;
                                            }

                                            .info-box i {
                                                color: #ea580c;
                                                margin-top: 0.1rem;
                                                flex-shrink: 0;
                                            }

                                            /* ======= STOCK BADGE ======= */
                                            .stock-badge {
                                                display: inline-flex;
                                                align-items: center;
                                                gap: 0.35rem;
                                                padding: 0.2rem 0.55rem;
                                                border-radius: 20px;
                                                font-size: 0.72rem;
                                                font-weight: 600;
                                            }

                                            .stock-badge.low {
                                                background: #fff7ed;
                                                color: #c2410c;
                                                border: 1px solid #fed7aa;
                                            }

                                            .stock-badge.ok {
                                                background: #dcfce7;
                                                color: #166534;
                                                border: 1px solid #bbf7d0;
                                            }

                                            .stock-badge.zero {
                                                background: #fee2e2;
                                                color: #991b1b;
                                                border: 1px solid #fecaca;
                                            }

                                            /* ======= PRODUCT SUMMARY ======= */
                                            .product-summary {
                                                display: flex;
                                                align-items: center;
                                                gap: 1rem;
                                                padding: 1rem;
                                                background: var(--gray-50);
                                                border-radius: var(--radius-sm);
                                                border: 1px solid var(--gray-200);
                                                margin-bottom: 0.5rem;
                                            }

                                            .product-summary-img {
                                                width: 56px;
                                                height: 56px;
                                                border-radius: var(--radius-sm);
                                                object-fit: cover;
                                                border: 1px solid var(--gray-200);
                                                flex-shrink: 0;
                                            }

                                            .product-summary-img-placeholder {
                                                width: 56px;
                                                height: 56px;
                                                border-radius: var(--radius-sm);
                                                background: var(--gray-200);
                                                display: flex;
                                                align-items: center;
                                                justify-content: center;
                                                color: var(--gray-400);
                                                font-size: 1.4rem;
                                                flex-shrink: 0;
                                            }

                                            .product-summary-info {
                                                flex: 1;
                                                min-width: 0;
                                            }

                                            .product-summary-name {
                                                font-size: 0.875rem;
                                                font-weight: 600;
                                                color: var(--gray-800);
                                                white-space: nowrap;
                                                overflow: hidden;
                                                text-overflow: ellipsis;
                                            }

                                            .product-summary-meta {
                                                font-size: 0.72rem;
                                                color: var(--gray-400);
                                                margin-top: 0.2rem;
                                                display: flex;
                                                gap: 0.75rem;
                                                flex-wrap: wrap;
                                            }

                                            /* ======= STOCK PREVIEW ======= */
                                            .stock-preview {
                                                background: var(--red-light);
                                                border: 1px solid var(--red-mid);
                                                border-radius: var(--radius-sm);
                                                padding: 0.9rem 1.1rem;
                                                display: flex;
                                                align-items: center;
                                                gap: 0.75rem;
                                                margin-top: 0.5rem;
                                            }

                                            .stock-preview i {
                                                color: var(--red-dark);
                                                font-size: 1rem;
                                                flex-shrink: 0;
                                            }

                                            .stock-preview-text {
                                                font-size: 0.82rem;
                                                color: var(--red-dark);
                                                line-height: 1.5;
                                            }

                                            .stock-preview-text strong {
                                                font-weight: 700;
                                            }

                                            .stock-arrow {
                                                color: var(--red);
                                                font-weight: 700;
                                                margin: 0 0.3rem;
                                            }

                                            .stock-error {
                                                background: #fff7ed;
                                                border: 1px solid #fed7aa;
                                                border-radius: var(--radius-sm);
                                                padding: 0.75rem 1rem;
                                                display: flex;
                                                align-items: center;
                                                gap: 0.5rem;
                                                margin-top: 0.5rem;
                                                font-size: 0.8rem;
                                                color: #c2410c;
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
                                                color: var(--red-dark);
                                                text-decoration: none;
                                            }

                                            .footer-logo i {
                                                color: var(--red);
                                            }

                                            .footer-copy {
                                                font-size: 0.78rem;
                                                color: var(--gray-400);
                                            }

                                            /* ======= RESPONSIVE ======= */
                                            @media (max-width: 900px) {
                                                .layout {
                                                    flex-direction: column;
                                                    padding: 0 1rem;
                                                }

                                                .sidebar {
                                                    width: 100%;
                                                    position: static;
                                                }

                                                .sidebar-nav {
                                                    display: flex;
                                                    flex-wrap: wrap;
                                                    gap: 0.25rem;
                                                }

                                                .sidebar-nav a {
                                                    width: auto;
                                                }
                                            }

                                            @media (max-width: 640px) {
                                                .form-grid {
                                                    grid-template-columns: 1fr;
                                                }

                                                .form-group.full {
                                                    grid-column: span 1;
                                                }

                                                .layout {
                                                    padding: 0 1rem;
                                                }

                                                .topnav {
                                                    padding: 0 1rem;
                                                }

                                                .nav-links {
                                                    display: none;
                                                }
                                            }

                                            /* BATCH CARDS & MODAL CSS */
                                            .product-grid {
                                                display: grid;
                                                grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
                                                gap: 1rem;
                                            }

                                            .batch-card {
                                                background: #fff;
                                                border-radius: var(--radius);
                                                border: 1px solid var(--gray-200);
                                                box-shadow: var(--shadow-sm);
                                                padding: 1rem;
                                                display: flex;
                                                flex-direction: column;
                                                gap: 0.8rem;
                                            }

                                            .batch-header {
                                                display: flex;
                                                align-items: flex-start;
                                                gap: 0.8rem;
                                            }

                                            .batch-img {
                                                width: 50px;
                                                height: 50px;
                                                border-radius: 8px;
                                                object-fit: cover;
                                                border: 1px solid var(--gray-200);
                                            }

                                            .batch-placeholder {
                                                width: 50px;
                                                height: 50px;
                                                border-radius: 8px;
                                                background: var(--gray-100);
                                                display: flex;
                                                align-items: center;
                                                justify-content: center;
                                                font-size: 1.2rem;
                                                color: var(--gray-400);
                                            }

                                            .batch-info {
                                                flex: 1;
                                            }

                                            .batch-title {
                                                font-weight: 600;
                                                font-size: 0.95rem;
                                                color: var(--gray-800);
                                                margin-bottom: 0.2rem;
                                            }

                                            .batch-stats {
                                                font-size: 0.8rem;
                                                color: var(--gray-600);
                                            }

                                            .batch-stats span {
                                                display: inline-block;
                                                margin-right: 0.5rem;
                                                margin-bottom: 0.2rem;
                                            }

                                            .batch-stats strong {
                                                color: var(--gray-800);
                                            }

                                            .status-expired {
                                                color: #dc2626;
                                                font-weight: 600;
                                            }

                                            .status-expiring {
                                                color: #c2410c;
                                                font-weight: 600;
                                            }

                                            .batch-action {
                                                margin-top: auto;
                                            }

                                            .btn-export-card {
                                                width: 100%;
                                                background: var(--red);
                                                color: #fff;
                                                border: none;
                                                padding: 0.6rem;
                                                border-radius: 8px;
                                                font-size: 0.85rem;
                                                font-weight: 600;
                                                cursor: pointer;
                                                transition: all 0.2s;
                                                display: flex;
                                                align-items: center;
                                                justify-content: center;
                                                gap: 0.4rem;
                                            }

                                            .btn-export-card:hover {
                                                background: var(--red-dark);
                                            }

                                            /* MODAL CSS */
                                            .modal-overlay {
                                                position: fixed;
                                                top: 0;
                                                left: 0;
                                                right: 0;
                                                bottom: 0;
                                                background: rgba(0, 0, 0, 0.5);
                                                display: none;
                                                align-items: center;
                                                justify-content: center;
                                                z-index: 9999;
                                                backdrop-filter: blur(3px);
                                            }

                                            .modal-overlay.active {
                                                display: flex;
                                            }

                                            .modal-content {
                                                background: #fff;
                                                width: 100%;
                                                max-width: 500px;
                                                border-radius: var(--radius);
                                                padding: 1.5rem;
                                                box-shadow: var(--shadow);
                                                position: relative;
                                                animation: modalFadeIn 0.3s ease-out;
                                            }

                                            @keyframes modalFadeIn {
                                                from {
                                                    opacity: 0;
                                                    transform: translateY(-20px);
                                                }

                                                to {
                                                    opacity: 1;
                                                    transform: translateY(0);
                                                }
                                            }

                                            .modal-close {
                                                position: absolute;
                                                top: 1rem;
                                                right: 1.5rem;
                                                font-size: 1.2rem;
                                                color: var(--gray-400);
                                                cursor: pointer;
                                                background: none;
                                                border: none;
                                            }

                                            .modal-close:hover {
                                                color: var(--gray-800);
                                            }

                                            .modal-header {
                                                margin-bottom: 1rem;
                                                padding-bottom: 0.8rem;
                                                border-bottom: 1px solid var(--gray-200);
                                                font-weight: 700;
                                                font-size: 1.1rem;
                                                display: flex;
                                                align-items: center;
                                                gap: 0.5rem;
                                                color: var(--gray-800);
                                            }

                                            .modal-product-name {
                                                font-size: 0.9rem;
                                                font-weight: 600;
                                                color: var(--red);
                                                margin-bottom: 1rem;
                                                padding: 0.5rem;
                                                background: var(--red-light);
                                                border-radius: 6px;
                                                border: 1px dashed var(--red-mid);
                                            }
                                        </style>
                                    </head>

                                    <body>

                                        <jsp:include page="/sidebar.jsp">
                                            <jsp:param name="activePage" value="inventory" />
                                        </jsp:include>

                                        <!-- MAIN -->
                                        <main class="sena-main">

                                            
                                            <!-- Alerts -->
                                            <% if (message !=null) { %>
                                                <div class="alert alert-success">
                                                    <i class="fa-solid fa-circle-check"></i>
                                                    <span>
                                                        <%= message %>
                                                    </span>
                                                </div>
                                                <% } %>
                                                    <% if (error !=null) { %>
                                                        <div class="alert alert-danger">
                                                            <i class="fa-solid fa-circle-exclamation"></i>
                                                            <span>
                                                                <%= error %>
                                                            </span>
                                                        </div>
                                                        <% } %>

                                                            <!-- Form -->
                                                            <!-- Danh sach the san pham sap het han -->
                                                            <div style="background: var(--white); padding: 1.2rem 1.5rem; border-radius: var(--radius); border: 1px solid var(--gray-200); box-shadow: var(--shadow-sm); display: flex; align-items: center; gap: 0.8rem; margin-bottom: 1.5rem;">
                                                                <div style="width: 40px; height: 40px; border-radius: 8px; background: var(--red-light); display: flex; align-items: center; justify-content: center; color: var(--red); font-size: 1.2rem;">
                                                                    <i class="fa-solid fa-box-open"></i>
                                                                </div>
                                                                <div>
                                                                    <h2 style="font-size: 1.1rem; font-weight: 700; color: var(--gray-800); margin: 0 0 0.2rem 0;">Sản Phẩm Cần Xuất Kho</h2>
                                                                    <p style="font-size: 0.85rem; color: var(--gray-400); margin: 0;">Chọn các sản phẩm bên dưới để ghi nhận xuất kho</p>
                                                                </div>
                                                            </div>
                                                            <div class="product-grid">
                                                                <% if (batches !=null && !batches.isEmpty()) { for
                                                                    (java.util.Map<String, Object> batch : batches) { 
                                                                    int stock = (Integer) batch.get("quantity"); 
                                                                    int productId = (Integer) batch.get("productId");
                                                                    java.sql.Timestamp expDate = (java.sql.Timestamp) batch.get("expiredDate");
                                                                    
                                                                    String expStr="Không có HSD" ; String statusClass=""
                                                                    ; String statusLabel="" ; String expStrForInput = "";
                                                                    if (expDate !=null) {
                                                                    expStrForInput = sdfSql.format(expDate);
                                                                    expStr=sdfExp.format(expDate); long
                                                                    diffMs=expDate.getTime() - now.getTime(); long
                                                                    diffDays=diffMs / (1000L * 60 * 60 * 24); if (diffMs
                                                                    < 0) { statusClass="status-expired" ;
                                                                    statusLabel="Đã hết hạn" ; } else if (diffDays <=7)
                                                                    { statusClass="status-expiring" ;
                                                                    statusLabel="Sắp hết hạn" ; } } String
                                                                    unit=batch.get("unit") !=null ? (String) batch.get("unit") : "" ; String
                                                                    safeTitle=batch.get("title") !=null ?
                                                                    ((String) batch.get("title")).replace("\"", "&quot;"
                                                                    ).replace("'", "\\'" ) : "" ; String
                                                                    imgUrl=batch.get("image") !=null ?
                                                                    ImageUrlUtil.resolve((String) batch.get("image"),
                                                                    request.getContextPath()) : "" ; %>
                                                                    <!-- Batch Card -->
                                                                    <div class="batch-card">
                                                                        <div class="batch-header">
                                                                            <% if (!imgUrl.isEmpty()) { %>
                                                                                <img src="<%= imgUrl %>"
                                                                                    alt="<%= safeTitle %>"
                                                                                    class="batch-img">
                                                                                <% } else { %>
                                                                                    <div class="batch-placeholder">
                                                                                        <i
                                                                                            class="fa-solid fa-box-open"></i>
                                                                                    </div>
                                                                                    <% } %>
                                                                                        <div class="batch-info">
                                                                                            <div class="batch-title">
                                                                                                <%= safeTitle %>
                                                                                            </div>
                                                                                            <div class="batch-stats">
                                                                                                <span>HSD:
                                                                                                    <strong>
                                                                                                        <%= expStr %>
                                                                                                    </strong></span>
                                                                                                <br />
                                                                                                <span>Tồn: <strong
                                                                                                        style="color:var(--red);"><%=
                                                                                                            stock %>
                                                                                                            <%= unit
                                                                                                                %></strong></span>
                                                                                                <% if
                                                                                                    (!statusLabel.isEmpty())
                                                                                                    { %>
                                                                                                    <span
                                                                                                        class="<%= statusClass %>"
                                                                                                        style="display:block;margin-top:2px;">
                                                                                                        <%= statusLabel
                                                                                                            %>
                                                                                                    </span>
                                                                                                    <% } %>
                                                                                            </div>
                                                                                        </div>
                                                                        </div>
                                                                        <div class="batch-action">
                                                                            <button type="button"
                                                                                class="btn-export-card"
                                                                                onclick="openExportModal(<%= productId %>, '<%= safeTitle %>', <%= stock %>, '<%= unit %>', '<%= expStrForInput %>')">
                                                                                <i class="fa-solid fa-arrow-right-from-bracket"
                                                                                    style="font-size:0.8rem;"></i>
                                                                                Xuất kho lô này
                                                                            </button>
                                                                        </div>
                                                                    </div>
                                                                    <% } } else { %>
                                                                        <div
                                                                            style="grid-column: 1 / -1; padding: 2rem; text-align: center; color: var(--gray-400); background: var(--white); border-radius: var(--radius); border: 1px dashed var(--gray-200);">
                                                                            <i class="fa-solid fa-box-open"
                                                                                style="font-size: 2rem; margin-bottom: 0.5rem;"></i>
                                                                            <p>Chưa có lô hàng nào cần xuất kho</p>
                                                                        </div>
                                                                        <% } %>
                                                            </div>

                                                            <!-- MODAL XUAT KHO -->
                                                            <div id="exportModal" class="modal-overlay">
                                                                <div class="modal-content">
                                                                    <button class="modal-close" type="button"
                                                                        onclick="closeExportModal()"><i
                                                                            class="fa-solid fa-xmark"></i></button>
                                                                    <div class="modal-header">
                                                                        <i class="fa-solid fa-warehouse"
                                                                            style="color:var(--red);"></i>
                                                                        Thông Tin Xuất Kho
                                                                    </div>
                                                                    <div class="modal-product-name"
                                                                        id="modalProductName"></div>

                                                                    <form action="inventory-export" method="POST"
                                                                        id="exportForm"
                                                                        onsubmit="return validateExport();">
                                                                        <input type="hidden" name="productId" id="modalProductId"
                                                            value="">
                                                        <input type="hidden" name="expiredDate" id="modalExpiredDate"
                                                            value="">
                                                        <input type="hidden" id="modalMaxStock" value="0">

                                                                        <div class="form-group"
                                                                            style="margin-bottom:1rem;">
                                                                            <label class="form-label">Số lượng xuất
                                                                                <span class="required">*</span></label>
                                                                            <input type="number" name="quantity"
                                                                                id="quantityInput" class="form-control"
                                                                                placeholder="VD: 10" min="1" step="1"
                                                                                required oninput="validateModalStock()">
                                                                            <span class="form-hint"
                                                                                id="modalStockHint">Số lượng không vượt
                                                                                quá tồn kho.</span>
                                                                            <div id="stockError" class="stock-error"
                                                                                style="display:none; margin-top:0.5rem; font-size:0.8rem; padding:0.5rem;">
                                                                                <i
                                                                                    class="fa-solid fa-circle-exclamation"></i>
                                                                                <span id="stockErrorText"></span>
                                                                            </div>
                                                                        </div>

                                                                        <div class="form-group"
                                                                            style="margin-bottom:1.5rem;">
                                                                            <label class="form-label">Ghi chú</label>
                                                                            <input type="text" name="note"
                                                                                id="noteInput" class="form-control"
                                                                                placeholder="VD: Bán cho khách hàng A">
                                                                        </div>

                                                                        <div class="form-actions">
                                                                            <button type="button"
                                                                                class="btn btn-outline"
                                                                                onclick="closeExportModal()">Hủy</button>
                                                                            <button type="submit" class="btn btn-red"
                                                                                id="btnSubmit">
                                                                                <i class="fa-solid fa-floppy-disk"></i>
                                                                                Xác Nhận Xuất
                                                                            </button>
                                                                        </div>
                                                                    </form>
                                                                </div>
                                                            </div>

                                        </main>
                                        </div><!-- /layout -->

                                        <!-- ====== FOOTER ====== -->
                                        <footer class="footer">
                                            <a href="home.jsp" class="footer-logo"><i
                                                    class="fa-solid fa-apple-whole"></i> SenaFruit</a>
                                            <span class="footer-copy">&copy; 2024 SenaFruit. Trái cây tươi
                                                ngon mỗi ngày.</span>
                                        </footer>

                                        <script>
                                            (function () {
                                                var exportModal = document.getElementById('exportModal');
                                                var modalProductId = document.getElementById('modalProductId');
                                                var modalExpiredDate = document.getElementById('modalExpiredDate');
                                                var modalMaxStock = document.getElementById('modalMaxStock');
                                                var modalProductName = document.getElementById('modalProductName');
                                                var quantityInput = document.getElementById('quantityInput');
                                                var stockError = document.getElementById('stockError');
                                                var stockErrorText = document.getElementById('stockErrorText');
                                                var btnSubmit = document.getElementById('btnSubmit');

                                                window.openExportModal = function (productId, title, stock, unit, expiredDateStr) {
                                                    modalProductId.value = productId;
                                                    modalExpiredDate.value = expiredDateStr;
                                                    modalMaxStock.value = stock;
                                                    modalProductName.innerHTML = title + ' <span style="color:var(--gray-600); font-size:0.85rem; font-weight:normal;">(Tồn: ' + stock + ' ' + unit + ')</span>';
                                                    quantityInput.value = '';
                                                    quantityInput.max = stock;
                                                    stockError.style.display = 'none';
                                                    btnSubmit.disabled = false;
                                                    exportModal.classList.add('active');
                                                };

                                                window.closeExportModal = function () {
                                                    exportModal.classList.remove('active');
                                                };

                                                window.validateModalStock = function () {
                                                    var max = parseInt(modalMaxStock.value || '0');
                                                    var qty = parseInt(quantityInput.value || '0');
                                                    if (qty > max) {
                                                        stockError.style.display = 'block';
                                                        stockErrorText.textContent = 'Vượt quá tồn kho (' + max + ')';
                                                        btnSubmit.disabled = true;
                                                    } else {
                                                        stockError.style.display = 'none';
                                                        btnSubmit.disabled = false;
                                                    }
                                                };

                                                window.validateExport = function () {
                                                    var max = parseInt(modalMaxStock.value || '0');
                                                    var qty = parseInt(quantityInput.value || '0');
                                                    if (qty <= 0) {
                                                        alert('Số lượng phải lớn hơn 0.');
                                                        return false;
                                                    }
                                                    if (qty > max) {
                                                        alert('Số lượng vượt quá tồn kho hiện có.');
                                                        return false;
                                                    }
                                                    btnSubmit.disabled = true;
                                                    btnSubmit.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang xử lý...';
                                                    return true;
                                                };

                                                // Close modal on click outside
                                                window.onclick = function (event) {
                                                    if (event.target == exportModal) {
                                                        closeExportModal();
                                                    }
                                                }
                                            })();
                                        </script>

                                    </body>

                                    </html>