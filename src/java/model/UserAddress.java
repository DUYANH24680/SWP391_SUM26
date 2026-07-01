package model;

public class UserAddress {
    private int id;
    private int userId;
    private String recipientName;
    private String recipientPhone;
    private String province;
    private String district;
    private String ward;
    private String detailAddress;
    private boolean isDefault;
    private String note = ""; // Not in DB, kept for Java compatibility

    public UserAddress() {
    }

    public UserAddress(int id, int userId, String recipientName, String recipientPhone, String province, String district, String ward, String detailAddress, boolean isDefault) {
        this.id = id;
        this.userId = userId;
        this.recipientName = recipientName;
        this.recipientPhone = recipientPhone;
        this.province = province;
        this.district = district;
        this.ward = ward;
        this.detailAddress = detailAddress;
        this.isDefault = isDefault;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    // Alias for customerId to keep backward compatibility
    public int getCustomerId() {
        return userId;
    }

    public void setCustomerId(int customerId) {
        this.userId = customerId;
    }

    public String getRecipientName() {
        return recipientName;
    }

    public void setRecipientName(String recipientName) {
        this.recipientName = recipientName;
    }

    public String getRecipientPhone() {
        return recipientPhone;
    }

    public void setRecipientPhone(String recipientPhone) {
        this.recipientPhone = recipientPhone;
    }

    public String getProvince() {
        return province;
    }

    public void setProvince(String province) {
        this.province = province;
    }

    public String getDistrict() {
        return district;
    }

    public void setDistrict(String district) {
        this.district = district;
    }

    public String getWard() {
        return ward;
    }

    public void setWard(String ward) {
        this.ward = ward;
    }

    public String getDetailAddress() {
        return detailAddress;
    }

    public void setDetailAddress(String detailAddress) {
        this.detailAddress = detailAddress;
    }

    public boolean isIsDefault() {
        return isDefault;
    }

    public void setIsDefault(boolean isDefault) {
        this.isDefault = isDefault;
    }

    // Note field compatibility (transient)
    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note != null ? note : "";
    }

    // Getter for flat address for backward compatibility in JSPs
    public String getAddress() {
        StringBuilder sb = new StringBuilder();
        if (detailAddress != null && !detailAddress.isEmpty()) {
            sb.append(detailAddress);
        }
        if (ward != null && !ward.isEmpty()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(ward);
        }
        if (district != null && !district.isEmpty()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(district);
        }
        if (province != null && !province.isEmpty()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(province);
        }
        return sb.toString();
    }

    // Setter for flat address (automatically parses flat string into components)
    public void setAddress(String address) {
        if (address == null) return;
        String[] parts = address.split(",");
        for (int i = 0; i < parts.length; i++) {
            parts[i] = parts[i].trim();
        }
        if (parts.length >= 4) {
            this.province = parts[parts.length - 1];
            this.district = parts[parts.length - 2];
            this.ward = parts[parts.length - 3];
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < parts.length - 3; i++) {
                if (i > 0) sb.append(", ");
                sb.append(parts[i]);
            }
            this.detailAddress = sb.toString();
        } else if (parts.length == 3) {
            this.province = parts[2];
            this.district = parts[1];
            this.ward = parts[0];
            this.detailAddress = parts[0];
        } else if (parts.length == 2) {
            this.province = parts[1];
            this.district = parts[0];
            this.ward = "";
            this.detailAddress = "";
        } else {
            this.province = address;
            this.district = "";
            this.ward = "";
            this.detailAddress = "";
        }
    }
}
