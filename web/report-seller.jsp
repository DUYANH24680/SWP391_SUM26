<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Shop" %>
<%
    Account user = (Account) session.getAttribute("user");
    Shop shop = (Shop) request.getAttribute("shop");
    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("message");
    session.removeAttribute("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo Cáo Cửa Hàng | Sena Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --green: #4caf50; --green-dark: #388e3c; --green-light: #e8f5e9;
            --bg: #f0f4f1; --white: #ffffff; --gray-100: #eef1ee; --gray-200: #dde5dd;
            --gray-400: #9aaa9a; --gray-600: #5a6a5a; --gray-800: #2d3d2d;
            --red: #dc2626; --red-light: #fee2e2;
            --radius: 14px; --shadow: 0 4px 12px rgba(0,0,0,.08);
        }
        body { font-family: 'Inter', sans-serif; background: var(--bg); min-height: 100vh; }
        .container { max-width: 640px; margin: 2rem auto; padding: 0 1.5rem; }
        .card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--gray-200);
                box-shadow: var(--shadow); overflow: hidden; }
        .card-header { background: var(--green-light); padding: 1.25rem 1.5rem;
                       border-bottom: 1px solid var(--gray-200); }
        .card-header h2 { font-size: 1.15rem; font-weight: 700; color: var(--green-dark); }
        .card-header p { font-size: 0.85rem; color: var(--gray-600); margin-top: 0.2rem; }
        .card-body { padding: 1.5rem; }

        .shop-preview { display: flex; align-items: center; gap: 0.85rem;
                        background: var(--gray-100); border-radius: 10px; padding: 0.85rem 1rem; margin-bottom: 1.25rem; }
        .shop-avatar { width: 44px; height: 44px; border-radius: 8px; background: var(--green-light);
                       border: 2px solid var(--green); display: flex; align-items: center; justify-content: center;
                       font-size: 1.2rem; color: var(--green); flex-shrink: 0; }
        .shop-name { font-weight: 700; color: var(--green-dark); font-size: 1rem; }

        .form-group { margin-bottom: 1.1rem; }
        .form-label { display: block; font-size: 0.85rem; font-weight: 600; color: var(--gray-800); margin-bottom: 0.35rem; }
        .form-label span { color: var(--red); }
        .form-control { width: 100%; padding: 0.6rem 0.85rem; border: 1.5px solid var(--gray-200);
                        border-radius: 8px; font-size: 0.875rem; font-family: inherit; outline: none;
                        transition: border-color 0.15s; }
        .form-control:focus { border-color: var(--green); }
        textarea.form-control { resize: vertical; min-height: 100px; }
        select.form-control { cursor: pointer; }

        .priority-group { display: flex; gap: 0.5rem; }
        .priority-option { flex: 1; }
        .priority-option input { display: none; }
        .priority-option label { display: block; text-align: center; padding: 0.45rem;
                                  border: 2px solid var(--gray-200); border-radius: 8px; font-size: 0.8rem;
                                  font-weight: 600; cursor: pointer; transition: all 0.15s; color: var(--gray-600); }
        .priority-option input:checked + label { border-color: var(--green); background: var(--green-light); color: var(--green-dark); }
        .priority-low input:checked + label { border-color: #f59e0b; background: #fffbeb; color: #92400e; }
        .priority-medium input:checked + label { border-color: var(--green); background: var(--green-light); color: var(--green-dark); }
        .priority-high input:checked + label { border-color: #ef4444; background: #fef2f2; color: #991b1b; }
        .priority-critical input:checked + label { border-color: #7c3aed; background: #f5f3ff; color: #5b21b6; }

        .btn-row { display: flex; gap: 0.75rem; margin-top: 1.5rem; }
        .btn { flex: 1; padding: 0.7rem; border-radius: 8px; font-size: 0.875rem; font-weight: 600;
               font-family: inherit; border: none; cursor: pointer; transition: all 0.15s; text-align: center; text-decoration: none; }
        .btn-primary { background: var(--green); color: white; }
        .btn-primary:hover { background: var(--green-dark); }
        .btn-outline { background: transparent; color: var(--gray-600); border: 1.5px solid var(--gray-200); }
        .btn-outline:hover { background: var(--gray-100); }

        .alert { display: flex; align-items: center; gap: 0.75rem; padding: 0.85rem 1rem;
                 border-radius: 8px; font-size: 0.875rem; font-weight: 500; margin-bottom: 1rem; }
        .alert-success { background: #dcfce7; border: 1px solid #bbf7d0; color: #15803d; }
        .alert-danger  { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }

        .report-type-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem; }
        .report-type-option input { display: none; }
        .report-type-option label { display: flex; align-items: center; gap: 0.5rem;
                                     padding: 0.6rem 0.85rem; border: 1.5px solid var(--gray-200);
                                     border-radius: 8px; font-size: 0.85rem; font-weight: 500;
                                     cursor: pointer; transition: all 0.15s; color: var(--gray-800); }
        .report-type-option input:checked + label { border-color: var(--red); background: var(--red-light); color: var(--red); }
        .report-type-option label i { font-size: 1rem; }

        .info-note { font-size: 0.78rem; color: var(--gray-400); margin-top: 0.3rem; }
    </style>
</head>
<body>
<div class="container">
    <% if (message != null) { %>
        <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> <%= message %></div>
    <% } %>
    <% if (error != null) { %>
        <div class="alert alert-danger"><i class="fa-solid fa-circle-exclamation"></i> <%= error %></div>
    <% } %>

    <div class="card">
        <div class="card-header">
            <h2><i class="fa-solid fa-flag" style="margin-right:6px;"></i>Báo Cáo Cửa Hàng</h2>
            <p>Mô tả chi tiết vấn đề bạn gặp phải với cửa hàng này.</p>
        </div>
        <div class="card-body">

            <% if (shop != null) { %>
            <div class="shop-preview">
                <div class="shop-avatar">
                    <% if (shop.getLogo() != null && !shop.getLogo().isEmpty()) { %>
                        <img src="<%= shop.getLogo() %>" alt="logo" style="width:100%;height:100%;border-radius:inherit;object-fit:cover;">
                    <% } else { %>
                        <i class="fa-solid fa-store"></i>
                    <% } %>
                </div>
                <div>
                    <div class="shop-name"><%= shop.getName() %></div>
                    <div style="font-size:0.78rem;color:var(--gray-400);">#<%= shop.getId() %> &bull; Báo cáo về cửa hàng này</div>
                </div>
            </div>
            <% } %>

            <form method="post" action="<%= request.getContextPath() %>/submit-report" id="reportForm">
                <input type="hidden" name="shopId" value="<%= shop != null ? shop.getId() : "" %>">

                <!-- Report Type -->
                <div class="form-group">
                    <label class="form-label">Loại vi phạm <span>*</span></label>
                    <div class="report-type-grid">
                        <div class="report-type-option">
                            <input type="radio" name="reportType" id="type-scam" value="Scam" required>
                            <label for="type-scam"><i class="fa-solid fa-ban"></i> Lừa đảo</label>
                        </div>
                        <div class="report-type-option">
                            <input type="radio" name="reportType" id="type-fake" value="FakeProduct">
                            <label for="type-fake"><i class="fa-solid fa-box-open"></i> Sản phẩm giả</label>
                        </div>
                        <div class="report-type-option">
                            <input type="radio" name="reportType" id="type-harassment" value="Harassment">
                            <label for="type-harassment"><i class="fa-solid fa-comment-slash"></i> Quấy rối</label>
                        </div>
                        <div class="report-type-option">
                            <input type="radio" name="reportType" id="type-late" value="LateDelivery">
                            <label for="type-late"><i class="fa-solid fa-truck-fast"></i> Giao trễ</label>
                        </div>
                        <div class="report-type-option">
                            <input type="radio" name="reportType" id="type-review" value="BadReview">
                            <label for="type-review"><i class="fa-solid fa-star-half-stroke"></i> Spam đánh giá</label>
                        </div>
                        <div class="report-type-option">
                            <input type="radio" name="reportType" id="type-other" value="Other">
                            <label for="type-other"><i class="fa-solid fa-ellipsis"></i> Khác</label>
                        </div>
                    </div>
                </div>

                <!-- Description -->
                <div class="form-group">
                    <label class="form-label">Mô tả chi tiết <span>*</span></label>
                    <textarea name="description" class="form-control"
                              placeholder="Mô tả chi tiết vấn đề bạn gặp phải... (tối thiểu 10 ký tự)"
                              required minlength="10" maxlength="2000"></textarea>
                    <div class="info-note">Mô tả càng chi tiết, admin xử lý càng nhanh.</div>
                </div>

                <!-- Priority -->
                <div class="form-group">
                    <label class="form-label">Mức độ nghiêm trọng</label>
                    <div class="priority-group">
                        <div class="priority-option priority-low">
                            <input type="radio" name="priority" id="prio-1" value="1">
                            <label for="prio-1"><i class="fa-solid fa-circle-info"></i> Thấp</label>
                        </div>
                        <div class="priority-option priority-medium">
                            <input type="radio" name="priority" id="prio-2" value="2" checked>
                            <label for="prio-2"><i class="fa-solid fa-circle-exclamation"></i> Trung bình</label>
                        </div>
                        <div class="priority-option priority-high">
                            <input type="radio" name="priority" id="prio-3" value="3">
                            <label for="prio-3"><i class="fa-solid fa-triangle-exclamation"></i> Cao</label>
                        </div>
                        <div class="priority-option priority-critical">
                            <input type="radio" name="priority" id="prio-4" value="4">
                            <label for="prio-4"><i class="fa-solid fa-skull"></i> Nghiêm trọng</label>
                        </div>
                    </div>
                </div>

                <!-- Order ID (optional) -->
                <div class="form-group">
                    <label class="form-label">Mã đơn hàng liên quan (nếu có)</label>
                    <input type="text" name="orderId" class="form-control" placeholder="VD: 123">
                    <div class="info-note">Nếu vấn đề liên quan đến đơn hàng cụ thể, hãy ghi rõ mã đơn.</div>
                </div>

                <div class="btn-row">
                    <a href="<%= request.getContextPath() %>/home.jsp" class="btn btn-outline">Hủy</a>
                    <button type="submit" class="btn btn-primary">
                        <i class="fa-solid fa-paper-plane"></i> Gửi Báo Cáo
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
</body>
</html>
