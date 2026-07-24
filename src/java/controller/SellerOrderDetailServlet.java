package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Order;
import model.OrderDetail;
import model.Product;
import model.Shop;
import model.DeliveryOrder;
import model.OrderTracking;
import model.SellerOrderActionResult;
import service.OrderService;
import service.DeliveryService;
import service.NotificationService;
import dao.ShopDAO;
import dao.ProductDAO;

import java.io.IOException;
import java.util.List;

/**
 * SellerOrderDetailServlet - Handles order detail view for sellers.
 * URL: /seller/order-detail?id={orderId}
 */
@WebServlet("/seller/order-detail")
public class SellerOrderDetailServlet extends HttpServlet {

    private static final String ROLE_SELLER = "seller";
    
    private OrderService orderService;
    private DeliveryService deliveryService;
    private NotificationService notificationService;

    @Override
    public void init() throws ServletException {
        this.orderService = new OrderService();
        this.deliveryService = new DeliveryService();
        this.notificationService = new NotificationService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        // Check authentication and seller role
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Account seller = (Account) session.getAttribute("Account");
        String sessionRole = (String) session.getAttribute("role");

        if (!ROLE_SELLER.equalsIgnoreCase(seller.getRoleName()) && !ROLE_SELLER.equalsIgnoreCase(sessionRole)) {
            session.setAttribute("error", "Bạn không có quyền truy cập trang này.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        // Validate order ID parameter
        String orderIdParam = req.getParameter("id");
        if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
            session.setAttribute("error", "ID đơn hàng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/seller/orders");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdParam.trim());
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID đơn hàng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/seller/orders");
            return;
        }

        try {
            // Check if seller has a shop
            System.out.println("[SellerOrderDetailServlet] Checking seller shop");
            ShopDAO shopDAO = new ShopDAO();
            Shop sellerShop = shopDAO.getShopByOwnerId(seller.getId());
            shopDAO.close();
            
            if (sellerShop == null || sellerShop.getStatus() != 1) {
                session.setAttribute("error", "Cửa hàng của bạn chưa được tạo hoặc chưa được phê duyệt.");
                resp.sendRedirect(req.getContextPath() + "/seller/orders");
                return;
            }

            // Get order details
            System.out.println("[SellerOrderDetailServlet] Getting order " + orderId);
            Order order = orderService.getOrderById(orderId);
            if (order == null) {
                session.setAttribute("error", "Đơn hàng không tồn tại.");
                resp.sendRedirect(req.getContextPath() + "/seller/orders");
                return;
            }

            // Get order items
            System.out.println("[SellerOrderDetailServlet] Getting order items");
            List<OrderDetail> orderItems = orderService.getOrderDetails(orderId);
            if (orderItems == null || orderItems.isEmpty()) {
                session.setAttribute("error", "Đơn hàng không có sản phẩm nào.");
                resp.sendRedirect(req.getContextPath() + "/seller/orders");
                return;
            }

            // Security: Validate seller ownership - seller can only view orders containing their products
            boolean canViewOrder = canSellerViewOrder(seller.getId(), sellerShop.getId(), orderItems);
            if (!canViewOrder) {
                session.setAttribute("error", "Bạn không có quyền xem đơn hàng này.");
                resp.sendRedirect(req.getContextPath() + "/seller/orders");
                return;
            }

            // Filter order items to show only products from seller's shop
            List<OrderDetail> sellerItems = filterSellerItems(sellerShop.getId(), orderItems);

            // Get delivery information (if exists)
            System.out.println("[SellerOrderDetailServlet] Getting delivery info");
            DeliveryOrder deliveryInfo = deliveryService.getDeliveryByOrderId(orderId);
            
            // Get tracking history
            System.out.println("[SellerOrderDetailServlet] Getting tracking history");
            List<OrderTracking> trackingHistory = deliveryService.getOrderTracking(orderId);

            // Calculate seller's portion of the order
            double sellerRevenue = calculateSellerRevenue(sellerItems);
            int sellerItemCount = sellerItems.size();

            // Set attributes for JSP
            req.setAttribute("order", order);
            req.setAttribute("orderItems", sellerItems); // Only seller's items
            req.setAttribute("allOrderItems", orderItems); // All items for context
            req.setAttribute("deliveryInfo", deliveryInfo);
            req.setAttribute("trackingHistory", trackingHistory);
            req.setAttribute("sellerShop", sellerShop);
            req.setAttribute("sellerRevenue", sellerRevenue);
            req.setAttribute("sellerItemCount", sellerItemCount);
            req.setAttribute("isMultiShopOrder", orderItems.size() > sellerItems.size());

            // Forward to seller order detail page
            req.getRequestDispatcher("/seller/order-detail.jsp").forward(req, resp);

        } catch (Exception e) {
            System.err.println("[SellerOrderDetailServlet] Error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi hệ thống. Vui lòng thử lại sau.");
            resp.sendRedirect(req.getContextPath() + "/seller/orders");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("Account") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Account seller = (Account) session.getAttribute("Account");

        if (!ROLE_SELLER.equalsIgnoreCase(seller.getRoleName())) {
            session.setAttribute("error", "Bạn không có quyền thực hiện hành động này.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        String action = req.getParameter("action");
        String orderIdParam = req.getParameter("orderId");

        if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
            session.setAttribute("error", "ID đơn hàng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/seller/orders");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdParam.trim());
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID đơn hàng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/seller/orders");
            return;
        }

        try {
            if ("confirm".equals(action) || "cancel".equals(action)) {
                // Use existing seller order action logic
                SellerOrderActionResult result = orderService.processSellerOrderAction(orderId, seller.getId(), action);
                session.setAttribute(result.isSuccess() ? "message" : "error", result.getMessage());

                // If order confirmed successfully → notify staff to assign shipper
                if (result.isSuccess() && "confirm".equals(action)) {
                    try {
                        ShopDAO shopDAO = new ShopDAO();
                        Shop shop = shopDAO.getShopByOwnerId(seller.getId());
                        shopDAO.close();
                        String shopName = (shop != null) ? shop.getShopName() : "Người bán";
                        notificationService.notifyStaffOrderConfirmed(orderId, shopName);
                    } catch (Exception ex) {
                        System.err.println("[SellerOrderDetailServlet] notifyStaffOrderConfirmed error: " + ex.getMessage());
                    }
                }
            } else {
                session.setAttribute("error", "Hành động không hợp lệ.");
            }

        } catch (Exception e) {
            System.err.println("[SellerOrderDetailServlet] POST error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Lỗi hệ thống. Vui lòng thử lại sau.");
        }

        // Redirect back to order detail
        resp.sendRedirect(req.getContextPath() + "/seller/order-detail?id=" + orderId);
    }

    /**
     * Check if seller can view this order (order contains at least one product from seller's shop).
     */
    private boolean canSellerViewOrder(int sellerId, int shopId, List<OrderDetail> orderItems) {
        if (orderItems == null || orderItems.isEmpty()) {
            return false;
        }
        for (OrderDetail item : orderItems) {
            if (item.getShopId() == shopId) {
                return true;
            }
        }
        // Fallback DB check if shopId in item is 0
        ProductDAO productDAO = new ProductDAO();
        try {
            for (OrderDetail item : orderItems) {
                Product product = productDAO.getProductById(item.getProductId());
                if (product != null && product.getShopId() == shopId) {
                    return true;
                }
            }
        } finally {
            productDAO.close();
        }
        return false;
    }

    /**
     * Filter order items to show only products from seller's shop.
     */
    private List<OrderDetail> filterSellerItems(int shopId, List<OrderDetail> allItems) {
        List<OrderDetail> sellerItems = new java.util.ArrayList<>();
        if (allItems == null || allItems.isEmpty()) {
            return sellerItems;
        }
        ProductDAO productDAO = null;
        try {
            for (OrderDetail item : allItems) {
                if (item.getShopId() > 0) {
                    if (item.getShopId() == shopId) {
                        sellerItems.add(item);
                    }
                } else {
                    if (productDAO == null) productDAO = new ProductDAO();
                    Product product = productDAO.getProductById(item.getProductId());
                    if (product != null && product.getShopId() == shopId) {
                        sellerItems.add(item);
                    }
                }
            }
        } finally {
            if (productDAO != null) productDAO.close();
        }
        return sellerItems;
    }

    /**
     * Calculate total revenue for seller's items in this order.
     */
    private double calculateSellerRevenue(List<OrderDetail> sellerItems) {
        double total = 0.0;
        for (OrderDetail item : sellerItems) {
            total += item.getTotalPrice();
        }
        return total;
    }

    @Override
    public void destroy() {
        if (orderService != null) {
            orderService.close();
        }
        if (deliveryService != null) {
            deliveryService.close();
        }
        if (notificationService != null) {
            notificationService.close();
        }
    }
}