package Utils;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;

import java.io.IOException;

/**
 * Intercepts multipart/form-data POST requests to /add-product and replaces
 * the raw HttpServletRequest with a MultipartRequestWrapper so that:
 *   - Text form fields are accessible via getParameter() (fixes the root bug)
 *   - File parts are cached as byte arrays so getPart() / getParts() still work
 *
 * The filter runs BEFORE the servlet, so when AddProductServlet calls
 * request.getParameter("title") it gets the real value instead of null.
 */
@WebFilter(urlPatterns = {"/add-product"})
public class MultipartFilter implements Filter {

    private FilterConfig filterConfig;

    @Override
    public void init(FilterConfig filterConfig) {
        this.filterConfig = filterConfig;
    }

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse,
                         FilterChain chain) throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) servletRequest;
        String contentType = httpRequest.getContentType();

        if (contentType != null && contentType.toLowerCase().startsWith("multipart/form-data")) {
            filterConfig.getServletContext().log("[MultipartFilter] Multipart request detected, wrapping request for /add-product");
            MultipartRequestWrapper wrapped = new MultipartRequestWrapper(httpRequest);
            chain.doFilter(wrapped, servletResponse);
        } else {
            chain.doFilter(servletRequest, servletResponse);
        }
    }
}

