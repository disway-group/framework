/**
 * @description REST API client for HTTP callouts with comprehensive logging and retry logic
 * @author Framework Team
 * @date 2024
 */
public with sharing class ApiClient {
    // ---------- Tipos públicos ----------
    public class CallResult {
        @AuraEnabled public Integer statusCode;
        @AuraEnabled public String body;
        @AuraEnabled public Map<String, String> headers;
        @AuraEnabled public Long durationMs;
        @AuraEnabled public Boolean ok;
    }
    public class CallOptions {
        @AuraEnabled public Integer timeoutMs;
        @AuraEnabled public Integer retryCount;
        @AuraEnabled public Map<String, String> headers;
        public Set<String> redactKeys; // Not @AuraEnabled due to Set type
        @AuraEnabled public String correlationId;
        @AuraEnabled public String contentType; // default: application/json
    }

    // ---------- API pública ----------
    @AuraEnabled(cacheable=false)
    public static CallResult get(String namedCred, String path, Map<String,String> query, CallOptions opt){
        String endpoint = buildEndpoint(namedCred, path, query);
        return exec('GET', endpoint, null, opt);
    }

    @AuraEnabled(cacheable=false)
    public static CallResult post(String namedCred, String path, Object body, CallOptions opt){
        String endpoint = buildEndpoint(namedCred, path, null);
        String payload = (body == null) ? null : JSON.serialize(body);
        return exec('POST', endpoint, payload, opt);
    }

    @AuraEnabled(cacheable=false)
    public static CallResult put(String namedCred, String path, Object body, CallOptions opt){
        String endpoint = buildEndpoint(namedCred, path, null);
        String payload = (body == null) ? null : JSON.serialize(body);
        return exec('PUT', endpoint, payload, opt);
    }

    // "delete" é palavra de DML; use "del" para HTTP DELETE
    @AuraEnabled(cacheable=false)
    public static CallResult del(String namedCred, String path, Map<String,String> query, CallOptions opt){
        String endpoint = buildEndpoint(namedCred, path, query);
        return exec('DELETE', endpoint, null, opt);
    }

    // Logar exceções arbitrárias
    public static void logException(String location, Exception ex, Map<String,Object> ctx){
        String cid = ensureCorrelationId(null);
        Map<String, Object> logData = new Map<String, Object>{
            'Channel__c' => 'Apex',
            'Category__c' => 'Exception',
            'Location__c' => location,
            'Correlation_Id__c' => cid,
            'Success__c' => false,
            'Error__c' => safe(ex.getMessage(), 32768),
            'Stacktrace__c' => safe(ex.getStackTraceString(), 32768),
            'Context__c' => safe(JSON.serialize(ctx), 32768)
        };
        IntegrationLogService.logWithFields(logData);
    }

    // ---------- Núcleo ----------
    private static CallResult exec(String method, String endpoint, String payload, CallOptions opt){
        Long started = DateTime.now().getTime();
        String cid = ensureCorrelationId(opt == null ? null : opt.correlationId);
        Integer timeout = (opt != null && opt.timeoutMs != null) ? opt.timeoutMs : 20000;
        Integer retries = (opt != null && opt.retryCount != null) ? Math.max(0, opt.retryCount) : 0;
        Map<String,String> extraHeaders = (opt != null && opt.headers != null) ? opt.headers : new Map<String,String>();
        Set<String> redact = (opt != null && opt.redactKeys != null) ? opt.redactKeys : new Set<String>();
        String contentType = (opt != null && !String.isBlank(opt.contentType)) ? opt.contentType : 'application/json';

        HttpResponse httpRes;
        Integer attempt = 0;
        Exception lastErr;

        while(true){
            attempt++;
            try{
                HttpRequest req = new HttpRequest();
                req.setMethod(method);
                req.setEndpoint(endpoint);        // callout:NC/...
                req.setTimeout(timeout);
                req.setHeader('Content-Type', contentType);
                req.setHeader('X-Correlation-Id', cid);
                for(String k : extraHeaders.keySet()){
                    req.setHeader(k, String.valueOf(extraHeaders.get(k)));
                }
                if(payload != null) req.setBody(payload);

                Http http = new Http();
                httpRes = http.send(req);

                CallResult cr = new CallResult();
                cr.statusCode = httpRes.getStatusCode();
                cr.body = httpRes.getBody();
                cr.headers = toHeaderMap(httpRes);
                cr.durationMs = DateTime.now().getTime() - started;
                cr.ok = (cr.statusCode >= 200 && cr.statusCode < 300);

                logApi(method, endpoint, payload, cr, cid, redact);
                return cr;
            } catch (Exception ex){
                lastErr = ex;

                CallResult fail = new CallResult();
                fail.ok = false;
                fail.body = null;
                fail.headers = new Map<String,String>();
                fail.durationMs = DateTime.now().getTime() - started;

                logApi(method, endpoint, payload, fail, cid, redact, ex);

                if(attempt > retries){
                    throw ex;
                }
            }
        }
        // This should never be reached due to the while(true) loop
        return null;
    }

    private static void logApi(String method, String endpoint, String payload, CallResult cr, String cid, Set<String> redact){
        logApi(method, endpoint, payload, cr, cid, redact, null);
    }
    private static void logApi(String method, String endpoint, String payload, CallResult cr, String cid, Set<String> redact, Exception ex){
        String reqBody = sanitize(payload, redact);
        String resBody = sanitize(cr != null ? cr.body : null, redact);

        Map<String, Object> logData = new Map<String, Object>{
            'Channel__c' => 'HTTP',
            'Category__c' => 'Callout',
            'Correlation_Id__c' => cid,
            'Http_Method__c' => method,
            'Endpoint__c' => endpoint,
            'Status_Code__c' => cr != null ? cr.statusCode : null,
            'Duration_ms__c' => cr != null ? cr.durationMs : null,
            'Success__c' => (cr != null && cr.ok),
            'Request_Payload__c' => safe(reqBody, 32768),
            'Response_Payload__c' => safe(resBody, 32768),
            'Error__c' => ex == null ? null : safe(ex.getMessage(), 32768)
        };
        IntegrationLogService.logWithFields(logData);
    }

    // ---------- Helpers ----------
    private static String buildEndpoint(String nc, String path, Map<String,String> query){
        String p = String.valueOf(path == null ? '' : path);
        if(!p.startsWith('/')) p = '/' + p;
        String qs = (query == null || query.isEmpty()) ? '' : ('?' + toQuery(query));
        return 'callout:' + nc + p + qs;
    }
    private static String toQuery(Map<String,String> q){
        List<String> parts = new List<String>();
        for(String k : q.keySet()){
            parts.add(EncodingUtil.urlEncode(k,'UTF-8') + '=' + EncodingUtil.urlEncode(String.valueOf(q.get(k)),'UTF-8'));
        }
        return String.join(parts,'&');
    }
    private static Map<String,String> toHeaderMap(HttpResponse r){
        Map<String,String> out = new Map<String,String>();
        for(String h : r.getHeaderKeys()) out.put(h, r.getHeader(h));
        return out;
    }
    private static String ensureCorrelationId(String maybe){
        if (String.isNotBlank(maybe)) {
            return maybe;
        }
        // Generate a unique correlation ID
        return 'CORR-' + System.currentTimeMillis() + '-' + Math.random().intValue();
    }
    private static String sanitize(String raw, Set<String> redact){
        if(String.isBlank(raw)) return null;
        String s = raw;
        for(String key : redact){
            if(String.isBlank(key)) continue;
            // "key":"value" -> "key":"***"
            String pattern = '("' + Pattern.quote(key) + '"\\s*:\\s*")[^"]*(")';
            s = s.replaceAll(pattern, '$1***$2');
        }
        return safe(s, 32768);
    }
    private static String safe(String s, Integer maxLen){
        if(s == null) return null;
        return (s.length() <= maxLen) ? s : s.substring(0, maxLen-3) + '...';
    }

}
