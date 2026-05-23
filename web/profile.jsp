<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer" %>
<%@ page import="model.DeliveryAddress" %>
<%@ page import="java.util.List" %>
<%
    // Ensure user is logged in
    Customer user = (Customer) session.getAttribute("user");
    String role = (String) session.getAttribute("role");
    
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/profile");
        return;
    }

    String fullname = user.getFullname();
    String username = user.getUsername();
    String email = user.getEmail();
    String phone = user.getPhone();
    String address = user.getAddress();
    String genderStr = "Chưa cập nhật";
    if (user.getGender() != null) {
        genderStr = user.getGender() ? "Nam" : "Nữ";
    }
    String avatarUrl = user.getAvatar();
    String createdAtStr = "";
    if (user.getCreatedAt() != null) {
        createdAtStr = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(user.getCreatedAt());
    }

    // Default values if empty
    if (phone == null || phone.trim().isEmpty()) phone = "Chưa cập nhật";
    if (address == null || address.trim().isEmpty()) address = "Chưa cập nhật";
    if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
        avatarUrl = "https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(fullname, "UTF-8") + "&background=10b981&color=020617&size=128&bold=true";
    }

    // Load addresses from request attribute
    List<DeliveryAddress> addresses = (List<DeliveryAddress>) request.getAttribute("addresses");

    // Flash messages
    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bảo Mật Thông Tin & Quản Lý Địa Chỉ | FreshBasket Portal</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- FontAwesome for Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        :root {
            --primary: #10b981; /* Fresh Emerald */
            --primary-hover: #059669;
            --accent: #f59e0b; /* Sunny Amber */
            --background: #020617; /* Deep Space Blue/Black */
            --card-bg: rgba(255, 255, 255, 0.03);
            --card-border: rgba(255, 255, 255, 0.07);
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
            --badge-default: rgba(16, 185, 129, 0.15);
            --badge-normal: rgba(255, 255, 255, 0.05);
            --danger: #ef4444;
            --danger-hover: #dc2626;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Outfit', sans-serif;
            transition: all 0.3s ease;
        }

        body {
            background: radial-gradient(circle at 90% 10%, rgba(16, 185, 129, 0.12) 0%, rgba(2, 6, 23, 0) 45%), 
                        radial-gradient(circle at 10% 90%, rgba(245, 158, 11, 0.08) 0%, rgba(2, 6, 23, 0) 45%),
                        #020617;
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            overflow-x: hidden;
            padding: 2rem 1rem;
        }

        /* Ambient glow background spheres */
        .glow-sphere-1 {
            position: absolute;
            width: 400px;
            height: 400px;
            background: var(--primary);
            filter: blur(180px);
            opacity: 0.12;
            top: 10%;
            right: 10%;
            border-radius: 50%;
            pointer-events: none;
            animation: float 12s ease-in-out infinite alternate;
        }

        .glow-sphere-2 {
            position: absolute;
            width: 350px;
            height: 350px;
            background: var(--accent);
            filter: blur(150px);
            opacity: 0.08;
            bottom: 10%;
            left: 10%;
            border-radius: 50%;
            pointer-events: none;
            animation: float 10s ease-in-out infinite alternate-reverse;
        }

        @keyframes float {
            0% { transform: translateY(0px) scale(1); }
            100% { transform: translateY(40px) scale(1.1); }
        }

        /* Glassmorphism Dashboard Container */
        .profile-container {
            width: 100%;
            max-width: 850px;
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 28px;
            backdrop-filter: blur(25px);
            -webkit-backdrop-filter: blur(25px);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.6);
            z-index: 10;
            position: relative;
            overflow: hidden;
            animation: slideUp 0.7s cubic-bezier(0.16, 1, 0.3, 1);
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(40px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Top decorative banner */
        .banner-glow {
            height: 120px;
            background: linear-gradient(135deg, rgba(16, 185, 129, 0.25) 0%, rgba(245, 158, 11, 0.15) 100%);
            border-bottom: 1px solid var(--card-border);
            position: relative;
        }

        /* Profile Header Area */
        .profile-header {
            padding: 0 2.5rem;
            position: relative;
            margin-top: -60px;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            margin-bottom: 1.5rem;
        }

        .avatar-wrapper {
            position: relative;
            width: 128px;
            height: 128px;
            border-radius: 50%;
            padding: 5px;
            background: linear-gradient(135deg, var(--primary) 0%, var(--accent) 100%);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.5);
            margin-bottom: 1rem;
        }

        .avatar-img {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
            border: 4px solid #040d21;
        }

        .user-name {
            font-size: 2rem;
            font-weight: 700;
            margin-top: 0.5rem;
            background: linear-gradient(135deg, #ffffff 60%, var(--text-muted) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .user-meta-sub {
            color: var(--text-muted);
            font-size: 0.95rem;
            margin-top: 0.2rem;
        }

        /* Tabs System */
        .profile-tabs {
            display: flex;
            justify-content: center;
            gap: 0.5rem;
            border-bottom: 1px solid var(--card-border);
            padding: 0 1.5rem;
            margin-bottom: 2rem;
        }

        .tab-btn {
            background: transparent;
            border: none;
            color: var(--text-muted);
            padding: 1rem 1.5rem;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            position: relative;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .tab-btn:hover {
            color: var(--text-main);
        }

        .tab-btn.active {
            color: var(--primary);
        }

        .tab-btn.active::after {
            content: '';
            position: absolute;
            bottom: -1px;
            left: 0;
            right: 0;
            height: 3px;
            background: var(--primary);
            border-radius: 3px 3px 0 0;
            box-shadow: 0 -2px 10px var(--primary);
        }

        /* Tab Content */
        .tab-pane {
            display: none;
            padding: 0 2.5rem 2.5rem 2.5rem;
            animation: fadeIn 0.4s ease;
        }

        .tab-pane.active {
            display: block;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Alerts */
        .alert {
            display: flex;
            align-items: center;
            gap: 0.8rem;
            padding: 1rem 1.5rem;
            border-radius: 12px;
            margin-bottom: 1.5rem;
            font-weight: 500;
        }

        .alert-success {
            background: rgba(16, 185, 129, 0.1);
            border: 1px solid rgba(16, 185, 129, 0.2);
            color: var(--primary);
        }

        .alert-danger {
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid rgba(239, 68, 68, 0.2);
            color: var(--danger);
        }

        /* Profile details grid & cards */
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .info-card {
            background: rgba(255, 255, 255, 0.015);
            border: 1px solid rgba(255, 255, 255, 0.04);
            border-radius: 16px;
            padding: 1.2rem;
            display: flex;
            align-items: flex-start;
            gap: 1rem;
        }

        .info-icon {
            width: 42px;
            height: 42px;
            border-radius: 10px;
            background: rgba(255, 255, 255, 0.03);
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 1.2rem;
            color: var(--primary);
            flex-shrink: 0;
            border: 1px solid rgba(255, 255, 255, 0.05);
        }

        .info-content {
            display: flex;
            flex-direction: column;
        }

        .info-label {
            font-size: 0.8rem;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 0.2rem;
            font-weight: 500;
        }

        .info-value {
            font-size: 1rem;
            color: var(--text-main);
            font-weight: 500;
            word-break: break-word;
        }

        /* Forms styling */
        .form-section-title {
            font-size: 1.25rem;
            font-weight: 600;
            margin-bottom: 1.2rem;
            color: #ffffff;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            padding-bottom: 0.5rem;
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.2rem;
            margin-bottom: 1.5rem;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 0.4rem;
        }

        .form-group.full-width {
            grid-column: span 2;
        }

        label {
            font-size: 0.9rem;
            color: var(--text-muted);
            font-weight: 500;
        }

        input[type="text"], input[type="email"], input[type="password"], textarea, select {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            padding: 0.8rem 1rem;
            color: #ffffff;
            font-size: 0.95rem;
            outline: none;
        }

        input[type="text"]:focus, input[type="email"]:focus, input[type="password"]:focus, textarea:focus, select:focus {
            border-color: var(--primary);
            background: rgba(16, 185, 129, 0.03);
            box-shadow: 0 0 10px rgba(16, 185, 129, 0.15);
        }

        /* View / Edit modes for in-place edit */
        .view-mode {
            display: inline-block;
        }
        .edit-mode {
            display: none;
            width: 100%;
        }
        .edit-mode input, .edit-mode select, .edit-mode textarea {
            width: 100%;
            margin-top: 0.3rem;
            padding: 0.5rem 0.8rem;
            font-size: 0.9rem;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.1);
            color: #ffffff;
            border-radius: 8px;
        }

        /* Addresses cards list */
        .address-list {
            display: flex;
            flex-direction: column;
            gap: 1.2rem;
            margin-bottom: 2rem;
        }

        .address-item {
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid rgba(255, 255, 255, 0.06);
            border-radius: 16px;
            padding: 1.2rem 1.5rem;
            position: relative;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .address-item:hover {
            border-color: rgba(16, 185, 129, 0.3);
            background: rgba(16, 185, 129, 0.01);
        }

        .address-info {
            display: flex;
            flex-direction: column;
            gap: 0.4rem;
        }

        .address-header {
            display: flex;
            align-items: center;
            gap: 0.8rem;
            flex-wrap: wrap;
        }

        .recipient-name {
            font-size: 1.1rem;
            font-weight: 600;
            color: #ffffff;
        }

        .recipient-phone {
            font-size: 0.95rem;
            color: var(--text-muted);
            font-weight: 500;
        }

        .badge {
            font-size: 0.75rem;
            font-weight: 600;
            padding: 0.2rem 0.6rem;
            border-radius: 100px;
            text-transform: uppercase;
        }

        .badge-default {
            background: var(--badge-default);
            color: var(--primary);
            border: 1px solid rgba(16, 185, 129, 0.3);
        }

        .address-detail {
            font-size: 0.95rem;
            color: var(--text-main);
        }

        .address-note {
            font-size: 0.85rem;
            color: var(--text-muted);
            font-style: italic;
            display: flex;
            align-items: center;
            gap: 0.3rem;
        }

        .address-actions {
            display: flex;
            gap: 0.6rem;
            align-items: center;
        }

        /* Buttons */
        .btn {
            padding: 0.75rem 1.25rem;
            border-radius: 10px;
            font-size: 0.9rem;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.4rem;
            border: none;
            text-decoration: none;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary) 0%, #10b981d0 100%);
            color: #020617;
            box-shadow: 0 4px 15px rgba(16, 185, 129, 0.2);
        }

        .btn-primary:hover {
            background: linear-gradient(135deg, var(--primary-hover) 0%, var(--primary) 100%);
            transform: translateY(-1px);
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            color: var(--text-main);
        }

        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.08);
            border-color: rgba(255, 255, 255, 0.2);
        }

        .btn-danger {
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid rgba(239, 68, 68, 0.2);
            color: #f87171;
        }

        .btn-danger:hover {
            background: rgba(239, 68, 68, 0.2);
            border-color: var(--danger);
            color: #ffffff;
        }

        .btn-sm {
            padding: 0.4rem 0.8rem;
            font-size: 0.8rem;
            border-radius: 8px;
        }

        /* Modal Overlay & Card */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(2, 6, 23, 0.7);
            backdrop-filter: blur(8px);
            z-index: 100;
            justify-content: center;
            align-items: center;
        }

        .modal.active {
            display: flex;
        }

        .modal-content {
            background: #091124;
            border: 1px solid var(--card-border);
            border-radius: 20px;
            width: 90%;
            max-width: 550px;
            padding: 2rem;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.5);
            animation: modalSlideUp 0.3s ease;
        }

        @keyframes modalSlideUp {
            from { transform: translateY(30px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            padding-bottom: 0.8rem;
        }

        .modal-title {
            font-size: 1.3rem;
            font-weight: 700;
            color: #ffffff;
        }

        .close-btn {
            background: transparent;
            border: none;
            color: var(--text-muted);
            font-size: 1.4rem;
            cursor: pointer;
        }

        .close-btn:hover {
            color: var(--danger);
        }

        /* Responsive */
        @media (max-width: 768px) {
            .info-grid, .form-grid {
                grid-template-columns: 1fr;
                gap: 1.2rem;
            }
            .form-group.full-width {
                grid-column: span 1;
            }
            .tab-btn {
                padding: 0.8rem 1rem;
                font-size: 0.9rem;
            }
            .address-item {
                flex-direction: column;
                align-items: flex-start;
                gap: 1.2rem;
            }
            .address-actions {
                width: 100%;
                justify-content: flex-end;
            }
        }
    </style>
</head>
<body>
    <div class="glow-sphere-1"></div>
    <div class="glow-sphere-2"></div>

    <div class="profile-container">
        <!-- Top banner decoration -->
        <div class="banner-glow"></div>

        <!-- Header details -->
        <div class="profile-header">
            <div class="avatar-wrapper">
                <img class="avatar-img" src="<%= avatarUrl %>" alt="Ảnh đại diện">
            </div>
            
            <h1 class="user-name"><%= fullname %></h1>
            <p class="user-meta-sub">@<%= username %> | Khách Hàng Thân Thiết</p>
        </div>

        <!-- Tab Controls -->
        <div class="profile-tabs">
            <button class="tab-btn active" onclick="switchTab('profile-info', this)">
                <i class="fa-regular fa-user"></i> Hồ Sơ Cá Nhân
            </button>
            <button class="tab-btn" onclick="switchTab('address-book', this)">
                <i class="fa-solid fa-map-location-dot"></i> Sổ Địa Chỉ
            </button>
            <button class="tab-btn" onclick="switchTab('security-settings', this)">
                <i class="fa-solid fa-shield-halved"></i> Bảo Mật Tài Khoản
            </button>
        </div>

        <!-- Alerts -->
        <div style="padding: 0 2.5rem;">
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
        </div>

        <!-- ================= TAB 1: PROFILE INFO ================= -->
        <div id="profile-info" class="tab-pane active">
            <form id="profile-form" action="profile" method="POST">
                <input type="hidden" name="action" value="updateProfile">
                
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
                    <h3 class="form-section-title" style="margin-bottom:0; border:none; padding:0;">
                        <i class="fa-regular fa-user"></i> Thông Tin Cá Nhân
                    </h3>
                    <button type="button" id="edit-profile-btn" class="btn btn-primary btn-sm" onclick="toggleProfileEdit()">
                        <i class="fa-regular fa-pen-to-square"></i> Chỉnh sửa
                    </button>
                </div>

                <div class="info-grid">
                    <!-- Fullname Card -->
                    <div class="info-card">
                        <div class="info-icon"><i class="fa-regular fa-address-card"></i></div>
                        <div class="info-content" style="width: 100%;">
                            <span class="info-label">Họ và tên</span>
                            <span class="info-value view-mode"><%= fullname %></span>
                            <div class="edit-mode">
                                <input type="text" name="fullname" value="<%= fullname %>" required>
                            </div>
                        </div>
                    </div>

                    <!-- Email Card -->
                    <div class="info-card">
                        <div class="info-icon"><i class="fa-regular fa-envelope"></i></div>
                        <div class="info-content" style="width: 100%;">
                            <span class="info-label">Địa chỉ Email</span>
                            <span class="info-value view-mode"><%= email %></span>
                            <div class="edit-mode">
                                <input type="email" name="email" value="<%= email %>" required>
                            </div>
                        </div>
                    </div>

                    <!-- Phone Card -->
                    <div class="info-card">
                        <div class="info-icon"><i class="fa-solid fa-phone"></i></div>
                        <div class="info-content" style="width: 100%;">
                            <span class="info-label">Số điện thoại</span>
                            <span class="info-value view-mode"><%= phone %></span>
                            <div class="edit-mode">
                                <input type="text" name="phone" value="<%= "Chưa cập nhật".equals(phone) ? "" : phone %>">
                            </div>
                        </div>
                    </div>

                    <!-- Gender Card -->
                    <div class="info-card">
                        <div class="info-icon"><i class="fa-solid fa-venus-mars"></i></div>
                        <div class="info-content" style="width: 100%;">
                            <span class="info-label">Giới tính</span>
                            <span class="info-value view-mode"><%= genderStr %></span>
                            <div class="edit-mode">
                                <select name="gender">
                                    <option value="" <%= user.getGender() == null ? "selected" : "" %>>Chưa chọn</option>
                                    <option value="1" <%= (user.getGender() != null && user.getGender()) ? "selected" : "" %>>Nam</option>
                                    <option value="0" <%= (user.getGender() != null && !user.getGender()) ? "selected" : "" %>>Nữ</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- Date Joined Card -->
                    <div class="info-card">
                        <div class="info-icon"><i class="fa-regular fa-calendar-check"></i></div>
                        <div class="info-content">
                            <span class="info-label">Ngày tham gia</span>
                            <span class="info-value"><%= createdAtStr %></span>
                        </div>
                    </div>

                    <!-- Avatar Card -->
                    <div class="info-card">
                        <div class="info-icon"><i class="fa-regular fa-image"></i></div>
                        <div class="info-content" style="width: 100%;">
                            <span class="info-label">Ảnh đại diện (Avatar URL)</span>
                            <span class="info-value view-mode" style="font-size:0.85rem; max-width:200px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;"><%= user.getAvatar() != null ? user.getAvatar() : "Mặc định" %></span>
                            <div class="edit-mode">
                                <input type="text" name="avatar" value="<%= user.getAvatar() != null ? user.getAvatar() : "" %>" placeholder="https://...">
                            </div>
                        </div>
                    </div>

                    <!-- Full Address Card -->
                    <div class="info-card" style="grid-column: span 2;">
                        <div class="info-icon"><i class="fa-solid fa-map-location-dot"></i></div>
                        <div class="info-content" style="width: 100%;">
                            <span class="info-label">Địa chỉ chi tiết</span>
                            <span class="info-value view-mode"><%= address %></span>
                            <div class="edit-mode">
                                <textarea name="address" rows="2"><%= "Chưa cập nhật".equals(address) ? "" : address %></textarea>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Submit / Cancel actions -->
                <div id="profile-edit-actions" style="display:none; justify-content:flex-end; gap:0.8rem; margin-top:1.5rem;">
                    <button type="button" class="btn btn-secondary" onclick="cancelProfileEdit()"><i class="fa-solid fa-xmark"></i> Hủy bỏ</button>
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi</button>
                </div>
            </form>
        </div>

        <!-- ================= TAB 2: ADDRESS BOOK ================= -->
        <div id="address-book" class="tab-pane">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
                <h3 class="form-section-title" style="margin-bottom:0; border:none; padding:0;">
                    <i class="fa-regular fa-address-book"></i> Địa Chỉ Giao Hàng Đã Lưu
                </h3>
                <button class="btn btn-primary btn-sm" onclick="openAddModal()">
                    <i class="fa-solid fa-plus"></i> Thêm Địa Chỉ
                </button>
            </div>

            <div class="address-list">
                <% if (addresses == null || addresses.isEmpty()) { %>
                    <div style="text-align:center; padding:3rem 1rem; color:var(--text-muted); background:rgba(255,255,255,0.01); border-radius:16px; border:1px dashed var(--card-border);">
                        <i class="fa-solid fa-map-location" style="font-size:3rem; margin-bottom:1rem; opacity:0.5;"></i>
                        <p>Bạn chưa lưu địa chỉ nhận hàng nào.</p>
                    </div>
                <% } else { %>
                    <% for (DeliveryAddress addr : addresses) { %>
                        <div class="address-item">
                            <div class="address-info">
                                <div class="address-header">
                                    <span class="recipient-name"><%= addr.getRecipientName() %></span>
                                    <span class="recipient-phone"><i class="fa-solid fa-phone" style="font-size:0.8rem;"></i> <%= addr.getRecipientPhone() %></span>
                                    <% if (addr.isIsDefault()) { %>
                                        <span class="badge badge-default"><i class="fa-solid fa-star"></i> Mặc định</span>
                                    <% } %>
                                </div>
                                <div class="address-detail"><%= addr.getAddress() %></div>
                                <% if (addr.getNote() != null && !addr.getNote().trim().isEmpty()) { %>
                                    <div class="address-note"><i class="fa-regular fa-comment-dots"></i> Ghi chú: <%= addr.getNote() %></div>
                                <% } %>
                            </div>
                            <div class="address-actions">
                                <% if (!addr.isIsDefault()) { %>
                                    <a href="profile?action=setDefault&id=<%= addr.getId() %>" class="btn btn-secondary btn-sm" title="Đặt làm mặc định">
                                        Mặc định
                                    </a>
                                <% } %>
                                <button class="btn btn-secondary btn-sm" onclick="openEditModal(<%= addr.getId() %>, '<%= addr.getRecipientName().replace("'", "\\'") %>', '<%= addr.getRecipientPhone().replace("'", "\\'") %>', '<%= addr.getAddress().replace("'", "\\'") %>', '<%= addr.getNote() != null ? addr.getNote().replace("'", "\\'") : "" %>', <%= addr.isIsDefault() ? 1 : 0 %>)">
                                    <i class="fa-regular fa-pen-to-square"></i> Sửa
                                </button>
                                <a href="profile?action=delete&id=<%= addr.getId() %>" class="btn btn-danger btn-sm" onclick="return confirm('Bạn chắc chắn muốn xóa địa chỉ này?')" title="Xóa địa chỉ">
                                    <i class="fa-regular fa-trash-can"></i>
                                </a>
                            </div>
                        </div>
                    <% } %>
                <% } %>
            </div>
        </div>

        <!-- ================= TAB 3: ACCOUNT SECURITY ================= -->
        <div id="security-settings" class="tab-pane">
            
            <!-- Change Password -->
            <form action="profile" method="POST" style="margin-bottom: 3rem;">
                <input type="hidden" name="action" value="changePassword">
                <h3 class="form-section-title"><i class="fa-solid fa-key"></i> Thay Đổi Mật Khẩu</h3>
                
                <div class="form-grid">
                    <div class="form-group">
                        <label for="currentPassword">Mật khẩu hiện tại</label>
                        <input type="password" id="currentPassword" name="currentPassword" required>
                    </div>
                    <div style="grid-column: span 1;"></div>
                    
                    <div class="form-group">
                        <label for="newPassword">Mật khẩu mới</label>
                        <input type="password" id="newPassword" name="newPassword" required>
                    </div>
                    <div class="form-group">
                        <label for="confirmPassword">Xác nhận mật khẩu mới</label>
                        <input type="password" id="confirmPassword" name="confirmPassword" required>
                    </div>
                </div>

                <div style="display:flex; justify-content:flex-end;">
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-arrows-rotate"></i> Cập nhật mật khẩu</button>
                </div>
            </form>

            <!-- Forgot / Reset Password Widget -->
            <div style="border-top:1px solid var(--card-border); padding-top:2rem; display:grid; grid-template-columns: 1fr 1fr; gap:2rem;">
                <!-- Forgot Password -->
                <form action="profile" method="POST">
                    <input type="hidden" name="action" value="forgotPassword">
                    <h3 class="form-section-title" style="font-size:1.1rem; border:none; padding-bottom:0;"><i class="fa-regular fa-circle-question"></i> Bạn Quên Mật Khẩu?</h3>
                    <p style="font-size:0.85rem; color:var(--text-muted); margin-bottom:1rem;">Nhập email đăng ký để tạo mã khôi phục mật khẩu ngay lập tức.</p>
                    
                    <div class="form-group" style="margin-bottom:1rem;">
                        <label for="forgotEmail">Email khôi phục</label>
                        <input type="email" id="forgotEmail" name="email" placeholder="example@gmail.com" required>
                    </div>
                    <button type="submit" class="btn btn-secondary" style="width:100%;"><i class="fa-solid fa-paper-plane"></i> Lấy Mã Khôi Phục</button>
                </form>

                <!-- Reset Password -->
                <form action="profile" method="POST">
                    <input type="hidden" name="action" value="resetPassword">
                    <h3 class="form-section-title" style="font-size:1.1rem; border:none; padding-bottom:0;"><i class="fa-solid fa-lock-open"></i> Đặt Lại Mật Khẩu</h3>
                    <p style="font-size:0.85rem; color:var(--text-muted); margin-bottom:1rem;">Nhập mã khôi phục nhận được cùng mật khẩu mới của bạn.</p>
                    
                    <div class="form-group" style="margin-bottom:0.8rem;">
                        <input type="email" name="email" placeholder="Email đăng ký" required>
                    </div>
                    <div class="form-group" style="margin-bottom:0.8rem;">
                        <input type="text" name="token" placeholder="Nhập Mã Khôi Phục (Token)" required>
                    </div>
                    <div class="form-group" style="margin-bottom:0.8rem;">
                        <input type="password" name="newPassword" placeholder="Mật khẩu mới (ít nhất 6 ký tự)" required>
                    </div>
                    <div class="form-group" style="margin-bottom:1rem;">
                        <input type="password" name="confirmPassword" placeholder="Xác nhận mật khẩu mới" required>
                    </div>
                    <button type="submit" class="btn btn-primary" style="width:100%;"><i class="fa-solid fa-key"></i> Đặt Lại Mật Khẩu</button>
                </form>
            </div>

        </div>
    </div>

    <!-- ================= ADD ADDRESS MODAL ================= -->
    <div id="addAddressModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span class="modal-title"><i class="fa-solid fa-map-pin"></i> Thêm Địa Chỉ Giao Hàng</span>
                <button class="close-btn" onclick="closeAddModal()">&times;</button>
            </div>
            <form action="profile" method="POST">
                <input type="hidden" name="action" value="addAddress">
                
                <div class="form-group" style="margin-bottom:1rem;">
                    <label for="add_recipientName">Tên người nhận</label>
                    <input type="text" id="add_recipientName" name="recipientName" required>
                </div>
                
                <div class="form-group" style="margin-bottom:1rem;">
                    <label for="add_recipientPhone">Số điện thoại</label>
                    <input type="text" id="add_recipientPhone" name="recipientPhone" required>
                </div>
                
                <div class="form-group" style="margin-bottom:1rem;">
                    <label for="add_address">Địa chỉ chi tiết</label>
                    <textarea id="add_address" name="address" rows="3" required placeholder="Số nhà, Tên đường, Phường/Xã, Quận/Huyện, Tỉnh/Thành phố"></textarea>
                </div>
                
                <div class="form-group" style="margin-bottom:1.5rem;">
                    <label for="add_note">Ghi chú giao hàng</label>
                    <input type="text" id="add_note" name="note" placeholder="Ví dụ: Giao giờ hành chính, gọi trước khi giao...">
                </div>

                <div style="display:flex; align-items:center; gap:0.5rem; margin-bottom:1.5rem;">
                    <input type="checkbox" id="add_isDefault" name="isDefault" value="1" style="width:18px; height:18px; cursor:pointer;">
                    <label for="add_isDefault" style="cursor:pointer; font-weight:600; color:#ffffff;">Đặt làm địa chỉ nhận hàng mặc định</label>
                </div>

                <div style="display:flex; justify-content:flex-end; gap:0.8rem;">
                    <button type="button" class="btn btn-secondary" onclick="closeAddModal()">Hủy bỏ</button>
                    <button type="submit" class="btn btn-primary">Lưu địa chỉ</button>
                </div>
            </form>
        </div>
    </div>

    <!-- ================= EDIT ADDRESS MODAL ================= -->
    <div id="editAddressModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span class="modal-title"><i class="fa-regular fa-pen-to-square"></i> Sửa Địa Chỉ Giao Hàng</span>
                <button class="close-btn" onclick="closeEditModal()">&times;</button>
            </div>
            <form action="profile" method="POST">
                <input type="hidden" name="action" value="editAddress">
                <input type="hidden" id="edit_id" name="id">
                
                <div class="form-group" style="margin-bottom:1rem;">
                    <label for="edit_recipientName">Tên người nhận</label>
                    <input type="text" id="edit_recipientName" name="recipientName" required>
                </div>
                
                <div class="form-group" style="margin-bottom:1rem;">
                    <label for="edit_recipientPhone">Số điện thoại</label>
                    <input type="text" id="edit_recipientPhone" name="recipientPhone" required>
                </div>
                
                <div class="form-group" style="margin-bottom:1rem;">
                    <label for="edit_address">Địa chỉ chi tiết</label>
                    <textarea id="edit_address" name="address" rows="3" required></textarea>
                </div>
                
                <div class="form-group" style="margin-bottom:1.5rem;">
                    <label for="edit_note">Ghi chú giao hàng</label>
                    <input type="text" id="edit_note" name="note">
                </div>

                <div style="display:flex; align-items:center; gap:0.5rem; margin-bottom:1.5rem;">
                    <input type="checkbox" id="edit_isDefault" name="isDefault" value="1" style="width:18px; height:18px; cursor:pointer;">
                    <label for="edit_isDefault" style="cursor:pointer; font-weight:600; color:#ffffff;">Đặt làm địa chỉ nhận hàng mặc định</label>
                </div>

                <div style="display:flex; justify-content:flex-end; gap:0.8rem;">
                    <button type="button" class="btn btn-secondary" onclick="closeEditModal()">Hủy bỏ</button>
                    <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Scripts -->
    <script>
        function switchTab(tabId, button) {
            // Hide all tab content panes
            const panes = document.querySelectorAll('.tab-pane');
            panes.forEach(pane => pane.classList.remove('active'));

            // Deactivate all tab buttons
            const buttons = document.querySelectorAll('.tab-btn');
            buttons.forEach(btn => btn.classList.remove('active'));

            // Show current active tab content pane & button
            document.getElementById(tabId).classList.add('active');
            button.classList.add('active');

            // Save tab preference to local storage
            localStorage.setItem('activeTab', tabId);
        }

        // Keep active tab on reload
        window.addEventListener('DOMContentLoaded', () => {
            const activeTab = localStorage.getItem('activeTab');
            if (activeTab && document.getElementById(activeTab)) {
                const btn = Array.from(document.querySelectorAll('.tab-btn')).find(b => b.getAttribute('onclick').includes(activeTab));
                if (btn) switchTab(activeTab, btn);
            }
        });

        // Add Modal actions
        function openAddModal() {
            document.getElementById('addAddressModal').classList.add('active');
        }
        function closeAddModal() {
            document.getElementById('addAddressModal').classList.remove('active');
        }

        // Edit Modal actions
        function openEditModal(id, name, phone, address, note, isDefault) {
            document.getElementById('edit_id').value = id;
            document.getElementById('edit_recipientName').value = name;
            document.getElementById('edit_recipientPhone').value = phone;
            document.getElementById('edit_address').value = address;
            document.getElementById('edit_note').value = note;
            document.getElementById('edit_isDefault').checked = (isDefault === 1);
            document.getElementById('editAddressModal').classList.add('active');
        }
        function closeEditModal() {
            document.getElementById('editAddressModal').classList.remove('active');
        }

        // Close modal when clicking outside content card
        window.onclick = function(event) {
            const addModal = document.getElementById('addAddressModal');
            const editModal = document.getElementById('editAddressModal');
            if (event.target === addModal) closeAddModal();
            if (event.target === editModal) closeEditModal();
        }

        // Toggle in-place profile edit
        let isProfileEditing = false;
        function toggleProfileEdit() {
            isProfileEditing = !isProfileEditing;
            const viewModes = document.querySelectorAll('#profile-info .view-mode');
            const editModes = document.querySelectorAll('#profile-info .edit-mode');
            const actions = document.getElementById('profile-edit-actions');
            const editBtn = document.getElementById('edit-profile-btn');

            if (isProfileEditing) {
                viewModes.forEach(el => el.style.display = 'none');
                editModes.forEach(el => el.style.display = 'block');
                actions.style.display = 'flex';
                editBtn.innerHTML = '<i class="fa-solid fa-xmark"></i> Hủy chỉnh sửa';
                editBtn.classList.replace('btn-primary', 'btn-secondary');
            } else {
                viewModes.forEach(el => el.style.display = 'inline-block');
                editModes.forEach(el => el.style.display = 'none');
                actions.style.display = 'none';
                editBtn.innerHTML = '<i class="fa-regular fa-pen-to-square"></i> Chỉnh sửa';
                editBtn.classList.replace('btn-secondary', 'btn-primary');
            }
        }

        function cancelProfileEdit() {
            document.getElementById('profile-form').reset();
            toggleProfileEdit();
        }
    </script>
</body>
</html>
