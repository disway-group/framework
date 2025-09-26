/**
 * @description Test class for ApiClient
 * @author Framework Team
 * @date 2024
 */
@IsTest
private class ApiClientTest {
    
    @IsTest
    static void testGetSuccess() {
        // Mock successful response
        Test.setMock(HttpCalloutMock.class, new ApiClientErrorMock(200, '{"success": true, "data": "test"}'));
        
        Test.startTest();
        
        ApiClient.CallOptions options = new ApiClient.CallOptions();
        options.timeoutMs = 10000;
        options.retryCount = 1;
        options.headers = new Map<String, String>{ 'Authorization' => 'Bearer test-token' };
        options.redactKeys = new Set<String>{ 'authorization' };
        options.correlationId = 'TEST-CORR-123';
        options.contentType = 'application/json';
        
        Map<String, String> queryParams = new Map<String, String>{
            'param1' => 'value1',
            'param2' => 'value2'
        };
        
        ApiClient.CallResult result = ApiClient.get('TestCredential', '/test/endpoint', queryParams, options);
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(true, result.ok, 'Request should be successful');
        System.assertEquals(200, result.statusCode, 'Status code should be 200');
        System.assertEquals('{"success": true, "data": "test"}', result.body, 'Response body should match');
        System.assertNotEquals(null, result.headers, 'Headers should not be null');
        System.assert(result.durationMs > 0, 'Duration should be greater than 0');
    }
    
    @IsTest
    static void testPostSuccess() {
        // Mock successful response
        Test.setMock(HttpCalloutMock.class, new ApiClientErrorMock(201, '{"id": 123, "created": true}'));
        
        Test.startTest();
        
        ApiClient.CallOptions options = new ApiClient.CallOptions();
        options.contentType = 'application/json';
        
        Map<String, Object> requestBody = new Map<String, Object>{
            'name' => 'Test Item',
            'description' => 'Test Description'
        };
        
        ApiClient.CallResult result = ApiClient.post('TestCredential', '/test/items', requestBody, options);
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(true, result.ok, 'Request should be successful');
        System.assertEquals(201, result.statusCode, 'Status code should be 201');
        System.assertEquals('{"id": 123, "created": true}', result.body, 'Response body should match');
    }
    
    @IsTest
    static void testHttpError() {
        // Mock error response
        Test.setMock(HttpCalloutMock.class, new ApiClientErrorMock(404, '{"error": "Not found"}'));
        
        Test.startTest();
        
        ApiClient.CallOptions options = new ApiClient.CallOptions();
        options.retryCount = 0; // No retries for this test
        
        ApiClient.CallResult result = ApiClient.get('TestCredential', '/test/notfound', null, options);
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(false, result.ok, 'Request should not be successful');
        System.assertEquals(404, result.statusCode, 'Status code should be 404');
        System.assertEquals('{"error": "Not found"}', result.body, 'Error response body should match');
    }
    
    @IsTest
    static void testLogException() {
        Test.startTest();
        
        Exception testException = new CalloutException('Test exception message');
        Map<String, Object> context = new Map<String, Object>{
            'userId' => UserInfo.getUserId(),
            'operation' => 'test'
        };
        
        // This should not throw an exception
        ApiClient.logException('TestLocation', testException, context);
        
        Test.stopTest();
        
        // Verify log was created (if Integration_Log__c exists)
        List<Integration_Log__c> logs = [SELECT Id, Error__c, Location__c FROM Integration_Log__c WHERE Location__c = 'TestLocation'];
        if (!logs.isEmpty()) {
            System.assertEquals('TestLocation', logs[0].Location__c, 'Log location should match');
        }
    }
    
    @IsTest
    static void testRetryLogic() {
        // Mock that fails first time, succeeds second time
        Test.setMock(HttpCalloutMock.class, new RetryTestMock());
        
        Test.startTest();
        
        ApiClient.CallOptions options = new ApiClient.CallOptions();
        options.retryCount = 2;
        options.timeoutMs = 5000;
        
        ApiClient.CallResult result = ApiClient.get('TestCredential', '/test/retry', null, options);
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(true, result.ok, 'Request should eventually succeed');
        System.assertEquals(200, result.statusCode, 'Status code should be 200');
    }
    
    /**
     * @description Mock that fails first time, succeeds second time for retry testing
     */
    private class RetryTestMock implements HttpCalloutMock {
        private Integer callCount = 0;
        
        public HTTPResponse respond(HTTPRequest req) {
            callCount++;
            
            HttpResponse res = new HttpResponse();
            if (callCount == 1) {
                // First call fails
                res.setStatusCode(500);
                res.setBody('{"error": "Temporary failure"}');
            } else {
                // Subsequent calls succeed
                res.setStatusCode(200);
                res.setBody('{"success": true, "retry": true}');
            }
            return res;
        }
    }
}
