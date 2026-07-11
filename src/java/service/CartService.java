package service;

import dao.CartDAO;
import dao.CartItemDAO;
import dao.ProductDAO;
import dao.VoucherDAO;
import model.Cart;
import model.CartItem;
import model.Product;
import model.Voucher;

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
}
