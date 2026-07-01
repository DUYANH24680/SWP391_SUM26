package Utils;

import jakarta.servlet.ReadListener;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletRequestWrapper;
import jakarta.servlet.http.Part;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;

/**
 * Wraps an HttpServletRequest so that text form fields from a multipart request
 * are accessible via getParameter() — which does not work reliably for all servlet
 * containers when @MultipartConfig is used alone.
 *
 * This implementation caches every Part (text and file) as a byte array on first
 * read, so getParameter() and getPart() / getParts() can both be called safely
 * without stream-consumption issues.
 */
public class MultipartRequestWrapper extends HttpServletRequestWrapper {

    private final Map<String, List<String>> parameters = new LinkedHashMap<>();
    private final Map<String, byte[]> fileBytes = new LinkedHashMap<>();
    private final Map<String, String> fileContentTypes = new LinkedHashMap<>();
    private final Map<String, String> fileNames = new LinkedHashMap<>();
    private List<Part> cachedParts;

    public MultipartRequestWrapper(HttpServletRequest request) throws IOException, ServletException {
        super(request);
        parseMultipart(request);
    }

    private void parseMultipart(HttpServletRequest request) throws IOException, ServletException {
        for (Part part : request.getParts()) {
            String name = part.getName();
            String contentType = part.getContentType();

            if (contentType != null && !contentType.isEmpty()) {
                // File part: cache bytes so the stream can be read multiple times
                String rawFileName = extractFileName(part);
                byte[] bytes = readAllBytes(part);
                fileBytes.put(name, bytes);
                fileContentTypes.put(name, contentType);
                fileNames.put(name, rawFileName);
            } else {
                // Text part: parse as UTF-8 string
                byte[] bytes = readAllBytes(part);
                String value = new String(bytes, StandardCharsets.UTF_8);
                List<String> values = parameters.computeIfAbsent(name, k -> new ArrayList<>());
                values.add(value);
            }
        }

        // Build list of all cached parts (both text and file)
        cachedParts = buildPartList();
    }

    private byte[] readAllBytes(Part part) throws IOException {
        try (InputStream is = part.getInputStream()) {
            return is.readAllBytes();
        }
    }

    private static final String HEADER_CONTENT_DISPOSITION = "content-disposition";

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader(HEADER_CONTENT_DISPOSITION);
        if (contentDisp == null) return "";
        for (String token : contentDisp.split(";")) {
            token = token.trim();
            if (token.startsWith("filename*")) {
                return parseFilenameStar(token);
            }
            if (token.startsWith("filename")) {
                String fileName = token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
                int lastSep = Math.max(fileName.lastIndexOf('/'), fileName.lastIndexOf('\\'));
                if (lastSep >= 0) fileName = fileName.substring(lastSep + 1);
                return fileName;
            }
        }
        return "";
    }

    private String parseFilenameStar(String token) {
        int eq = token.indexOf('=');
        if (eq < 0) return "";
        String encoded = token.substring(eq + 1).trim();
        int secondQuote = encoded.indexOf('\'');
        if (secondQuote >= 0) {
            int thirdQuote = encoded.indexOf('\'', secondQuote + 1);
            encoded = (thirdQuote >= 0) ? encoded.substring(thirdQuote + 1) : encoded.substring(secondQuote + 1);
        }
        try {
            return java.net.URLDecoder.decode(encoded, "UTF-8");
        } catch (Exception e) {
            return encoded;
        }
    }

    private List<Part> buildPartList() {
        List<Part> result = new ArrayList<>();
        // Text parts first
        for (Map.Entry<String, List<String>> e : parameters.entrySet()) {
            result.add(new TextPart(e.getKey()));
        }
        // File parts next
        for (Map.Entry<String, byte[]> e : fileBytes.entrySet()) {
            result.add(new CachedFilePart(e.getKey(), e.getValue(),
                    fileContentTypes.get(e.getKey()), fileNames.get(e.getKey())));
        }
        return Collections.unmodifiableList(result);
    }

    // ── getParameter() implementations ──────────────────────────────────────

    @Override
    public String getParameter(String name) {
        List<String> values = parameters.get(name);
        return (values != null && !values.isEmpty()) ? values.get(0) : null;
    }

    @Override
    public String[] getParameterValues(String name) {
        List<String> values = parameters.get(name);
        return (values != null) ? values.toArray(new String[0]) : null;
    }

    @Override
    public Enumeration<String> getParameterNames() {
        return Collections.enumeration(parameters.keySet());
    }

    @Override
    public Map<String, String[]> getParameterMap() {
        Map<String, String[]> result = new HashMap<>();
        for (Map.Entry<String, List<String>> e : parameters.entrySet()) {
            result.put(e.getKey(), e.getValue().toArray(new String[0]));
        }
        return Collections.unmodifiableMap(result);
    }

    // ── getPart() / getParts() implementations ───────────────────────────────

    @Override
    public Part getPart(String name) throws IOException, ServletException {
        for (Part p : cachedParts) {
            if (p.getName().equals(name)) return p;
        }
        return null;
    }

    @Override
    public Collection<Part> getParts() {
        return cachedParts;
    }

    // ── Cached text part ────────────────────────────────────────────────────

    private static class TextPart implements Part {
        private final String name;

        TextPart(String name) {
            this.name = name;
        }

        @Override public String getName() { return name; }
        @Override public String getContentType() { return null; }
        @Override public long getSize() { return 0; }

        @Override
        public String getSubmittedFileName() { return null; }

        @Override
        public void write(String fileName) throws IOException {
            throw new IOException("Text parts cannot be written to disk.");
        }

        @Override
        public InputStream getInputStream() {
            return new ByteArrayInputStream(new byte[0]);
        }

        @Override
        public void delete() {
            throw new UnsupportedOperationException("Cached parts cannot be deleted.");
        }

        @Override
        public String getHeader(String name) { return null; }
        @Override
        public Collection<String> getHeaders(String name) { return Collections.emptyList(); }
        @Override
        public Collection<String> getHeaderNames() { return Collections.emptyList(); }
    }

    // ── Cached file part ────────────────────────────────────────────────────

    private static class CachedFilePart implements Part {
        private final String name;
        private final byte[] bytes;
        private final String contentType;
        private final String submittedFileName;

        CachedFilePart(String name, byte[] bytes, String contentType, String submittedFileName) {
            this.name = name;
            this.bytes = bytes;
            this.contentType = contentType;
            this.submittedFileName = submittedFileName;
        }

        @Override public String getName() { return name; }
        @Override public String getContentType() { return contentType; }
        @Override public long getSize() { return bytes.length; }

        @Override
        public String getSubmittedFileName() { return submittedFileName; }

        @Override
        public InputStream getInputStream() {
            return new ByteArrayInputStream(bytes);
        }

        @Override
        public void write(String fileName) throws IOException {
            try (FileOutputStream fos = new FileOutputStream(fileName)) {
                fos.write(bytes);
            }
        }

        @Override
        public void delete() {
            throw new UnsupportedOperationException("Cached parts cannot be deleted.");
        }

        @Override
        public String getHeader(String name) {
            if (HEADER_CONTENT_DISPOSITION.equalsIgnoreCase(name)) {
                return "form-data; name=\"" + name + "\"; filename=\"" + submittedFileName + "\"";
            }
            return null;
        }

        @Override
        public Collection<String> getHeaders(String name) {
            String h = getHeader(name);
            return (h != null) ? Collections.singletonList(h) : Collections.emptyList();
        }

        @Override
        public Collection<String> getHeaderNames() {
            return Collections.singletonList(HEADER_CONTENT_DISPOSITION);
        }
    }
}


