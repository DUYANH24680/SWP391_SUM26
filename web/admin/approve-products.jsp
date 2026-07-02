<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="Utils.ImageUrlUtil" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    Account user = (Account) session.getAttribute("Account");
    if (user == null || !"admin".equals(user.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<Product> pendingProducts = (List<Product>) request.getAttribute("pendingProducts");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    NumberFormat nf = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Duyệt Sản Phẩm | Sena Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --green:       #4caf50;
            --green-dark:  #388e3c;
            --green-light: #e8f5e9;
            --green-mid:   #c8e6c9;
            --bg:          #f0f4f1;
            --white:       #ffffff;
            --gray-50:     #f8fafb;
            --gray-100:    #eef1ee;
            --gray-200:    #dde5dd;
            --gray-400:    #9aaa9a;
            --gray-600:    #5a6a5a;
            --gray-800:    #2d3d2d;
            --shadow-sm:   0 1px 3px rgba(0,0,0,.08);
            --shadow:      0 4px 12px rgba(0,0,0,.08);
            --radius:      14px;
            --radius-sm:   8px;
        }

        html, body {
            min-height: 100vh;
            font-family: 'Inter', sans-serif;
            color: var(--gray-800);
            background: var(--bg);
        }

        /* ======= TOPNAV ======= */
        .topnav {
            background: var(--white);
            border-bottom: 1px solid var(--gray-200);
            height: 60px;
            display: flex;
            align-items: center;
            padding: 0 2rem;
            gap: 1.5rem;
            position: sticky;
            top: 0;
            z-index: 100;
            box-shadow: var(--shadow-sm);
        }
        .nav-logo {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 1.3rem;
            font-weight: 800;
            color: var(--green-dark);
            text-decoration: none;
            white-space: nowrap;
        }
        .nav-logo i { color: var(--green); }

        .nav-links {
            display: flex;
            gap: 0.25rem;
        }
        .nav-links a {
            padding: 0.4rem 0.85rem;
            border-radius: 6px;
            font-size: 0.875rem;
            font-weight: 500;
            color: var(--gray-600);
            text-decoration: none;
            transition: all 0.15s;
        }
        .nav-links a:hover { background: var(--green-light); color: var(--green-dark); }
        .nav-links a.active { background: var(--green-light); color: var(--green-dark); font-weight: 600; }

        .nav-right {
            margin-left: auto;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        .nav-avatar {
            width: 38px; height: 38px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--green);
        }
        .nav-username {
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--gray-800);
        }

        /* ======= LAYOUT ======= */
        .layout {
            max-width: 1280px;
            margin: 1.5rem auto;
            padding: 0 1.5rem;
        }

        /* ======= ALERTS ======= */
        .alert {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.9rem 1.2rem;
            border-radius: var(--radius-sm);
            font-size: 0.875rem;
            font-weight: 500;
            margin-bottom: 1.25rem;
        }
        .alert-success { background: #dcfce7; border: 1px solid #bbf7d0; color: #15803d; }
        .alert-danger  { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }

        /* ======= PAGE HEADER ======= */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
            gap: 1rem;
            flex-wrap: wrap;
        }
        .page-title {
            font-size: 1.5rem;
            font-weight: 800;
            color: var(--gray-800);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .page-title i { color: var(--green); }
        .stat-badge {
            background: #fef9c3;
            color: #92400e;
            padding: 0.25rem 0.75rem;
            border-radius: 100px;
            font-size: 0.8rem;
            font-weight: 700;
        }
        .stat-badge.empty { background: var(--gray-100); color: var(--gray-400); }

        /* ======= TABLE ======= */
        .card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
        }
        .table-wrap { overflow-x: auto; }
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.875rem;
        }
        thead { background: var(--gray-50); }
        th {
            padding: 0.8rem 1rem;
            text-align: left;
            font-weight: 700;
            font-size: 0.8rem;
            color: var(--gray-600);
            text-transform: uppercase;
            letter-spacing: 0.04em;
            border-bottom: 2px solid var(--gray-200);
            white-space: nowrap;
        }
        td {
            padding: 0.85rem 1rem;
            border-bottom: 1px solid var(--gray-100);
            color: var(--gray-800);
            vertical-align: middle;
        }
        tbody tr:last-child td { border-bottom: none; }
        tbody tr:hover { background: var(--gray-50); }

        .product-info {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        .product-img {
            width: 56px;
            height: 56px;
            border-radius: var(--radius-sm);
            object-fit: cover;
            border: 1.5px solid var(--gray-200);
            background: var(--green-light);
            flex-shrink: 0;
        }
        .product-img-placeholder {
            width: 56px;
            height: 56px;
            border-radius: var(--radius-sm);
            background: var(--green-light);
            border: 1.5px solid var(--green-mid);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            flex-shrink: 0;
        }
        .product-title {
            font-weight: 600;
            color: var(--gray-800);
            max-width: 220px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .product-id { font-size: 0.75rem; color: var(--gray-400); }

        .shop-name {
            font-weight: 600;
            color: var(--gray-800);
        }
        .shop-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            padding: 0.15rem 0.5rem;
            border-radius: 100px;
            font-size: 0.72rem;
            font-weight: 600;
            background: var(--green-light);
            color: var(--green-dark);
        }

        .price-cell {
            font-weight: 600;
            color: var(--gray-800);
            white-space: nowrap;
        }
        .price-original {
            font-size: 0.75rem;
            color: var(--gray-400);
            text-decoration: line-through;
        }
        .price-sale {
            color: var(--green-dark);
        }

        .stock-cell {
            font-weight: 600;
        }
        .stock-low { color: #dc2626; }
        .stock-ok  { color: var(--green-dark); }

        .date-cell { color: var(--gray-600); font-size: 0.82rem; }

        .badge {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.2rem 0.65rem;
            border-radius: 100px;
            font-size: 0.75rem;
            font-weight: 700;
        }
        .badge-pending {
            background: #fef9c3;
            color: #92400e;
        }

        /* ======= ACTION BUTTONS ======= */
        .action-btn {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            padding: 0.45rem 0.9rem;
            border-radius: var(--radius-sm);
            font-size: 0.8rem;
            font-weight: 600;
            border: none;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.15s;
            white-space: nowrap;
        }
        .btn-approve {
            background: var(--green);
            color: white;
            box-shadow: 0 2px 6px rgba(76,175,80,.3);
        }
        .btn-approve:hover {
            background: var(--green-dark);
            box-shadow: 0 4px 10px rgba(56,142,60,.35);
            transform: translateY(-1px);
        }

        /* ======= EMPTY STATE ======= */
        .empty-state {
            text-align: center;
            padding: 5rem 2rem;
            color: var(--gray-400);
        }
        .empty-state i {
            font-size: 4rem;
            color: var(--green-mid);
            margin-bottom: 1rem;
            display: block;
        }
        .empty-state h3 {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--gray-600);
            margin-bottom: 0.4rem;
        }
        .empty-state p { font-size: 0.875rem; }

        /* ======= RESPONSIVE ======= */
        @media (max-width: 768px) {
            .page-header { flex-direction: column; align-items: flex-start; }
        }
    </style>
</head>
<body>

    <!-- Topnav -->
    <nav class="topnav">
        <a href="../home.jsp" class="nav-logo">
            <i class="fa-solid fa-apple-whole"></i> Sena Shop
        </a>
        <div class="nav-links">
            <a href="../home.jsp">Trang Chủ</a>
            <a href="../danh-muc">Danh Mục</a>
            <a href="../products">Sản Phẩm</a>
            <a href="../admin/customers">Khách Hàng</a>
            <a href="#" class="active">Duyệt Sản Phẩm</a>
        </div>
        <div class="nav-right">
            <% String avatarUrl = user.getAvatar();
               if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
                   String fn = user.getFullname() != null ? user.getFullname() : user.getUsername();
                   avatarUrl = "https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(fn, "UTF-8") + "&background=4caf50&color=fff&size=80&bold=true&rounded=true";
               }
            %>
            <span class="nav-username">Admin: <%= user.getFullname() != null ? user.getFullname() : user.getUsername() %></span>
            <img class="nav-avatar" src="<%= avatarUrl %>" alt="avatar">
        </div>
    </nav>

    <!-- Layout -->
    <div class="layout">

        <!-- Alerts -->
        <% if (message != null) { %>
            <div class="alert alert-success">
                <i class="fa-solid fa-circle-check"></i> <%= message %>
            </div>
        <% } %>
        <% if (error != null) { %>
            <div class="alert alert-danger">
                <i class="fa-solid fa-circle-exclamation"></i> <%= error %>
            </div>
        <% } %>

        <!-- Page Header -->
        <div class="page-header">
            <div class="page-title">
                <i class="fa-solid fa-clipboard-check"></i>
                Duyệt Sản Phẩm Mới
                <% if (totalCount != null && totalCount > 0) { %>
                    <span class="stat-badge"><%= totalCount %> chờ duyệt</span>
                <% } else { %>
                    <span class="stat-badge empty">Không có</span>
                <% } %>
            </div>
        </div>

        <!-- Table / Empty -->
        <div class="card">
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>Ảnh</th>
                            <th>ID / Sản phẩm</th>
                            <th>Cửa hàng</th>
                            <th>Giá gốc</th>
                            <th>Giá bán</th>
                            <th>Tồn kho</th>
                            <th>Ngày tạo</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        if (pendingProducts != null && !pendingProducts.isEmpty()) {
                            for (Product p : pendingProducts) {
                    %>
                        <tr>
                            <!-- Ảnh -->
                            <td>
                                <% if (p.getImage() != null && !p.getImage().trim().isEmpty()) { %>
                                    <img src="<%= ImageUrlUtil.resolve(p.getImage(), request.getContextPath()) %>" alt="<%= p.getTitle() %>" class="product-img"
                                         onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
                                    <div class="product-img-placeholder" style="display:none;">🍎</div>
                                <% } else { %>
                                    <div class="product-img-placeholder">🍎</div>
                                <% } %>
                            </td>

                            <!-- ID / Tên sản phẩm -->
                            <td>
                                <div class="product-title" title="<%= p.getTitle() %>"><%= p.getTitle() %></div>
                                <div class="product-id">#<%= p.getId() %></div>
                            </td>

                            <!-- Cửa hàng -->
                            <td>
                                <div class="shop-name"><%= p.getShopName() != null ? p.getShopName() : "—" %></div>
                                <span class="shop-badge">
                                    <i class="fa-solid fa-store"></i> Shop
                                </span>
                            </td>

                            <!-- Giá gốc -->
                            <td class="price-cell">
                                <% if (p.getOriginalPrice() > 0) { %>
                                    <span class="price-original"><%= nf.format((long) p.getOriginalPrice()) %> đ</span>
                                <% } else { %>—<% } %>
                            </td>

                            <!-- Giá bán -->
                            <td class="price-cell">
                                <span class="price-sale"><%= nf.format((long) p.getSalePrice()) %> đ</span>
                            </td>

                            <!-- Tồn kho -->
                            <td class="price-cell">
                                <span class="stock-cell <%= p.getStockQuantity() <= 0 ? "stock-low" : "stock-ok" %>">
                                    <%= nf.format(p.getStockQuantity()) %>
                                </span>
                            </td>

                            <!-- Ngày tạo -->
                            <td class="date-cell">
                                <%= p.getCreatedAt() != null ? sdf.format(p.getCreatedAt()) : "—" %>
                            </td>

                            <!-- Trạng thái -->
                            <td>
                                <span class="badge badge-pending">
                                    <i class="fa-solid fa-clock"></i> Chờ duyệt
                                </span>
                            </td>

                            <!-- Thao tác -->
                            <td>
                                <form method="post" style="display:inline-block;"
                                      onsubmit="return confirm('Duyệt sản phẩm &quot;<%= p.getTitle() %>&quot;?\nSản phẩm sẽ hiển thị công khai.');">
                                    <input type="hidden" name="productId" value="<%= p.getId() %>">
                                    <button type="submit" class="action-btn btn-approve">
                                        <i class="fa-solid fa-check"></i> Duyệt
                                    </button>
                                </form>
                            </td>
                        </tr>
                    <%
                            }
                        }
                    %>
                    </tbody>
                </table>
            </div>

            <% if (pendingProducts == null || pendingProducts.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fa-solid fa-check-circle"></i>
                    <h3>Không có sản phẩm nào chờ duyệt</h3>
                    <p>Tất cả sản phẩm đã được duyệt hoặc chưa có sản phẩm mới.</p>
                </div>
            <% } %>
        </div>

    </div>
</body>
</html>

