<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Account" %>
<%
    Account reportUser = (Account) session.getAttribute("Account");
    String reportRole = reportUser != null ? reportUser.getRoleName() : "";
    if (reportRole == null) reportRole = "";
    String reportCtx = request.getContextPath();
%>
<% if ("customer".equalsIgnoreCase(reportRole)) { %>
<!-- REPORT MODAL INLINE (no fab) -->
<!-- REPORT MODAL -->
<div id="report-modal" style="position:fixed;inset:0;background:rgba(0,0,0,0.5);z-index:1000;display:none;align-items:center;justify-content:center;">
    <div style="background:#fff;width:400px;border-radius:12px;padding:2rem;box-shadow:0 10px 25px rgba(0,0,0,0.2);">
        <h3 style="margin-top:0;font-family:'Inter',sans-serif;color:#0f172a;display:flex;align-items:center;gap:0.5rem;">
            <i class="fa-solid fa-triangle-exclamation" style="color:#ef4444;"></i> Báo Cáo Sản Phẩm
        </h3>
        <p style="font-size:0.85rem;color:#64748b;margin-bottom:1rem;">Gửi báo cáo hỗ trợ cho sản phẩm này.</p>
        
        <div style="margin-bottom:1rem;">
            <label style="display:block;font-size:0.85rem;font-weight:600;margin-bottom:0.4rem;color:#334155;">Sản phẩm</label>
            <input type="hidden" id="report-product-id" value="">
            <div id="report-product-name" style="width:100%;padding:0.65rem;border-radius:8px;border:1px solid #cbd5e1;background:#f8fafb;font-family:'Inter';color:#334155;"></div>
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
    function openReportModal(productId, productName) {
        document.getElementById('report-product-id').value = productId;
        document.getElementById('report-product-name').textContent = productName;
        document.getElementById('report-reason').value = '';
        document.getElementById('report-modal').style.display = 'flex';
    }

    function closeReportModal() {
        document.getElementById('report-modal').style.display = 'none';
    }

    function submitReport() {
        let pid = document.getElementById('report-product-id').value;
        let reason = document.getElementById('report-reason').value;
        if (!pid || !reason.trim()) {
            alert("Vui lòng nhập lý do báo cáo!");
            return;
        }
        
        let fd = new URLSearchParams();
        fd.append('action', 'create');
        fd.append('productId', pid);
        fd.append('reason', reason);

        fetch('<%= reportCtx %>/report', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: fd
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                alert("Đã gửi báo cáo thành công! Vui lòng chờ Admin xác nhận.");
                closeReportModal();
            } else {
                alert("Có lỗi xảy ra khi gửi báo cáo.");
            }
        });
    }
</script>
<% } %>
