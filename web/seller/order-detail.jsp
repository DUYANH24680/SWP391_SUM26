<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Order" %>
<%@ page import="model.OrderDetail" %>
<%@ page import="model.Shop" %>
<%@ page import="model.DeliveryOrder" %>
<%@ page import="model.OrderTracking" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="Utils.ImageUrlUtil" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    Account user = (Account) session.getAttribute("Account");
    String userRole = (String) session.getAttribute("role");
    if (user == null || (!"seller".equalsIgnoreCase(user.getRoleName()) && !"seller".equalsIgnoreCase(userRole))) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    Order order = (Order) request.getAttribute("order");
    if (order == null) {
        response.sendRedirect(request.getContextPath() + "/seller/orders");
        return;
    }
    
    List<OrderDetail> orderItems = (List<OrderDetail>) request.getAttribute("orderItems"); // Seller's items only
    if (orderItems == null) {
        orderItems = new java.util.ArrayList<>();
    }
    
    List<OrderDetail> allOrderItems = (List<OrderDetail>) request.getAttribute("allOrderItems"); // All items
    if (allOrderItems == null) {
        allOrderItems = new java.util.ArrayList<>();
    }
    
    Shop sellerShop = (Shop) request.getAttribute("sellerShop");
    Double sellerRevenue = (Double) request.getAttribute("sellerRevenue");
    if (sellerRevenue == null) sellerRevenue = 0.0;
    
    Integer sellerItemCount = (Integer) request.getAttribute("sellerItemCount");
    if (sellerItemCount == null) sellerItemCount = 0;
    
    Boolean isMultiShopOrder = (Boolean) request.getAttribute("isMultiShopOrder");
    if (isMultiShopOrder == null) isMultiShopOrder = false;
    
    DeliveryOrder deliveryInfo = (DeliveryOrder) request.getAttribute("deliveryInfo");
    
    List<OrderTracking> trackingHistory = (List<OrderTracking>) request.getAttribute("trackingHistory");
    if (trackingHistory == null) {
        trackingHistory = new java.util.ArrayList<>();
    }

    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");

    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(java.util.Locale.forLanguageTag("vi"));
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi Tiết Đơn Hàng #<%= order.getId() %> | Seller Dashboard</title>
    <style>
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 1rem;
            flex-wrap: wrap;
        }
        .page-title {
            font-size: 1.5rem;
            font-weight: 800;
            color: var(--gray-800);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .page-title i { color: var(--green); }
        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            border-radius: var(--radius-sm);
            font-size: 0.875rem;
            font-weight: 500;
            color: var(--gray-600);
            background: var(--white);
            border: 1px solid var(--gray-200);
            text-decoration: none;
            transition: all 0.15s;
        }
        .back-btn:hover { background: var(--gray-50); color: var(--gray-800); }

        .card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
            margin-bottom: 1.25rem;
        }
        .card-header {
            padding: 1.1rem 1.5rem;
            border-bottom: 1px solid var(--gray-200);
            background: var(--gray-50);
        }
        .card-title {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--gray-800);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .card-body { padding: 1.5rem; }

        .order-summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.25rem;
        }
        .order-info-item {
            display: flex;
            flex-direction: column;
            gap: 0.25rem;
        }
        .order-info-label {
            font-size: 0.75rem;
            font-weight: 700;
            color: var(--gray-400);
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        .order-info-value {
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--gray-800);
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.35rem 0.8rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 700;
            text-transform: uppercase;
        }
        .badge-yellow { background: #fef9c3; color: #854d0e; }
        .badge-blue { background: #dbeafe; color: #1e40af; }
        .badge-green { background: #dcfce7; color: #166534; }
        .badge-red { background: #fee2e2; color: #991b1b; }
        .badge-gray { background: var(--gray-100); color: var(--gray-600); }

        .revenue-card {
            background: linear-gradient(135deg, var(--green) 0%, var(--green-dark) 100%);
            color: white;
            padding: 1.5rem;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            margin-bottom: 1.25rem;
        }
        .revenue-label {
            font-size: 0.85rem;
            opacity: 0.9;
            margin-bottom: 0.4rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .revenue-value {
            font-size: 1.8rem;
            font-weight: 800;
        }

        .product-list {
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
        }
        .product-item {
            display: flex;
            gap: 1rem;
            padding: 1rem;
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-sm);
            background: var(--gray-50);
            align-items: center;
        }
        .product-image {
            width: 72px;
            height: 72px;
            border-radius: var(--radius-sm);
            object-fit: cover;
            border: 1px solid var(--gray-200);
        }
        .product-placeholder {
            width: 72px;
            height: 72px;
            border-radius: var(--radius-sm);
            background: var(--green-light);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
        }
        .product-details {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 0.25rem;
        }
        .product-title {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--gray-800);
        }
        .product-meta {
            display: flex;
            align-items: center;
            gap: 1rem;
            font-size: 0.85rem;
            color: var(--gray-600);
        }
        .product-price {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--green-dark);
        }

        .pricing-summary {
            background: var(--gray-50);
            padding: 1.25rem;
            border-radius: var(--radius-sm);
            border: 1px solid var(--gray-200);
        }
        .pricing-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.55rem 0;
        }
        .pricing-row:not(:last-child) {
            border-bottom: 1px solid var(--gray-200);
        }
        .pricing-label { font-size: 0.9rem; color: var(--gray-600); }
        .pricing-value { font-size: 0.9rem; font-weight: 600; color: var(--gray-800); }
        .pricing-total { font-size: 1.1rem; font-weight: 800; color: var(--green-dark); }

        .btn-action {
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            padding: 0.55rem 1.15rem;
            border-radius: var(--radius-sm);
            font-size: 0.85rem;
            font-weight: 600;
            border: none;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.15s;
        }
        .btn-success { background: var(--green); color: white; }
        .btn-success:hover { background: var(--green-dark); }
        .btn-danger { background: #ef4444; color: white; }
        .btn-danger:hover { background: #dc2626; }
        .btn-outline { background: var(--white); border: 1.5px solid var(--gray-200); color: var(--gray-600); }
        .btn-outline:hover { background: var(--gray-50); color: var(--gray-800); }

        .breadcrumb {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            list-style: none;
            font-size: 0.85rem;
            color: var(--gray-400);
        }
        .breadcrumb a { color: var(--gray-600); text-decoration: none; font-weight: 500; }
        .breadcrumb a:hover { color: var(--green-dark); }
        .breadcrumb .current { color: var(--gray-800); font-weight: 600; }
    </style>
</head>
<body>

    <jsp:include page="/sidebar.jsp">
        <jsp:param name="activePage" value="orders"/>
    </jsp:include>

    <main class="sena-main">

        <!-- Breadcrumb Navigation -->
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li><a href="<%= request.getContextPath() %>/seller/dashboard">Dashboard</a></li>
                <li class="separator"><i class="fa-solid fa-chevron-right" style="font-size:0.7rem;"></i></li>
                <li><a href="<%= request.getContextPath() %>/seller/orders">Đơn hàng</a></li>
                <li class="separator"><i class="fa-solid fa-chevron-right" style="font-size:0.7rem;"></i></li>
                <li class="current">#<%= order.getId() %></li>
            </ol>
        </nav>

        <!-- Page Header -->
        <div class="page-header">
            <div class="page-title">
                <i class="fa-solid fa-receipt"></i>
                Chi tiết đơn hàng #<%= order.getId() %>
            </div>
            <a href="<%= request.getContextPath() %>/seller/orders" class="back-btn">
                <i class="fa-solid fa-arrow-left"></i>
                Quay lại danh sách
            </a>
        </div>

        <!-- Alerts -->
        <% if (message != null) { %>
            <div class="sena-alert sena-alert-success">
                <i class="fa-solid fa-circle-check"></i>
                <%= message %>
            </div>
        <% } %>
        <% if (error != null) { %>
            <div class="sena-alert sena-alert-danger">
                <i class="fa-solid fa-circle-exclamation"></i>
                <%= error %>
            </div>
        <% } %>
        <% if (isMultiShopOrder != null && isMultiShopOrder) { %>
            <div class="sena-alert sena-alert-warning">
                <i class="fa-solid fa-circle-info"></i>
                <div>
                    <strong>Đơn hàng đa-shop:</strong> Bạn đang xem <%= sellerItemCount %> sản phẩm thuộc shop của bạn trong tổng số <%= allOrderItems.size() %> sản phẩm của đơn hàng này.
                </div>
            </div>
        <% } %>

        <!-- Seller Revenue Summary Card -->
        <div class="revenue-card">
            <div class="revenue-label">
                <i class="fa-solid fa-sack-dollar"></i>
                Doanh thu shop nhận từ đơn hàng này (tạm tính)
            </div>
            <div class="revenue-value">
                <%= nf.format(sellerRevenue) %> đ
            </div>
        </div>

        <!-- Order Summary Card -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">
                    <i class="fa-solid fa-circle-info"></i>
                    Thông tin chung đơn hàng
                </h3>
            </div>
            <div class="card-body">
                <div class="order-summary">
                    <div class="order-info-item">
                        <div class="order-info-label">Mã đơn hàng</div>
                        <div class="order-info-value">#<%= order.getId() %></div>
                    </div>
                    <div class="order-info-item">
                        <div class="order-info-label">Thời gian đặt</div>
                        <div class="order-info-value"><%= order.getOrderDate() != null ? sdf.format(order.getOrderDate()) : "N/A" %></div>
                    </div>
                    <div class="order-info-item">
                        <div class="order-info-label">Trạng thái</div>
                        <div class="order-info-value">
                            <span class="status-badge <%= order.getStatusClass() %>">
                                <%= order.getStatusLabel() %>
                            </span>
                        </div>
                    </div>
                    <div class="order-info-item">
                        <div class="order-info-label">Khách hàng</div>
                        <div class="order-info-value"><%= order.getCustomerName() != null ? order.getCustomerName() : "N/A" %></div>
                    </div>
                    <div class="order-info-item">
                        <div class="order-info-label">Phương thức thanh toán</div>
                        <div class="order-info-value"><%= order.getPaymentMethod() %> (<%= order.getPaymentStatusLabel() %>)</div>
                    </div>
                    <div class="order-info-item">
                        <div class="order-info-label">Tổng tiền đơn hàng</div>
                        <div class="order-info-value" style="color: var(--green-dark);">
                            <%= nf.format(order.getFinalCost()) %> đ
                        </div>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div style="margin-top: 1.5rem; display: flex; gap: 0.75rem; flex-wrap: wrap;">
                    <% if (order.getStatus() == 1) { // Pending %>
                        <form method="post" action="<%= request.getContextPath() %>/seller/order-detail" onsubmit="return confirm('Bạn có chắc chắn muốn XÁC NHẬN đơn hàng này?')" style="display: inline;">
                            <input type="hidden" name="action" value="confirm">
                            <input type="hidden" name="orderId" value="<%= order.getId() %>">
                            <button type="submit" class="btn-action btn-success">
                                <i class="fa-solid fa-circle-check"></i>
                                Xác nhận đơn hàng
                            </button>
                        </form>
                        <form method="post" action="<%= request.getContextPath() %>/seller/order-detail" onsubmit="return confirm('Bạn có chắc chắn muốn TỪ CHỐI / HỦY đơn hàng này?')" style="display: inline;">
                            <input type="hidden" name="action" value="cancel">
                            <input type="hidden" name="orderId" value="<%= order.getId() %>">
                            <button type="submit" class="btn-action btn-danger">
                                <i class="fa-solid fa-circle-xmark"></i>
                                Từ chối đơn hàng
                            </button>
                        </form>
                    <% } %>

                    <button onclick="window.print()" class="btn-action btn-outline">
                        <i class="fa-solid fa-print"></i>
                        In hóa đơn
                    </button>
                    <button onclick="exportOrderDetails()" class="btn-action btn-outline">
                        <i class="fa-solid fa-file-export"></i>
                        Xuất file CSV
                    </button>
                </div>
            </div>
        </div>

        <!-- Customer & Delivery Address Card -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">
                    <i class="fa-solid fa-user"></i>
                    Thông tin giao hàng
                </h3>
            </div>
            <div class="card-body">
                <div class="order-summary">
                    <div class="order-info-item">
                        <div class="order-info-label">Tên tài khoản</div>
                        <div class="order-info-value"><%= order.getCustomerName() != null ? order.getCustomerName() : "Khách hàng" %></div>
                    </div>
                    <div class="order-info-item">
                        <div class="order-info-label">Người nhận hàng</div>
                        <div class="order-info-value"><%= order.getRecipientName() %></div>
                    </div>
                    <div class="order-info-item">
                        <div class="order-info-label">Số điện thoại</div>
                        <div class="order-info-value"><%= order.getRecipientPhone() %></div>
                    </div>
                    <div class="order-info-item" style="grid-column: 1 / -1;">
                        <div class="order-info-label">Địa chỉ nhận hàng</div>
                        <div class="order-info-value"><%= order.getAddress() %></div>
                    </div>
                    <% if (order.getNote() != null && !order.getNote().trim().isEmpty()) { %>
                        <div class="order-info-item" style="grid-column: 1 / -1;">
                            <div class="order-info-label">Ghi chú từ khách hàng</div>
                            <div class="order-info-value" style="font-style: italic; color: var(--gray-600);">
                                "<%= order.getNote() %>"
                            </div>
                        </div>
                    <% } %>
                    <% if (order.getStatus() == 5 && order.getCancelReason() != null && !order.getCancelReason().isEmpty()) { %>
                        <div class="order-info-item" style="grid-column: 1 / -1; color: #dc2626;">
                            <div class="order-info-label" style="color: #dc2626;">Lý do hủy</div>
                            <div class="order-info-value"><%= order.getCancelReason() %></div>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Products Card -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">
                    <i class="fa-solid fa-box"></i>
                    Sản phẩm thuộc shop (<%= orderItems.size() %> sản phẩm)
                </h3>
            </div>
            <div class="card-body">
                <div class="product-list">
                    <% for (OrderDetail item : orderItems) {
                        String imgUrl = ImageUrlUtil.resolve(item.getProductImage(), request.getContextPath());
                    %>
                        <div class="product-item">
                            <% if (imgUrl != null && !imgUrl.isEmpty()) { %>
                                <img src="<%= imgUrl %>" alt="<%= item.getProductTitle() %>" class="product-image" onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
                                <div class="product-placeholder" style="display:none;">🍎</div>
                            <% } else { %>
                                <div class="product-placeholder">🍎</div>
                            <% } %>
                            <div class="product-details">
                                <div class="product-title"><%= item.getProductTitle() %></div>
                                <div class="product-meta">
                                    <span>Số lượng: <strong><%= item.getQuantity() %></strong></span>
                                    <span>Đơn giá: <strong><%= nf.format(item.getUnitPrice()) %> đ</strong></span>
                                    <span>Đơn vị: <%= item.getProductUnit() != null ? item.getProductUnit() : "kg" %></span>
                                </div>
                                <div class="product-price">
                                    Thành tiền: <%= nf.format(item.getTotalPrice()) %> đ
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Delivery Status Card -->
        <% if (order.getStatus() >= 2) { %>
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">
                        <i class="fa-solid fa-truck"></i>
                        Trạng thái giao hàng
                    </h3>
                </div>
                <div class="card-body">
                    <% if (deliveryInfo == null) { %>
                        <div class="sena-alert sena-alert-warning" style="margin: 0;">
                            <i class="fa-solid fa-clock"></i>
                            Đơn hàng đã được xác nhận và đang chờ Staff phân công Shipper.
                        </div>
                    <% } else { %>
                        <div class="order-summary">
                            <div class="order-info-item">
                                <div class="order-info-label">Trạng thái giao hàng</div>
                                <div class="order-info-value">
                                    <% 
                                        String deliveryStatus = "Chưa xác định";
                                        if (deliveryInfo.getStatus() == 1) deliveryStatus = "Đã giao shipper";
                                        else if (deliveryInfo.getStatus() == 2) deliveryStatus = "Shipper đã nhận";
                                        else if (deliveryInfo.getStatus() == 3) deliveryStatus = "Đang lấy hàng";
                                        else if (deliveryInfo.getStatus() == 4) deliveryStatus = "Đang giao hàng";
                                        else if (deliveryInfo.getStatus() == 5) deliveryStatus = "Đã giao thành công";
                                        else if (deliveryInfo.getStatus() == 6) deliveryStatus = "Giao thất bại";
                                    %>
                                    <%= deliveryStatus %>
                                </div>
                            </div>
                            <% if (deliveryInfo.getShipperName() != null) { %>
                                <div class="order-info-item">
                                    <div class="order-info-label">Shipper</div>
                                    <div class="order-info-value"><%= deliveryInfo.getShipperName() %></div>
                                </div>
                            <% } %>
                            <% if (deliveryInfo.getShipperPhone() != null) { %>
                                <div class="order-info-item">
                                    <div class="order-info-label">SĐT Shipper</div>
                                    <div class="order-info-value"><%= deliveryInfo.getShipperPhone() %></div>
                                </div>
                            <% } %>
                            <% if (deliveryInfo.getAssignedDate() != null) { %>
                                <div class="order-info-item">
                                    <div class="order-info-label">Ngày phân công</div>
                                    <div class="order-info-value"><%= sdf.format(deliveryInfo.getAssignedDate()) %></div>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
            </div>
        <% } %>

        <!-- Seller Revenue Breakdown Card -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">
                    <i class="fa-solid fa-calculator"></i>
                    Chi tiết doanh thu shop
                </h3>
            </div>
            <div class="card-body">
                <div class="pricing-summary">
                    <div class="pricing-row">
                        <div class="pricing-label">Tổng tiền sản phẩm của shop</div>
                        <div class="pricing-value"><%= nf.format(sellerRevenue) %> đ</div>
                    </div>
                    <div class="pricing-row">
                        <div class="pricing-label">Số lượng món hàng</div>
                        <div class="pricing-value"><%= sellerItemCount %> món</div>
                    </div>
                    <div class="pricing-row">
                        <div class="pricing-label">Phí hoa hồng sàn (tạm tính 5%)</div>
                        <div class="pricing-value" style="color: #ef4444;">-<%= nf.format(sellerRevenue * 0.05) %> đ</div>
                    </div>
                    <div class="pricing-row">
                        <div class="pricing-label"><strong>Doanh thu thực nhận của Shop (tạm tính)</strong></div>
                        <div class="pricing-value pricing-total"><%= nf.format(sellerRevenue * 0.95) %> đ</div>
                    </div>
                </div>
            </div>
        </div>

    </main>
    </div><!-- end sena-layout -->

    <script>
    function exportOrderDetails() {
        const orderData = [
            'Mã đơn hàng,#<%= order.getId() %>',
            'Ngày đặt,<%= order.getOrderDate() != null ? sdf.format(order.getOrderDate()) : "" %>',
            'Khách hàng,<%= order.getCustomerName() != null ? order.getCustomerName().replace(",", ";") : "N/A" %>',
            'Trạng thái,<%= order.getStatusLabel() %>',
            'Tổng tiền shop,<%= nf.format(sellerRevenue) %> đ',
            '',
            'Sản phẩm:'
            <% for (OrderDetail item : orderItems) { %>,
            '<%= item.getProductTitle().replace(",", ";") %>,<%= item.getQuantity() %>,<%= nf.format(item.getUnitPrice()) %> đ,<%= nf.format(item.getTotalPrice()) %> đ'
            <% } %>
        ];
        
        const csvContent = orderData.join('\n');
        const blob = new Blob(['\ufeff' + csvContent], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = 'order_<%= order.getId() %>_details.csv';
        link.click();
    }
    </script>
</body>
</html>