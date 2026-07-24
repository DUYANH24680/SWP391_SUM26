<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.DeliveryOrder" %>
<%@ page import="java.util.List" %>
<%
    Account user = (Account) session.getAttribute("Account");
    if (user == null || !"staff".equals(user.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    List<DeliveryOrder> deliveries = (List<DeliveryOrder>) request.getAttribute("deliveries");
    String statusFilter = (String) request.getAttribute("statusFilter");
    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");
    
    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch Sử Giao Hàng | SenaFruit</title>
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
        .filter-row { display: flex; gap: 0.5rem; margin-bottom: 1rem; flex-wrap: wrap; }
        .filter-btn { padding: 0.4rem 0.85rem; border-radius: 6px; font-size: 0.8rem; font-weight: 600; border: 1px solid var(--gray-200); background: white; cursor: pointer; transition: all 0.15s; }
        .filter-btn:hover { border-color: var(--green); }
        .filter-btn.active { background: var(--green); color: white; border-color: var(--green); }
        .table { width: 100%; border-collapse: collapse; }
        .table th { background: var(--gray-50); padding: 0.9rem 1rem; text-align: left; font-size: 0.8rem; font-weight: 600; color: var(--gray-600); text-transform: uppercase; letter-spacing: 0.05em; border-bottom: 1px solid var(--gray-200); }
        .table td { padding: 0.9rem 1rem; font-size: 0.875rem; border-bottom: 1px solid var(--gray-100); }
        .table tr:last-child td { border-bottom: none; }
        .table tr:hover td { background: var(--gray-50); }
        .badge { display: inline-flex; align-items: center; padding: 0.25rem 0.6rem; border-radius: 100px; font-size: 0.75rem; font-weight: 600; }
        .badge-yellow { background: #fef3c7; color: #92400e; }
        .badge-blue { background: #dbeafe; color: #1d4ed8; }
        .badge-green { background: #dcfce7; color: #15803d; }
        .badge-red { background: #fee2e2; color: #991b1b; }
        .badge-purple { background: #f3e8ff; color: #7c3aed; }
        .badge-orange { background: #ffedd5; color: #ea580c; }
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
            <a href="${pageContext.request.contextPath}/staff/orders-waiting">Đơn Chờ Giao</a>
            <a href="${pageContext.request.contextPath}/staff/delivery-history" class="active">Lịch Sử</a>
        </div>
        <div class="nav-right">
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
        
        <h1 class="page-title"><i class="fas fa-history"></i> Lịch Sử Giao Hàng</h1>
        
        <div class="card" style="padding: 1.5rem; margin-bottom: 1.5rem;">
            <div class="filter-row">
                <a href="${pageContext.request.contextPath}/staff/delivery-history" class="filter-btn <%= statusFilter == null || statusFilter.isEmpty() ? "active" : "" %>">Tất Cả</a>
                <a href="${pageContext.request.contextPath}/staff/delivery-history?status=1" class="filter-btn <%= "1".equals(statusFilter) ? "active" : "" %>">Chờ Nhận</a>
                <a href="${pageContext.request.contextPath}/staff/delivery-history?status=2" class="filter-btn <%= "2".equals(statusFilter) ? "active" : "" %>">Đã Nhận</a>
                <a href="${pageContext.request.contextPath}/staff/delivery-history?status=3" class="filter-btn <%= "3".equals(statusFilter) ? "active" : "" %>">Đang Lấy Hàng</a>
                <a href="${pageContext.request.contextPath}/staff/delivery-history?status=4" class="filter-btn <%= "4".equals(statusFilter) ? "active" : "" %>">Đang Giao</a>
                <a href="${pageContext.request.contextPath}/staff/delivery-history?status=5" class="filter-btn <%= "5".equals(statusFilter) ? "active" : "" %>">Đã Giao</a>
                <a href="${pageContext.request.contextPath}/staff/delivery-history?status=6" class="filter-btn <%= "6".equals(statusFilter) ? "active" : "" %>">Giao Thất Bại</a>
            </div>
        </div>
        
        <div class="card">
            <% if (deliveries == null || deliveries.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-truck" style="font-size: 3rem;"></i>
                <p>Không có giao dịch giao hàng nào</p>
            </div>
            <% } else { %>
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Mã Đơn</th>
                        <th>Shipper</th>
                        <th>Người Giao</th>
                        <th>Ngày Giao</th>
                        <th>Tổng Tiền</th>
                        <th>Trạng Thái</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (DeliveryOrder d : deliveries) { %>
                    <tr>
                        <td>#<%= d.getDeliveryId() %></td>
                        <td>#<%= d.getOrderId() %></td>
                        <td><%= d.getShipperName() != null ? d.getShipperName() : "-" %></td>
                        <td><%= d.getAssignedByName() != null ? d.getAssignedByName() : "-" %></td>
                        <td><%= d.getAssignedDate() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(d.getAssignedDate()) : "-" %></td>
                        <td><%= nf.format(d.getOrderTotal()) %>đ</td>
                        <td><span class="badge <%= d.getStatusClass() %>"><%= d.getStatusLabel() %></span></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } %>
        </div>
    </div>
</body>
</html>
