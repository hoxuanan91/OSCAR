public class BatchLoadAllBulkBatch implements Database.Batchable<ReloadDataUtil.bulkBatchWrapper>,Database.AllowsCallouts,Database.Stateful{
	
    //cette variable permet de collecter les données pour le prochain batch
    private List<ReloadDataUtil.bulkBatchWrapper> result;
    //la list des jobs recuperer comme input
    private List<ReloadDataUtil.bulkBatchWrapper> jobList;
     //la list regex Error recuperer comme input
    private List<String> errorRegex;
    
    public BatchLoadAllBulkBatch(List<ReloadDataUtil.bulkBatchWrapper> jobList, List<String> errorRegex) {
        //initialisation
        this.jobList = jobList;
        this.result = new List<ReloadDataUtil.bulkBatchWrapper>();
        this.errorRegex = errorRegex;
    }
    
    public List<ReloadDataUtil.bulkBatchWrapper> start(Database.BatchableContext bc){
        
        return new List<ReloadDataUtil.bulkBatchWrapper>{jobList.get(0)};
    }
    
    public void execute(Database.BatchableContext bc, List<ReloadDataUtil.bulkBatchWrapper> scope) {
        System.debug('@@ scope ' + scope);
        for(ReloadDataUtil.bulkBatchWrapper job : scope) {
            //recuperer les batch associé à un job donné.
            List<String> batchIdList = ReloadDataUtil.getAllBatchDetailsByJobId(job.jobId);
            System.debug('@@ batchIdList ' + batchIdList);
            for(String batchId : batchIdList) {
                //formater les batch dans l'objet bulkBatchWrapper
                this.result.add(new ReloadDataUtil.bulkBatchWrapper(job, batchId));
            }
             System.debug('@@ bs1 ' + this.Result);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        //lancer le prochain apex batch qui va prendre en change de recuperer les données cibles
        System.debug('@@ bs ' + this.result);
        if(this.result.size() > 0) {
            Database.executeBatch(new BatchLoadAllDetailsBatch(this.result, errorRegex), 1);
        }
        jobList.remove(0);
        if(jobList.size() > 0) {
            Database.executeBatch(new BatchLoadAllBulkBatch(this.jobList, errorRegex), 1);
        }
    }
}