package util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Simple utility to print SHA-256 hash of given strings.
 * Usage: java util.HashGenerator admin123 johnpassword
 */
public class HashGenerator {
    public static void main(String[] args) {
        for (String s : args) {
            System.out.println(s + " -> " + hashPassword(s));
        }
    }

    private static String hashPassword(String plain) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(plain.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder();
            for (byte b : hash) {
                String h = Integer.toHexString(0xff & b);
                if (h.length() == 1) hex.append('0');
                hex.append(h);
            }
            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }
}
