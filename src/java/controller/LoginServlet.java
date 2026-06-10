package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

import model.User;
import service.UserService;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private UserService service = new UserService();
     
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        User user = service.login(username, password);

        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("user", user);

            response.sendRedirect("home.jsp");
        } else {
            request.setAttribute("error", "Sai tài khoản hoặc mật khẩu");
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}
}
