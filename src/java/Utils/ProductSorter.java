package Utils;

import model.Product;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class ProductSorter {

    /**
     * Sắp xếp danh sách sản phẩm theo tiêu chí (Popular, Newest, Price Asc/Desc, Rating)
     * 
     * @param list Danh sách sản phẩm cần sắp xếp
     * @param sortBy Chuỗi tiêu chí: "popular", "newest", "price_asc", "price_desc", "rating"
     */
    public static void sortProducts(List<Product> list, String sortBy) {
        if (list == null || list.isEmpty() || sortBy == null) {
            return;
        }

        switch (sortBy) {
            case "popular":
                // Phổ biến: Dựa trên số lượng đã bán (giảm dần)
                Collections.sort(list, new Comparator<Product>() {
                    @Override
                    public int compare(Product p1, Product p2) {
                        return Integer.compare(p2.getSoldQuantity(), p1.getSoldQuantity());
                    }
                });
                break;
            case "newest":
                // Mới nhất: Dựa trên ngày tạo (giảm dần)
                Collections.sort(list, new Comparator<Product>() {
                    @Override
                    public int compare(Product p1, Product p2) {
                        if (p1.getCreatedAt() == null || p2.getCreatedAt() == null) return 0;
                        return p2.getCreatedAt().compareTo(p1.getCreatedAt());
                    }
                });
                break;
            case "price_asc":
                // Giá tăng dần
                Collections.sort(list, new Comparator<Product>() {
                    @Override
                    public int compare(Product p1, Product p2) {
                        return Double.compare(p1.getSalePrice(), p2.getSalePrice());
                    }
                });
                break;
            case "price_desc":
                // Giá giảm dần
                Collections.sort(list, new Comparator<Product>() {
                    @Override
                    public int compare(Product p1, Product p2) {
                        return Double.compare(p2.getSalePrice(), p1.getSalePrice());
                    }
                });
                break;
            case "rating":
                // Đánh giá: Dựa trên averageRating (giảm dần)
                Collections.sort(list, new Comparator<Product>() {
                    @Override
                    public int compare(Product p1, Product p2) {
                        return Double.compare(p2.getAverageRating(), p1.getAverageRating());
                    }
                });
                break;
            default:
                // Mặc định không thay đổi
                break;
        }
    }
}

