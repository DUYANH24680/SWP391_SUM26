<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer" %>
<%@ page import="model.Seller" %>
<%
    Object sessionAccount = session.getAttribute("account");
    Object sessionUser = session.getAttribute("user");

    Object user = null;
    boolean isSeller = false;

    if (sessionAccount instanceof Seller) {
        user = (Seller) sessionAccount;
        isSeller = true;
    } else if (sessionUser instanceof Seller) {
        user = (Seller) sessionUser;
        isSeller = true;
    } else if (sessionUser instanceof Customer) {
        user = (Customer) sessionUser;
        isSeller = false;
    }

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String roleDisplay = "Member";
    if (isSeller) roleDisplay = "Nhan Vien Ban Hang";

    String fullname = "";
    String username = "";
    String email = "";
    String phone = "";
    String address = "";
    String genderStr = "Chua cap nhat";
    String avatarUrl = "";
    String createdAtStr = "";
    String userGender = "";

    if (user instanceof Seller) {
        Seller s = (Seller) user;
        fullname = s.getFullname() != null ? s.getFullname() : "";
        username = s.getUsername() != null ? s.getUsername() : "";
        email = s.getEmail() != null ? s.getEmail() : "";
        phone = s.getPhone() != null ? s.getPhone() : "";
        address = s.getAddress() != null ? s.getAddress() : "";
        userGender = s.getGender() != null ? (s.getGender() ? "Nam" : "Nu") : "";
        avatarUrl = s.getAvatar() != null ? s.getAvatar() : "";
        if (s.getCreatedAt() != null) {
            createdAtStr = new java.text.SimpleDateFormat("dd/MM/yyyy").format(s.getCreatedAt());
        }
    } else if (user instanceof Customer) {
        Customer c = (Customer) user;
        fullname = c.getFullname() != null ? c.getFullname() : "";
        username = c.getUsername() != null ? c.getUsername() : "";
        email = c.getEmail() != null ? c.getEmail() : "";
        phone = c.getPhone() != null ? c.getPhone() : "";
        address = c.getAddress() != null ? c.getAddress() : "";
        userGender = c.getGender() != null ? (c.getGender() ? "Nam" : "Nu") : "";
        avatarUrl = c.getAvatar() != null ? c.getAvatar() : "";
        if (c.getCreatedAt() != null) {
            createdAtStr = new java.text.SimpleDateFormat("dd/MM/yyyy").format(c.getCreatedAt());
        }
    }

    if (phone.trim().isEmpty())   phone = "Chua cap nhat";
    if (address.trim().isEmpty()) address = "Chua cap nhat";
    if (avatarUrl.trim().isEmpty()) {
        avatarUrl = "https://ui-avatars.com/api/?name="
                  + java.net.URLEncoder.encode(fullname, "UTF-8")
                  + "&background=4caf50&color=fff&size=160&bold=true&rounded=true";
    }

    String message = (String) session.getAttribute("message");
    String errorMsg = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ Sơ Cá Nhân | Sena Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/profile.css">
</head>
<body>

<!-- ====== TOPNAV ====== -->
<nav class="topnav">
    <a href="home.jsp" class="nav-logo">
        <i class="fa-solid fa-apple-whole"></i> Sena Shop
    </a>
    <div class="nav-links">
        <a href="#">Trái Cây</a>
        <a href="#">Rau Củ</a>
        <a href="#">Nhập Khẩu</a>
        <a href="#">Huu Co</a>
        <a href="#">Khuyến Mãi</a>
    </div>
    <div class="nav-right">
        <button class="nav-icon-btn" title="Gio hang"><i class="fa-solid fa-basket-shopping"></i></button>
        <img class="nav-avatar" src="<%= avatarUrl %>" alt="avatar">
    </div>
</nav>

<!-- ====== LAYOUT ====== -->
<div class="layout">

    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-user">
            <div class="sidebar-user-row">
                <img class="sidebar-user-avatar" src="<%= avatarUrl %>" alt="avatar">
                <div>
                    <div class="sidebar-welcome"><%= fullname.split(" ")[fullname.split(" ").length - 1] %></div>
                </div>
            </div>
            <div class="sidebar-role-text"><%= roleDisplay %></div>
        </div>

        <div class="sidebar-nav">
            <button class="active" id="nav-profile" onclick="showPanel('profile')">
                <i class="fa-regular fa-user"></i> Ho So
            </button>
            <button id="nav-security" onclick="showPanel('security')">
                <i class="fa-solid fa-shield-halved"></i> Bảo Mật
            </button>
            <a href="logout" style="text-decoration:none; display:flex; align-items:center; gap:0.75rem; padding:12px 16px; border-radius:12px; color:#e53e3e; font-weight:600; font-size:0.95rem; margin-bottom:8px; border:1px solid transparent; transition:all 0.2s;" onmouseover="this.style.background='#fff5f5'; this.style.borderColor='#fed7d7';" onmouseout="this.style.background='transparent'; this.style.borderColor='transparent';">
                <i class="fa-solid fa-right-from-bracket" style="width:20px;text-align:center;"></i> Đăng Xuất
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="main">

        <!-- Flash messages -->
        <% if (message != null) { %>
        <div class="alert alert-success">
            <i class="fa-solid fa-circle-check"></i>
            <span><%= message %></span>
        </div>
        <% } %>
        <% if (errorMsg != null) { %>
        <div class="alert alert-danger">
            <i class="fa-solid fa-circle-exclamation"></i>
            <span><%= errorMsg %></span>
        </div>
        <% } %>

        <!-- ====== PANEL: HO SO ====== -->
        <div id="panel-profile" style="display:flex; flex-direction:column; gap:1.25rem;">

            <!-- Hero card -->
            <div class="hero-card">
                <div class="hero-avatar-wrap">
                    <img class="hero-avatar" src="<%= avatarUrl %>" alt="Avatar">
                    <div class="hero-avatar-edit" onclick="openEdit()" title="Chinh sua anh dai dien">
                        <i class="fa-solid fa-gear"></i>
                    </div>
                </div>
                <div class="hero-info">
                    <div class="hero-badge">
                        <i class="fa-solid fa-circle-dot" style="font-size:0.5rem;"></i>
                        <%= roleDisplay.toUpperCase() %>
                    </div>
                    <h1 class="hero-name"><%= fullname %></h1>
                    <div class="hero-sub">
                        @<%= username %>
                        <% if (!createdAtStr.isEmpty()) { %>
                          &nbsp;&bull;&nbsp; Tham gia tu <%= createdAtStr %>
                        <% } %>
                    </div>
                    <div class="hero-actions">
                        <button class="btn btn-green btn-sm" onclick="openEdit()">
                            <i class="fa-solid fa-pencil"></i> Chinh Sua Ho So
                        </button>
                    </div>
                </div>
            </div>

            <!-- Personal Information card (full width, no security card here) -->
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <i class="fa-regular fa-address-card"></i> Thong Tin Ca Nhan
                    </div>
                </div>
                <div class="card-body">
                    <div class="field-grid">
                        <div class="field-box">
                            <div class="field-lbl"><i class="fa-regular fa-user"></i> Ho va Ten</div>
                            <div class="field-val"><%= fullname %></div>
                        </div>
                        <div class="field-box">
                            <div class="field-lbl"><i class="fa-solid fa-venus-mars"></i> Gioi Tinh</div>
                            <div class="field-val"><%= genderStr %></div>
                        </div>
                        <div class="field-box">
                            <div class="field-lbl"><i class="fa-regular fa-envelope"></i> Dia Chi Email</div>
                            <div class="field-val"><%= email %></div>
                        </div>
                        <div class="field-box">
                            <div class="field-lbl"><i class="fa-solid fa-phone"></i> So Dien Thoai</div>
                            <div class="field-val"><%= phone %></div>
                        </div>
                        <div class="field-box full">
                            <div class="field-lbl"><i class="fa-solid fa-location-dot"></i> Dia Chi Mac Dinh</div>
                            <div class="field-val"><i class="fa-solid fa-map-pin"></i> <%= address %></div>
                        </div>
                    </div>
                </div>
            </div>

        </div><!-- /panel-profile -->

        <!-- ====== PANEL: BAO MAT ====== -->
        <div id="panel-security" style="display:none; flex-direction:column; gap:1.25rem;">

            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <i class="fa-solid fa-shield-halved"></i> Bảo Mật Tai Khoan
                    </div>
                </div>
                <div class="card-body">
                    <p class="security-desc">
                        Giu tai khoan cua ban luon an toan bang cach cap nhat mat khau dinh ky.
                        Su dung mat khau manh voi it nhat 6 ky tu.
                    </p>
                    <form action="profile" method="POST">
                        <input type="hidden" name="action" value="changePassword">
                        <div class="form-section-lbl">Thay Đổi Mật Khẩu</div>
                        <div class="form-grid">
                            <div class="form-group full">
                                <label class="form-label">Mật khẩu hiện tại</label>
                                <input type="password" name="currentPassword" class="form-control"
                                       placeholder="Nhap mat khau hien tai" required>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Mật khẩu mới</label>
                                <input type="password" name="newPassword" class="form-control"
                                       placeholder="Mật khẩu mới" required>
                                <span class="pw-hint">Toi thieu 6 ky tu</span>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Xác nhận mật khẩu mới</label>
                                <input type="password" name="confirmPassword" class="form-control"
                                       placeholder="Nhap lai mat khau moi" required>
                            </div>
                        </div>
                        <div class="form-actions">
                            <button type="submit" class="btn btn-green">
                                <i class="fa-solid fa-shield-halved"></i> Cập Nhật Mật Khẩu
                            </button>
                        </div>
                    </form>

                    <% if (!createdAtStr.isEmpty()) { %>
                    <div class="security-join">
                        <i class="fa-regular fa-calendar"></i>
                        Tham gia Sena Shop tu ngay <strong style="margin-left:0.2rem;"><%= createdAtStr %></strong>
                    </div>
                    <% } %>
                </div>
            </div>

        </div><!-- /panel-security -->

    </main>
</div><!-- /layout -->

<!-- ====== FOOTER ====== -->
<footer class="footer">
    <a href="home.jsp" class="footer-logo"><i class="fa-solid fa-apple-whole"></i> Sena Shop</a>
    <span class="footer-copy">&copy; 2024 Sena Shop. Trái cây tươi ngon mỗi ngày.</span>
    <div class="footer-links">
        <a href="#">Privacy</a>
        <a href="#">Terms</a>
        <a href="#">Lien He</a>
    </div>
</footer>

<!-- ====== MODAL: CHINH SUA HO SO ====== -->
<div class="modal-overlay" id="editModal">
    <div class="modal-box">
        <div class="modal-header">
            <div class="modal-title"><i class="fa-regular fa-pen-to-square"></i> Chinh Sua Ho So</div>
            <button class="modal-close" onclick="closeEdit()"><i class="fa-solid fa-xmark"></i></button>
        </div>
        <form action="profile" method="POST">
            <input type="hidden" name="action" value="updateProfile">
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Ho va ten</label>
                    <input type="text" name="fullname" class="form-control" value="<%= fullname %>" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Email</label>
                    <input type="email" name="email" class="form-control" value="<%= email %>" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Số điện thoại</label>
                    <input type="text" name="phone" class="form-control"
                           value="<%= "Chưa cập nhật".equals(phone) ? "" : phone %>"
                           placeholder="Nhap so dien thoai">
                </div>
                <div class="form-group">
                    <label class="form-label">Gioi tinh</label>
                    <select name="gender" class="form-control">
                        <option value="" <%= userGender.isEmpty() ? "selected" : "" %>>Chua chon</option>
                        <option value="1" <%= "Nam".equals(userGender) ? "selected" : "" %>>Nam</option>
                        <option value="0" <%= "Nu".equals(userGender) ? "selected" : "" %>>Nu</option>
                    </select>
                </div>
                <div class="form-group full">
                    <label class="form-label">Dia chi</label>
                    <textarea name="address" class="form-control"
                              placeholder="Nhap dia chi"><%= "Chưa cập nhật".equals(address) ? "" : address %></textarea>
                </div>
                <div class="form-group full">
                    <label class="form-label">Avatar URL</label>
                    <input type="text" name="avatar" class="form-control"
                           value="<%= avatarUrl %>"
                           placeholder="https://...">
                </div>
            </div>
            <div class="form-actions">
                <button type="button" class="btn btn-outline" onclick="closeEdit()">Huy</button>
                <button type="submit" class="btn btn-green">
                    <i class="fa-solid fa-floppy-disk"></i> Lưu Thay Đổi
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    // Panel switching
    function showPanel(name) {
        var profile  = document.getElementById('panel-profile');
        var security = document.getElementById('panel-security');
        var btnP     = document.getElementById('nav-profile');
        var btnS     = document.getElementById('nav-security');

        if (name === 'profile') {
            profile.style.display  = 'flex';
            security.style.display = 'none';
            btnP.classList.add('active');
            btnS.classList.remove('active');
        } else {
            profile.style.display  = 'none';
            security.style.display = 'flex';
            btnP.classList.remove('active');
            btnS.classList.add('active');
        }
        localStorage.setItem('senaPanel', name);
    }

    // Restore last panel
    window.addEventListener('DOMContentLoaded', function() {
        var urlParams = new URLSearchParams(window.location.search);
        var tabFromUrl = urlParams.get('tab');
        var saved = tabFromUrl || localStorage.getItem('senaPanel') || 'profile';
        
        // Remove param from URL to prevent sticking on reload
        if (tabFromUrl) {
            window.history.replaceState({}, document.title, window.location.pathname);
        }
        
        showPanel(saved);
    });

    // Edit profile modal
    function openEdit() {
        document.getElementById('editModal').classList.add('open');
        document.body.style.overflow = 'hidden';
    }

    function closeEdit() {
        document.getElementById('editModal').classList.remove('open');
        document.body.style.overflow = '';
    }

    // Close on overlay click
    document.getElementById('editModal').addEventListener('click', function(e) {
        if (e.target === this) closeEdit();
    });

    // Escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeEdit();
    });
</script>
</body>
</html>
