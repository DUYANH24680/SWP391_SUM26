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

/**
 * AllNotificationsServlet - View full notification history page.
 */
@WebServlet("/notifications/all")
public class AllNotificationsServlet extends HttpServlet {

    private NotificationService notifService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Account user = (Account) session.getAttribute("Account");

        try {
            List<Notification> notifications = notifService.getAllByUserId(user.getId());
            int unreadCount = notifService.getUnreadCount(user.getId());

            req.setAttribute("notifications", notifications);
            req.setAttribute("unreadCount", unreadCount);
        } catch (Exception e) {
            System.err.println("[AllNotificationsServlet] Error: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("notifications", java.util.Collections.emptyList());
            req.setAttribute("unreadCount", 0);
        }

        req.getRequestDispatcher("/notifications-all.jsp").forward(req, resp);
    }
}
