package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Notification;
import service.NotificationService;
import java.io.IOException;
import java.util.List;

@WebServlet("/notifications/all")
public class AllNotificationsServlet extends HttpServlet {

    private NotificationService notifService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Account user = (Account) session.getAttribute("Account");
        
        try {
            // Get last 100 notifications for the user
            List<Notification> notifications = notifService.getByUserId(user.getId(), 100);
            request.setAttribute("notificationsList", notifications);
            
            // Forward to JSP
            request.getRequestDispatcher("/notifications.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("[AllNotificationsServlet] Error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Không thể tải thông báo: " + e.getMessage());
            request.getRequestDispatcher("/home.jsp").forward(request, response);
        }
    }
}
