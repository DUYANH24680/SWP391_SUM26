<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%@ page import="model.Voucher" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Account account = (Account) session.getAttribute("Account");
    if (account == null || (!"admin".equalsIgnoreCase(account.getRoleName()) && !"seller".equalsIgnoreCase(account.getRoleName()))) {
        response.sendRedirect("login");
        return;
    }
    List<Voucher> vouchers = (List<Voucher>) request.getAttribute("vouchers");
    Boolean isGlobal = (Boolean) request.getAttribute("isGlobal");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản Lý Voucher</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { font-family: 'Inter', sans-serif; background: #f8fafc; margin: 0; color: #334155; }
        .container { max-width: 1200px; margin: 2rem auto; padding: 0 1rem; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; }
        .btn { padding: 0.6rem 1.2rem; border-radius: 8px; border: none; cursor: pointer; font-weight: 500; font-family: 'Inter', sans-serif; }
        .btn-primary { background: #10b981; color: white; }
        .btn-danger { background: #ef4444; color: white; padding: 0.4rem 0.8rem; font-size: 0.85rem;}
        .btn-edit { background: #3b82f6; color: white; padding: 0.4rem 0.8rem; font-size: 0.85rem;}
        table { width: 100%; border-collapse: collapse; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); }
        th, td { padding: 1rem; text-align: left; border-bottom: 1px solid #f1f5f9; }
        th { background: #f8fafc; font-weight: 600; color: #475569; }
        
        /* Modal Styles */
        .modal { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.5); align-items: center; justify-content: center; z-index: 1000; }
        .modal-content { background: white; width: 500px; border-radius: 12px; padding: 2rem; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1); max-height: 90vh; overflow-y: auto; }
        .form-group { margin-bottom: 1rem; }
        .form-group label { display: block; margin-bottom: 0.4rem; font-weight: 500; font-size: 0.9rem; }
        .form-control { width: 100%; padding: 0.6rem; border: 1px solid #cbd5e1; border-radius: 6px; font-family: inherit; box-sizing: border-box; }
        .status-badge { padding: 0.2rem 0.6rem; border-radius: 999px; font-size: 0.8rem; font-weight: 500; }
        .status-active { background: #dcfce7; color: #166534; }
        .status-inactive { background: #fee2e2; color: #991b1b; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>Quản Lý Voucher <%= isGlobal != null && isGlobal ? "(Toàn Hệ Thống)" : "(Shop Của Bạn)" %></h2>
            <div>
                <a href="home.jsp" class="btn" style="background:#e2e8f0; color:#475569; text-decoration:none; margin-right:10px;">Trở Về</a>
                <button class="btn btn-primary" onclick="openModal()"><i class="fa-solid fa-plus"></i> Tạo Voucher Mới</button>
            </div>
        </div>
        
        <% String msg = (String) session.getAttribute("message"); 
           String err = (String) session.getAttribute("error");
           if (msg != null) { %> <div style="padding:1rem;background:#dcfce7;color:#166534;border-radius:8px;margin-bottom:1rem;"><%= msg %></div> <% session.removeAttribute("message"); }
           if (err != null) { %> <div style="padding:1rem;background:#fee2e2;color:#991b1b;border-radius:8px;margin-bottom:1rem;"><%= err %></div> <% session.removeAttribute("error"); } %>

        <table>
            <thead>
                <tr>
                    <th>Mã Code</th>
                    <th>Loại</th>
                    <th>Giảm Giá</th>
                    <th>Đơn Tối Thiểu</th>
                    <th>Số Lượng / Đã Dùng</th>
                    <th>Hạn Dùng</th>
                    <th>Trạng Thái</th>
                    <th>Hành Động</th>
                </tr>
            </thead>
            <tbody>
                <% if (vouchers != null) {
                    for (Voucher v : vouchers) { %>
                    <tr>
                        <td style="font-weight:600;color:#10b981;"><%= v.getCode() %></td>
                        <td><%= v.getType() %></td>
                        <td>
                            <% if ("FREESHIP".equals(v.getType())) { %>
                                Freeship (Tối đa <%= v.getMaxDiscount() %>đ)
                            <% } else { %>
                                <%= v.getDiscountPercent() %>% 
                                <% if (v.getMaxDiscount() > 0) { %>(Tối đa <%= v.getMaxDiscount() %>đ)<% } %>
                            <% } %>
                        </td>
                        <td><%= v.getMinimumOrder() %>đ</td>
                        <td><%= v.getUsedCount() %> / <%= v.getQuantity() %><br><small>Tối đa <%= v.getMaxUsagesPerUser() %>/người</small></td>
                        <td>
                            <small>Từ: <%= v.getStartDate() != null ? sdf.format(v.getStartDate()).replace("T", " ") : "Không có" %></small><br>
                            <small>Đến: <%= v.getEndDate() != null ? sdf.format(v.getEndDate()).replace("T", " ") : "Không có" %></small>
                        </td>
                        <td>
                            <span class="status-badge <%= v.isStatus() ? "status-active" : "status-inactive" %>">
                                <%= v.isStatus() ? "Hoạt động" : "Đã khóa" %>
                            </span>
                        </td>
                        <td>
                            <button class="btn btn-edit" onclick="editVoucher(<%= v.getId() %>, '<%= v.getCode() %>', '<%= v.getType() %>', <%= v.getDiscountPercent() %>, <%= v.getMaxDiscount() %>, <%= v.getMinimumOrder() %>, <%= v.getQuantity() %>, <%= v.getMaxUsagesPerUser() %>, <%= v.isStatus() %>, '<%= v.getStartDate() != null ? sdf.format(v.getStartDate()) : "" %>', '<%= v.getEndDate() != null ? sdf.format(v.getEndDate()) : "" %>')"><i class="fa-solid fa-pen"></i></button>
                            <form action="manage-vouchers" method="post" style="display:inline;" onsubmit="return confirm('Bạn có chắc muốn xóa voucher này?');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="<%= v.getId() %>">
                                <button type="submit" class="btn btn-danger"><i class="fa-solid fa-trash"></i></button>
                            </form>
                        </td>
                    </tr>
                <%  } } %>
            </tbody>
        </table>
    </div>

    <!-- Modal -->
    <div id="voucherModal" class="modal">
        <div class="modal-content">
            <h3 id="modalTitle" style="margin-top:0;">Tạo Voucher Mới</h3>
            <form action="manage-vouchers" method="post">
                <input type="hidden" name="action" id="formAction" value="create">
                <input type="hidden" name="id" id="voucherId" value="">
                
                <div class="form-group">
                    <label>Mã Voucher (Code)</label>
                    <input type="text" name="code" id="code" class="form-control" required style="text-transform:uppercase;">
                </div>
                
                <div class="form-group">
                    <label>Loại Voucher</label>
                    <select name="type" id="type" class="form-control" onchange="toggleType()">
                        <option value="DISCOUNT">Giảm Giá Sản Phẩm (Hoa quả)</option>
                        <option value="FREESHIP">Miễn Phí Vận Chuyển</option>
                    </select>
                </div>
                
                <div class="form-group" id="discountPercentGroup">
                    <label>Phần trăm giảm giá (%)</label>
                    <input type="number" step="0.1" name="discountPercent" id="discountPercent" class="form-control" value="0">
                </div>
                
                <div class="form-group">
                    <label id="maxDiscountLabel">Giảm tối đa (đ)</label>
                    <input type="number" name="maxDiscount" id="maxDiscount" class="form-control" value="0">
                </div>
                
                <div class="form-group">
                    <label>Đơn tối thiểu (đ)</label>
                    <input type="number" name="minimumOrder" id="minimumOrder" class="form-control" value="0">
                </div>
                
                <div style="display:flex;gap:1rem;">
                    <div class="form-group" style="flex:1;">
                        <label>Ngày Bắt Đầu</label>
                        <input type="datetime-local" name="startDate" id="startDate" class="form-control">
                    </div>
                    <div class="form-group" style="flex:1;">
                        <label>Ngày Kết Thúc</label>
                        <input type="datetime-local" name="endDate" id="endDate" class="form-control">
                    </div>
                </div>
                
                <div style="display:flex;gap:1rem;">
                    <div class="form-group" style="flex:1;">
                        <label>Số lượng (tổng lượt dùng)</label>
                        <input type="number" name="quantity" id="quantity" class="form-control" value="100" required>
                    </div>
                    <div class="form-group" style="flex:1;">
                        <label>Số lượt tối đa / Khách hàng</label>
                        <input type="number" name="maxUsagesPerUser" id="maxUsagesPerUser" class="form-control" value="3" required>
                    </div>
                </div>

                <div class="form-group" style="display:flex;align-items:center;gap:0.5rem;">
                    <input type="checkbox" name="status" id="status" checked value="true">
                    <label style="margin:0;">Kích hoạt</label>
                </div>

                <div style="text-align:right; margin-top:2rem;">
                    <button type="button" class="btn" style="background:#e2e8f0;margin-right:0.5rem;" onclick="closeModal()">Hủy</button>
                    <button type="submit" class="btn btn-primary">Lưu Thay Đổi</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function toggleType() {
            var type = document.getElementById('type').value;
            if (type === 'FREESHIP') {
                document.getElementById('discountPercentGroup').style.display = 'none';
                document.getElementById('maxDiscountLabel').innerText = 'Giảm tối đa (Phí vận chuyển - đ)';
            } else {
                document.getElementById('discountPercentGroup').style.display = 'block';
                document.getElementById('maxDiscountLabel').innerText = 'Giảm tối đa (đ)';
            }
        }

        function openModal() {
            document.getElementById('modalTitle').innerText = 'Tạo Voucher Mới';
            document.getElementById('formAction').value = 'create';
            document.getElementById('voucherId').value = '';
            document.getElementById('code').value = '';
            document.getElementById('type').value = 'DISCOUNT';
            document.getElementById('discountPercent').value = '0';
            document.getElementById('maxDiscount').value = '0';
            document.getElementById('minimumOrder').value = '0';
            document.getElementById('startDate').value = '';
            document.getElementById('endDate').value = '';
            document.getElementById('quantity').value = '100';
            document.getElementById('maxUsagesPerUser').value = '3';
            document.getElementById('status').checked = true;
            toggleType();
            document.getElementById('voucherModal').style.display = 'flex';
        }

        function editVoucher(id, code, type, dp, md, mo, qty, maxu, status, sd, ed) {
            document.getElementById('modalTitle').innerText = 'Cập Nhật Voucher';
            document.getElementById('formAction').value = 'update';
            document.getElementById('voucherId').value = id;
            document.getElementById('code').value = code;
            document.getElementById('type').value = type;
            document.getElementById('discountPercent').value = dp;
            document.getElementById('maxDiscount').value = md;
            document.getElementById('minimumOrder').value = mo;
            document.getElementById('startDate').value = sd;
            document.getElementById('endDate').value = ed;
            document.getElementById('quantity').value = qty;
            document.getElementById('maxUsagesPerUser').value = maxu;
            document.getElementById('status').checked = status;
            toggleType();
            document.getElementById('voucherModal').style.display = 'flex';
        }

        function closeModal() {
            document.getElementById('voucherModal').style.display = 'none';
        }
    </script>
</body>
</html>
