<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Category" %>
<%@ page import="model.Product" %>
<%@ page import="model.Customer" %>
<%@ page import="model.Seller" %>
<%@ page import="java.util.List" %>
<%
    Object sessionAccount = session.getAttribute("account");
    Object sessionUser = session.getAttribute("user");

    Object user = null;
    boolean isSeller = false;

    if (sessionAccount instanceof Seller) {
        user = (Seller) sessionAccount;
        isSeller = true;
    } else if (sessionUser instanceof Seller) {
        user = (Seller) sessionUser;
        isSeller = true;
    } else if (sessionUser instanceof Customer) {
        user = (Customer) sessionUser;
        isSeller = false;
    }

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String displayName = "";
    String avatarUrl = "";
    if (user instanceof Seller) {
        Seller seller = (Seller) user;
        displayName = seller.getFullname();
        avatarUrl = seller.getAvatar();
    } else if (user instanceof Customer) {
        Customer customer = (Customer) user;
        displayName = customer.getFullname();
        avatarUrl = customer.getAvatar();
    }

    if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
        avatarUrl = "https://ui-avatars.com/api/?name="
                  + java.net.URLEncoder.encode(displayName, "UTF-8")
                  + "&background=4caf50&color=fff&size=160&bold=true&rounded=true";
    }

    Product product = (Product) request.getAttribute("product");
    List<Category> categories = (List<Category>) request.getAttribute("categories");

    String errorMsg = "";
    if (request.getAttribute("error") != null) {
        errorMsg = request.getAttribute("error").toString();
    }

    String statusLabel = "";
    if (product != null) {
        if (product.getStatus() == 0) statusLabel = "Cho Duyet";
        else if (product.getStatus() == 1) statusLabel = "Hien Thi";
        else if (product.getStatus() == 2) statusLabel = "An";
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chinh Sua San Pham | Sena Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/seller.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/edit-product.css">
</head>
<body>

<!-- ====== TOPNAV ====== -->
<nav class="topnav">
    <a href="<%= request.getContextPath() %>/home.jsp" class="nav-logo">
        <i class="fa-solid fa-apple-whole"></i> Sena Shop
    </a>
    <div class="nav-links">
        <a href="<%= request.getContextPath() %>/home.jsp">Trang Chu</a>
        <a href="#">San Pham</a>
        <a href="#">Don Hang</a>
        <a href="#" class="active">Quan Ly</a>
    </div>
    <div class="nav-right">
        <button class="nav-icon-btn" title="Thong bao"><i class="fa-regular fa-bell"></i></button>
        <a href="<%= request.getContextPath() %>/profile">
            <img class="nav-avatar" src="<%= avatarUrl %>" alt="avatar">
        </a>
    </div>
</nav>

<!-- ====== LAYOUT ====== -->
<div class="layout">

    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-user">
            <div class="sidebar-user-row">
                <img class="sidebar-user-avatar" src="<%= avatarUrl %>" alt="avatar">
                <div>
                    <div class="sidebar-welcome"><%= displayName.split(" ")[displayName.split(" ").length - 1] %></div>
                </div>
            </div>
            <div class="sidebar-role-text">Nhan Vien Ban Hang</div>
        </div>

        <div class="sidebar-nav">
            <a href="<%= request.getContextPath() %>/seller/dashboard">
                <i class="fa-solid fa-chart-line"></i> Tong Quan
            </a>
            <a href="<%= request.getContextPath() %>/seller/add-product">
                <i class="fa-solid fa-plus-circle"></i> Them San Pham
            </a>
            <a href="<%= request.getContextPath() %>/seller/products" class="active">
                <i class="fa-solid fa-box-open"></i> Quan Ly San Pham
            </a>
            <a href="<%= request.getContextPath() %>/seller/orders">
                <i class="fa-solid fa-receipt"></i> Don Hang
            </a>
            <a href="<%= request.getContextPath() %>/profile">
                <i class="fa-regular fa-user"></i> Ho So
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="main">

        <% if (!errorMsg.isEmpty()) { %>
        <div class="alert alert-danger">
            <i class="fa-solid fa-circle-exclamation"></i>
            <span><%= errorMsg %></span>
        </div>
        <% } %>

        <!-- Edit Product Card -->
        <div class="card">
            <div class="card-header">
                <div class="card-title">
                    <i class="fa-solid fa-pen-to-square"></i> Chinh Sua San Pham
                </div>
                <% if (product != null) { %>
                <a href="<%= request.getContextPath() %>/seller/products" class="btn btn-outline btn-sm">
                    <i class="fa-solid fa-arrow-left"></i> Quay Lai
                </a>
                <% } %>
            </div>
            <div class="card-body">
                <div class="inline-errors" id="inlineErrors">
                    <strong><i class="fa-solid fa-circle-exclamation"></i> Vui long kiem tra lai:</strong>
                    <ul id="errorList"></ul>
                </div>

                <form action="<%= request.getContextPath() %>/seller/edit-product" method="POST"
                      enctype="multipart/form-data" id="productForm">

                    <!-- Hidden product id -->
                    <% if (product != null) { %>
                    <input type="hidden" name="id" value="<%= product.getId() %>">
                    <input type="hidden" name="keepImage" id="keepImage" value="true">
                    <% } %>

                    <!-- Category + Status row -->
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">Danh Muc <span class="required">*</span></label>
                            <select name="categoryId" id="categoryId" class="form-control" required>
                                <option value="">-- Chon danh muc --</option>
                                <% if (categories != null) {
                                    for (Category cat : categories) {
                                        boolean selected = product != null && product.getCategoryId() == cat.getId();
                                %>
                                <option value="<%= cat.getId() %>" <%= selected ? "selected" : "" %>>
                                    <%= cat.getName() %>
                                </option>
                                <%  }
                                   } %>
                            </select>
                            <div class="field-error" id="categoryId-error">Vui long chon danh muc san pham.</div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Trang Thai <span class="required">*</span></label>
                            <div class="status-group" style="padding-top:0.45rem;">
                                <label class="status-option">
                                    <input type="radio" name="status" value="0"
                                           <%= product != null && product.getStatus() == 0 ? "checked" : "" %>>
                                    <div class="status-pill pending"><i class="fa-regular fa-clock"></i> Cho Duyet</div>
                                </label>
                                <label class="status-option">
                                    <input type="radio" name="status" value="1"
                                           <%= product != null && product.getStatus() == 1 ? "checked" : "" %>>
                                    <div class="status-pill active"><i class="fa-solid fa-eye"></i> Hien Thi</div>
                                </label>
                                <label class="status-option">
                                    <input type="radio" name="status" value="2"
                                           <%= product != null && product.getStatus() == 2 ? "checked" : "" %>>
                                    <div class="status-pill hidden"><i class="fa-solid fa-eye-slash"></i> An</div>
                                </label>
                            </div>
                        </div>
                    </div>

                    <!-- Title -->
                    <div class="form-grid" style="margin-top:1rem;">
                        <div class="form-group full">
                            <label class="form-label">Ten San Pham <span class="required">*</span></label>
                            <input type="text" name="title" id="title" class="form-control"
                                   placeholder="VD: Tao My Fuji Nhap Khau"
                                   maxlength="255" required
                                   value="<%= product != null && product.getTitle() != null ? product.getTitle().replace("\"", "&quot;") : "" %>">
                            <div class="field-error" id="title-error">Ten san pham khong duoc de trong.</div>
                        </div>
                    </div>

                    <!-- Description -->
                    <div class="form-grid" style="margin-top:1rem;">
                        <div class="form-group full">
                            <label class="form-label">Mo Ta San Pham</label>
                            <textarea name="description" class="form-control"
                                      placeholder="Mo ta chi tiet ve san pham: nguon goc, dac diem, cach bao quan..."><%= product != null && product.getDescription() != null ? product.getDescription() : "" %></textarea>
                        </div>
                    </div>

                    <!-- Current image + new image -->
                    <div class="form-grid" style="margin-top:1rem;">
                        <div class="form-group">
                            <label class="form-label">Hinh Anh Hien Tai</label>
                            <% if (product != null && product.getImage() != null && !product.getImage().isEmpty()) { %>
                            <div class="current-image-wrap">
                                <img src="<%= product.getImage() %>" alt="Current Image" class="current-image">
                                <div class="current-image-label">
                                    <i class="fa-solid fa-image"></i> Da co anh
                                </div>
                            </div>
                            <% } else { %>
                            <div class="current-image-wrap">
                                <div class="current-image-placeholder">
                                    <i class="fa-solid fa-image"></i>
                                    <span>Chua co anh</span>
                                </div>
                            </div>
                            <% } %>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Tai Anh Moi</label>
                            <div class="file-upload-wrap">
                                <label for="imageInput" class="file-upload-label" id="uploadLabel">
                                    <i class="fa-solid fa-cloud-arrow-up" id="uploadIcon"></i>
                                    <span id="uploadText">Nhan vao de tai anh moi</span>
                                    <small id="uploadHint">Dinh dang: JPG, PNG, WEBP, GIF | Toc do: toi da 5MB</small>
                                </label>
                                <input type="file" id="imageInput" name="image" accept="image/*" onchange="handleNewImage(this)">
                                <div id="imagePreview" style="display:none;">
                                    <img id="previewImg" src="" alt="Preview">
                                    <button type="button" class="remove-preview" onclick="removePreview()">
                                        <i class="fa-solid fa-xmark"></i>
                                    </button>
                                </div>
                            </div>
                            <span class="field-hint">Bo trong neu khong muon thay doi anh</span>
                        </div>
                    </div>

                    <!-- Unit -->
                    <div class="form-grid" style="margin-top:1rem;">
                        <div class="form-group">
                            <label class="form-label">Don Vi Tinh <span class="required">*</span></label>
                            <select name="unit" id="unit" class="form-control" required>
                                <option value="">-- Chon don vi --</option>
                                <% String[] units = {"kg", "quả", "hộp", "gói", "chai", "túi", "lần"};
                                   String currentUnit = product != null ? product.getUnit() : "";
                                   for (String u : units) { %>
                                <option value="<%= u %>" <%= u.equals(currentUnit) ? "selected" : "" %>><%= u %></option>
                                <% } %>
                            </select>
                            <div class="field-error" id="unit-error">Vui long chon don vi tinh.</div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">So Luong Ton Kho <span class="required">*</span></label>
                            <input type="number" name="stockQuantity" id="stockQuantity" class="form-control"
                                   placeholder="VD: 100" min="0" value="<%= product != null ? product.getStockQuantity() : 0 %>" required>
                            <div class="field-error" id="stockQuantity-error">So luong ton kho phai lon hon hoac bang 0.</div>
                        </div>
                    </div>

                    <!-- Prices -->
                    <div class="form-grid" style="margin-top:1rem;">
                        <div class="form-group">
                            <label class="form-label">Gia Goc (VND) <span class="required">*</span></label>
                            <input type="number" name="originalPrice" id="originalPrice" class="form-control"
                                   placeholder="VD: 120000" min="1" step="1000" required
                                   value="<%= product != null && product.getOriginalPrice() != null ? product.getOriginalPrice() : "" %>">
                            <div class="field-error" id="originalPrice-error">Gia goc phai lon hon 0.</div>
                            <span class="field-hint">Gia chua khuyen mai</span>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Gia Ban (VND)</label>
                            <input type="number" name="salePrice" id="salePrice" class="form-control"
                                   placeholder="VD: 99000" min="0" step="1000"
                                   value="<%= product != null && product.getSalePrice() != null ? product.getSalePrice() : "" %>">
                            <div class="field-error" id="salePrice-error">Gia ban khong duoc lon hon gia goc.</div>
                            <span class="field-hint">De trong neu khong co khuyen mai</span>
                        </div>
                    </div>

                    <!-- Expired date -->
                    <div class="form-grid" style="margin-top:1rem;">
                        <div class="form-group">
                            <label class="form-label">Ngay Het Han</label>
                            <input type="date" name="expiredDate" id="expiredDate" class="form-control"
                                   value="<%= product != null && product.getExpiredDate() != null ? product.getExpiredDate().toString() : "" %>">
                            <div class="field-error" id="expiredDate-error">Ngay het han phai sau ngay hien tai.</div>
                            <span class="field-hint">Bo trong neu khong co han su dung</span>
                        </div>

                        <div class="form-group">
                            <label class="form-label">San Pham Noi Bat</label>
                            <div style="display:flex; align-items:center; gap:0.75rem; padding-top:0.45rem;">
                                <label style="display:flex; align-items:center; gap:0.4rem; cursor:pointer; font-size:0.875rem; color:var(--gray-600);">
                                    <input type="checkbox" name="isFeatured" value="1"
                                           style="width:17px; height:17px; accent-color:var(--green);"
                                           <%= product != null && product.isIsFeatured() ? "checked" : "" %>>
                                    Danh dau san pham noi bat
                                </label>
                            </div>
                        </div>
                    </div>

                    <!-- Product info (read-only) -->
                    <% if (product != null) { %>
                    <div class="form-grid" style="margin-top:1rem;">
                        <div class="form-group">
                            <label class="form-label">Da Ban</label>
                            <input type="text" class="form-control" value="<%= product.getSoldQuantity() %> san pham" readonly>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Danh Gia TB</label>
                            <input type="text" class="form-control"
                                   value="<%= product.getAverageRating() != null ? product.getAverageRating() + " / 5" : "Chua co danh gia" %>" readonly>
                        </div>
                    </div>
                    <% } %>

                    <div class="form-actions">
                        <a href="<%= request.getContextPath() %>/seller/products" class="btn btn-outline">
                            <i class="fa-solid fa-arrow-left"></i> Quay Lai
                        </a>
                        <button type="submit" class="btn btn-green">
                            <i class="fa-solid fa-floppy-disk"></i> Luu Thay Doi
                        </button>
                    </div>
                </form>
            </div>
        </div>

    </main>
</div><!-- /layout -->

<!-- ====== FOOTER ====== -->
<footer class="footer">
    <a href="<%= request.getContextPath() %>/home.jsp" class="footer-logo"><i class="fa-solid fa-apple-whole"></i> Sena Shop</a>
    <span class="footer-copy">&copy; 2024 Sena Shop. Trai cay tuoi ngon moi ngay.</span>
</footer>

<script>
    function handleNewImage(input) {
        var preview = document.getElementById('imagePreview');
        var previewImg = document.getElementById('previewImg');
        var uploadLabel = document.getElementById('uploadLabel');
        var uploadText = document.getElementById('uploadText');
        var uploadHint = document.getElementById('uploadHint');
        var keepImage = document.getElementById('keepImage');

        if (input.files && input.files[0]) {
            var file = input.files[0];

            if (file.size > 5 * 1024 * 1024) {
                showFieldError(input, 'Kich thuoc file qua lon! Vui long chon file nho hon 5MB.');
                input.value = '';
                return;
            }
            clearFieldError(input);

            var reader = new FileReader();
            reader.onload = function(e) {
                previewImg.src = e.target.result;
                preview.style.display = 'block';
                uploadText.textContent = file.name;
                uploadHint.textContent = (file.size / 1024 / 1024).toFixed(2) + ' MB';
                if (keepImage) keepImage.value = 'false';
            };
            reader.readAsDataURL(file);
        }
    }

    function removePreview() {
        var input = document.getElementById('imageInput');
        var preview = document.getElementById('imagePreview');
        var previewImg = document.getElementById('previewImg');
        var uploadText = document.getElementById('uploadText');
        var uploadHint = document.getElementById('uploadHint');
        var keepImage = document.getElementById('keepImage');

        input.value = '';
        preview.style.display = 'none';
        previewImg.src = '';
        uploadText.textContent = 'Nhan vao de tai anh moi';
        uploadHint.textContent = 'Dinh dang: JPG, PNG, WEBP, GIF | Toc do: toi da 5MB';
        if (keepImage) keepImage.value = 'true';
        clearFieldError(input);
    }

    function showFieldError(fieldId, msg) {
        var field = typeof fieldId === 'string' ? document.getElementById(fieldId) : fieldId;
        if (!field) return;
        field.classList.add('error-field');
        var errEl = document.getElementById(field.name + '-error');
        if (!errEl) errEl = document.getElementById(fieldId + '-error');
        if (errEl) { errEl.textContent = msg; errEl.classList.add('show'); }
    }

    function clearFieldError(fieldId) {
        var field = typeof fieldId === 'string' ? document.getElementById(fieldId) : fieldId;
        if (!field) return;
        field.classList.remove('error-field');
        var errEl = document.getElementById(field.name + '-error');
        if (!errEl) errEl = document.getElementById(fieldId + '-error');
        if (errEl) { errEl.textContent = ''; errEl.classList.remove('show'); }
    }

    function showInlineErrors(errors) {
        var el = document.getElementById('inlineErrors');
        var list = document.getElementById('errorList');
        list.innerHTML = '';
        errors.forEach(function(e) { var li = document.createElement('li'); li.textContent = e; list.appendChild(li); });
        el.classList.add('show');
        el.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }

    function clearInlineErrors() {
        var el = document.getElementById('inlineErrors');
        if (el) el.classList.remove('show');
    }

    ['categoryId','title','unit','stockQuantity','originalPrice','salePrice','expiredDate'].forEach(function(id) {
        var el = document.getElementById(id);
        if (el) {
            el.addEventListener('change', function() { clearFieldError(id); clearInlineErrors(); });
            el.addEventListener('input',  function() { clearFieldError(id); clearInlineErrors(); });
        }
    });

    document.getElementById('productForm').addEventListener('submit', function(e) {
        e.preventDefault();

        var errors = [];
        clearInlineErrors();

        var categoryId = document.getElementById('categoryId');
        if (!categoryId.value || categoryId.value.trim() === '') {
            errors.push('Vui long chon danh muc san pham.');
            showFieldError(categoryId, 'Vui long chon danh muc san pham.');
        }

        var title = document.getElementById('title');
        if (!title.value || title.value.trim().length < 3) {
            errors.push('Ten san pham phai tu 3 ky tu tro len.');
            showFieldError(title, 'Ten san pham phai tu 3 ky tu tro len.');
        } else if (title.value.trim().length > 255) {
            errors.push('Ten san pham khong duoc qua 255 ky tu.');
            showFieldError(title, 'Ten san pham khong duoc qua 255 ky tu.');
        }

        var unit = document.getElementById('unit');
        if (!unit.value || unit.value.trim() === '') {
            errors.push('Vui long chon don vi tinh.');
            showFieldError(unit, 'Vui long chon don vi tinh.');
        }

        var stock = document.getElementById('stockQuantity');
        if (stock.value === '' || parseInt(stock.value) < 0) {
            errors.push('So luong ton kho phai lon hon hoac bang 0.');
            showFieldError(stock, 'So luong ton kho phai lon hon hoac bang 0.');
        } else if (parseInt(stock.value) > 99999) {
            errors.push('So luong ton kho khong duoc vuot qua 99.999.');
            showFieldError(stock, 'So luong ton kho khong duoc vuot qua 99.999.');
        }

        var originalPrice = document.getElementById('originalPrice');
        if (originalPrice.value === '' || parseFloat(originalPrice.value) <= 0) {
            errors.push('Gia goc phai lon hon 0.');
            showFieldError(originalPrice, 'Gia goc phai lon hon 0.');
        }

        var salePrice = document.getElementById('salePrice');
        if (salePrice.value !== '') {
            var sp = parseFloat(salePrice.value);
            var op = parseFloat(originalPrice.value);
            if (sp < 0) {
                errors.push('Gia ban khong duoc la so am.');
                showFieldError(salePrice, 'Gia ban khong duoc la so am.');
            } else if (!isNaN(op) && sp > op) {
                errors.push('Gia ban khong duoc lon hon gia goc.');
                showFieldError(salePrice, 'Gia ban khong duoc lon hon gia goc.');
            }
        }

        var expiredDate = document.getElementById('expiredDate');
        if (expiredDate.value !== '') {
            var today = new Date();
            today.setHours(0, 0, 0, 0);
            var expDate = new Date(expiredDate.value);
            if (expDate <= today) {
                errors.push('Ngay het han phai sau ngay hien tai.');
                showFieldError(expiredDate, 'Ngay het han phai sau ngay hien tai.');
            }
        }

        if (errors.length > 0) {
            showInlineErrors(errors);
            return false;
        }

        this.submit();
    });
</script>

</body>
</html>
