<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Shop" %>
<%@ page import="model.UserReport" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Account user = (Account) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Shop selectedShop = (Shop) request.getAttribute("shop");
    List<Shop> shops = (List<Shop>) request.getAttribute("shops");
    List<UserReport> myReports = (List<UserReport>) request.getAttribute("myReports");

    String errorMsg = (String) session.getAttribute("error");
    if (errorMsg == null) errorMsg = (String) request.getAttribute("error");
    session.removeAttribute("error");

    String successMsg = (String) session.getAttribute("message");
    session.removeAttribute("message");

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo Cáo Cửa Hàng | Sena Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --green:      #4caf50;
            --green-dark: #388e3c;
            --green-light:#e8f5e9;
            --bg:         #f0f4f1;
            --white:      #ffffff;
            --gray-50:    #f8fafb;
            --gray-100:   #eef1ee;
            --gray-200:   #dde5dd;
            --gray-400:   #9aaa9a;
            --gray-600:   #5a6a5a;
            --gray-800:   #2d3d2d;
            --shadow-sm:  0 1px 3px rgba(0,0,0,.08);
            --shadow:     0 4px 12px rgba(0,0,0,.08);
            --radius:     14px;
            --radius-sm:  8px;
            --danger:     #ef4444;
            --danger-dark:#dc2626;
            --danger-bg:  #fef2f2;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg);
            color: var(--gray-800);
            min-height: 100vh;
        }

        /* TOPNAV */
        .topnav {
            background: var(--white);
            border-bottom: 1px solid var(--gray-200);
            height: 64px;
            display: flex;
            align-items: center;
            padding: 0 2rem;
            gap: 1.5rem;
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
        }
        .nav-logo i { color: var(--green); }
        .nav-back {
            margin-left: auto;
            color: var(--gray-600);
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.4rem 0.8rem;
            border-radius: 6px;
            transition: all 0.15s;
        }
        .nav-back:hover { background: var(--gray-100); color: var(--gray-800); }

        /* CONTAINER */
        .main-container {
            max-width: 1100px;
            margin: 2rem auto;
            padding: 0 1.5rem;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
        }

        @media (max-width: 900px) {
            .main-container {
                grid-template-columns: 1fr;
            }
        }

        /* CARDS */
        .card {
            background: var(--white);
            border-radius: var(--radius);
            padding: 1.75rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--gray-200);
        }

        .card-header {
            display: flex;
            align-items: center;
            gap: 0.6rem;
            margin-bottom: 1.25rem;
            padding-bottom: 0.75rem;
            border-bottom: 1px solid var(--gray-200);
        }
        .card-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--gray-800);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .card-title i { color: var(--danger); }

        /* ALERTS */
        .alert {
            padding: 0.85rem 1rem;
            border-radius: var(--radius-sm);
            font-size: 0.9rem;
            margin-bottom: 1.25rem;
            display: flex;
            align-items: center;
            gap: 0.6rem;
        }
        .alert-error {
            background: var(--danger-bg);
            color: var(--danger-dark);
            border: 1px solid #fca5a5;
        }
        .alert-success {
            background: var(--green-light);
            color: var(--green-dark);
            border: 1px solid #a7f3d0;
        }

        /* FORM */
        .form-group {
            margin-bottom: 1.25rem;
        }
        .form-label {
            display: block;
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--gray-800);
            margin-bottom: 0.4rem;
        }
        .form-label span { color: var(--danger); }
        .form-control {
            width: 100%;
            padding: 0.65rem 0.85rem;
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-family: inherit;
            font-size: 0.9rem;
            background: var(--gray-50);
            transition: all 0.15s;
        }
        .form-control:focus {
            outline: none;
            border-color: var(--green);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.15);
        }

        .radio-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.5rem;
        }
        .radio-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.6rem 0.8rem;
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-sm);
            cursor: pointer;
            font-size: 0.85rem;
            transition: all 0.15s;
            background: var(--gray-50);
        }
        .radio-item:hover {
            border-color: var(--green);
            background: var(--white);
        }
        .radio-item input[type="radio"] {
            accent-color: var(--danger);
        }

        .btn-submit {
            width: 100%;
            padding: 0.75rem;
            border: none;
            border-radius: var(--radius-sm);
            background: var(--danger);
            color: var(--white);
            font-weight: 600;
            font-size: 0.95rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            transition: background 0.15s;
        }
        .btn-submit:hover {
            background: var(--danger-dark);
        }

        /* TABLE / REPORTS HISTORY */
        .reports-list {
            display: flex;
            flex-direction: column;
            gap: 0.85rem;
            max-height: 550px;
            overflow-y: auto;
        }
        .report-item {
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-sm);
            padding: 1rem;
            background: var(--gray-50);
        }
        .report-item-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 0.5rem;
        }
        .shop-name-tag {
            font-weight: 700;
            color: var(--gray-800);
            font-size: 0.95rem;
        }
        .badge {
            padding: 0.25rem 0.6rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        .badge-pending   { background: #fef3c7; color: #d97706; }
        .badge-reviewed  { background: #dbeafe; color: #2563eb; }
        .badge-resolved  { background: #d1fae5; color: #059669; }
        .badge-dismissed { background: #fee2e2; color: #dc2626; }

        .report-meta {
            font-size: 0.8rem;
            color: var(--gray-600);
            display: flex;
            gap: 1rem;
            margin-bottom: 0.5rem;
        }
        .report-desc {
            font-size: 0.85rem;
            color: var(--gray-800);
            background: var(--white);
            padding: 0.6rem 0.8rem;
            border-radius: 6px;
            border: 1px solid var(--gray-200);
            line-height: 1.4;
        }
        .admin-response {
            margin-top: 0.5rem;
            font-size: 0.8rem;
            color: #0369a1;
            background: #e0f2fe;
            padding: 0.5rem 0.75rem;
            border-radius: 6px;
        }

        .empty-state {
            text-align: center;
            padding: 3rem 1rem;
            color: var(--gray-600);
        }
        .empty-state i {
            font-size: 2.5rem;
            color: var(--gray-400);
            margin-bottom: 0.75rem;
        }
    </style>
</head>
<body>

    <!-- TOPNAV -->
    <header class="topnav">
        <a href="<%= request.getContextPath() %>/home.jsp" class="nav-logo">
            <i class="fa-solid fa-leaf"></i> Sena Shop
        </a>
        <a href="<%= request.getContextPath() %>/home.jsp" class="nav-back">
            <i class="fa-solid fa-arrow-left"></i> Quay lại trang chủ
        </a>
    </header>

    <!-- MAIN CONTENT -->
    <main class="main-container">
        
        <!-- LEFT: SUBMIT REPORT FORM -->
        <section class="card">
            <div class="card-header">
                <div class="card-title">
                    <i class="fa-solid fa-flag"></i> Tố Cáo Cửa Hàng
                </div>
            </div>

            <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
                <div class="alert alert-error">
                    <i class="fa-solid fa-circle-exclamation"></i>
                    <span><%= errorMsg %></span>
                </div>
            <% } %>

            <% if (successMsg != null && !successMsg.isEmpty()) { %>
                <div class="alert alert-success">
                    <i class="fa-solid fa-circle-check"></i>
                    <span><%= successMsg %></span>
                </div>
            <% } %>

            <form action="<%= request.getContextPath() %>/submit-report" method="POST">
                
                <!-- SHOP SELECTION -->
                <div class="form-group">
                    <label class="form-label" for="shopId">Chọn Cửa Hàng <span>*</span></label>
                    <select name="shopId" id="shopId" class="form-control" required>
                        <option value="">-- Chọn cửa hàng vi phạm --</option>
                        <% if (shops != null) {
                            for (Shop s : shops) { 
                                boolean isSelected = (selectedShop != null && selectedShop.getId() == s.getId());
                        %>
                            <option value="<%= s.getId() %>" <%= isSelected ? "selected" : "" %>>
                                <%= s.getShopName() %> <% if (s.getOwnerFullname() != null) { %>(Chủ shop: <%= s.getOwnerFullname() %>)<% } %>
                            </option>
                        <%  } 
                        } %>
                    </select>
                </div>

                <!-- VIOLATION TYPE -->
                <div class="form-group">
                    <label class="form-label">Loại Vi Phạm <span>*</span></label>
                    <div class="radio-grid">
                        <label class="radio-item">
                            <input type="radio" name="reportType" value="SellingRotten" checked>
                            Bán trái cây hỏng / thối
                        </label>
                        <label class="radio-item">
                            <input type="radio" name="reportType" value="Chemicals">
                            Trái cây ngâm hóa chất
                        </label>
                        <label class="radio-item">
                            <input type="radio" name="reportType" value="UnderWeight">
                            Cân điêu / Thiếu ký
                        </label>
                        <label class="radio-item">
                            <input type="radio" name="reportType" value="LateDelivery">
                            Giao trễ / Giao sai
                        </label>
                        <label class="radio-item">
                            <input type="radio" name="reportType" value="BadAttitude">
                            Thái độ phục vụ kém
                        </label>
                        <label class="radio-item">
                            <input type="radio" name="reportType" value="Other">
                            Khác
                        </label>
                    </div>
                </div>

                <!-- SEVERITY PRIORITY -->
                <div class="form-group">
                    <label class="form-label">Mức Độ Nghiêm Trọng</label>
                    <div style="display: flex; gap: 1rem;">
                        <label class="radio-item" style="flex:1;">
                            <input type="radio" name="priority" value="1"> Thấp
                        </label>
                        <label class="radio-item" style="flex:1;">
                            <input type="radio" name="priority" value="2" checked> Trung bình
                        </label>
                        <label class="radio-item" style="flex:1;">
                            <input type="radio" name="priority" value="3"> Cao
                        </label>
                        <label class="radio-item" style="flex:1;">
                            <input type="radio" name="priority" value="4"> Nghiêm trọng
                        </label>
                    </div>
                </div>

                <!-- ORDER ID (OPTIONAL) -->
                <div class="form-group">
                    <label class="form-label" for="orderId">Mã Đơn Hàng Liên Quan (Không bắt buộc)</label>
                    <input type="text" id="orderId" name="orderId" class="form-control" placeholder="VD: 1024">
                </div>

                <!-- DESCRIPTION -->
                <div class="form-group">
                    <label class="form-label" for="description">Mô Tả Chi Tiết <span>*</span></label>
                    <textarea id="description" name="description" class="form-control" rows="4" placeholder="Nhập mô tả cụ thể về sự cố hoặc bằng chứng vi phạm của cửa hàng (tối thiểu 10 ký tự)..." required></textarea>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="fa-solid fa-paper-plane"></i> Gửi Báo Cáo Cửa Hàng
                </button>
            </form>
        </section>

        <!-- RIGHT: REPORT HISTORY -->
        <section class="card">
            <div class="card-header">
                <div class="card-title" style="color: var(--gray-800);">
                    <i class="fa-solid fa-clock-rotate-left" style="color: var(--green-dark);"></i> Lịch Sử Báo Cáo Của Tôi
                </div>
            </div>

            <div class="reports-list">
                <% if (myReports != null && !myReports.isEmpty()) { 
                    for (UserReport r : myReports) {
                        String statusCss = "badge-pending";
                        if (r.getStatus() == 1) statusCss = "badge-reviewed";
                        if (r.getStatus() == 2) statusCss = "badge-resolved";
                        if (r.getStatus() == 3) statusCss = "badge-dismissed";
                %>
                    <div class="report-item">
                        <div class="report-item-header">
                            <span class="shop-name-tag">
                                <i class="fa-solid fa-store"></i> <%= r.getShopName() != null ? r.getShopName() : ("Shop #" + r.getReportedShopId()) %>
                            </span>
                            <span class="badge <%= statusCss %>">
                                <%= r.getStatusLabel() %>
                            </span>
                        </div>
                        <div class="report-meta">
                            <span><i class="fa-solid fa-tag"></i> <%= r.getReportTypeLabel() %></span>
                            <span><i class="fa-solid fa-layer-group"></i> Mức độ: <%= r.getPriorityLabel() %></span>
                            <span><i class="fa-regular fa-calendar-days"></i> <%= r.getCreatedAt() != null ? dateFormat.format(r.getCreatedAt()) : "" %></span>
                        </div>
                        <div class="report-desc">
                            <%= r.getDescription() %>
                        </div>
                        <% if (r.getAdminNote() != null && !r.getAdminNote().trim().isEmpty()) { %>
                            <div class="admin-response">
                                <strong><i class="fa-solid fa-shield-halved"></i> Phản hồi từ Admin:</strong> <%= r.getAdminNote() %>
                            </div>
                        <% } %>
                    </div>
                <%  } 
                } else { %>
                    <div class="empty-state">
                        <i class="fa-regular fa-folder-open"></i>
                        <p>Bạn chưa gửi báo cáo cửa hàng nào.</p>
                    </div>
                <% } %>
            </div>
        </section>

    </main>

</body>
</html>
