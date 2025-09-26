public with sharing class AsyncFacade {
    @AuraEnabled public static void runWeather() {
        System.enqueueJob(new WeatherSyncJob());
    }
    @AuraEnabled public static void runAccountBatch() {
        Database.executeBatch(new AccountRefreshBatch(), FrameworkSettings.get().defaultBatchSize);
    }
}
