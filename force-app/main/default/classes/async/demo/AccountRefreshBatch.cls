public class AccountRefreshBatch extends AsyncBatchBase {
    public override Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name FROM Account WHERE Active__c = true');
    }
    public override void execute(Database.BatchableContext bc, List<SObject> scope) {
        try { update scope; } catch (Exception e) { log('Batch', 'Error', e); throw e; }
    }
}
