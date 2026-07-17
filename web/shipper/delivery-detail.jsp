<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.DeliveryOrder" %>
<%@ page import="model.OrderTracking" %>
<%@ page import="java.util.List" %>
<%
    Account user = (Account) session.getAttribute("Account");
    if (user == null || !"shipper".equals(user.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    DeliveryOrder delivery = (DeliveryOrder) request.getAttribute("delivery");
    List<OrderTracking> trackingHistory = (List<OrderTracking>) request.getAttribute("trackingHistory");
    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");
    
    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi"));
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi Tiết Giao Hàng | Sena Shop</title>
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
        .layout { max-width: 900px; margin: 1.5rem auto; padding: 0 1.5rem; }
        .alert { display: flex; align-items: center; gap: 0.75rem; padding: 0.9rem 1.2rem; border-radius: var(--radius-sm); font-size: 0.875rem; font-weight: 500; margin-bottom: 1.25rem; }
        .alert-success { background: #dcfce7; border: 1px solid #bbf7d0; color: #15803d; }
        .alert-danger { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }
        .page-title { font-size: 1.5rem; font-weight: 800; color: var(--gray-800); margin-bottom: 1.5rem; display: flex; align-items: center; gap: 0.5rem; }
        .page-title i { color: var(--green); }
        .card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--gray-200); box-shadow: var(--shadow-sm); padding: 1.5rem; margin-bottom: 1.5rem; }
        .card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; padding-bottom: 1rem; border-bottom: 1px solid var(--gray-200); }
        .card-title { font-size: 1.1rem; font-weight: 700; color: var(--gray-800); display: flex; align-items: center; gap: 0.5rem; }
        .card-title i { color: var(--green); }
        .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
        .info-item { }
        .info-label { font-size: 0.8rem; font-weight: 600; color: var(--gray-600); text-transform: uppercase; margin-bottom: 0.25rem; }
        .info-value { font-size: 0.95rem; color: var(--gray-800); }
        .badge { display: inline-flex; align-items: center; padding: 0.25rem 0.6rem; border-radius: 100px; font-size: 0.75rem; font-weight: 600; }
        .badge-yellow { background: #fef3c7; color: #92400e; }
        .badge-blue { background: #dbeafe; color: #1d4ed8; }
        .badge-green { background: #dcfce7; color: #15803d; }
        .badge-red { background: #fee2e2; color: #991b1b; }
        .badge-purple { background: #f3e8ff; color: #7c3aed; }
        .badge-orange { background: #ffedd5; color: #ea580c; }
        .btn { padding: 0.75rem 1.5rem; border-radius: var(--radius-sm); font-size: 0.875rem; font-weight: 600; text-decoration: none; transition: all 0.15s; cursor: pointer; border: none; display: inline-flex; align-items: center; gap: 0.5rem; }
        .btn-primary { background: var(--green); color: white; }
        .btn-primary:hover { background: var(--green-dark); }
        .btn-warning { background: #f59e0b; color: white; }
        .btn-warning:hover { background: #d97706; }
        .btn-danger { background: #ef4444; color: white; }
        .btn-danger:hover { background: #dc2626; }
        .btn-secondary { background: var(--gray-200); color: var(--gray-600); }
        .btn-secondary:hover { background: var(--gray-300); }
        .btn-group { display: flex; gap: 0.75rem; flex-wrap: wrap; }
        .action-section { margin-top: 1.5rem; padding-top: 1.5rem; border-top: 1px solid var(--gray-200); }
        .timeline { padding-left: 0; list-style: none; }
        .timeline-item { display: flex; gap: 1rem; padding-bottom: 1.5rem; position: relative; }
        .timeline-item:not(:last-child)::before { content: ''; position: absolute; left: 11px; top: 24px; bottom: 0; width: 2px; background: var(--gray-200); }
        .timeline-icon { width: 24px; height: 24px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0; background: var(--gray-200); color: var(--gray-600); font-size: 0.75rem; }
        .timeline-icon.active { background: var(--green); color: white; }
        .timeline-content { flex: 1; }
        .timeline-status { font-weight: 600; color: var(--gray-800); margin-bottom: 0.25rem; }
        .timeline-desc { font-size: 0.875rem; color: var(--gray-600); margin-bottom: 0.25rem; }
        .timeline-time { font-size: 0.75rem; color: var(--gray-400); }
        .form-group { margin-bottom: 1rem; }
        .form-label { display: block; font-size: 0.875rem; font-weight: 600; color: var(--gray-600); margin-bottom: 0.5rem; }
        .form-textarea { width: 100%; padding: 0.75rem; border: 1.5px solid var(--gray-200); border-radius: var(--radius-sm); font-size: 0.875rem; font-family: inherit; resize: vertical; min-height: 100px; }
        .form-textarea:focus { outline: none; border-color: var(--green); }
        .modal { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center; }
        .modal.show { display: flex; }
        .modal-content { background: white; padding: 2rem; border-radius: var(--radius); max-width: 400px; width: 90%; }
        .modal-title { font-size: 1.25rem; font-weight: 700; margin-bottom: 1rem; }
        .modal-actions { display: flex; gap: 1rem; justify-content: flex-end; margin-top: 1.5rem; }
    </style>
</head>
<body>
    <nav class="topnav">
        <a href="${pageContext.request.contextPath}/shipper/delivery" class="nav-logo">
            <i class="fas fa-motorcycle"></i> Shipper Panel
        </a>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/shipper/delivery">Giao Hàng</a>
            <a href="${pageContext.request.contextPath}/shipper/my-deliveries" class="active">Đơn Của Tôi</a>
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
        
        <h1 class="page-title"><i class="fas fa-truck"></i> Chi Tiết Giao Hàng #<%= delivery.getDeliveryId() %></h1>
        
        <div class="card">
            <div class="card-header">
                <div class="card-title">
                    <i class="fas fa-box"></i> Thông Tin Đơn Hàng
                </div>
                <span class="badge <%= delivery.getStatusClass() %>"><%= delivery.getStatusLabel() %></span>
            </div>
            
            <div class="info-grid">
                <div class="info-item">
                    <div class="info-label">Mã Giao Hàng</div>
                    <div class="info-value">#<%= delivery.getDeliveryId() %></div>
                </div>
                <div class="info-item">
                    <div class="info-label">Mã Đơn Hàng</div>
                    <div class="info-value">#<%= delivery.getOrderId() %></div>
                </div>
                <div class="info-item">
                    <div class="info-label">Người Nhận</div>
                    <div class="info-value"><%= delivery.getRecipientName() %></div>
                </div>
                <div class="info-item">
                    <div class="info-label">Số Điện Thoại</div>
                    <div class="info-value"><%= delivery.getRecipientPhone() %></div>
                </div>
                <div class="info-item" style="grid-column: 1 / -1;">
                    <div class="info-label">Địa Chỉ Giao Hàng</div>
                    <div class="info-value"><%= delivery.getDeliveryAddress() %></div>
                </div>
                <div class="info-item">
                    <div class="info-label">Tổng Tiền</div>
                    <div class="info-value" style="color: var(--green-dark); font-weight: 700; font-size: 1.1rem;">
                        <%= nf.format(delivery.getOrderTotal()) %>đ
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-label">Ngày Được Giao</div>
                    <div class="info-value"><%= delivery.getAssignedDate() != null ? sdf.format(delivery.getAssignedDate()) : "-" %></div>
                </div>
            </div>
            
            <% if (delivery.getNote() != null && !delivery.getNote().isEmpty()) { %>
            <div class="info-item" style="margin-top: 1rem;">
                <div class="info-label">Ghi Chú</div>
                <div class="info-value"><%= delivery.getNote() %></div>
            </div>
            <% } %>
            
            <div class="action-section">
                <div class="card-title" style="margin-bottom: 1rem;">
                    <i class="fas fa-cogs"></i> Hành Động
                </div>
                
                <div class="btn-group">
                    <% if (delivery.canBeAccepted()) { %>
                    <form action="${pageContext.request.contextPath}/shipper/delivery-action" method="post">
                        <input type="hidden" name="deliveryId" value="<%= delivery.getDeliveryId() %>">
                        <input type="hidden" name="action" value="accept">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-check"></i> Chấp Nhận Giao Hàng
                        </button>
                    </form>
                    <% } %>
                    
                    <% if (delivery.canBePickedUp()) { %>
                    <form action="${pageContext.request.contextPath}/shipper/delivery-action" method="post" style="display:inline;">
                        <input type="hidden" name="deliveryId" value="<%= delivery.getDeliveryId() %>">
                        <input type="hidden" name="action" value="pickingup">
                        <button type="submit" class="btn btn-warning">
                            <i class="fas fa-box"></i> Bắt Đầu Lấy Hàng
                        </button>
                    </form>
                    <% } %>
                    
                    <% if (delivery.canBeDelivered()) { %>
                    <form action="${pageContext.request.contextPath}/shipper/delivery-action" method="post" style="display:inline;">
                        <input type="hidden" name="deliveryId" value="<%= delivery.getDeliveryId() %>">
                        <input type="hidden" name="action" value="delivering">
                        <button type="submit" class="btn btn-warning">
                            <i class="fas fa-truck"></i> Bắt Đầu Giao Hàng
                        </button>
                    </form>
                    <% } %>
                    
                    <% if (delivery.canBeConfirmed()) { %>
                    <form action="${pageContext.request.contextPath}/shipper/delivery-action" method="post" style="display:inline;">
                        <input type="hidden" name="deliveryId" value="<%= delivery.getDeliveryId() %>">
                        <input type="hidden" name="action" value="deliver">
                        <div style="display: flex; gap: 0.5rem; align-items: end;">
                            <div class="form-group" style="margin-bottom: 0;">
                                <input type="text" name="note" class="form-textarea" placeholder="Ghi chú (tùy chọn)" style="min-height: 40px; width: 200px;">
                            </div>
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-check-circle"></i> Xác Nhận Đã Giao
                            </button>
                        </div>
                    </form>
                    <button onclick="showFailModal()" class="btn btn-danger">
                        <i class="fas fa-times-circle"></i> Giao Thất Bại
                    </button>
                    <% } %>
                </div>
            </div>
        </div>
        
        <div class="card">
            <div class="card-header">
                <div class="card-title">
                    <i class="fas fa-history"></i> Lịch Sử Trạng Thái
                </div>
            </div>
            
            <% if (trackingHistory == null || trackingHistory.isEmpty()) { %>
            <p style="color: var(--gray-400); text-align: center; padding: 2rem;">Chưa có lịch sử trạng thái</p>
            <% } else { %>
            <ul class="timeline">
                <% for (OrderTracking tracking : trackingHistory) { %>
                <li class="timeline-item">
                    <div class="timeline-icon active"><i class="fas fa-circle"></i></div>
                    <div class="timeline-content">
                        <div class="timeline-status"><%= tracking.getStatus() %></div>
                        <div class="timeline-desc"><%= tracking.getDescription() %></div>
                        <div class="timeline-time">
                            <%= tracking.getCreatedAt() != null ? sdf.format(tracking.getCreatedAt()) : "" %>
                            <% if (tracking.getUpdatedByName() != null) { %>
                            - <%= tracking.getUpdatedByName() %>
                            <% } %>
                        </div>
                    </div>
                </li>
                <% } %>
            </ul>
            <% } %>
        </div>
        
        <a href="${pageContext.request.contextPath}/shipper/my-deliveries" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Quay Lại
        </a>
    </div>
    
    <!-- Fail Modal -->
    <div id="failModal" class="modal">
        <div class="modal-content">
            <h3 class="modal-title"><i class="fas fa-exclamation-triangle"></i> Xác Nhận Giao Thất Bại</h3>
            <form action="${pageContext.request.contextPath}/shipper/delivery-action" method="post">
                <input type="hidden" name="deliveryId" value="<%= delivery.getDeliveryId() %>">
                <input type="hidden" name="action" value="fail">
                <div class="form-group">
                    <label class="form-label">Lý do giao hàng thất bại <span style="color: #ef4444;">*</span></label>
                    <textarea name="note" class="form-textarea" required placeholder="Vui lòng nhập lý do..."></textarea>
                </div>
                <div class="modal-actions">
                    <button type="button" onclick="hideFailModal()" class="btn btn-secondary">Hủy</button>
                    <button type="submit" class="btn btn-danger">Xác Nhận</button>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        function showFailModal() {
            document.getElementById('failModal').classList.add('show');
        }
        function hideFailModal() {
            document.getElementById('failModal').classList.remove('show');
        }
    </script>
</body>
</html>
