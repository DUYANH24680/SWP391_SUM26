<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Order" %>
<%@ page import="model.OrderDetail" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.NumberFormat" %>
<%
    Account user = (Account) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    Account customer = (Account) request.getAttribute("customer");
    List<Order> orders = (List<Order>) request.getAttribute("orders");

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    NumberFormat nf = NumberFormat.getInstance();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch Sử Đơn Hàng | <%= customer != null ? customer.getFullname() : "" %> | Sena Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --green:       #4caf50;
            --green-dark:  #388e3c;
            --green-light: #e8f5e9;
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
            --radius:      14px;
            --radius-sm:   8px;
        }

        html, body {
            min-height: 100vh;
            font-family: 'Inter', sans-serif;
            color: var(--gray-800);
            background: var(--bg);
        }

        /* ======= TOPNAV ======= */
        .topnav {
            background: var(--white);
            border-bottom: 1px solid var(--gray-200);
            height: 60px;
            display: flex;
            align-items: center;
            padding: 0 2rem;
            gap: 1.5rem;
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
        }
        .nav-logo i { color: var(--green); }
        .nav-links {
            display: flex;
            gap: 0.25rem;
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
        .nav-links a.active { background: var(--green-light); color: var(--green-dark); font-weight: 600; }
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
        .nav-username {
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--gray-800);
        }

        /* ======= LAYOUT ======= */
        .layout {
            max-width: 1100px;
            margin: 1.5rem auto;
            padding: 0 1.5rem;
        }

        /* ======= BACK LINK ======= */
        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            color: var(--gray-600);
            text-decoration: none;
            font-size: 0.875rem;
            font-weight: 500;
            margin-bottom: 1.25rem;
            transition: color 0.15s;
        }
        .back-link:hover { color: var(--green-dark); }

        /* ======= CUSTOMER INFO CARD ======= */
        .customer-card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            padding: 1.25rem 1.5rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 1.5rem;
        }
        .customer-avatar {
            width: 56px; height: 56px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid var(--green);
            background: var(--green-light);
            flex-shrink: 0;
        }
        .customer-info-text h2 {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--gray-800);
        }
        .customer-info-text p {
            font-size: 0.82rem;
            color: var(--gray-600);
            margin-top: 0.15rem;
        }
        .customer-meta {
            display: flex;
            gap: 1rem;
            margin-left: auto;
            flex-wrap: wrap;
        }
        .meta-item {
            text-align: center;
        }
        .meta-value {
            font-size: 1.3rem;
            font-weight: 800;
            color: var(--green-dark);
        }
        .meta-label {
            font-size: 0.75rem;
            color: var(--gray-400);
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }

        /* ======= ORDER CARDS ======= */
        .order-card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            margin-bottom: 1.25rem;
            overflow: hidden;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .order-card:hover {
            transform: translateY(-1px);
            box-shadow: var(--shadow);
        }
        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.9rem 1.5rem;
            background: var(--gray-50);
            border-bottom: 1px solid var(--gray-100);
            flex-wrap: wrap;
            gap: 0.5rem;
        }
        .order-date-id { font-size: 0.85rem; color: var(--gray-600); }
        .order-id { font-weight: 700; color: var(--gray-800); margin-left: 0.4rem; }

        .badge {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.2rem 0.65rem;
            border-radius: 100px;
            font-size: 0.75rem;
            font-weight: 700;
        }
        .badge-green  { background: #dcfce7; color: #166534; }
        .badge-yellow { background: #fef9c3; color: #854d0e; }
        .badge-red    { background: #fee2e2; color: #991b1b; }
        .badge-blue   { background: #dbeafe; color: #1e40af; }
        .badge-gray   { background: var(--gray-100); color: var(--gray-600); }

        .order-body { padding: 1.1rem 1.5rem; }
        .item-row {
            display: flex;
            gap: 0.85rem;
            align-items: center;
            margin-bottom: 0.75rem;
        }
        .item-row:last-child { margin-bottom: 0; }
        .item-img {
            width: 50px; height: 50px;
            border-radius: var(--radius-sm);
            object-fit: cover;
            border: 1px solid var(--gray-200);
        }
        .item-details { flex: 1; }
        .item-title { font-weight: 600; font-size: 0.88rem; color: var(--gray-800); }
        .item-meta { font-size: 0.78rem; color: var(--gray-400); margin-top: 0.15rem; }
        .item-price { font-weight: 600; font-size: 0.88rem; color: var(--gray-800); }

        .order-footer {
            padding: 0.9rem 1.5rem;
            border-top: 1px solid var(--gray-100);
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 1rem;
            flex-wrap: wrap;
            background: var(--gray-50);
        }
        .order-cost-details {
            font-size: 0.8rem;
            color: var(--gray-400);
            text-align: right;
        }
        .order-total {
            font-size: 1rem;
            font-weight: 800;
            color: var(--green-dark);
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
        .empty-state i { font-size: 3rem; color: var(--gray-200); margin-bottom: 0.75rem; display: block; }
        .empty-state p { font-size: 0.95rem; }

        /* Tab filter */
        .tabs-card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            padding: 0.4rem;
            display: flex;
            gap: 0.2rem;
            overflow-x: auto;
            margin-bottom: 1.25rem;
            flex-wrap: wrap;
        }
        .tab-btn {
            padding: 0.5rem 1rem;
            border-radius: var(--radius-sm);
            font-size: 0.82rem;
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
    </style>
</head>
<body>

    <!-- Topnav -->
    <nav class="topnav">
        <a href="<%= request.getContextPath() %>/home.jsp" class="nav-logo">
            <i class="fa-solid fa-apple-whole"></i> Sena Shop
        </a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/home.jsp">Trang Chủ</a>
            <a href="<%= request.getContextPath() %>/products">Sản Phẩm</a>
            <a href="<%= request.getContextPath() %>/admin/customers" class="active">
                <i class="fa-solid fa-users"></i> Khách Hàng
            </a>
        </div>
        <div class="nav-right">
            <span class="nav-username">Admin: <%= user.getFullname() != null ? user.getFullname() : user.getUsername() %></span>
            <% String navAvatar = user.getAvatar();
               if (navAvatar == null || navAvatar.trim().isEmpty()) {
                   String fn = user.getFullname() != null ? user.getFullname() : user.getUsername();
                   navAvatar = "https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(fn, "UTF-8") + "&background=4caf50&color=fff&size=80&bold=true&rounded=true";
               }
            %>
            <img class="nav-avatar" src="<%= navAvatar %>" alt="avatar">
        </div>
    </nav>

    <div class="layout">
        <!-- Back link -->
        <a href="<%= request.getContextPath() %>/admin/customers" class="back-link">
            <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách khách hàng
        </a>

        <% if (customer != null) { %>
            <!-- Customer Info -->
            <div class="customer-card">
                <%
                    String cAvatar = customer.getAvatar();
                    if (cAvatar == null || cAvatar.trim().isEmpty()) {
                        String cFn = customer.getFullname() != null ? customer.getFullname() : customer.getUsername();
                        cAvatar = "https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(cFn, "UTF-8") + "&background=e8f5e9&color=4caf50&size=80&bold=true&rounded=true";
                    }
                %>
                <img src="<%= cAvatar %>" alt="avatar" class="customer-avatar">
                <div class="customer-info-text">
                    <h2><%= customer.getFullname() != null ? customer.getFullname() : "Chưa có tên" %></h2>
                    <p>
                        <i class="fa-solid fa-user"></i> @<%= customer.getUsername() %>
                        &nbsp;|&nbsp;
                        <i class="fa-solid fa-envelope"></i> <%= customer.getEmail() != null ? customer.getEmail() : "—" %>
                        &nbsp;|&nbsp;
                        <i class="fa-solid fa-phone"></i> <%= customer.getPhone() != null ? customer.getPhone() : "—" %>
                    </p>
                    <p>
                        <i class="fa-solid fa-calendar"></i> Tham gia: <%= customer.getCreatedAt() != null ? sdf.format(customer.getCreatedAt()) : "—" %>
                    </p>
                </div>
                <div class="customer-meta">
                    <div class="meta-item">
                        <div class="meta-value"><%= orders != null ? orders.size() : 0 %></div>
                        <div class="meta-label">Đơn hàng</div>
                    </div>
                    <div class="meta-item">
                        <div class="meta-value" style="color: <%= customer.getStatus() == 1 ? "var(--green-dark)" : "#dc2626" %>;">
                            <%= customer.getStatus() == 1 ? "Active" : "Blocked" %>
                        </div>
                        <div class="meta-label">Trạng thái</div>
                    </div>
                </div>
            </div>
        <% } %>

        <!-- Tab filter -->
        <div class="tabs-card">
            <button class="tab-btn active" onclick="filterOrders('all')">Tất cả</button>
            <button class="tab-btn" onclick="filterOrders('1')">Chờ xác nhận</button>
            <button class="tab-btn" onclick="filterOrders('2')">Đã xác nhận</button>
            <button class="tab-btn" onclick="filterOrders('3')">Đang giao</button>
            <button class="tab-btn" onclick="filterOrders('4')">Đã giao</button>
            <button class="tab-btn" onclick="filterOrders('5')">Đã hủy</button>
        </div>

        <!-- Orders -->
        <%
            if (orders != null && !orders.isEmpty()) {
                for (Order o : orders) {
        %>
            <div class="order-card" data-status="<%= o.getStatus() %>">
                <div class="order-header">
                    <div class="order-date-id">
                        <i class="fa-regular fa-calendar"></i>
                        <strong><%= o.getOrderDate() != null ? sdf.format(o.getOrderDate()) : "—" %></strong>
                        <span class="order-id">Mã đơn: #<%= o.getId() %></span>
                        <% if (o.getPaymentMethod() != null) { %>
                            &nbsp;&nbsp;|&nbsp;&nbsp;
                            <i class="fa-regular fa-credit-card"></i> <%= o.getPaymentMethod() %>
                        <% } %>
                    </div>
                    <div style="display:flex; gap:0.4rem; align-items:center;">
                        <span class="badge badge-<%= o.getPaymentStatus() == 1 ? "green" : o.getPaymentStatus() == 2 ? "blue" : "gray" %>">
                            <%= o.getPaymentStatusLabel() %>
                        </span>
                        <span class="badge <%= o.getStatusClass() %>">
                            <%= o.getStatusLabel() %>
                        </span>
                    </div>
                </div>

                <div class="order-body">
                    <% if (o.getRecipientName() != null) { %>
                        <div style="font-size:0.82rem; color:var(--gray-600); margin-bottom:0.75rem;">
                            <i class="fa-solid fa-user-tag" style="color:var(--green);"></i>
                            <strong>Người nhận:</strong> <%= o.getRecipientName() %>
                            &nbsp;&nbsp;
                            <i class="fa-solid fa-phone" style="color:var(--green);"></i> <%= o.getRecipientPhone() != null ? o.getRecipientPhone() : "—" %>
                            &nbsp;&nbsp;
                            <i class="fa-solid fa-map-pin" style="color:var(--green);"></i>
                            <%= o.getAddress() != null ? o.getAddress() : "—" %>
                        </div>
                    <% } %>
                    <% if (o.getNote() != null && !o.getNote().isEmpty()) { %>
                        <div style="font-size:0.82rem; color:var(--gray-600); margin-bottom:0.75rem; font-style:italic;">
                            <i class="fa-solid fa-comment" style="color:var(--green);"></i>
                            Ghi chú: <%= o.getNote() %>
                        </div>
                    <% } %>
                </div>

                <div class="order-footer">
                    <div class="order-cost-details">
                        Tiền hàng: <%= nf.format((long) o.getTotalCost()) %> đ
                        <% if (o.getDiscountAmount() > 0) { %> | Giảm: -<%= nf.format((long) o.getDiscountAmount()) %> đ<% } %>
                        | Ship: +<%= nf.format((long) o.getShippingFee()) %> đ
                    </div>
                    <div class="order-total">
                        Thực thu: <%= nf.format((long) o.getFinalCost()) %> đ
                    </div>
                </div>
            </div>
        <%
                }
            } else {
        %>
            <div class="empty-state">
                <i class="fa-solid fa-receipt"></i>
                <p>Khách hàng này chưa có đơn hàng nào.</p>
            </div>
        <% } %>
    </div>

    <script>
        function filterOrders(status) {
            var buttons = document.querySelectorAll('.tab-btn');
            buttons.forEach(function(btn) { btn.classList.remove('active'); });
            if (event && event.currentTarget) event.currentTarget.classList.add('active');

            var cards = document.querySelectorAll('.order-card');
            cards.forEach(function(card) {
                var s = card.getAttribute('data-status');
                card.style.display = (status === 'all' || s === status) ? 'block' : 'none';
            });
        }
    </script>
</body>
</html>
