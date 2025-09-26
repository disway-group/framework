public abstract class AsyncQueueJobBase implements Queueable, Database.AllowsCallouts {
    protected Integer maxRetries { get { return FrameworkSettings.get().maxQueueRetries; } }
    protected abstract void handle(AsyncContext ctx);
    public void execute(QueueableContext qc) {
        AsyncContext ctx = new AsyncContext(qc, this);
        Long started = DateTime.now().getTime();
        try {
            handle(ctx);
            log('Queue', 'Success', ctx, started, null);
        } catch (Exception e) {
            ctx.retries++;
            log('Queue', 'Error', ctx, started, e);
            if (ctx.retries <= maxRetries) {
                Integer backoff = FrameworkSettings.get().retryBackoffSeconds;
                if (backoff != null && backoff > 0) {
                    AsyncRetryScheduler.scheduleOnce(backoff, this);
                } else {
                    System.enqueueJob(this);
                }
            } else { throw e; }
        }
    }
    private static void log(String channel, String category, AsyncContext ctx, Long started, Exception e) {
        if (!FrameworkSettings.get().enableLogging) return;
        try {
            IntegrationLogService.log(
                channel, // integrationName
                e == null ? 'Success' : 'Error', // status
                'AsyncQueue', // externalSystem
                category, // operationType
                ctx.correlationId, // correlationId
                e == null ? null : e.getMessage(), // errorMessage
                e == null ? null : e.getStackTraceString() // stacktrace
            );
        } catch (Exception ignore) {}
    }
    public class AsyncContext {
        public String correlationId;
        public String jobName;
        public Integer retries;
        public Map<String,Object> data;
        
        public AsyncContext(QueueableContext qc, Object job) {
            this.correlationId = System.currentTimeMillis() + '-' + String.valueOf(Math.random().intValue());
            this.jobName = String.valueOf(job).split(':')[0];
            this.retries = 0;
            this.data = new Map<String,Object>();
        }               
    }
}
