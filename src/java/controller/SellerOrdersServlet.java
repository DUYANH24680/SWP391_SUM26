package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Seller;

import java.io.IOException;

@WebServlet("/seller/orders")
public class SellerOrdersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isSellerLoggedIn(session)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        request.getRequestDispatcher("/seller/orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/seller/orders");
    }

    private boolean isSellerLoggedIn(HttpSession session) {
        if (session == null) return false;
        Object account = session.getAttribute("account");
        if (account instanceof Seller) return true;
        Object user = session.getAttribute("user");
        return user instanceof Seller;
    }
}
