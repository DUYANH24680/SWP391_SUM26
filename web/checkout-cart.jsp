<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.CartItem" %>
<%@ page import="model.DeliveryAddress" %>
<%@ page import="model.Voucher" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    Account Account = (Account) session.getAttribute("user");
    if (Account == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<CartItem> selectedItems = (List<CartItem>) request.getAttribute("selectedItems");
    if (selectedItems == null || selectedItems.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/view-cart");
        return;
    }

    List<DeliveryAddress> addresses = (List<DeliveryAddress>) request.getAttribute("addresses");
    List<Voucher> vouchers = (List<Voucher>) request.getAttribute("vouchers");
    List<Integer> selectedProductIds = (List<Integer>) request.getAttribute("selectedProductIds");
    double totalCost = request.getAttribute("totalCost") != null ? ((Number) request.getAttribute("totalCost")).doubleValue() : 0;
    double shippingFee = totalCost >= 200000 ? 0.0 : 20000.0;
    double finalCost = totalCost + shippingFee;

    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(java.util.Locale.forLanguageTag("vi"));

    StringBuilder selectedProductsBuilder = new StringBuilder();
    for (int i = 0; i < selectedProductIds.size(); i++) {
        if (i > 0) selectedProductsBuilder.append(",");
        selectedProductsBuilder.append(selectedProductIds.get(i));
    }
    String selectedProductsStr = selectedProductsBuilder.toString();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác nhận đặt hàng | Sena Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --green: #4caf50;
            --green-dark: #388e3c;
            --green-light: #e8f5e9;
            --green-mid: #c8e6c9;
            --bg: #f4f6f4;
            --white: #ffffff;
            --gray-100: #eef1ee;
            --gray-200: #dde5dd;
            --gray-400: #9aaa9a;
            --gray-600: #5a6a5a;
            --gray-800: #2d3d2d;
            --shadow: 0 4px 16px rgba(0,0,0,.08);
            --shadow-md: 0 10px 30px rgba(0,0,0,.1);
            --radius: 16px;
            --radius-sm: 10px;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg);
            color: var(--gray-800);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .topnav {
            background: var(--white);
            border-bottom: 1px solid var(--gray-200);
            height: 60px;
            display: flex;
            align-items: center;
            padding: 0 2rem;
            position: sticky;
            top: 0;
            z-index: 100;
            box-shadow: 0 1px 3px rgba(0,0,0,.05);
        }
        .nav-logo {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 1.3rem;
            font-weight: 800;
            color: var(--green-dark);
            text-decoration: none;
        }
        .nav-logo i { color: var(--green); }

        .container {
            max-width: 1100px;
            width: 100%;
            margin: 2rem auto;
            padding: 0 1.5rem;
            flex: 1;
        }

        .breadcrumb {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.85rem;
            color: var(--gray-400);
            margin-bottom: 1.5rem;
        }
        .breadcrumb a { color: var(--green); text-decoration: none; font-weight: 600; }
        .breadcrumb span { color: var(--gray-600); }

        .checkout-grid {
            display: grid;
            grid-template-columns: 1.6fr 1fr;
            gap: 2rem;
            align-items: flex-start;
        }
        @media (max-width: 850px) {
            .checkout-grid { grid-template-columns: 1fr; }
        }

        .card {
            background: var(--white);
            border-radius: var(--radius);
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow);
            padding: 1.75rem;
            margin-bottom: 1.5rem;
        }
        .card-title {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--gray-800);
            margin-bottom: 1.25rem;
            display: flex;
            align-items: center;
            gap: 0.65rem;
            border-bottom: 1px solid var(--gray-100);
            padding-bottom: 0.75rem;
        }
        .card-title i { color: var(--green); }

        .form-group {
            margin-bottom: 1.25rem;
            display: flex;
            flex-direction: column;
            gap: 0.4rem;
        }
        .form-label {
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--gray-600);
        }
        .form-select, .form-input, .form-textarea {
            width: 100%;
            padding: 0.75rem 1rem;
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-family: inherit;
            font-size: 0.9rem;
            outline: none;
            transition: all 0.15s ease;
            color: var(--gray-800);
            background: var(--white);
        }
        .form-select:focus, .form-input:focus, .form-textarea:focus {
            border-color: var(--green);
            box-shadow: 0 0 0 3px rgba(76,175,80,0.1);
        }
        .address-suggestion {
            background: var(--green-light);
            border: 1.5px dashed var(--green-mid);
            border-radius: var(--radius-sm);
            padding: 0.85rem 1.1rem;
            font-size: 0.8rem;
            color: var(--green-dark);
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .product-list {
            display: flex;
            flex-direction: column;
            gap: 1rem;
            max-height: 360px;
            overflow-y: auto;
            padding-right: 0.25rem;
        }
        .product-summary {
            display: flex;
            gap: 1rem;
            align-items: center;
            background: var(--gray-50);
            padding: 1rem;
            border-radius: var(--radius-sm);
            border: 1px solid var(--gray-100);
        }
        .product-img {
            width: 64px;
            height: 64px;
            border-radius: var(--radius-sm);
            object-fit: cover;
            border: 1px solid var(--gray-200);
        }
        .product-details { flex: 1; }
        .product-name {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--gray-800);
            margin-bottom: 0.25rem;
        }
        .product-qty-price {
            font-size: 0.85rem;
            color: var(--gray-600);
        }

        .voucher-input-group {
            display: flex;
            gap: 0.5rem;
        }
        .btn-apply {
            padding: 0.75rem 1.25rem;
            background: var(--gray-800);
            color: #fff;
            border: none;
            border-radius: var(--radius-sm);
            font-weight: 600;
            cursor: pointer;
            transition: background 0.15s;
            font-size: 0.9rem;
        }
        .btn-apply:hover { background: #1e2b1e; }
        .voucher-msg {
            font-size: 0.8rem;
            margin-top: 0.4rem;
            font-weight: 500;
        }
        .voucher-msg.success { color: var(--green-dark); }
        .voucher-msg.error { color: #dc2626; }

        .bill-row {
            display: flex;
            justify-content: space-between;
            font-size: 0.875rem;
            color: var(--gray-600);
            margin-bottom: 0.75rem;
        }
        .bill-row.total {
            border-top: 1px solid var(--gray-100);
            padding-top: 0.75rem;
            font-weight: 800;
            color: var(--gray-800);
            font-size: 1.05rem;
            margin-top: 0.5rem;
        }
        .bill-row.discount {
            color: #dc2626;
        }

        .payment-option {
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            padding: 0.9rem 1.1rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            cursor: pointer;
            transition: all 0.18s;
            margin-bottom: 0.75rem;
        }
        .payment-option:hover {
            background: var(--green-light);
            border-color: var(--green-mid);
        }
        .payment-option.active {
            border-color: var(--green);
            background: var(--green-light);
        }
        .payment-option input { accent-color: var(--green); }
        .payment-option i {
            font-size: 1.15rem;
            color: var(--green-dark);
            width: 20px;
            text-align: center;
        }

        .btn-checkout {
            width: 100%;
            padding: 0.9rem;
            background: var(--green);
            color: #fff;
            border: none;
            border-radius: var(--radius-sm);
            font-weight: 700;
            font-size: 1rem;
            cursor: pointer;
            box-shadow: 0 4px 14px rgba(76,175,80,0.3);
            transition: all 0.18s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
        }
        .btn-checkout:hover {
            background: var(--green-dark);
            box-shadow: 0 6px 18px rgba(56,142,60,0.35);
            transform: translateY(-1px);
        }

        .footer {
            background: var(--white);
            border-top: 1px solid var(--gray-200);
            padding: 1.5rem 2rem;
            text-align: center;
            font-size: 0.8rem;
            color: var(--gray-400);
            margin-top: auto;
        }
    </style>
</head>
<body>

    <nav class="topnav">
        <a href="home.jsp" class="nav-logo">
            <i class="fa-solid fa-apple-whole"></i> Sena Shop
        </a>
    </nav>

    <div class="container">

        <div class="breadcrumb">
            <a href="home.jsp">Trang Chủ</a>
            <i class="fa-solid fa-chevron-right" style="font-size:0.6rem;"></i>
            <a href="view-cart">Giỏ hàng</a>
            <i class="fa-solid fa-chevron-right" style="font-size:0.6rem;"></i>
            <span>Đặt hàng</span>
        </div>

        <c:if test="${not empty error}">
            <div style="background:#fee2e2; border: 1px solid #fecaca; color:#991b1b; padding:0.9rem 1.2rem; border-radius:var(--radius-sm); font-size:0.875rem; margin-bottom:1.5rem;">
                <i class="fa-solid fa-circle-exclamation" style="margin-right:0.5rem;"></i> ${error}
            </div>
        </c:if>

        <form method="post" action="checkout-cart" id="checkoutForm">
            <input type="hidden" name="selectedProducts" value="<%= selectedProductsStr %>">

            <div class="checkout-grid">
                <div class="checkout-left">
                    <div class="card">
                        <div class="card-title">
                            <i class="fa-solid fa-truck-ramp-box"></i> Thông Tin Nhận Hàng
                        </div>

                        <% 
                            if (addresses != null && !addresses.isEmpty()) { 
                                int selectedIndex = 0;
                                for (int i = 0; i < addresses.size(); i++) {
                                    if (addresses.get(i).isIsDefault()) {
                                        selectedIndex = i;
                                        break;
                                    }
                                }
                        %>
                            <div class="form-group">
                                <label class="form-label" for="savedAddressSelect">Chọn địa chỉ đã lưu</label>
                                <select class="form-select" id="savedAddressSelect" onchange="fillAddressFields()">
                                    <% 
                                        for (int i = 0; i < addresses.size(); i++) {
                                            DeliveryAddress addr = addresses.get(i);
                                            String selectedStr = (i == selectedIndex) ? "selected" : "";
                                    %>
                                        <option value="<%= addr.getId() %>" 
                                                data-name="<%= addr.getRecipientName() %>"
                                                data-phone="<%= addr.getRecipientPhone() %>"
                                                data-address="<%= addr.getAddress() %>"
                                                <%= selectedStr %>>
                                            <%= addr.getRecipientName() %> - <%= addr.getRecipientPhone() %> (<%= addr.getAddress() %>) <%= addr.isIsDefault() ? "[Mặc định]" : "" %>
                                        </option>
                                    <% } %>
                                    <option value="new">-- Nhập địa chỉ mới --</option>
                                </select>
                            </div>
                        <% } else { %>
                            <div class="address-suggestion">
                                <i class="fa-solid fa-circle-info"></i> Bạn chưa lưu địa chỉ nào. Hệ thống đã tự động điền thông tin tài khoản của bạn.
                            </div>
                        <% } %>

                        <div class="form-group">
                            <label class="form-label" for="recipientName">Tên người nhận <span style="color:#e53e3e;">*</span></label>
                            <input type="text" class="form-input" id="recipientName" name="recipientName" required placeholder="Ví dụ: Nguyễn Văn A" value="<%= Account.getFullname() != null ? Account.getFullname() : "" %>">
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="recipientPhone">Số điện thoại nhận hàng <span style="color:#e53e3e;">*</span></label>
                            <input type="tel" class="form-input" id="recipientPhone" name="recipientPhone" required placeholder="Ví dụ: 0987654321" pattern="[0-9]{9,11}" value="<%= Account.getPhone() != null ? Account.getPhone() : "" %>">
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="address">Địa chỉ giao hàng <span style="color:#e53e3e;">*</span></label>
                            <input type="text" class="form-input" id="address" name="address" required placeholder="Số nhà, ngõ, đường, phường/xã, quận/huyện, tỉnh thành" value="<%= Account.getAddress() != null ? Account.getAddress() : "" %>">
                        </div>

                        <div class="form-group" style="margin-bottom:0;">
                            <label class="form-label" for="note">Ghi chú cho shipper (nếu có)</label>
                            <textarea class="form-textarea" id="note" name="note" rows="2" placeholder="Ví dụ: Giao ngoài giờ hành chính, gọi trước 15 phút..."></textarea>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-title">
                            <i class="fa-regular fa-credit-card"></i> Phương Thức Thanh Toán
                        </div>

                        <label class="payment-option active">
                            <input type="radio" name="paymentMethod" value="COD" checked>
                            <i class="fa-solid fa-hand-holding-dollar"></i>
                            <div>
                                <strong style="display:block; font-size:0.875rem;">Thanh toán khi nhận hàng (COD)</strong>
                                <span style="font-size:0.75rem; color:var(--gray-600);">Thanh toán bằng tiền mặt khi shipper giao hàng tới nơi.</span>
                            </div>
                        </label>

                        <label class="payment-option" style="opacity: 0.6; cursor: not-allowed;" onclick="alert('Thanh toán ví điện tử MoMo đang được tích hợp.'); return false;">
                            <input type="radio" name="paymentMethod" value="Momo" disabled>
                            <i class="fa-solid fa-wallet" style="color:var(--gray-400);"></i>
                            <div>
                                <strong style="display:block; font-size:0.875rem; color:var(--gray-600);">Thanh toán qua ví MoMo (Bảo trì)</strong>
                                <span style="font-size:0.75rem; color:var(--gray-400);">Sử dụng ví MoMo để quét mã thanh toán trực tuyến.</span>
                            </div>
                        </label>

                        <label class="payment-option" style="opacity: 0.6; cursor: not-allowed;" onclick="alert('Thanh toán VNPay đang được tích hợp.'); return false;">
                            <input type="radio" name="paymentMethod" value="VNPay" disabled>
                            <i class="fa-solid fa-credit-card" style="color:var(--gray-400);"></i>
                            <div>
                                <strong style="display:block; font-size:0.875rem; color:var(--gray-600);">Thanh toán qua VNPay (Bảo trì)</strong>
                                <span style="font-size:0.75rem; color:var(--gray-400);">Liên kết thẻ ngân hàng ATM/Visa/MasterCard qua cổng VNPay.</span>
                            </div>
                        </label>
                    </div>
                </div>

                <div class="checkout-right">
                    <div class="card">
                        <div class="card-title">
                            <i class="fa-solid fa-basket-shopping"></i> Tóm Tắt Đơn Hàng
                        </div>

                        <div class="product-list" style="margin-bottom:1.25rem;">
                            <%
                                for (CartItem item : selectedItems) {
                                    double itemTotal = item.getUnitPrice() * item.getQuantity();
                            %>
                                <div class="product-summary">
                                    <% if (item.getImage() != null && !item.getImage().trim().isEmpty()) { %>
                                        <img src="<%= item.getImage() %>" alt="<%= item.getTitle() %>" class="product-img" onerror="this.src='https://ui-avatars.com/api/?name=F&background=4caf50&color=fff&size=80&bold=true';">
                                    <% } else { %>
                                        <div class="product-img" style="background:var(--green-light); display:flex; align-items:center; justify-content:center; font-size:1.8rem;">🍎</div>
                                    <% } %>
                                    <div class="product-details">
                                        <div class="product-name"><%= item.getTitle() %></div>
                                        <div class="product-qty-price">Số lượng: <strong><%= item.getQuantity() %></strong> &times; <%= nf.format((long) item.getUnitPrice()) %> đ</div>
                                        <div class="product-qty-price">Tạm tính: <strong><%= nf.format((long) itemTotal) %> đ</strong></div>
                                    </div>
                                </div>
                            <% } %>
                        </div>

                        <div class="form-group" style="margin-bottom: 1.25rem;">
                            <label class="form-label" for="voucherCode">Áp dụng mã giảm giá</label>
                            <div class="voucher-input-group">
                                <input type="text" class="form-input" id="voucherCode" name="voucherCode" placeholder="Nhập mã (Ví dụ: WELCOME10)">
                                <button type="button" class="btn-apply" onclick="applyVoucher()">Áp dụng</button>
                            </div>
                            <div class="voucher-msg" id="voucherMessage"></div>
                        </div>

                        <div style="border-top:1px solid var(--gray-100); padding-top:1rem;">
                            <div class="bill-row">
                                <span>Tiền hàng:</span>
                                <strong id="totalCostValue"><%= nf.format((long) totalCost) %> đ</strong>
                            </div>
                            <div class="bill-row discount" id="discountRow" style="display:none;">
                                <span>Mã giảm giá:</span>
                                <strong id="discountValue">-0 đ</strong>
                            </div>
                            <div class="bill-row">
                                <span>Phí vận chuyển:</span>
                                <strong id="shippingFeeValue"><%= nf.format((long) shippingFee) %> đ</strong>
                            </div>

                            <% if (shippingFee == 0) { %>
                                <div style="font-size:0.75rem; color:var(--green-dark); font-weight:600; text-align:right; margin-bottom:0.5rem; margin-top:-0.25rem;">
                                    <i class="fa-solid fa-circle-check"></i> Được miễn phí vận chuyển (đơn trên 200k)
                                </div>
                            <% } %>

                            <div class="bill-row total">
                                <span>Tổng cộng:</span>
                                <span id="finalCostValue" style="color:var(--green-dark);"><%= nf.format((long) finalCost) %> đ</span>
                            </div>
                        </div>
                    </div>

                    <button type="submit" class="btn-checkout">
                        <i class="fa-solid fa-shield-check"></i> Xác Nhận Mua Hàng
                    </button>

                    <a href="view-cart" style="display:block; text-align:center; font-size:0.85rem; color:var(--gray-600); text-decoration:none; margin-top:1rem; font-weight:600;">
                        <i class="fa-solid fa-chevron-left" style="font-size:0.75rem;"></i> Quay lại giỏ hàng
                    </a>
                </div>
            </div>
        </form>

    </div>

    <footer class="footer">
        &copy; 2026 Sena Shop. Hệ thống mua bán trái cây tươi ngon - chất lượng cao.
    </footer>

    <script>
        function fillAddressFields() {
            var select = document.getElementById("savedAddressSelect");
            if (!select) return;

            var selectedOption = select.options[select.selectedIndex];

            var nameField = document.getElementById("recipientName");
            var phoneField = document.getElementById("recipientPhone");
            var addrField = document.getElementById("address");

            if (selectedOption.value === "new") {
                nameField.value = "";
                phoneField.value = "";
                addrField.value = "";
            } else {
                nameField.value = selectedOption.getAttribute("data-name") || "";
                phoneField.value = selectedOption.getAttribute("data-phone") || "";
                addrField.value = selectedOption.getAttribute("data-address") || "";
            }
        }

        window.addEventListener("DOMContentLoaded", function() {
            fillAddressFields();
        });

        var originalTotal = <%= totalCost %>;
        var originalShipping = <%= shippingFee %>;
        var appliedVoucherId = null;

        function formatCurrency(number) {
            return new Intl.NumberFormat('vi-VN').format(number) + " đ";
        }

        function applyVoucher() {
            var code = document.getElementById("voucherCode").value.trim();
            var msgDiv = document.getElementById("voucherMessage");

            if (code === "") {
                msgDiv.className = "voucher-msg error";
                msgDiv.innerText = "Vui lòng nhập mã giảm giá.";
                clearVoucherDisplay();
                return;
            }

            var url = "${pageContext.request.contextPath}/checkout?action=checkVoucher&code=" + encodeURIComponent(code) + "&total=" + originalTotal;

            fetch(url)
                .then(response => response.json())
                .then(data => {
                    if (data.valid) {
                        msgDiv.className = "voucher-msg success";
                        msgDiv.innerHTML = '<i class="fa-solid fa-circle-check"></i> ' + data.msg;

                        var discount = data.discount;
                        var finalTotal = originalTotal - discount + originalShipping;

                        var discountRow = document.getElementById("discountRow");
                        var discountVal = document.getElementById("discountValue");
                        var finalCostVal = document.getElementById("finalCostValue");

                        discountRow.style.display = "flex";
                        discountVal.innerText = "-" + formatCurrency(discount);
                        finalCostVal.innerText = formatCurrency(finalTotal);

                        appliedVoucherId = data.voucherId;
                    } else {
                        msgDiv.className = "voucher-msg error";
                        msgDiv.innerHTML = '<i class="fa-solid fa-circle-xmark"></i> ' + data.msg;
                        clearVoucherDisplay();
                    }
                })
                .catch(err => {
                    console.error("Lỗi AJAX voucher:", err);
                    msgDiv.className = "voucher-msg error";
                    msgDiv.innerText = "Lỗi khi kiểm tra mã giảm giá.";
                    clearVoucherDisplay();
                });
        }

        function clearVoucherDisplay() {
            var discountRow = document.getElementById("discountRow");
            var finalCostVal = document.getElementById("finalCostValue");

            discountRow.style.display = "none";
            finalCostVal.innerText = formatCurrency(originalTotal + originalShipping);
            appliedVoucherId = null;
        }
    </script>
</body>
</html>

