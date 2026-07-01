package controller;

import dao.OrderDAO;
import dao.ShopDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Order;
import model.OrderDetail;
import model.Shop;

import java.io.IOException;
import java.sql.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/orders")
public class AdminOrdersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Account user = (Account) session.getAttribute("user");
        if (!"admin".equalsIgnoreCase(user.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        ShopDAO shopDAO = new ShopDAO();

        try {
            Integer status = null;
            Integer shopId = null;
            Date fromDate = null;
            Date toDate = null;
            Double minValue = null;
            Double maxValue = null;

            String statusParam = req.getParameter("status");
            String shopIdParam = req.getParameter("shopId");
            String fromParam = req.getParameter("fromDate");
            String toParam = req.getParameter("toDate");
            String minValParam = req.getParameter("minValue");
            String maxValParam = req.getParameter("maxValue");

            if (statusParam != null && !statusParam.trim().isEmpty() && !"all".equals(statusParam.trim())) {
                try { status = Integer.parseInt(statusParam.trim()); } catch (NumberFormatException ignored) {}
            }
            if (shopIdParam != null && !shopIdParam.trim().isEmpty()) {
                try { shopId = Integer.parseInt(shopIdParam.trim()); } catch (NumberFormatException ignored) {}
            }
            if (fromParam != null && !fromParam.trim().isEmpty()) {
                try { fromDate = Date.valueOf(fromParam.trim()); } catch (IllegalArgumentException ignored) {}
            }
            if (toParam != null && !toParam.trim().isEmpty()) {
                try { toDate = Date.valueOf(toParam.trim()); } catch (IllegalArgumentException ignored) {}
            }
            if (minValParam != null && !minValParam.trim().isEmpty()) {
                try { minValue = Double.parseDouble(minValParam.trim().replace(",", "")); } catch (NumberFormatException ignored) {}
            }
            if (maxValParam != null && !maxValParam.trim().isEmpty()) {
                try { maxValue = Double.parseDouble(maxValParam.trim().replace(",", "")); } catch (NumberFormatException ignored) {}
            }

            List<Order> orders = orderDAO.getAllOrdersForAdmin(status, shopId, fromDate, toDate, minValue, maxValue);
            Map<Integer, List<OrderDetail>> detailsMap = new HashMap<>();
            for (Order o : orders) {
                detailsMap.put(o.getId(), orderDAO.getOrderDetails(o.getId()));
            }

            List<Shop> shops = shopDAO.getAllShops();

            req.setAttribute("orders", orders);
            req.setAttribute("detailsMap", detailsMap);
            req.setAttribute("shops", shops);
            req.setAttribute("filterStatus", statusParam);
            req.setAttribute("filterShopId", shopIdParam);
            req.setAttribute("filterFromDate", fromParam);
            req.setAttribute("filterToDate", toParam);
            req.setAttribute("filterMinValue", minValParam);
            req.setAttribute("filterMaxValue", maxValParam);

            req.getRequestDispatcher("/admin/orders.jsp").forward(req, resp);
        } finally {
            orderDAO.close();
            shopDAO.close();
        }
    }
}
