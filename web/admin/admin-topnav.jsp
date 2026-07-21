<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%
    Account adminUser = (Account) session.getAttribute("Account");
    String activePage = request.getParameter("activePage");
    String ctx = request.getContextPath();
    
    String adminAvatarUrl = adminUser != null ? adminUser.getAvatar() : null;
    if (adminAvatarUrl == null || adminAvatarUrl.trim().isEmpty()) {
        String fn = adminUser != null && adminUser.getFullname() != null ? adminUser.getFullname() : (adminUser != null ? adminUser.getUsername() : "Admin");
        adminAvatarUrl = "https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(fn, "UTF-8") + "&background=4caf50&color=fff&size=80&bold=true&rounded=true";
    }
%>
<style>
    /* Admin Topnav Styles */
    .admin-topnav {
        background: #ffffff;
        border-bottom: 1px solid #eef1ee;
        height: 64px;
        display: flex;
        align-items: center;
        padding: 0 2rem;
        gap: 1.5rem;
        position: sticky;
        top: 0;
        z-index: 1000;
        box-shadow: 0 1px 3px rgba(0,0,0,.04);
        font-family: 'Inter', sans-serif;
    }
    .admin-nav-logo {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        font-size: 1.25rem;
        font-weight: 800;
        color: #388e3c;
        text-decoration: none;
        white-space: nowrap;
        margin-right: 1rem;
    }
    .admin-nav-logo i { color: #4caf50; font-size: 1.4rem; }
    
    .admin-nav-links {
        display: flex;
        align-items: center;
        gap: 0.25rem;
        flex: 1;
    }
    .admin-nav-links a {
        padding: 0.5rem 0.85rem;
        border-radius: 8px;
        font-size: 0.85rem;
        font-weight: 600;
        color: #5a6a5a;
        text-decoration: none;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        gap: 0.4rem;
        white-space: nowrap;
    }
    .admin-nav-links a:hover {
        color: #388e3c;
        background: #f8fafb;
    }
    .admin-nav-links a.active {
        background: #e8f5e9;
        color: #388e3c;
    }
    .admin-nav-links a i {
        font-size: 0.9rem;
    }
    
    .admin-nav-right {
        margin-left: auto;
        display: flex;
        align-items: center;
        gap: 1rem;
    }
    .admin-nav-user-info {
        display: flex;
        align-items: center;
        gap: 0.75rem;
    }
    .admin-nav-username {
        font-size: 0.85rem;
        font-weight: 600;
        color: #2d3d2d;
    }
    .admin-nav-avatar {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        object-fit: cover;
    }
</style>

<nav class="admin-topnav">
    <a href="<%= ctx %>/home.jsp" class="admin-nav-logo">
        <i class="fa-solid fa-apple-whole"></i> Sena Shop
    </a>
    <div class="admin-nav-links">
        <a href="<%= ctx %>/home.jsp" class="<%= "home".equals(activePage) ? "active" : "" %>">
            Trang Chủ
        </a>
        <a href="<%= ctx %>/products" class="<%= "products".equals(activePage) ? "active" : "" %>">
            Sản Phẩm
        </a>
        <a href="<%= ctx %>/admin/customers" class="<%= "customers".equals(activePage) ? "active" : "" %>">
            Khách Hàng
        </a>
        <a href="<%= ctx %>/admin/orders" class="<%= "orders".equals(activePage) ? "active" : "" %>">
            Monitor Đơn Hàng
        </a>
        <a href="<%= ctx %>/admin/seller-requests" class="<%= "seller-requests".equals(activePage) ? "active" : "" %>">
            Duyệt Seller
        </a>
        <a href="<%= ctx %>/admin/sellers" class="<%= "sellers".equals(activePage) ? "active" : "" %>">
            Quản Lý Sellers
        </a>
        <a href="<%= ctx %>/admin/approve-products" class="<%= "approve-products".equals(activePage) ? "active" : "" %>">
            Duyệt Sản Phẩm
        </a>
    </div>
    <div class="admin-nav-right">
        <div class="admin-nav-user-info">
            <span class="admin-nav-username">Admin: <%= adminUser != null && adminUser.getFullname() != null ? adminUser.getFullname() : "Quản Trị Viên" %></span>
            <img class="admin-nav-avatar" src="<%= adminAvatarUrl %>" alt="avatar">
        </div>
    </div>
</nav>
