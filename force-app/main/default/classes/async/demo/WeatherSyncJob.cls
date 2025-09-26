public class WeatherSyncJob extends AsyncQueueJobBase {
    protected override void handle(AsyncContext ctx) {
        ApiClient.CallOptions opt = new ApiClient.CallOptions();
        opt.headers = new Map<String,String>();
        opt.redactKeys = new Set<String>{ 'authorization','api_key','token' };
        ApiClient.CallResult cr = ApiClient.get('OpenMeteo', '/v1/forecast',
            new Map<String,String>{ 'latitude' => '-23.5505', 'longitude' => '-46.6333', 'hourly' => 'temperature_2m' },
            opt
        );
        if (!cr.ok) throw new CalloutException('Falha clima: ' + cr.statusCode);
    }
}
