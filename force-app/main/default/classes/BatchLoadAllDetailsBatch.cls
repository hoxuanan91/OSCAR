public class BatchLoadAllDetailsBatch implements Database.Batchable<ReloadDataUtil.bulkBatchWrapper>,Database.AllowsCallouts,Database.Stateful{
    //liste de batch en entrée
    private List<ReloadDataUtil.bulkBatchWrapper> batchJobList;
    // list des erreur regex
    private List<String> errorRegex;
    //list des sobject en sortie
    private List<ReloadDataUtil.SObjectWrapper> resultList;
    
    public BatchLoadAllDetailsBatch(List<ReloadDataUtil.bulkBatchWrapper> batchJobList, List<String> errorRegex) {
        //Initialisation
        this.batchJobList = batchJobList;
        this.errorRegex = errorRegex;
        resultList = new List<ReloadDataUtil.SObjectWrapper>();
    }
    
    public List<ReloadDataUtil.bulkBatchWrapper> start(Database.BatchableContext bc){
       
        return new List<ReloadDataUtil.bulkBatchWrapper>{batchJobList.get(0)};
    }
    
    public void execute(Database.BatchableContext bc, List<ReloadDataUtil.bulkBatchWrapper> scope) {
       
        //parcourir les batchs
        for(ReloadDataUtil.bulkBatchWrapper jobBatch : scope) {
            //récuperer la liste des objets
            List<ReloadDataUtil.SObjectWrapper> currentList = ReloadDataUtil.getRecordData(jobBatch, ReloadDataUtil.getErrorData(jobBatch, errorRegex));
           
            resultList.addAll(currentList);
        }
    }
    public void finish(Database.BatchableContext bc) {
        //Lancer le batch de mise à jour de données
        if(resultList.size() > 0) {
            Database.executeBatch(new BatchCreateSObject(resultList), Integer.valueOf(Label.Reload_Batch_Size_Processing));
        }
        batchJobList.remove(0);
        
         if(batchJobList.size() > 0) {
            Database.executeBatch(new BatchLoadAllDetailsBatch(this.batchJobList, errorRegex), 1);
        }
    }
}