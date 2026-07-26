<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Order" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Account user = (Account) session.getAttribute("Account");
    if (user == null || !"staff".equals(user.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    List<Order> waitingOrders = (List<Order>) request.getAttribute("waitingOrders");
    List<Account> shippers = (List<Account>) request.getAttribute("shippers");
    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn Hàng Chờ Giao | Sena Shop</title>
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
        .page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 1.5rem; }
        .page-title { font-size: 1.5rem; font-weight: 800; color: var(--gray-800); display: flex; align-items: center; gap: 0.5rem; }
        .page-title i { color: var(--green); }
        .card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--gray-200); box-shadow: var(--shadow-sm); overflow: hidden; }
        .table { width: 100%; border-collapse: collapse; }
        .table th { background: var(--gray-50); padding: 0.9rem 1rem; text-align: left; font-size: 0.8rem; font-weight: 600; color: var(--gray-600); text-transform: uppercase; letter-spacing: 0.05em; border-bottom: 1px solid var(--gray-200); }
        .table th:first-child { min-width: 120px; text-align: center; white-space: nowrap; }
        .table td { padding: 0.9rem 1rem; font-size: 0.875rem; border-bottom: 1px solid var(--gray-100); vertical-align: middle; }
        .table td:first-child { text-align: center; }
        .table tr:last-child td { border-bottom: none; }
        .table tr:hover td { background: var(--gray-50); }
        .table tr.selected td { background: #e8f5e9; }
        .checkbox-wrapper { display: flex; align-items: center; justify-content: center; }
        .custom-checkbox { width: 20px; height: 20px; cursor: pointer; accent-color: var(--green); }
        .badge { display: inline-flex; align-items: center; padding: 0.25rem 0.6rem; border-radius: 100px; font-size: 0.75rem; font-weight: 600; }
        .badge-yellow { background: #fef3c7; color: #92400e; }
        .btn { padding: 0.6rem 1.2rem; border-radius: var(--radius-sm); font-size: 0.875rem; font-weight: 600; text-decoration: none; transition: all 0.15s; cursor: pointer; border: none; display: inline-flex; align-items: center; gap: 0.5rem; }
        .btn-primary { background: var(--green); color: white; }
        .btn-primary:hover { background: var(--green-dark); }
        .btn-primary:disabled { background: var(--gray-400); cursor: not-allowed; }
        .btn-outline { background: transparent; border: 2px solid var(--gray-200); color: var(--gray-600); }
        .btn-outline:hover { border-color: var(--green); color: var(--green); }
        .empty-state { text-align: center; padding: 3rem; color: var(--gray-400); }
        
        /* Filter Bar */
        .filter-bar {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 1.25rem;
            flex-wrap: wrap;
        }
        .filter-bar .filter-label {
            font-size: 0.8rem;
            font-weight: 600;
            color: var(--gray-600);
            margin-right: 0.25rem;
            white-space: nowrap;
        }
        .filter-btn {
            padding: 0.45rem 1rem;
            border-radius: 100px;
            font-size: 0.8rem;
            font-weight: 600;
            border: 2px solid var(--gray-200);
            background: var(--white);
            color: var(--gray-600);
            cursor: pointer;
            transition: all 0.18s;
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
        }
        .filter-btn:hover {
            border-color: var(--green);
            color: var(--green-dark);
            background: var(--green-light);
        }
        .filter-btn.active {
            background: var(--green);
            border-color: var(--green);
            color: #fff;
            box-shadow: 0 2px 8px rgba(76,175,80,0.25);
        }
        .filter-count {
            background: rgba(255,255,255,0.3);
            border-radius: 100px;
            padding: 0 6px;
            font-size: 0.7rem;
            min-width: 18px;
            text-align: center;
        }
        .filter-btn:not(.active) .filter-count {
            background: var(--gray-100);
            color: var(--gray-600);
        }
        .no-filter-result { display: none; text-align: center; padding: 2.5rem; color: var(--gray-400); }
        .no-filter-result i { font-size: 2.5rem; margin-bottom: 0.75rem; }
        
        /* Modal */
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center; }
        .modal-overlay.show { display: flex; }
        .modal { background: var(--white); border-radius: var(--radius); width: 100%; max-width: 480px; max-height: 90vh; overflow: hidden; box-shadow: 0 20px 60px rgba(0,0,0,0.3); }
        .modal-header { padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--gray-200); display: flex; align-items: center; justify-content: space-between; }
        .modal-header h3 { font-size: 1.1rem; font-weight: 700; color: var(--gray-800); display: flex; align-items: center; gap: 0.5rem; }
        .modal-header h3 i { color: var(--green); }
        .modal-close { background: none; border: none; font-size: 1.25rem; color: var(--gray-400); cursor: pointer; padding: 0.25rem; }
        .modal-close:hover { color: var(--gray-600); }
        .modal-body { padding: 1.5rem; max-height: 60vh; overflow-y: auto; }
        .modal-footer { padding: 1rem 1.5rem; border-top: 1px solid var(--gray-200); display: flex; gap: 0.75rem; justify-content: flex-end; }
        .form-group { margin-bottom: 1.25rem; }
        .form-group label { display: block; font-size: 0.875rem; font-weight: 600; color: var(--gray-600); margin-bottom: 0.5rem; }
        .form-group select { width: 100%; padding: 0.65rem 0.85rem; border: 2px solid var(--gray-200); border-radius: var(--radius-sm); font-size: 0.875rem; font-family: inherit; background: var(--white); cursor: pointer; }
        .form-group select:focus { outline: none; border-color: var(--green); }
        .form-group textarea { width: 100%; padding: 0.65rem 0.85rem; border: 2px solid var(--gray-200); border-radius: var(--radius-sm); font-size: 0.875rem; font-family: inherit; resize: vertical; min-height: 80px; }
        .form-group textarea:focus { outline: none; border-color: var(--green); }
        .selected-info { background: var(--green-light); padding: 0.75rem 1rem; border-radius: var(--radius-sm); margin-bottom: 1.25rem; font-size: 0.875rem; color: var(--green-dark); display: flex; align-items: center; gap: 0.5rem; }
        .shipper-option { display: flex; align-items: center; gap: 0.75rem; padding: 0.75rem; border: 2px solid var(--gray-200); border-radius: var(--radius-sm); margin-bottom: 0.5rem; cursor: pointer; transition: all 0.15s; }
        .shipper-option:hover { border-color: var(--green); background: var(--green-light); }
        .shipper-option.selected { border-color: var(--green); background: var(--green-light); }
        .shipper-avatar { width: 40px; height: 40px; border-radius: 50%; background: var(--gray-200); display: flex; align-items: center; justify-content: center; font-weight: 700; color: var(--gray-600); }
        .shipper-info { flex: 1; }
        .shipper-name { font-weight: 600; font-size: 0.9rem; }
        .shipper-phone { font-size: 0.8rem; color: var(--gray-400); }
        .shipper-check { color: var(--green); font-size: 1.1rem; display: none; }
        .shipper-option.selected .shipper-check { display: block; }
        .hidden { display: none; }
    </style>
</head>
<body>
    <nav class="topnav">
        <a href="${pageContext.request.contextPath}/staff/delivery" class="nav-logo">
            <i class="fas fa-warehouse"></i> Staff Panel
        </a>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/staff/delivery">Giao Hàng</a>
            <a href="${pageContext.request.contextPath}/staff/orders-waiting" class="active">Đơn Chờ Giao</a>
            <a href="${pageContext.request.contextPath}/staff/delivery-history">Lịch Sử</a>
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
        
        <div class="page-header">
            <div class="page-title">
                <i class="fas fa-clock"></i> Đơn Hàng Chờ Giao
            </div>
            <button type="button" id="assignDeliveryBtn" class="btn btn-primary" disabled onclick="openShipperModal()">
                <i class="fas fa-motorcycle"></i> Giao Hàng (<span id="selectedCount">0</span>)
            </button>
        </div>
        
        <!-- Filter Bar -->
        <div class="filter-bar">
            <span class="filter-label"><i class="fas fa-filter"></i> Lọc:</span>
            <button class="filter-btn active" id="filter-all" onclick="applyFilter('all', this)">
                <i class="fas fa-list"></i> Tất Cả
                <span class="filter-count" id="count-all">0</span>
            </button>
            <button class="filter-btn" id="filter-newest" onclick="applyFilter('newest', this)">
                <i class="fas fa-arrow-down-short-wide"></i> Mới Nhất
                <span class="filter-count" id="count-newest">0</span>
            </button>
            <button class="filter-btn" id="filter-today" onclick="applyFilter('today', this)">
                <i class="fas fa-calendar-day"></i> Hôm Nay
                <span class="filter-count" id="count-today">0</span>
            </button>
            <button class="filter-btn" id="filter-week" onclick="applyFilter('week', this)">
                <i class="fas fa-calendar-week"></i> Tuần Này
                <span class="filter-count" id="count-week">0</span>
            </button>
            <button class="filter-btn" id="filter-month" onclick="applyFilter('month', this)">
                <i class="fas fa-calendar-alt"></i> Tháng Này
                <span class="filter-count" id="count-month">0</span>
            </button>
        </div>
        
        <div class="card">
            <% if (waitingOrders == null || waitingOrders.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-check-circle" style="font-size: 3rem;"></i>
                <p>Không có đơn hàng nào đang chờ giao</p>
            </div>
            <% } else { %>
            <div class="no-filter-result" id="noFilterResult">
                <i class="fas fa-search"></i>
                <p>Không có đơn hàng nào trong khoảng thời gian này</p>
            </div>
            <table class="table" id="ordersTable">
                <thead>
                    <tr>
                        <th style="min-width: 120px; white-space: nowrap;">
                            <div class="checkbox-wrapper" style="gap: 0.45rem; white-space: nowrap;">
                                <input type="checkbox" id="selectAll" class="custom-checkbox" onchange="toggleSelectAll()">
                                <label for="selectAll" style="cursor: pointer; font-size: 0.78rem; font-weight: 700; color: var(--gray-600); letter-spacing: 0.05em; user-select: none; margin: 0; white-space: nowrap;">TẤT CẢ</label>
                            </div>
                        </th>
                        <th>Mã Đơn</th>
                        <th>Khách Hàng</th>
                        <th>Địa Chỉ</th>
                        <th>Tổng Tiền</th>
                        <th>Ngày Đặt</th>
                    </tr>
                </thead>
                <tbody id="ordersBody">
                    <% for (Order order : waitingOrders) { %>
                    <tr class="order-row" data-date="<%= order.getOrderDate() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss").format(order.getOrderDate()) : "" %>">
                        <td>
                            <div class="checkbox-wrapper">
                                <input type="checkbox" class="custom-checkbox order-checkbox" 
                                       value="<%= order.getId() %>" 
                                       onchange="updateSelectedCount()">
                            </div>
                        </td>
                        <td>#<%= order.getId() %></td>
                        <td><%= order.getRecipientName() %><br><small style="color: var(--gray-400);"><%= order.getRecipientPhone() %></small></td>
                        <td><%= order.getAddress() %></td>
                        <td><%= nf.format(order.getFinalCost()) %>đ</td>
                        <td><%= order.getOrderDate() != null ? sdf.format(order.getOrderDate()) : "-" %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } %>
        </div>
    </div>

    <!-- Modal Chọn Shipper -->
    <div class="modal-overlay" id="shipperModal">
        <div class="modal">
            <div class="modal-header">
                <h3><i class="fas fa-motorcycle"></i> Giao Hàng Cho Shipper</h3>
                <button type="button" class="modal-close" onclick="closeShipperModal()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <form action="${pageContext.request.contextPath}/staff/assign-delivery" method="POST" id="assignForm">
                <div class="modal-body">
                    <div class="selected-info">
                        <i class="fas fa-box"></i>
                        <span>Đã chọn <strong id="modalSelectedCount">0</strong> đơn hàng</span>
                    </div>
                    
                    <div class="form-group">
                        <label>Chọn Shipper</label>
                        <select name="shipperId" id="shipperSelect" required onchange="selectShipperOption(this.value)">
                            <option value="">-- Chọn shipper --</option>
                            <% if (shippers != null) { %>
                                <% for (Account shipper : shippers) { %>
                                <option value="<%= shipper.getId() %>"><%= shipper.getFullname() %> - <%= shipper.getPhone() != null ? shipper.getPhone() : "Chưa có SĐT" %></option>
                                <% } %>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Ghi Chú (không bắt buộc)</label>
                        <textarea name="note" placeholder="Ví dụ: Giao nhanh, gọi điện trước khi giao..."></textarea>
                    </div>
                    
                    <input type="hidden" name="orderIds" id="selectedOrderIds">
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline" onclick="closeShipperModal()">Hủy</button>
                    <button type="submit" class="btn btn-primary" id="confirmBtn" disabled>
                        <i class="fas fa-check"></i> Xác Nhận Giao Hàng
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // ==================== Filter Logic ====================
        var currentFilter = 'all';
        var currentSort = 'asc'; // default: oldest first (original)

        function getStartOfDay(date) {
            var d = new Date(date);
            d.setHours(0, 0, 0, 0);
            return d;
        }

        function getStartOfWeek(date) {
            var d = new Date(date);
            var day = d.getDay(); // 0=Sun
            var diff = d.getDate() - day + (day === 0 ? -6 : 1); // Monday
            d.setDate(diff);
            d.setHours(0, 0, 0, 0);
            return d;
        }

        function getStartOfMonth(date) {
            var d = new Date(date);
            d.setDate(1);
            d.setHours(0, 0, 0, 0);
            return d;
        }

        function applyFilter(type, btnEl) {
            // Update active button
            document.querySelectorAll('.filter-btn').forEach(function(b) {
                b.classList.remove('active');
            });
            btnEl.classList.add('active');
            currentFilter = type;

            var now = new Date();
            var todayStart = getStartOfDay(now);
            var weekStart  = getStartOfWeek(now);
            var monthStart = getStartOfMonth(now);

            var rows = Array.from(document.querySelectorAll('.order-row'));
            var visibleRows = [];

            rows.forEach(function(row) {
                var dateStr = row.getAttribute('data-date');
                var rowDate = dateStr ? new Date(dateStr) : null;
                var show = false;

                if (type === 'all' || type === 'newest') {
                    show = true;
                } else if (type === 'today' && rowDate) {
                    show = rowDate >= todayStart;
                } else if (type === 'week' && rowDate) {
                    show = rowDate >= weekStart;
                } else if (type === 'month' && rowDate) {
                    show = rowDate >= monthStart;
                }

                row.style.display = show ? '' : 'none';
                if (show) visibleRows.push({ row: row, date: rowDate });
            });

            // Sort if 'newest'
            if (type === 'newest') {
                var tbody = document.getElementById('ordersBody');
                visibleRows.sort(function(a, b) {
                    if (!a.date) return 1;
                    if (!b.date) return -1;
                    return b.date - a.date; // descending
                });
                visibleRows.forEach(function(item) {
                    tbody.appendChild(item.row);
                });
            } else if (type === 'all') {
                // Restore original order (ascending by order_date)
                var tbody = document.getElementById('ordersBody');
                visibleRows.sort(function(a, b) {
                    if (!a.date) return 1;
                    if (!b.date) return -1;
                    return a.date - b.date;
                });
                visibleRows.forEach(function(item) {
                    tbody.appendChild(item.row);
                });
            }

            // Show/hide no-result message
            var noResult = document.getElementById('noFilterResult');
            var table    = document.getElementById('ordersTable');
            if (noResult && table) {
                if (visibleRows.length === 0) {
                    noResult.style.display = 'block';
                    table.style.display = 'none';
                } else {
                    noResult.style.display = 'none';
                    table.style.display = '';
                }
            }

            // Uncheck all hidden rows and update count
            document.querySelectorAll('.order-row').forEach(function(row) {
                if (row.style.display === 'none') {
                    var cb = row.querySelector('.order-checkbox');
                    if (cb) cb.checked = false;
                }
            });
            updateSelectedCount();
        }

        function initFilterCounts() {
            var now = new Date();
            var todayStart = getStartOfDay(now);
            var weekStart  = getStartOfWeek(now);
            var monthStart = getStartOfMonth(now);

            var total = 0, today = 0, week = 0, month = 0;
            document.querySelectorAll('.order-row').forEach(function(row) {
                var dateStr = row.getAttribute('data-date');
                var rowDate = dateStr ? new Date(dateStr) : null;
                total++;
                if (rowDate) {
                    if (rowDate >= todayStart) today++;
                    if (rowDate >= weekStart)  week++;
                    if (rowDate >= monthStart) month++;
                }
            });

            var el;
            el = document.getElementById('count-all');    if (el) el.textContent = total;
            el = document.getElementById('count-newest'); if (el) el.textContent = total;
            el = document.getElementById('count-today');  if (el) el.textContent = today;
            el = document.getElementById('count-week');   if (el) el.textContent = week;
            el = document.getElementById('count-month');  if (el) el.textContent = month;
        }

        // ==================== Checkbox Logic ====================
        function toggleSelectAll() {
            const selectAll = document.getElementById('selectAll');
            const checkboxes = document.querySelectorAll('.order-row:not([style*="display: none"]) .order-checkbox');
            checkboxes.forEach(cb => cb.checked = selectAll.checked);
            updateSelectedCount();
        }

        function updateSelectedCount() {
            const checkboxes = document.querySelectorAll('.order-checkbox');
            const selected = Array.from(checkboxes).filter(cb => cb.checked);
            const count = selected.length;
            
            document.getElementById('selectedCount').textContent = count;
            document.getElementById('modalSelectedCount').textContent = count;
            
            const assignBtn = document.getElementById('assignDeliveryBtn');
            assignBtn.disabled = count === 0;
            
            // Update row highlighting
            document.querySelectorAll('.order-row').forEach(row => {
                const cb = row.querySelector('.order-checkbox');
                if (cb && cb.checked) {
                    row.classList.add('selected');
                } else {
                    row.classList.remove('selected');
                }
            });
        }

        function openShipperModal() {
            const checkboxes = document.querySelectorAll('.order-checkbox:checked');
            if (checkboxes.length === 0) return;
            
            // Get selected order IDs
            const orderIds = Array.from(checkboxes).map(cb => cb.value);
            document.getElementById('selectedOrderIds').value = orderIds.join(',');
            
            // Reset form
            document.getElementById('shipperSelect').value = '';
            document.getElementById('confirmBtn').disabled = true;
            
            // Show modal
            document.getElementById('shipperModal').classList.add('show');
        }

        function closeShipperModal() {
            document.getElementById('shipperModal').classList.remove('show');
        }

        function selectShipperOption(shipperId) {
            document.getElementById('confirmBtn').disabled = !shipperId;
        }

        // Close modal when clicking overlay
        document.getElementById('shipperModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeShipperModal();
            }
        });

        // Handle form submission
        document.getElementById('assignForm').addEventListener('submit', function() {
            const btn = document.getElementById('confirmBtn');
            btn.disabled = true;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang xử lý...';
        });

        // Initialize
        updateSelectedCount();
        initFilterCounts();
    </script>
</body>
</html>
