<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Order" %>
<%@ page import="model.OrderDetail" %>
<%@ page import="model.DeliveryOrder" %>
<%@ page import="model.OrderTracking" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="Utils.ImageUrlUtil" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    Account user = (Account) session.getAttribute("Account");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    Order order = (Order) request.getAttribute("order");
    if (order == null) {
        response.sendRedirect(request.getContextPath() + "/my-orders");
        return;
    }
    
    List<OrderDetail> orderItems = (List<OrderDetail>) request.getAttribute("orderItems");
    if (orderItems == null) {
        orderItems = new java.util.ArrayList<>();
    }
    
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
    <title>Chi Tiết Đơn Hàng #<%= order.getId() %> | SenaFruit</title>
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

        /* Timeline */
        .timeline {
            position: relative;
            padding: 0.5rem 0;
        }
        .timeline-item {
            display: flex;
            align-items: flex-start;
            gap: 1rem;
            padding: 0.85rem 0;
            position: relative;
        }
        .timeline-item:not(:last-child)::after {
            content: '';
            position: absolute;
            left: 17px;
            top: 42px;
            bottom: -12px;
            width: 2px;
            background: var(--gray-200);
        }
        .timeline-item.completed::after { background: var(--green); }

        .timeline-icon {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.9rem;
            flex-shrink: 0;
            position: relative;
            z-index: 1;
        }
        .timeline-icon.completed { background: var(--green); color: white; }
        .timeline-icon.active { background: #f59e0b; color: white; }
        .timeline-icon.pending { background: var(--gray-200); color: var(--gray-600); }

        .timeline-content {
            flex: 1;
            padding-top: 0.2rem;
        }
        .timeline-title {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--gray-800);
            margin-bottom: 0.2rem;
        }
        .timeline-desc {
            font-size: 0.85rem;
            color: var(--gray-600);
            margin-bottom: 0.2rem;
        }
        .timeline-time {
            font-size: 0.78rem;
            color: var(--gray-400);
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
        .shop-name {
            font-size: 0.8rem;
            color: var(--gray-600);
            font-style: italic;
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
                <li><a href="<%= request.getContextPath() %>/home.jsp">Trang chủ</a></li>
                <li class="separator"><i class="fa-solid fa-chevron-right" style="font-size:0.7rem;"></i></li>
                <li><a href="<%= request.getContextPath() %>/my-orders">Đơn hàng của tôi</a></li>
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
            <a href="<%= request.getContextPath() %>/my-orders" class="back-btn">
                <i class="fa-solid fa-arrow-left"></i>
                Quay lại danh sách đơn hàng
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

        <!-- Order Summary Card -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">
                    <i class="fa-solid fa-circle-info"></i>
                    Thông tin đơn hàng
                </h3>
            </div>
            <div class="card-body">
                <div class="order-summary">
                    <div class="order-info-item">
                        <div class="order-info-label">Mã đơn hàng</div>
                        <div class="order-info-value">#<%= order.getId() %></div>
                    </div>
                    <div class="order-info-item">
                        <div class="order-info-label">Ngày đặt hàng</div>
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
                        <div class="order-info-label">Thanh toán</div>
                        <div class="order-info-value"><%= order.getPaymentMethod() %> (<%= order.getPaymentStatusLabel() %>)</div>
                    </div>
                    <div class="order-info-item">
                        <div class="order-info-label">Tổng thanh toán</div>
                        <div class="order-info-value" style="color: var(--green-dark); font-size: 1.1rem;">
                            <%= nf.format(order.getFinalCost()) %> đ
                        </div>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div style="margin-top: 1.5rem; display: flex; gap: 0.75rem; flex-wrap: wrap;">
                    <% if (order.getStatus() == 1) { // Pending %>
                        <form method="post" action="<%= request.getContextPath() %>/order-detail" style="display: inline;" onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn hàng này?')">
                            <input type="hidden" name="action" value="cancel">
                            <input type="hidden" name="orderId" value="<%= order.getId() %>">
                            <button type="submit" class="btn-action btn-danger">
                                <i class="fa-solid fa-rectangle-xmark"></i>
                                Hủy đơn hàng
                            </button>
                        </form>
                    <% } %>

                    <button onclick="window.print()" class="btn-action btn-outline">
                        <i class="fa-solid fa-print"></i>
                        In hóa đơn
                    </button>
                </div>
            </div>
        </div>

        <!-- Delivery Timeline Card -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">
                    <i class="fa-solid fa-truck"></i>
                    Theo dõi tiến trình đơn hàng
                </h3>
            </div>
            <div class="card-body">
                <div class="timeline">
                    <!-- Order Placed -->
                    <div class="timeline-item completed">
                        <div class="timeline-icon completed">
                            <i class="fa-solid fa-check"></i>
                        </div>
                        <div class="timeline-content">
                            <div class="timeline-title">Đặt hàng thành công</div>
                            <div class="timeline-desc">Đơn hàng đã được tạo thành công</div>
                            <div class="timeline-time"><%= order.getOrderDate() != null ? sdf.format(order.getOrderDate()) : "" %></div>
                        </div>
                    </div>

                    <!-- Shop Confirmation -->
                    <div class="timeline-item <%= order.getStatus() >= 2 ? "completed" : (order.getStatus() == 1 ? "active" : "pending") %>">
                        <div class="timeline-icon <%= order.getStatus() >= 2 ? "completed" : (order.getStatus() == 1 ? "active" : "pending") %>">
                            <i class="fa-solid <%= order.getStatus() >= 2 ? "fa-check" : (order.getStatus() == 1 ? "fa-clock" : "fa-circle") %>"></i>
                        </div>
                        <div class="timeline-content">
                            <div class="timeline-title">
                                <%= order.getStatus() >= 2 ? "Shop đã xác nhận" : (order.getStatus() == 1 ? "Chờ shop xác nhận" : "Chờ xác nhận") %>
                            </div>
                            <div class="timeline-desc">
                                <%= order.getStatus() >= 2 ? "Shop đã xác nhận đơn hàng và đang chuẩn bị đóng gói" : "Đơn hàng đang chờ shop duyệt" %>
                            </div>
                        </div>
                    </div>

                    <!-- Delivery Assignment -->
                    <div class="timeline-item <%= (deliveryInfo != null) ? "completed" : (order.getStatus() >= 2 ? "active" : "pending") %>">
                        <div class="timeline-icon <%= (deliveryInfo != null) ? "completed" : (order.getStatus() >= 2 ? "active" : "pending") %>">
                            <i class="fa-solid <%= (deliveryInfo != null) ? "fa-check" : (order.getStatus() >= 2 ? "fa-clock" : "fa-circle") %>"></i>
                        </div>
                        <div class="timeline-content">
                            <div class="timeline-title">
                                <%= (deliveryInfo != null) ? "Đã giao Shipper" : "Chờ phân công Shipper" %>
                            </div>
                            <div class="timeline-desc">
                                <%= (deliveryInfo != null) ? "Đã gán cho Shipper giao hàng" : "Đang chờ phân công đơn vị vận chuyển" %>
                            </div>
                            <% if (deliveryInfo != null && deliveryInfo.getShipperName() != null) { %>
                                <div class="timeline-time">Shipper: <%= deliveryInfo.getShipperName() %></div>
                            <% } %>
                        </div>
                    </div>

                    <% if (deliveryInfo != null) { %>
                        <!-- Shipper Accepted -->
                        <div class="timeline-item <%= (deliveryInfo.getStatus() >= 2) ? "completed" : (deliveryInfo.getStatus() == 1 ? "active" : "pending") %>">
                            <div class="timeline-icon <%= (deliveryInfo.getStatus() >= 2) ? "completed" : (deliveryInfo.getStatus() == 1 ? "active" : "pending") %>">
                                <i class="fa-solid <%= (deliveryInfo.getStatus() >= 2) ? "fa-check" : (deliveryInfo.getStatus() == 1 ? "fa-clock" : "fa-circle") %>"></i>
                            </div>
                            <div class="timeline-content">
                                <div class="timeline-title">
                                    <%= (deliveryInfo.getStatus() >= 2) ? "Shipper đã tiếp nhận" : "Chờ Shipper nhận đơn" %>
                                </div>
                                <div class="timeline-desc">
                                    <%= (deliveryInfo.getStatus() >= 2) ? "Shipper đã nhận và đang di chuyển đến shop" : "Shipper chuẩn bị nhận đơn" %>
                                </div>
                                <% if (deliveryInfo.getAcceptedDate() != null) { %>
                                    <div class="timeline-time"><%= sdf.format(deliveryInfo.getAcceptedDate()) %></div>
                                <% } %>
                            </div>
                        </div>

                        <!-- Delivering -->
                        <div class="timeline-item <%= (deliveryInfo.getStatus() >= 4) ? "completed" : (deliveryInfo.getStatus() == 3 ? "active" : "pending") %>">
                            <div class="timeline-icon <%= (deliveryInfo.getStatus() >= 4) ? "completed" : (deliveryInfo.getStatus() == 3 ? "active" : "pending") %>">
                                <i class="fa-solid <%= (deliveryInfo.getStatus() >= 4) ? "fa-check" : (deliveryInfo.getStatus() == 3 ? "fa-truck-fast" : "fa-circle") %>"></i>
                            </div>
                            <div class="timeline-content">
                                <div class="timeline-title">
                                    <%= (deliveryInfo.getStatus() >= 4) ? "Đang trên đường giao" : "Chuẩn bị giao" %>
                                </div>
                                <div class="timeline-desc">
                                    <%= (deliveryInfo.getStatus() >= 4) ? "Đơn hàng đang được shipper giao đến địa chỉ của bạn" : "Đơn hàng sẽ sớm được vận chuyển" %>
                                </div>
                            </div>
                        </div>
                    <% } %>

                    <!-- Delivered -->
                    <div class="timeline-item <%= (order.getStatus() == 4) ? "completed" : "pending" %>">
                        <div class="timeline-icon <%= (order.getStatus() == 4) ? "completed" : "pending" %>">
                            <i class="fa-solid <%= (order.getStatus() == 4) ? "fa-circle-check" : "fa-circle" %>"></i>
                        </div>
                        <div class="timeline-content">
                            <div class="timeline-title">
                                <%= (order.getStatus() == 4) ? "Giao hàng thành công" : "Chờ hoàn thành" %>
                            </div>
                            <div class="timeline-desc">
                                <%= (order.getStatus() == 4) ? "Cảm ơn bạn đã mua hàng tại SenaFruit!" : "Đơn hàng chưa giao thành công" %>
                            </div>
                            <% if (order.getStatus() == 4 && deliveryInfo != null && deliveryInfo.getDeliveryTime() != null) { %>
                                <div class="timeline-time"><%= sdf.format(deliveryInfo.getDeliveryTime()) %></div>
                            <% } %>
                        </div>
                    </div>

                    <!-- Cancelled -->
                    <% if (order.getStatus() == 5) { %>
                        <div class="timeline-item" style="border-left: 2px solid #ef4444;">
                            <div class="timeline-icon" style="background: #ef4444; color: white;">
                                <i class="fa-solid fa-circle-xmark"></i>
                            </div>
                            <div class="timeline-content">
                                <div class="timeline-title" style="color: #ef4444;">Đơn hàng đã bị hủy</div>
                                <div class="timeline-desc">
                                    <%= order.getCancelReason() != null ? order.getCancelReason() : "Đơn hàng đã bị hủy" %>
                                </div>
                                <% if (order.getCancelledAt() != null) { %>
                                    <div class="timeline-time"><%= sdf.format(order.getCancelledAt()) %></div>
                                <% } %>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Shipping Information Card -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">
                    <i class="fa-solid fa-location-dot"></i>
                    Địa chỉ và thông tin nhận hàng
                </h3>
            </div>
            <div class="card-body">
                <div class="order-summary">
                    <div class="order-info-item">
                        <div class="order-info-label">Người nhận hàng</div>
                        <div class="order-info-value"><%= order.getRecipientName() %></div>
                    </div>
                    <div class="order-info-item">
                        <div class="order-info-label">Số điện thoại liên hệ</div>
                        <div class="order-info-value"><%= order.getRecipientPhone() %></div>
                    </div>
                    <div class="order-info-item" style="grid-column: 1 / -1;">
                        <div class="order-info-label">Địa chỉ giao hàng</div>
                        <div class="order-info-value"><%= order.getAddress() %></div>
                    </div>
                    <% if (order.getNote() != null && !order.getNote().trim().isEmpty()) { %>
                        <div class="order-info-item" style="grid-column: 1 / -1;">
                            <div class="order-info-label">Ghi chú giao hàng</div>
                            <div class="order-info-value" style="font-style: italic; color: var(--gray-600);"><%= order.getNote() %></div>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Products List Card -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">
                    <i class="fa-solid fa-basket-shopping"></i>
                    Danh sách sản phẩm đã đặt (<%= orderItems.size() %> sản phẩm)
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
                                <% if (item.getShopName() != null && !item.getShopName().isEmpty()) { %>
                                    <div class="shop-name"><i class="fa-solid fa-store"></i> <%= item.getShopName() %></div>
                                <% } %>
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

        <!-- Payment Summary Card -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">
                    <i class="fa-solid fa-credit-card"></i>
                    Chi tiết thanh toán
                </h3>
            </div>
            <div class="card-body">
                <div class="pricing-summary">
                    <div class="pricing-row">
                        <div class="pricing-label">Tổng tiền hàng</div>
                        <div class="pricing-value"><%= nf.format(order.getTotalCost()) %> đ</div>
                    </div>
                    <% if (order.getDiscountAmount() > 0) { %>
                        <div class="pricing-row">
                            <div class="pricing-label">Giảm giá từ Shop</div>
                            <div class="pricing-value" style="color: var(--green-dark);">-<%= nf.format(order.getDiscountAmount()) %> đ</div>
                        </div>
                    <% } %>
                    <% if (order.getPlatformDiscountAmount() > 0) { %>
                        <div class="pricing-row">
                            <div class="pricing-label">Giảm giá từ Sàn</div>
                            <div class="pricing-value" style="color: var(--green-dark);">-<%= nf.format(order.getPlatformDiscountAmount()) %> đ</div>
                        </div>
                    <% } %>
                    <div class="pricing-row">
                        <div class="pricing-label">Phí vận chuyển</div>
                        <div class="pricing-value">
                            <% if (order.getShippingFee() > 0) { %>
                                +<%= nf.format(order.getShippingFee()) %> đ
                            <% } else { %>
                                Miễn phí
                            <% } %>
                        </div>
                    </div>
                    <div class="pricing-row">
                        <div class="pricing-label"><strong>Tổng tiền thanh toán</strong></div>
                        <div class="pricing-value pricing-total"><%= nf.format(order.getFinalCost()) %> đ</div>
                    </div>
                    <div class="pricing-row">
                        <div class="pricing-label">Phương thức thanh toán</div>
                        <div class="pricing-value"><%= order.getPaymentMethod() %></div>
                    </div>
                    <div class="pricing-row">
                        <div class="pricing-label">Trạng thái thanh toán</div>
                        <div class="pricing-value">
                            <span class="status-badge <%= order.getPaymentStatus() == 1 ? "badge-green" : (order.getPaymentStatus() == 2 ? "badge-blue" : "badge-yellow") %>">
                                <%= order.getPaymentStatusLabel() %>
                            </span>
                        </div>
                    </div>
                    <% if (order.getVoucherCode() != null && !order.getVoucherCode().trim().isEmpty()) { %>
                        <div class="pricing-row">
                            <div class="pricing-label">Mã voucher áp dụng</div>
                            <div class="pricing-value"><%= order.getVoucherCode() %></div>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>

    </main>
    </div><!-- end sena-layout -->

</body>
</html>