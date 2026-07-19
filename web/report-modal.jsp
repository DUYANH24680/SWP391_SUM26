<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%
    Account reportUser = (Account) session.getAttribute("user");
    String reportRole = reportUser != null ? reportUser.getRoleName() : "";
    if (reportRole == null) reportRole = "";
    String reportCtx = request.getContextPath();
%>
<% if ("customer".equalsIgnoreCase(reportRole)) { %>
<!-- DuyAnhNgo- Modal Đa Năng: Dùng chung cho cả Báo cáo Sản phẩm và Tố cáo Cửa hàng -->
<div id="report-modal" style="position:fixed;inset:0;background:rgba(0,0,0,0.5);z-index:1000;display:none;align-items:center;justify-content:center;">
    <div style="background:#fff;width:400px;border-radius:12px;padding:2rem;box-shadow:0 10px 25px rgba(0,0,0,0.2);">
        
        <!-- DuyAnhNgo- Tiêu đề Modal (Sẽ được JS tự động đổi tên tùy ngữ cảnh) -->
        <h3 id="report-modal-title" style="margin-top:0;font-family:'Inter',sans-serif;color:#ef4444;display:flex;align-items:center;gap:0.5rem;">
            <i class="fa-solid fa-triangle-exclamation"></i> Báo Cáo Sản Phẩm
        </h3>
        <p id="report-modal-desc" style="font-size:0.85rem;color:#64748b;margin-bottom:1rem;">Gửi báo cáo hỗ trợ cho sản phẩm này.</p>
        
        <!-- DuyAnhNgo- Thông tin đối tượng bị báo cáo (Lưu ngầm ID và Loại để JS xử lý) -->
        <div style="margin-bottom:1rem;">
            <label id="report-modal-target-label" style="display:block;font-size:0.85rem;font-weight:600;margin-bottom:0.4rem;color:#334155;">Sản phẩm</label>
            <input type="hidden" id="report-target-id" value="">
            <input type="hidden" id="report-target-type" value="PRODUCT">
            <div id="report-target-name" style="width:100%;padding:0.65rem;border-radius:8px;border:1px solid #cbd5e1;background:#f8fafb;font-family:'Inter';color:#334155;"></div>
        </div>

        <!-- DuyAnhNgo- Khu vực chứa các nút chọn Loại vi phạm (Được nạp bằng Javascript) -->
        <div style="margin-bottom:1rem;">
            <label style="display:block;font-size:0.85rem;font-weight:600;margin-bottom:0.4rem;color:#334155;">Loại vi phạm <span style="color:#ef4444">*</span></label>
            <div id="report-modal-reasons-container" style="display:grid;grid-template-columns:1fr 1fr;gap:0.5rem;">
                <!-- Radio buttons will be injected here by JS -->
            </div>
        </div>
        
        <div style="margin-bottom:1rem;">
            <label style="display:block;font-size:0.85rem;font-weight:600;margin-bottom:0.4rem;color:#334155;">Mức độ nghiêm trọng</label>
            <div style="display:flex;gap:1rem;">
                <label style="display:flex;align-items:center;gap:0.3rem;font-size:0.85rem;cursor:pointer;">
                    <input type="radio" name="report-priority-modal" value="Thấp"> Thấp
                </label>
                <label style="display:flex;align-items:center;gap:0.3rem;font-size:0.85rem;cursor:pointer;">
                    <input type="radio" name="report-priority-modal" value="Trung bình" checked> Trung bình
                </label>
                <label style="display:flex;align-items:center;gap:0.3rem;font-size:0.85rem;cursor:pointer;">
                    <input type="radio" name="report-priority-modal" value="Cao"> Cao
                </label>
                <label style="display:flex;align-items:center;gap:0.3rem;font-size:0.85rem;cursor:pointer;">
                    <input type="radio" name="report-priority-modal" value="Nghiêm trọng"> Nghiêm trọng
                </label>
            </div>
        </div>

        <div style="margin-bottom:1rem;">
            <label style="display:block;font-size:0.85rem;font-weight:600;margin-bottom:0.4rem;color:#334155;">Mã đơn hàng liên quan (nếu có)</label>
            <input type="text" id="report-order-id" style="width:100%;padding:0.65rem;border-radius:8px;border:1px solid #cbd5e1;font-family:'Inter';" placeholder="VD: 123">
        </div>

        <div style="margin-bottom:1.5rem;">
            <label style="display:block;font-size:0.85rem;font-weight:600;margin-bottom:0.4rem;color:#334155;">Lý do báo cáo</label>
            <textarea id="report-reason" rows="4" style="width:100%;padding:0.65rem;border-radius:8px;border:1px solid #cbd5e1;font-family:'Inter';resize:vertical;" placeholder="Nhập chi tiết vấn đề bạn gặp phải..."></textarea>
        </div>
        
        <div style="display:flex;gap:1rem;justify-content:flex-end;">
            <button onclick="closeReportModal()" style="padding:0.6rem 1.2rem;border-radius:8px;border:1px solid #cbd5e1;background:transparent;cursor:pointer;font-weight:600;color:#64748b;">Hủy</button>
            <button onclick="submitReport()" style="padding:0.6rem 1.2rem;border-radius:8px;border:none;background:#ef4444;color:#fff;cursor:pointer;font-weight:600;">Gửi Báo Cáo</button>
        </div>
    </div>
</div>

<script>
    // DuyAnhNgo- Hàm Bật Modal Đa Năng:
    // targetId: ID của Sản phẩm hoặc Cửa hàng
    // targetName: Tên của Sản phẩm hoặc Cửa hàng
    // type: 'PRODUCT' (Báo cáo SP) hoặc 'SHOP' (Tố cáo CH)
    function openReportModal(targetId, targetName, type = 'PRODUCT') {
        // Lưu thông tin gốc vào các input ẩn
        document.getElementById('report-target-id').value = targetId;
        document.getElementById('report-target-type').value = type;
        document.getElementById('report-target-name').textContent = targetName;
        document.getElementById('report-reason').value = '';
        
        // Đổi tên các nhãn trên giao diện
        let titleEl = document.getElementById('report-modal-title');
        let descEl = document.getElementById('report-modal-desc');
        let labelEl = document.getElementById('report-modal-target-label');
        let reasonsContainer = document.getElementById('report-modal-reasons-container');
        
        // Chuẩn bị danh sách lý do Tố cáo Shop
        let shopReasons = [
            {val: 'SellingRotten', text: 'Bán trái cây hỏng/thối'},
            {val: 'Chemicals', text: 'Trái cây ngâm hóa chất'},
            {val: 'UnderWeight', text: 'Cân điêu / Thiếu ký'},
            {val: 'LateDelivery', text: 'Giao trễ / Giao sai'},
            {val: 'BadAttitude', text: 'Thái độ phục vụ kém'},
            {val: 'Other', text: 'Khác'}
        ];
        
        // Chuẩn bị danh sách lý do Báo cáo SP
        let productReasons = [
            {val: 'Trái cây bị hỏng/thối', text: 'Trái cây hỏng/thối'},
            {val: 'Giao sai loại quả', text: 'Giao sai loại quả'},
            {val: 'Trái cây chưa chín/quá xanh', text: 'Trái cây chưa chín'},
            {val: 'Khác', text: 'Khác'}
        ];
        
        // Nạp HTML radio buttons tương ứng vào giao diện
        let reasons = type === 'SHOP' ? shopReasons : productReasons;
        let reasonsHtml = '';
        reasons.forEach((r, idx) => {
            reasonsHtml += '<label style="display:flex;align-items:center;gap:0.5rem;padding:0.5rem;border:1px solid #cbd5e1;border-radius:6px;cursor:pointer;">' +
                           '<input type="radio" name="report-type-modal" value="' + r.val + '" ' + (idx===0?'checked':'') + '> ' + r.text +
                           '</label>';
        });
        reasonsContainer.innerHTML = reasonsHtml;
        
        // Cập nhật Tiêu đề tùy theo ngữ cảnh
        if (type === 'SHOP') {
            titleEl.innerHTML = '<i class="fa-solid fa-flag"></i> Tố Cáo Cửa Hàng';
            descEl.textContent = 'Mô tả chi tiết vấn đề bạn gặp phải với cửa hàng này.';
            labelEl.textContent = 'Cửa hàng';
        } else {
            titleEl.innerHTML = '<i class="fa-solid fa-triangle-exclamation"></i> Báo Cáo Sản Phẩm';
            descEl.textContent = 'Gửi báo cáo hỗ trợ cho sản phẩm này.';
            labelEl.textContent = 'Sản phẩm';
        }
        
        document.getElementById('report-modal').style.display = 'flex';
    }

    function closeReportModal() {
        document.getElementById('report-modal').style.display = 'none';
    }

    // DuyAnhNgo- Hàm Bấm Nút Gửi Báo Cáo
    function submitReport() {
        let targetId = document.getElementById('report-target-id').value;
        let targetType = document.getElementById('report-target-type').value;
        let reason = document.getElementById('report-reason').value;
        
        let typeElement = document.querySelector('input[name="report-type-modal"]:checked');
        let reportType = typeElement ? typeElement.value : 'Khác';
        
        let priorityElement = document.querySelector('input[name="report-priority-modal"]:checked');
        let priorityStr = priorityElement ? priorityElement.value : 'Trung bình';
        
        // Chuyển mức độ thành số cho backend SubmitReportServlet
        let priorityNum = 2; // Default Trung bình
        if (priorityStr === 'Thấp') priorityNum = 1;
        if (priorityStr === 'Cao') priorityNum = 3;
        if (priorityStr === 'Nghiêm trọng') priorityNum = 4;
        
        let orderId = document.getElementById('report-order-id').value.trim();

        if (!targetId || !reason.trim()) {
            alert("Vui lòng nhập lý do báo cáo!");
            return;
        }
        
        let fd = new URLSearchParams();
        let endpoint = '';
        
        // DuyAnhNgo- RẼ NHÁNH: Xử lý theo 2 luồng riêng biệt
        if (targetType === 'SHOP') {
            // Luồng Tố cáo Cửa Hàng: Gửi dữ liệu dưới dạng JSON (create_ajax) về SubmitReportServlet
            endpoint = '<%= reportCtx %>/submit-report';
            fd.append('action', 'create_ajax');
            fd.append('shopId', targetId);
            fd.append('orderId', orderId);
            fd.append('reportType', reportType);
            fd.append('description', reason.trim());
            fd.append('priority', priorityNum);
        } else {
            // Luồng Báo cáo Sản Phẩm: Gộp tất cả thành 1 chuỗi 'reason' và gửi về ReportServlet (tạo Phòng chat)
            endpoint = '<%= reportCtx %>/report';
            let orderInfo = orderId ? " [Mã đơn: " + orderId + "]" : "";
            let finalReason = "[" + reportType + "] [Mức độ: " + priorityStr + "]" + orderInfo + " - " + reason.trim();
            fd.append('action', 'create');
            fd.append('productId', targetId);
            fd.append('reason', finalReason);
        }

        // Gọi AJAX ngầm lên server
        fetch(endpoint, {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: fd
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                alert(data.message || "Đã gửi báo cáo thành công! Vui lòng chờ Admin xác nhận.");
                closeReportModal();
            } else {
                alert(data.message || "Có lỗi xảy ra khi gửi báo cáo.");
            }
        });
    }
</script>
<% } %>
