package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.*;
import java.util.stream.Collectors;

import dao.ShopDAO;
import dao.AccountDAO;
import dao.OrderDAO;
import dao.ProductDAO;
import dao.UserReportDAO;
import dao.SellerActionDAO;
import model.Account;
import model.Order;
import model.Shop;
import model.UserReport;
import model.SellerAction;

/**
 * Admin: Manage Sellers — central dashboard for monitoring all sellers/shops.
 * GET  /admin/sellers              — list all sellers with stats
 * GET  /admin/sellers?detail=ID   — view specific seller detail + report history
 * POST /admin/sellers              — actions: warn | temp_suspend | lift_suspend | block | unblock
 */
@WebServlet(name = "ManageSellerServlet", urlPatterns = {"/admin/sellers"})
public class ManageSellerServlet extends HttpServlet {

    private final ShopDAO shopDAO         = new ShopDAO();
    private final AccountDAO accountDAO   = new AccountDAO();
    private final OrderDAO orderDAO       = new OrderDAO();
    private final ProductDAO productDAO   = new ProductDAO();
    private final UserReportDAO reportDAO = new UserReportDAO();
    private final SellerActionDAO actionDAO = new SellerActionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        guard(req, resp);

        String detailId = req.getParameter("detail");
        String keyword   = req.getParameter("search");
        String filter    = req.getParameter("filter");
        if (filter == null) filter = "all";

        if (detailId != null && !detailId.isEmpty()) {
            // ---- DETAIL VIEW ----
            int shopId = parseInt(detailId);
            if (shopId <= 0) {
                resp.sendRedirect(req.getContextPath() + "/admin/sellers");
                return;
            }
            handleDetailView(req, shopId);
        } else {
            // ---- LIST VIEW ----
            handleListView(req, keyword, filter);
        }

        req.getRequestDispatcher("/admin/sellers.jsp").forward(req, resp);
    }

    private void handleDetailView(HttpServletRequest req, int shopId) throws ServletException {
        Shop shop = shopDAO.getShopById(shopId);
        if (shop == null) {
            req.setAttribute("error", "Không tìm thấy cửa hàng.");
            return;
        }
        // Load owner info
        List<Shop> temp = shopDAO.getAllShopsWithOwner().stream()
                .filter(s -> s.getId() == shopId).collect(Collectors.toList());
        if (!temp.isEmpty()) {
            Shop s = temp.get(0);
            shop.setOwnerFullname(s.getOwnerFullname());
            shop.setOwnerEmail(s.getOwnerEmail());
            shop.setOwnerPhone(s.getOwnerPhone());
            shop.setOwnerAccountStatus(s.getOwnerAccountStatus());
        }

        // Stats
        int productCount = productDAO.countProductsByShopId(shopId);
        List<Order> orders = orderDAO.getOrdersByShopId(shopId);
        int orderCount = orders.size();
        double revenue = orders.stream()
                .filter(o -> o.getStatus() == 4)
                .mapToDouble(Order::getShopActualRevenue)
                .sum(); 

        // Reports
        List<UserReport> reports = reportDAO.getByShopId(shopId, null);
        int pendingReports = (int) reports.stream().filter(UserReport::isPending).count();

        // Seller actions history
        List<SellerAction> actions = actionDAO.getByShopId(shopId);
        int warnCount = actionDAO.countWarnsByShopId(shopId);
        int blockCount = actionDAO.countBlocksByShopId(shopId);
        boolean isSuspended = actionDAO.hasActiveSuspension(shopId);
        SellerAction latestAction = actionDAO.getLatestByShopId(shopId);

        req.setAttribute("detailShop", shop);
        req.setAttribute("productCount", productCount);
        req.setAttribute("orderCount", orderCount);
        req.setAttribute("totalRevenue", revenue);
        req.setAttribute("reports", reports);
        req.setAttribute("pendingReports", pendingReports);
        req.setAttribute("actionHistory", actions);
        req.setAttribute("warnCount", warnCount);
        req.setAttribute("blockCount", blockCount);
        req.setAttribute("isSuspended", isSuspended);
        req.setAttribute("latestAction", latestAction);
    }

    private void handleListView(HttpServletRequest req, String keyword, String filter) {
        List<Shop> shops;
        if (keyword != null && !keyword.trim().isEmpty()) {
            shops = shopDAO.searchSellers(keyword.trim());
        } else if ("active".equals(filter)) {
            shops = shopDAO.getAllShopsWithOwner().stream()
                    .filter(s -> s.isActive() && !actionDAO.hasActiveSuspension(s.getId()))
                    .collect(Collectors.toList());
        } else if ("blocked".equals(filter)) {
            shops = shopDAO.getAllShopsWithOwner().stream()
                    .filter(Shop::isBlocked).collect(Collectors.toList());
        } else if ("suspended".equals(filter)) {
            shops = shopDAO.getAllShopsWithOwner().stream()
                    .filter(s -> actionDAO.hasActiveSuspension(s.getId()))
                    .collect(Collectors.toList());
        } else {
            // "all" filter: return all shops including active, suspended, and blocked
            shops = shopDAO.getAllShopsWithOwner();
        }

        // Attach stats per shop
        List<Map<String, Object>> dashboardList = new ArrayList<>();
        for (Shop shop : shops) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("shop", shop);
            item.put("productCount", productDAO.countProductsByShopId(shop.getId()));
            item.put("orderCount", orderDAO.getOrdersByShopId(shop.getId()).size());
            item.put("pendingReports", reportDAO.countPendingByShopId(shop.getId()));
            item.put("warnCount", actionDAO.countWarnsByShopId(shop.getId()));
            item.put("blockCount", actionDAO.countBlocksByShopId(shop.getId()));
            item.put("isSuspended", actionDAO.hasActiveSuspension(shop.getId()));
            item.put("latestAction", actionDAO.getLatestByShopId(shop.getId()));
            dashboardList.add(item);
        }

        req.setAttribute("dashboardList", dashboardList);
        req.setAttribute("keyword", keyword != null ? keyword : "");
        req.setAttribute("filter", filter);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        guard(req, resp);

        HttpSession session = req.getSession();
        String action = req.getParameter("action");
        int shopId = parseInt(req.getParameter("shopId"));
        String reason = req.getParameter("reason");
        String note = req.getParameter("note");
        String suspendDaysStr = req.getParameter("suspendDays");
        String detailShopId = req.getParameter("detailShopId");

        // If came from detail page, redirect back to detail
        String redirectSuffix = (detailShopId != null && !detailShopId.isEmpty())
                ? "?detail=" + detailShopId : "";
        String base = req.getContextPath() + "/admin/sellers" + redirectSuffix;

        if (shopId <= 0) {
            session.setAttribute("error", "ID cửa hàng không hợp lệ.");
            resp.sendRedirect(base);
            return;
        }

        if (reason == null || reason.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng nhập lý do hành động.");
            resp.sendRedirect(base);
            return;
        }

        Shop shop = shopDAO.getShopById(shopId);
        if (shop == null) {
            session.setAttribute("error", "Không tìm thấy cửa hàng.");
            resp.sendRedirect(req.getContextPath() + "/admin/sellers");
            return;
        }

        Account admin = (Account) session.getAttribute("user");
        SellerAction logAction = new SellerAction();
        logAction.setShopId(shopId);
        logAction.setSellerId(shop.getOwnerId());
        logAction.setReason(reason.trim());
        logAction.setNote(note != null ? note.trim() : null);
        logAction.setPerformedBy(admin.getId());

        boolean success = false;
        String successMsg = "";
        String errorMsg = "";

        try {
            switch (action) {
                case "warn": {
                    logAction.setActionType("warn");
                    actionDAO.insert(logAction);
                    success = true;
                    successMsg = "Đã gửi cảnh cáo đến shop [" + shop.getShopName() + "].";
                    break;
                }
                case "temp_suspend": {
                    int days = 7;
                    try { days = Integer.parseInt(suspendDaysStr); } catch (Exception ignored) {}
                    if (days < 1) days = 7;
                    if (days > 90) days = 90;
                    long ms = System.currentTimeMillis() + (days * 24L * 3600L * 1000L);
                    logAction.setActionType("temp_suspend");
                    logAction.setSuspendUntil(new Timestamp(ms));
                    actionDAO.insert(logAction);
                    shopDAO.suspendShop(shopId);
                    accountDAO.updateAccountStatus(shop.getOwnerId(), 0);
                    success = true;
                    successMsg = "Đã khóa tạm shop [" + shop.getShopName() + "] trong " + days + " ngày.";
                    break;
                }
                case "lift_suspend": {
                    logAction.setActionType("temp_suspend_end");
                    actionDAO.insert(logAction);
                    shopDAO.endSuspension(shopId);
                    accountDAO.updateAccountStatus(shop.getOwnerId(), 1);
                    success = true;
                    successMsg = "Đã kết thúc khóa tạm của shop [" + shop.getShopName() + "].";
                    break;
                }
                case "block": {
                    logAction.setActionType("block");
                    actionDAO.insert(logAction);
                    shopDAO.blockShop(shopId);
                    accountDAO.updateAccountStatus(shop.getOwnerId(), 0);
                    success = true;
                    successMsg = "Đã khóa vĩnh viễn shop [" + shop.getShopName() + "].";
                    break;
                }
                case "unblock": {
                    logAction.setActionType("unblock");
                    actionDAO.insert(logAction);
                    shopDAO.unblockShop(shopId);
                    accountDAO.updateAccountStatus(shop.getOwnerId(), 1);
                    success = true;
                    successMsg = "Đã mở khóa shop [" + shop.getShopName() + "].";
                    break;
                }
                default: {
                    session.setAttribute("error", "Hành động không hợp lệ.");
                    resp.sendRedirect(base);
                    return;
                }
            }
        } catch (Exception e) {
            session.setAttribute("error", "Lỗi xử lý: " + e.getMessage());
            resp.sendRedirect(base);
            return;
        }

        if (success) {
            session.setAttribute("message", successMsg);
        } else {
            session.setAttribute("error", errorMsg.isEmpty() ? "Thao tác thất bại." : errorMsg);
        }
        resp.sendRedirect(base);
    }

    private void guard(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        Account user = (Account) (session != null ? session.getAttribute("user") : null);
        if (user == null || !"admin".equals(user.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
        }
    }

    private int parseInt(String s) {
        try { return Integer.parseInt(s.trim()); } catch (Exception e) { return -1; }
    }
}
