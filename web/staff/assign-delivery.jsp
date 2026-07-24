<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Order" %>
<%@ page import="model.DeliveryOrder" %>
<%@ page import="java.util.List" %>
<%
    Account user = (Account) session.getAttribute("Account");
    if (user == null || !"staff".equals(user.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    List<Order> waitingOrders = (List<Order>) request.getAttribute("waitingOrders");
    List<Account> shippers = (List<Account>) request.getAttribute("shippers");
    Integer selectedOrderId = (Integer) request.getAttribute("selectedOrderId");
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
    <title>Giao Hàng Cho Shipper | SenaFruit</title>
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
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; }
        .card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--gray-200); box-shadow: var(--shadow-sm); padding: 1.5rem; }
        .card-title { font-size: 1.1rem; font-weight: 700; color: var(--gray-800); margin-bottom: 1rem; display: flex; align-items: center; gap: 0.5rem; }
        .card-title i { color: var(--green); }
        .form-group { margin-bottom: 1rem; }
        .form-label { display: block; font-size: 0.875rem; font-weight: 600; color: var(--gray-600); margin-bottom: 0.5rem; }
        .form-label .required { color: #ef4444; }
        .form-input, .form-select, .form-textarea { width: 100%; padding: 0.75rem 1rem; border: 1.5px solid var(--gray-200); border-radius: var(--radius-sm); font-size: 0.875rem; font-family: inherit; outline: none; }
        .form-input:focus, .form-select:focus, .form-textarea:focus { border-color: var(--green); }
        .form-textarea { resize: vertical; min-height: 100px; }
        .btn { padding: 0.75rem 1.5rem; border-radius: var(--radius-sm); font-size: 0.875rem; font-weight: 600; text-decoration: none; transition: all 0.15s; cursor: pointer; border: none; display: inline-flex; align-items: center; gap: 0.5rem; }
        .btn-primary { background: var(--green); color: white; }
        .btn-primary:hover { background: var(--green-dark); }
        .btn-secondary { background: var(--gray-200); color: var(--gray-600); }
        .btn-secondary:hover { background: var(--gray-300); }
        .order-list { max-height: 400px; overflow-y: auto; }
        .order-item { padding: 1rem; border: 1px solid var(--gray-200); border-radius: var(--radius-sm); margin-bottom: 0.75rem; cursor: pointer; transition: all 0.15s; }
        .order-item:hover { border-color: var(--green); background: var(--green-light); }
        .order-item.selected { border-color: var(--green); background: var(--green-light); }
        .order-item input[type="radio"] { margin-right: 0.5rem; }
        .order-info { display: flex; justify-content: space-between; align-items: center; }
        .order-total { font-weight: 600; color: var(--green-dark); }
        .shipper-card { padding: 1rem; border: 1px solid var(--gray-200); border-radius: var(--radius-sm); margin-bottom: 0.75rem; cursor: pointer; transition: all 0.15s; }
        .shipper-card:hover { border-color: var(--green); background: var(--green-light); }
        .shipper-card.selected { border-color: var(--green); background: var(--green-light); }
        .shipper-card input[type="radio"] { margin-right: 0.5rem; }
        .form-actions { display: flex; justify-content: flex-end; gap: 1rem; margin-top: 1.5rem; }
        .empty-state { text-align: center; padding: 2rem; color: var(--gray-400); }
    </style>
</head>
<body>
    <nav class="topnav">
        <a href="${pageContext.request.contextPath}/home.jsp" class="nav-logo">
            <i class="fas fa-leaf"></i> SenaFruit
        </a>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/home.jsp">Trang Chủ</a>
            <a href="${pageContext.request.contextPath}/staff/delivery">Giao Hàng</a>
            <a href="${pageContext.request.contextPath}/staff/orders-waiting">Đơn Chờ Giao</a>
            <a href="${pageContext.request.contextPath}/staff/delivery-history">Lịch Sử</a>
        </div>
        <div class="nav-right">
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm" style="background: #fee2e2; color: #991b1b;">Đăng Xuất</a>
        </div>
    </nav>
    
    <div class="layout">
        <% if (message != null) { %>
        <div class="alert alert-success"><i class="fas fa-check-circle"></i> <%= message %></div>
        <% } %>
        <% if (error != null) { %>
        <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> <%= error %></div>
        <% } %>
        
        <h1 class="page-title"><i class="fas fa-motorcycle"></i> Giao Đơn Hàng Cho Shipper</h1>
        
        <div class="grid">
            <div class="card">
                <h2 class="card-title"><i class="fas fa-box"></i> Chọn Đơn Hàng</h2>
                
                <% if (waitingOrders == null || waitingOrders.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-check-circle"></i>
                    <p>Không có đơn hàng nào cần giao</p>
                </div>
                <% } else { %>
                <div class="order-list">
                    <form id="orderForm">
                        <% for (Order order : waitingOrders) { %>
                        <div class="order-item" onclick="selectOrder(<%= order.getId() %>)">
                            <label>
                                <input type="radio" name="orderId" value="<%= order.getId() %>" <%= selectedOrderId != null && selectedOrderId == order.getId() ? "checked" : "" %> required>
                                <strong>#<%= order.getId() %></strong> - <%= order.getRecipientName() %>
                            </label>
                            <div class="order-info">
                                <small><%= order.getAddress() %></small>
                                <span class="order-total"><%= nf.format(order.getFinalCost()) %>đ</span>
                            </div>
                        </div>
                        <% } %>
                    </form>
                </div>
                <% } %>
            </div>
            
            <div class="card">
                <h2 class="card-title"><i class="fas fa-user"></i> Chọn Shipper</h2>
                
                <form id="assignForm" action="${pageContext.request.contextPath}/staff/assign-delivery" method="post">
                    <input type="hidden" name="orderId" id="selectedOrderId" value="<%= selectedOrderId != null ? selectedOrderId : "" %>">
                    
                    <div class="form-group">
                        <label class="form-label">Shipper <span class="required">*</span></label>
                        <% if (shippers == null || shippers.isEmpty()) { %>
                        <div class="empty-state" style="padding: 1rem;">
                            <p>Không có shipper nào khả dụng</p>
                        </div>
                        <% } else { %>
                        <div class="order-list">
                            <% for (Account shipper : shippers) { %>
                            <div class="shipper-card" onclick="selectShipper(<%= shipper.getId() %>)">
                                <label>
                                    <input type="radio" name="shipperId" value="<%= shipper.getId() %>" required>
                                    <strong><%= shipper.getFullname() %></strong>
                                </label>
                                <div>
                                    <small>Điện thoại: <%= shipper.getPhone() != null ? shipper.getPhone() : "-" %></small>
                                </div>
                            </div>
                            <% } %>
                        </div>
                        <% } %>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Ghi chú</label>
                        <textarea name="note" class="form-textarea" placeholder="Nhập ghi chú cho shipper (nếu có)"></textarea>
                    </div>
                    
                    <div class="form-actions">
                        <a href="${pageContext.request.contextPath}/staff/orders-waiting" class="btn btn-secondary">Hủy</a>
                        <button type="submit" class="btn btn-primary" onclick="return validateForm()">
                            <i class="fas fa-paper-plane"></i> Giao Đơn
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script>
        function selectOrder(orderId) {
            document.querySelectorAll('.order-item').forEach(function(item) {
                item.classList.remove('selected');
            });
            event.currentTarget.classList.add('selected');
            document.getElementById('selectedOrderId').value = orderId;
            document.querySelector('input[name="orderId"][value="' + orderId + '"]').checked = true;
        }
        
        function selectShipper(shipperId) {
            document.querySelectorAll('.shipper-card').forEach(function(card) {
                card.classList.remove('selected');
            });
            event.currentTarget.classList.add('selected');
            document.querySelector('input[name="shipperId"][value="' + shipperId + '"]').checked = true;
        }
        
        function validateForm() {
            var orderId = document.getElementById('selectedOrderId').value;
            var shipperId = document.querySelector('input[name="shipperId"]:checked');
            
            if (!orderId) {
                alert('Vui lòng chọn đơn hàng');
                return false;
            }
            if (!shipperId) {
                alert('Vui lòng chọn shipper');
                return false;
            }
            return true;
        }
        
        // Auto-select if pre-selected
        <% if (selectedOrderId != null) { %>
        var selectedOrderDiv = document.querySelector('.order-item input[value="<%= selectedOrderId %>"]');
        if (selectedOrderDiv) {
            selectedOrderDiv.closest('.order-item').classList.add('selected');
        }
        <% } %>
    </script>
</body>
</html>
