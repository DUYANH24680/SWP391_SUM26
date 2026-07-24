<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Product" %>
<%@ page import="Utils.ImageUrlUtil" %>
<%@ page import="java.util.List" %>
<%
    Object rawUser = session.getAttribute("Account");
    Object rawUserId = session.getAttribute("userId");

    Account user = (Account) rawUser;
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String role = (String) session.getAttribute("role");
    String avatarUrl = user.getAvatar();
    if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
        String fullname = user.getFullname() != null ? user.getFullname() : user.getUsername();
        avatarUrl = "https://ui-avatars.com/api/?name="
                  + java.net.URLEncoder.encode(fullname, "UTF-8")
                  + "&background=4caf50&color=fff&size=80&bold=true&rounded=true";
    }

    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");

    List<Product> products = (List<Product>) request.getAttribute("products");
    if (products == null) products = java.util.Collections.emptyList();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhập Kho | SenaFruit</title>
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

        body { display: flex; flex-direction: column; }

        /* ======= MAIN ======= */
        .main { flex: 1; display: flex; flex-direction: column; gap: 1.25rem; min-width: 0; }

        /* ======= ALERTS ======= */
        .alert {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.9rem 1.2rem;
            border-radius: var(--radius-sm);
            font-size: 0.875rem;
            font-weight: 500;
        }

        .alert-success { background: #dcfce7; border: 1px solid #bbf7d0; color: #166534; }
        .alert-danger  { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }

        /* ======= CARD ======= */
        .card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
        }

        .card-header {
            display: flex;
            align-items: center;
            gap: 0.6rem;
            padding: 1.1rem 1.5rem;
            border-bottom: 1px solid var(--gray-100);
        }

        .card-title {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--gray-800);
        }

        .card-title i { color: var(--green); }

        .card-body { padding: 1.5rem; }

        /* ======= BREADCRUMB ======= */
        .breadcrumb {
            display: flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 0.82rem;
            color: var(--gray-400);
        }

        .breadcrumb a { color: var(--green); text-decoration: none; font-weight: 500; }
        .breadcrumb a:hover { text-decoration: underline; }
        .breadcrumb span { color: var(--gray-600); font-weight: 500; }

        /* ======= SECTION LABEL ======= */
        .section-label {
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: var(--gray-400);
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.4rem;
        }

        /* ======= FORM ======= */
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }

        .form-group { display: flex; flex-direction: column; gap: 0.4rem; }
        .form-group.full { grid-column: span 2; }

        .form-label {
            font-size: 0.78rem;
            font-weight: 600;
            color: var(--gray-600);
            display: flex;
            align-items: center;
            gap: 0.3rem;
        }

        .form-label .required { color: #dc2626; font-size: 0.7rem; }

        .form-control {
            background: var(--gray-50);
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            padding: 0.7rem 0.9rem;
            font-size: 0.875rem;
            font-family: 'Inter', sans-serif;
            color: var(--gray-800);
            outline: none;
            transition: all 0.18s;
            width: 100%;
        }

        .form-control:focus {
            border-color: var(--green);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(76,175,80,0.12);
        }

        .form-control::placeholder { color: var(--gray-400); }
        textarea.form-control { resize: vertical; min-height: 100px; }
        select.form-control option { background: var(--white); }

        .form-hint {
            font-size: 0.72rem;
            color: var(--gray-400);
            margin-top: 0.2rem;
        }

        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 0.75rem;
            padding: 1.25rem 1.5rem;
            border-top: 1px solid var(--gray-100);
            background: var(--gray-50);
        }

        /* ======= BUTTONS ======= */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.45rem;
            padding: 0.7rem 1.4rem;
            border-radius: var(--radius-sm);
            font-size: 0.875rem;
            font-weight: 600;
            font-family: 'Inter', sans-serif;
            cursor: pointer;
            border: none;
            text-decoration: none;
            transition: all 0.18s ease;
            white-space: nowrap;
        }

        .btn-green {
            background: var(--green);
            color: #fff;
            box-shadow: 0 2px 8px rgba(76,175,80,0.3);
        }

        .btn-green:hover {
            background: var(--green-dark);
            box-shadow: 0 4px 14px rgba(56,142,60,0.35);
            transform: translateY(-1px);
        }

        .btn-outline {
            background: var(--white);
            color: var(--gray-600);
            border: 1.5px solid var(--gray-200);
        }

        .btn-outline:hover {
            background: var(--gray-50);
            border-color: var(--gray-400);
            color: var(--gray-800);
        }

        /* ======= INFO BOX ======= */
        .info-box {
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            border-radius: var(--radius-sm);
            padding: 0.9rem 1.1rem;
            font-size: 0.82rem;
            color: #1e40af;
            display: flex;
            align-items: flex-start;
            gap: 0.6rem;
            line-height: 1.5;
        }

        .info-box i { color: #3b82f6; margin-top: 0.1rem; flex-shrink: 0; }

        /* ======= STOCK BADGE ======= */
        .stock-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.2rem 0.55rem;
            border-radius: 20px;
            font-size: 0.72rem;
            font-weight: 600;
        }

        .stock-badge.low  { background: #fff7ed; color: #c2410c; border: 1px solid #fed7aa; }
        .stock-badge.ok   { background: #dcfce7; color: #166534;  border: 1px solid #bbf7d0; }
        .stock-badge.zero { background: #fee2e2; color: #991b1b;  border: 1px solid #fecaca; }

        /* ======= PRODUCT SUMMARY ======= */
        .product-summary {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1rem;
            background: var(--gray-50);
            border-radius: var(--radius-sm);
            border: 1px solid var(--gray-200);
            margin-bottom: 0.5rem;
        }

        .product-summary-img {
            width: 56px;
            height: 56px;
            border-radius: var(--radius-sm);
            object-fit: cover;
            border: 1px solid var(--gray-200);
            flex-shrink: 0;
        }

        .product-summary-img-placeholder {
            width: 56px;
            height: 56px;
            border-radius: var(--radius-sm);
            background: var(--gray-200);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--gray-400);
            font-size: 1.4rem;
            flex-shrink: 0;
        }

        .product-summary-info { flex: 1; min-width: 0; }

        .product-summary-name {
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--gray-800);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .product-summary-meta {
            font-size: 0.72rem;
            color: var(--gray-400);
            margin-top: 0.2rem;
            display: flex;
            gap: 0.75rem;
            flex-wrap: wrap;
        }

        /* ======= STOCK PREVIEW ======= */
        .stock-preview {
            background: var(--green-light);
            border: 1px solid var(--green-mid);
            border-radius: var(--radius-sm);
            padding: 0.9rem 1.1rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-top: 0.5rem;
        }

        .stock-preview i { color: var(--green-dark); font-size: 1rem; flex-shrink: 0; }

        .stock-preview-text {
            font-size: 0.82rem;
            color: var(--green-dark);
            line-height: 1.5;
        }

        .stock-preview-text strong { font-weight: 700; }

        .stock-arrow { color: var(--green); font-weight: 700; margin: 0 0.3rem; }

        /* ======= FOOTER ======= */
        .footer {
            background: var(--white);
            border-top: 1px solid var(--gray-200);
            padding: 1.2rem 2rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .footer-logo {
            display: flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 0.9rem;
            font-weight: 700;
            color: var(--green-dark);
            text-decoration: none;
        }

        .footer-logo i { color: var(--green); }
        .footer-copy { font-size: 0.78rem; color: var(--gray-400); }

        /* ======= RESPONSIVE ======= */
        @media (max-width: 900px) {
            .layout { flex-direction: column; padding: 0 1rem; }
            .sidebar { width: 100%; position: static; }
            .sidebar-nav { display: flex; flex-wrap: wrap; gap: 0.25rem; }
            .sidebar-nav a { width: auto; }
        }

        @media (max-width: 640px) {
            .form-grid { grid-template-columns: 1fr; }
            .form-group.full { grid-column: span 1; }
            .layout { padding: 0 1rem; }
            .topnav { padding: 0 1rem; }
            .nav-links { display: none; }
        }
    </style>
</head>
<body>

<jsp:include page="/sidebar.jsp">
    <jsp:param name="activePage" value="inventory"/>
</jsp:include>

    <!-- MAIN -->
    <main class="sena-main">

        <!-- Breadcrumb -->
        <div class="breadcrumb">
            <a href="products"><i class="fa-solid fa-box"></i> Sản Phẩm</a>
            <i class="fa-solid fa-chevron-right" style="font-size:0.6rem;color:var(--gray-400);"></i>
            <span>Nhập Kho</span>
        </div>

        <!-- Alerts -->
        <% if (message != null) { %>
        <div class="alert alert-success">
            <i class="fa-solid fa-circle-check"></i>
            <span><%= message %></span>
        </div>
        <% } %>
        <% if (error != null) { %>
        <div class="alert alert-danger">
            <i class="fa-solid fa-circle-exclamation"></i>
            <span><%= error %></span>
        </div>
        <% } %>

        <!-- Info box -->
        <div class="info-box">
            <i class="fa-solid fa-circle-info"></i>
            <span>Chức năng <strong>Nhập Kho</strong> cho phép bạn bổ sung số lượng tồn kho cho sản phẩm của cửa hàng. Mỗi lần nhập kho được ghi nhận vào lịch sử giao dịch kho.</span>
        </div>

        <!-- Form -->
        <form action="inventory-import" method="POST" id="importForm">
            <!-- Chon san pham -->
            <div class="card">
                <div class="card-header">
                    <i class="fa-solid fa-boxes-packing" style="color:var(--green);font-size:1rem;"></i>
                    <div class="card-title">Chọn Sản Phẩm Nhập Kho</div>
                </div>
                <div class="card-body">
                    <div class="section-label">
                        <i class="fa-solid fa-asterisk" style="font-size:0.5rem;color:var(--green);"></i>
                        Thong tin san pham
                    </div>

                    <div class="form-group">
                        <label class="form-label">Sản phẩm <span class="required">*</span></label>
                        <select name="productId" id="productSelect" class="form-control" required onchange="onProductChange()">
                            <option value="">-- Chọn sản phẩm --</option>
                            <% for (Product p : products) { %>
                            <option value="<%= p.getId() %>"
                                    data-stock="<%= p.getStockQuantity() %>"
                                    data-unit="<%= p.getUnit() != null ? p.getUnit() : "" %>"
                                    data-title="<%= p.getTitle() != null ? p.getTitle() : "" %>"
                                    data-image="<%= p.getImage() != null ? ImageUrlUtil.resolve(p.getImage(), request.getContextPath()) : "" %>">
                                <%= p.getTitle() %> (Tồn kho: <%= p.getStockQuantity() %><%= p.getUnit() != null ? " " + p.getUnit() : "" %>)
                            </option>
                            <% } %>
                        </select>
                        <span class="form-hint">Chỉ hiển thị sản phẩm thuộc cửa hàng của bạn.</span>
                    </div>

                    <!-- Product summary -->
                    <div id="productSummary" class="product-summary" style="display:none;">
                        <img id="summaryImg" class="product-summary-img" src="" alt="product">
                        <div id="summaryImgPlaceholder" class="product-summary-img-placeholder" style="display:none;">
                            <i class="fa-solid fa-image"></i>
                        </div>
                        <div class="product-summary-info">
                            <div class="product-summary-name" id="summaryName"></div>
                            <div class="product-summary-meta">
                                <span>Đơn vị: <strong id="summaryUnit"></strong></span>
                                <span>Tồn kho hiện tại: <strong id="summaryStock"></strong></span>
                                <span id="summaryBadge"></span>
                            </div>
                        </div>
                    </div>

                    <!-- Stock preview -->
                    <div id="stockPreview" class="stock-preview" style="display:none;">
                        <i class="fa-solid fa-arrow-right-arrow-left"></i>
                        <div class="stock-preview-text" id="stockPreviewText"></div>
                    </div>
                </div>
            </div>

            <!-- Thong tin nhap kho -->
            <div class="card">
                <div class="card-header">
                    <i class="fa-solid fa-warehouse" style="color:var(--green);font-size:1rem;"></i>
                    <div class="card-title">Thông Tin Nhập Kho</div>
                </div>
                <div class="card-body">
                    <div class="section-label">
                        <i class="fa-solid fa-asterisk" style="font-size:0.5rem;color:var(--green);"></i>
                        So luong & ghi chu
                    </div>
                    <div class="form-grid">

                        <div class="form-group">
                            <label class="form-label">Số lượng nhập <span class="required">*</span></label>
                            <input type="number" name="quantity" id="quantityInput" class="form-control"
                                   placeholder="VD: 50" min="1" step="1" required oninput="updateStockPreview()">
                            <span class="form-hint">Số lượng phải lớn hơn 0.</span>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Ghi chú</label>
                            <input type="text" name="note" id="noteInput" class="form-control"
                                   placeholder="VD: Nhập bổ sung từ nhà cung cấp A">
                            <span class="form-hint">Không bắt buộc. Giúp bạn ghi nhận nguồn hàng.</span>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Ngày hết hạn lô hàng</label>
                            <input type="date" name="expiredDate" id="expiredDateInput" class="form-control">
                            <span class="form-hint">Không bắt buộc. Mỗi lần nhập kho có thể có hạn sử dụng riêng.</span>
                        </div>

                    </div>
                </div>
            </div>

            <!-- Actions -->
            <div class="form-actions">
                <a href="products" class="btn btn-outline">
                    <i class="fa-solid fa-arrow-left"></i> Quay Lại
                </a>
                <button type="submit" class="btn btn-green" id="btnSubmit">
                    <i class="fa-solid fa-floppy-disk"></i> Xác Nhận Nhập Kho
                </button>
            </div>
        </form>

    </main>
</div><!-- /layout -->

<!-- ====== FOOTER ====== -->
<footer class="footer">
    <a href="home.jsp" class="footer-logo"><i class="fa-solid fa-apple-whole"></i> SenaFruit</a>
    <span class="footer-copy">&copy; 2024 SenaFruit. Trái cây tươi ngon mỗi ngày.</span>
</footer>

<script>
(function() {
    var productSelect  = document.getElementById('productSelect');
    var quantityInput  = document.getElementById('quantityInput');
    var productSummary = document.getElementById('productSummary');
    var summaryImg     = document.getElementById('summaryImg');
    var summaryImgPlaceholder = document.getElementById('summaryImgPlaceholder');
    var summaryName    = document.getElementById('summaryName');
    var summaryUnit    = document.getElementById('summaryUnit');
    var summaryStock   = document.getElementById('summaryStock');
    var summaryBadge   = document.getElementById('summaryBadge');
    var stockPreview   = document.getElementById('stockPreview');
    var stockPreviewText = document.getElementById('stockPreviewText');
    var btnSubmit      = document.getElementById('btnSubmit');

    window.onProductChange = function() {
        var selected = productSelect.options[productSelect.selectedIndex];
        var stock = parseInt(selected.getAttribute('data-stock') || '0');
        var unit  = selected.getAttribute('data-unit') || '';
        var title = selected.getAttribute('data-title') || '';
        var image = selected.getAttribute('data-image') || '';

        if (!title) {
            productSummary.style.display = 'none';
            stockPreview.style.display   = 'none';
            return;
        }

        // Show summary
        productSummary.style.display = 'flex';
        summaryName.textContent = title;
        summaryUnit.textContent = unit;
        summaryStock.textContent = stock + (unit ? ' ' + unit : '');

        // Stock badge
        if (stock <= 0) {
            summaryBadge.className = 'stock-badge zero';
            summaryBadge.innerHTML = '<i class="fa-solid fa-circle-exclamation"></i> Hết hàng';
        } else if (stock <= 20) {
            summaryBadge.className = 'stock-badge low';
            summaryBadge.innerHTML = '<i class="fa-solid fa-circle-exclamation"></i> Sắp hết';
        } else {
            summaryBadge.className = 'stock-badge ok';
            summaryBadge.innerHTML = '<i class="fa-solid fa-check-circle"></i> Còn hàng';
        }

        // Product image
        if (image) {
            summaryImg.style.display = 'block';
            summaryImg.src = image;
            summaryImg.onerror = function() {
                summaryImg.style.display = 'none';
                summaryImgPlaceholder.style.display = 'flex';
            };
            summaryImgPlaceholder.style.display = 'none';
        } else {
            summaryImg.style.display = 'none';
            summaryImgPlaceholder.style.display = 'flex';
        }

        updateStockPreview();
    };

    window.updateStockPreview = function() {
        var selected = productSelect.options[productSelect.selectedIndex];
        if (!selected || !selected.value) {
            stockPreview.style.display = 'none';
            return;
        }

        var currentStock = parseInt(selected.getAttribute('data-stock') || '0');
        var qty = parseInt(quantityInput.value || '0');
        var unit = selected.getAttribute('data-unit') || '';

        if (qty > 0) {
            var newStock = currentStock + qty;
            stockPreview.style.display = 'flex';
            stockPreviewText.innerHTML =
                'Tồn kho hiện tại: <strong>' + currentStock + (unit ? ' ' + unit : '') + '</strong>'
                + ' <span class="stock-arrow">→</span> '
                + 'Sau khi nhập: <strong style="color:var(--green-dark);">' + newStock + (unit ? ' ' + unit : '') + '</strong>'
                + ' <span style="color:var(--green);">(+' + qty + ')</span>';
        } else {
            stockPreview.style.display = 'none';
        }
    };

    // Prevent double submit
    var form = document.getElementById('importForm');
    form.addEventListener('submit', function() {
        btnSubmit.disabled = true;
        btnSubmit.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang xử lý...';
    });
})();
</script>

</body>
</html>
