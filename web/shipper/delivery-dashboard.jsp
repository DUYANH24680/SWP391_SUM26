<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.DeliveryOrder" %>
<%@ page import="java.util.List" %>
<%
    Account user = (Account) session.getAttribute("Account");
    if (user == null || !"shipper".equals(user.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    Integer pendingCount = (Integer) request.getAttribute("pendingCount");
    Integer completedCount = (Integer) request.getAttribute("completedCount");
    Integer failedCount = (Integer) request.getAttribute("failedCount");
    List<DeliveryOrder> pendingDeliveries = (List<DeliveryOrder>) request.getAttribute("pendingDeliveries");
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
    <title>Giao Hàng Của Tôi | SenaFruit</title>
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
        .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.5rem; margin-bottom: 1.5rem; }
        .stat-card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--gray-200); box-shadow: var(--shadow-sm); padding: 1.5rem; display: flex; align-items: center; gap: 1rem; }
        .stat-icon { width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; }
        .stat-icon.blue { background: #dbeafe; color: #2563eb; }
        .stat-icon.green { background: #dcfce7; color: #16a34a; }
        .stat-icon.red { background: #fee2e2; color: #dc2626; }
        .stat-value { font-size: 2rem; font-weight: 800; color: var(--gray-800); }
        .stat-label { font-size: 0.875rem; color: var(--gray-600); }
        .card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--gray-200); box-shadow: var(--shadow-sm); overflow: hidden; }
        .card-header { padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--gray-200); }
        .card-title { font-size: 1.1rem; font-weight: 700; color: var(--gray-800); display: flex; align-items: center; gap: 0.5rem; }
        .card-title i { color: var(--green); }
        .delivery-list { padding: 1rem; }
        .delivery-item { border: 1px solid var(--gray-200); border-radius: var(--radius-sm); padding: 1rem; margin-bottom: 1rem; transition: all 0.15s; }
        .delivery-item:hover { border-color: var(--green); box-shadow: var(--shadow-sm); }
        .delivery-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.75rem; }
        .delivery-id { font-weight: 700; color: var(--green-dark); }
        .delivery-address { color: var(--gray-600); font-size: 0.875rem; margin-bottom: 0.75rem; }
        .delivery-address i { margin-right: 0.5rem; }
        .delivery-footer { display: flex; justify-content: space-between; align-items: center; }
        .badge { display: inline-flex; align-items: center; padding: 0.25rem 0.6rem; border-radius: 100px; font-size: 0.75rem; font-weight: 600; }
        .badge-yellow { background: #fef3c7; color: #92400e; }
        .badge-blue { background: #dbeafe; color: #1d4ed8; }
        .badge-green { background: #dcfce7; color: #15803d; }
        .badge-red { background: #fee2e2; color: #991b1b; }
        .badge-purple { background: #f3e8ff; color: #7c3aed; }
        .badge-orange { background: #ffedd5; color: #ea580c; }
        .btn { padding: 0.5rem 1rem; border-radius: var(--radius-sm); font-size: 0.875rem; font-weight: 600; text-decoration: none; transition: all 0.15s; cursor: pointer; border: none; display: inline-flex; align-items: center; gap: 0.5rem; }
        .btn-primary { background: var(--green); color: white; }
        .btn-primary:hover { background: var(--green-dark); }
        .btn-sm { padding: 0.35rem 0.75rem; font-size: 0.8rem; }
        .empty-state { text-align: center; padding: 3rem; color: var(--gray-400); }
    </style>
</head>
<body>
    <nav class="topnav">
        <a href="${pageContext.request.contextPath}/shipper/delivery" class="nav-logo">
            <i class="fas fa-motorcycle"></i> Shipper Panel
        </a>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/shipper/delivery" class="active">Giao Hàng</a>
            <a href="${pageContext.request.contextPath}/shipper/my-deliveries">Đơn Của Tôi</a>
        </div>
        <div class="nav-right">
            <span style="font-size: 0.875rem; font-weight: 600;"><%= user.getFullname() %></span>
            <jsp:include page="/notification-icon.jsp" />
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
        
        <h1 class="page-title"><i class="fas fa-motorcycle"></i> Giao Hàng Của Tôi</h1>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue"><i class="fas fa-clock"></i></div>
                <div>
                    <div class="stat-value"><%= pendingCount != null ? pendingCount : 0 %></div>
                    <div class="stat-label">Đang Xử Lý</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green"><i class="fas fa-check-circle"></i></div>
                <div>
                    <div class="stat-value"><%= completedCount != null ? completedCount : 0 %></div>
                    <div class="stat-label">Đã Giao</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon red"><i class="fas fa-times-circle"></i></div>
                <div>
                    <div class="stat-value"><%= failedCount != null ? failedCount : 0 %></div>
                    <div class="stat-label">Thất Bại</div>
                </div>
            </div>
        </div>
        
        <div class="card">
            <div class="card-header">
                <h2 class="card-title"><i class="fas fa-truck"></i> Đơn Hàng Đang Giao</h2>
            </div>
            <div class="delivery-list">
                <% if (pendingDeliveries == null || pendingDeliveries.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-check-circle" style="font-size: 3rem;"></i>
                    <p>Không có đơn hàng nào đang chờ giao</p>
                </div>
                <% } else { %>
                <% for (DeliveryOrder d : pendingDeliveries) { %>
                <div class="delivery-item">
                    <div class="delivery-header">
                        <div>
                            <span class="delivery-id">#<%= d.getDeliveryId() %></span> - Đơn #<%= d.getOrderId() %>
                        </div>
                        <span class="badge <%= d.getStatusClass() %>"><%= d.getStatusLabel() %></span>
                    </div>
                    <div class="delivery-address">
                        <i class="fas fa-map-marker-alt"></i>
                        <%= d.getDeliveryAddress() %>
                    </div>
                    <div class="delivery-address">
                        <i class="fas fa-user"></i>
                        <%= d.getRecipientName() %> - <%= d.getRecipientPhone() %>
                    </div>
                    <div class="delivery-footer">
                        <span style="font-weight: 600; color: var(--green-dark);">
                            <%= java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi")).format(d.getOrderTotal()) %>đ
                        </span>
                        <a href="${pageContext.request.contextPath}/shipper/delivery-detail?id=<%= d.getDeliveryId() %>" class="btn btn-primary btn-sm">
                            <i class="fas fa-eye"></i> Chi Tiết
                        </a>
                    </div>
                </div>
                <% } %>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>
