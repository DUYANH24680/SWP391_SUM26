package service;

import dao.CartDAO;
import dao.ProductDAO;
import dao.WishlistDAO;
import model.Cart;
import model.Product;
import model.Wishlist;

public class WishlistService {

    public Wishlist getWishlistByCustomerId(int customerId) {
        if (customerId <= 0) {
            return null;
        }
        WishlistDAO wishlistDAO = new WishlistDAO();
        try {
            return wishlistDAO.getWishlistByUser(customerId);
        } finally {
            wishlistDAO.close();
        }
    }

    public boolean addToWishlist(int customerId, int productId) {
        if (customerId <= 0) {
            throw new IllegalArgumentException("Vui lòng đăng nhập để tiếp tục.");
        }
        if (productId <= 0) {
            throw new IllegalArgumentException("Sản phẩm không hợp lệ.");
        }

        ProductDAO productDAO = new ProductDAO();
        WishlistDAO wishlistDAO = new WishlistDAO();
        try {
            Product product = productDAO.getProductById(productId);
            if (product == null || product.isIsDelete()) {
                throw new IllegalArgumentException("Sản phẩm không tồn tại.");
            }
            if (!product.isActive()) {
                throw new IllegalArgumentException("Sản phẩm hiện tại không hoạt động.");
            }
            if (wishlistDAO.exists(customerId, productId)) {
                return false;
            }
            return wishlistDAO.addWishlist(customerId, productId);
        } finally {
            productDAO.close();
            wishlistDAO.close();
        }
    }

    public boolean removeFromWishlist(int customerId, int productId) {
        if (customerId <= 0) {
            throw new IllegalArgumentException("Vui lòng đăng nhập để tiếp tục.");
        }
        if (productId <= 0) {
            throw new IllegalArgumentException("Sản phẩm không hợp lệ.");
        }
        WishlistDAO wishlistDAO = new WishlistDAO();
        try {
            return wishlistDAO.removeWishlist(customerId, productId);
        } finally {
            wishlistDAO.close();
        }
    }

    public Cart moveWishlistItemToCart(int customerId, int productId) {
        if (customerId <= 0) {
            throw new IllegalArgumentException("Vui lòng đăng nhập để tiếp tục.");
        }
        if (productId <= 0) {
            throw new IllegalArgumentException("Sản phẩm không hợp lệ.");
        }

        WishlistDAO wishlistDAO = new WishlistDAO();
        CartDAO cartDAO = new CartDAO();
        try {
            boolean moved = wishlistDAO.moveToCart(customerId, productId);
            if (!moved) {
                throw new IllegalArgumentException("Không thể chuyển sản phẩm từ wishlist vào giỏ hàng.");
            }
            return cartDAO.getCartByCustomerId(customerId);
        } finally {
            wishlistDAO.close();
            cartDAO.close();
        }
    }
}
