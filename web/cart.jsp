<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Cart" %>
<%@ page import="model.CartItem" %>
<%@ page import="model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    Cart cart = (Cart) session.getAttribute("cart");
    if (cart == null) {
        cart = new Cart();
        session.setAttribute("cart", cart);
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Giỏ Hàng | Sena Shop</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background: #f7faf7;
            color: #2d3d2d;
            margin: 0;
            padding: 0;
        }
        .page-wrap {
            max-width: 1040px;
            margin: 0 auto;
            padding: 2rem 1rem;
        }
        .page-title {
            font-size: 2rem;
            margin-bottom: 1rem;
            font-weight: 700;
        }
        .breadcrumb {
            margin-bottom: 1.5rem;
            color: #6b7280;
            font-size: 0.95rem;
        }
        .breadcrumb a {
            color: #16a34a;
            text-decoration: none;
        }
        .cart-card {
            background: #ffffff;
            border-radius: 18px;
            box-shadow: 0 24px 48px rgba(15, 23, 42, 0.08);
            padding: 1.5rem;
            margin-bottom: 1.5rem;
        }
        .cart-table {
            width: 100%;
            border-collapse: collapse;
        }
        .cart-table th,
        .cart-table td {
            padding: 1rem 0.75rem;
            border-bottom: 1px solid #e5e7eb;
            vertical-align: middle;
        }
        .cart-table th {
            text-align: left;
            font-size: 0.92rem;
            color: #4b5563;
            font-weight: 700;
        }
        .cart-item {
            display: flex;
            gap: 1rem;
            align-items: center;
        }
        .cart-item-image {
            width: 88px;
            height: 88px;
            border-radius: 16px;
            overflow: hidden;
            background: #f3f4f6;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .cart-item-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .cart-item-details {
            display: grid;
            gap: 0.3rem;
        }
        .cart-item-title {
            font-size: 1rem;
            font-weight: 700;
            color: #111827;
        }
        .cart-item-meta {
            font-size: 0.9rem;
            color: #6b7280;
        }
        .quantity-input {
            width: 80px;
            padding: 0.6rem 0.75rem;
            border: 1px solid #d1d5db;
            border-radius: 12px;
            font-size: 0.95rem;
            color: #111827;
        }
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            border: none;
            border-radius: 999px;
            cursor: pointer;
            font-weight: 600;
            transition: transform 0.15s ease;
        }
        .btn:hover { transform: translateY(-1px); }
        .btn-primary {
            background: #16a34a;
            color: #fff;
            padding: 0.85rem 1.25rem;
        }
        .btn-secondary {
            background: #f3f4f6;
            color: #374151;
            padding: 0.75rem 1rem;
        }
        .btn-danger {
            background: #ef4444;
            color: #fff;
            padding: 0.75rem 1rem;
        }
        .summary-box {
            background: #ecfdf5;
            border: 1px solid #d1fae5;
            border-radius: 18px;
            padding: 1.5rem;
        }
        .summary-row {
            display: flex;
            justify-content: space-between;
            gap: 1rem;
            margin-bottom: 0.85rem;
            font-size: 1rem;
            color: #111827;
        }
        .summary-row strong {
            font-weight: 700;
        }
        .summary-total {
            margin-top: 1rem;
            font-size: 1.25rem;
            font-weight: 700;
            color: #16a34a;
        }
        .empty-cart {
            padding: 2rem;
            text-align: center;
            color: #4b5563;
        }
        .empty-cart h2 {
            margin-bottom: 0.5rem;
            font-size: 1.5rem;
            color: #111827;
        }
        .cart-actions {
            display: flex;
            gap: 0.75rem;
            flex-wrap: wrap;
            margin-top: 1rem;
        }
        .notes-text {
            font-size: 0.9rem;
            color: #4b5563;
            margin-top: 0.35rem;
        }
    </style>
</head>
<body>
<div class="page-wrap">
    <div class="breadcrumb">
        <a href="home.jsp">Trang chủ</a> / Giỏ hàng
    </div>
    <div class="page-title">Giỏ hàng của bạn</div>

    <div class="cart-card">
        <% if (cart.isEmpty()) { %>
            <div class="empty-cart">
                <h2>Giỏ hàng đang trống</h2>
                <p>Hãy chọn sản phẩm bạn yêu thích và thêm vào giỏ hàng.</p>
                <div class="cart-actions">
                    <a href="home.jsp" class="btn btn-primary">Tiếp tục mua sắm</a>
                </div>
            </div>
        <% } else { %>
            <table class="cart-table">
                <thead>
                <tr>
                    <th>Sản phẩm</th>
                    <th>Số lượng</th>
                    <th>Đơn giá</th>
                    <th>Tạm tính</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                <% for (CartItem item : cart.getItems()) { %>
                    <tr>
                        <td>
                            <div class="cart-item">
                                <div class="cart-item-image">
                                    <% if (item.getImage() != null && !item.getImage().trim().isEmpty()) { %>
                                        <img src="<%= item.getImage() %>" alt="<%= item.getTitle() %>">
                                    <% } else { %>
                                        <span style="font-size: 1.5rem;">🍎</span>
                                    <% } %>
                                </div>
                                <div class="cart-item-details">
                                    <div class="cart-item-title"><%= item.getTitle() %></div>
                                    <div class="cart-item-meta">
                                        <% if (item.getSize() != null && !item.getSize().isEmpty()) { %>
                                            <span>Kích cỡ: <strong><%= item.getSize() %></strong></span>
                                        <% } %>
                                        <% if (item.getNote() != null && !item.getNote().isEmpty()) { %>
                                            <div class="notes-text">Ghi chú: <%= item.getNote() %></div>
                                        <% } %>
                                        <% if (item.getDiscountCode() != null && !item.getDiscountCode().isEmpty()) { %>
                                            <div class="notes-text">Mã giảm giá: <strong><%= item.getDiscountCode() %></strong></div>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <form action="cart" method="post" style="display:flex;align-items:center;gap:0.5rem;">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="productId" value="<%= item.getProductId() %>">
                                <input type="hidden" name="size" value="<%= item.getSize() != null ? item.getSize() : "" %>">
                                <input class="quantity-input" type="number" name="quantity" min="1" value="<%= item.getQuantity() %>">
                                <button type="submit" class="btn btn-secondary">Cập nhật</button>
                            </form>
                        </td>
                        <td><%= String.format("%,.0f", item.getUnitPrice()) %> đ</td>
                        <td><%= String.format("%,.0f", item.getSubtotal()) %> đ</td>
                        <td>
                            <a href="cart?action=remove&productId=<%= item.getProductId() %>&size=<%= item.getSize() != null ? item.getSize() : "" %>"
                               class="btn btn-danger">Xóa</a>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
            <div class="summary-box">
                <div class="summary-row">
                    <span>Tổng số lượng</span>
                    <strong><%= cart.getTotalQuantity() %></strong>
                </div>
                <div class="summary-row">
                    <span>Tổng tiền</span>
                    <strong><%= String.format("%,.0f", cart.getTotalPrice()) %> đ</strong>
                </div>
                <div class="summary-total">Thanh toán khi nhận hàng sẽ sớm được hỗ trợ.</div>
                <div class="cart-actions">
                    <a href="home.jsp" class="btn btn-secondary">Tiếp tục mua sắm</a>
                    <a href="cart?action=clear" class="btn btn-danger">Xóa giỏ hàng</a>
                    <button type="button" class="btn btn-primary" onclick="alert('Thanh toán đang phát triển.')">Tiến hành thanh toán</button>
                </div>
            </div>
        <% } %>
    </div>
</div>
</body>
</html>
