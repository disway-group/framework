/**
 * @description Service class for Integration_Log__c operations
 * @author Framework Team
 * @date 2024
 */
public with sharing class IntegrationLogService {
    
    private static final String CLASS_NAME = 'IntegrationLogService';
    
    /**
     * @description Create and insert an integration log in one shot
     * @param channel Channel name (mapped to Channel__c)
     * @param status Status of the integration (Success/Error - mapped to Success__c)
     * @param externalSystem External system name (mapped to Context__c)
     * @param operationType Type of operation (mapped to Category__c)
     * @param correlationId Correlation ID (optional)
     * @param errorMessage Error message (optional)
     * @param stacktrace Stack trace (optional)
     * @return Database.SaveResult Save result
     */
    public static Database.SaveResult log(String channel, String status, String externalSystem, 
                                        String operationType, String correlationId, String errorMessage, String stacktrace) {
        try {
            Integration_Log__c log = new Integration_Log__c();
            log.Channel__c = channel;
            log.Category__c = operationType;  // Map operationType to Category
            log.Context__c = externalSystem;  // Map externalSystem to Context
            log.Correlation_Id__c = String.isNotBlank(correlationId) ? correlationId : generateCorrelationId();
            log.Success__c = !('Error'.equals(status)); // Map status to Success
            
            if (String.isNotBlank(errorMessage)) {
                log.Error__c = errorMessage;
            }
            
            if (String.isNotBlank(stacktrace)) {
                log.Stacktrace__c = stacktrace;
            }
            
            return Database.insert(log, false);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.log: ' + e.getMessage());
            throw e;
        }
    }

    /**
     * @description Create and insert an integration log with dynamic field mapping
     * @param logData Map of field API names to values
     * @return Database.SaveResult Save result
     */
    public static Database.SaveResult logWithFields(Map<String, Object> logData) {
        try {
            Integration_Log__c log = new Integration_Log__c();
            
            // Set fields dynamically
            for (String fieldName : logData.keySet()) {
                try {
                    log.put(fieldName, logData.get(fieldName));
                } catch (Exception e) {
                    // Skip invalid fields silently
                    System.debug(LoggingLevel.WARN, CLASS_NAME + '.logWithFields: Invalid field ' + fieldName + ': ' + e.getMessage());
                }
            }
            
            // Ensure correlation ID is set
            if (String.isBlank(log.Correlation_Id__c)) {
                log.Correlation_Id__c = generateCorrelationId();
            }
            
            return Database.insert(log, false);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.logWithFields: ' + e.getMessage());
            // Don't throw exception to avoid breaking the main flow
            return null;
        }
    }

    /**
     * @description Create a log record without inserting it
     * @param channel Channel name
     * @param category Category name
     * @param context Context information (optional)
     * @return Integration_Log__c Log record
     */
    public static Integration_Log__c createLog(String channel, String category, String context) {
        Integration_Log__c log = new Integration_Log__c();
        log.Channel__c = channel;
        log.Category__c = category;
        log.Correlation_Id__c = generateCorrelationId();
        
        if (String.isNotBlank(context)) {
            log.Context__c = context;
        }
        
        return log;
    }

    /**
     * @description Create an error log record without inserting it
     * @param channel Channel name
     * @param category Category name
     * @param errorMessage Error message
     * @param stacktrace Stack trace (optional)
     * @return Integration_Log__c Log record
     */
    public static Integration_Log__c createErrorLog(String channel, String category, String errorMessage, String stacktrace) {
        Integration_Log__c log = new Integration_Log__c();
        log.Channel__c = channel;
        log.Category__c = category;
        log.Error__c = errorMessage;
        log.Success__c = false;
        log.Correlation_Id__c = generateCorrelationId();
        
        if (String.isNotBlank(stacktrace)) {
            log.Stacktrace__c = stacktrace;
        }
        
        return log;
    }

    /**
     * @description Insert a single log record
     * @param log Integration_Log__c record to insert
     * @return Database.SaveResult Save result
     */
    public static Database.SaveResult insertLog(Integration_Log__c log) {
        try {
            return Database.insert(log, false);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.insertLog: ' + e.getMessage());
            throw e;
        }
    }

    /**
     * @description Insert multiple log records
     * @param logs List of Integration_Log__c records to insert
     * @return Database.SaveResult[] Array of save results
     */
    public static Database.SaveResult[] insertLogs(List<Integration_Log__c> logs) {
        try {
            return Database.insert(logs, false);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.insertLogs: ' + e.getMessage());
            throw e;
        }
    }

    /**
     * @description Update a log record with processing time
     * @param logId ID of the log record to update
     * @param processingTimeMs Processing time in milliseconds
     * @param responsePayload Response payload (optional)
     * @param statusCode Status code (optional)
     */
    public static void updateLogWithProcessingTime(Id logId, Integer processingTimeMs, String responsePayload, Integer statusCode) {
        try {
            Integration_Log__c log = new Integration_Log__c();
            log.Id = logId;
            log.Duration_ms__c = processingTimeMs;
            
            if (String.isNotBlank(responsePayload)) {
                log.Response_Payload__c = responsePayload;
            }
            
            if (statusCode != null) {
                log.Status_Code__c = statusCode;
            }
            
            update log;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.updateLogWithProcessingTime: ' + e.getMessage());
            throw e;
        }
    }

    /**
     * @description Clean up old logs older than specified days
     * @param daysOld Number of days old
     * @return Integer Number of records deleted
     */
    public static Integer cleanupOldLogs(Integer daysOld) {
        try {
            Date cutoffDate = Date.today().addDays(-daysOld);
            List<Integration_Log__c> oldLogs = [SELECT Id FROM Integration_Log__c WHERE CreatedDate < :cutoffDate];
            
            if (!oldLogs.isEmpty()) {
                delete oldLogs;
                return oldLogs.size();
            }
            
            return 0;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.cleanupOldLogs: ' + e.getMessage());
            throw e;
        }
    }

    /**
     * @description Generate a unique correlation ID
     * @return String correlation ID
     */
    private static String generateCorrelationId() {
        return 'CORR-' + System.currentTimeMillis() + '-' + Math.random().intValue();
    }
}