package model;

import java.util.Date;

public class ProductReview {
    private int id;
    private int productId;
    private int accountId;
    private int rating;
    private String comment;
    private Date createdAt;
    
    // Additional fields from Accounts table
    private String username;
    private String fullname;
    private String avatar;
    
    // DuyAnhNgo- Admin/Seller reply
    private String reply;

    public ProductReview() {}

    public ProductReview(int id, int productId, int accountId, int rating, String comment, Date createdAt) {
        this.id = id;
        this.productId = productId;
        this.accountId = accountId;
        this.rating = rating;
        this.comment = comment;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public int getAccountId() { return accountId; }
    public void setAccountId(int accountId) { this.accountId = accountId; }
    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }
    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getFullname() { return fullname; }
    public void setFullname(String fullname) { this.fullname = fullname; }
    public String getAvatar() { return avatar; }
    public void setAvatar(String avatar) { this.avatar = avatar; }

    public String getReply() { return reply; }
    public void setReply(String reply) { this.reply = reply; }
}