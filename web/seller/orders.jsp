<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer" %>
<%@ page import="model.Seller" %>
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
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Don Hang | Sena Shop</title>
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
            <a href="<%= request.getContextPath() %>/seller/dashboard"><i class="fa-solid fa-chart-line"></i> Tong Quan</a>
            <a href="<%= request.getContextPath() %>/seller/add-product"><i class="fa-solid fa-plus-circle"></i> Them San Pham</a>
            <a href="<%= request.getContextPath() %>/seller/products"><i class="fa-solid fa-box-open"></i> Quan Ly San Pham</a>
            <a href="<%= request.getContextPath() %>/seller/orders" class="active"><i class="fa-solid fa-receipt"></i> Don Hang</a>
            <a href="<%= request.getContextPath() %>/profile"><i class="fa-regular fa-user"></i> Ho So</a>
        </div>
    </aside>

    <main class="main">
        <div class="card">
            <div class="card-header">
                <div class="card-title"><i class="fa-solid fa-receipt"></i> Quan Ly Don Hang</div>
            </div>
            <div class="card-body">
                <i class="fa-solid fa-inbox" style="font-size:3rem; color:var(--gray-200); margin-bottom:1rem; display:block;"></i>
                <p>Chua co don hang nao.</p>
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
