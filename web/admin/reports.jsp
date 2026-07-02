<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Report" %>
<%
    List<Report> reports = (List<Report>) request.getAttribute("reports");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản Lý Báo Cáo</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { background: #f0f4f1; margin: 0; padding: 2rem; font-family: 'Inter', sans-serif; }
        .layout { max-width: 1000px; margin: 0 auto; background: #fff; padding: 2rem; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
        .report-table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
        .report-table th, .report-table td { padding: 1rem; text-align: left; border-bottom: 1px solid #e2e8f0; }
        .report-table th { background: #f8fafc; color: #64748b; font-weight: 600; font-size: 0.9rem; }
        .report-table td { font-size: 0.95rem; color: #334155; }
        .btn-confirm { padding: 0.5rem 1rem; border: none; background: #22c55e; color: #fff; border-radius: 6px; cursor: pointer; font-weight: 600; text-decoration: none; display: inline-block; }
        .btn-confirm:hover { background: #16a34a; }
        .back-link { display: inline-block; margin-bottom: 1.5rem; color: #3b82f6; text-decoration: none; font-weight: 500; }
        .back-link:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="layout">
        <a href="<%= ctx %>/home.jsp" class="back-link"><i class="fa-solid fa-arrow-left"></i> Quay lại Trang Chủ</a>

        <div class="main">
            <h2 style="margin-top:0;font-family:'Inter';"><i class="fa-solid fa-flag" style="color:#ef4444;"></i> Yêu Cầu Hỗ Trợ (Báo Cáo)</h2>
            <p style="color:#64748b;">Danh sách các báo cáo từ người mua cần Admin xác nhận để tạo phòng Chat.</p>
            
            <% if (request.getParameter("msg") != null) { %>
                <div style="padding:1rem;background:#dcfce7;color:#166534;border-radius:8px;margin-bottom:1rem;">Đã xác nhận và tạo phòng Chat thành công!</div>
            <% } %>

            <table class="report-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Khách Hàng</th>
                        <th>Sản Phẩm</th>
                        <th>Lý Do</th>
                        <th>Thời Gian</th>
                        <th>Hành Động</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (reports != null && !reports.isEmpty()) {
                        for (Report r : reports) { %>
                        <tr>
                            <td>#<%= r.getId() %></td>
                            <td><%= r.getCustomerName() %></td>
                            <td><%= r.getProductName() %></td>
                            <td style="max-width:300px;word-wrap:break-word;"><%= r.getReason() %></td>
                            <td><%= r.getCreatedAt() %></td>
                            <td>
                                <form method="post" action="<%= ctx %>/report" style="margin:0;">
                                    <input type="hidden" name="action" value="confirm">
                                    <input type="hidden" name="reportId" value="<%= r.getId() %>">
                                    <button type="submit" class="btn-confirm"><i class="fa-solid fa-check"></i> Xác Nhận</button>
                                </form>
                            </td>
                        </tr>
                    <%  } } else { %>
                        <tr><td colspan="6" style="text-align:center;padding:2rem;">Chưa có báo cáo nào.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
