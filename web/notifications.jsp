<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    String role = null;
    model.Account acc = (model.Account) session.getAttribute("Account");
    if (acc != null) {
        role = acc.getRoleName();
        request.setAttribute("role", role);
    }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tất Cả Thông Báo | Sena Shop</title>
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root {
            --green: #4caf50;
            --green-dark: #388e3c;
            --green-light: #e8f5e9;
            --bg: #f0f4f1;
            --white: #ffffff;
            --gray-100: #eef1ee;
            --gray-200: #dde5dd;
            --gray-400: #9aaa9a;
            --gray-600: #5a6a5a;
            --gray-800: #2d3d2d;
            --shadow-sm: 0 1px 3px rgba(0,0,0,.08);
            --shadow: 0 4px 12px rgba(0,0,0,.08);
            --radius: 14px;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg);
            color: var(--gray-800);
            margin: 0;
            padding: 0;
        }

        .layout {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 1rem;
            display: flex;
            gap: 2rem;
            min-height: calc(100vh - 120px);
        }

        /* Sidebar styles copied from standard layout */
        .sidebar {
            width: 250px;
            flex-shrink: 0;
            background: var(--white);
            border-radius: var(--radius);
            box-shadow: var(--shadow-sm);
            padding: 1.5rem 1rem;
            height: fit-content;
        }

        .sidebar-nav {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .sidebar-nav a {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 0.75rem 1rem;
            color: var(--gray-600);
            text-decoration: none;
            border-radius: 8px;
            font-weight: 500;
            transition: all 0.2s;
        }

        .sidebar-nav a:hover {
            background: var(--gray-100);
            color: var(--gray-800);
        }

        .sidebar-nav a.active {
            background: var(--green-light);
            color: var(--green-dark);
        }

        .sidebar-nav a.active i {
            color: var(--green);
        }
        
        .sidebar-nav a.logout {
            color: #ef4444;
        }
        
        .sidebar-nav a.logout:hover {
            background: #fef2f2;
        }

        .main {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }

        .card {
            background: var(--white);
            border-radius: var(--radius);
            box-shadow: var(--shadow-sm);
            padding: 1.5rem;
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid var(--gray-100);
        }

        .card-title {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--gray-800);
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .card-title i {
            color: var(--green);
        }

        /* Notifications List */
        .notif-list {
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .notif-item {
            display: flex;
            gap: 1rem;
            padding: 1rem;
            border-radius: 12px;
            background: var(--white);
            border: 1px solid var(--gray-100);
            transition: all 0.2s;
            text-decoration: none;
            color: inherit;
        }

        .notif-item:hover {
            border-color: var(--green);
            transform: translateY(-2px);
            box-shadow: var(--shadow-sm);
        }

        .notif-item.unread {
            background: #f8fafb;
            border-left: 4px solid var(--green);
        }

        .notif-icon-wrap {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            flex-shrink: 0;
        }

        .notif-content {
            flex: 1;
        }

        .notif-title {
            font-weight: 600;
            margin-bottom: 0.25rem;
            font-size: 1rem;
        }

        .notif-text {
            color: var(--gray-600);
            font-size: 0.9rem;
            line-height: 1.4;
            margin-bottom: 0.5rem;
        }

        .notif-time {
            font-size: 0.8rem;
            color: var(--gray-400);
            display: flex;
            align-items: center;
            gap: 0.25rem;
        }

        .empty-state {
            text-align: center;
            padding: 3rem 1rem;
            color: var(--gray-600);
        }

        .empty-state i {
            font-size: 3rem;
            color: var(--gray-200);
            margin-bottom: 1rem;
        }
    </style>
</head>
<body>

    <!-- Include Navbar -->
    <jsp:include page="/sidebar.jsp">
        <jsp:param name="activePage" value="" />
    </jsp:include>

    <main class="sena-main">
        <div class="card">
            <div class="card-header">
                <div class="card-title">
                    <i class="fa-regular fa-bell"></i> Tất Cả Thông Báo
                </div>
            </div>
            
            <div class="notif-list">
                <c:choose>
                    <c:when test="${not empty notificationsList}">
                        <c:forEach var="n" items="${notificationsList}">
                            <a href="${n.link != null ? pageContext.request.contextPath : ''}${n.link != null ? n.link : '#'}" class="notif-item ${!n.read ? 'unread' : ''}">
                                <div class="notif-icon-wrap" style="background-color: ${n.typeColor}20; color: ${n.typeColor};">
                                    <i class="${n.typeIcon}"></i>
                                </div>
                                <div class="notif-content">
                                    <div class="notif-title">${n.title}</div>
                                    <div class="notif-text">${n.content}</div>
                                    <div class="notif-time">
                                        <i class="fa-regular fa-clock"></i> ${n.timeAgo}
                                    </div>
                                </div>
                            </a>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state">
                            <i class="fa-regular fa-bell-slash"></i>
                            <h3>Không có thông báo nào</h3>
                            <p>Khi có thông báo mới, chúng sẽ xuất hiện ở đây.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
</div> <!-- Close sena-layout from sidebar.jsp -->

    <script>
        // Mark all as read when visiting this page
        fetch('<%= ctx %>/notifications?action=markAllRead', {
            method: 'POST'
        }).catch(err => console.error(err));
    </script>
</body>
</html>
