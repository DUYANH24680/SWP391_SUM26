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
    <title>Sena Shop - Đăng Nhập & Đăng Ký</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/variables.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/login.css">
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
                <i class="fa-regular fa-user"></i>
                <input type="text" name="fullname" placeholder="Họ và tên" required />
            </div>
            <div class="input-group">
                <i class="fa-regular fa-envelope"></i>
                <input type="email" name="email" placeholder="Email" required />
            </div>
            <div class="input-group">
                <i class="fa-solid fa-user"></i>
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
                <i class="fa-solid fa-user"></i>
                <input type="text" name="username" placeholder="Tên đăng nhập" required />
            </div>
            <div class="input-group">
                <i class="fa-solid fa-lock"></i>
                <input type="password" name="password" placeholder="Mật khẩu" required />
            </div>
            
            <a href="#">Quên mật khẩu?</a>
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