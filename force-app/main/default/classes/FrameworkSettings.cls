public with sharing class FrameworkSettings {
    public class Values {
        public Integer maxQueueRetries;
        public Integer defaultBatchSize;
        public Boolean enableLogging;
        public Integer retryBackoffSeconds;
    }
    private static Values cached;
    public static Values get() {
        if (cached != null) return cached;
        cached = new Values();
        cached.maxQueueRetries = 2;
        cached.defaultBatchSize = 200;
        cached.enableLogging = true;
        cached.retryBackoffSeconds = 0;
        try {
            Framework_Settings__mdt s = [
                SELECT Max_Queue_Retries__c, Default_Batch_Size__c, Enable_Logging__c, Retry_Backoff_Seconds__c
                FROM Framework_Settings__mdt
                WHERE DeveloperName = 'Default' LIMIT 1
            ];
            if (s.Max_Queue_Retries__c != null)      cached.maxQueueRetries = Integer.valueOf(s.Max_Queue_Retries__c);
            if (s.Default_Batch_Size__c != null)     cached.defaultBatchSize = Integer.valueOf(s.Default_Batch_Size__c);
            if (s.Enable_Logging__c != null)         cached.enableLogging = s.Enable_Logging__c;
            if (s.Retry_Backoff_Seconds__c != null)  cached.retryBackoffSeconds = Integer.valueOf(s.Retry_Backoff_Seconds__c);
        } catch (Exception ignore) {}
        return cached;
    }
    @TestVisible static void resetCache() { cached = null; }
}
