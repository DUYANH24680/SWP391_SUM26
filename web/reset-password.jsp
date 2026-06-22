<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt Lại Mật Khẩu - SenaFruit</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .container {
            width: 100%;
            max-width: 400px;
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
        }

        .logo {
            text-align: center;
            margin-bottom: 30px;
        }

        .logo h1 {
            color: #667eea;
            font-size: 28px;
            margin-bottom: 10px;
        }

        .logo p {
            color: #999;
            font-size: 14px;
        }

        h2 {
            color: #333;
            font-size: 24px;
            margin-bottom: 20px;
            text-align: center;
        }

        .description {
            color: #666;
            font-size: 14px;
            text-align: center;
            margin-bottom: 30px;
            line-height: 1.5;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 500;
            font-size: 14px;
        }

        input[type="password"],
        input[type="text"] {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            transition: border-color 0.3s;
        }

        input[type="password"]:focus,
        input[type="text"]:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .password-strength {
            margin-top: 8px;
            font-size: 12px;
            color: #999;
        }

        .btn {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.3s, box-shadow 0.3s;
            margin-top: 10px;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }

        .btn:active {
            transform: translateY(0);
        }

        .link-section {
            text-align: center;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }

        .link-section a {
            color: #667eea;
            text-decoration: none;
            font-size: 14px;
        }

        .link-section a:hover {
            text-decoration: underline;
        }

        .alert {
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 5px;
            font-size: 14px;
        }

        .alert-error {
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
        }

        .alert-success {
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
        }

        .info-box {
            background-color: #e7f3ff;
            border-left: 4px solid #667eea;
            padding: 12px;
            margin-bottom: 20px;
            font-size: 13px;
            color: #004085;
            border-radius: 3px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">
            <h1>🍎 SenaFruit</h1>
            <p>Cửa hàng trái cây tươi</p>
        </div>

        <h2>Đặt Lại Mật Khẩu</h2>

        <%-- Error message --%>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <%-- Success message --%>
        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success">
                <%= request.getAttribute("success") %>
            </div>
        <% } %>

        <%-- Show form only if token is valid --%>
        <% if (request.getAttribute("token") != null && request.getAttribute("email") != null) { %>
            <div class="info-box">
                ✓ Link hợp lệ. Vui lòng nhập mật khẩu mới.
            </div>

            <form method="POST" action="reset-password">
                <input type="hidden" name="token" value="<%= request.getAttribute("token") %>">
                <input type="hidden" name="email" value="<%= request.getAttribute("email") %>">

                <div class="form-group">
                    <label for="password">Mật Khẩu Mới</label>
                    <input 
                        type="password" 
                        id="password" 
                        name="password" 
                        placeholder="Nhập mật khẩu mới (tối thiểu 6 ký tự)"
                        required
                    >
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Xác Nhận Mật Khẩu</label>
                    <input 
                        type="password" 
                        id="confirmPassword" 
                        name="confirmPassword" 
                        placeholder="Nhập lại mật khẩu"
                        required
                    >
                </div>

                <button type="submit" class="btn">Cập Nhật Mật Khẩu</button>
            </form>
        <% } else if (request.getAttribute("error") == null) { %>
            <div class="alert alert-error">
                Liên kết không hợp lệ hoặc đã hết hạn. Vui lòng yêu cầu đặt lại mật khẩu lại.
            </div>
        <% } %>

        <div class="link-section">
            <a href="login.jsp">Quay lại đăng nhập</a> |
            <a href="forgot-password">Quên mật khẩu?</a>
        </div>
    </div>
</body>
</html>

