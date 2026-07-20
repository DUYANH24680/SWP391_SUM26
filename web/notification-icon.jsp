<%-- 
    Notification Icon Component
    Include this in any JSP page to show notification bell + dropdown.
    
    Required session attributes:
    - Account (logged in user)
    
    This component loads notifications via AJAX and displays a dropdown panel.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%
    Account user = (Account) session.getAttribute("Account");
    if (user == null) {
        // Not logged in - no notifications
        return;
    }
    int userId = user.getId();
    String role = user.getRoleName();
%>

<style>
    /* Notification Component Styles */
    .notif-container {
        position: relative;
        display: inline-block;
    }
    
    .notif-btn {
        background: none;
        border: none;
        cursor: pointer;
        padding: 8px;
        border-radius: 8px;
        position: relative;
        color: var(--gray-600, #5a6a5a);
        font-size: 1.1rem;
        transition: all 0.2s;
    }
    
    .notif-btn:hover {
        background: var(--green-light, #e8f5e9);
        color: var(--green-dark, #388e3c);
    }
    
    .notif-badge {
        position: absolute;
        top: 2px;
        right: 2px;
        background: #ef4444;
        color: white;
        font-size: 0.65rem;
        font-weight: 700;
        min-width: 18px;
        height: 18px;
        border-radius: 100px;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 0 4px;
        border: 2px solid white;
    }
    
    .notif-badge.hidden {
        display: none;
    }
    
    .notif-dropdown {
        position: absolute;
        top: 100%;
        right: 0;
        width: 380px;
        max-height: 500px;
        background: white;
        border-radius: 12px;
        box-shadow: 0 10px 40px rgba(0,0,0,0.15);
        border: 1px solid #e5e7eb;
        z-index: 1000;
        display: none;
        overflow: hidden;
    }
    
    .notif-dropdown.show {
        display: block;
    }
    
    .notif-header {
        padding: 14px 16px;
        border-bottom: 1px solid #e5e7eb;
        display: flex;
        align-items: center;
        justify-content: space-between;
        background: #f9fafb;
    }
    
    .notif-header h4 {
        font-size: 0.95rem;
        font-weight: 700;
        color: #1f2937;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    
    .notif-header h4 i {
        color: var(--green, #4caf50);
    }
    
    .notif-mark-all {
        background: none;
        border: none;
        font-size: 0.8rem;
        color: var(--green, #4caf50);
        cursor: pointer;
        font-weight: 600;
        padding: 4px 8px;
        border-radius: 4px;
    }
    
    .notif-mark-all:hover {
        background: var(--green-light, #e8f5e9);
    }
    
    .notif-list {
        max-height: 400px;
        overflow-y: auto;
    }
    
    .notif-empty {
        text-align: center;
        padding: 40px 20px;
        color: #9ca3af;
    }
    
    .notif-empty i {
        font-size: 2.5rem;
        margin-bottom: 10px;
        color: #d1d5db;
    }
    
    .notif-empty p {
        font-size: 0.875rem;
        margin: 0;
    }
    
    .notif-item {
        display: flex;
        gap: 12px;
        padding: 12px 16px;
        border-bottom: 1px solid #f3f4f6;
        cursor: pointer;
        transition: background 0.15s;
        text-decoration: none;
        color: inherit;
    }
    
    .notif-item:hover {
        background: #f9fafb;
    }
    
    .notif-item:last-child {
        border-bottom: none;
    }
    
    .notif-item.unread {
        background: #f0fdf4;
    }
    
    .notif-item.unread:hover {
        background: #dcfce7;
    }
    
    .notif-icon {
        width: 40px;
        height: 40px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1rem;
        flex-shrink: 0;
    }
    
    .notif-content {
        flex: 1;
        min-width: 0;
    }
    
    .notif-title {
        font-size: 0.85rem;
        font-weight: 600;
        color: #1f2937;
        margin-bottom: 3px;
        line-height: 1.3;
    }
    
    .notif-text {
        font-size: 0.8rem;
        color: #6b7280;
        line-height: 1.4;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }
    
    .notif-time {
        font-size: 0.75rem;
        color: #9ca3af;
        margin-top: 4px;
    }
    
    .notif-footer {
        padding: 10px 16px;
        border-top: 1px solid #e5e7eb;
        text-align: center;
        background: #f9fafb;
    }
    
    .notif-footer a {
        font-size: 0.8rem;
        color: var(--green, #4caf50);
        font-weight: 600;
        text-decoration: none;
    }
    
    .notif-footer a:hover {
        text-decoration: underline;
    }
    
    .notif-loading {
        text-align: center;
        padding: 30px;
        color: #9ca3af;
    }
    
    .notif-loading i {
        animation: spin 1s linear infinite;
    }
    
    @keyframes spin {
        from { transform: rotate(0deg); }
        to { transform: rotate(360deg); }
    }
</style>

<div class="notif-container">
    <button class="notif-btn" onclick="toggleNotifDropdown(event)" title="Thông báo">
        <i class="fa-regular fa-bell"></i>
        <span class="notif-badge hidden" id="notifBadge">0</span>
    </button>
    
    <div class="notif-dropdown" id="notifDropdown">
        <div class="notif-header">
            <h4><i class="fas fa-bell"></i> Thông Báo</h4>
            <button class="notif-mark-all" onclick="markAllNotifRead(event)">Đánh dấu tất cả đã đọc</button>
        </div>
        
        <div class="notif-list" id="notifList">
            <div class="notif-loading">
                <i class="fas fa-spinner"></i> Đang tải...
            </div>
        </div>
        
        <div class="notif-footer">
            <a href="<%= request.getContextPath() %>/notifications/all">Xem tất cả thông báo</a>
        </div>
    </div>
</div>

<script>
    // Load notifications on page load
    document.addEventListener('DOMContentLoaded', function() {
        loadNotifCount();
        
        // Auto-refresh badge count every 30 seconds
        setInterval(loadNotifCount, 30000);
        
        // Close dropdown when clicking outside
        document.addEventListener('click', function(e) {
            const container = document.querySelector('.notif-container');
            if (container && !container.contains(e.target)) {
                const dropdown = document.getElementById('notifDropdown');
                if (dropdown) {
                    dropdown.classList.remove('show');
                }
            }
        });
    });
    
    function toggleNotifDropdown(event) {
        event.stopPropagation();
        const dropdown = document.getElementById('notifDropdown');
        dropdown.classList.toggle('show');
        
        if (dropdown.classList.contains('show')) {
            loadNotifications();
        }
    }
    
    function loadNotifCount() {
        fetch('<%= request.getContextPath() %>/notifications?action=count')
            .then(response => response.json())
            .then(data => {
                if (data.success && data.count > 0) {
                    const badge = document.getElementById('notifBadge');
                    badge.textContent = data.count > 99 ? '99+' : data.count;
                    badge.classList.remove('hidden');
                }
            })
            .catch(err => console.log('Load notif count error:', err));
    }
    
    function loadNotifications() {
        const list = document.getElementById('notifList');
        list.innerHTML = '<div class="notif-loading"><i class="fas fa-spinner"></i> Đang tải...</div>';
        
        fetch('<%= request.getContextPath() %>/notifications?action=list&limit=10')
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    renderNotifications(data.notifications, data.unreadCount);
                    
                    // Update badge
                    const badge = document.getElementById('notifBadge');
                    if (data.unreadCount > 0) {
                        badge.textContent = data.unreadCount > 99 ? '99+' : data.unreadCount;
                        badge.classList.remove('hidden');
                    } else {
                        badge.classList.add('hidden');
                    }
                } else {
                    list.innerHTML = '<div class="notif-empty"><i class="fas fa-bell-slash"></i><p>Không thể tải thông báo</p></div>';
                }
            })
            .catch(err => {
                console.log('Load notifications error:', err);
                list.innerHTML = '<div class="notif-empty"><i class="fas fa-bell-slash"></i><p>Không thể tải thông báo</p></div>';
            });
    }
    
    function renderNotifications(notifications, unreadCount) {
        const list = document.getElementById('notifList');
        
        if (!notifications || notifications.length === 0) {
            list.innerHTML = '<div class="notif-empty"><i class="fas fa-bell"></i><p>Không có thông báo nào</p></div>';
            return;
        }
        
        let html = '';
        notifications.forEach(function(n) {
            const unreadClass = n.isRead ? '' : 'unread';
            const link = getNotifLink(n);
            
            html += '<a href="' + link + '" class="notif-item ' + unreadClass + '" '
                  + 'onclick="markNotifRead(' + n.id + ', event)" data-notif-id="' + n.id + '">';
            html += '<div class="notif-icon" style="background: ' + n.typeColor + '20; color: ' + n.typeColor + ';">';
            html += '<i class="fa-solid ' + n.typeIcon + '"></i>';
            html += '</div>';
            html += '<div class="notif-content">';
            html += '<div class="notif-title">' + escapeHtml(n.title) + '</div>';
            html += '<div class="notif-text">' + escapeHtml(n.content) + '</div>';
            html += '<div class="notif-time">' + n.timeAgo + '</div>';
            html += '</div>';
            html += '</a>';
        });
        
        list.innerHTML = html;
    }
    
    function getNotifLink(n) {
        if (!n.relatedId) return '#';
        
        switch (n.type) {
            case 'order_status':
                return '<%= request.getContextPath() %>/my-orders';
            case 'new_order':
                return '<%= request.getContextPath() %>/seller/orders';
            case 'staff_assign':
                return '<%= request.getContextPath() %>/staff/orders-waiting';
            case 'delivery':
                return '<%= request.getContextPath() %>/my-orders';
            case 'product_approval':
                return '<%= request.getContextPath() %>/seller/products';
            case 'seller_request':
                return '<%= request.getContextPath() %>/admin/seller-requests';
            case 'voucher':
                return '<%= request.getContextPath() %>/vouchers';
            default:
                return '#';
        }
    }
    
    function markNotifRead(id, event) {
        if (event) event.preventDefault();
        
        fetch('<%= request.getContextPath() %>/notifications?action=read&id=' + id, { method: 'POST' })
            .then(response => response.json())
            .then(data => {
                if (data.success && data.unreadCount !== undefined) {
                    const badge = document.getElementById('notifBadge');
                    if (data.unreadCount > 0) {
                        badge.textContent = data.unreadCount > 99 ? '99+' : data.unreadCount;
                        badge.classList.remove('hidden');
                    } else {
                        badge.classList.add('hidden');
                    }
                    
                    // Remove unread style from this item
                    const item = document.querySelector('[data-notif-id="' + id + '"]');
                    if (item) item.classList.remove('unread');
                }
            })
            .catch(err => console.log('Mark read error:', err));
        
        // Navigate to link if exists
        if (event && event.target && event.target.closest('a')) {
            const link = event.target.closest('a').href;
            if (link && link !== '#') {
                window.location.href = link;
            }
        }
    }
    
    function markAllNotifRead(event) {
        if (event) event.stopPropagation();
        
        fetch('<%= request.getContextPath() %>/notifications?action=read&markAll=true', { method: 'POST' })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    const badge = document.getElementById('notifBadge');
                    badge.classList.add('hidden');
                    
                    // Remove unread style from all items
                    document.querySelectorAll('.notif-item.unread').forEach(function(item) {
                        item.classList.remove('unread');
                    });
                }
            })
            .catch(err => console.log('Mark all read error:', err));
    }
    
    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
</script>
