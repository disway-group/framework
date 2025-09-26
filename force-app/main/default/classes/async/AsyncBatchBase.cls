public abstract class AsyncBatchBase implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    protected String correlationId = 'CORR-' + System.currentTimeMillis() + '-' + Math.random().intValue();
    
    public abstract Database.QueryLocator start(Database.BatchableContext bc);
    public abstract void execute(Database.BatchableContext bc, List<SObject> scope);
    
    public virtual void finish(Database.BatchableContext bc) { 
        log('Batch', 'Finish', null); 
    }
    
    protected void log(String channel, String category, Exception e) {
        if (!FrameworkSettings.get().enableLogging) return;
        try {
            Map<String, Object> logData = new Map<String, Object>{
                'Channel__c' => channel,
                'Category__c' => category,
                'Correlation_Id__c' => correlationId,
                'Success__c' => e == null,
                'Error__c' => e == null ? null : e.getMessage(),
                'Stacktrace__c' => e == null ? null : e.getStackTraceString()
            };
            IntegrationLogService.logWithFields(logData);
        } catch (Exception ignore) {
            // Logging failed, but we don't want to break the batch execution
        }
    }
}
