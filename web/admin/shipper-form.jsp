<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%
    Account user = (Account) session.getAttribute("Account");
    if (user == null || !"admin".equals(user.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    Account shipper = (Account) request.getAttribute("shipper");
    boolean isEdit = (shipper != null);
    
    String formError = (String) request.getAttribute("formError");
    
    // Values for form redisplay on error
    String valFullname = request.getAttribute("val_fullname") != null ? (String) request.getAttribute("val_fullname") : (shipper != null ? shipper.getFullname() : "");
    String valUsername = request.getAttribute("val_username") != null ? (String) request.getAttribute("val_username") : (shipper != null ? shipper.getUsername() : "");
    String valEmail = request.getAttribute("val_email") != null ? (String) request.getAttribute("val_email") : (shipper != null ? shipper.getEmail() : "");
    String valPhone = request.getAttribute("val_phone") != null ? (String) request.getAttribute("val_phone") : (shipper != null ? shipper.getPhone() : "");
    String valAddress = request.getAttribute("val_address") != null ? (String) request.getAttribute("val_address") : (shipper != null ? shipper.getAddress() : "");
    String valGender = request.getAttribute("val_gender") != null ? (String) request.getAttribute("val_gender") : (shipper != null && shipper.getGender() != null ? String.valueOf(shipper.getGender()) : "");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Sửa" : "Thêm" %> Shipper | Sena Shop</title>
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
        .nav-username { font-size: 0.875rem; font-weight: 600; color: var(--gray-800); }
        .layout { max-width: 800px; margin: 1.5rem auto; padding: 0 1.5rem; }
        .card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--gray-200); box-shadow: var(--shadow-sm); padding: 2rem; }
        .page-title { font-size: 1.5rem; font-weight: 800; color: var(--gray-800); margin-bottom: 1.5rem; display: flex; align-items: center; gap: 0.5rem; }
        .page-title i { color: var(--green); }
        .form-group { margin-bottom: 1.25rem; }
        .form-label { display: block; font-size: 0.875rem; font-weight: 600; color: var(--gray-600); margin-bottom: 0.5rem; }
        .form-label .required { color: #ef4444; }
        .form-input { width: 100%; padding: 0.75rem 1rem; border: 1.5px solid var(--gray-200); border-radius: var(--radius-sm); font-size: 0.875rem; font-family: inherit; outline: none; transition: border-color 0.15s; }
        .form-input:focus { border-color: var(--green); background: var(--white); }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
        .radio-group { display: flex; gap: 1.5rem; }
        .radio-item { display: flex; align-items: center; gap: 0.5rem; cursor: pointer; }
        .radio-item input[type="radio"] { width: 18px; height: 18px; accent-color: var(--green); }
        .btn { padding: 0.75rem 1.5rem; border-radius: var(--radius-sm); font-size: 0.875rem; font-weight: 600; text-decoration: none; transition: all 0.15s; cursor: pointer; border: none; display: inline-flex; align-items: center; gap: 0.5rem; }
        .btn-primary { background: var(--green); color: white; }
        .btn-primary:hover { background: var(--green-dark); }
        .btn-secondary { background: var(--gray-200); color: var(--gray-600); }
        .btn-secondary:hover { background: var(--gray-300); }
        .form-actions { display: flex; justify-content: flex-end; gap: 1rem; margin-top: 2rem; }
        .alert-danger { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; padding: 1rem; border-radius: var(--radius-sm); margin-bottom: 1.5rem; font-weight: 500; }
    </style>
</head>
<body>
    <nav class="topnav">
        <a href="${pageContext.request.contextPath}/admin/orders" class="nav-logo">
            <i class="fas fa-shield-halved"></i> Admin Panel
        </a>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/admin/orders">Monitor Đơn Hàng</a>
            <a href="${pageContext.request.contextPath}/admin/staff">Nhân Viên</a>
            <a href="${pageContext.request.contextPath}/admin/shipper" class="active">Shipper</a>
        </div>
        <div class="nav-right">
            <span class="nav-username"><%= user.getFullname() %></span>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm" style="background: #fee2e2; color: #991b1b; text-decoration: none;">Đăng Xuất</a>
        </div>
    </nav>
    
    <div class="layout">
        <div class="card">
            <h1 class="page-title">
                <i class="fas fa-<%= isEdit ? "edit" : "motorcycle" %>"></i>
                <%= isEdit ? "Sửa" : "Thêm" %> Shipper
            </h1>
            
            <% if (formError != null) { %>
            <div class="alert-danger"><i class="fas fa-exclamation-circle"></i> <%= formError %></div>
            <% } %>
            
            <form action="${pageContext.request.contextPath}<%= isEdit ? "/admin/shipper/edit" : "/admin/shipper/add" %>" method="post">
                <% if (isEdit) { %>
                <input type="hidden" name="id" value="<%= shipper.getId() %>">
                <% } %>
                
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Họ và tên <span class="required">*</span></label>
                        <input type="text" name="fullname" class="form-input" value="<%= valFullname %>" required placeholder="Nhập họ và tên">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Số điện thoại</label>
                        <input type="text" name="phone" class="form-input" value="<%= valPhone %>" placeholder="0xxxxxxxxx">
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Email <span class="required">*</span></label>
                    <input type="email" name="email" class="form-input" value="<%= valEmail %>" required placeholder="email@example.com">
                </div>
                
                <% if (!isEdit) { %>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Tên đăng nhập <span class="required">*</span></label>
                        <input type="text" name="username" class="form-input" value="<%= valUsername %>" required placeholder="username">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Mật khẩu <span class="required">*</span></label>
                        <input type="password" name="password" class="form-input" required placeholder="Nhập mật khẩu" minlength="6">
                    </div>
                </div>
                <% } %>
                
                <div class="form-group">
                    <label class="form-label">Địa chỉ</label>
                    <input type="text" name="address" class="form-input" value="<%= valAddress %>" placeholder="Nhập địa chỉ">
                </div>
                
                <div class="form-group">
                    <label class="form-label">Giới tính</label>
                    <div class="radio-group">
                        <label class="radio-item">
                            <input type="radio" name="gender" value="true" <%= "true".equals(valGender) ? "checked" : "" %>>
                            <span>Nam</span>
                        </label>
                        <label class="radio-item">
                            <input type="radio" name="gender" value="false" <%= "false".equals(valGender) ? "checked" : "" %>>
                            <span>Nữ</span>
                        </label>
                    </div>
                </div>
                
                <div class="form-actions">
                    <a href="${pageContext.request.contextPath}/admin/shipper" class="btn btn-secondary">Hủy</a>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> <%= isEdit ? "Lưu" : "Thêm" %>
                    </button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
