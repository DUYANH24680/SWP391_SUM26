<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.DeliveryAddress" %>
<%@ page import="java.util.List" %>
<%
    // DuyAnhNgo- LOGIC 1: Lấy thông tin user đăng nhập. Nếu chưa đăng nhập thì tự động đẩy về trang Login
    Account user = (Account) session.getAttribute("Account");
    String role   = (String) session.getAttribute("role");

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    // DuyAnhNgo- LOGIC 2: Dịch mã Role (Vai trò) từ tiếng Anh sang tiếng Việt để hiển thị ra màn hình cho đẹp
    String roleDisplay = "Member";
    if ("admin".equalsIgnoreCase(role))         roleDisplay = "Quản Trị Viên";
    else if ("seller".equalsIgnoreCase(role))   roleDisplay = "Nhân Viên Bán Hàng";
    else if ("delivery".equalsIgnoreCase(role)) roleDisplay = "Nhân Viên Giao Hàng";

    // DuyAnhNgo- LOGIC 3: Lấy ảnh đại diện. Nếu khách chưa có ảnh thì gọi API của "ui-avatars" để tự động tạo ra cái ảnh có chứa Chữ cái đầu tiên của tên khách (Ví dụ: tên Duy thì avatar có chữ D)
    String fullname    = user.getFullname();
    String avatarUrl   = user.getAvatar();
    if (avatarUrl == null || avatarUrl.trim().isEmpty())
        avatarUrl = "https://ui-avatars.com/api/?name="
                  + java.net.URLEncoder.encode(fullname, "UTF-8")
                  + "&background=4caf50&color=fff&size=160&bold=true&rounded=true";

    // DuyAnhNgo- LOGIC 4: Cơ chế "Flash Message" (Thông báo chỉ hiện 1 lần). Lấy thông báo lỗi/thành công từ Session ra để in, sau đó XÓA NGAY (removeAttribute) để lỡ khách có F5 load lại trang thì thông báo không bị dính lại màn hình.
    String message = (String) session.getAttribute("message");
    String error   = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sổ Địa Chỉ | Sena Shop</title>
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
            --shadow-md:   0 8px 24px rgba(0,0,0,.10);
            --radius:      14px;
            --radius-sm:   8px;
        }

        html, body {
            min-height: 100vh;
            font-family: 'Inter', sans-serif;
            color: var(--gray-800);
            background: var(--bg);
            display: flex;
            flex-direction: column;
        }

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
            display: flex; align-items: center; gap: 0.5rem;
            font-size: 1.3rem; font-weight: 800; color: var(--green-dark); text-decoration: none;
        }
        .nav-logo i { color: var(--green); }
        .nav-right {
            margin-left: auto; display: flex; align-items: center; gap: 0.75rem;
        }
        .nav-avatar {
            width: 38px; height: 38px; border-radius: 50%; object-fit: cover; border: 2px solid var(--green); cursor: pointer;
        }

        /* ======= MAIN LAYOUT ======= */
        .layout {
            display: flex;
            flex: 1;
            max-width: 1080px;
            width: 100%;
            margin: 2rem auto;
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
        .sidebar-user { padding: 1.25rem 1rem; border-bottom: 1px solid var(--gray-100); }
        .sidebar-user-row { display: flex; align-items: center; gap: 0.65rem; margin-bottom: 0.3rem; }
        .sidebar-user-avatar { width: 34px; height: 34px; border-radius: 50%; object-fit: cover; border: 2px solid var(--green); }
        .sidebar-welcome { font-size: 0.8rem; font-weight: 700; color: var(--gray-800); }
        .sidebar-role-text { font-size: 0.72rem; color: var(--gray-400); padding-left: 0.1rem; }

        .sidebar-nav { padding: 0.5rem; }
        .sidebar-nav a {
            display: flex; align-items: center; gap: 0.65rem; width: 100%; padding: 0.65rem 0.9rem;
            border-radius: var(--radius-sm); font-size: 0.875rem; font-weight: 500;
            color: var(--gray-600); border: none; background: transparent; cursor: pointer;
            text-decoration: none; transition: all 0.15s;
        }
        .sidebar-nav a:hover { background: var(--green-light); color: var(--green-dark); }
        .sidebar-nav a.active { background: var(--green); color: #fff; font-weight: 600; }

        /* ======= MAIN CONTENT ======= */
        .main { flex: 1; display: flex; flex-direction: column; gap: 1.25rem; min-width: 0; }
        .alert { display: flex; align-items: center; gap: 0.75rem; padding: 0.9rem 1.2rem; border-radius: var(--radius-sm); font-size: 0.875rem; font-weight: 500; }
        .alert-success { background: #dcfce7; border: 1px solid #bbf7d0; color: #166534; }
        .alert-danger  { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }

        .card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--gray-200); box-shadow: var(--shadow-sm); overflow: hidden; }
        .card-header { display: flex; align-items: center; justify-content: space-between; padding: 1.1rem 1.5rem; border-bottom: 1px solid var(--gray-100); }
        .card-title { display: flex; align-items: center; gap: 0.5rem; font-size: 0.95rem; font-weight: 700; color: var(--gray-800); }
        .card-title i { color: var(--green); }
        .card-body { padding: 1.25rem 1.5rem; }

        .btn {
            display: inline-flex; align-items: center; justify-content: center; gap: 0.45rem;
            padding: 0.65rem 1.3rem; border-radius: var(--radius-sm); font-size: 0.875rem; font-weight: 600;
            cursor: pointer; border: none; text-decoration: none; transition: all 0.18s ease;
        }
        .btn-green { background: var(--green); color: #fff; box-shadow: 0 2px 8px rgba(76,175,80,0.3); }
        .btn-green:hover { background: var(--green-dark); transform: translateY(-1px); }
        .btn-outline { background: var(--white); color: var(--gray-600); border: 1.5px solid var(--gray-200); }
        .btn-outline:hover { background: var(--gray-50); border-color: var(--gray-400); color: var(--gray-800); }
        .btn-sm { padding: 0.5rem 1rem; font-size: 0.82rem; }

        /* ======= MODAL ======= */
        .modal-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.3); backdrop-filter: blur(4px); z-index: 200; align-items: center; justify-content: center; }
        .modal-overlay.open { display: flex; animation: fadeBg 0.2s ease; }
        @keyframes fadeBg { from { opacity: 0; } to { opacity: 1; } }
        .modal-box { background: var(--white); border-radius: var(--radius); padding: 2rem; width: 90%; max-width: 480px; box-shadow: var(--shadow-md); animation: slideUp 0.25s cubic-bezier(0.34,1.56,0.64,1); }
        @keyframes slideUp { from { opacity: 0; transform: translateY(20px) scale(0.97); } to { opacity: 1; transform: translateY(0) scale(1); } }
        .modal-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 1.5rem; }
        .modal-title { font-size: 1.05rem; font-weight: 700; color: var(--gray-800); display: flex; align-items: center; gap: 0.5rem; }
        .modal-title i { color: var(--green); }
        .modal-close { width: 30px; height: 30px; border-radius: 50%; border: none; background: var(--gray-100); color: var(--gray-600); cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 0.85rem; }
        .modal-close:hover { background: #fee2e2; color: #ef4444; }

        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0.85rem; }
        .form-group { display: flex; flex-direction: column; gap: 0.35rem; }
        .form-group.full { grid-column: span 2; }
        .form-label { font-size: 0.78rem; font-weight: 600; color: var(--gray-600); }
        .form-control { background: var(--gray-50); border: 1.5px solid var(--gray-200); border-radius: var(--radius-sm); padding: 0.7rem 0.9rem; font-size: 0.875rem; font-family: inherit; width: 100%; outline:none; }
        .form-control:focus { border-color: var(--green); background: var(--white); }
        .form-actions { display: flex; justify-content: flex-end; gap: 0.65rem; margin-top: 1.25rem; padding-top: 1.25rem; border-top: 1px solid var(--gray-100); }

        /* ======= ADDRESS CARD (PREMIUM STYLE) ======= */
        .address-card {
            background: var(--white);
            border: 1px solid var(--gray-200);
            border-radius: 16px;
            padding: 1.5rem;
            margin-bottom: 1.25rem;
            position: relative;
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .address-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 24px rgba(0,0,0,0.06);
            border-color: var(--gray-300);
        }
        .address-card.default-address {
            border: 1.5px solid var(--green);
            background: #fafdfa;
            box-shadow: 0 8px 20px rgba(76, 175, 80, 0.08);
        }
        .address-card.default-address:hover {
            box-shadow: 0 12px 28px rgba(76, 175, 80, 0.12);
        }
        
        .address-content {
            flex: 1;
            padding-right: 2rem;
            position: relative;
        }
        .address-name-row {
            font-weight: 700;
            font-size: 1.15rem;
            color: var(--gray-800);
            margin-bottom: 0.6rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            letter-spacing: -0.01em;
        }
        .name-text {
            color: var(--gray-800);
        }
        .address-phone {
            color: var(--gray-500);
            font-weight: 500;
            font-size: 0.9rem;
            background: var(--gray-50);
            padding: 0.25rem 0.6rem;
            border-radius: 6px;
            border: 1px solid var(--gray-100);
        }
        .address-badge {
            background: #e8f5e9;
            color: var(--green-dark);
            border: 1px solid #c8e6c9;
            font-size: 0.7rem;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-weight: 700;
            letter-spacing: 0.02em;
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
        }
        .address-detail {
            color: var(--gray-600);
            font-size: 0.95rem;
            line-height: 1.5;
            display: flex;
            align-items: flex-start;
            gap: 0.6rem;
            margin-bottom: 0.5rem;
        }
        .address-detail i {
            color: var(--green);
            margin-top: 0.25rem;
            opacity: 0.8;
        }
        .address-note {
            color: var(--gray-500);
            font-size: 0.85rem;
            background: var(--gray-50);
            padding: 0.5rem 0.75rem;
            border-radius: 8px;
            display: inline-block;
            margin-top: 0.25rem;
            border: 1px dashed var(--gray-200);
        }
        
        .address-actions {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 0.75rem;
            min-width: 130px;
        }
        .address-actions-top {
            display: flex;
            align-items: center;
            gap: 0.6rem;
        }
        .btn-icon {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            border: 1px solid var(--gray-200);
            background: var(--white);
            color: var(--gray-600);
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .btn-icon.edit:hover { background: #f0f9ff; border-color: #bae6fd; color: #0284c7; }
        .btn-icon.delete:hover { background: #fef2f2; border-color: #fecaca; color: #dc2626; }
        
        .btn-set-default {
            border: 1px solid var(--gray-300);
            background: transparent;
            color: var(--gray-700);
            padding: 0.4rem 0.85rem;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.8rem;
            transition: all 0.2s;
            width: 100%;
            text-align: center;
        }
        .btn-set-default:hover {
            background: var(--gray-50);
            border-color: var(--gray-400);
            color: var(--gray-800);
        }
    </style>
</head>
<body>

<jsp:include page="/sidebar.jsp">
    <jsp:param name="activePage" value="address"/>
</jsp:include>

    <!-- MAIN -->
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

        <div class="card">
            <div class="card-header">
                <div class="card-title">
                    <i class="fa-solid fa-map-location-dot"></i> Quản Lý Sổ Địa Chỉ
                </div>
                <button class="btn btn-green btn-sm" onclick="openAddressModal()">
                    <i class="fa-solid fa-plus"></i> Thêm Địa Chỉ Mới
                </button>
            </div>
            <div class="card-body">
                <%
                    List<DeliveryAddress> addresses = (List<DeliveryAddress>) request.getAttribute("addresses");
                    if (addresses == null || addresses.isEmpty()) {
                %>
                    <div style="text-align:center; padding:2rem 0; color:var(--gray-400);">
                        <i class="fa-regular fa-map" style="font-size:3rem; margin-bottom:1rem;"></i>
                        <p>Bạn chưa thêm địa chỉ nào.</p>
                    </div>
                <%
                    } else {
                        // DuyAnhNgo- Logic lặp danh sách địa chỉ: Hiển thị từng ô địa chỉ lấy từ Database
                        for (DeliveryAddress da : addresses) {
                %>
                    <div class="address-card <%= da.isIsDefault() ? "default-address" : "" %>">
                        <div class="address-content">
                            <div class="address-name-row">
                                <span class="name-text"><%= da.getRecipientName() %></span>
                                <span class="address-phone"><i class="fa-solid fa-phone" style="font-size:0.8em; margin-right:4px;"></i> <%= da.getRecipientPhone() %></span>
                                <% if (da.isIsDefault()) { %>
                                    <span class="address-badge"><i class="fa-solid fa-circle-check"></i> MẶC ĐỊNH</span>
                                <% } %>
                            </div>
                            <div class="address-detail">
                                <i class="fa-solid fa-location-dot"></i>
                                <span><%= da.getAddress() %></span>
                            </div>
                            <% if (da.getNote() != null && !da.getNote().isEmpty()) { %>
                                <div class="address-note"><i class="fa-regular fa-clipboard"></i> <%= da.getNote() %></div>
                            <% } %>
                        </div>
                        <div class="address-actions">
                            <div class="address-actions-top">
                                <button type="button" class="btn-icon edit" title="Chỉnh sửa" onclick="openAddressEdit(<%= da.getId() %>, '<%= da.getRecipientName().replace("'", "\\'") %>', '<%= da.getRecipientPhone() %>', '<%= da.getAddress().replace("'", "\\'") %>', '<%= da.getNote() != null ? da.getNote().replace("'", "\\'") : "" %>', <%= da.isIsDefault() %>)">
                                    <i class="fa-solid fa-pen"></i>
                                </button>
                                <%
                                // DuyAnhNgo- Nút Xóa Địa Chỉ: Gọi POST request lên AddressServlet với action=deleteAddress
                                %>
                                <form action="address" method="POST" style="margin:0;" onsubmit="return confirm('Bạn có chắc muốn xóa địa chỉ này?');">
                                    <input type="hidden" name="action" value="deleteAddress">
                                    <input type="hidden" name="id" value="<%= da.getId() %>">
                                    <button type="submit" class="btn-icon delete" title="Xóa">
                                        <i class="fa-solid fa-trash-can"></i>
                                    </button>
                                </form>
                            </div>
                            <% if (!da.isIsDefault()) { 
                                // DuyAnhNgo- Nút Đặt Mặc Định: Gọi POST request với action=setDefaultAddress
                            %>
                            <form action="address" method="POST" style="margin:0; width: 100%;">
                                <input type="hidden" name="action" value="setDefaultAddress">
                                <input type="hidden" name="id" value="<%= da.getId() %>">
                                <button type="submit" class="btn-set-default">Đặt mặc định</button>
                            </form>
                            <% } %>
                        </div>
                    </div>
                <%
                        }
                    }
                %>
            </div>
        </div>
    </main>
</div><!-- end sena-layout -->

<!-- Modal Thêm/Sửa Địa Chỉ -->
<div class="modal-overlay" id="addressModal">
    <div class="modal-box">
        <div class="modal-header">
            <div class="modal-title" id="addressModalTitle"><i class="fa-solid fa-map-location-dot"></i> Thêm Địa Chỉ Mới</div>
            <button class="modal-close" onclick="closeAddressModal()"><i class="fa-solid fa-xmark"></i></button>
        </div>
        <form action="address" method="POST">
            <input type="hidden" name="action" id="addressAction" value="addAddress">
            <input type="hidden" name="id" id="addressId" value="0">
            <div class="form-grid">
                <div class="form-group full">
                    <label class="form-label">Tên người nhận</label>
                    <input type="text" class="form-control" name="recipientName" id="addressName" required>
                </div>
                <div class="form-group full">
                    <label class="form-label">Số điện thoại</label>
                    <input type="text" class="form-control" name="recipientPhone" id="addressPhone" required>
                </div>
                <div class="form-group full">
                    <label class="form-label">Địa chỉ cụ thể</label>
                    <textarea class="form-control" name="address" id="addressDetail" rows="2" style="resize:vertical;" required></textarea>
                </div>
                <div class="form-group full">
                    <label class="form-label">Ghi chú (Tùy chọn)</label>
                    <input type="text" class="form-control" name="note" id="addressNote">
                </div>
                <div class="form-group full" style="flex-direction:row; align-items:center; gap:0.5rem; margin-top:0.5rem;">
                    <input type="checkbox" name="isDefault" id="addressDefault" style="width:16px; height:16px;">
                    <label for="addressDefault" style="font-size:0.85rem; font-weight:600; cursor:pointer;">Đặt làm địa chỉ mặc định</label>
                </div>
            </div>
            <div class="form-actions">
                <button type="button" class="btn btn-outline" onclick="closeAddressModal()">Hủy</button>
                <button type="submit" class="btn btn-green">Lưu Địa Chỉ</button>
            </div>
        </form>
    </div>
</div>

<script>
    // DuyAnhNgo- Mở Form Thêm Mới: Xóa trắng toàn bộ các ô nhập liệu và đổi action thành "addAddress"
    function openAddressModal() {
        document.getElementById('addressAction').value = 'addAddress';
        document.getElementById('addressId').value = '0';
        document.getElementById('addressName').value = '';
        document.getElementById('addressPhone').value = '';
        document.getElementById('addressDetail').value = '';
        document.getElementById('addressNote').value = '';
        document.getElementById('addressDefault').checked = false;
        document.getElementById('addressModalTitle').innerHTML = '<i class="fa-solid fa-map-location-dot"></i> Thêm Địa Chỉ Mới';
        
        document.getElementById('addressModal').classList.add('open');
        document.body.style.overflow = 'hidden';
    }

    // DuyAnhNgo- Mở Form Chỉnh Sửa: Đổ dữ liệu cũ của địa chỉ vào các ô nhập liệu để người dùng sửa, đổi action thành "updateAddress"
    function openAddressEdit(id, name, phone, address, note, isDefault) {
        document.getElementById('addressAction').value = 'updateAddress';
        document.getElementById('addressId').value = id;
        document.getElementById('addressName').value = name;
        document.getElementById('addressPhone').value = phone;
        document.getElementById('addressDetail').value = address;
        document.getElementById('addressNote').value = note;
        document.getElementById('addressDefault').checked = isDefault;
        document.getElementById('addressModalTitle').innerHTML = '<i class="fa-solid fa-pen"></i> Chỉnh Sửa Địa Chỉ';
        
        document.getElementById('addressModal').classList.add('open');
        document.body.style.overflow = 'hidden';
    }

    function closeAddressModal() {
        document.getElementById('addressModal').classList.remove('open');
        document.body.style.overflow = '';
    }

    // Close on overlay click
    document.getElementById('addressModal').addEventListener('click', function(e) {
        if (e.target === this) closeAddressModal();
    });

    // Escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeAddressModal();
    });
</script>
</body>
</html>
