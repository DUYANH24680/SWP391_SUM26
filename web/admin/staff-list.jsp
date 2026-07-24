<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.StaffDetails" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Account user = (Account) session.getAttribute("Account");
    if (user == null || !"admin".equals(user.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    List<Account> staffList = (List<Account>) request.getAttribute("staffList");
    Map<Integer, StaffDetails> staffDetailsMap = (Map<Integer, StaffDetails>) request.getAttribute("staffDetailsMap");
    String keyword = (String) request.getAttribute("searchKeyword");
    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Nhân Viên | SenaFruit</title>
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
        .layout { max-width: 1280px; margin: 1.5rem auto; padding: 0 1.5rem; }
        .alert { display: flex; align-items: center; gap: 0.75rem; padding: 0.9rem 1.2rem; border-radius: var(--radius-sm); font-size: 0.875rem; font-weight: 500; margin-bottom: 1.25rem; }
        .alert-success { background: #dcfce7; border: 1px solid #bbf7d0; color: #15803d; }
        .alert-danger { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; gap: 1rem; flex-wrap: wrap; }
        .page-title { font-size: 1.5rem; font-weight: 800; color: var(--gray-800); display: flex; align-items: center; gap: 0.5rem; }
        .page-title i { color: var(--green); }
        .btn { padding: 0.5rem 1rem; border-radius: var(--radius-sm); font-size: 0.875rem; font-weight: 600; text-decoration: none; transition: all 0.15s; cursor: pointer; border: none; }
        .btn-primary { background: var(--green); color: white; }
        .btn-primary:hover { background: var(--green-dark); }
        .btn-sm { padding: 0.35rem 0.75rem; font-size: 0.8rem; }
        .btn-danger { background: #ef4444; color: white; }
        .btn-danger:hover { background: #dc2626; }
        .btn-warning { background: #f59e0b; color: white; }
        .btn-warning:hover { background: #d97706; }
        .search-card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--gray-200); box-shadow: var(--shadow-sm); padding: 1.25rem 1.5rem; margin-bottom: 1.5rem; }
        .search-form { display: flex; gap: 0.75rem; }
        .search-input { flex: 1; padding: 0.6rem 1rem; border: 1.5px solid var(--gray-200); border-radius: var(--radius-sm); font-size: 0.875rem; font-family: inherit; outline: none; }
        .search-input:focus { border-color: var(--green); }
        .table-card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--gray-200); box-shadow: var(--shadow-sm); overflow: hidden; }
        .table { width: 100%; border-collapse: collapse; }
        .table th { background: var(--gray-50); padding: 0.9rem 1rem; text-align: left; font-size: 0.8rem; font-weight: 600; color: var(--gray-600); text-transform: uppercase; letter-spacing: 0.05em; border-bottom: 1px solid var(--gray-200); }
        .table td { padding: 0.9rem 1rem; font-size: 0.875rem; border-bottom: 1px solid var(--gray-100); vertical-align: middle; }
        .table tr:last-child td { border-bottom: none; }
        .table tr:hover td { background: var(--gray-50); }
        .badge { display: inline-flex; align-items: center; padding: 0.25rem 0.6rem; border-radius: 100px; font-size: 0.75rem; font-weight: 600; }
        .badge-active { background: #dcfce7; color: #15803d; }
        .badge-locked { background: #fee2e2; color: #991b1b; }
        .badge-deleted { background: #f3f4f6; color: #6b7280; }
        .actions { display: flex; gap: 0.5rem; }
        .empty-state { text-align: center; padding: 3rem; color: var(--gray-400); }
        .empty-state i { font-size: 3rem; margin-bottom: 1rem; }
    </style>
</head>
<body>
    <jsp:include page="/admin/admin-topnav.jsp">
        <jsp:param name="activePage" value="staff" />
    </jsp:include>

    
    <div class="layout">
        <% if (message != null) { %>
        <div class="alert alert-success"><i class="fas fa-check-circle"></i> <%= message %></div>
        <% } %>
        <% if (error != null) { %>
        <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> <%= error %></div>
        <% } %>
        
        <div class="page-header">
            <h1 class="page-title"><i class="fas fa-users-cog"></i> Quản Lý Nhân Viên</h1>
            <a href="${pageContext.request.contextPath}/admin/staff/add" class="btn btn-primary">
                <i class="fas fa-plus"></i> Thêm Nhân Viên
            </a>
        </div>
        
        <div class="search-card">
            <form action="${pageContext.request.contextPath}/admin/staff" method="get" class="search-form">
                <input type="text" name="search" class="search-input" placeholder="Tìm kiếm theo tên, username, email, số điện thoại..." value="<%= keyword != null ? keyword : "" %>">
                <button type="submit" class="btn btn-primary"><i class="fas fa-search"></i> Tìm</button>
                <% if (keyword != null && !keyword.isEmpty()) { %>
                <a href="${pageContext.request.contextPath}/admin/staff" class="btn btn-sm" style="background: var(--gray-200); color: var(--gray-600);">Xóa lọc</a>
                <% } %>
            </form>
        </div>
        
        <div class="table-card">
            <% if (staffList == null || staffList.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-users"></i>
                <p>Không có nhân viên nào<%= keyword != null ? " phù hợp với từ khóa tìm kiếm" : "" %></p>
            </div>
            <% } else { %>
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Họ Tên</th>
                        <th>Mã NV</th>
                        <th>CCCD</th>
                        <th>Khu Vực Quản Lý</th>
                        <th>Điện Thoại</th>
                        <th>Trạng Thái</th>
                        <th>Hành Động</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Account staff : staffList) {
                        StaffDetails details = staffDetailsMap != null ? staffDetailsMap.get(staff.getId()) : null;
                    %>
                    <tr>
                        <td>#<%= staff.getId() %></td>
                        <td>
                            <div style="font-weight: 600;"><%= staff.getFullname() %></div>
                            <div style="font-size: 0.75rem; color: var(--gray-400);"><%= staff.getUsername() %></div>
                        </td>
                        <td><%= details != null && details.getStaffCode() != null ? details.getStaffCode() : "-" %></td>
                        <td><%= details != null && details.getCccd() != null ? details.getCccd() : "-" %></td>
                        <td><%= details != null && details.getManagedArea() != null ? details.getManagedArea() : "-" %></td>
                        <td><%= staff.getPhone() != null ? staff.getPhone() : "-" %></td>
                        <td>
                            <% if (staff.getStatus() == 1) { %>
                            <span class="badge badge-active"><i class="fas fa-check"></i> Hoạt động</span>
                            <% } else if (staff.getStatus() == 0) { %>
                            <span class="badge badge-locked"><i class="fas fa-lock"></i> Đã khóa</span>
                            <% } else { %>
                            <span class="badge badge-deleted"><i class="fas fa-trash"></i> Đã xóa</span>
                            <% } %>
                        </td>
                        <td>
                            <div class="actions">
                                <a href="${pageContext.request.contextPath}/admin/staff/edit?id=<%= staff.getId() %>" class="btn btn-sm" style="background: var(--gray-200); color: var(--gray-800);">
                                    <i class="fas fa-edit"></i> Sửa
                                </a>
                                <% if (staff.getStatus() == 1) { %>
                                <form action="${pageContext.request.contextPath}/admin/staff/action" method="post" style="display:inline;">
                                    <input type="hidden" name="id" value="<%= staff.getId() %>">
                                    <input type="hidden" name="action" value="lock">
                                    <button type="submit" class="btn btn-sm btn-warning" onclick="return confirm('Khóa tài khoản này?');">
                                        <i class="fas fa-lock"></i>
                                    </button>
                                </form>
                                <% } else if (staff.getStatus() == 0) { %>
                                <form action="${pageContext.request.contextPath}/admin/staff/action" method="post" style="display:inline;">
                                    <input type="hidden" name="id" value="<%= staff.getId() %>">
                                    <input type="hidden" name="action" value="unlock">
                                    <button type="submit" class="btn btn-sm btn-primary">
                                        <i class="fas fa-unlock"></i>
                                    </button>
                                </form>
                                <% } %>
                                <% if (staff.getStatus() != -1) { %>
                                <form action="${pageContext.request.contextPath}/admin/staff/action" method="post" style="display:inline;">
                                    <input type="hidden" name="id" value="<%= staff.getId() %>">
                                    <input type="hidden" name="action" value="delete">
                                    <button type="submit" class="btn btn-sm btn-danger" onclick="return confirm('Xóa tài khoản này?');">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </form>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } %>
        </div>
    </div>
</body>
</html>
