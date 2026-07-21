package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;

import java.io.IOException;

/**
 * Handles clicks from notifications or emails to /orders/{id}.
 * Redirects the user to their respective order dashboard based on role.
 */
@WebServlet("/orders/*")
public class OrderRedirectServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        Account user = (Account) session.getAttribute("Account");
        String role = user.getRoleName();
        
        // Extract order ID if any
        String pathInfo = req.getPathInfo(); // e.g. "/5"
        String orderId = "";
        if (pathInfo != null && pathInfo.length() > 1) {
            orderId = pathInfo.substring(1);
        }

        // Redirect based on role
        String redirectUrl = req.getContextPath();
        
        if ("customer".equalsIgnoreCase(role)) {
            redirectUrl += "/my-orders";
        } else if ("seller".equalsIgnoreCase(role)) {
            redirectUrl += "/seller/orders";
        } else if ("admin".equalsIgnoreCase(role)) {
            redirectUrl += "/admin/orders";
        } else if ("staff".equalsIgnoreCase(role)) {
            redirectUrl += "/staff/orders-waiting";
        } else {
            redirectUrl += "/home.jsp"; // Default fallback
        }

        resp.sendRedirect(redirectUrl);
    }
}
