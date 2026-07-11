<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="model.Account" %>
<%@ page import="model.ShopRequest" %>
<%
    Account user = (Account) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String role = user.getRoleName();
    if ("seller".equals(role) || "admin".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/home.jsp");
        return;
    }

    ShopRequest existing = (ShopRequest) request.getAttribute("existingRequest");
    String error = (String) request.getAttribute("error");
    String success = (String) session.getAttribute("registerSellerSuccess");
    session.removeAttribute("registerSellerSuccess");

    String valShopName    = request.getAttribute("val_shopName")    != null ? (String) request.getAttribute("val_shopName")    : "";
    String valDescription = request.getAttribute("val_description") != null ? (String) request.getAttribute("val_description") : "";
    String valAddress     = request.getAttribute("val_address")      != null ? (String) request.getAttribute("val_address")      : "";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Ký Cửa Hàng | Sena Shop</title>
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
            --danger:     #dc2626;
            --danger-bg:  #fee2e2;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg);
            color: var(--gray-800);
            min-height: 100vh;
        }

        /* ===== TOPNAV ===== */
        .topnav {
            background: var(--white);
            border-bottom: 1px solid var(--gray-200);
            height: 60px;
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
        .nav-links {
            display: flex;
            gap: 0.5rem;
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
        .nav-back {
            margin-left: auto;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.875rem;
            color: var(--gray-600);
            text-decoration: none;
        }
        .nav-back:hover { color: var(--green); }

        /* ===== LAYOUT ===== */
        .page-wrap {
            max-width: 700px;
            margin: 2.5rem auto;
            padding: 0 1.5rem;
        }

        /* ===== ALERTS ===== */
        .alert {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.9rem 1.2rem;
            border-radius: var(--radius-sm);
            font-size: 0.875rem;
            font-weight: 500;
            margin-bottom: 1.25rem;
        }
        .alert-danger  { background: var(--danger-bg); border: 1px solid #fecaca; color: var(--danger); }
        .alert-success { background: #dcfce7; border: 1px solid #bbf7d0; color: #15803d; }
        .alert-info    { background: #eff6ff; border: 1px solid #bfdbfe; color: #1d4ed8; }

        /* ===== CARD ===== */
        .card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
        }
        .card-header {
            background: linear-gradient(135deg, var(--green-dark), var(--green));
            padding: 1.75rem 2rem;
            color: var(--white);
        }
        .card-header h1 {
            font-size: 1.4rem;
            font-weight: 800;
            display: flex;
            align-items: center;
            gap: 0.65rem;
        }
        .card-header p {
            font-size: 0.875rem;
            opacity: 0.9;
            margin-top: 0.35rem;
        }
        .card-body { padding: 1.75rem 2rem; }

        /* ===== FORM ===== */
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
        .form-label .required { color: var(--danger); }
        .form-hint {
            font-size: 0.78rem;
            color: var(--gray-400);
            margin-top: 0.3rem;
        }
        .form-input, .form-textarea {
            width: 100%;
            padding: 0.7rem 0.9rem;
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-size: 0.9rem;
            font-family: inherit;
            color: var(--gray-800);
            transition: border-color 0.15s, box-shadow 0.15s;
            background: var(--white);
        }
        .form-input:focus, .form-textarea:focus {
            outline: none;
            border-color: var(--green);
            box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.12);
        }
        .form-textarea { resize: vertical; min-height: 120px; }

        /* ===== BUTTONS ===== */
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.7rem 1.5rem;
            border-radius: var(--radius-sm);
            font-size: 0.9rem;
            font-weight: 700;
            font-family: inherit;
            border: none;
            cursor: pointer;
            transition: all 0.15s;
            text-decoration: none;
        }
        .btn-primary {
            background: var(--green);
            color: var(--white);
            box-shadow: 0 2px 8px rgba(76, 175, 80, 0.3);
        }
        .btn-primary:hover {
            background: var(--green-dark);
            box-shadow: 0 4px 12px rgba(76, 175, 80, 0.4);
        }
        .btn-secondary {
            background: var(--gray-100);
            color: var(--gray-600);
        }
        .btn-secondary:hover { background: var(--gray-200); }
        .btn-danger { background: var(--danger-bg); color: var(--danger); }
        .btn-danger:hover { background: #fecaca; }
        .btn-group { display: flex; gap: 0.75rem; margin-top: 1.5rem; }

        /* ===== STATUS BADGE ===== */
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.3rem 0.85rem;
            border-radius: 100px;
            font-size: 0.8rem;
            font-weight: 700;
        }
        .status-pending  { background: #fef3c7; color: #92400e; }
        .status-approved { background: #dcfce7; color: #166534; }
        .status-rejected { background: var(--danger-bg); color: var(--danger); }

        /* ===== INFO ROW ===== */
        .info-box {
            background: var(--green-light);
            border: 1px solid #bbf7d0;
            border-radius: var(--radius-sm);
            padding: 1rem 1.2rem;
            font-size: 0.875rem;
            color: var(--green-dark);
            margin-bottom: 1.5rem;
        }
        .info-box i { margin-right: 0.5rem; }

        /* ===== RESPONSIVE ===== */
        @media (max-width: 600px) {
            .card-body { padding: 1.25rem 1rem; }
            .card-header { padding: 1.25rem 1rem; }
            .btn-group { flex-direction: column; }
        }
    </style>
</head>
<body>

    <!-- Topnav -->
    <nav class="topnav">
        <a href="<%= request.getContextPath() %>/home.jsp" class="nav-logo">
            <i class="fa-solid fa-apple-whole"></i> Sena Shop
        </a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/home.jsp">
                <i class="fa-solid fa-house"></i> Trang Chủ
            </a>
            <a href="<%= request.getContextPath() %>/register-seller" style="color: var(--green-dark); font-weight: 600;">
                <i class="fa-solid fa-store"></i> Đăng Ký Cửa Hàng
            </a>
        </div>
        <a href="<%= request.getContextPath() %>/home.jsp" class="nav-back">
            <i class="fa-solid fa-arrow-left"></i> Quay lại
        </a>
    </nav>

    <div class="page-wrap">

        <% if (success != null) { %>
            <div class="alert alert-success">
                <i class="fa-solid fa-circle-check"></i>
                <%= success %>
            </div>
        <% } %>

        <% if (error != null) { %>
            <div class="alert alert-danger">
                <i class="fa-solid fa-circle-exclamation"></i>
                <%= error %>
            </div>
        <% } %>

        <!-- If already has a request, show status instead of form -->
        <% if (existing != null) { %>
            <div class="card">
                <div class="card-header">
                    <h1><i class="fa-solid fa-clipboard-list"></i> Yêu Cầu Đăng Ký Cửa Hàng</h1>
                    <p>Thông tin yêu cầu đăng ký của bạn</p>
                </div>
                <div class="card-body">
                    <div class="info-box">
                        <i class="fa-solid fa-circle-info"></i>
                        Bạn đã gửi yêu cầu đăng ký cửa hàng. Vui lòng chờ Admin duyệt.
                    </div>

                    <div class="form-group">
                        <label class="form-label">Trạng thái</label>
                        <% if (existing.isPending()) { %>
                            <span class="status-badge status-pending">
                                <i class="fa-solid fa-clock"></i> <%= existing.getStatusLabel() %>
                            </span>
                        <% } else if (existing.isApproved()) { %>
                            <span class="status-badge status-approved">
                                <i class="fa-solid fa-check-circle"></i> <%= existing.getStatusLabel() %>
                            </span>
                        <% } else { %>
                            <span class="status-badge status-rejected">
                                <i class="fa-solid fa-xmark-circle"></i> <%= existing.getStatusLabel() %>
                            </span>
                        <% } %>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Tên cửa hàng</label>
                        <div style="font-weight: 600; color: var(--gray-800);"><%= existing.getShopName() %></div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Địa chỉ</label>
                        <div><%= existing.getAddress() != null ? existing.getAddress() : "—" %></div>
                    </div>

                    <% if (existing.getDescription() != null && !existing.getDescription().isEmpty()) { %>
                    <div class="form-group">
                        <label class="form-label">Mô tả</label>
                        <div><%= existing.getDescription() %></div>
                    </div>
                    <% } %>

                    <div class="btn-group">
                        <a href="<%= request.getContextPath() %>/home.jsp" class="btn btn-secondary">
                            <i class="fa-solid fa-house"></i> Về Trang Chủ
                        </a>
                    </div>
                </div>
            </div>

        <% } else { %>

            <!-- Registration Form -->
            <div class="card">
                <div class="card-header">
                    <h1><i class="fa-solid fa-store"></i> Đăng Ký Cửa Hàng</h1>
                    <p>Mở cửa hàng trái cây của riêng bạn trên Sena Shop</p>
                </div>
                <div class="card-body">
                    <div class="info-box">
                        <i class="fa-solid fa-circle-info"></i>
                        Sau khi gửi yêu cầu, Admin sẽ xem xét và phê duyệt trong thời gian sớm nhất.
                    </div>

                    <form method="post" action="<%= request.getContextPath() %>/register-seller" id="sellerForm">
                        <div class="form-group">
                            <label class="form-label">
                                Tên cửa hàng <span class="required">*</span>
                            </label>
                            <input type="text" name="shopName" class="form-input"
                                   placeholder="Ví dụ: Cửa Hàng Trái Cây Tươi Ngon"
                                   value="<%= valShopName %>"
                                   maxlength="100" required />
                            <div class="form-hint">Từ 3 đến 100 ký tự. Đây sẽ là tên hiển thị của cửa hàng.</div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">
                                Địa chỉ cửa hàng <span class="required">*</span>
                            </label>
                            <input type="text" name="address" class="form-input"
                                   placeholder="Ví dụ: 123 Đường Nguyễn Trãi, Quận 1, TP.HCM"
                                   value="<%= valAddress %>"
                                   maxlength="255" required />
                            <div class="form-hint">Địa chỉ đầy đủ để khách hàng có thể tìm đến.</div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Mô tả cửa hàng</label>
                            <textarea name="description" class="form-textarea"
                                      placeholder="Giới thiệu ngắn về cửa hàng của bạn, các loại trái cây chủ lực, điểm mạnh..."
                                      maxlength="1000"><%= valDescription %></textarea>
                            <div class="form-hint">Không bắt buộc. Tối đa 1000 ký tự.</div>
                        </div>

                        <div class="btn-group">
                            <button type="submit" class="btn btn-primary">
                                <i class="fa-solid fa-paper-plane"></i> Gửi Yêu Cầu
                            </button>
                            <a href="<%= request.getContextPath() %>/home.jsp" class="btn btn-secondary">
                                <i class="fa-solid fa-xmark"></i> Hủy
                            </a>
                        </div>
                    </form>
                </div>
            </div>

        <% } %>
    </div>

</body>
</html>
