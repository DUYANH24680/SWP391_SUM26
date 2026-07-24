<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Order" %>
<%@ page import="model.OrderDetail" %>
<%@ page import="model.Shop" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="Utils.ImageUrlUtil" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    Account Account = (Account) session.getAttribute("Account");
    if (Account == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String avatarUrl = Account.getAvatar();
    if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
        String fullname = Account.getFullname() != null ? Account.getFullname() : Account.getUsername();
        avatarUrl = "https://ui-avatars.com/api/?name="
                  + java.net.URLEncoder.encode(fullname, "UTF-8")
                  + "&background=4caf50&color=fff&size=80&bold=true&rounded=true";
    }

    Shop shop = (Shop) request.getAttribute("shop");
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    Map<Integer, List<OrderDetail>> detailsMap = (Map<Integer, List<OrderDetail>>) request.getAttribute("detailsMap");
    Boolean shopNotApproved = (Boolean) request.getAttribute("shopNotApproved");
    String shopNotApprovedMsg = (String) request.getAttribute("shopNotApprovedMsg");

    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    if (error == null) {
        error = (String) request.getAttribute("error");
    }
    session.removeAttribute("message");
    session.removeAttribute("error");

    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(java.util.Locale.forLanguageTag("vi"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Đơn Hàng | Seller Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --green:       #4caf50;
            --green-dark:  #388e3c;
            --green-light: #e8f5e9;
            --green-mid:   #c8e6c9;
            --bg:          #f0f4f1;
            --white:       #ffffff;
            --gray-50:     #f8fafb;
            --gray-100:    #eef1ee;
            --gray-200:    #dde5dd;
            --gray-400:    #9aaa9a;
            --gray-600:    #5a6a5a;
            --gray-800:    #2d3d2d;
            --shadow-sm:   0 1px 3px rgba(0,0,0,.08);
            --shadow:      0 4px 12px rgba(0,0,0,.08);
            --shadow-md:   0 8px 24px rgba(0,0,0,.10);
            --radius:      14px;
            --radius-sm:   8px;
        }

        html, body {
            min-height: 100vh;
            font-family: 'Inter', sans-serif;
            color: var(--gray-800);
            background: var(--bg);
        }

        body { display: flex; flex-direction: column; }

        /* ======= TOPNAV ======= */
        .topnav {
            background: var(--white);
            border-bottom: 1px solid var(--gray-200);
            height: 60px;
            display: flex;
            align-items: center;
            padding: 0 2rem;
            gap: 2rem;
            position: sticky;
            top: 0;
            z-index: 100;
            box-shadow: var(--shadow-sm);
        }

        .nav-logo {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 1.3rem;
            font-weight: 800;
            color: var(--green-dark);
            text-decoration: none;
            white-space: nowrap;
            letter-spacing: -0.01em;
        }
        .nav-logo i { color: var(--green); font-size: 1.15rem; }

        .nav-links {
            display: flex;
            gap: 0.25rem;
            margin-left: 1rem;
        }
        .nav-links a {
            padding: 0.4rem 0.85rem;
            border-radius: 6px;
            font-size: 0.875rem;
            font-weight: 500;
            color: var(--gray-600);
            text-decoration: none;
            transition: all 0.15s;
        }
        .nav-links a:hover { background: var(--green-light); color: var(--green-dark); }

        .nav-right {
            margin-left: auto;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        .nav-avatar {
            width: 38px; height: 38px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--green);
        }

        /* ======= LAYOUT ======= */
        .layout {
            display: flex;
            flex: 1;
            max-width: 1280px;
            width: 100%;
            margin: 1.5rem auto;
            padding: 0 1.5rem;
            gap: 1.5rem;
            align-items: flex-start;
        }

        /* ======= SIDEBAR ======= */
        .sidebar {
            width: 200px;
            flex-shrink: 0;
            background: var(--white);
            border-radius: var(--radius);
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--gray-200);
            overflow: hidden;
            position: sticky;
            top: 76px;
        }
        .sidebar-nav { padding: 0.5rem; }
        .sidebar-nav a {
            display: flex;
            align-items: center;
            gap: 0.65rem;
            width: 100%;
            padding: 0.65rem 0.9rem;
            border-radius: var(--radius-sm);
            font-size: 0.875rem;
            font-weight: 500;
            color: var(--gray-600);
            border: none;
            background: transparent;
            cursor: pointer;
            text-align: left;
            text-decoration: none;
            transition: all 0.15s;
        }
        .sidebar-nav a:hover { background: var(--green-light); color: var(--green-dark); }
        .sidebar-nav a.active {
            background: var(--green);
            color: #fff;
            font-weight: 600;
        }
        .sidebar-nav a.logout { color: #e53e3e; }
        .sidebar-nav a.logout:hover { background: #fff5f5; color: #c53030; }

        /* ======= MAIN CONTENT ======= */
        .main { flex: 1; display: flex; flex-direction: column; gap: 1.25rem; min-width: 0; }

        /* ======= ALERTS ======= */
        .alert {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.9rem 1.2rem;
            border-radius: var(--radius-sm);
            font-size: 0.875rem;
            font-weight: 500;
        }
        .alert-success { background: #dcfce7; border: 1px solid #bbf7d0; color: #15803d; }
        .alert-danger { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }
        .alert-warning { background: #fef9c3; border: 1px solid #fde68a; color: #92400e; }

        /* ======= TABS ======= */
        .tabs-card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            padding: 0.5rem;
            display: flex;
            gap: 0.25rem;
            overflow-x: auto;
        }
        .tab-btn {
            padding: 0.6rem 1.2rem;
            border-radius: var(--radius-sm);
            font-size: 0.85rem;
            font-weight: 600;
            border: none;
            background: transparent;
            color: var(--gray-600);
            cursor: pointer;
            transition: all 0.15s;
            white-space: nowrap;
        }
        .tab-btn:hover { background: var(--gray-50); color: var(--gray-800); }
        .tab-btn.active { background: var(--green-light); color: var(--green-dark); }

        /* ======= ORDER CARDS ======= */
        .order-card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            margin-bottom: 1.25rem;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .order-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow);
        }
        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem 1.5rem;
            background: var(--gray-50);
            border-bottom: 1px solid var(--gray-100);
            font-size: 0.85rem;
            flex-wrap: wrap;
            gap: 0.5rem;
        }
        .order-date-id {
            color: var(--gray-600);
        }
        .order-id {
            font-weight: 700;
            color: var(--gray-800);
            margin-left: 0.5rem;
        }
        .badge {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.25rem 0.75rem;
            border-radius: 100px;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
        }
        .badge-green  { background: #dcfce7; color: #166534; }
        .badge-yellow { background: #fef9c3; color: #854d0e; }
        .badge-red    { background: #fee2e2; color: #991b1b; }
        .badge-blue   { background: #dbeafe; color: #1e40af; }
        .badge-gray   { background: var(--gray-100); color: var(--gray-600); }

        .order-body {
            padding: 1.25rem 1.5rem;
        }
        .item-row {
            display: flex;
            gap: 1rem;
            align-items: center;
            margin-bottom: 1rem;
        }
        .item-row:last-child { margin-bottom: 0; }
        .item-img {
            width: 60px;
            height: 60px;
            border-radius: var(--radius-sm);
            object-fit: cover;
            border: 1px solid var(--gray-200);
        }
        .item-img-placeholder {
            width: 60px;
            height: 60px;
            border-radius: var(--radius-sm);
            background: var(--green-light);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.5rem;
        }
        .item-details { flex: 1; }
        .item-title { font-weight: 700; font-size: 0.92rem; color: var(--gray-800); margin-bottom: 0.25rem; }
        .item-meta { font-size: 0.8rem; color: var(--gray-400); }
        .item-price { font-weight: 600; font-size: 0.9rem; color: var(--gray-800); text-align: right; }

        .order-shipping-info {
            border-top: 1px dashed var(--gray-200);
            padding: 0.9rem 1.5rem;
            font-size: 0.82rem;
            color: var(--gray-600);
            background: var(--gray-50);
            line-height: 1.4;
        }

        .order-footer {
            padding: 1rem 1.5rem;
            border-top: 1px solid var(--gray-100);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 1rem;
        }
        .order-cost-details {
            font-size: 0.8rem;
            color: var(--gray-400);
        }
        .order-total-pay {
            font-size: 1.05rem;
            font-weight: 800;
            color: var(--green-dark);
        }
        .order-actions {
            display: flex;
            gap: 0.5rem;
        }
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.45rem;
            padding: 0.55rem 1.15rem;
            border-radius: var(--radius-sm);
            font-size: 0.82rem;
            font-weight: 600;
            cursor: pointer;
            border: none;
            text-decoration: none;
            transition: all 0.15s;
        }
        .btn-green {
            background: var(--green);
            color: #white;
            color: white;
            box-shadow: 0 2px 6px rgba(76,175,80,0.25);
        }
        .btn-green:hover {
            background: var(--green-dark);
            box-shadow: 0 4px 10px rgba(56,142,60,0.3);
            transform: translateY(-1px);
        }
        .btn-danger-outline {
            background: transparent;
            color: #dc2626;
            border: 1.5px solid #fecaca;
        }
        .btn-danger-outline:hover {
            background: #fee2e2;
            border-color: #dc2626;
        }

        /* Empty state */
        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            color: var(--gray-400);
            box-shadow: var(--shadow-sm);
        }
        .empty-state i { font-size: 3.5rem; color: var(--gray-200); margin-bottom: 1rem; display: block; }
        .empty-state p { font-size: 0.95rem; margin-bottom: 1.25rem; color: var(--gray-600); }

        /* ======= RESPONSIVE ======= */
        @media (max-width: 900px) {
            .layout { flex-direction: column; }
            .sidebar { width: 100%; position: static; }
            .sidebar-nav { display: flex; flex-wrap: wrap; gap: 0.25rem; }
            .sidebar-nav a { width: auto; }
        }
    </style>
</head>
<body>

    <jsp:include page="/sidebar.jsp">
        <jsp:param name="activePage" value="orders"/>
    </jsp:include>

        <!-- Main Content -->
        <main class="sena-main">
            
            <% if (message != null) { %>
                <div class="alert alert-success">
                    <i class="fa-solid fa-circle-check"></i>
                    <span><%= message %></span>
                </div>
            <% } %>
            <% if (error != null) { %>
                <div class="alert alert-danger">
                    <i class="fa-solid fa-circle-exclamation"></i>
                    <span><%= error %></span>
                </div>
            <% } %>

            <% if (shopNotApproved != null && shopNotApproved) { %>
                <div class="alert alert-warning">
                    <i class="fa-solid fa-shop-slash"></i>
                    <span><strong>Không thể truy cập:</strong> <%= shopNotApprovedMsg %></span>
                </div>
            <% } else if (shop != null) { %>

                <!-- Tab Filtering -->
                <div class="tabs-card">
                    <button class="tab-btn active" onclick="filterOrders('all')">Tất Cả</button>
                    <button class="tab-btn" onclick="filterOrders('1')">Chờ xác nhận</button>
                    <button class="tab-btn" onclick="filterOrders('2')">Đã xác nhận</button>
                    <button class="tab-btn" onclick="filterOrders('3')">Đang giao</button>
                    <button class="tab-btn" onclick="filterOrders('4')">Đã giao</button>
                    <button class="tab-btn" onclick="filterOrders('5')">Đã hủy</button>
                </div>

                <!-- Order Cards List -->
                <div id="ordersContainer">
                    <% 
                        if (orders != null && !orders.isEmpty()) { 
                            for (Order o : orders) {
                                List<OrderDetail> details = detailsMap.get(o.getId());
                    %>
                        <div class="order-card" data-status="<%= o.getStatus() %>" onclick="window.location.href='<%= request.getContextPath() %>/seller/order-detail?id=<%= o.getId() %>'" style="cursor: pointer;">
                            <!-- Order Header -->
                            <div class="order-header">
                                <div class="order-date-id">
                                    Khách hàng: <strong><%= o.getCustomerName() != null ? o.getCustomerName() : "Khách vãng lai" %></strong>
                                    <span style="color:var(--gray-400); margin:0 0.5rem;">|</span>
                                    Đặt ngày: <strong><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(o.getOrderDate()) %></strong>
                                    <span class="order-id"></span>
                                </div>
                                <span class="badge <%= o.getStatusClass() %>"><%= o.getStatusLabel() %></span>
                            </div>

                            <!-- Order Body (Items) -->
                            <div class="order-body">
                                <% 
                                    if (details != null) {
                                        for (OrderDetail od : details) {
                                %>
                                    <div class="item-row">
                                        <% if (od.getProductImage() != null && !od.getProductImage().trim().isEmpty()) { %>
                                            <img src="<%= ImageUrlUtil.resolve(od.getProductImage(), request.getContextPath()) %>" alt="<%= od.getProductTitle() %>" class="item-img" onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
                                            <div class="item-img-placeholder" style="display:none;">🍎</div>
                                        <% } else { %>
                                            <div class="item-img-placeholder">🍎</div>
                                        <% } %>
                                        
                                        <div class="item-details">
                                            <div class="item-title"><%= od.getProductTitle() %></div>
                                            <div class="item-meta">Đơn vị: <%= od.getProductUnit() != null ? od.getProductUnit() : "kg" %></div>
                                            <div class="item-meta">Số lượng đặt mua: <strong><%= od.getQuantity() %></strong></div>
                                        </div>
                                        <div class="item-price">
                                            Đơn giá: <%= nf.format((long) od.getUnitPrice()) %> đ<br>
                                            <span style="font-size:0.75rem; color:var(--gray-400);">Thành tiền: <%= nf.format((long) od.getTotalPrice()) %> đ</span>
                                        </div>
                                    </div>
                                <% 
                                        } 
                                    } 
                                %>
                            </div>

                            <!-- Shipping info -->
                            <div class="order-shipping-info">
                                <div><i class="fa-solid fa-Account-tag" style="width:14px;color:var(--green);"></i> <strong>Người nhận:</strong> <%= o.getRecipientName() %> - <%= o.getRecipientPhone() %></div>
                                <div style="margin-top:0.2rem;"><i class="fa-solid fa-map-pin" style="width:14px;color:var(--green);"></i> <strong>Địa chỉ nhận:</strong> <%= o.getAddress() %></div>
                                <% if (o.getNote() != null && !o.getNote().isEmpty()) { %>
                                    <div style="margin-top:0.2rem;"><i class="fa-solid fa-comment-dots" style="width:14px;color:var(--green);"></i> <strong>Ghi chú từ khách:</strong> <%= o.getNote() %></div>
                                <% } %>
                                <% if (o.getStatus() == 5 && o.getCancelReason() != null && !o.getCancelReason().isEmpty()) { %>
                                    <div style="margin-top:0.2rem; color: #dc2626;"><i class="fa-solid fa-circle-xmark" style="width:14px;color:#dc2626;"></i> <strong>Lý do hủy:</strong> <%= o.getCancelReason() %></div>
                                <% } %>
                            </div>

                            <!-- Order Footer -->
                            <div class="order-footer">
                                <div class="order-cost-details">
                                    Thanh toán: <strong><%= o.getPaymentMethod() %></strong> (<%= o.getPaymentStatusLabel() %>)<br>
                                    Tiền hàng: <%= nf.format((long) o.getTotalCost()) %> đ 
                                    <% if (o.getDiscountAmount() > 0) { %> | Voucher của Shop: -<%= nf.format((long) o.getDiscountAmount()) %> đ (Mã: <%= o.getVoucherCode() %>)<% } %>
                                    <% if (o.getPlatformDiscountAmount() > 0) { %> | Voucher của Sàn: -<%= nf.format((long) o.getPlatformDiscountAmount()) %> đ (Sàn chịu)<% } %>
                                    | Phí ship: +<%= nf.format((long) o.getShippingFee()) %> đ
                                </div>
                                
                                <div style="display:flex; align-items:center; gap:1.25rem;">
                                    <div class="order-total-pay" style="display:flex; flex-direction:column; align-items:flex-end; gap:0.25rem;">
                                        <div style="font-size:0.82rem; color:var(--gray-600);">Thực thu từ khách: <strong><%= nf.format((long) o.getFinalCost()) %> đ</strong></div>
                                        <div style="font-size:1.05rem; font-weight:800; color:var(--green-dark);">Doanh thu của Shop: <span><%= nf.format((long) o.getShopActualRevenue()) %> đ</span></div>
                                    </div>

                                    <div class="order-actions">
                                        <% if (o.getStatus() == 1) { %>
                                            <!-- Action for Pending orders -->
                                            <form method="post" action="orders" style="display:inline-block;" onclick="event.stopPropagation();" onsubmit="return confirm('Bạn có chắc chắn muốn XÁC NHẬN đơn hàng này không?');">
                                                <input type="hidden" name="action" value="confirm">
                                                <input type="hidden" name="orderId" value="<%= o.getId() %>">
                                                <button type="submit" class="btn btn-green">
                                                    <i class="fa-solid fa-circle-check"></i> Xác Nhận Đơn
                                                </button>
                                            </form>

                                            <form method="post" action="orders" style="display:inline-block;" onclick="event.stopPropagation();" onsubmit="return confirm('Bạn có chắc chắn muốn TỪ CHỐI đơn hàng này không?');">
                                                <input type="hidden" name="action" value="cancel">
                                                <input type="hidden" name="orderId" value="<%= o.getId() %>">
                                                <button type="submit" class="btn btn-danger-outline">
                                                    <i class="fa-solid fa-rectangle-xmark"></i> Từ Chối
                                                </button>
                                            </form>
                                        <% } else if (o.getStatus() == 2) { %>
                                            <span class="text-muted" style="font-size:0.875rem;color:#64748b;">
                                                <i class="fa-solid fa-lock"></i> Đã xác nhận — không thể từ chối
                                            </span>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        </div>
                    <% 
                            }
                        } else { 
                    %>
                        <div class="empty-state">
                            <i class="fa-solid fa-receipt"></i>
                            <p>Cửa hàng của bạn chưa nhận được đơn hàng nào.</p>
                        </div>
                    <% } %>
                </div>

            <% } %>

        </main>
    </div><!-- end sena-layout -->

    <script>
        // Lọc đơn hàng theo tab trạng thái
        function filterOrders(status) {
            // Đổi active tab button
            var buttons = document.querySelectorAll('.tab-btn');
            buttons.forEach(btn => btn.classList.remove('active'));
            event.currentTarget.classList.add('active');

            var cards = document.querySelectorAll('.order-card');
            var shownCount = 0;
            cards.forEach(card => {
                var cardStatus = card.getAttribute('data-status');
                if (status === 'all' || cardStatus === status) {
                    card.style.display = 'flex';
                    shownCount++;
                } else {
                    card.style.display = 'none';
                }
            });

            // Nếu không có card nào hiển thị, tạo empty state
            var container = document.getElementById('ordersContainer');
            var emptyDiv = document.getElementById('tempEmptyState');
            if (shownCount === 0 && cards.length > 0) {
                if (!emptyDiv) {
                    emptyDiv = document.createElement('div');
                    emptyDiv.id = 'tempEmptyState';
                    emptyDiv.className = 'empty-state';
                    emptyDiv.innerHTML = '<i class="fa-solid fa-receipt"></i><p>Không tìm thấy đơn hàng nào ở trạng thái này.</p>';
                    container.appendChild(emptyDiv);
                }
            } else {
                if (emptyDiv) {
                    emptyDiv.remove();
                }
            }
        }
    </script>
</body>
</html>


