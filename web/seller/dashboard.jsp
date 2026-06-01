<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Product" %>
<%@ page import="model.Customer" %>
<%@ page import="model.Seller" %>
<%@ page import="java.util.List" %>
<%
    Object sessionAccount = session.getAttribute("account");
    Object sessionUser = session.getAttribute("user");

    Object user = null;
    boolean isSeller = false;

    if (sessionAccount instanceof Seller) {
        user = (Seller) sessionAccount;
        isSeller = true;
    } else if (sessionUser instanceof Seller) {
        user = (Seller) sessionUser;
        isSeller = true;
    } else if (sessionUser instanceof Customer) {
        user = (Customer) sessionUser;
        isSeller = false;
    }

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String displayName = "";
    String avatarUrl = "";
    if (user instanceof Seller) {
        Seller s = (Seller) user;
        displayName = s.getFullname() != null ? s.getFullname() : s.getUsername();
        avatarUrl = s.getAvatar() != null ? s.getAvatar() : "";
    } else if (user instanceof Customer) {
        Customer c = (Customer) user;
        displayName = c.getFullname() != null ? c.getFullname() : c.getUsername();
        avatarUrl = c.getAvatar() != null ? c.getAvatar() : "";
    }

    if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
        String dn = (displayName != null && !displayName.trim().isEmpty()) ? displayName : "User";
        avatarUrl = "https://ui-avatars.com/api/?name="
                  + java.net.URLEncoder.encode(dn, "UTF-8")
                  + "&background=4caf50&color=fff&size=160&bold=true&rounded=true";
    }

    int totalProducts = (Integer) request.getAttribute("totalProducts");
    int totalStock = (Integer) request.getAttribute("totalStock");
    int totalSold = (Integer) request.getAttribute("totalSold");
    int activeProducts = (Integer) request.getAttribute("activeProducts");
    String sellerName = (String) request.getAttribute("sellerName");
    List<Product> products = (List<Product>) request.getAttribute("products");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard | Sena Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/seller.css">
</head>
<body>

<nav class="topnav">
    <a href="<%= request.getContextPath() %>/home.jsp" class="nav-logo"><i class="fa-solid fa-apple-whole"></i> Sena Shop</a>
    <div class="nav-links">
        <a href="<%= request.getContextPath() %>/home.jsp">Trang Chu</a>
        <a href="#">San Pham</a>
        <a href="#">Don Hang</a>
        <a href="#" class="active">Quan Ly</a>
    </div>
    <div class="nav-right">
        <button class="nav-icon-btn" title="Thong bao"><i class="fa-regular fa-bell"></i></button>
        <a href="<%= request.getContextPath() %>/profile"><img class="nav-avatar" src="<%= avatarUrl %>" alt="avatar"></a>
    </div>
</nav>

<div class="layout">
    <aside class="sidebar">
        <div class="sidebar-user">
            <div class="sidebar-user-row">
                <img class="sidebar-user-avatar" src="<%= avatarUrl %>" alt="avatar">
                <div><div class="sidebar-welcome"><%= displayName.split(" ")[displayName.split(" ").length - 1] %></div></div>
            </div>
            <div class="sidebar-role-text">Nhan Vien Ban Hang</div>
        </div>
        <div class="sidebar-nav">
            <a href="<%= request.getContextPath() %>/seller/dashboard" class="active"><i class="fa-solid fa-chart-line"></i> Tong Quan</a>
            <a href="<%= request.getContextPath() %>/seller/add-product"><i class="fa-solid fa-plus-circle"></i> Them San Pham</a>
            <a href="<%= request.getContextPath() %>/seller/products"><i class="fa-solid fa-box-open"></i> Quan Ly San Pham</a>
            <a href="<%= request.getContextPath() %>/seller/orders"><i class="fa-solid fa-receipt"></i> Don Hang</a>
            <a href="<%= request.getContextPath() %>/profile"><i class="fa-regular fa-user"></i> Ho So</a>
        </div>
    </aside>

    <main class="main">
        <div class="stat-grid">
            <div class="stat-card">
                <div class="stat-icon green"><i class="fa-solid fa-box-open"></i></div>
                <div class="stat-number"><%= totalProducts %></div>
                <div class="stat-label">Tong San Pham</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon orange"><i class="fa-solid fa-eye"></i></div>
                <div class="stat-number"><%= activeProducts %></div>
                <div class="stat-label">Dang Hien Thi</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon blue"><i class="fa-solid fa-boxes-stacked"></i></div>
                <div class="stat-number"><%= totalStock %></div>
                <div class="stat-label">Ton Kho</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon purple"><i class="fa-solid fa-bag-shopping"></i></div>
                <div class="stat-number"><%= totalSold %></div>
                <div class="stat-label">Da Ban</div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <div class="card-title"><i class="fa-solid fa-box-open"></i> San Pham Cua Ban</div>
                <a href="<%= request.getContextPath() %>/seller/add-product" class="btn btn-green btn-sm"><i class="fa-solid fa-plus"></i> Them San Pham</a>
            </div>
            <div class="card-body">
                <% if (products == null || products.isEmpty()) { %>
                <p style="text-align:center; color:var(--gray-400); padding:2rem;">Chua co san pham nao.</p>
                <% } else { %>
                <p style="font-size:0.875rem; color:var(--gray-600);">
                    Ban dang co <strong><%= totalProducts %></strong> san pham. <a href="<%= request.getContextPath() %>/seller/products" style="color:var(--green); font-weight:600;">Xem chi tiet &rarr;</a>
                </p>
                <% } %>
            </div>
        </div>
    </main>
</div>

<footer class="footer">
    <a href="<%= request.getContextPath() %>/home.jsp" class="footer-logo"><i class="fa-solid fa-apple-whole"></i> Sena Shop</a>
    <span class="footer-copy">&copy; 2024 Sena Shop.</span>
</footer>

</body>
</html>
