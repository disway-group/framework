@IsTest
private class IntegrationLogServiceTest {

    @TestSetup
    static void setupTestData() {
        List<Integration_Log__c> logs = new List<Integration_Log__c>();

        logs.add(IntegrationLogService.createLog('Integration1', 'Outbound', 'External1'));
        logs.add(IntegrationLogService.createLog('Integration2', 'Inbound', 'External2'));
        logs.add(IntegrationLogService.createErrorLog('Integration3', 'Bulk', 'Test Error', 'Stacktrace'));

        insert logs;
    }

    @IsTest
    static void testCreateLog() {
        Test.startTest();
        Integration_Log__c log = IntegrationLogService.createLog('IntegrationTest', 'Outbound', 'ExternalSys');
        Test.stopTest();

        System.assertNotEquals(null, log);
        System.assertEquals('IntegrationTest', log.Channel__c);
        System.assertEquals('Outbound', log.Category__c);
        System.assertEquals('ExternalSys', log.Context__c);
        System.assertNotEquals(null, log.Correlation_Id__c);
    }

    @IsTest
    static void testCreateErrorLog() {
        Test.startTest();
        Integration_Log__c log = IntegrationLogService.createErrorLog('IntegrationError', 'Inbound', 'Error occurred', 'Stacktrace');
        Test.stopTest();

        System.assertEquals(false, log.Success__c);
        System.assertEquals('Error occurred', log.Error__c);
        System.assertEquals('Inbound', log.Category__c);
        System.assertNotEquals(null, log.Correlation_Id__c);
    }

    @IsTest
    static void testInsertLogs() {
        List<Integration_Log__c> logs = new List<Integration_Log__c>();
        logs.add(IntegrationLogService.createLog('Log1', 'Outbound', 'External1'));
        logs.add(IntegrationLogService.createLog('Log2', 'Inbound', 'External2'));

        Test.startTest();
        Database.SaveResult[] results = IntegrationLogService.insertLogs(logs);
        Test.stopTest();

        System.assertEquals(2, results.size());
        System.assert(results[0].isSuccess());
        System.assert(results[1].isSuccess());
    }

    @IsTest
    static void testInsertLog() {
        Integration_Log__c log = IntegrationLogService.createLog('LogSingle', 'Outbound', 'ExternalSys');

        Test.startTest();
        Database.SaveResult result = IntegrationLogService.insertLog(log);
        Test.stopTest();

        System.assert(result.isSuccess());
        System.assertNotEquals(null, result.getId());
    }

    @IsTest
    static void testUpdateLogWithProcessingTime() {
        Integration_Log__c log = IntegrationLogService.createLog('IntegrationUpdate', 'Outbound', 'ExternalSys');
        insert log;

        Test.startTest();
        IntegrationLogService.updateLogWithProcessingTime(log.Id, 1500, 'ResponsePayload', 200);
        Test.stopTest();

        Integration_Log__c updated = [SELECT Duration_ms__c, Response_Payload__c, Status_Code__c FROM Integration_Log__c WHERE Id = :log.Id];
        System.assertEquals(1500, updated.Duration_ms__c);
        System.assertEquals('ResponsePayload', updated.Response_Payload__c);
        System.assertEquals(200, updated.Status_Code__c);
    }

    @IsTest
    static void testCleanupOldLogs() {
        Integration_Log__c oldLog = IntegrationLogService.createLog('OldIntegration', 'Outbound', 'ExternalSys');
        insert oldLog;
        Test.setCreatedDate(oldLog.Id, Date.today().addDays(-10));

        Test.startTest();
        Integer deletedCount = IntegrationLogService.cleanupOldLogs(5);
        Test.stopTest();

        System.assertEquals(1, deletedCount);
        System.assertEquals(0, [SELECT COUNT() FROM Integration_Log__c WHERE Id = :oldLog.Id]);
    }
}