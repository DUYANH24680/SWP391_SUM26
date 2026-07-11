package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.AdminOrdersData;
import service.OrderService;

import java.io.IOException;
import java.sql.Date;

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

        OrderService orderService = new OrderService();

        try {
            Integer status = null;
            Integer shopId = null;
            Date fromDate = null;
            Date toDate = null;
            Double minValue = null;
            Double maxValue = null;
            int page = 1;
            int pageSize = 15;

            String statusParam = req.getParameter("status");
            String shopIdParam = req.getParameter("shopId");
            String fromParam = req.getParameter("fromDate");
            String toParam = req.getParameter("toDate");
            String minValParam = req.getParameter("minValue");
            String maxValParam = req.getParameter("maxValue");
            String pageParam = req.getParameter("page");
            String pageSizeParam = req.getParameter("pageSize");

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
            if (pageParam != null && !pageParam.trim().isEmpty()) {
                try { page = Math.max(1, Integer.parseInt(pageParam.trim())); } catch (NumberFormatException ignored) {}
            }
            if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) {
                try { pageSize = Math.max(1, Math.min(100, Integer.parseInt(pageSizeParam.trim()))); } catch (NumberFormatException ignored) {}
            }

            AdminOrdersData adminOrdersData = orderService.getAdminOrdersData(status, shopId, fromDate, toDate, minValue, maxValue, page, pageSize);

            req.setAttribute("orders", adminOrdersData.getOrders());
            req.setAttribute("detailsMap", adminOrdersData.getDetailsMap());
            req.setAttribute("shops", adminOrdersData.getShops());
            req.setAttribute("filterStatus", statusParam);
            req.setAttribute("filterShopId", shopIdParam);
            req.setAttribute("filterFromDate", fromParam);
            req.setAttribute("filterToDate", toParam);
            req.setAttribute("filterMinValue", minValParam);
            req.setAttribute("filterMaxValue", maxValParam);
            req.setAttribute("currentPage", adminOrdersData.getCurrentPage());
            req.setAttribute("totalPages", adminOrdersData.getTotalPages());
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("totalOrders", adminOrdersData.getTotalOrders());

            req.getRequestDispatcher("/admin/orders.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }
}

