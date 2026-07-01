# Review Workflow & Dataflow - Mua hàng & Quản lý đơn hàng

> Mục tiêu: Tóm tắt luồng nghiệp vụ chuẩn và dataflow trong code để review với giảng viên.
> Dựa trên code hiện tại: `BuyNowServlet`, `ViewCartServlet`, `CheckoutServlet`, `CheckoutCartServlet`, `CustomerDashboardServlet`, `MyOrdersServlet`, `SellerDashboardServlet`, `SellerOrdersServlet`, `OrderService`, `CheckoutService`, `OrderDAO`.

---

## 1) Mua ngay (`Buy Now`)

### Luồng chuẩn
1. Khách chọn **Mua ngay** trên trang sản phẩm.
2. Frontend gọi `POST /buy-now` với `productId` và `quantity`.
3. Server thêm sản phẩm vào giỏ hàng của khách.
4. Server redirect sang `GET /checkout?productId=...&quantity=...`.
5. Khách nhập thông tin giao hàng + voucher → `POST /checkout`.
6. Đặt hàng thành công → redirect `/my-orders`.

### Dataflow code hiện tại
- **Controller:** `BuyNowServlet.doPost`
  - Validate đăng nhập
  - Parse `productId`, `quantity`
  - Gọi `CartService.addToCart(...)` với `note=null`, `discountCode=null`
  - Cập nhật session: `cart`, `cartCount`
  - Redirect sang `checkout?productId=...&quantity=...`
- **Service:** `OrderService.placeOrder(...)` được gọi từ `CheckoutServlet`
- **DAO:** `OrderDAO.createOrder(...)` insert `Orders` + `OrderDetails` trong transaction

### Nhận xét
- **Điểm mạnh:** Tách rõ giỏ hàng và thanh toán, đúng single responsibility.
- **Rủi ro:** `BuyNow` bắt buộc qua giỏ hàng nên nếu có lỗi giữa `addToCart` và `checkout`, dữ liệu có thể rơi vào trạng thái không nhất quán.
- **Đề xuất:** Có thể cân nhắc thêm endpoint `POST /checkout/buy-now` bỏ qua giỏ để giảm phụ thuộc, hoặc giữ nguyên nếu yêu cầu giỏ chung.

---

## 2) Thêm vào giỏ (`Add to Cart`)

### Luồng chuẩn
1. Khách bấm **Thêm vào giỏ** trên product page / cart page.
2. Frontend gọi `POST /cart` hoặc `POST /view-cart` với `action=add`.
3. Server thêm item vào giỏ, lưu session, quay về trang giỏ hoặc referer.

### Dataflow code hiện tại
- **Controller:** `ViewCartServlet.doPost`
  - Chỉ xử lý `action=add` / `action=buyNow`
  - Các action khác (`update`, `remove`, `clear`, `select`) comment “xử lý ở servlet riêng”
- **Service:** `CartService.addToCart(...)` nhận thêm `discountCode` và `note`
- **Session:** `cart`, `cartCount`

### Nhận xét
- **Điểm mạnh:** Session lưu cart giúp nhiều page đọc nhanh.
- **Rủi ro:** `ViewCartServlet` đang trở thành “catch-all” nhưng thực tế chỉ xử lý `add`. Nếu sau này thêm `update/remove` mà comment không được thực thi, sẽ gây lỗi logic.
- **Đề xuất:** Nếu có servlet riêng cho update/remove/clear/select, nên triển khai hoặc gọi rõ ràng thay vì comment.

---

## 3) Tiến hành mua hàng từ giỏ (`Checkout Cart`)

### Luồng chuẩn
1. Khách chọn sản phẩm trong giỏ → bấm **Thanh toán**.
2. Frontend gọi `GET /checkout-cart?selectedProducts=1,2,3`.
3. Server load danh sách sản phẩm đã chọn, tính `totalCost`, load address + voucher.
4. Khách xác nhận → `POST /checkout-cart`.
5. Server gọi `OrderService.placeCartOrder(...)`.
6. Thành công → redirect `/my-orders`.

### Dataflow code hiện tại
- **Controller:** `CheckoutCartServlet`
  - `doGet`: parse `selectedProducts`, lọc items trong cart, tính `totalCost`, forward `/checkout-cart.jsp`
  - `doPost`: validate, parse `selectedProducts`, gọi `placeCartOrder(...)`, cập nhật session cart
- **Service:** `OrderService.placeCartOrder(...)`
  - Validate tồn kho, tính `totalCost`, `shippingFee`, `discountAmount`, `finalCost`
  - `OrderDAO.createOrder(order, details)` trong transaction
  - Xóa items khỏi cart sau khi đặt
- **DAO:** `OrderDAO.createOrder(...)` tương tự buy now nhưng nhận `List<OrderDetail>`

### Nhận xét
- **Điểm mạnh:** Luồng checkout từ giỏ có validation tồn kho rõ ràng.
- **Rủi ro:** `CheckoutCartServlet` tự tính `totalCost` từ DAO trong khi `OrderService` cũng tự tính; dễ lệch nếu sau này có phí khác.
- **Đề xuất:** Đưa logic tính tổng vào service hoặc shared helper để đảm bảo single source of truth.

---

## 4) Customer Dashboard

### Luồng chuẩn
1. Khách đăng nhập → vào `/customer-dashboard`.
2. Server lấy toàn bộ đơn hàng của khách.
3. Tính tổng đơn, tổng chi tiêu, đếm theo trạng thái.
4. Render dashboard: thống kê + tracker + danh sách đơn gần nhất.

### Dataflow code hiện tại
- **Controller:** `CustomerDashboardServlet.doGet`
  - Gọi `OrderService.getCustomerOrdersWithDetails(customerId, null)`
  - Tính `totalSpent`, `pendingCount`, `confirmedCount`, `shippingCount`, `deliveredCount`, `canceledCount`
  - Forward `/customer-dashboard.jsp`
- **View:** `customer-dashboard.jsp`
  - Hiển thị thống kê + status cards click sang `/my-orders?status=...`
  - Hiển thị order list với `detailsMap`

### Nhận xét
- **Điểm mạnh:** Có đủ số liệu dashboard, UI đẹp.
- **Rủi ro:** Nếu khách có hàng trăm đơn, `getCustomerOrdersWithDetails` sẽ query N+1 (`getOrderDetails` trong vòng lặp).
- **Đề xuất:** Đánh thêm phân trang/giới hạn số đơn hiển thị dashboard; cân nhắc join `OrderDetails` trong DAO để giảm round-trip.

---

## 5) Đơn hàng của Customer (`My Orders`)

### Luồng chuẩn
1. Khách vào `/my-orders` hoặc click status card trên dashboard.
2. Server nhận `status` query param (1-5), filter đơn hàng.
3. Render danh sách đơn + tabs filter.

### Dataflow code hiện tại
- **Controller:** `MyOrdersServlet`
  - `doGet`: parse `status` → `statusFilter` → `OrderService.getCustomerOrdersWithDetails(customerId, statusFilter)`
  - `doPost`: hủy đơn hàng (`action=cancel`) → `OrderService.cancelCustomerOrder(...)`
- **Service:** `OrderService`
  - `getCustomerOrdersWithDetails(...)` chọn query theo filter hoặc all
  - `cancelCustomerOrder(...)` kiểm tra quyền + status=1 rồi gọi `cancelOrder`
- **DAO:** `OrderDAO`
  - `getOrdersByCustomerIdAndStatus(...)`
  - `cancelOrder(...)` rollback stock + voucher count trong transaction

### Nhận xét
- **Điểm mạnh:** Filter theo status rõ ràng, hủy đơn có rollback tồn kho.
- **Rủi ro:** `doPost` hủy đơn sau đó `sendRedirect` về `/my-orders` không giữ filter; nếu đang xem “Đã hủy” mà hủy 1 đơn khác, sẽ quay về tất cả.
- **Đề xuất:** Sau khi hủy, redirect kèm lại `status=5` hoặc giữ filter session để trải nghiệm nhất quán.

---

## 6) Seller Dashboard

### Luồng chuẩn
1. Seller vào `/seller/dashboard`.
2. Server kiểm tra role + shop approved.
3. Lấy tổng sản phẩm, tổng đơn, pending orders, doanh thu, danh sách đơn gần nhất.
4. Render dashboard.

### Dataflow code hiện tại
- **Controller:** `SellerDashboardServlet`
  - Kiểm tra `role=seller`
  - Gọi `SellerDashboardService.getDashboardData(sellerAccountId)`
  - Forward `/seller/dashboard.jsp`
- **Service:** `SellerDashboardService`
  - Load `Shop` theo owner
  - Đếm products/orders, tính revenue, load recent orders
- **DAO:** `ShopDAO`, `OrderDAO`

### Nhận xét
- **Điểm mạnh:** Tách dashboard service riêng, không lẫn business logic trong servlet.
- **Rủi ro:** Doanh thu hiện có thể chỉ tính `final_cost` mà chưa xử lý trường hợp đơn hủy/hoàn tiền; cần rõ rule nghiệp vụ.
- **Đề xuất:** Lưu ý giảng viên revenue có cần trừ đơn hủy/refund không, và cập nhật service theo rule đó.

---

## 7) Quản lý đơn hàng của Seller (`Seller Orders`)

### Luồng chuẩn
1. Seller vào `/seller/orders`.
2. Xem danh sách đơn thuộc shop.
3. Seller có thể **xác nhận** hoặc **từ chối** đơn.
4. Cập nhật trạng thái đơn + rollback tồn kho/voucher nếu từ chối.

### Dataflow code hiện tại
- **Controller:** `SellerOrdersServlet`
  - `doGet`: gọi `OrderService.getSellerOrdersData(account.getId())`, forward `/seller/orders.jsp`
  - `doPost`: gọi `OrderService.handleSellerOrderAction(account.getId(), orderId, action)`
- **Service:** `OrderService.handleSellerOrderAction(...)`
  - Kiểm tra shop approved
  - Kiểm tra quyền sở hữu đơn (`checkOrderOwnership`)
  - `confirm`: `confirmOrder(orderId)` → status 1→2
  - `cancel`: `cancelOrder(orderId)` → status 1→5, rollback stock/voucher
- **DAO:** `OrderDAO`
  - `checkOrderOwnership(...)`
  - `confirmOrder(...)` kiểm tra current status = 1
  - `cancelOrder(...)` transaction rollback stock + voucher count

### Nhận xét
- **Điểm mạnh:** Có check ownership trước khi update, tránh cross-shop action.
- **Rủi ro:** `handleSellerOrderAction` trong service kiểm tra `status==2` trước cancel, nhưng `cancelOrder` trong DAO chỉ cho phép cancel khi `status==1`. Tức seller đang ở trạng thái đã xác nhận không thể cancel ở DB, nhưng UI/service đã chặy trước → OK, nhưng cần đảm bảo UI hiển thị đúng hành động.
- **Đề xuất:** Rõ ràng hóa business rule: seller chỉ được xử lý đơn ở `Chờ xác nhận`; nếu cần hủy đơn đã xác nhận, cần action mới hoặc role admin.

---

## 8) Tổng quan Dataflow & Tách lớp

```
Frontend
  -> Controller (Servlet)
    -> Service (Business logic)
      -> DAO (SQL / Transaction)
        -> Database
```

### Các Service hiện có
- `OrderService`: placeOrder, cancelOrder, seller action, fetch orders
- `CheckoutService`: validate voucher, prepare checkout page
- `CartService`: add/update/remove cart items

### Các DAO hiện có
- `OrderDAO`: tạo đơn, query đơn, update status, cancel transaction
- `ProductDAO`, `VoucherDAO`, `DeliveryAddressDAO`, `ShopDAO`

### Nhận xét chung
- **Điểm mạnh:** Phân tách Controller/Service/DAO rõ ràng, phù hợp để trình bày.
- **Rủi ro:** Một số servlet vừa xử lý GET vừa xử lý POST nhiều action khác nhau (`ViewCartServlet`, `CheckoutCartServlet`). Nên tách thành servlet nhỏ hơn hoặc dùng command pattern để dễ bảo trì.
- **Đề xuất:** Nếu thầy hỏi về mở rộng, có thể đề cập thêm: đơn có thể mở rộng sang `PaymentService`, `ShippingService`, `NotificationService`.

---

## 9) Gợi ý cấu trúc trình bày với thầy

1. **Workflow tổng quan:** Vẽ sơ đồ luồng từ Product → Cart → Checkout → Order → Seller action → Delivery.
2. **Dataflow:** Lấy 1-2 luồng đại diện (Mua ngay + Hủy đơn) demo chi tiết từ `Servlet -> Service -> DAO -> DB`.
3. **Điểm mạnh:** Phân lớp rõ, transaction an toàn, có rollback tồn kho/voucher.
4. **Hạn chế hiện tại:**
   - N+1 query khi load chi tiết đơn
   - Redirect sau hủy/hoàn thành chưa giữ filter
   - Một số servlet đang “đa nhiệm”
5. **Đề xuất cải tiến:**
   - Pagination / join query cho order details
   - Tách servlet theo action rõ ràng hơn
   - Đưa logic tính phí vào service để tránh lệch

---

## 10) Liên kết file tham chiếu

- `src/java/controller/BuyNowServlet.java`
- `src/java/controller/ViewCartServlet.java`
- `src/java/controller/CheckoutServlet.java`
- `src/java/controller/CheckoutCartServlet.java`
- `src/java/controller/CustomerDashboardServlet.java`
- `src/java/controller/MyOrdersServlet.java`
- `src/java/controller/SellerDashboardServlet.java`
- `src/java/controller/SellerOrdersServlet.java`
- `src/java/service/OrderService.java`
- `src/java/service/CheckoutService.java`
- `src/java/dao/OrderDAO.java`