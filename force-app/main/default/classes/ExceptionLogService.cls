/**
 * @description Service class for Exception_Log__c operations
 * @author Framework Team
 * @date 2024
 */
public with sharing class ExceptionLogService {
    
    private static final String CLASS_NAME = 'ExceptionLogService';
    
    /**
     * @description Log an exception with all details
     * @param exceptionObj The exception to log
     * @param context Additional context information (optional)
     * @param meta Additional metadata (optional)
     * @return Database.SaveResult Save result
     */
    public static Database.SaveResult logException(Exception exceptionObj, String context, String meta) {
        try {
            Exception_Log__c log = new Exception_Log__c();
            log.Message__c = exceptionObj.getMessage();
            log.StackTrace__c = exceptionObj.getStackTraceString();
            log.ClassName__c = getClassNameFromStackTrace(exceptionObj.getStackTraceString());
            log.MethodName__c = getMethodNameFromStackTrace(exceptionObj.getStackTraceString());
            log.LineNumber__c = getLineNumberFromStackTrace(exceptionObj.getStackTraceString());
            log.OccurredAt__c = System.now();
            
            if (String.isNotBlank(context)) {
                log.Context__c = context;
            }
            
            if (String.isNotBlank(meta)) {
                log.Meta__c = meta;
            }
            
            return Database.insert(log, false);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.logException: ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Log an exception with minimal details
     * @param exceptionObj The exception to log
     * @return Database.SaveResult Save result
     */
    public static Database.SaveResult logException(Exception exceptionObj) {
        return logException(exceptionObj, null, null);
    }
    
    /**
     * @description Log an exception with context
     * @param exceptionObj The exception to log
     * @param context Additional context information
     * @return Database.SaveResult Save result
     */
    public static Database.SaveResult logException(Exception exceptionObj, String context) {
        return logException(exceptionObj, context, null);
    }
    
    /**
     * @description Create an exception log record without inserting
     * @param exceptionObj The exception to log
     * @param context Additional context information (optional)
     * @param meta Additional metadata (optional)
     * @return Exception_Log__c The created log record
     */
    public static Exception_Log__c createExceptionLog(Exception exceptionObj, String context, String meta) {
        Exception_Log__c log = new Exception_Log__c();
        log.Message__c = exceptionObj.getMessage();
        log.StackTrace__c = exceptionObj.getStackTraceString();
        log.ClassName__c = getClassNameFromStackTrace(exceptionObj.getStackTraceString());
        log.MethodName__c = getMethodNameFromStackTrace(exceptionObj.getStackTraceString());
        log.LineNumber__c = getLineNumberFromStackTrace(exceptionObj.getStackTraceString());
        log.OccurredAt__c = System.now();
        
        if (String.isNotBlank(context)) {
            log.Context__c = context;
        }
        
        if (String.isNotBlank(meta)) {
            log.Meta__c = meta;
        }
        
        return log;
    }
    
    /**
     * @description Create an exception log record without inserting (minimal)
     * @param exceptionObj The exception to log
     * @return Exception_Log__c The created log record
     */
    public static Exception_Log__c createExceptionLog(Exception exceptionObj) {
        return createExceptionLog(exceptionObj, null, null);
    }
    
    /**
     * @description Insert a single exception log
     * @param log The exception log to insert
     * @return Database.SaveResult Save result
     */
    public static Database.SaveResult insertExceptionLog(Exception_Log__c log) {
        try {
            return Database.insert(log, false);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.insertExceptionLog: ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Insert multiple exception logs
     * @param logs List of exception logs to insert
     * @return Database.SaveResult[] Save results
     */
    public static Database.SaveResult[] insertExceptionLogs(List<Exception_Log__c> logs) {
        try {
            return Database.insert(logs, false);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.insertExceptionLogs: ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Get exception logs by class name
     * @param className The class name to search for
     * @param limitCount Maximum number of records to return
     * @return List<Exception_Log__c> List of exception logs
     */
    public static List<Exception_Log__c> getExceptionLogsByClassName(String className, Integer limitCount) {
        try {
            return [SELECT Id, Message__c, StackTrace__c, ClassName__c, MethodName__c, 
                           LineNumber__c, OccurredAt__c, Context__c, Meta__c
                    FROM Exception_Log__c 
                    WHERE ClassName__c = :className 
                    ORDER BY OccurredAt__c DESC 
                    LIMIT :limitCount];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getExceptionLogsByClassName: ' + e.getMessage());
            return new List<Exception_Log__c>();
        }
    }
    
    /**
     * @description Get exception logs by method name
     * @param methodName The method name to search for
     * @param limitCount Maximum number of records to return
     * @return List<Exception_Log__c> List of exception logs
     */
    public static List<Exception_Log__c> getExceptionLogsByMethodName(String methodName, Integer limitCount) {
        try {
            return [SELECT Id, Message__c, StackTrace__c, ClassName__c, MethodName__c, 
                           LineNumber__c, OccurredAt__c, Context__c, Meta__c
                    FROM Exception_Log__c 
                    WHERE MethodName__c = :methodName 
                    ORDER BY OccurredAt__c DESC 
                    LIMIT :limitCount];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getExceptionLogsByMethodName: ' + e.getMessage());
            return new List<Exception_Log__c>();
        }
    }
    
    /**
     * @description Get exception logs within a date range
     * @param startDate Start date for the range
     * @param endDate End date for the range
     * @return List<Exception_Log__c> List of exception logs
     */
    public static List<Exception_Log__c> getExceptionLogsByDateRange(Date startDate, Date endDate) {
        try {
            DateTime startDateTime = DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0));
            DateTime endDateTime = DateTime.newInstance(endDate, Time.newInstance(23, 59, 59, 999));
            
            return [SELECT Id, Message__c, StackTrace__c, ClassName__c, MethodName__c, 
                           LineNumber__c, OccurredAt__c, Context__c, Meta__c
                    FROM Exception_Log__c 
                    WHERE OccurredAt__c >= :startDateTime 
                    AND OccurredAt__c <= :endDateTime
                    ORDER BY OccurredAt__c DESC];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getExceptionLogsByDateRange: ' + e.getMessage());
            return new List<Exception_Log__c>();
        }
    }
    
    /**
     * @description Get recent exception logs
     * @param limitCount Maximum number of records to return
     * @return List<Exception_Log__c> List of exception logs
     */
    public static List<Exception_Log__c> getRecentExceptionLogs(Integer limitCount) {
        try {
            return [SELECT Id, Message__c, StackTrace__c, ClassName__c, MethodName__c, 
                           LineNumber__c, OccurredAt__c, Context__c, Meta__c
                    FROM Exception_Log__c 
                    ORDER BY OccurredAt__c DESC 
                    LIMIT :limitCount];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecentExceptionLogs: ' + e.getMessage());
            return new List<Exception_Log__c>();
        }
    }
    
    /**
     * @description Clean up old exception logs
     * @param daysOld Number of days old to consider for cleanup
     * @return Integer Number of records deleted
     */
    public static Integer cleanupOldExceptionLogs(Integer daysOld) {
        try {
            DateTime cutoffDate = DateTime.now().addDays(-daysOld);
            
            List<Exception_Log__c> oldLogs = [SELECT Id FROM Exception_Log__c WHERE OccurredAt__c < :cutoffDate];
            
            if (!oldLogs.isEmpty()) {
                delete oldLogs;
                return oldLogs.size();
            }
            
            return 0;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.cleanupOldExceptionLogs: ' + e.getMessage());
            return 0;
        }
    }
    
    /**
     * @description Extract class name from stack trace
     * @param stackTrace The stack trace string
     * @return String The class name
     */
    private static String getClassNameFromStackTrace(String stackTrace) {
        if (String.isBlank(stackTrace)) {
            return null;
        }
        
        try {
            // Stack trace format: ClassName.methodName:lineNumber
            String[] lines = stackTrace.split('\n');
            if (lines.size() > 0) {
                String firstLine = lines[0].trim();
                if (firstLine.contains('.')) {
                    String[] parts = firstLine.split('\\.');
                    if (parts.size() > 0) {
                        return parts[0];
                    }
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Error parsing class name from stack trace: ' + e.getMessage());
        }
        
        return null;
    }
    
    /**
     * @description Extract method name from stack trace
     * @param stackTrace The stack trace string
     * @return String The method name
     */
    private static String getMethodNameFromStackTrace(String stackTrace) {
        if (String.isBlank(stackTrace)) {
            return null;
        }
        
        try {
            // Stack trace format: ClassName.methodName:lineNumber
            String[] lines = stackTrace.split('\n');
            if (lines.size() > 0) {
                String firstLine = lines[0].trim();
                if (firstLine.contains('.')) {
                    String[] parts = firstLine.split('\\.');
                    if (parts.size() > 1) {
                        String methodPart = parts[1];
                        if (methodPart.contains(':')) {
                            return methodPart.split(':')[0];
                        }
                        return methodPart;
                    }
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Error parsing method name from stack trace: ' + e.getMessage());
        }
        
        return null;
    }
    
    /**
     * @description Extract line number from stack trace
     * @param stackTrace The stack trace string
     * @return Integer The line number
     */
    private static Integer getLineNumberFromStackTrace(String stackTrace) {
        if (String.isBlank(stackTrace)) {
            return null;
        }
        
        try {
            // Stack trace format: ClassName.methodName:lineNumber
            String[] lines = stackTrace.split('\n');
            if (lines.size() > 0) {
                String firstLine = lines[0].trim();
                if (firstLine.contains(':')) {
                    String[] parts = firstLine.split(':');
                    if (parts.size() > 1) {
                        String lineNumberStr = parts[parts.size() - 1];
                        return Integer.valueOf(lineNumberStr);
                    }
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Error parsing line number from stack trace: ' + e.getMessage());
        }
        
        return null;
    }
}
