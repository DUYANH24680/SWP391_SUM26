<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Nhập | FreshBasket Portal</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- FontAwesome for Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        :root {
            --primary: #10b981; /* Fresh Emerald */
            --primary-hover: #059669;
            --accent: #f59e0b; /* Sunny Amber */
            --background: #0b1329; /* Deep Space Blue/Black */
            --card-bg: rgba(255, 255, 255, 0.03);
            --card-border: rgba(255, 255, 255, 0.07);
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
            --error: #ef4444;
            --error-bg: rgba(239, 68, 68, 0.1);
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Outfit', sans-serif;
            transition: all 0.3s ease;
        }

        body {
            background: radial-gradient(circle at 10% 20%, rgba(16, 185, 129, 0.15) 0%, rgba(2, 6, 23, 0) 45%), 
                        radial-gradient(circle at 90% 80%, rgba(245, 158, 11, 0.1) 0%, rgba(2, 6, 23, 0) 45%),
                        #020617;
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            overflow-x: hidden;
        }

        /* Ambient glow background spheres */
        .glow-sphere-1 {
            position: absolute;
            width: 300px;
            height: 300px;
            background: var(--primary);
            filter: blur(150px);
            opacity: 0.15;
            top: 20%;
            left: 15%;
            border-radius: 50%;
            pointer-events: none;
            animation: float 8s ease-in-out infinite alternate;
        }

        .glow-sphere-2 {
            position: absolute;
            width: 250px;
            height: 250px;
            background: var(--accent);
            filter: blur(130px);
            opacity: 0.1;
            bottom: 20%;
            right: 15%;
            border-radius: 50%;
            pointer-events: none;
            animation: float 10s ease-in-out infinite alternate-reverse;
        }

        @keyframes float {
            0% { transform: translateY(0px) scale(1); }
            100% { transform: translateY(30px) scale(1.1); }
        }

        /* Card Container with Glassmorphism */
        .login-container {
            width: 100%;
            max-width: 440px;
            padding: 2.5rem;
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 24px;
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.5);
            z-index: 10;
            position: relative;
            animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1);
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Branding logo styling */
        .brand {
            text-align: center;
            margin-bottom: 2rem;
        }

        .brand-logo {
            display: inline-flex;
            justify-content: center;
            align-items: center;
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, var(--primary) 0%, var(--accent) 100%);
            border-radius: 16px;
            margin-bottom: 1rem;
            box-shadow: 0 8px 20px rgba(16, 185, 129, 0.3);
            animation: logoPulse 4s ease-in-out infinite;
        }

        @keyframes logoPulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }

        .brand-logo i {
            font-size: 1.8rem;
            color: #020617;
        }

        .brand h2 {
            font-size: 1.8rem;
            font-weight: 700;
            letter-spacing: -0.5px;
            background: linear-gradient(135deg, #ffffff 60%, var(--text-muted) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .brand p {
            color: var(--text-muted);
            font-size: 0.9rem;
            margin-top: 0.3rem;
        }

        /* Form Controls */
        .form-group {
            margin-bottom: 1.5rem;
            position: relative;
        }

        .form-label {
            display: block;
            margin-bottom: 0.5rem;
            font-size: 0.85rem;
            font-weight: 500;
            color: var(--text-muted);
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }

        .input-wrapper {
            position: relative;
        }

        .input-wrapper i {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted);
            pointer-events: none;
            font-size: 1.1rem;
        }

        .form-input {
            width: 100%;
            padding: 0.9rem 1rem 0.9rem 2.8rem;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            color: var(--text-main);
            font-size: 1rem;
            outline: none;
        }

        .form-input::placeholder {
            color: rgba(148, 163, 184, 0.4);
        }

        .form-input:focus {
            background: rgba(255, 255, 255, 0.08);
            border-color: var(--primary);
            box-shadow: 0 0 15px rgba(16, 185, 129, 0.15);
        }

        .form-input:focus + i {
            color: var(--primary);
        }

        /* Actions & Remember Me */
        .form-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.8rem;
            font-size: 0.9rem;
        }

        .remember-me {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            cursor: pointer;
            color: var(--text-muted);
            user-select: none;
        }

        .remember-me input {
            accent-color: var(--primary);
            cursor: pointer;
            width: 16px;
            height: 16px;
        }

        .forgot-pass {
            color: var(--primary);
            text-decoration: none;
            font-weight: 500;
        }

        .forgot-pass:hover {
            color: var(--primary-hover);
            text-decoration: underline;
        }

        /* Login Button */
        .btn-login {
            width: 100%;
            padding: 1rem;
            background: linear-gradient(135deg, var(--primary) 0%, #10b981d0 100%);
            border: none;
            border-radius: 12px;
            color: #020617;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            box-shadow: 0 8px 24px rgba(16, 185, 129, 0.25);
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 0.5rem;
        }

        .btn-login:hover {
            background: linear-gradient(135deg, var(--primary-hover) 0%, var(--primary) 100%);
            transform: translateY(-2px);
            box-shadow: 0 12px 28px rgba(16, 185, 129, 0.35);
        }

        .btn-login:active {
            transform: translateY(0);
        }

        /* Error Message Banner */
        .error-banner {
            background: var(--error-bg);
            border: 1px solid rgba(239, 68, 68, 0.2);
            color: #f87171;
            padding: 0.8rem 1rem;
            border-radius: 12px;
            margin-bottom: 1.5rem;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            animation: shake 0.4s ease-in-out;
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-6px); }
            75% { transform: translateX(6px); }
        }

        .error-banner i {
            font-size: 1.1rem;
            color: var(--error);
        }

        /* Register Footer */
        .register-footer {
            text-align: center;
            margin-top: 2rem;
            font-size: 0.9rem;
            color: var(--text-muted);
        }

        .register-footer a {
            color: var(--accent);
            text-decoration: none;
            font-weight: 600;
        }

        .register-footer a:hover {
            text-decoration: underline;
        }

        /* Quick Login Section */
        .quick-login-section {
            margin-top: 1.8rem;
            padding-top: 1.5rem;
            border-top: 1px solid var(--card-border);
            text-align: center;
        }

        .quick-login-title {
            font-size: 0.8rem;
            font-weight: 600;
            color: var(--text-muted);
            letter-spacing: 0.5px;
            text-transform: uppercase;
            margin-bottom: 0.8rem;
        }

        .quick-login-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 0.6rem;
        }

        .btn-quick {
            padding: 0.6rem 0.4rem;
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 10px;
            color: var(--text-muted);
            font-size: 0.8rem;
            font-weight: 500;
            cursor: pointer;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 0.4rem;
        }

        .btn-quick:hover {
            background: rgba(16, 185, 129, 0.1);
            border-color: var(--primary);
            color: var(--primary);
            transform: translateY(-2px);
        }

        .btn-quick i {
            font-size: 1.1rem;
        }

        @keyframes pulseGlow {
            0% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.4); }
            70% { box-shadow: 0 0 0 10px rgba(16, 185, 129, 0); }
            100% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
        }

        .pulse-glow {
            animation: pulseGlow 0.5s ease-out;
        }
    </style>
</head>
<body>
    <div class="glow-sphere-1"></div>
    <div class="glow-sphere-2"></div>

    <div class="login-container">
        <!-- Brand Logo & Header -->
        <div class="brand">
            <div class="brand-logo">
                <i class="fa-solid fa-basket-shopping"></i>
            </div>
            <h2>FreshBasket</h2>
            <p>Hệ thống Quản lý Cửa hàng Trái cây</p>
        </div>

        <!-- Error Handling -->
        <%
            String error = (String) request.getAttribute("error");
            if (error != null) {
        %>
            <div class="error-banner">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <span><%= error %></span>
            </div>
        <%
            }
        %>

        <!-- Login Form -->
        <form action="<%= request.getContextPath() %>/login" method="POST">
            <!-- Username / Email Field -->
            <div class="form-group">
                <label for="username" class="form-label">Tên đăng nhập hoặc Email</label>
                <div class="input-wrapper">
                    <input type="text" id="username" name="username" class="form-input" placeholder="Nhập username hoặc email..." value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>" required autocomplete="username">
                    <i class="fa-regular fa-user"></i>
                </div>
            </div>

            <!-- Password Field -->
            <div class="form-group">
                <label for="password" class="form-label">Mật khẩu</label>
                <div class="input-wrapper">
                    <input type="password" id="password" name="password" class="form-input" placeholder="••••••••" required autocomplete="current-password">
                    <i class="fa-solid fa-lock"></i>
                </div>
            </div>

            <!-- Remember Me & Forgot Password -->
            <div class="form-actions">
                <label class="remember-me">
                    <input type="checkbox" name="remember">
                    <span>Ghi nhớ tôi</span>
                </label>
                <a href="#" class="forgot-pass">Quên mật khẩu?</a>
            </div>

            <!-- Submit Button -->
            <button type="submit" class="btn-login">
                <span>Đăng Nhập</span>
                <i class="fa-solid fa-arrow-right-to-bracket"></i>
            </button>
        </form>

        <!-- Quick Login / Demo Accounts -->
        <div class="quick-login-section">
            <div class="quick-login-title">Đăng Nhập Nhanh</div>
            <div class="quick-login-grid">
                <button type="button" class="btn-quick" onclick="fillLogin('customer', '1')">
                    <i class="fa-solid fa-user"></i>
                    <span>Khách Hàng</span>
                </button>
                <button type="button" class="btn-quick" onclick="fillLogin('seller', '1')">
                    <i class="fa-solid fa-store"></i>
                    <span>Cửa Hàng</span>
                </button>
                <button type="button" class="btn-quick" onclick="fillLogin('admin', '1')">
                    <i class="fa-solid fa-user-shield"></i>
                    <span>Admin</span>
                </button>
            </div>
        </div>

        <!-- Register Link -->
        <div class="register-footer">
            Chưa có tài khoản? <a href="#">Đăng ký ngay</a>
        </div>
    </div>

    <script>
        function fillLogin(username, password) {
            const userField = document.getElementById('username');
            const passField = document.getElementById('password');
            
            userField.value = username;
            passField.value = password;
            
            // Add pulse glow animation to the input fields for visual feedback
            userField.classList.add('pulse-glow');
            passField.classList.add('pulse-glow');
            
            setTimeout(() => {
                userField.classList.remove('pulse-glow');
                passField.classList.remove('pulse-glow');
            }, 500);
        }
    </script>
</body>
</html>
