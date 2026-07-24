<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Shop" %>
<%@ page import="model.Voucher" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    List<Voucher> vouchers = (List<Voucher>) request.getAttribute("vouchers");
    Map<Integer, Shop> shopMap = (Map<Integer, Shop>) request.getAttribute("shopMap");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    
    Account Account = (Account) session.getAttribute("Account");
    // Fetch cart count for navbar
    int cartCount = 0;
    model.Cart cart = (model.Cart) session.getAttribute("cart");
    if (cart != null) { cartCount = cart.getTotalQuantity(); }
    int wishlistCount = 0;
    if (session.getAttribute("wishlistCount") != null) { wishlistCount = (Integer) session.getAttribute("wishlistCount"); }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Kho Voucher - SenaFruit</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { font-family: 'Inter', sans-serif; background: #f8fafc; margin: 0; padding-top: 80px; color: #334155; }
        .container { max-width: 1200px; margin: 0 auto; padding: 2rem 1rem; }
        
        .page-title { text-align: center; margin-bottom: 3rem; }
        .page-title h1 { font-size: 2.5rem; color: #0f172a; margin-bottom: 0.5rem; }
        .page-title p { color: #64748b; font-size: 1.1rem; }

        .voucher-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 1.5rem;
        }

        .voucher-card {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            display: flex;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);
            position: relative;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .voucher-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1);
        }

        .vc-left {
            width: 110px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 1rem;
            color: white;
            text-align: center;
            position: relative;
            border-right: 2px dashed rgba(255,255,255,0.5);
        }
        
        .vc-left::before, .vc-left::after {
            content: '';
            position: absolute;
            right: -8px;
            width: 16px;
            height: 16px;
            background: #f8fafc;
            border-radius: 50%;
        }
        .vc-left::before { top: -8px; }
        .vc-left::after { bottom: -8px; }

        .vc-left.type-freeship { background: #0ea5e9; }
        .vc-left.type-discount { background: #ef4444; }

        .vc-left i { font-size: 2rem; margin-bottom: 0.5rem; }
        .vc-left span { font-weight: 700; font-size: 0.9rem; }

        .vc-right {
            flex: 1;
            padding: 1.2rem;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .vc-title { font-weight: 700; font-size: 1.1rem; color: #1e293b; margin-bottom: 0.3rem; }
        .vc-shop { font-size: 0.85rem; color: #10b981; font-weight: 600; margin-bottom: 0.5rem; display: flex; align-items: center; gap: 0.3rem; }
        .vc-min { font-size: 0.85rem; color: #64748b; margin-bottom: 0.5rem; }
        .vc-exp { font-size: 0.8rem; color: #94a3b8; margin-bottom: 1rem; }
        
        .vc-footer { display: flex; justify-content: space-between; align-items: center; margin-top: auto; }
        .vc-code { background: #f1f5f9; padding: 0.3rem 0.6rem; border-radius: 6px; font-weight: 600; font-size: 0.9rem; color: #475569; letter-spacing: 1px; }
        .vc-btn { background: #10b981; color: white; border: none; padding: 0.4rem 1rem; border-radius: 6px; font-weight: 600; cursor: pointer; font-family: 'Inter', sans-serif; transition: background 0.2s; }
        .vc-btn:hover { background: #059669; }

        /* Topnav Styles */
        .topnav { position: fixed; top: 0; left: 0; width: 100%; height: 60px; background: white; display: flex; align-items: center; padding: 0 2rem; box-shadow: 0 2px 10px rgba(0,0,0,0.05); z-index: 100; box-sizing: border-box; }
        .nav-logo { font-size: 1.5rem; font-weight: 700; color: #10b981; text-decoration: none; display: flex; align-items: center; gap: 0.5rem; margin-right: 2rem; }
        .nav-links { display: flex; gap: 1.5rem; margin-left: 2rem; }
        .nav-links a { text-decoration: none; color: #475569; font-weight: 500; font-size: 0.95rem; transition: color 0.2s; }
        .nav-links a:hover, .nav-links a.active { color: #10b981; }
        .nav-right { margin-left: auto; display: flex; align-items: center; gap: 1rem; }
        .nav-icon-btn { background: #f8fafc; border: none; width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; cursor: pointer; color: #475569; transition: all 0.2s; text-decoration: none; position: relative; }
        .nav-icon-btn:hover { background: #e2e8f0; color: #10b981; }
        .badge { position: absolute; top: -5px; right: -5px; background: #ef4444; color: white; font-size: 0.7rem; font-weight: 700; width: 18px; height: 18px; border-radius: 50%; display: flex; align-items: center; justify-content: center; border: 2px solid white; }
    </style>
</head>
<body>

    <!-- TOPNAV -->
    <nav class="topnav">
        <a href="home.jsp" class="nav-logo"><i class="fa-solid fa-apple-whole"></i> SenaFruit</a>
        <div class="nav-links">
            <% if (Account != null && "seller".equalsIgnoreCase(Account.getRoleName())) { %>
                <a href="inventory-export">Xuất Kho</a>
                <a href="inventory-import">Nhập Kho</a>
            <% } %>
            <% if (Account != null && ("admin".equalsIgnoreCase(Account.getRoleName()) || "seller".equalsIgnoreCase(Account.getRoleName()))) { %>
                <a href="products">Sản Phẩm</a>
            <% } %>
            <a href="danh-muc">Danh Mục</a>
            <% if (Account == null || "customer".equalsIgnoreCase(Account.getRoleName())) { %>
                <a href="vouchers" class="active" style="color:#ef4444;"><i class="fa-solid fa-ticket"></i> Voucher</a>
            <% } %>
        </div>
        <div class="nav-right">
            <a href="wishlist" class="nav-icon-btn" title="Wishlist">
                <i class="fa-solid fa-heart"></i>
                <span class="badge"><%= wishlistCount %></span>
            </a>
            <a href="cart" class="nav-icon-btn" title="Giỏ hàng">
                <i class="fa-solid fa-basket-shopping"></i>
                <span class="badge"><%= cartCount %></span>
            </a>
        </div>
    </nav>

    <div class="container">
        <div class="page-title">
            <h1>Kho Voucher Khuyến Mãi</h1>
            <p>Thu thập các mã giảm giá và mã miễn phí vận chuyển để tiết kiệm hơn khi mua sắm tại SenaFruit!</p>
        </div>

        <% if (vouchers == null || vouchers.isEmpty()) { %>
            <div style="text-align:center; padding: 4rem; background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);">
                <i class="fa-solid fa-ticket-simple" style="font-size: 4rem; color: #cbd5e1; margin-bottom: 1rem;"></i>
                <h3 style="color:#475569;">Hiện tại chưa có voucher nào</h3>
                <p style="color:#94a3b8;">Vui lòng quay lại sau nhé!</p>
            </div>
        <% } else { %>
            <div class="voucher-grid">
                <% for (Voucher v : vouchers) { 
                    boolean isFreeship = "FREESHIP".equals(v.getType());
                    String shopName = v.getShopId() == null ? "Toàn Hệ Thống" : (shopMap.get(v.getShopId()) != null ? shopMap.get(v.getShopId()).getShopName() : "Shop Lạ");
                %>
                <div class="voucher-card">
                    <div class="vc-left <%= isFreeship ? "type-freeship" : "type-discount" %>">
                        <i class="<%= isFreeship ? "fa-solid fa-truck-fast" : "fa-solid fa-percent" %>"></i>
                        <span><%= isFreeship ? "Freeship" : "Giảm Giá" %></span>
                    </div>
                    <div class="vc-right">
                        <div class="vc-shop"><i class="<%= v.getShopId() == null ? "fa-solid fa-globe" : "fa-solid fa-store" %>"></i> <%= shopName %></div>
                        <div class="vc-title">
                            <% if (isFreeship) { %>
                                Giảm phí ship <%= v.getMaxDiscount() > 0 ? "tối đa " + String.format("%,.0f", v.getMaxDiscount()) + "đ" : "" %>
                            <% } else { %>
                                Giảm <%= v.getDiscountPercent() %>% <%= v.getMaxDiscount() > 0 ? "tối đa " + String.format("%,.0f", v.getMaxDiscount()) + "đ" : "" %>
                            <% } %>
                        </div>
                        <div class="vc-min">Đơn tối thiểu <%= String.format("%,.0f", v.getMinimumOrder()) %>đ</div>
                        <div class="vc-exp">HSD: <%= v.getEndDate() != null ? sdf.format(v.getEndDate()) : "Không giới hạn" %></div>
                        <div class="vc-footer">
                            <div class="vc-code" id="code-<%= v.getCode() %>"><%= v.getCode() %></div>
                            <button class="vc-btn" onclick="copyCode('<%= v.getCode() %>', this)">Copy Mã</button>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        <% } %>
    </div>

    <script>
        function copyCode(code, btn) {
            if (navigator.clipboard && window.isSecureContext) {
                navigator.clipboard.writeText(code).then(() => {
                    showSuccess(btn);
                }).catch(err => {
                    fallbackCopyTextToClipboard(code, btn);
                });
            } else {
                fallbackCopyTextToClipboard(code, btn);
            }
        }

        function fallbackCopyTextToClipboard(text, btn) {
            var textArea = document.createElement("textarea");
            textArea.value = text;
            
            // Avoid scrolling to bottom
            textArea.style.top = "0";
            textArea.style.left = "0";
            textArea.style.position = "fixed";

            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();

            try {
                var successful = document.execCommand('copy');
                if (successful) {
                    showSuccess(btn);
                } else {
                    alert('Không thể copy mã. Vui lòng copy tay!');
                }
            } catch (err) {
                alert('Không thể copy mã. Vui lòng copy tay!');
            }

            document.body.removeChild(textArea);
        }

        function showSuccess(btn) {
            let originalText = btn.innerText;
            btn.innerText = 'Đã Copy!';
            btn.style.background = '#0ea5e9';
            setTimeout(() => {
                btn.innerText = originalText;
                btn.style.background = '#10b981';
            }, 2000);
        }
    </script>
</body>
</html>
