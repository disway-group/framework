/**
 * @description Test class for ExceptionLogService
 * @author Framework
 * @date 2025
 */
@IsTest
private class ExceptionLogServiceTest {
    
    @TestSetup
    static void setupTestData() {
        List<Exception_Log__c> logs = new List<Exception_Log__c>();
        
        try {
            throw new DmlException('Test DML Exception');
        } catch (Exception e) {
            logs.add(ExceptionLogService.createExceptionLog(e, 'Context 1', 'Meta 1'));
        }
        try {
            throw new CalloutException('Test Callout Exception');
        } catch (Exception e) {
            logs.add(ExceptionLogService.createExceptionLog(e, 'Context 2', null));
        }
        try {
            throw new QueryException('Test Query Exception');
        } catch (Exception e) {
            logs.add(ExceptionLogService.createExceptionLog(e, null, null));
        }
        insert logs;
    }
    
    @IsTest
    static void testLogExceptionWithAllDetails() {
        Test.startTest();
        Database.SaveResult result;
        try {
            throw new DmlException('Test exception with all details');
        } catch (Exception e) {
            result = ExceptionLogService.logException(e, 'Test Context', 'Test Meta');
        }
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.isSuccess(), 'Insert should succeed');

        Exception_Log__c log = [
            SELECT Message__c, Context__c, Meta__c, StackTrace__c, OccurredAt__c
            FROM Exception_Log__c WHERE Id = :result.getId()
        ];

        System.assertEquals('Test exception with all details', log.Message__c);
        System.assertEquals('Test Context', log.Context__c);
        System.assertEquals('Test Meta', log.Meta__c);
        System.assertNotEquals(null, log.StackTrace__c);
        System.assertNotEquals(null, log.OccurredAt__c);
    }

    @IsTest
    static void testLogExceptionWithContext() {
        Test.startTest();
        Database.SaveResult result;
        try {
            throw new CalloutException('Test exception with context');
        } catch (Exception e) {
            result = ExceptionLogService.logException(e, 'Context Only');
        }
        Test.stopTest();

        Exception_Log__c log = [
            SELECT Message__c, Context__c, Meta__c FROM Exception_Log__c WHERE Id = :result.getId()
        ];

        System.assertEquals('Test exception with context', log.Message__c);
        System.assertEquals('Context Only', log.Context__c);
        System.assertEquals(null, log.Meta__c);
    }

    @IsTest
    static void testLogExceptionMinimal() {
        Test.startTest();
        Database.SaveResult result;
        try {
            throw new QueryException('Test minimal');
        } catch (Exception e) {
            result = ExceptionLogService.logException(e);
        }
        Test.stopTest();

        Exception_Log__c log = [
            SELECT Message__c, Context__c, Meta__c FROM Exception_Log__c WHERE Id = :result.getId()
        ];

        System.assertEquals('Test minimal', log.Message__c);
        System.assertEquals(null, log.Context__c);
        System.assertEquals(null, log.Meta__c);
    }

    @IsTest
    static void testCreateExceptionLog() {
        try {
            throw new DmlException('Create Exception');
        } catch (Exception e) {
            Exception_Log__c log = ExceptionLogService.createExceptionLog(e, 'Ctx', 'Meta');
            System.assertEquals('Create Exception', log.Message__c);
            System.assertEquals('Ctx', log.Context__c);
            System.assertEquals('Meta', log.Meta__c);
        }
    }

    @IsTest
    static void testInsertExceptionLogs() {
        List<Exception_Log__c> listLogs = new List<Exception_Log__c>();
        try {
            throw new DmlException('Insert batch 1');
        } catch (Exception e) {
            listLogs.add(ExceptionLogService.createExceptionLog(e, 'Batch1', null));
        }
        try {
            throw new CalloutException('Insert batch 2');
        } catch (Exception e) {
            listLogs.add(ExceptionLogService.createExceptionLog(e, 'Batch2', null));
        }

        Test.startTest();
        Database.SaveResult[] results = ExceptionLogService.insertExceptionLogs(listLogs);
        Test.stopTest();

        System.assertEquals(2, results.size());
        System.assert(results[0].isSuccess());
        System.assert(results[1].isSuccess());
    }

    @IsTest
    static void testCleanupOldExceptionLogs() {
        Exception_Log__c oldLog;
        try {
            throw new DmlException('Old one');
        } catch (Exception e) {
            oldLog = ExceptionLogService.createExceptionLog(e);
            insert oldLog;
            Test.setCreatedDate(oldLog.Id, Date.today().addDays(-10));
        }

        Test.startTest();
        Integer deletedCount = ExceptionLogService.cleanupOldExceptionLogs(5);
        Test.stopTest();

        System.assertEquals(1, deletedCount);
        System.assertEquals(0, [SELECT COUNT() FROM Exception_Log__c WHERE Id = :oldLog.Id]);
    }

    @IsTest
    static void testExceptionLoggingWithNullsAndEmpties() {
        // Null values
        Database.SaveResult nullResult;
        try {
            throw new DmlException('Nulls');
        } catch (Exception e) {
            nullResult = ExceptionLogService.logException(e, null, null);
        }

        Exception_Log__c nullLog = [
            SELECT Context__c, Meta__c FROM Exception_Log__c WHERE Id = :nullResult.getId()
        ];
        System.assertEquals(null, nullLog.Context__c);
        System.assertEquals(null, nullLog.Meta__c);

        // Empty strings
        Database.SaveResult emptyResult;
        try {
            throw new DmlException('Empties');
        } catch (Exception e) {
            emptyResult = ExceptionLogService.logException(e, '', '');
        }

        Exception_Log__c emptyLog = [
            SELECT Context__c, Meta__c FROM Exception_Log__c WHERE Id = :emptyResult.getId()
        ];
        System.assertEquals(null, emptyLog.Context__c);
        System.assertEquals(null, emptyLog.Meta__c);
    }
}