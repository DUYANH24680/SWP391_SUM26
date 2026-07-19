package Utils;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Filter to prevent browser caching for dynamic pages.
 * This solves the issue where pressing the "Back" button shows data from a previous session or user
 * because the browser restores the DOM from BFCache.
 */
@WebFilter("/*")
public class NoCacheFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
            
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        String uri = req.getRequestURI().toLowerCase();
        
        // Only apply no-cache headers to dynamic routes (ignore static assets)
        if (!uri.endsWith(".css") && !uri.endsWith(".js") && !uri.endsWith(".jpg") 
            && !uri.endsWith(".jpeg") && !uri.endsWith(".png") && !uri.endsWith(".gif") 
            && !uri.endsWith(".svg") && !uri.endsWith(".webp") && !uri.endsWith(".woff") 
            && !uri.endsWith(".woff2") && !uri.endsWith(".ttf") && !uri.endsWith(".ico")) {
            
            res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
            res.setHeader("Pragma", "no-cache"); // HTTP 1.0
            res.setDateHeader("Expires", 0); // Proxies
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
