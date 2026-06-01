package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

import model.Customer;
import model.Seller;
import service.CustomerService;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private CustomerService service = new CustomerService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Customer customer = service.login(username, password);

        if (customer != null) {
            HttpSession session = request.getSession();

            if (customer.getRoleId() == 2) {
                Seller seller = toSeller(customer);
                session.setAttribute("account", seller);
            } else {
                session.setAttribute("user", customer);
            }

            response.sendRedirect("home.jsp");
        } else {
            request.setAttribute("error", "Sai tai khoan hoac mat khau");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    private Seller toSeller(Customer c) {
        Seller s = new Seller();
        s.setId(c.getId());
        s.setRoleId(c.getRoleId());
        s.setFullname(c.getFullname());
        s.setUsername(c.getUsername());
        s.setPasswordHash(c.getPasswordHash());
        s.setEmail(c.getEmail());
        s.setPhone(c.getPhone());
        s.setAddress(c.getAddress());
        s.setAvatar(c.getAvatar());
        s.setGender(c.getGender());
        s.setStatus(c.getStatus());
        s.setCreatedAt(c.getCreatedAt());
        return s;
    }
}
