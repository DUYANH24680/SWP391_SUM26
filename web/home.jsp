<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="model.Customer" %>
<%
    Customer user = (Customer) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang chủ - SenaFruit</title>
    <style>
        :root {
            --nav: #1f2937;
            --surface: #ffffff;
            --soft: #f8fafc;
            --primary: #16a34a;
            --accent: #f59e0b;
            --text: #0f172a;
            --muted: #475569;
            --border: #e2e8f0;
        }
        * {
            box-sizing: border-box;
        }
        body {
            margin: 0;
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(180deg, #f8fafc 0%, #e2f5e9 100%);
            color: var(--text);
        }
        header {
            background: var(--nav);
            color: white;
            padding: 20px 32px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 16px;
        }
        .brand {
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .brand-icon {
            width: 42px;
            height: 42px;
            border-radius: 14px;
            background: linear-gradient(135deg, #34d399, #10b981);
            display: grid;
            place-items: center;
            color: white;
            font-weight: 700;
            font-size: 1.15rem;
        }
        .brand-text h1 {
            margin: 0;
            font-size: 1.4rem;
            letter-spacing: 0.01em;
        }
        .brand-text p {
            margin: 4px 0 0;
            color: #cbd5e1;
            font-size: 0.95rem;
        }
        nav a {
            color: white;
            text-decoration: none;
            margin-left: 18px;
            font-weight: 600;
        }
        nav a:hover {
            color: var(--accent);
        }
        .container {
            max-width: 1180px;
            margin: 28px auto;
            padding: 0 24px 28px;
        }
        .hero {
            background: linear-gradient(135deg, rgba(255,255,255,0.9), rgba(255,255,255,0.65));
            border-radius: 28px;
            padding: 36px;
            display: grid;
            grid-template-columns: 1.2fr 0.8fr;
            gap: 28px;
            align-items: center;
            box-shadow: 0 28px 54px rgba(15, 23, 42, 0.08);
        }
        .hero h2 {
            margin-top: 0;
            font-size: 2.7rem;
            line-height: 1.05;
            color: var(--text);
        }
        .hero p {
            margin: 20px 0 0;
            color: var(--muted);
            font-size: 1.05rem;
            max-width: 520px;
        }
        .hero .hero-actions {
            margin-top: 28px;
            display: flex;
            flex-wrap: wrap;
            gap: 14px;
        }
        .hero .btn-primary,
        .hero .btn-secondary {
            border: none;
            border-radius: 16px;
            padding: 14px 24px;
            font-size: 1rem;
            cursor: pointer;
        }
        .hero .btn-primary {
            background: var(--primary);
            color: white;
        }
        .hero .btn-secondary {
            background: transparent;
            color: var(--text);
            border: 1px solid var(--border);
        }
        .hero-visual {
            display: grid;
            gap: 14px;
        }
        .hero-visual div {
            border-radius: 24px;
            min-height: 140px;
            background: linear-gradient(135deg, #fafafc, #d8f5e5);
        }
        .hero-visual .big {
            min-height: 220px;
            background: linear-gradient(135deg, #34d399, #6ee7b7);
        }
        .content-grid {
            display: grid;
            gap: 24px;
            margin-top: 28px;
            grid-template-columns: repeat(3, minmax(0, 1fr));
        }
        .card {
            background: white;
            border-radius: 24px;
            padding: 24px;
            box-shadow: 0 16px 30px rgba(15, 23, 42, 0.06);
            border: 1px solid rgba(226, 232, 240, 0.9);
        }
        .card h3 {
            margin-top: 0;
            font-size: 1.25rem;
        }
        .card p {
            color: var(--muted);
            line-height: 1.7;
        }
        .profile-card {
            display: grid;
            gap: 16px;
        }
        .profile-card .profile-item {
            display: flex;
            justify-content: space-between;
            gap: 16px;
            color: var(--muted);
        }
        .profile-card .profile-item span {
            font-weight: 600;
            color: var(--text);
        }
        footer {
            margin-top: 32px;
            text-align: center;
            color: #94a3b8;
            font-size: 0.95rem;
        }
        @media (max-width: 900px) {
            .hero { grid-template-columns: 1fr; }
            nav { width: 100%; display: flex; justify-content: center; flex-wrap: wrap; gap: 12px; }
            .content-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <header>
        <div class="brand">
            <div class="brand-icon">SF</div>
            <div class="brand-text">
                <h1>SenaFruit</h1>
                <p>Shop hoa quả tươi ngon, giao hàng nhanh</p>
            </div>
        </div>
        <nav>
            <a href="home.jsp">Trang chủ</a>
            <a href="#products">Sản phẩm</a>
            <a href="logout">Đăng xuất</a>
        </nav>
    </header>
    <main class="container">
        <section class="hero">
            <div>
                <h2>Chào mừng <%= user != null ? user.getFullname() : "Khách" %> đến với SenaFruit</h2>
                <p>Chúng tôi mang đến trái cây tươi ngon mỗi ngày, được chọn lọc kỹ càng và giao nhanh tận nơi. Khám phá ưu đãi đặc biệt cho khách hàng đăng nhập.</p>
                <div class="hero-actions">
                    <button type="button" class="btn-primary">Mua ngay</button>
                    <button type="button" class="btn-secondary">Xem sản phẩm</button>
                    <a href="logout" class="btn-secondary">Đăng xuất</a>
                </div>
            </div>
            <div class="hero-visual">
                <div class="big"></div>
                <div></div>
                <div></div>
            </div>
        </section>

        <section class="content-grid">
            <article class="card">
                <h3>Thông tin tài khoản</h3>
                <div class="profile-card">
                    <div class="profile-item"><span>Họ và tên</span><span><%= user != null ? user.getFullname() : "-" %></span></div>
                    <div class="profile-item"><span>Email</span><span><%= user != null ? user.getEmail() : "-" %></span></div>
                    <div class="profile-item"><span>Tên đăng nhập</span><span><%= user != null ? user.getUsername() : "-" %></span></div>
                </div>
            </article>
            <article class="card">
                <h3>Ưu điểm SenaFruit</h3>
                <p>Hoa quả tươi mỗi ngày, an toàn và chuẩn sạch. Giao hàng nhanh trong ngày và hỗ trợ khách hàng nhiệt tình 24/7.</p>
            </article>
            <article class="card">
                <h3>Sản phẩm nổi bật</h3>
                <p>Thanh long Việt, xoài cát Hòa Lộc, dưa lưới, nho không hạt và nhiều loại trái cây nhập khẩu tươi ngon cho cả gia đình.</p>
            </article>
        </section>

        <footer>
            © 2026 SenaFruit. Chúc bạn một ngày mua sắm hoa quả thật vui.
        </footer>
    </main>
</body>
</html>