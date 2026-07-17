<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Order" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Account user = (Account) session.getAttribute("Account");
    if (user == null || !"staff".equals(user.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    List<Order> waitingOrders = (List<Order>) request.getAttribute("waitingOrders");
    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn Hàng Chờ Giao | Sena Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --green: #4caf50; --green-dark: #388e3c; --green-light: #e8f5e9;
            --bg: #f0f4f1; --white: #ffffff; --gray-50: #f8fafb;
            --gray-100: #eef1ee; --gray-200: #dde5dd; --gray-400: #9aaa9a;
            --gray-600: #5a6a5a; --gray-800: #2d3d2d;
            --shadow-sm: 0 1px 3px rgba(0,0,0,.08); --shadow: 0 4px 12px rgba(0,0,0,.08);
            --radius: 14px; --radius-sm: 8px;
        }
        html, body { min-height: 100vh; font-family: 'Inter', sans-serif; color: var(--gray-800); background: var(--bg); }
        .topnav {
            background: var(--white); border-bottom: 1px solid var(--gray-200); height: 60px;
            display: flex; align-items: center; padding: 0 2rem; gap: 1.5rem;
            position: sticky; top: 0; z-index: 100; box-shadow: var(--shadow-sm);
        }
        .nav-logo { display: flex; align-items: center; gap: 0.5rem; font-size: 1.3rem; font-weight: 800; color: var(--green-dark); text-decoration: none; }
        .nav-logo i { color: var(--green); }
        .nav-links { display: flex; gap: 0.25rem; }
        .nav-links a { padding: 0.4rem 0.85rem; border-radius: 6px; font-size: 0.875rem; font-weight: 500; color: var(--gray-600); text-decoration: none; transition: all 0.15s; }
        .nav-links a:hover { background: var(--green-light); color: var(--green-dark); }
        .nav-links a.active { background: var(--green-light); color: var(--green-dark); font-weight: 600; }
        .nav-right { margin-left: auto; display: flex; align-items: center; gap: 0.75rem; }
        .layout { max-width: 1280px; margin: 1.5rem auto; padding: 0 1.5rem; }
        .alert { display: flex; align-items: center; gap: 0.75rem; padding: 0.9rem 1.2rem; border-radius: var(--radius-sm); font-size: 0.875rem; font-weight: 500; margin-bottom: 1.25rem; }
        .alert-success { background: #dcfce7; border: 1px solid #bbf7d0; color: #15803d; }
        .alert-danger { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }
        .page-title { font-size: 1.5rem; font-weight: 800; color: var(--gray-800); margin-bottom: 1.5rem; display: flex; align-items: center; gap: 0.5rem; }
        .page-title i { color: var(--green); }
        .card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--gray-200); box-shadow: var(--shadow-sm); overflow: hidden; }
        .table { width: 100%; border-collapse: collapse; }
        .table th { background: var(--gray-50); padding: 0.9rem 1rem; text-align: left; font-size: 0.8rem; font-weight: 600; color: var(--gray-600); text-transform: uppercase; letter-spacing: 0.05em; border-bottom: 1px solid var(--gray-200); }
        .table td { padding: 0.9rem 1rem; font-size: 0.875rem; border-bottom: 1px solid var(--gray-100); vertical-align: middle; }
        .table tr:last-child td { border-bottom: none; }
        .table tr:hover td { background: var(--gray-50); }
        .badge { display: inline-flex; align-items: center; padding: 0.25rem 0.6rem; border-radius: 100px; font-size: 0.75rem; font-weight: 600; }
        .badge-yellow { background: #fef3c7; color: #92400e; }
        .btn { padding: 0.5rem 1rem; border-radius: var(--radius-sm); font-size: 0.875rem; font-weight: 600; text-decoration: none; transition: all 0.15s; cursor: pointer; border: none; }
        .btn-primary { background: var(--green); color: white; }
        .btn-primary:hover { background: var(--green-dark); }
        .btn-sm { padding: 0.35rem 0.75rem; font-size: 0.8rem; }
        .empty-state { text-align: center; padding: 3rem; color: var(--gray-400); }
    </style>
</head>
<body>
    <nav class="topnav">
        <a href="${pageContext.request.contextPath}/staff/delivery" class="nav-logo">
            <i class="fas fa-warehouse"></i> Staff Panel
        </a>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/staff/delivery">Giao Hàng</a>
            <a href="${pageContext.request.contextPath}/staff/orders-waiting" class="active">Đơn Chờ Giao</a>
            <a href="${pageContext.request.contextPath}/staff/delivery-history">Lịch Sử</a>
        </div>
        <div class="nav-right">
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm" style="background: #fee2e2; color: #991b1b; text-decoration: none;">Đăng Xuất</a>
        </div>
    </nav>
    
    <div class="layout">
        <% if (message != null) { %>
        <div class="alert alert-success"><i class="fas fa-check-circle"></i> <%= message %></div>
        <% } %>
        <% if (error != null) { %>
        <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> <%= error %></div>
        <% } %>
        
        <div class="page-title">
            <i class="fas fa-clock"></i> Đơn Hàng Chờ Giao
        </div>
        
        <div class="card">
            <% if (waitingOrders == null || waitingOrders.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-check-circle" style="font-size: 3rem;"></i>
                <p>Không có đơn hàng nào đang chờ giao</p>
            </div>
            <% } else { %>
            <table class="table">
                <thead>
                    <tr>
                        <th>Mã Đơn</th>
                        <th>Khách Hàng</th>
                        <th>Địa Chỉ</th>
                        <th>Tổng Tiền</th>
                        <th>Ngày Đặt</th>
                        <th>Thao Tác</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Order order : waitingOrders) { %>
                    <tr>
                        <td>#<%= order.getId() %></td>
                        <td><%= order.getRecipientName() %><br><small style="color: var(--gray-400);"><%= order.getRecipientPhone() %></small></td>
                        <td><%= order.getAddress() %></td>
                        <td><%= nf.format(order.getFinalCost()) %>đ</td>
                        <td><%= order.getOrderDate() != null ? sdf.format(order.getOrderDate()) : "-" %></td>
                        <td>
                            <a href="${pageContext.request.contextPath}/staff/assign-delivery?orderId=<%= order.getId() %>" class="btn btn-primary btn-sm">
                                <i class="fas fa-motorcycle"></i> Giao Hàng
                            </a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } %>
        </div>
    </div>
</body>
</html>
