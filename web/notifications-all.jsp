<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Notification" %>
<%@ page import="java.util.List" %>
<%
    Account user = (Account) session.getAttribute("Account");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    Integer unreadCount = (Integer) request.getAttribute("unreadCount");
    if (unreadCount == null) unreadCount = 0;
    
    String role = user.getRoleName() != null ? user.getRoleName().toLowerCase() : "customer";
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tất Cả Thông Báo | Sena Shop</title>
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
        
        /* Top Navigation Bar */
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
        
        /* Layout Container */
        .layout { max-width: 960px; margin: 2rem auto; padding: 0 1.5rem; }
        
        /* Back Button & Page Header */
        .header-section {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 1.5rem; flex-wrap: wrap; gap: 1rem;
        }
        .header-title-box { display: flex; align-items: center; gap: 0.85rem; }
        .back-btn {
            width: 40px; height: 40px; border-radius: 10px; background: var(--white);
            border: 1px solid var(--gray-200); display: flex; align-items: center; justify-content: center;
            color: var(--gray-600); text-decoration: none; transition: all 0.2s; box-shadow: var(--shadow-sm);
        }
        .back-btn:hover { background: var(--green-light); color: var(--green-dark); border-color: var(--green); }
        .page-title { font-size: 1.5rem; font-weight: 800; color: var(--gray-800); display: flex; align-items: center; gap: 0.6rem; }
        .page-title i { color: var(--green); }
        
        .header-actions { display: flex; align-items: center; gap: 0.75rem; }
        .btn {
            padding: 0.55rem 1.1rem; border-radius: var(--radius-sm); font-size: 0.85rem; font-weight: 600;
            text-decoration: none; transition: all 0.18s; cursor: pointer; border: none;
            display: inline-flex; align-items: center; gap: 0.4rem;
        }
        .btn-outline-green { background: var(--white); border: 1.5px solid var(--green); color: var(--green-dark); }
        .btn-outline-green:hover { background: var(--green-light); }
        
        /* Filter Bar */
        .filter-bar {
            display: flex; align-items: center; gap: 0.5rem; margin-bottom: 1.25rem;
            background: var(--white); padding: 0.5rem; border-radius: var(--radius);
            border: 1px solid var(--gray-200); box-shadow: var(--shadow-sm);
        }
        .filter-btn {
            padding: 0.45rem 1rem; border-radius: 100px; font-size: 0.8rem; font-weight: 600;
            border: none; background: transparent; color: var(--gray-600); cursor: pointer;
            transition: all 0.18s; display: inline-flex; align-items: center; gap: 0.4rem;
        }
        .filter-btn:hover { background: var(--gray-100); color: var(--gray-800); }
        .filter-btn.active { background: var(--green); color: white; box-shadow: 0 2px 8px rgba(76,175,80,0.3); }
        .filter-badge {
            background: rgba(0,0,0,0.08); padding: 2px 7px; border-radius: 100px; font-size: 0.75rem;
        }
        .filter-btn.active .filter-badge { background: rgba(255,255,255,0.25); color: white; }
        
        /* Notifications Card List */
        .card {
            background: var(--white); border-radius: var(--radius); border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm); overflow: hidden;
        }
        
        .notif-item {
            display: flex; gap: 1rem; padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--gray-100);
            transition: all 0.2s; text-decoration: none; color: inherit; position: relative;
        }
        .notif-item:last-child { border-bottom: none; }
        .notif-item:hover { background: #f9fafb; }
        .notif-item.unread { background: #f0fdf4; }
        .notif-item.unread:hover { background: #dcfce7; }
        
        .notif-unread-dot {
            position: absolute; top: 1.3rem; right: 1.5rem; width: 9px; height: 9px;
            border-radius: 50%; background: var(--green); display: block;
        }
        .notif-item:not(.unread) .notif-unread-dot { display: none; }
        
        .notif-icon-wrapper {
            width: 48px; height: 48px; border-radius: 12px; display: flex;
            align-items: center; justify-content: center; font-size: 1.2rem; flex-shrink: 0;
        }
        
        .notif-body { flex: 1; min-width: 0; padding-right: 1.5rem; }
        .notif-item-title { font-size: 0.95rem; font-weight: 700; color: var(--gray-800); margin-bottom: 0.25rem; }
        .notif-item-content { font-size: 0.875rem; color: var(--gray-600); line-height: 1.5; margin-bottom: 0.5rem; word-break: break-word; }
        .notif-item-meta { display: flex; align-items: center; gap: 1rem; font-size: 0.78rem; color: var(--gray-400); }
        .notif-item-time { display: flex; align-items: center; gap: 0.3rem; }
        
        .notif-actions { display: flex; align-items: center; gap: 0.5rem; margin-top: 0.6rem; }
        .action-link {
            font-size: 0.8rem; font-weight: 600; color: var(--green-dark); text-decoration: none;
            display: inline-flex; align-items: center; gap: 0.3rem; transition: color 0.15s;
        }
        .action-link:hover { text-decoration: underline; color: var(--green); }
        .btn-sm-action {
            background: none; border: none; font-size: 0.78rem; color: var(--gray-400);
            cursor: pointer; font-weight: 500; transition: color 0.15s; padding: 2px 6px; border-radius: 4px;
        }
        .btn-sm-action:hover { color: #ef4444; background: #fee2e2; }
        .btn-sm-action.read-btn:hover { color: var(--green-dark); background: var(--green-light); }
        
        /* Empty state */
        .empty-state { text-align: center; padding: 4rem 2rem; color: var(--gray-400); }
        .empty-state i { font-size: 3.5rem; margin-bottom: 1rem; color: #d1d5db; }
        .empty-state h3 { font-size: 1.1rem; font-weight: 700; color: var(--gray-600); margin-bottom: 0.4rem; }
        .empty-state p { font-size: 0.875rem; color: #9ca3af; }
    </style>
</head>
<body>
    <!-- Top Navigation -->
    <nav class="topnav">
        <% if ("staff".equals(role)) { %>
            <a href="<%= ctx %>/staff/delivery" class="nav-logo"><i class="fas fa-warehouse"></i> Staff Panel</a>
            <div class="nav-links">
                <a href="<%= ctx %>/staff/delivery">Giao Hàng</a>
                <a href="<%= ctx %>/staff/orders-waiting">Đơn Chờ Giao</a>
                <a href="<%= ctx %>/staff/delivery-history">Lịch Sử</a>
            </div>
        <% } else if ("shipper".equals(role) || "delivery".equals(role)) { %>
            <a href="<%= ctx %>/shipper/delivery" class="nav-logo"><i class="fas fa-motorcycle"></i> Shipper Panel</a>
            <div class="nav-links">
                <a href="<%= ctx %>/shipper/delivery">Giao Hàng</a>
                <a href="<%= ctx %>/shipper/my-deliveries">Đơn Của Tôi</a>
            </div>
        <% } else if ("seller".equals(role)) { %>
            <a href="<%= ctx %>/seller/dashboard" class="nav-logo"><i class="fas fa-store"></i> Kênh Người Bán</a>
            <div class="nav-links">
                <a href="<%= ctx %>/seller/dashboard">Tổng Quan</a>
                <a href="<%= ctx %>/seller/orders">Đơn Hàng</a>
                <a href="<%= ctx %>/seller/products">Sản Phẩm</a>
            </div>
        <% } else { %>
            <a href="<%= ctx %>/home.jsp" class="nav-logo"><i class="fas fa-leaf"></i> Sena Shop</a>
            <div class="nav-links">
                <a href="<%= ctx %>/home.jsp">Trang Chủ</a>
                <a href="<%= ctx %>/my-orders">Đơn Hàng Của Tôi</a>
            </div>
        <% } %>
        
        <div class="nav-right">
            <jsp:include page="/notification-icon.jsp" />
            <a href="<%= ctx %>/logout" class="btn" style="background: #fee2e2; color: #991b1b; padding: 0.4rem 0.85rem;">Đăng Xuất</a>
        </div>
    </nav>

    <!-- Main Layout -->
    <div class="layout">
        <div class="header-section">
            <div class="header-title-box">
                <a href="javascript:history.back()" class="back-btn" title="Quay lại"><i class="fas fa-arrow-left"></i></a>
                <div class="page-title">
                    <i class="fas fa-bell"></i> Tất Cả Thông Báo
                </div>
            </div>
            
            <div class="header-actions">
                <button type="button" class="btn btn-outline-green" onclick="markAllReadPage()">
                    <i class="fas fa-check-double"></i> Đánh dấu tất cả đã đọc
                </button>
            </div>
        </div>

        <!-- Filter Bar -->
        <div class="filter-bar">
            <button type="button" class="filter-btn active" id="btn-all" onclick="filterNotifs('all', this)">
                <i class="fas fa-list"></i> Tất Cả
                <span class="filter-badge" id="badge-all"><%= notifications != null ? notifications.size() : 0 %></span>
            </button>
            <button type="button" class="filter-btn" id="btn-unread" onclick="filterNotifs('unread', this)">
                <i class="fas fa-envelope"></i> Chưa Đọc
                <span class="filter-badge" id="badge-unread"><%= unreadCount %></span>
            </button>
            <button type="button" class="filter-btn" id="btn-read" onclick="filterNotifs('read', this)">
                <i class="fas fa-envelope-open"></i> Đã Đọc
                <span class="filter-badge" id="badge-read"><%= notifications != null ? (notifications.size() - unreadCount) : 0 %></span>
            </button>
        </div>

        <!-- Notification List Container -->
        <div class="card">
            <div id="notifContainer">
                <% if (notifications == null || notifications.isEmpty()) { %>
                    <div class="empty-state">
                        <i class="fas fa-bell-slash"></i>
                        <h3>Chưa có thông báo nào</h3>
                        <p>Thông báo mới về đơn hàng và hệ thống sẽ xuất hiện ở đây.</p>
                    </div>
                <% } else { %>
                    <% for (Notification n : notifications) { 
                        String linkUrl = n.getLinkUrl();
                        if (linkUrl == null || linkUrl.isEmpty()) linkUrl = "#";
                        else if (!linkUrl.startsWith("/") && !linkUrl.startsWith("http")) linkUrl = ctx + "/" + linkUrl;
                        else if (linkUrl.startsWith("/")) linkUrl = ctx + linkUrl;
                        
                        String typeColor = n.getTypeColor() != null ? n.getTypeColor() : "#4caf50";
                        String typeIcon = n.getTypeIcon() != null ? n.getTypeIcon() : "fa-bell";
                    %>
                        <div class="notif-item <%= n.isRead() ? "" : "unread" %>" data-id="<%= n.getId() %>" data-unread="<%= !n.isRead() %>">
                            <span class="notif-unread-dot"></span>
                            <div class="notif-icon-wrapper" style="background: <%= typeColor %>20; color: <%= typeColor %>;">
                                <i class="fa-solid <%= typeIcon %>"></i>
                            </div>
                            <div class="notif-body">
                                <div class="notif-item-title"><%= n.getTitle() != null ? n.getTitle() : "Thông Báo" %></div>
                                <div class="notif-item-content"><%= n.getContent() != null ? n.getContent() : "" %></div>
                                <div class="notif-item-meta">
                                    <span class="notif-item-time"><i class="far fa-clock"></i> <%= n.getTimeAgo() %></span>
                                </div>
                                <div class="notif-actions">
                                    <% if (!"#".equals(linkUrl)) { %>
                                        <a href="<%= linkUrl %>" class="action-link" onclick="handleNotifClick(<%= n.getId() %>, event)">
                                            Xem chi tiết <i class="fas fa-chevron-right"></i>
                                        </a>
                                    <% } %>
                                    <% if (!n.isRead()) { %>
                                        <button type="button" class="btn-sm-action read-btn" onclick="markSingleRead(<%= n.getId() %>, event)">
                                            <i class="fas fa-check"></i> Đánh dấu đã đọc
                                        </button>
                                    <% } %>
                                    <button type="button" class="btn-sm-action" onclick="deleteSingleNotif(<%= n.getId() %>, event)">
                                        <i class="fas fa-trash-can"></i> Xóa
                                    </button>
                                </div>
                            </div>
                        </div>
                    <% } %>
                <% } %>
            </div>
            
            <div id="noFilterState" class="empty-state" style="display: none;">
                <i class="fas fa-filter"></i>
                <h3>Không tìm thấy thông báo</h3>
                <p>Không có thông báo phù hợp với bộ lọc được chọn.</p>
            </div>
        </div>
    </div>

    <script>
        var currentTab = 'all';

        function filterNotifs(tab, btn) {
            currentTab = tab;
            document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');

            var items = document.querySelectorAll('.notif-item');
            var visibleCount = 0;

            items.forEach(function(item) {
                var isUnread = item.getAttribute('data-unread') === 'true';
                var show = false;

                if (tab === 'all') show = true;
                else if (tab === 'unread') show = isUnread;
                else if (tab === 'read') show = !isUnread;

                if (show) {
                    item.style.display = 'flex';
                    visibleCount++;
                } else {
                    item.style.display = 'none';
                }
            });

            var noFilterState = document.getElementById('noFilterState');
            if (visibleCount === 0 && items.length > 0) {
                noFilterState.style.display = 'block';
            } else {
                noFilterState.style.display = 'none';
            }
        }

        function handleNotifClick(id, event) {
            var item = document.querySelector('.notif-item[data-id="' + id + '"]');
            if (item && item.classList.contains('unread')) {
                // Mark as read in background
                fetch('<%= ctx %>/notifications?action=read&id=' + id, { method: 'POST' });
            }
        }

        function markSingleRead(id, event) {
            if (event) event.stopPropagation();

            fetch('<%= ctx %>/notifications?action=read&id=' + id, { method: 'POST' })
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        var item = document.querySelector('.notif-item[data-id="' + id + '"]');
                        if (item) {
                            item.classList.remove('unread');
                            item.setAttribute('data-unread', 'false');
                            
                            var readBtn = item.querySelector('.read-btn');
                            if (readBtn) readBtn.remove();
                        }
                        updateBadges();
                        if (typeof loadNotifCount === 'function') loadNotifCount();
                    }
                })
                .catch(err => console.error('Mark read error:', err));
        }

        function deleteSingleNotif(id, event) {
            if (event) event.stopPropagation();

            fetch('<%= ctx %>/notifications?action=delete&id=' + id, { method: 'POST' })
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        var item = document.querySelector('.notif-item[data-id="' + id + '"]');
                        if (item) {
                            item.style.opacity = '0';
                            item.style.transform = 'scale(0.95)';
                            setTimeout(function() {
                                item.remove();
                                updateBadges();
                                if (typeof loadNotifCount === 'function') loadNotifCount();
                            }, 200);
                        }
                    }
                })
                .catch(err => console.error('Delete notif error:', err));
        }

        function markAllReadPage() {
            fetch('<%= ctx %>/notifications?action=read&markAll=true', { method: 'POST' })
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        document.querySelectorAll('.notif-item.unread').forEach(function(item) {
                            item.classList.remove('unread');
                            item.setAttribute('data-unread', 'false');
                            var readBtn = item.querySelector('.read-btn');
                            if (readBtn) readBtn.remove();
                        });
                        updateBadges();
                        if (typeof loadNotifCount === 'function') loadNotifCount();
                    }
                })
                .catch(err => console.error('Mark all read error:', err));
        }

        function updateBadges() {
            var items = document.querySelectorAll('.notif-item');
            var total = items.length;
            var unread = 0;

            items.forEach(function(item) {
                if (item.getAttribute('data-unread') === 'true') {
                    unread++;
                }
            });

            var badgeAll = document.getElementById('badge-all');
            var badgeUnread = document.getElementById('badge-unread');
            var badgeRead = document.getElementById('badge-read');

            if (badgeAll) badgeAll.textContent = total;
            if (badgeUnread) badgeUnread.textContent = unread;
            if (badgeRead) badgeRead.textContent = total - unread;

            // Refresh current filter tab view
            var activeBtn = document.querySelector('.filter-btn.active');
            if (activeBtn) filterNotifs(currentTab, activeBtn);
        }
    </script>
</body>
</html>
