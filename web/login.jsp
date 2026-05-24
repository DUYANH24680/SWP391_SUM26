<%@ page contentType="text/html;charset=UTF-8" %>
<%
    if (session.getAttribute("user") != null) {
        response.sendRedirect("home.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - SenaFruit</title>
    <style>
        :root {
            --primary: #2f855a;
            --secondary: #f6ad55;
            --accent: #ecc94b;
            --bg: #f7fafc;
            --card: #ffffff;
            --text: #1a202c;
            --muted: #4a5568;
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
        .login-card {
            width: min(420px, 100%);
            background: var(--card);
            border-radius: 28px;
            box-shadow: 0 24px 70px rgba(46, 64, 83, 0.12);
            overflow: hidden;
        }
        .login-header {
            padding: 36px 30px 24px;
            background: linear-gradient(135deg, var(--primary), #48bb78);
            color: white;
            text-align: center;
        }
        .login-header h1 {
            margin: 0;
            font-size: 2.1rem;
            letter-spacing: 0.02em;
        }
        .login-header p {
            margin: 12px 0 0;
            color: rgba(255,255,255,0.88);
            font-size: 0.96rem;
        }
        .login-body {
            padding: 32px 30px 34px;
        }
        .login-body label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--muted);
            font-size: 0.95rem;
        }
        .login-body input {
            width: 100%;
            padding: 14px 16px;
            margin-bottom: 18px;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            font-size: 1rem;
            transition: border-color 0.2s ease;
        }
        .login-body input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(72, 187, 120, 0.16);
        }
        .login-body button {
            width: 100%;
            padding: 14px 16px;
            background: var(--secondary);
            border: none;
            border-radius: 14px;
            color: #1a202c;
            font-size: 1rem;
            font-weight: 700;
            cursor: pointer;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .login-body button:hover {
            transform: translateY(-1px);
            box-shadow: 0 12px 20px rgba(0,0,0,0.08);
        }
        .login-body .hint {
            margin-top: 18px;
            color: var(--muted);
            font-size: 0.93rem;
            text-align: center;
        }
        .login-body .hint a {
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
        }
        .error-message {
            margin-top: 16px;
            color: #c53030;
            text-align: center;
            font-weight: 600;
        }
        .footer-note {
            margin-top: 14px;
            text-align: center;
            color: #718096;
            font-size: 0.88rem;
        }
    </style>
</head>
<body>
    <div class="page-shell">
        <section class="login-card">
            <div class="login-header">
                <h1>SenaFruit</h1>
                <p>Đăng nhập để tiếp tục mua hoa quả tươi ngon mỗi ngày</p>
            </div>
            <div class="login-body">
                <form action="login" method="post">
                    <label for="username">Tên đăng nhập</label>
                    <input id="username" type="text" name="username" placeholder="Nhập username" required>

                    <label for="password">Mật khẩu</label>
                    <input id="password" type="password" name="password" placeholder="Nhập mật khẩu" required>

                    <button type="submit">Đăng nhập</button>
                </form>

                <p class="hint">Chưa có tài khoản? <a href="#">Liên hệ quản trị viên</a></p>
                <p class="footer-note">SenaFruit - Hoa quả sạch, an toàn và giao nhanh toàn quốc.</p>

                <% if (request.getAttribute("error") != null) { %>
                    <p class="error-message"><%= request.getAttribute("error") %></p>
                <% } %>
            </div>
        </section>
    </div>
</body>
</html>