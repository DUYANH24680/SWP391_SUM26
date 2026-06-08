package dao;

import model.Cart;
import model.CartItem;
import model.Product;
import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDAO extends DbContext {

    private ProductDAO productDAO;

    public CartDAO() {
        super();
        this.productDAO = new ProductDAO();
    }

    // 1. Get or Create Cart for Customer
    public Cart getCartByCustomerId(int customerId) {
        Cart cart = null;
        String sql = "SELECT cart_id, customer_id, created_at FROM Cart WHERE customer_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    cart = new Cart();
                    cart.setId(rs.getInt("cart_id"));
                    cart.setCustomerId(rs.getInt("customer_id"));
                    cart.setCreatedAt(rs.getTimestamp("created_at"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // If not found, create a new cart
        if (cart == null) {
            cart = createCartForCustomer(customerId);
        }

        if (cart != null) {
            // Load items
            cart.setItems(getCartItems(cart.getId()));
        }

        return cart;
    }

    private Cart createCartForCustomer(int customerId) {
        String sql = "INSERT INTO Cart (customer_id, created_at) VALUES (?, GETDATE())"; // GETDATE() for SQL Server, use NOW() for MySQL
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, customerId);
            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        Cart cart = new Cart();
                        cart.setId(rs.getInt(1));
                        cart.setCustomerId(customerId);
                        cart.setCreatedAt(new Timestamp(System.currentTimeMillis()));
                        return cart;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private List<CartItem> getCartItems(int cartId) {
        List<CartItem> items = new ArrayList<>();
        String sql = "SELECT cart_item_id, cart_id, product_id, quantity, added_at FROM CartItem WHERE cart_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, cartId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartItem item = new CartItem();
                    item.setId(rs.getInt("cart_item_id"));
                    item.setCartId(rs.getInt("cart_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setAddedAt(rs.getTimestamp("added_at"));
                    
                    // Fetch Product details
                    Product product = productDAO.getProductById(rs.getInt("product_id"));
                    item.setProduct(product);
                    
                    items.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }

    // 2. Add or Update Item in Cart
    public boolean addCartItem(int customerId, int productId, int quantity) {
        Cart cart = getCartByCustomerId(customerId);
        if (cart == null) return false;

        // Check if item already exists
        CartItem existingItem = null;
        for (CartItem item : cart.getItems()) {
            if (item.getProduct().getId() == productId) {
                existingItem = item;
                break;
            }
        }

        if (existingItem != null) {
            // Update quantity
            return updateQuantity(existingItem.getId(), existingItem.getQuantity() + quantity);
        } else {
            // Insert new item
            String sql = "INSERT INTO CartItem (cart_id, product_id, quantity, added_at) VALUES (?, ?, ?, GETDATE())";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setInt(1, cart.getId());
                ps.setInt(2, productId);
                ps.setInt(3, quantity);
                return ps.executeUpdate() > 0;
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return false;
    }

    // 3. Update Quantity
    public boolean updateQuantity(int cartItemId, int newQuantity) {
        if (newQuantity <= 0) {
            return removeCartItem(cartItemId);
        }
        String sql = "UPDATE CartItem SET quantity = ? WHERE cart_item_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, newQuantity);
            ps.setInt(2, cartItemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 4. Remove Item
    public boolean removeCartItem(int cartItemId) {
        String sql = "DELETE FROM CartItem WHERE cart_item_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, cartItemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
