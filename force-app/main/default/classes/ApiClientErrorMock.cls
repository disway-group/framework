/**
 * @description Mock class for testing HTTP callouts with ApiClient
 * @author Framework Team
 * @date 2024
 */
@IsTest
global class ApiClientErrorMock implements HttpCalloutMock {
    global Integer statusCode;
    global String body;
    global Map<String,String> headers;
    global Integer delayMs; // Simulate network delay
    global Boolean shouldThrowException; // Force exception during send

    public ApiClientErrorMock() {
        this.statusCode = 200;
        this.body = '{"success": true}';
        this.headers = new Map<String,String>();
        this.delayMs = 0;
        this.shouldThrowException = false;
    }
    
    public ApiClientErrorMock(Integer code, String responseBody) {
        this();
        this.statusCode = code;
        this.body = responseBody;
    }
    
    public ApiClientErrorMock(Integer code, String responseBody, Map<String,String> responseHeaders) {
        this(code, responseBody);
        this.headers = responseHeaders != null ? responseHeaders : new Map<String,String>();
    }
    
    public ApiClientErrorMock withDelay(Integer delayMs) {
        this.delayMs = delayMs;
        return this;
    }
    
    public ApiClientErrorMock withException() {
        this.shouldThrowException = true;
        return this;
    }

    global HTTPResponse respond(HTTPRequest req) {
        // Simulate network delay
        if (delayMs > 0) {
            Long startTime = System.currentTimeMillis();
            while (System.currentTimeMillis() - startTime < delayMs) {
                // Busy wait to simulate delay
            }
        }
        
        // Force exception if configured
        if (shouldThrowException) {
            throw new CalloutException('Mocked network error');
        }
        
        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode == null ? 500 : statusCode);
        res.setBody(String.isBlank(body) ? '{"error":"mocked"}' : body);
        
        // Set default headers if none provided
        if (headers == null || headers.isEmpty()) {
            res.setHeader('Content-Type', 'application/json');
        } else {
            for (String k : headers.keySet()) {
                res.setHeader(k, headers.get(k));
            }
        }
        
        return res;
    }
}
