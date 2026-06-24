package service;

import dao.CartDAO;
import dao.ProductDAO;
import dao.WishlistDAO;
import model.Cart;
import model.Product;
import model.Wishlist;

public class WishlistService {

    private WishlistDAO wishlistDAO;
    private ProductDAO productDAO;
    private CartDAO cartDAO;

    public WishlistService() {
        this.wishlistDAO = new WishlistDAO();
        this.productDAO = new ProductDAO();
        this.cartDAO = new CartDAO();
    }

    public void close() {
        if (wishlistDAO != null) {
            try { wishlistDAO.close(); } catch (Exception ignored) {}
            wishlistDAO = null;
        }
        if (productDAO != null) {
            try { productDAO.close(); } catch (Exception ignored) {}
            productDAO = null;
        }
        if (cartDAO != null) {
            try { cartDAO.close(); } catch (Exception ignored) {}
            cartDAO = null;
        }
    }

    public Wishlist getWishlistByCustomerId(int customerId) {
        if (customerId <= 0) return null;
        return wishlistDAO.getWishlistByUser(customerId);
    }

    public AddResult addToWishlist(int customerId, int productId) {
        if (customerId <= 0) return AddResult.notLoggedIn();
        if (productId <= 0) return AddResult.invalidProduct();

        Product product = productDAO.getProductById(productId);
        if (product == null || product.isIsDelete()) return AddResult.productNotFound();
        if (!product.isActive()) return AddResult.productInactive();
        if (wishlistDAO.exists(customerId, productId)) return AddResult.alreadyExists();

        boolean added = wishlistDAO.addWishlist(customerId, productId);
        return added ? AddResult.success() : AddResult.failed();
    }

    public boolean removeFromWishlist(int customerId, int productId) {
        if (customerId <= 0) throw new IllegalArgumentException("Vui lòng đăng nhập để tiếp tục.");
        if (productId <= 0) throw new IllegalArgumentException("Sản phẩm không hợp lệ.");
        return wishlistDAO.removeWishlist(customerId, productId);
    }

    public Cart moveWishlistItemToCart(int customerId, int productId) {
        if (customerId <= 0) throw new IllegalArgumentException("Vui lòng đăng nhập để tiếp tục.");
        if (productId <= 0) throw new IllegalArgumentException("Sản phẩm không hợp lệ.");

        boolean moved = wishlistDAO.moveToCart(customerId, productId);
        if (!moved) throw new IllegalArgumentException("Không thể chuyển sản phẩm từ wishlist vào giỏ hàng.");
        return cartDAO.getCartByCustomerId(customerId);
    }

    public boolean isInWishlist(int customerId, int productId) {
        if (customerId <= 0 || productId <= 0) return false;
        return wishlistDAO.exists(customerId, productId);
    }

    public int getWishlistCount(int customerId) {
        if (customerId <= 0) return 0;
        return wishlistDAO.getWishlistCount(customerId);
    }

    public static class AddResult {
        private final boolean success;
        private final String code;
        private final String message;

        private AddResult(boolean success, String code, String message) {
            this.success = success;
            this.code = code;
            this.message = message;
        }

        public boolean isSuccess() { return success; }
        public String getCode() { return code; }
        public String getMessage() { return message; }

        public static AddResult success() {
            return new AddResult(true, "SUCCESS", "Đã thêm sản phẩm vào wishlist.");
        }
        public static AddResult alreadyExists() {
            return new AddResult(false, "ALREADY_EXISTS", "Sản phẩm đã có trong wishlist.");
        }
        public static AddResult productNotFound() {
            return new AddResult(false, "PRODUCT_NOT_FOUND", "Sản phẩm không tồn tại.");
        }
        public static AddResult productInactive() {
            return new AddResult(false, "PRODUCT_INACTIVE", "Sản phẩm hiện tại không hoạt động.");
        }
        public static AddResult notLoggedIn() {
            return new AddResult(false, "NOT_LOGGED_IN", "Vui lòng đăng nhập để sử dụng wishlist.");
        }
        public static AddResult invalidProduct() {
            return new AddResult(false, "INVALID_PRODUCT", "Sản phẩm không hợp lệ.");
        }
        public static AddResult failed() {
            return new AddResult(false, "FAILED", "Lỗi khi thêm sản phẩm vào wishlist.");
        }
    }
}
