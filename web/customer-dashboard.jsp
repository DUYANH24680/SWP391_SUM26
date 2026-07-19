<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Order" %>
<%@ page import="model.OrderDetail" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
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

    List<Order> orders = (List<Order>) request.getAttribute("orders");
    if (orders == null) {
        response.sendRedirect(request.getContextPath() + "/customer-dashboard");
        return;
    }

    Map<Integer, List<OrderDetail>> detailsMap = (Map<Integer, List<OrderDetail>>) request.getAttribute("detailsMap");
    int totalOrders = request.getAttribute("totalOrders") != null ? (Integer) request.getAttribute("totalOrders") : 0;
    double totalSpent = request.getAttribute("totalSpent") != null
            ? ((Number) request.getAttribute("totalSpent")).doubleValue()
            : 0;
    int pendingCount = request.getAttribute("pendingCount") != null ? ((Number) request.getAttribute("pendingCount")).intValue() : 0;
    int confirmedCount = request.getAttribute("confirmedCount") != null ? ((Number) request.getAttribute("confirmedCount")).intValue() : 0;
    int shippingCount = request.getAttribute("shippingCount") != null ? ((Number) request.getAttribute("shippingCount")).intValue() : 0;
    int deliveredCount = request.getAttribute("deliveredCount") != null ? ((Number) request.getAttribute("deliveredCount")).intValue() : 0;
    int canceledCount = request.getAttribute("canceledCount") != null ? ((Number) request.getAttribute("canceledCount")).intValue() : 0;
    int recentOrderCount = request.getAttribute("recentOrderCount") != null ? ((Number) request.getAttribute("recentOrderCount")).intValue() : 0;
    double avgOrderValue = request.getAttribute("avgOrderValue") != null ? ((Number) request.getAttribute("avgOrderValue")).doubleValue() : 0;
    double monthlySpend = request.getAttribute("monthlySpend") != null ? ((Number) request.getAttribute("monthlySpend")).doubleValue() : 0;
    List<Order> recentOrders = (List<Order>) request.getAttribute("recentOrders");

    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");

    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(java.util.Locale.forLanguageTag("vi"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard | Sena Shop</title>
    <style>
        /* Layout vars already provided by sidebar.jsp */

        /* ======= TOPNAV ======= */
        .topnav {
            background: var(--white);
            border-bottom: 1px solid var(--gray-200);
            height: 64px;
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
            font-size: 1.4rem;
            font-weight: 800;
            color: var(--green-dark);
            text-decoration: none;
        }
        .nav-logo i { color: var(--green); font-size: 1.2rem; }

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
            max-width: 1200px;
            width: 100%;
            margin: 1.5rem auto;
            padding: 0 1.5rem;
            gap: 1.5rem;
            align-items: flex-start;
        }

        /* ======= SIDEBAR ======= */
        .sidebar {
            width: 220px;
            flex-shrink: 0;
            background: var(--white);
            border-radius: var(--radius);
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--gray-200);
            overflow: hidden;
            position: sticky;
            top: 80px;
        }
        .sidebar-user {
            padding: 1.25rem 1rem;
            border-bottom: 1px solid var(--gray-100);
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        .sidebar-avatar {
            width: 40px; height: 40px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--green);
        }
        .sidebar-name {
            font-size: 0.85rem;
            font-weight: 700;
            color: var(--gray-800);
        }
        .sidebar-role {
            font-size: 0.75rem;
            color: var(--gray-400);
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
            text-decoration: none;
            transition: all 0.15s;
        }
        .sidebar-nav a:hover { background: var(--green-light); color: var(--green-dark); }
        .sidebar-nav a.active { background: var(--green); color: #fff; font-weight: 600; }
        .sidebar-nav a.logout { color: #e53e3e; }
        .sidebar-nav a.logout:hover { background: #fff5f5; color: #c53030; }

        /* ======= MAIN ======= */
        .main { flex: 1; display: flex; flex-direction: column; gap: 1.25rem; min-width: 0; }

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

        /* ======= STATS ======= */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 1.25rem;
        }
        @media (max-width: 640px) {
            .stats-grid { grid-template-columns: 1fr; }
        }

        .stat-card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            padding: 1.25rem 1.5rem;
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        .stat-icon {
            width: 48px; height: 48px;
            border-radius: 12px;
            background: var(--green-light);
            color: var(--green-dark);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
        }
        .stat-info {}
        .stat-label {
            font-size: 0.8rem;
            color: var(--gray-400);
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }
        .stat-value {
            font-size: 1.35rem;
            font-weight: 800;
            color: var(--gray-800);
            margin-top: 0.15rem;
        }

        /* ======= ORDER TRACKER ======= */
        .tracker-card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            padding: 1.25rem 1.5rem;
        }
        .tracker-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1rem;
        }
        .tracker-title {
            font-size: 1rem;
            font-weight: 700;
            color: var(--gray-800);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .tracker-title i { color: var(--green); }

        .stepper {
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: relative;
            margin: 1rem 0;
        }
        .stepper-line {
            position: absolute;
            left: 24px;
            right: 24px;
            top: 18px;
            height: 2px;
            background: var(--gray-200);
            z-index: 0;
        }
        .stepper-line-fill {
            position: absolute;
            left: 24px;
            top: 18px;
            height: 2px;
            background: var(--green);
            z-index: 0;
            transition: width 0.3s ease;
        }
        .step {
            position: relative;
            z-index: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 0.35rem;
        }
        .step-circle {
            width: 36px; height: 36px;
            border-radius: 50%;
            background: var(--white);
            border: 2px solid var(--gray-200);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.85rem;
            color: var(--gray-400);
            transition: all 0.2s;
        }
        .step.active .step-circle {
            background: var(--green);
            border-color: var(--green);
            color: #fff;
        }
        .step.done .step-circle {
            background: var(--green-light);
            border-color: var(--green);
            color: var(--green-dark);
        }
        .step-label {
            font-size: 0.75rem;
            color: var(--gray-400);
            font-weight: 600;
        }
        .step.active .step-label { color: var(--gray-800); }

        /* ======= STATUS GRID ======= */
        .status-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 1rem;
        }
        .status-card {
            display: flex;
            align-items: center;
            gap: 0.9rem;
            padding: 1rem 1rem;
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            background: var(--white);
            box-shadow: var(--shadow-sm);
            text-decoration: none;
            transition: transform 0.2s, box-shadow 0.2s, border-color 0.2s;
        }
        .status-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow);
            border-color: var(--green);
        }
        .status-icon {
            width: 38px; height: 38px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1rem;
            background: var(--green-light);
            color: var(--green-dark);
        }
        .status-info {
            display: flex;
            flex-direction: column;
        }
        .status-name {
            font-size: 0.82rem;
            color: var(--gray-600);
            font-weight: 600;
        }
        .status-count {
            font-size: 1.3rem;
            font-weight: 800;
            color: var(--gray-900);
        }

        /* ======= ORDER LIST ======= */
        .order-list { display: flex; flex-direction: column; gap: 1rem; }
        .order-card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
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
            padding: 1rem 1.25rem;
            background: var(--gray-50);
            border-bottom: 1px solid var(--gray-100);
            font-size: 0.85rem;
            flex-wrap: wrap;
            gap: 0.5rem;
        }
        .order-id { font-weight: 700; color: var(--gray-800); }
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
        .badge-green { background: #dcfce7; color: #166534; }
        .badge-yellow { background: #fef9c3; color: #854d0e; }
        .badge-red { background: #fee2e2; color: #991b1b; }
        .badge-blue { background: #dbeafe; color: #1e40af; }
        .badge-gray { background: var(--gray-100); color: var(--gray-600); }

        .order-body { padding: 1rem 1.25rem; }
        .item-row {
            display: flex;
            gap: 1rem;
            align-items: center;
            margin-bottom: 0.75rem;
        }
        .item-row:last-child { margin-bottom: 0; }
        .item-img {
            width: 56px; height: 56px;
            border-radius: var(--radius-sm);
            object-fit: cover;
            border: 1px solid var(--gray-200);
        }
        .item-placeholder {
            width: 56px; height: 56px;
            border-radius: var(--radius-sm);
            background: var(--green-light);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
        }
        .item-details { flex: 1; }
        .item-title { font-weight: 700; font-size: 0.9rem; color: var(--gray-800); margin-bottom: 0.2rem; }
        .item-meta { font-size: 0.8rem; color: var(--gray-400); }
        .item-price { font-weight: 600; font-size: 0.9rem; color: var(--gray-800); text-align: right; }

        .order-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.75rem 1.25rem;
            border-top: 1px solid var(--gray-100);
            font-size: 0.85rem;
            color: var(--gray-600);
        }
        .order-total {
            font-weight: 800;
            color: var(--green-dark);
            font-size: 1rem;
        }

        .empty-state {
            text-align: center;
            padding: 3rem 2rem;
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            color: var(--gray-400);
            box-shadow: var(--shadow-sm);
        }
        .empty-state i { font-size: 3rem; color: var(--gray-200); margin-bottom: 1rem; display: block; }
        .empty-state p { font-size: 0.95rem; margin-bottom: 1rem; color: var(--gray-600); }
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.45rem;
            padding: 0.65rem 1.25rem;
            border-radius: var(--radius-sm);
            font-size: 0.875rem;
            font-weight: 600;
            cursor: pointer;
            border: none;
            text-decoration: none;
            transition: all 0.18s ease;
        }
        .btn-green {
            background: var(--green);
            color: #fff;
            box-shadow: 0 2px 8px rgba(76,175,80,0.3);
        }
        .btn-green:hover {
            background: var(--green-dark);
            transform: translateY(-1px);
        }

    </style>
</head>
<body>

    <jsp:include page="/sidebar.jsp">
        <jsp:param name="activePage" value="customer-dashboard"/>
    </jsp:include>

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

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fa-solid fa-receipt"></i>
                    </div>
                    <div class="stat-info">
                        <div class="stat-label">Tổng đơn hàng</div>
                        <div class="stat-value"><%= totalOrders %></div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fa-solid fa-sack-dollar"></i>
                    </div>
                    <div class="stat-info">
                        <div class="stat-label">Tổng đã chi tiêu</div>
                        <div class="stat-value"><%= nf.format((long) totalSpent) %> đ</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fa-solid fa-cart-shopping"></i>
                    </div>
                    <div class="stat-info">
                        <div class="stat-label">Đơn trung bình</div>
                        <div class="stat-value"><%= nf.format((long) avgOrderValue) %> đ</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fa-solid fa-calendar-day"></i>
                    </div>
                    <div class="stat-info">
                        <div class="stat-label">Chi tiêu tháng này</div>
                        <div class="stat-value"><%= nf.format((long) monthlySpend) %> đ</div>
                    </div>
                </div>
            </div>

            <div class="tracker-card">
                <div class="tracker-header">
                    <div class="tracker-title">
                        <i class="fa-solid fa-layer-group"></i>
                        Trạng thái đơn hàng của bạn
                    </div>
                </div>

                <div class="status-grid">
                    <a class="status-card" href="my-orders?status=1">
                        <div class="status-icon"><i class="fa-solid fa-clipboard-check"></i></div>
                        <div class="status-info">
                            <div class="status-name">Chờ xác nhận</div>
                            <div class="status-count"><%= pendingCount %></div>
                        </div>
                    </a>

                    <a class="status-card" href="my-orders?status=2">
                        <div class="status-icon"><i class="fa-solid fa-box"></i></div>
                        <div class="status-info">
                            <div class="status-name">Đã xác nhận</div>
                            <div class="status-count"><%= confirmedCount %></div>
                        </div>
                    </a>

                    <a class="status-card" href="my-orders?status=3">
                        <div class="status-icon"><i class="fa-solid fa-truck-fast"></i></div>
                        <div class="status-info">
                            <div class="status-name">Đang giao</div>
                            <div class="status-count"><%= shippingCount %></div>
                        </div>
                    </a>

                    <a class="status-card" href="my-orders?status=4">
                        <div class="status-icon"><i class="fa-solid fa-circle-check"></i></div>
                        <div class="status-info">
                            <div class="status-name">Đã giao</div>
                            <div class="status-count"><%= deliveredCount %></div>
                        </div>
                    </a>

                    <a class="status-card" href="my-orders?status=5">
                        <div class="status-icon"><i class="fa-solid fa-rectangle-xmark"></i></div>
                        <div class="status-info">
                            <div class="status-name">Đã hủy</div>
                            <div class="status-count"><%= canceledCount %></div>
                        </div>
                    </a>
                </div>
            </div>

            <div class="tracker-card">
                <div class="tracker-header">
                    <div class="tracker-title">
                        <i class="fa-solid fa-clock-rotate-left"></i>
                        Đơn hàng gần đây
                    </div>
                    <a href="my-orders" class="btn btn-outline btn-sm">Xem tất cả đơn hàng</a>
                </div>
                <div class="order-list">
                    <%
                        List<Order> displayOrders = (recentOrders != null && !recentOrders.isEmpty()) ? recentOrders : orders;
                        if (displayOrders != null && displayOrders.size() > 3) {
                            displayOrders = new java.util.ArrayList<>(displayOrders.subList(0, 3));
                        }
                        if (displayOrders != null && !displayOrders.isEmpty()) {
                            for (Order o : displayOrders) {
                                List<OrderDetail> details = detailsMap.get(o.getId());
                    %>
                        <div class="order-card">
                            <div class="order-header">
                                <div>
                                    Ngày đặt: <strong><%= o.getOrderDate() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(o.getOrderDate()) : "N/A" %></strong>
                                    <span class="order-id"></span>
                                </div>
                                <span class="badge <%= o.getStatusClass() %>"><%= o.getStatusLabel() %></span>
                            </div>
                            <div class="order-body">
                                <%
                                    if (details != null) {
                                        for (OrderDetail od : details) {
                                %>
                                    <div class="item-row">
                                        <div class="item-placeholder">🍎</div>
                                        <div class="item-details">
                                            <div class="item-title"><%= od.getProductTitle() %></div>
                                            <% if (od.getShopName() != null) { %>
                                            <div class="item-meta"><i class="fa-solid fa-store"></i> <%= od.getShopName() %></div>
                                            <% } %>
                                            <div class="item-meta">x<%= od.getQuantity() %> &middot; <%= od.getProductUnit() != null ? od.getProductUnit() : "kg" %></div>
                                        </div>
                                        <div class="item-price"><%= nf.format((long) od.getUnitPrice()) %> đ</div>
                                    </div>
                                <%
                                        }
                                    }
                                %>
                            </div>
                            <div class="order-footer">
                                <div>
                                    Thanh toán: <strong><%= o.getPaymentMethod() %></strong> &middot;
                                    <% if (o.getDiscountAmount() > 0) { %>
                                        Giảm giá Shop: -<%= nf.format((long) o.getDiscountAmount()) %> đ &middot;
                                    <% } %>
                                    <% if (o.getPlatformDiscountAmount() > 0) { %>
                                        Giảm giá Sàn: -<%= nf.format((long) o.getPlatformDiscountAmount()) %> đ &middot;
                                    <% } %>
                                    Ship: +<%= nf.format((long) o.getShippingFee()) %> đ
                                </div>
                                <div class="order-total">
                                    Khách trả: <%= nf.format((long) o.getFinalCost()) %> đ
                                </div>
                            </div>
                        </div>
                    <%
                            }
                        } else {
                    %>
                        <div class="empty-state">
                            <i class="fa-solid fa-receipt"></i>
                            <p>Bạn chưa có đơn hàng nào.</p>
                            <a href="home.jsp" class="btn btn-green">Mua ngay sản phẩm</a>
                        </div>
                    <%
                        }
                    %>
                </div>
            </div>
        </main>
    </div><!-- end sena-layout -->
</body>
</html>

