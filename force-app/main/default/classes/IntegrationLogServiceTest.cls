/**
 * @description Test class for IntegrationLogService
 * @author Framework Team
 * @date 2024
 */
@IsTest
private class IntegrationLogServiceTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test integration logs
        List<Integration_Log__c> testLogs = new List<Integration_Log__c>();
        
        testLogs.add(IntegrationLogService.createLog('Test Integration', 'Success', 'External System', 'Outbound'));
        testLogs.add(IntegrationLogService.createLog('Test Integration 2', 'Error', 'External System 2', 'Inbound'));
        testLogs.add(IntegrationLogService.createErrorLog('Test Integration 3', 'External System 3', 'Bulk', 'Test Error', 500));
        
        insert testLogs;
    }
    
    @IsTest
    static void testCreateLog() {
        Test.startTest();
        
        Integration_Log__c log = IntegrationLogService.createLog('Test Integration', 'Success', 'External System', 'Outbound');
        
        Test.stopTest();
        
        System.assertNotEquals(null, log, 'Log should not be null');
        System.assertEquals('Test Integration', log.Integration_Name__c, 'Integration name should match');
        System.assertEquals('Success', log.Status__c, 'Status should match');
        System.assertEquals('External System', log.External_System__c, 'External system should match');
        System.assertEquals('Outbound', log.Operation_Type__c, 'Operation type should match');
        System.assertNotEquals(null, log.Correlation_Id__c, 'Correlation ID should be generated');
    }
    
    @IsTest
    static void testCreateLogWithRequestResponse() {
        Test.startTest();
        
        Integration_Log__c log = IntegrationLogService.createLog('Test Integration', 'Success', 'External System', 
                                                                'Outbound', 'Request Body', 'Response Body', 200);
        
        Test.stopTest();
        
        System.assertEquals('Request Body', log.Request_Body__c, 'Request body should match');
        System.assertEquals('Response Body', log.Response_Body__c, 'Response body should match');
        System.assertEquals(200, log.HTTP_Status_Code__c, 'HTTP status code should match');
    }
    
    @IsTest
    static void testCreateErrorLog() {
        Test.startTest();
        
        Integration_Log__c log = IntegrationLogService.createErrorLog('Test Integration', 'External System', 
                                                                     'Outbound', 'Test Error', 500);
        
        Test.stopTest();
        
        System.assertEquals('Error', log.Status__c, 'Status should be Error');
        System.assertEquals('Test Error', log.Error_Message__c, 'Error message should match');
        System.assertEquals(500, log.HTTP_Status_Code__c, 'HTTP status code should match');
    }
    
    @IsTest
    static void testInsertLogs() {
        Test.startTest();
        
        List<Integration_Log__c> logs = new List<Integration_Log__c>();
        logs.add(IntegrationLogService.createLog('Test Integration 1', 'Success', 'External System 1', 'Outbound'));
        logs.add(IntegrationLogService.createLog('Test Integration 2', 'Error', 'External System 2', 'Inbound'));
        
        Database.SaveResult[] results = IntegrationLogService.insertLogs(logs);
        
        Test.stopTest();
        
        System.assertEquals(2, results.size(), 'Should have 2 results');
        System.assert(results[0].isSuccess(), 'First insert should be successful');
        System.assert(results[1].isSuccess(), 'Second insert should be successful');
    }
    
    @IsTest
    static void testInsertLog() {
        Test.startTest();
        
        Integration_Log__c log = IntegrationLogService.createLog('Test Integration', 'Success', 'External System', 'Outbound');
        Database.SaveResult result = IntegrationLogService.insertLog(log);
        
        Test.stopTest();
        
        System.assert(result.isSuccess(), 'Insert should be successful');
        System.assertNotEquals(null, result.getId(), 'Should have an ID');
    }
    
    @IsTest
    static void testUpdateLogWithProcessingTime() {
        // Create a test log first
        Integration_Log__c testLog = IntegrationLogService.createLog('Test Integration', 'In Progress', 'External System', 'Outbound');
        insert testLog;
        
        Test.startTest();
        
        IntegrationLogService.updateLogWithProcessingTime(testLog.Id, 1500, 'Success', 'Response Body', 200);
        
        Test.stopTest();
        
        // Verify the update
        Integration_Log__c updatedLog = [SELECT Id, Processing_Time_MS__c, Status__c, Response_Body__c, HTTP_Status_Code__c 
                                        FROM Integration_Log__c WHERE Id = :testLog.Id];
        
        System.assertEquals(1500, updatedLog.Processing_Time_MS__c, 'Processing time should match');
        System.assertEquals('Success', updatedLog.Status__c, 'Status should be updated');
        System.assertEquals('Response Body', updatedLog.Response_Body__c, 'Response body should match');
        System.assertEquals(200, updatedLog.HTTP_Status_Code__c, 'HTTP status code should match');
    }
    
    @IsTest
    static void testGetLogsByCorrelationId() {
        // Get a test log from setup
        Integration_Log__c testLog = [SELECT Correlation_Id__c FROM Integration_Log__c LIMIT 1];
        
        Test.startTest();
        
        List<Integration_Log__c> logs = IntegrationLogService.getLogsByCorrelationId(testLog.Correlation_Id__c);
        
        Test.stopTest();
        
        System.assertNotEquals(null, logs, 'Logs should not be null');
        System.assertEquals(1, logs.size(), 'Should find 1 log');
        System.assertEquals(testLog.Correlation_Id__c, logs[0].Correlation_Id__c, 'Correlation ID should match');
    }
    
    @IsTest
    static void testGetLogsByIntegrationName() {
        Test.startTest();
        
        List<Integration_Log__c> logs = IntegrationLogService.getLogsByIntegrationName('Test Integration', 10);
        
        Test.stopTest();
        
        System.assertNotEquals(null, logs, 'Logs should not be null');
        System.assertEquals(1, logs.size(), 'Should find 1 log');
        System.assertEquals('Test Integration', logs[0].Integration_Name__c, 'Integration name should match');
    }
    
    @IsTest
    static void testGetErrorLogs() {
        Date startDate = Date.today().addDays(-1);
        Date endDate = Date.today().addDays(1);
        
        Test.startTest();
        
        List<Integration_Log__c> errorLogs = IntegrationLogService.getErrorLogs(startDate, endDate);
        
        Test.stopTest();
        
        System.assertNotEquals(null, errorLogs, 'Error logs should not be null');
        System.assertEquals(2, errorLogs.size(), 'Should find 2 error logs');
        
        for (Integration_Log__c log : errorLogs) {
            System.assertEquals('Error', log.Status__c, 'All logs should have Error status');
        }
    }
    
    @IsTest
    static void testCleanupOldLogs() {
        // Create an old log
        Integration_Log__c oldLog = IntegrationLogService.createLog('Old Integration', 'Success', 'External System', 'Outbound');
        insert oldLog;
        
        // Update the created date to be old
        Test.setCreatedDate(oldLog.Id, Date.today().addDays(-10));
        
        Test.startTest();
        
        Integer deletedCount = IntegrationLogService.cleanupOldLogs(5);
        
        Test.stopTest();
        
        System.assertEquals(1, deletedCount, 'Should delete 1 old log');
        
        // Verify the log was deleted
        List<Integration_Log__c> remainingLogs = [SELECT Id FROM Integration_Log__c WHERE Id = :oldLog.Id];
        System.assertEquals(0, remainingLogs.size(), 'Old log should be deleted');
    }
}

