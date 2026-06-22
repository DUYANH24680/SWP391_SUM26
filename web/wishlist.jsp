<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Wishlist" %>
<%@ page import="model.WishlistItem" %>
<%@ page import="model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    Wishlist wishlist = (Wishlist) request.getAttribute("wishlist");
    if (wishlist == null) {
        wishlist = new Wishlist();
    }
    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Wishlist | Sena Shop</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { margin: 0; font-family: 'Inter', sans-serif; background: #f7faf7; color: #2d3d2d; }
        .container { max-width: 1100px; margin: 0 auto; padding: 1.5rem; }
        .header { display: flex; align-items: center; justify-content: space-between; gap: 1rem; margin-bottom: 1rem; }
        .title { font-size: 2rem; font-weight: 700; }
        .breadcrumb { color: #6b7280; font-size: 0.95rem; }
        .breadcrumb a { color: #16a34a; text-decoration: none; }
        .alert { border-radius: 12px; padding: 1rem 1.2rem; margin-bottom: 1rem; }
        .alert-success { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
        .alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
        .wishlist-card { background: #fff; border-radius: 20px; box-shadow: 0 10px 30px rgba(15,23,42,.08); padding: 1.5rem; }
        .wishlist-item { display: grid; grid-template-columns: 100px 1fr 140px 140px; gap: 1rem; align-items: center; padding: 1rem 0; border-bottom: 1px solid #e5e7eb; }
        .wishlist-item:last-child { border-bottom: none; }
        .item-image { width: 100px; height: 100px; border-radius: 18px; overflow: hidden; background: #f3f4f6; display: flex; align-items: center; justify-content: center; }
        .item-image img { width: 100%; height: 100%; object-fit: cover; }
        .item-details { display: grid; gap: 0.4rem; }
        .item-title { font-size: 1rem; font-weight: 700; }
        .item-meta { color: #6b7280; font-size: 0.92rem; }
        .item-actions { display: flex; flex-wrap: wrap; gap: 0.5rem; justify-content: flex-end; }
        .btn { border: none; border-radius: 999px; cursor: pointer; font-weight: 600; transition: transform 0.15s ease; }
        .btn:hover { transform: translateY(-1px); }
        .btn-primary { background: #16a34a; color: #fff; padding: 0.8rem 1rem; }
        .btn-secondary { background: #f3f4f6; color: #374151; padding: 0.8rem 1rem; }
        .btn-danger { background: #ef4444; color: #fff; padding: 0.8rem 1rem; }
        .empty-state { text-align: center; padding: 3rem 1rem; color: #4b5563; }
        .empty-state h2 { margin-bottom: 0.75rem; font-size: 1.5rem; }
        .summary-box { margin-top: 1.5rem; background: #ecfdf5; border: 1px solid #d1fae5; border-radius: 18px; padding: 1.25rem; display: grid; gap: 0.65rem; }
        .summary-row { display: flex; justify-content: space-between; color: #111827; font-weight: 600; }
        @media (max-width: 900px) {
            .wishlist-item { grid-template-columns: 1fr; }
            .item-actions { justify-content: flex-start; }
        }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <div>
            <div class="breadcrumb"><a href="home.jsp">Trang chủ</a> / Wishlist</div>
            <div class="title">Wishlist của bạn</div>
        </div>
        <a href="home.jsp" class="btn btn-secondary">Tiếp tục mua sắm</a>
    </div>

    <% if (message != null) { %>
    <div class="alert alert-success"><%= message %></div>
    <% } %>
    <% if (error != null) { %>
    <div class="alert alert-error"><%= error %></div>
    <% } %>

    <div class="wishlist-card">
        <% if (wishlist.isEmpty()) { %>
            <div class="empty-state">
                <h2>Wishlist đang trống</h2>
                <p>Hãy thêm sản phẩm yêu thích để lưu lại và chuyển vào giỏ hàng sau.</p>
            </div>
        <% } else { %>
            <div class="summary-box">
                <div class="summary-row"><span>Tổng sản phẩm</span><span><%= wishlist.getTotalItems() %></span></div>
            </div>
            <% for (WishlistItem item : wishlist.getItems()) { %>
            <div class="wishlist-item">
                <div class="item-image">
                    <% if (item.getImage() != null && !item.getImage().trim().isEmpty()) { %>
                        <img src="<%= item.getImage() %>" alt="<%= item.getTitle() %>">
                    <% } else { %>
                        <span style="font-size:1.5rem;">🍎</span>
                    <% } %>
                </div>
                <div class="item-details">
                    <div class="item-title"><%= item.getTitle() != null ? item.getTitle() : "Sản phẩm" %></div>
                    <div class="item-meta">Giá: <strong><%= String.format("%,.0f", item.getUnitPrice()) %> đ</strong></div>
                    <div class="item-meta">Tồn kho: <strong><%= item.getStockQuantity() %></strong></div>
                </div>
                <div class="item-actions">
                    <button class="btn btn-primary" data-wishlist-action="move" data-product-id="<%= item.getProductId() %>">Move To Cart</button>
                    <button class="btn btn-danger" data-wishlist-action="remove" data-product-id="<%= item.getProductId() %>">Remove</button>
                </div>
            </div>
            <% } %>
        <% } %>
    </div>
</div>
<script src="js/wishlist.js"></script>
</body>
</html>
