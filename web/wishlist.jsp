<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    Customer user = (Customer) session.getAttribute("user");
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

    String error = (String) session.getAttribute("error");
    String message = (String) session.getAttribute("message");
    if (error != null) session.removeAttribute("error");
    if (message != null) session.removeAttribute("message");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh Sách Yêu Thích | Sena Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        /* (Giữ nguyên CSS từ template chuẩn của project) */
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
            background: var(--white); border-bottom: 1px solid var(--gray-200);
            height: 60px; display: flex; align-items: center; padding: 0 2rem; gap: 2rem;
            position: sticky; top: 0; z-index: 100; box-shadow: var(--shadow-sm);
        }
        .nav-logo { display: flex; align-items: center; gap: 0.5rem; font-size: 1.3rem; font-weight: 800; color: var(--green-dark); text-decoration: none; }
        .nav-logo i { color: var(--green); }
        .nav-links { display: flex; gap: 0.25rem; margin-left: 1rem; }
        .nav-links a { padding: 0.4rem 0.85rem; border-radius: 6px; font-size: 0.875rem; font-weight: 500; color: var(--gray-600); text-decoration: none; transition: all 0.15s; }
        .nav-links a:hover { background: var(--green-light); color: var(--green-dark); }
        .nav-right { margin-left: auto; display: flex; align-items: center; gap: 0.75rem; }
        .nav-icon-btn { width: 38px; height: 38px; border-radius: 50%; background: var(--gray-100); border: none; display: flex; align-items: center; justify-content: center; color: var(--gray-600); cursor: pointer; transition: background 0.15s; }
        .nav-icon-btn:hover { background: var(--green-light); color: var(--green-dark); }
        .nav-avatar { width: 38px; height: 38px; border-radius: 50%; object-fit: cover; border: 2px solid var(--green); }

        /* ======= LAYOUT & SIDEBAR ======= */
        .layout { display: flex; flex: 1; max-width: 1280px; width: 100%; margin: 1.5rem auto; padding: 0 1.5rem; gap: 1.5rem; align-items: flex-start; }
        .sidebar { width: 200px; flex-shrink: 0; background: var(--white); border-radius: var(--radius); box-shadow: var(--shadow-sm); border: 1px solid var(--gray-200); position: sticky; top: 76px; }
        .sidebar-nav { padding: 0.5rem; }
        .sidebar-nav a { display: flex; align-items: center; gap: 0.65rem; padding: 0.65rem 0.9rem; border-radius: var(--radius-sm); font-size: 0.875rem; font-weight: 500; color: var(--gray-600); text-decoration: none; transition: all 0.15s; }
        .sidebar-nav a:hover { background: var(--green-light); color: var(--green-dark); }
        .sidebar-nav a.active { background: var(--green); color: #fff; font-weight: 600; }
        .sidebar-nav a.logout { color: #e53e3e; }

        /* ======= MAIN CONTENT ======= */
        .main { flex: 1; display: flex; flex-direction: column; gap: 1.25rem; min-width: 0; }
        .alert { display: flex; align-items: center; gap: 0.75rem; padding: 0.9rem 1.2rem; border-radius: var(--radius-sm); font-size: 0.875rem; font-weight: 500; }
        .alert-danger { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }
        .alert-success { background: #dcfce7; border: 1px solid #bbf7d0; color: #166534; }
        .card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--gray-200); box-shadow: var(--shadow-sm); overflow: hidden; }
        .card-header { display: flex; align-items: center; justify-content: space-between; padding: 1.1rem 1.5rem; border-bottom: 1px solid var(--gray-100); }
        .card-title { display: flex; align-items: center; gap: 0.5rem; font-size: 1.1rem; font-weight: 700; color: var(--gray-800); }
        .card-title i { color: #e21b1b; }

        /* ======= BUTTONS ======= */
        .btn { display: inline-flex; align-items: center; justify-content: center; gap: 0.45rem; padding: 0.65rem 1.3rem; border-radius: var(--radius-sm); font-size: 0.875rem; font-weight: 600; cursor: pointer; border: none; text-decoration: none; }
        .btn-green { background: var(--green); color: #fff; }
        .btn-green:hover { background: var(--green-dark); }
        .btn-outline { background: var(--white); color: var(--gray-600); border: 1.5px solid var(--gray-200); }
        .btn-danger { background: #fee2e2; color: #dc2626; border: 1px solid #fecaca; }
        .btn-danger:hover { background: #fecaca; color: #991b1b; }

        /* ======= TABLE ======= */
        .table-wrap { overflow-x: auto; padding: 1rem; }
        .product-table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
        .product-table th { background: var(--gray-50); padding: 0.85rem 1rem; text-align: left; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; color: var(--gray-600); border-bottom: 2px solid var(--gray-200); }
        .product-table td { padding: 1rem; border-bottom: 1px solid var(--gray-100); vertical-align: middle; }
        
        .product-info { display: flex; align-items: center; gap: 1rem; }
        .product-img { width: 60px; height: 60px; border-radius: 8px; object-fit: cover; border: 1px solid var(--gray-200); }
        .product-title { font-weight: 600; color: var(--gray-800); }
        .price { font-weight: 600; color: #dc2626; }
        .badge-green { background: #dcfce7; color: #166534; padding: 0.2rem 0.6rem; border-radius: 100px; font-size: 0.75rem; font-weight: bold; }
        .badge-red { background: #fee2e2; color: #991b1b; padding: 0.2rem 0.6rem; border-radius: 100px; font-size: 0.75rem; font-weight: bold; }

        .empty-state { text-align: center; padding: 3rem 1.5rem; color: var(--gray-400); }
        .empty-state i { font-size: 3rem; margin-bottom: 0.75rem; display: block; color: #fecaca; }
        
        .footer { background: var(--white); border-top: 1px solid var(--gray-200); padding: 1.2rem 2rem; text-align: center; color: var(--gray-400); font-size: 0.85rem; margin-top: auto;}
    </style>
</head>
<body>

<nav class="topnav">
    <a href="home.jsp" class="nav-logo"><i class="fa-solid fa-apple-whole"></i> Sena Shop</a>
    <div class="nav-links">
        <a href="home.jsp">Trang Chủ</a>
        <a href="products">Sản Phẩm</a>
    </div>
    <div class="nav-right">
        <a href="cart" class="nav-icon-btn"><i class="fa-solid fa-basket-shopping"></i></a>
        <img class="nav-avatar" src="<%= avatarUrl %>" alt="avatar">
    </div>
</nav>

<div class="layout">
    <aside class="sidebar">
        <div class="sidebar-nav">
            <a href="profile"><i class="fa-regular fa-user"></i> Hồ Sơ</a>
            <a href="products"><i class="fa-brands fa-opencart"></i> Sản Phẩm</a>
            <a href="cart"><i class="fa-solid fa-basket-shopping"></i> Giỏ Hàng</a>
            <a href="wishlist" class="active"><i class="fa-solid fa-heart"></i> Yêu Thích</a>
            <a href="logout" class="logout" style="margin-top:0.5rem;"><i class="fa-solid fa-right-from-bracket"></i> Đăng Xuất</a>
        </div>
    </aside>

    <main class="main">
        <% if (error != null) { %>
        <div class="alert alert-danger"><i class="fa-solid fa-circle-exclamation"></i><span><%= error %></span></div>
        <% } %>
        <% if (message != null) { %>
        <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i><span><%= message %></span></div>
        <% } %>

        <div class="card">
            <div class="card-header">
                <div class="card-title"><i class="fa-solid fa-heart"></i> Danh Sách Yêu Thích</div>
            </div>

            <c:choose>
                <c:when test="${not empty wishlist}">
                    <div class="table-wrap">
                        <table class="product-table">
                            <thead>
                                <tr>
                                    <th>Sản Phẩm</th>
                                    <th>Giá</th>
                                    <th>Trạng Thái</th>
                                    <th>Hành Động</th>
                                    <th>Xóa</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="item" items="${wishlist}">
                                    <tr>
                                        <td>
                                            <div class="product-info">
                                                <img class="product-img" src="${item.product.image != null ? item.product.image : 'https://placehold.co/60x60'}" alt="img">
                                                <div class="product-title">${item.product.title}</div>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="price"><fmt:formatNumber value="${item.product.salePrice}" pattern="#,##0" /> đ</span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${item.product.stockQuantity > 0}">
                                                    <span class="badge-green">Còn Hàng</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-red">Hết Hàng</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:if test="${item.product.stockQuantity > 0}">
                                                <form action="wishlist" method="POST">
                                                    <input type="hidden" name="action" value="moveToCart">
                                                    <input type="hidden" name="productId" value="${item.product.id}">
                                                    <button type="submit" class="btn btn-green" style="padding: 0.4rem 0.8rem; font-size: 0.8rem;">
                                                        <i class="fa-solid fa-cart-plus"></i> Thêm Vào Giỏ
                                                    </button>
                                                </form>
                                            </c:if>
                                        </td>
                                        <td>
                                            <form action="wishlist" method="POST">
                                                <input type="hidden" name="action" value="remove">
                                                <input type="hidden" name="productId" value="${item.product.id}">
                                                <button type="submit" class="btn btn-danger" title="Bỏ yêu thích"><i class="fa-solid fa-heart-crack"></i></button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <i class="fa-regular fa-heart"></i>
                        <p>Bạn chưa có sản phẩm yêu thích nào.</p>
                        <a href="products" class="btn btn-green" style="margin-top: 1rem;">Khám Phá Trái Cây</a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>

<footer class="footer">
    &copy; 2024 Sena Shop. Trái cây tươi ngon mỗi ngày.
</footer>

</body>
</html>
