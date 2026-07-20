package service;

import dao.CartDAO;
import dao.CartItemDAO;
import dao.ProductDAO;
import dao.VoucherDAO;
import model.Cart;
import model.CartItem;
import model.Product;
import model.Voucher;
import model.ReorderResult;
import dao.OrderDAO;
import model.Order;
import model.OrderDetail;
import java.util.ArrayList;
import java.util.List;

public class CartService {

    private CartDAO cartDAO;
    private CartItemDAO cartItemDAO;
    private ProductDAO productDAO;
    private VoucherDAO voucherDAO;

    public CartService() {
        this.cartDAO = new CartDAO();
        this.cartItemDAO = new CartItemDAO();
        this.productDAO = new ProductDAO();
        this.voucherDAO = new VoucherDAO();
    }

    public void close() {
        if (cartDAO != null) {
            try { cartDAO.close(); } catch (Exception ignored) {}
            cartDAO = null;
        }
        if (cartItemDAO != null) {
            try { cartItemDAO.close(); } catch (Exception ignored) {}
            cartItemDAO = null;
        }
        if (productDAO != null) {
            try { productDAO.close(); } catch (Exception ignored) {}
            productDAO = null;
        }
        if (voucherDAO != null) {
            try { voucherDAO.close(); } catch (Exception ignored) {}
            voucherDAO = null;
        }
    }

    public Cart getCartByCustomerId(int customerId) {
        if (customerId <= 0) return null;
        return cartDAO.getCartByCustomerId(customerId);
    }

    public Cart addToCart(int customerId, int productId, int quantity,
                          String voucherCode, String note) {
        if (customerId <= 0) {
            throw new IllegalArgumentException("Vui lòng đăng nhập để tiếp tục.");
        }
        if (productId <= 0) {
            throw new IllegalArgumentException("Sản phẩm không hợp lệ.");
        }
        if (quantity <= 0) {
            throw new IllegalArgumentException("Số lượng phải lớn hơn 0.");
        }

        Product product = productDAO.getProductById(productId);
        if (product == null || product.isIsDelete()) {
            throw new IllegalArgumentException("Sản phẩm không tồn tại.");
        }
        if (!product.isActive()) {
            throw new IllegalArgumentException("Sản phẩm hiện tại không hoạt động.");
        }
        if (quantity > product.getStockQuantity()) {
            throw new IllegalArgumentException("Số lượng vượt quá tồn kho hiện có.");
        }

        double unitPrice = product.getSalePrice();
        if (unitPrice <= 0) {
            unitPrice = product.getOriginalPrice();
        }

        Voucher voucher = null;
        Integer voucherId = null;
        double discountAmount = 0;
        if (voucherCode != null && !voucherCode.trim().isEmpty()) {
            voucher = voucherDAO.findByCode(voucherCode);
            if (voucher == null) {
                throw new IllegalArgumentException("Mã voucher không tồn tại.");
            }
            double voucherTotal = unitPrice * quantity;
            if (!voucher.isValidForCart(voucherTotal)) {
                throw new IllegalArgumentException("Mã voucher không hợp lệ cho đơn hàng này.");
            }
            voucherId = voucher.getId();
            discountAmount = voucher.calculateCartDiscount(voucherTotal);
        }

        int cartId = cartDAO.getOrCreateCartId(customerId);
        CartItem existing = cartItemDAO.getItemByProductId(cartId, productId);
        if (existing != null) {
            throw new IllegalArgumentException("Sản phẩm đã có trong giỏ hàng. Vui lòng vào giỏ hàng để cập nhật số lượng.");
        } else {
            double totalPrice = unitPrice * quantity;
            CartItem item = new CartItem();
            item.setCartId(cartId);
            item.setProductId(product.getId());
            item.setQuantity(quantity);
            item.setUnitPrice(unitPrice);
            item.setDiscountAmount(discountAmount);
            item.setTotalPrice(totalPrice - discountAmount);
            item.setNote(note);
            if (voucherId != null) {
                item.setVoucherId(voucherId);
                item.setDiscountCode(voucher.getCode());
            } else {
                item.setVoucherId(0);
                item.setDiscountCode(null);
            }
            item.setSelected(true);
            cartItemDAO.insertItem(item);
        }

        cartDAO.recalculateCartTotals(cartId);
        return cartDAO.getCartByCustomerId(customerId);
    }

    public Cart updateQuantity(int customerId, int productId, int quantity) {
        if (customerId <= 0) {
            throw new IllegalArgumentException("Vui lòng đăng nhập để tiếp tục.");
        }
        if (productId <= 0) {
            throw new IllegalArgumentException("Thông tin sản phẩm không hợp lệ.");
        }
        if (quantity <= 0) {
            throw new IllegalArgumentException("Số lượng phải lớn hơn 0.");
        }

        Cart cart = cartDAO.getCartByCustomerId(customerId);
        if (cart == null) {
            throw new IllegalArgumentException("Giỏ hàng không tồn tại.");
        }
        CartItem item = cartItemDAO.getItemByProductId(cart.getId(), productId);
        if (item == null) {
            throw new IllegalArgumentException("Mặt hàng không tồn tại trong giỏ hàng.");
        }
        Product product = productDAO.getProductById(productId);
        if (product == null || !product.isActive()) {
            throw new IllegalArgumentException("Sản phẩm không hợp lệ.");
        }
        if (quantity > product.getStockQuantity()) {
            throw new IllegalArgumentException("Số lượng vượt quá tồn kho hiện có.");
        }

        item.setQuantity(quantity);
        double totalPrice = item.getUnitPrice() * quantity;
        if (item.getVoucherId() > 0) {
            Voucher voucher = voucherDAO.findByCode(item.getDiscountCode());
            if (voucher != null) {
                double discount = voucher.calculateCartDiscount(totalPrice);
                if (discount > 0) {
                    item.setDiscountAmount(discount);
                } else {
                    item.setDiscountAmount(0);
                    item.setVoucherId(0);
                    item.setDiscountCode(null);
                }
            } else {
                item.setDiscountAmount(0);
                item.setVoucherId(0);
                item.setDiscountCode(null);
            }
        }
        item.setTotalPrice(totalPrice - item.getDiscountAmount());
        cartItemDAO.updateItem(item);
        cartDAO.recalculateCartTotals(cart.getId());
        return cartDAO.getCartByCustomerId(customerId);
    }

    public Cart updateCartItem(int customerId, int productId,
                               Integer quantity, String note, String discountCode) {
        if (customerId <= 0) {
            throw new IllegalArgumentException("Vui lòng đăng nhập để tiếp tục.");
        }
        if (productId <= 0) {
            throw new IllegalArgumentException("Thông tin sản phẩm không hợp lệ.");
        }

        Cart cart = cartDAO.getCartByCustomerId(customerId);
        if (cart == null) {
            throw new IllegalArgumentException("Giỏ hàng không tồn tại.");
        }

        CartItem item = cartItemDAO.getItemByProductId(cart.getId(), productId);
        if (item == null) {
            throw new IllegalArgumentException("Mặt hàng không tồn tại trong giỏ hàng. productId=" + productId);
        }

        Product product = productDAO.getProductById(productId);
        if (product == null || !product.isActive()) {
            throw new IllegalArgumentException("Sản phẩm không hợp lệ.");
        }

        if (quantity == null || quantity <= 0) {
            quantity = item.getQuantity();
        }

        if (quantity > product.getStockQuantity()) {
            throw new IllegalArgumentException("Số lượng vượt quá tồn kho hiện có (" + product.getStockQuantity() + ").");
        }

        item.setQuantity(quantity);
        if (note != null) {
            item.setNote(note);
        }

        if (discountCode != null && !discountCode.trim().isEmpty()) {
            Voucher voucher = voucherDAO.findByCode(discountCode);
            if (voucher == null) {
                throw new IllegalArgumentException("Mã voucher không tồn tại.");
            }
            double checkTotal = item.getUnitPrice() * quantity;
            double discount = voucher.calculateCartDiscount(checkTotal);
            if (discount <= 0) {
                throw new IllegalArgumentException("Mã voucher không hợp lệ cho đơn hàng này.");
            }
            item.setVoucherId(voucher.getId());
            item.setDiscountCode(voucher.getCode());
            item.setDiscountAmount(discount);
        } else {
            item.setVoucherId(0);
            item.setDiscountCode(null);
            item.setDiscountAmount(0);
        }

        double totalPrice = item.getUnitPrice() * quantity;
        item.setTotalPrice(totalPrice - item.getDiscountAmount());

        cartItemDAO.updateItem(item);
        cartDAO.recalculateCartTotals(cart.getId());
        return cartDAO.getCartByCustomerId(customerId);
    }

    public void updateItemSelection(int customerId, int productId, boolean selected) {
        if (customerId <= 0) return;
        Cart cart = cartDAO.getCartByCustomerId(customerId);
        if (cart == null) return;
        cartItemDAO.updateItemSelectionByProductId(cart.getId(), productId, selected);
    }

    public Cart removeItem(int customerId, int productId) {
        if (customerId <= 0) {
            throw new IllegalArgumentException("Vui lòng đăng nhập để tiếp tục.");
        }
        if (productId <= 0) {
            throw new IllegalArgumentException("Thông tin sản phẩm không hợp lệ.");
        }

        Cart cart = cartDAO.getCartByCustomerId(customerId);
        if (cart == null) {
            return null;
        }

        cartItemDAO.deleteItemByProductId(cart.getId(), productId);
        cartDAO.recalculateCartTotals(cart.getId());
        return cartDAO.getCartByCustomerId(customerId);
    }

    public Cart clearCart(int customerId) {
        if (customerId <= 0) {
            throw new IllegalArgumentException("Vui lòng đăng nhập để tiếp tục.");
        }
        Cart cart = cartDAO.getCartByCustomerId(customerId);
        if (cart == null) {
            return null;
        }

        cartItemDAO.deleteItemsByCartId(cart.getId());
        cartDAO.updateCartTotals(cart.getId(), 0, 0);
        return cartDAO.getCartByCustomerId(customerId);
    }

    public ReorderResult reorder(int customerId, int orderId) {
        if (customerId <= 0) {
            return ReorderResult.failure("Vui lòng đăng nhập để tiếp tục.");
        }
        if (orderId <= 0) {
            return ReorderResult.failure("Đơn hàng không hợp lệ.");
        }

        OrderDAO orderDAO = new OrderDAO();
        Order order = null;
        List<OrderDetail> details = null;
        try {
            order = orderDAO.getOrderById(orderId);
            if (order == null || order.getCustomerId() != customerId) {
                return ReorderResult.failure("Đơn hàng không tồn tại hoặc không thuộc quyền sở hữu của bạn.");
            }
            details = orderDAO.getOrderDetails(orderId);
        } finally {
            orderDAO.close();
        }

        if (details == null || details.isEmpty()) {
            return ReorderResult.failure("Đơn hàng không có sản phẩm nào để mua lại.");
        }

        int cartId = cartDAO.getOrCreateCartId(customerId);

        List<String> added = new ArrayList<>();
        List<String> adjusted = new ArrayList<>();
        List<String> failed = new ArrayList<>();

        for (OrderDetail detail : details) {
            int productId = detail.getProductId();
            Product product = productDAO.getProductById(productId);

            // Check if product is available and has stock
            if (product == null || !product.isActive() || !product.isInStock()) {
                failed.add(detail.getProductTitle() != null ? detail.getProductTitle() : ("Sản phẩm #" + productId));
                continue;
            }

            int targetQty = detail.getQuantity();
            if (targetQty <= 0) {
                targetQty = 1;
            }

            CartItem existing = cartItemDAO.getItemByProductId(cartId, productId);
            if (existing != null) {
                int newQty = existing.getQuantity() + targetQty;
                if (newQty > product.getStockQuantity()) {
                    newQty = product.getStockQuantity();
                    adjusted.add(product.getTitle());
                } else {
                    added.add(product.getTitle());
                }

                existing.setQuantity(newQty);
                double unitPrice = product.getSalePrice() > 0 && product.getSalePrice() < product.getOriginalPrice()
                        ? product.getSalePrice() : product.getOriginalPrice();
                existing.setUnitPrice(unitPrice);
                existing.setVoucherId(0);
                existing.setDiscountCode(null);
                existing.setDiscountAmount(0);
                existing.setTotalPrice(unitPrice * newQty);
                cartItemDAO.updateItem(existing);
            } else {
                int finalQty = targetQty;
                if (finalQty > product.getStockQuantity()) {
                    finalQty = product.getStockQuantity();
                    adjusted.add(product.getTitle());
                } else {
                    added.add(product.getTitle());
                }

                double unitPrice = product.getSalePrice() > 0 && product.getSalePrice() < product.getOriginalPrice()
                        ? product.getSalePrice() : product.getOriginalPrice();
                double totalPrice = unitPrice * finalQty;

                CartItem item = new CartItem();
                item.setCartId(cartId);
                item.setProductId(productId);
                item.setQuantity(finalQty);
                item.setUnitPrice(unitPrice);
                item.setDiscountAmount(0);
                item.setTotalPrice(totalPrice);
                item.setNote("");
                item.setVoucherId(0);
                item.setDiscountCode(null);
                item.setSelected(true);
                cartItemDAO.insertItem(item);
            }
        }

        cartDAO.recalculateCartTotals(cartId);

        if (added.isEmpty() && adjusted.isEmpty() && !failed.isEmpty()) {
            return ReorderResult.failure("Không thể mua lại. Tất cả sản phẩm trong đơn hàng đã hết hàng hoặc ngừng bán.");
        }

        StringBuilder msg = new StringBuilder("Đã thêm các sản phẩm khả dụng vào giỏ hàng thành công.");
        if (!failed.isEmpty()) {
            msg.append(" Có ").append(failed.size()).append(" sản phẩm đã hết hàng hoặc ngừng bán nên bị bỏ qua.");
        }
        if (!adjusted.isEmpty()) {
            msg.append(" Có ").append(adjusted.size()).append(" sản phẩm được điều chỉnh số lượng theo tồn kho.");
        }

        return ReorderResult.success(msg.toString());
    }
}
