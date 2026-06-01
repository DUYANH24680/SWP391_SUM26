package service;

import dao.ProductDAO;
import dao.CategoryDAO;
import dao.SellerDAO;
import model.Product;
import model.Category;
import model.Seller;
import java.math.BigDecimal;
import java.util.List;

public class ProductService {

    private final ProductDAO dao = new ProductDAO();
    private final CategoryDAO categoryDao = new CategoryDAO();
    private final SellerDAO sellerDao = new SellerDAO();

    public boolean addProduct(Product product) {
        String error = validateProduct(product, null);
        if (error != null) {
            throw new IllegalArgumentException(error);
        }
        return dao.addProduct(product);
    }

    public String addProductWithValidation(Product product) {
        String error = validateProduct(product, null);
        if (error != null) {
            return error;
        }
        boolean ok = dao.addProduct(product);
        return ok ? null : "Them san pham that bai. Vui long thu lai.";
    }

    public List<Product> getAll() {
        return dao.getAll();
    }

    public Product getById(int id) {
        return dao.findById(id);
    }

    public List<Product> getByCategory(int categoryId) {
        return dao.getByCategory(categoryId);
    }

    public List<Product> getBySeller(int sellerId) {
        return dao.getBySeller(sellerId);
    }

    public String updateProduct(Product product) {
        String error = validateProduct(product, product.getId());
        if (error != null) {
            return error;
        }
        Product existing = dao.findById(product.getId());
        if (existing == null) {
            return "Khong tim thay san pham.";
        }
        boolean ok = dao.update(product);
        return ok ? null : "Cap nhat san pham that bai. Vui long thu lai.";
    }

    public String deleteProduct(int id) {
        Product existing = dao.findById(id);
        if (existing == null) {
            return "Khong tim thay san pham.";
        }
        boolean ok = dao.hardDelete(id);
        return ok ? null : "Xoa san pham that bai. Vui long thu lai.";
    }

    public String updateStatus(int id, int status) {
        if (status < 0 || status > 2) {
            return "Trang thai khong hop le (0=Cho duyet, 1=Hien thi, 2=An).";
        }
        Product existing = dao.findById(id);
        if (existing == null) {
            return "Khong tim thay san pham.";
        }
        boolean ok = dao.updateStatus(id, status);
        return ok ? null : "Cap nhat trang thai that bai. Vui long thu lai.";
    }

    private String validateProduct(Product p, Integer excludeId) {
        if (p.getTitle() == null || p.getTitle().trim().isEmpty()) {
            return "Ten san pham khong duoc de trong.";
        }
        if (p.getOriginalPrice() == null) {
            return "Gia goc khong duoc de trong.";
        }
        if (p.getOriginalPrice().compareTo(BigDecimal.ZERO) <= 0) {
            return "Gia goc phai lon hon 0.";
        }
        if (p.getSalePrice() != null && p.getSalePrice().compareTo(BigDecimal.ZERO) < 0) {
            return "Gia ban khong duoc la so am.";
        }
        if (p.getSalePrice() != null && p.getOriginalPrice() != null
                && p.getSalePrice().compareTo(p.getOriginalPrice()) > 0) {
            return "Gia ban khong duoc lon hon gia goc.";
        }
        if (p.getStockQuantity() < 0) {
            return "So luong ton kho khong duoc la so am.";
        }
        Category cat = categoryDao.findById(p.getCategoryId());
        if (cat == null || cat.isIsDelete()) {
            return "Danh muc khong hop le.";
        }
        Seller seller = sellerDao.findById(p.getSellerId());
        if (seller == null || seller.getStatus() != 1) {
            return "Nguoi ban khong hop le hoac da bi khoa.";
        }
        return null;
    }
}
