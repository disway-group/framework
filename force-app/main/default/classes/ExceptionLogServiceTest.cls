/**
 * @description Test class for ExceptionLogService
 * @author Framework Team
 * @date 2024
 */
@IsTest
private class ExceptionLogServiceTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test exception logs
        List<Exception_Log__c> testLogs = new List<Exception_Log__c>();
        
        // Create test exceptions
        try {
            throw new DmlException('Test DML Exception');
        } catch (Exception e) {
            testLogs.add(ExceptionLogService.createExceptionLog(e, 'Test Context 1', 'Test Meta 1'));
        }
        
        try {
            throw new CalloutException('Test Callout Exception');
        } catch (Exception e) {
            testLogs.add(ExceptionLogService.createExceptionLog(e, 'Test Context 2'));
        }
        
        try {
            throw new QueryException('Test Query Exception');
        } catch (Exception e) {
            testLogs.add(ExceptionLogService.createExceptionLog(e));
        }
        
        insert testLogs;
    }
    
    @IsTest
    static void testLogExceptionWithAllDetails() {
        Test.startTest();
        
        try {
            throw new DmlException('Test exception with all details');
        } catch (Exception e) {
            Database.SaveResult result = ExceptionLogService.logException(e, 'Test Context', 'Test Meta');
            
            Test.stopTest();
            
            System.assert(result.isSuccess(), 'Exception log should be inserted successfully');
            System.assertNotEquals(null, result.getId(), 'Should have an ID');
            
            // Verify the logged exception
            Exception_Log__c loggedException = [SELECT Id, Message__c, StackTrace__c, ClassName__c, 
                                                      MethodName__c, LineNumber__c, OccurredAt__c, 
                                                      Context__c, Meta__c
                                               FROM Exception_Log__c 
                                               WHERE Id = :result.getId()];
            
            System.assertEquals('Test exception with all details', loggedException.Message__c, 'Message should match');
            System.assertNotEquals(null, loggedException.StackTrace__c, 'Stack trace should not be null');
            System.assertEquals('Test Context', loggedException.Context__c, 'Context should match');
            System.assertEquals('Test Meta', loggedException.Meta__c, 'Meta should match');
            System.assertNotEquals(null, loggedException.OccurredAt__c, 'OccurredAt should not be null');
        }
    }
    
    @IsTest
    static void testLogExceptionWithContext() {
        Test.startTest();
        
        try {
            throw new CalloutException('Test exception with context');
        } catch (Exception e) {
            Database.SaveResult result = ExceptionLogService.logException(e, 'Test Context Only');
            
            Test.stopTest();
            
            System.assert(result.isSuccess(), 'Exception log should be inserted successfully');
            
            Exception_Log__c loggedException = [SELECT Id, Message__c, Context__c, Meta__c
                                               FROM Exception_Log__c 
                                               WHERE Id = :result.getId()];
            
            System.assertEquals('Test exception with context', loggedException.Message__c, 'Message should match');
            System.assertEquals('Test Context Only', loggedException.Context__c, 'Context should match');
            System.assertEquals(null, loggedException.Meta__c, 'Meta should be null');
        }
    }
    
    @IsTest
    static void testLogExceptionMinimal() {
        Test.startTest();
        
        try {
            throw new QueryException('Test minimal exception');
        } catch (Exception e) {
            Database.SaveResult result = ExceptionLogService.logException(e);
            
            Test.stopTest();
            
            System.assert(result.isSuccess(), 'Exception log should be inserted successfully');
            
            Exception_Log__c loggedException = [SELECT Id, Message__c, Context__c, Meta__c
                                               FROM Exception_Log__c 
                                               WHERE Id = :result.getId()];
            
            System.assertEquals('Test minimal exception', loggedException.Message__c, 'Message should match');
            System.assertEquals(null, loggedException.Context__c, 'Context should be null');
            System.assertEquals(null, loggedException.Meta__c, 'Meta should be null');
        }
    }
    
    @IsTest
    static void testCreateExceptionLog() {
        Test.startTest();
        
        try {
            throw new DmlException('Test create exception log');
        } catch (Exception e) {
            Exception_Log__c log = ExceptionLogService.createExceptionLog(e, 'Test Context', 'Test Meta');
            
            Test.stopTest();
            
            System.assertNotEquals(null, log, 'Log should not be null');
            System.assertEquals('Test create exception log', log.Message__c, 'Message should match');
            System.assertNotEquals(null, log.StackTrace__c, 'Stack trace should not be null');
            System.assertEquals('Test Context', log.Context__c, 'Context should match');
            System.assertEquals('Test Meta', log.Meta__c, 'Meta should match');
            System.assertNotEquals(null, log.OccurredAt__c, 'OccurredAt should not be null');
        }
    }
    
    @IsTest
    static void testCreateExceptionLogMinimal() {
        Test.startTest();
        
        try {
            throw new CalloutException('Test create minimal exception log');
        } catch (Exception e) {
            Exception_Log__c log = ExceptionLogService.createExceptionLog(e);
            
            Test.stopTest();
            
            System.assertNotEquals(null, log, 'Log should not be null');
            System.assertEquals('Test create minimal exception log', log.Message__c, 'Message should match');
            System.assertEquals(null, log.Context__c, 'Context should be null');
            System.assertEquals(null, log.Meta__c, 'Meta should be null');
        }
    }
    
    @IsTest
    static void testInsertExceptionLog() {
        Test.startTest();
        
        try {
            throw new QueryException('Test insert exception log');
        } catch (Exception e) {
            Exception_Log__c log = ExceptionLogService.createExceptionLog(e, 'Test Context');
            Database.SaveResult result = ExceptionLogService.insertExceptionLog(log);
            
            Test.stopTest();
            
            System.assert(result.isSuccess(), 'Insert should be successful');
            System.assertNotEquals(null, result.getId(), 'Should have an ID');
        }
    }
    
    @IsTest
    static void testInsertExceptionLogs() {
        Test.startTest();
        
        List<Exception_Log__c> logs = new List<Exception_Log__c>();
        
        try {
            throw new DmlException('Test insert logs 1');
        } catch (Exception e) {
            logs.add(ExceptionLogService.createExceptionLog(e, 'Context 1'));
        }
        
        try {
            throw new CalloutException('Test insert logs 2');
        } catch (Exception e) {
            logs.add(ExceptionLogService.createExceptionLog(e, 'Context 2'));
        }
        
        Database.SaveResult[] results = ExceptionLogService.insertExceptionLogs(logs);
        
        Test.stopTest();
        
        System.assertEquals(2, results.size(), 'Should have 2 results');
        System.assert(results[0].isSuccess(), 'First insert should be successful');
        System.assert(results[1].isSuccess(), 'Second insert should be successful');
    }
    
    @IsTest
    static void testGetExceptionLogsByClassName() {
        // Get a test log from setup
        Exception_Log__c testLog = [SELECT ClassName__c FROM Exception_Log__c LIMIT 1];
        
        Test.startTest();
        
        List<Exception_Log__c> logs = ExceptionLogService.getExceptionLogsByClassName(testLog.ClassName__c, 10);
        
        Test.stopTest();
        
        System.assertNotEquals(null, logs, 'Logs should not be null');
        System.assert(logs.size() > 0, 'Should find at least 1 log');
        
        for (Exception_Log__c log : logs) {
            System.assertEquals(testLog.ClassName__c, log.ClassName__c, 'Class name should match');
        }
    }
    
    @IsTest
    static void testGetExceptionLogsByMethodName() {
        // Get a test log from setup
        Exception_Log__c testLog = [SELECT MethodName__c FROM Exception_Log__c WHERE MethodName__c != null LIMIT 1];
        
        Test.startTest();
        
        List<Exception_Log__c> logs = ExceptionLogService.getExceptionLogsByMethodName(testLog.MethodName__c, 10);
        
        Test.stopTest();
        
        System.assertNotEquals(null, logs, 'Logs should not be null');
        
        for (Exception_Log__c log : logs) {
            System.assertEquals(testLog.MethodName__c, log.MethodName__c, 'Method name should match');
        }
    }
    
    @IsTest
    static void testGetExceptionLogsByDateRange() {
        Date startDate = Date.today().addDays(-1);
        Date endDate = Date.today().addDays(1);
        
        Test.startTest();
        
        List<Exception_Log__c> logs = ExceptionLogService.getExceptionLogsByDateRange(startDate, endDate);
        
        Test.stopTest();
        
        System.assertNotEquals(null, logs, 'Logs should not be null');
        System.assertEquals(3, logs.size(), 'Should find 3 logs from setup');
        
        for (Exception_Log__c log : logs) {
            System.assert(log.OccurredAt__c.date() >= startDate, 'Log should be within date range');
            System.assert(log.OccurredAt__c.date() <= endDate, 'Log should be within date range');
        }
    }
    
    @IsTest
    static void testGetRecentExceptionLogs() {
        Test.startTest();
        
        List<Exception_Log__c> logs = ExceptionLogService.getRecentExceptionLogs(5);
        
        Test.stopTest();
        
        System.assertNotEquals(null, logs, 'Logs should not be null');
        System.assertEquals(3, logs.size(), 'Should find 3 logs from setup');
        
        // Verify they are ordered by OccurredAt DESC
        for (Integer i = 1; i < logs.size(); i++) {
            System.assert(logs[i-1].OccurredAt__c >= logs[i].OccurredAt__c, 'Logs should be ordered by OccurredAt DESC');
        }
    }
    
    @IsTest
    static void testCleanupOldExceptionLogs() {
        // Create an old log
        try {
            throw new DmlException('Old exception');
        } catch (Exception e) {
            Exception_Log__c oldLog = ExceptionLogService.createExceptionLog(e);
            insert oldLog;
            
            // Update the created date to be old
            Test.setCreatedDate(oldLog.Id, Date.today().addDays(-10));
            
            Test.startTest();
            
            Integer deletedCount = ExceptionLogService.cleanupOldExceptionLogs(5);
            
            Test.stopTest();
            
            System.assertEquals(1, deletedCount, 'Should delete 1 old log');
            
            // Verify the log was deleted
            List<Exception_Log__c> remainingLogs = [SELECT Id FROM Exception_Log__c WHERE Id = :oldLog.Id];
            System.assertEquals(0, remainingLogs.size(), 'Old log should be deleted');
        }
    }
    
    @IsTest
    static void testCleanupOldExceptionLogsNoOldLogs() {
        Test.startTest();
        
        Integer deletedCount = ExceptionLogService.cleanupOldExceptionLogs(1);
        
        Test.stopTest();
        
        System.assertEquals(0, deletedCount, 'Should delete 0 logs when no old logs exist');
    }
    
    @IsTest
    static void testStackTraceParsing() {
        Test.startTest();
        
        try {
            throw new DmlException('Test stack trace parsing');
        } catch (Exception e) {
            Exception_Log__c log = ExceptionLogService.createExceptionLog(e);
            
            Test.stopTest();
            
            // Verify that stack trace parsing worked
            System.assertNotEquals(null, log.StackTrace__c, 'Stack trace should not be null');
            // Note: In test context, the actual class/method names might be different
            // so we just verify that the parsing didn't cause errors
        }
    }
    
    @IsTest
    static void testExceptionLoggingWithNullValues() {
        Test.startTest();
        
        try {
            throw new DmlException('Test with null values');
        } catch (Exception e) {
            Database.SaveResult result = ExceptionLogService.logException(e, null, null);
            
            Test.stopTest();
            
            System.assert(result.isSuccess(), 'Exception log should be inserted successfully');
            
            Exception_Log__c loggedException = [SELECT Id, Message__c, Context__c, Meta__c
                                               FROM Exception_Log__c 
                                               WHERE Id = :result.getId()];
            
            System.assertEquals('Test with null values', loggedException.Message__c, 'Message should match');
            System.assertEquals(null, loggedException.Context__c, 'Context should be null');
            System.assertEquals(null, loggedException.Meta__c, 'Meta should be null');
        }
    }
    
    @IsTest
    static void testExceptionLoggingWithEmptyStrings() {
        Test.startTest();
        
        try {
            throw new DmlException('Test with empty strings');
        } catch (Exception e) {
            Database.SaveResult result = ExceptionLogService.logException(e, '', '');
            
            Test.stopTest();
            
            System.assert(result.isSuccess(), 'Exception log should be inserted successfully');
            
            Exception_Log__c loggedException = [SELECT Id, Message__c, Context__c, Meta__c
                                               FROM Exception_Log__c 
                                               WHERE Id = :result.getId()];
            
            System.assertEquals('Test with empty strings', loggedException.Message__c, 'Message should match');
            System.assertEquals(null, loggedException.Context__c, 'Context should be null for empty string');
            System.assertEquals(null, loggedException.Meta__c, 'Meta should be null for empty string');
        }
    }
}
