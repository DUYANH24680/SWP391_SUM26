<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    Account user = (Account) session.getAttribute("user");
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
            --red:         #dc2626;
            --red-light:   #fee2e2;
            --red-dark:    #991b1b;
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
        .btn-remove {
            background: var(--red-light);
            color: var(--red-dark);
            border: 1.5px solid #fca5a5;
        }
        .btn-remove:hover {
            background: #fecaca;
            transform: translateY(-1px);
        }
        .btn-remove:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }

        /* ======= MODAL ======= */
        .modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
            padding: 1rem;
        }
        .modal-overlay.show { display: flex; }
        .modal-box {
            background: var(--white);
            border-radius: var(--radius);
            box-shadow: var(--shadow-md, 0 8px 24px rgba(0,0,0,.12));
            padding: 1.75rem;
            max-width: 480px;
            width: 100%;
        }
        .modal-header {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 1rem;
        }
        .modal-header i { font-size: 1.5rem; color: var(--red); }
        .modal-header h3 { font-size: 1.1rem; font-weight: 700; color: var(--gray-800); }
        .modal-product-name {
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-sm);
            padding: 0.75rem 1rem;
            font-size: 0.875rem;
            color: var(--gray-800);
            margin-bottom: 1rem;
            word-break: break-word;
        }
        .modal-product-name strong { color: var(--red-dark); }
        .modal-label {
            font-size: 0.82rem;
            font-weight: 600;
            color: var(--gray-600);
            margin-bottom: 0.5rem;
            display: block;
        }
        .modal-textarea {
            width: 100%;
            padding: 0.65rem 0.9rem;
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-size: 0.875rem;
            font-family: inherit;
            color: var(--gray-800);
            resize: vertical;
            min-height: 100px;
            outline: none;
            transition: border-color 0.15s;
            margin-bottom: 0.5rem;
        }
        .modal-textarea:focus { border-color: var(--red); }
        .modal-hint {
            font-size: 0.75rem;
            color: var(--gray-400);
            margin-bottom: 1.25rem;
        }
        .modal-actions {
            display: flex;
            gap: 0.75rem;
            justify-content: flex-end;
        }
        .btn-cancel {
            background: var(--gray-100);
            color: var(--gray-600);
            padding: 0.55rem 1.25rem;
            border-radius: var(--radius-sm);
            font-size: 0.85rem;
            font-weight: 600;
            border: none;
            cursor: pointer;
            transition: background 0.15s;
        }
        .btn-cancel:hover { background: var(--gray-200); }
        .btn-confirm-remove {
            background: var(--red);
            color: white;
            padding: 0.55rem 1.25rem;
            border-radius: var(--radius-sm);
            font-size: 0.85rem;
            font-weight: 600;
            border: none;
            cursor: pointer;
            transition: background 0.15s;
        }
        .btn-confirm-remove:hover { background: var(--red-dark); }
        .modal-error {
            color: var(--red);
            font-size: 0.78rem;
            margin-top: 0.25rem;
            display: none;
        }
        .modal-error.show { display: block; }

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

    <jsp:include page="/admin/admin-topnav.jsp">
        <jsp:param name="activePage" value="approve-products" />
    </jsp:include>

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
                                    <img src="<%= request.getContextPath() %>/<%= p.getImage() %>" alt="<%= p.getTitle() %>" class="product-img"
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
                                    <input type="hidden" name="action" value="approve">
                                    <button type="submit" class="action-btn btn-approve">
                                        <i class="fa-solid fa-check"></i> Duyệt
                                    </button>
                                </form>

                                <button type="button" class="action-btn btn-remove"
                                        onclick="openRemoveModal(<%= p.getId() %>, '<%= p.getTitle().replace("'", "\\'").replace("\n", " ").replace("\r", "") %>')">
                                    <i class="fa-solid fa-trash-can"></i> Gỡ
                                </button>
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

    <!-- Remove Product Modal -->
    <div class="modal-overlay" id="removeModal" onclick="closeModalOnOverlay(event)">
        <div class="modal-box">
            <div class="modal-header">
                <i class="fa-solid fa-circle-exclamation"></i>
                <h3>Xác nhận gỡ sản phẩm vi phạm</h3>
            </div>

            <div class="modal-product-name" id="modalProductName">
                Đang tải...
            </div>

                <form id="removeForm" method="post" action="<%= request.getContextPath() %>/admin/approve-products">
                <input type="hidden" name="productId" id="modalProductId" value="">
                <input type="hidden" name="action" value="remove">

                <label class="modal-label" for="modalRemoveReason">
                    Lý do gỡ sản phẩm <span style="color:var(--red);">*</span>
                </label>
                <textarea
                    id="modalRemoveReason"
                    name="removeReason"
                    class="modal-textarea"
                    placeholder="Ví dụ: Sản phẩm hàng giả, vi phạm tiêu chuẩn hóa đơn, thông tin không chính xác..."
                    maxlength="500"
                    oninput="validateRemoveReason()"></textarea>
                <div class="modal-hint" style="display:flex;justify-content:space-between;">
                    <span>Tối thiểu 10 ký tự. Tối đa 500 ký tự.</span>
                    <span id="charCount">0/500</span>
                </div>
                <div class="modal-error" id="modalError">Vui lòng nhập lý do gỡ (ít nhất 10 ký tự).</div>

                <div class="modal-actions">
                    <button type="button" class="btn-cancel" onclick="closeRemoveModal()">Hủy</button>
                    <button type="submit" class="btn-confirm-remove" id="confirmRemoveBtn" disabled>
                        <i class="fa-solid fa-trash-can"></i> Xác nhận gỡ
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openRemoveModal(productId, productTitle) {
            document.getElementById('modalProductId').value = productId;
            document.getElementById('modalProductName').innerHTML =
                '<strong>Sản phẩm:</strong> ' + productTitle;
            document.getElementById('modalRemoveReason').value = '';
            document.getElementById('charCount').textContent = '0/500';
            document.getElementById('modalError').classList.remove('show');
            document.getElementById('confirmRemoveBtn').disabled = true;
            document.getElementById('removeModal').classList.add('show');
            setTimeout(function() {
                document.getElementById('modalRemoveReason').focus();
            }, 100);
        }

        function closeRemoveModal() {
            document.getElementById('removeModal').classList.remove('show');
        }

        function closeModalOnOverlay(event) {
            if (event.target === event.currentTarget) {
                closeRemoveModal();
            }
        }

        function validateRemoveReason() {
            var reason = document.getElementById('modalRemoveReason').value.trim();
            var charCount = reason.length;
            var isValid = charCount >= 10;
            document.getElementById('charCount').textContent = charCount + '/500';
            document.getElementById('confirmRemoveBtn').disabled = !isValid;
            if (isValid) {
                document.getElementById('modalError').classList.remove('show');
            }
        }

        document.getElementById('removeForm').addEventListener('submit', function(e) {
            var reason = document.getElementById('modalRemoveReason').value.trim();
            if (reason.length < 10) {
                e.preventDefault();
                document.getElementById('modalError').classList.add('show');
                document.getElementById('modalRemoveReason').focus();
            }
        });

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') closeRemoveModal();
        });
    </script>
</body>
</html>
