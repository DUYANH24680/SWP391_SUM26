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

    public Cart getCartByCustomerId(int customerId) {
        if (customerId <= 0) {
            return null;
        }
        CartDAO cartDAO = new CartDAO();
        try {
            return cartDAO.getCartByCustomerId(customerId);
        } finally {
            cartDAO.close();
        }
    }

    public Cart addToCart(int customerId, int productId, String size, int quantity,
                          String voucherCode, String note) {
        if (customerId <= 0) {
            throw new IllegalArgumentException("Vui lòng đăng nhập để tiếp tục.");
        }
        if (productId <= 0) {
            throw new IllegalArgumentException("Sản phẩm không hợp lệ.");
        }
        if (size == null || size.trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng chọn kích cỡ.");
        }
        if (quantity <= 0) {
            throw new IllegalArgumentException("Số lượng phải lớn hơn 0.");
        }

        ProductDAO productDAO = new ProductDAO();
        VoucherDAO voucherDAO = new VoucherDAO();
        CartDAO cartDAO = new CartDAO();
        CartItemDAO cartItemDAO = new CartItemDAO();
        try {
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

            Voucher voucher = null;
            Integer voucherId = null;
            double discountAmount = 0;
            if (voucherCode != null && !voucherCode.trim().isEmpty()) {
                voucher = voucherDAO.findByCode(voucherCode);
                if (voucher == null) {
                    throw new IllegalArgumentException("Mã voucher không tồn tại.");
                }
                if (!voucher.isActive()) {
                    throw new IllegalArgumentException("Mã voucher không còn hoạt động.");
                }
                if (voucher.isExpired()) {
                    throw new IllegalArgumentException("Mã voucher đã hết hạn.");
                }
                if (!voucher.hasAvailableUsage()) {
                    throw new IllegalArgumentException("Mã voucher đã vượt quá số lượt sử dụng.");
                }
                voucherId = voucher.getId();
            }

            int cartId = cartDAO.getOrCreateCartId(customerId);
            CartItem existing = cartItemDAO.getItem(cartId, productId, size);
            double unitPrice = product.getSalePrice();
            if (unitPrice <= 0) {
                unitPrice = product.getOriginalPrice();
            }
            if (existing != null) {
                int combinedQuantity = existing.getQuantity() + quantity;
                if (combinedQuantity > product.getStockQuantity()) {
                    throw new IllegalArgumentException("Số lượng mới vượt quá tồn kho hiện có.");
                }
                double combinedTotal = unitPrice * combinedQuantity;
                if (voucher != null) {
                    discountAmount = voucher.calculateDiscount(combinedTotal);
                } else {
                    discountAmount = existing.getDiscountAmount();
                }
                existing.setQuantity(combinedQuantity);
                existing.setDiscountAmount(discountAmount);
                existing.setTotalPrice(combinedTotal - discountAmount);
                existing.setNote(note);
                if (voucherId != null) {
                    existing.setVoucherId(voucherId);
                    existing.setDiscountCode(voucher.getCode());
                }
                cartItemDAO.updateItem(existing);
            } else {
                double totalPrice = unitPrice * quantity;
                if (voucher != null) {
                    discountAmount = voucher.calculateDiscount(totalPrice);
                }
                CartItem item = new CartItem();
                item.setCartId(cartId);
                item.setProductId(product.getId());
                item.setSize(size);
                item.setQuantity(quantity);
                item.setUnitPrice(unitPrice);
                item.setDiscountAmount(discountAmount);
                item.setTotalPrice(totalPrice - discountAmount);
                item.setNote(note);
                if (voucherId != null) {
                    item.setVoucherId(voucherId);
                    item.setDiscountCode(voucher.getCode());
                }
                item.setSelected(true);
                cartItemDAO.insertItem(item);
            }

            cartDAO.recalculateCartTotals(cartId);
            return cartDAO.getCartByCustomerId(customerId);
        } finally {
            productDAO.close();
            voucherDAO.close();
            cartDAO.close();
            cartItemDAO.close();
        }
    }

    public Cart updateQuantity(int customerId, int productId, String size, int quantity) {
        if (customerId <= 0) {
            throw new IllegalArgumentException("Vui lòng đăng nhập để tiếp tục.");
        }
        if (productId <= 0 || size == null || size.trim().isEmpty()) {
            throw new IllegalArgumentException("Thông tin sản phẩm không hợp lệ.");
        }
        if (quantity <= 0) {
            throw new IllegalArgumentException("Số lượng phải lớn hơn 0.");
        }

        CartDAO cartDAO = new CartDAO();
        CartItemDAO cartItemDAO = new CartItemDAO();
        ProductDAO productDAO = new ProductDAO();
        VoucherDAO voucherDAO = new VoucherDAO();
        try {
            Cart cart = cartDAO.getCartByCustomerId(customerId);
            if (cart == null) {
                throw new IllegalArgumentException("Giỏ hàng không tồn tại.");
            }
            CartItem item = cartItemDAO.getItem(cart.getId(), productId, size);
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
                if (voucher != null && voucher.isActive() && !voucher.isExpired() && voucher.hasAvailableUsage()) {
                    item.setDiscountAmount(voucher.calculateDiscount(totalPrice));
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
        } finally {
            cartDAO.close();
            cartItemDAO.close();
            productDAO.close();
            voucherDAO.close();
        }
    }

    public Cart removeItem(int customerId, int productId, String size) {
        if (customerId <= 0) {
            throw new IllegalArgumentException("Vui lòng đăng nhập để tiếp tục.");
        }
        if (productId <= 0 || size == null || size.trim().isEmpty()) {
            throw new IllegalArgumentException("Thông tin sản phẩm không hợp lệ.");
        }

        CartDAO cartDAO = new CartDAO();
        CartItemDAO cartItemDAO = new CartItemDAO();
        try {
            Cart cart = cartDAO.getCartByCustomerId(customerId);
            if (cart == null) {
                throw new IllegalArgumentException("Giỏ hàng không tồn tại.");
            }
            cartItemDAO.deleteItem(cart.getId(), productId, size);
            cartDAO.recalculateCartTotals(cart.getId());
            return cartDAO.getCartByCustomerId(customerId);
        } finally {
            cartDAO.close();
            cartItemDAO.close();
        }
    }

    public Cart clearCart(int customerId) {
        if (customerId <= 0) {
            throw new IllegalArgumentException("Vui lòng đăng nhập để tiếp tục.");
        }
        CartDAO cartDAO = new CartDAO();
        CartItemDAO cartItemDAO = new CartItemDAO();
        try {
            Cart cart = cartDAO.getCartByCustomerId(customerId);
            if (cart == null) {
                return null;
            }
            cartItemDAO.deleteItemsByCartId(cart.getId());
            cartDAO.updateCartTotals(cart.getId(), 0, 0);
            return cartDAO.getCartByCustomerId(customerId);
        } finally {
            cartDAO.close();
            cartItemDAO.close();
        }
    }
}
