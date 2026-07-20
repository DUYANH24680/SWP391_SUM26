package listener;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import service.OrderService;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@WebListener
public class OrderAutoCancelListener implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor();
        // Schedule task to run every 30 minutes, checking for unconfirmed orders older than 24 hours.
        scheduler.scheduleAtFixedRate(() -> {
            try {
                OrderService orderService = new OrderService();
                int canceledCount = orderService.cancelLateUnconfirmedOrders(24); // 24 hours threshold
                if (canceledCount > 0) {
                    System.out.println("[OrderAutoCancelListener] Successfully auto-canceled " + canceledCount + " late orders.");
                }
            } catch (Exception e) {
                System.err.println("[OrderAutoCancelListener] Error in auto-cancel runner: " + e.getMessage());
                e.printStackTrace();
            }
        }, 0, 30, TimeUnit.MINUTES);
        System.out.println("[OrderAutoCancelListener] Background scheduler initialized (runs every 30 minutes, threshold 24 hours).");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdown();
            try {
                if (!scheduler.awaitTermination(5, TimeUnit.SECONDS)) {
                    scheduler.shutdownNow();
                }
            } catch (InterruptedException e) {
                scheduler.shutdownNow();
            }
        }
        System.out.println("[OrderAutoCancelListener] Background scheduler destroyed.");
    }
}
