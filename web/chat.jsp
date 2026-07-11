<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.ChatSession" %>
<%@ page import="model.Account" %>
<%
    List<ChatSession> sessions = (List<ChatSession>) request.getAttribute("sessions");
    Account currentUser = (Account) session.getAttribute("user");
    String ctx = request.getContextPath();
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
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .chat-item-last {
            font-size: 0.85rem;
            color: #b0b3b8;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
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
                    if ("customer".equals(currentUser.getRoleName())) {
                        title = s.getSellerName() + " & Admin";
                        avatar = s.getSellerAvatar() != null ? s.getSellerAvatar() : "https://ui-avatars.com/api/?name=S";
                    } else if ("seller".equals(currentUser.getRoleName())) {
                        title = s.getCustomerName() + " & Admin";
                        avatar = s.getCustomerAvatar() != null ? s.getCustomerAvatar() : "https://ui-avatars.com/api/?name=C";
                    } else {
                        title = s.getCustomerName() + " & " + s.getSellerName();
                        avatar = s.getCustomerAvatar() != null ? s.getCustomerAvatar() : "https://ui-avatars.com/api/?name=U";
                    }
            %>
            <div class="chat-item" onclick="loadMessages(<%= s.getId() %>, '<%= title %>', '<%= s.getProductName() %>')">
                <img src="<%= avatar %>" class="chat-avatar">
                <div class="chat-item-info">
                    <div class="chat-item-name"><%= title %></div>
                    <div class="chat-item-last"><%= s.getLastMessage() != null ? s.getLastMessage() : "Phòng chat đã tạo" %></div>
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

        function loadMessages(sessionId, title, product) {
            currentSessionId = sessionId;
            document.getElementById('emptyChat').style.display = 'none';
            document.getElementById('chatMain').style.display = 'flex';
            document.getElementById('headerTitle').innerText = title;
            document.getElementById('headerProduct').innerText = "Sản phẩm: " + product;
            
            // Highlight active session
            document.querySelectorAll('.chat-item').forEach(el => el.classList.remove('active'));
            event.currentTarget.classList.add('active');

            fetchMessages();

            if (fetchInterval) clearInterval(fetchInterval);
            fetchInterval = setInterval(fetchMessages, 2500); // Poll every 2.5s
        }

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
                        
                        html += `
                        <div class="message-row ` + (isMe ? 'me' : 'them') + `">
                            ` + (!isMe ? `<img src="${avatar}" class="message-avatar">` : '') + `
                            <div class="message-bubble">
                                ` + (!isMe ? `<span class="message-sender">${roleBadge}${m.senderName}</span>` : '') + `
                                ${m.message}
                            </div>
                        </div>`;
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

            fetch('<%= ctx %>/chat', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: fd
            }).then(() => fetchMessages()); // fetch immediately
        }
    </script>
</body>
</html>
