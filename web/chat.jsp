<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.ChatSession" %>
<%@ page import="model.Account" %>
<%
    List<ChatSession> sessions = (List<ChatSession>) request.getAttribute("sessions");
    Account currentUser = (Account) session.getAttribute("user");
    String ctx = request.getContextPath();
%>
<%!
    // Hàm hỗ trợ sửa lỗi avatar và chuỗi null
    public String safeAvatar(String avatar, String defaultLetter, String ctx) {
        if (avatar == null || avatar.trim().isEmpty() || avatar.equals("null")) {
            return "https://ui-avatars.com/api/?name=" + defaultLetter + "&background=random";
        }
        if (avatar.startsWith("http")) return avatar;
        if (avatar.startsWith("uploads/")) {
            try { return ctx + "/image?path=" + java.net.URLEncoder.encode(avatar.trim(), "UTF-8"); } 
            catch (Exception e) { return ctx + "/" + avatar; }
        }
        return ctx + "/" + avatar;
    }
    
    public String safeName(String name) {
        if (name == null || name.equals("null")) return "Người dùng";
        return name;
    }
    
    public String escapeJs(String str) {
        if (str == null || str.equals("null")) return "";
        return str.replace("'", "\\'").replace("\"", "&quot;");
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hỗ Trợ & Khiếu Nại</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body {
            margin: 0; padding: 0;
            font-family: 'Inter', sans-serif;
            background-color: #1e1e20;
            color: #e4e6eb;
            display: flex;
            height: 100vh;
            overflow: hidden;
        }

        /* Sidebar - Chat List */
        .chat-sidebar {
            width: 350px;
            background-color: #242526;
            border-right: 1px solid #393a3b;
            display: flex;
            flex-direction: column;
        }
        .chat-header {
            padding: 20px;
            font-size: 1.5rem;
            font-weight: 700;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .chat-header a { color: #e4e6eb; text-decoration: none; }
        .chat-list {
            flex: 1;
            overflow-y: auto;
        }
        .chat-item {
            display: flex;
            align-items: center;
            padding: 12px 20px;
            cursor: pointer;
            transition: background 0.2s;
            text-decoration: none;
            color: inherit;
        }
        .chat-item:hover { background-color: #3a3b3c; }
        .chat-item.active { background-color: #252f3c; }
        .chat-avatar {
            width: 50px; height: 50px;
            border-radius: 50%;
            object-fit: cover;
            margin-right: 12px;
        }
        .chat-item-info { flex: 1; overflow: hidden; }
        .chat-item-name {
            font-weight: 600;
            margin-bottom: 4px;
            word-break: break-word;
        }
        .chat-item-last {
            font-size: 0.85rem;
            color: #b0b3b8;
            word-break: break-word;
        }

        /* Main Chat Area */
        .chat-main {
            flex: 1;
            display: flex;
            flex-direction: column;
            background-color: #242526;
        }
        .chat-main-header {
            height: 70px;
            border-bottom: 1px solid #393a3b;
            display: flex;
            align-items: center;
            padding: 0 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .chat-main-avatar {
            width: 40px; height: 40px;
            border-radius: 50%;
            margin-right: 12px;
        }
        .chat-main-name { font-weight: 600; font-size: 1.1rem; }
        .chat-main-product { font-size: 0.85rem; color: #b0b3b8; margin-top: 2px; }
        
        .chat-report-card {
            background-color: #2c2d2f;
            border-left: 4px solid #ef4444;
            margin: 15px 20px 0 20px;
            padding: 15px 20px;
            border-radius: 6px;
            display: none;
        }
        .chat-report-card-title {
            font-size: 0.9rem;
            color: #ef4444;
            font-weight: 600;
            text-transform: uppercase;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .chat-report-card-content {
            font-size: 0.95rem;
            color: #e4e6eb;
            line-height: 1.6;
        }
        
        .chat-messages {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
        .message-row { display: flex; align-items: flex-end; }
        .message-row.me { justify-content: flex-end; }
        .message-avatar {
            width: 28px; height: 28px;
            border-radius: 50%;
            margin: 0 8px;
        }
        .message-bubble {
            max-width: 60%;
            padding: 10px 15px;
            border-radius: 18px;
            font-size: 0.95rem;
            line-height: 1.4;
            position: relative;
            word-break: break-word;
            overflow-wrap: break-word;
        }
        /* My message */
        .message-row.me .message-bubble {
            background-color: #0084ff;
            color: white;
            border-bottom-right-radius: 4px;
        }
        /* Their message */
        .message-row.them .message-bubble {
            background-color: #3e4042;
            color: #e4e6eb;
            border-bottom-left-radius: 4px;
        }
        .message-sender {
            font-size: 0.75rem;
            color: #b0b3b8;
            margin-bottom: 4px;
            display: block;
        }

        /* Input Area */
        .chat-input-area {
            padding: 15px 20px;
            display: flex;
            align-items: center;
            background-color: #242526;
        }
        .chat-input-wrapper {
            flex: 1;
            background-color: #3a3b3c;
            border-radius: 20px;
            display: flex;
            align-items: center;
            padding: 8px 15px;
        }
        .chat-input {
            flex: 1;
            background: transparent;
            border: none;
            color: #e4e6eb;
            font-size: 0.95rem;
            outline: none;
            font-family: 'Inter', sans-serif;
        }
        .chat-send-btn {
            background: transparent;
            border: none;
            color: #0084ff;
            font-size: 1.2rem;
            cursor: pointer;
            margin-left: 10px;
        }
        .chat-send-btn:hover { color: #0073e6; }
        
        .empty-chat {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            color: #b0b3b8;
        }

        /* Custom scrollbar */
        ::-webkit-scrollbar { width: 8px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: #4e4f50; border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: #666768; }
    </style>
</head>
<body>

    <!-- SIDEBAR -->
    <div class="chat-sidebar">
        <div class="chat-header">
            Đoạn chat
            <a href="<%= ctx %>/profile"><i class="fa-solid fa-arrow-left" style="font-size:1.2rem;color:#b0b3b8;"></i></a>
        </div>
        <div class="chat-list" id="chatList">
            <% if (sessions != null) {
                for (ChatSession s : sessions) {
                    String title = "";
                    String avatar = "";
                    
                    String cName = safeName(s.getCustomerName());
                    String sName = safeName(s.getSellerName());
                    
                    if ("customer".equals(currentUser.getRoleName())) {
                        title = sName + " & Admin";
                        avatar = safeAvatar(s.getSellerAvatar(), "S", ctx);
                    } else if ("seller".equals(currentUser.getRoleName())) {
                        title = cName + " & Admin";
                        avatar = safeAvatar(s.getCustomerAvatar(), "C", ctx);
                    } else {
                        title = cName + " & " + sName;
                        avatar = safeAvatar(s.getCustomerAvatar(), "U", ctx);
                    }
                    
                    String lastMsg = s.getLastMessage() != null && !s.getLastMessage().equals("null") ? s.getLastMessage() : "Phòng chat đã tạo";
                    String reason = s.getReportReason() != null ? s.getReportReason() : "Chưa cập nhật lý do";
            %>
            <div class="chat-item" onclick="loadMessages(<%= s.getId() %>, '<%= escapeJs(title) %>', '<%= escapeJs(s.getProductName()) %>', '<%= escapeJs(reason) %>')">
                <img src="<%= avatar %>" class="chat-avatar" onerror="this.src='https://ui-avatars.com/api/?name=U'">
                <div class="chat-item-info">
                    <div class="chat-item-name"><%= title %></div>
                    <div class="chat-item-last"><%= lastMsg %></div>
                </div>
            </div>
            <% } } %>
        </div>
    </div>

    <!-- MAIN CHAT -->
    <div class="chat-main" id="chatMain" style="display:none;">
        <div class="chat-main-header">
            <div>
                <div class="chat-main-name" id="headerTitle">...</div>
                <div class="chat-main-product" id="headerProduct">Sản phẩm: ...</div>
            </div>
        </div>
        
        <!-- DuyAnhNgo- Thẻ hiển thị Lý do Báo cáo (Ẩn mặc định, chỉ hiện khi có dữ liệu) -->
        <div class="chat-report-card" id="chatReportCard">
            <div class="chat-report-card-title">
                <i class="fa-solid fa-triangle-exclamation"></i> Thông tin Tố cáo / Báo cáo
            </div>
            <div class="chat-report-card-content" id="reportReasonText">...</div>
        </div>
        
        <div class="chat-messages" id="messagesArea">
            <!-- Messages load here -->
        </div>

        <div class="chat-input-area">
            <div class="chat-input-wrapper">
                <input type="text" class="chat-input" id="messageInput" placeholder="Aa" onkeypress="handleKeyPress(event)">
            </div>
            <button class="chat-send-btn" onclick="sendMessage()"><i class="fa-solid fa-paper-plane"></i></button>
        </div>
    </div>
    
    <div class="empty-chat" id="emptyChat">
        <i class="fa-brands fa-facebook-messenger" style="font-size: 5rem; margin-bottom: 20px; color: #3e4042;"></i>
        <h2>Chọn một đoạn chat để bắt đầu</h2>
    </div>

    <script>
        let currentSessionId = null;
        let myUserId = <%= currentUser.getId() %>;
        let fetchInterval = null;

        // DuyAnhNgo- Hàm chạy khi người dùng Bấm vào một phòng chat ở cột bên trái
        // Nhiệm vụ: Ẩn màn hình trống đi, hiện khung chat lên, đổi tên tiêu đề và gọi API lấy tin nhắn
        function loadMessages(sessionId, title, product, reason) {
            currentSessionId = sessionId;
            document.getElementById('emptyChat').style.display = 'none';
            document.getElementById('chatMain').style.display = 'flex';
            document.getElementById('headerTitle').innerText = title;
            document.getElementById('headerProduct').innerText = "Sản phẩm: " + product;
            
            // DuyAnhNgo- Hiển thị Card lý do báo cáo
            if (reason && reason !== 'Chưa cập nhật lý do') {
                document.getElementById('chatReportCard').style.display = 'block';
                
                // DuyAnhNgo- Format lại chuỗi lý do: Tách chuỗi thành nhiều dòng (Thay thế "] [" thành "] <br>&bull; [")
                // Ví dụ: "[Hàng giả] [Mức độ: Cao] - Kém chất lượng" -> 3 dòng có dấu chấm tròn
                let formattedReason = reason;
                if (formattedReason.startsWith("[")) {
                    formattedReason = formattedReason.replace(/\] \[/g, "]<br>&bull; [");
                    formattedReason = formattedReason.replace(/\] - /g, "]<br>&bull; <b>Chi tiết:</b> ");
                    formattedReason = "&bull; " + formattedReason;
                }
                
                document.getElementById('reportReasonText').innerHTML = formattedReason;
            } else {
                document.getElementById('chatReportCard').style.display = 'none';
            }
            
            // Highlight active session
            document.querySelectorAll('.chat-item').forEach(el => el.classList.remove('active'));
            event.currentTarget.classList.add('active');

            // DuyAnhNgo- Gọi API lần đầu để lấy tin nhắn ngay lập tức
            fetchMessages();

            // DuyAnhNgo- Quan trọng: Cứ mỗi 2.5 giây lại tự động gọi API 1 lần để lôi tin nhắn mới về (Polling)
            if (fetchInterval) clearInterval(fetchInterval);
            fetchInterval = setInterval(fetchMessages, 2500); // Poll every 2.5s
        }

        // DuyAnhNgo- Hàm lấy tin nhắn: Gọi AJAX GET đến /chat?action=getMessages để lấy file JSON
        function fetchMessages() {
            if (!currentSessionId) return;
            fetch('<%= ctx %>/chat?action=getMessages&sessionId=' + currentSessionId)
                .then(res => res.json())
                .then(data => {
                    let html = '';
                    data.forEach(m => {
                        let isMe = m.senderId === myUserId;
                        let roleBadge = m.senderRole === 'admin' ? '<span style="color:#ef4444">[Admin] </span>' : '';
                        let avatar = m.senderAvatar || 'https://ui-avatars.com/api/?name=' + m.senderName;
                        
                        html += '<div class="message-row ' + (isMe ? 'me' : 'them') + '">' +
                                (!isMe ? '<img src="' + avatar + '" class="message-avatar" onerror="this.src=\\\'https://ui-avatars.com/api/?name=U\\\';">' : '') +
                                '<div class="message-bubble">' +
                                (!isMe ? '<span class="message-sender">' + roleBadge + (m.senderName || 'Người dùng') + '</span>' : '') +
                                (m.message || '') +
                                '</div></div>';
                    });
                    
                    let box = document.getElementById('messagesArea');
                    let isScrolledToBottom = box.scrollHeight - box.clientHeight <= box.scrollTop + 50;
                    box.innerHTML = html;
                    if (isScrolledToBottom) {
                        box.scrollTop = box.scrollHeight;
                    }
                });
        }

        function handleKeyPress(e) {
            if (e.key === 'Enter') sendMessage();
        }

        function sendMessage() {
            let input = document.getElementById('messageInput');
            let msg = input.value.trim();
            if (!msg || !currentSessionId) return;
            input.value = '';

            let fd = new URLSearchParams();
            fd.append('action', 'sendMessage');
            fd.append('sessionId', currentSessionId);
            fd.append('message', msg);

            // DuyAnhNgo- Dùng fetch API gửi gói tin POST chứa action=sendMessage lên ChatServlet
            fetch('<%= ctx %>/chat', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: fd
            }).then(() => fetchMessages()); // fetch immediately
        }
    </script>
</body>
</html>
