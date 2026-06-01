<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Product" %>
<%@ page import="model.Customer" %>
<%@ page import="model.Seller" %>
<%@ page import="model.Category" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
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
        Seller seller = (Seller) user;
        displayName = seller.getFullname() != null ? seller.getFullname() : "";
        avatarUrl = seller.getAvatar();
    } else if (user instanceof Customer) {
        Customer customer = (Customer) user;
        displayName = customer.getFullname() != null ? customer.getFullname() : "";
        avatarUrl = customer.getAvatar();
    }

    if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
        String dn = (displayName != null && !displayName.trim().isEmpty()) ? displayName : "User";
        avatarUrl = "https://ui-avatars.com/api/?name="
                  + java.net.URLEncoder.encode(dn, "UTF-8")
                  + "&background=4caf50&color=fff&size=160&bold=true&rounded=true";
    }

    List<Product> products = (List<Product>) request.getAttribute("products");
    String message = (String) request.getAttribute("message");
    String errorMsg = (String) request.getAttribute("error");

    Locale localeVN = new Locale("vi", "VN");
    NumberFormat nf = NumberFormat.getCurrencyInstance(localeVN);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quan Ly San Pham | Sena Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/seller.css">
</head>
<body>

<nav class="topnav">
    <a href="<%= request.getContextPath() %>/home.jsp" class="nav-logo">
        <i class="fa-solid fa-apple-whole"></i> Sena Shop
    </a>
    <div class="nav-links">
        <a href="<%= request.getContextPath() %>/home.jsp">Trang Chu</a>
        <a href="#">San Pham</a>
        <a href="#">Don Hang</a>
        <a href="#" class="active">Quan Ly</a>
    </div>
    <div class="nav-right">
        <button class="nav-icon-btn" title="Thong bao"><i class="fa-regular fa-bell"></i></button>
        <a href="<%= request.getContextPath() %>/profile">
            <img class="nav-avatar" src="<%= avatarUrl %>" alt="avatar">
        </a>
    </div>
</nav>

<div class="layout">

    <aside class="sidebar">
        <div class="sidebar-user">
            <div class="sidebar-user-row">
                <img class="sidebar-user-avatar" src="<%= avatarUrl %>" alt="avatar">
                <div>
                    <div class="sidebar-welcome"><%= displayName.split(" ")[displayName.split(" ").length - 1] %></div>
                </div>
            </div>
            <div class="sidebar-role-text">Nhan Vien Ban Hang</div>
        </div>

        <div class="sidebar-nav">
            <a href="<%= request.getContextPath() %>/seller/dashboard">
                <i class="fa-solid fa-chart-line"></i> Tong Quan
            </a>
            <a href="<%= request.getContextPath() %>/seller/add-product">
                <i class="fa-solid fa-plus-circle"></i> Them San Pham
            </a>
            <a href="<%= request.getContextPath() %>/seller/products" class="active">
                <i class="fa-solid fa-box-open"></i> Quan Ly San Pham
            </a>
            <a href="<%= request.getContextPath() %>/seller/orders">
                <i class="fa-solid fa-receipt"></i> Don Hang
            </a>
            <a href="<%= request.getContextPath() %>/profile">
                <i class="fa-regular fa-user"></i> Ho So
            </a>
        </div>
    </aside>

    <main class="main">

        <% if (errorMsg != null) { %>
        <div class="alert alert-danger">
            <i class="fa-solid fa-circle-exclamation"></i>
            <span><%= errorMsg %></span>
        </div>
        <% } %>

        <% if (message != null) { %>
        <div class="alert alert-success">
            <i class="fa-solid fa-circle-check"></i>
            <span><%= message %></span>
        </div>
        <% } %>

        <div class="card">
            <div class="card-header">
                <div class="card-title">
                    <i class="fa-solid fa-box-open"></i> Quan Ly San Pham
                </div>
                <a href="<%= request.getContextPath() %>/seller/add-product" class="btn btn-green btn-sm">
                    <i class="fa-solid fa-plus"></i> Them San Pham
                </a>
            </div>
            <div class="card-body">

                <% if (products == null || products.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fa-solid fa-box-open"></i>
                    <p>Chua co san pham nao. Hay them san pham dau tien cua ban!</p>
                    <a href="<%= request.getContextPath() %>/seller/add-product" class="btn btn-green">
                        <i class="fa-solid fa-plus"></i> Them San Pham
                    </a>
                </div>
                <% } else { %>
                <table class="product-table">
                    <thead>
                        <tr>
                            <th>San Pham</th>
                            <th>Gia</th>
                            <th>Kho</th>
                            <th>Trang Thai</th>
                            <th>Thao Tac</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Product p : products) {
                            String imgSrc = p.getImage() != null ? p.getImage() : "";
                            String statusBadge = "";
                            String statusClass = "";
                            switch (p.getStatus()) {
                                case 0: statusBadge = "Cho Duyet"; statusClass = "badge-pending"; break;
                                case 1: statusBadge = "Hien Thi";  statusClass = "badge-active";  break;
                                case 2: statusBadge = "An";        statusClass = "badge-hidden";  break;
                            }
                            String stockClass = "";
                            if (p.getStockQuantity() == 0) stockClass = "stock-out";
                            else if (p.getStockQuantity() < 10) stockClass = "stock-low";
                            else stockClass = "stock-ok";
                        %>
                        <tr>
                            <td>
                                <div style="display:flex; align-items:center; gap:0.75rem;">
                                    <% if (imgSrc != null && !imgSrc.isEmpty()) { %>
                                    <img class="product-thumb" src="<%= imgSrc %>" alt="<%= p.getTitle() %>">
                                    <% } else { %>
                                    <div class="product-thumb-placeholder">
                                        <i class="fa-solid fa-image"></i>
                                    </div>
                                    <% } %>
                                    <div>
                                        <div class="product-title"><%= p.getTitle() %></div>
                                        <div style="font-size:0.72rem; color:var(--gray-400); margin-top:0.15rem;">
                                            <%= p.getUnit() %> &bull; Da ban: <%= p.getSoldQuantity() %>
                                        </div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div class="product-price">
                                    <%= nf.format(p.getSalePrice() != null ? p.getSalePrice() : p.getOriginalPrice()) %>
                                </div>
                                <% if (p.getSalePrice() != null && p.getSalePrice().compareTo(p.getOriginalPrice()) < 0) { %>
                                <div class="product-price-original">
                                    <%= nf.format(p.getOriginalPrice()) %>
                                </div>
                                <% } %>
                            </td>
                            <td>
                                <span class="<%= stockClass %>"><%= p.getStockQuantity() %></span>
                            </td>
                            <td>
                                <span class="badge <%= statusClass %>"><%= statusBadge %></span>
                                <% if (p.isIsFeatured()) { %>
                                <span class="badge badge-featured">Noi Bat</span>
                                <% } %>
                            </td>
                            <td>
                                <a href="<%= request.getContextPath() %>/seller/view-product?id=<%= p.getId() %>" class="action-btn" title="Xem chi tiet">
                                    <i class="fa-solid fa-eye"></i>
                                </a>
                                <a href="<%= request.getContextPath() %>/seller/edit-product?id=<%= p.getId() %>" class="action-btn" title="Chinh sua" style="margin-left:0.35rem;">
                                    <i class="fa-solid fa-pen-to-square"></i>
                                </a>
                                <a href="<%= request.getContextPath() %>/seller/products?action=delete&id=<%= p.getId() %>"
                                   class="action-btn action-btn-danger"
                                   title="Xoa san pham"
                                   style="margin-left:0.35rem;"
                                   onclick="return confirm('Ban co chac chan muon xoa san pham nay?');">
                                    <i class="fa-solid fa-trash"></i>
                                </a>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } %>

            </div>
        </div>

    </main>
</div>

<footer class="footer">
    <a href="<%= request.getContextPath() %>/home.jsp" class="footer-logo"><i class="fa-solid fa-apple-whole"></i> Sena Shop</a>
    <span class="footer-copy">&copy; 2024 Sena Shop. Trai cay tuoi ngon moi ngay.</span>
</footer>

</body>
</html>
