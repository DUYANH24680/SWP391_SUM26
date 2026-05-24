package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

import model.Customer;
import service.CustomerService;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private CustomerService service = new CustomerService();

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Customer customer = service.login(username, password);

        if (customer != null) {
            HttpSession session = request.getSession();
            session.setAttribute("user", customer);

            response.sendRedirect("home.jsp");
        }else {
            request.setAttribute("error", "Sai tài khoản hoặc mật khẩu");
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}
}
