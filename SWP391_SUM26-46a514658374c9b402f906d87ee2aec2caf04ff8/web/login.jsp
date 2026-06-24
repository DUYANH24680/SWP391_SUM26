<%@ page contentType="text/html;charset=UTF-8" %>
<%
    if (session.getAttribute("Account") != null) {
        response.sendRedirect("home.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sena Shop - Đăng Nhập & Đăng Ký</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        :root {
            --green: #4caf50;
            --green-dark: #388e3c;
            --green-light: #e8f5e9;
            --white: #ffffff;
            --gray-800: #2d3d2d;
            --gray-500: #7a8a7a;
            --gray-200: #dde5dd;
            --bg: #f0f4f1;
            --danger: #ef4444;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            background: url('https://images.unsplash.com/photo-1610832958506-aa56368176cf?q=80&w=2070&auto=format&fit=crop') no-repeat center center/cover;
            font-family: 'Inter', sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            color: var(--gray-800);
            position: relative;
        }

        /* Dark overlay for background readability */
        body::before {
            content: "";
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0, 0, 0, 0.4);
            backdrop-filter: blur(4px);
            z-index: 0;
        }

        h1 {
            font-weight: 800;
            margin: 0 0 1rem;
            color: var(--gray-800);
            font-size: 2rem;
        }

        h1.brand {
            color: var(--green);
            display: flex;
            align-items: center;
            gap: 0.5rem;
            justify-content: center;
            margin-bottom: 1.5rem;
            font-size: 2.2rem;
        }

        p {
            font-size: 0.95rem;
            font-weight: 400;
            line-height: 20px;
            letter-spacing: 0.5px;
            margin: 20px 0 30px;
            color: var(--white);
        }

        span {
            font-size: 0.85rem;
            color: var(--gray-500);
            margin-bottom: 1.5rem;
            display: inline-block;
        }

        a {
            color: var(--green-dark);
            font-size: 0.9rem;
            text-decoration: none;
            margin: 15px 0;
            font-weight: 600;
            transition: color 0.3s;
        }

        a:hover {
            color: var(--green);
        }

        button {
            border-radius: 30px;
            border: none;
            background-color: var(--green);
            color: #FFFFFF;
            font-size: 0.9rem;
            font-weight: 700;
            padding: 14px 45px;
            letter-spacing: 1px;
            text-transform: uppercase;
            transition: transform 80ms ease-in, background-color 0.3s, box-shadow 0.3s;
            cursor: pointer;
            box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3);
            margin-top: 10px;
        }

        button:hover {
            background-color: var(--green-dark);
            box-shadow: 0 6px 20px rgba(56, 142, 60, 0.4);
        }

        button:active {
            transform: scale(0.95);
        }

        button:focus {
            outline: none;
        }

        button.ghost {
            background-color: transparent;
            border: 2px solid #FFFFFF;
            box-shadow: none;
        }
        
        button.ghost:hover {
            background-color: rgba(255, 255, 255, 0.1);
        }

        form {
            background-color: #FFFFFF;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            padding: 0 50px;
            height: 100%;
            text-align: center;
        }

        .input-group {
            width: 100%;
            position: relative;
            margin-bottom: 15px;
        }

        .input-group i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--gray-500);
        }

        input {
            background-color: var(--bg);
            border: 1px solid var(--gray-200);
            border-radius: 12px;
            padding: 14px 15px 14px 45px;
            width: 100%;
            font-size: 0.95rem;
            font-family: inherit;
            transition: border-color 0.3s, background-color 0.3s;
        }

        input:focus {
            outline: none;
            border-color: var(--green);
            background-color: var(--white);
        }

        .container {
            background-color: #fff;
            border-radius: 20px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.25), 0 10px 20px rgba(0, 0, 0, 0.22);
            position: relative;
            overflow: hidden;
            width: 900px;
            max-width: 100%;
            min-height: 600px;
            z-index: 1;
        }

        .form-container {
            position: absolute;
            top: 0;
            height: 100%;
            transition: all 0.6s ease-in-out;
        }

        .sign-in-container {
            left: 0;
            width: 50%;
            z-index: 2;
        }

        .container.right-panel-active .sign-in-container {
            transform: translateX(100%);
        }

        .sign-up-container {
            left: 0;
            width: 50%;
            opacity: 0;
            z-index: 1;
        }

        .container.right-panel-active .sign-up-container {
            transform: translateX(100%);
            opacity: 1;
            z-index: 5;
            animation: show 0.6s;
        }

        @keyframes show {
            0%, 49.99% { opacity: 0; z-index: 1; }
            50%, 100% { opacity: 1; z-index: 5; }
        }

        .overlay-container {
            position: absolute;
            top: 0;
            left: 50%;
            width: 50%;
            height: 100%;
            overflow: hidden;
            transition: transform 0.6s ease-in-out;
            z-index: 100;
        }

        .container.right-panel-active .overlay-container {
            transform: translateX(-100%);
        }

        .overlay {
            background: linear-gradient(135deg, var(--green-dark), var(--green));
            background-repeat: no-repeat;
            background-size: cover;
            background-position: 0 0;
            color: #FFFFFF;
            position: relative;
            left: -100%;
            height: 100%;
            width: 200%;
            transform: translateX(0);
            transition: transform 0.6s ease-in-out;
        }

        .container.right-panel-active .overlay {
            transform: translateX(50%);
        }

        .overlay-panel {
            position: absolute;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            padding: 0 40px;
            text-align: center;
            top: 0;
            height: 100%;
            width: 50%;
            transform: translateX(0);
            transition: transform 0.6s ease-in-out;
        }

        .overlay-panel h1 {
            color: var(--white);
        }

        .overlay-left {
            transform: translateX(-20%);
        }

        .container.right-panel-active .overlay-left {
            transform: translateX(0);
        }

        .overlay-right {
            right: 0;
            transform: translateX(0);
        }

        .container.right-panel-active .overlay-right {
            transform: translateX(20%);
        }
        
        .error-msg {
            background: #fef2f2;
            color: var(--danger);
            padding: 10px 15px;
            border-radius: 8px;
            font-size: 0.9rem;
            font-weight: 500;
            width: 100%;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
            border: 1px solid #fecaca;
        }

        /* Mobile Responsive */
        @media (max-width: 768px) {
            .container {
                min-height: 700px;
            }
            .form-container {
                width: 100%;
                height: 50%;
            }
            .sign-in-container {
                top: 50%;
            }
            .sign-up-container {
                top: 0;
                opacity: 1;
                transform: translateY(0);
            }
            .overlay-container {
                display: none;
            }
            form {
                padding: 0 30px;
            }
        }
    </style>
</head>
<body>

<div class="container" id="container">
    
    <!-- Sign Up Form -->
    <div class="form-container sign-up-container">
        <form action="register" method="post">
            <h1 class="brand"><i class="fa-solid fa-apple-whole"></i> Sena Shop</h1>
            <h1>Tạo Tài Khoản</h1>
            <span>Nhập thông tin bên dưới để tham gia Sena Shop</span>
            
            <div class="input-group">
                <i class="fa-regular fa-Account"></i>
                <input type="text" name="fullname" placeholder="Họ và tên" required />
            </div>
            <div class="input-group">
                <i class="fa-regular fa-envelope"></i>
                <input type="email" name="email" placeholder="Email" required />
            </div>
            <div class="input-group">
                <i class="fa-solid fa-Account"></i>
                <input type="text" name="username" placeholder="Tên đăng nhập" required />
            </div>
            <div class="input-group">
                <i class="fa-solid fa-lock"></i>
                <input type="password" name="password" placeholder="Mật khẩu" required />
            </div>
            
            <button type="submit">Đăng Ký Ngay</button>
        </form>
    </div>

    <!-- Sign In Form -->
    <div class="form-container sign-in-container">
        <form action="login" method="post">
            <h1 class="brand"><i class="fa-solid fa-apple-whole"></i> Sena Shop</h1>
            <h1>Đăng Nhập</h1>
            <span>Sử dụng tài khoản thành viên của bạn</span>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="error-msg">
                    <i class="fa-solid fa-circle-exclamation"></i>
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>

            <div class="input-group">
                <i class="fa-solid fa-Account"></i>
                <input type="text" name="username" placeholder="Tên đăng nhập" required />
            </div>
            <div class="input-group">
                <i class="fa-solid fa-lock"></i>
                <input type="password" name="password" placeholder="Mật khẩu" required />
            </div>
            
            <a href="forgot-password">Quên mật khẩu?</a>
            <button type="submit">Đăng Nhập</button>
        </form>
    </div>

    <!-- Sliding Overlay -->
    <div class="overlay-container">
        <div class="overlay">
            <div class="overlay-panel overlay-left">
                <h1>Chào mừng trở lại!</h1>
                <p>Để tiếp tục mua sắm và theo dõi đơn hàng, vui lòng đăng nhập bằng tài khoản của bạn.</p>
                <button class="ghost" id="signIn">Đăng Nhập</button>
            </div>
            <div class="overlay-panel overlay-right">
                <h1>Chào bạn mới!</h1>
                <p>Nhập thông tin cá nhân của bạn và bắt đầu hành trình mua sắm trái cây tươi ngon cùng Sena Shop.</p>
                <button class="ghost" id="signUp">Tạo Tài Khoản</button>
            </div>
        </div>
    </div>
</div>

<script>
    const signUpButton = document.getElementById('signUp');
    const signInButton = document.getElementById('signIn');
    const container = document.getElementById('container');

    signUpButton.addEventListener('click', () => {
        container.classList.add("right-panel-active");
    });

    signInButton.addEventListener('click', () => {
        container.classList.remove("right-panel-active");
    });
</script>

</body>
</html>
