<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đổi mật khẩu - SenaFruit</title>
    <style>
        :root {
            --primary: #2f855a;
            --secondary: #f6ad55;
            --accent: #ecc94b;
            --bg: #f7fafc;
            --card: #ffffff;
            --text: #1a202c;
            --muted: #4a5568;
            --border: #e2e8f0;
            --blue-border: #2563eb;
        }
        * {
            box-sizing: border-box;
        }
        body {
            margin: 0;
            min-height: 100vh;
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #e9f7ef 0%, #fafaf7 100%);
            color: var(--text);
        }
        .page-shell {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            padding: 24px;
        }
        .cp-card {
            width: min(460px, 100%);
            background: var(--card);
            border-radius: 28px;
            box-shadow: 0 24px 70px rgba(46, 64, 83, 0.12);
            overflow: hidden;
        }
        .cp-header {
            padding: 32px 30px 24px;
            background: linear-gradient(135deg, var(--primary), #48bb78);
            color: white;
            text-align: center;
        }
        .cp-header h1 {
            margin: 0;
            font-size: 1.9rem;
            letter-spacing: 0.02em;
        }
        .cp-header p {
            margin: 10px 0 0;
            color: rgba(255,255,255,0.85);
            font-size: 0.95rem;
        }
        .cp-body {
            padding: 32px 30px 34px;
        }
        .cp-body label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--muted);
            font-size: 0.95rem;
        }
        .cp-body input {
            width: 100%;
            padding: 14px 16px;
            margin-bottom: 18px;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            font-size: 1rem;
            transition: border-color 0.2s ease;
        }
        .cp-body input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(72, 187, 120, 0.16);
        }
        .cp-body .btn-submit {
            width: 100%;
            padding: 14px 16px;
            background: var(--card);
            border: 2px solid var(--blue-border);
            border-radius: 14px;
            color: var(--blue-border);
            font-size: 1rem;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.2s ease, color 0.2s ease;
        }
        .cp-body .btn-submit:hover {
            background: var(--blue-border);
            color: white;
        }
        .cp-body .back-link {
            display: block;
            margin-top: 16px;
            text-align: center;
            color: var(--muted);
            text-decoration: none;
            font-size: 0.93rem;
        }
        .cp-body .back-link:hover {
            color: var(--primary);
        }
        .alert {
            padding: 12px 16px;
            border-radius: 12px;
            margin-bottom: 18px;
            font-weight: 600;
            font-size: 0.95rem;
        }
        .alert-error {
            background: #fff5f5;
            color: #c53030;
            border: 1px solid #feb2b2;
        }
        .alert-success {
            background: #f0fff4;
            color: #276749;
            border: 1px solid #9ae6b4;
        }
    </style>
</head>
<body>
    <div class="page-shell">
        <section class="cp-card">
            <div class="cp-header">
                <h1>Đổi mật khẩu</h1>
                <p>Cập nhật mật khẩu tài khoản của bạn</p>
            </div>
            <div class="cp-body">
                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-error"><%= request.getAttribute("error") %></div>
                <% } %>
                <% if (request.getAttribute("message") != null) { %>
                    <div class="alert alert-success"><%= request.getAttribute("message") %></div>
                <% } %>

                <form action="change-password" method="post">
                    <label for="oldPassword">Mật khẩu hiện tại</label>
                    <input id="oldPassword" type="password" name="oldPassword" placeholder="Nhập mật khẩu hiện tại" required>

                    <label for="newPassword">Mật khẩu mới</label>
                    <input id="newPassword" type="password" name="newPassword" placeholder="Nhập mật khẩu mới" required>

                    <label for="confirmPassword">Xác nhận mật khẩu mới</label>
                    <input id="confirmPassword" type="password" name="confirmPassword" placeholder="Nhập lại mật khẩu mới" required>

                    <button type="submit" class="btn-submit">Đổi mật khẩu</button>
                </form>

                <a href="home.jsp" class="back-link"> Quay lại trang chủ</a>
            </div>
        </section>
    </div>
</body>
</html>
