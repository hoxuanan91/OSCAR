public class BatchCreateSObject implements Database.Batchable<ReloadDataUtil.SObjectWrapper>,Database.AllowsCallouts,Database.Stateful{
    
    private List<ReloadDataUtil.SObjectWrapper> sobjectList;
   private List<ReloadDataUtil.SObjectWrapper> result;
     public BatchCreateSObject(List<ReloadDataUtil.SObjectWrapper> sobjectList) {
         this.sobjectList = sobjectList;
         result = new List<ReloadDataUtil.SObjectWrapper>();
     }
    public List<ReloadDataUtil.SObjectWrapper> start(Database.BatchableContext bc){
        return sobjectList;
    }
    
    public void execute(Database.BatchableContext bc, List<ReloadDataUtil.SObjectWrapper> scope) {
        for(ReloadDataUtil.SObjectWrapper item : scope) {
            result.add(ReloadDataUtil.processingTypeSObject(item));
            System.debug('@@@ ' + item);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        Database.executeBatch(new BatchReloadData(result), Integer.valueOf(Label.ReloadDataBatchSize));
    }
}