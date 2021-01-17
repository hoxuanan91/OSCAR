public class ScheduleReloadExecute implements Queueable,Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        
        //recuperer la liste des jobs filter et non traiter avant.
        List<ReloadDataUtil.BulkBatchWrapper> jobIdList = ReloadDataUtil.getAllJobDetails();
        //charger la liste des regex erreurs active. 
        List<String> errorRegex = ReloadDataUtil.loadRegexError();
        Database.executeBatch(new BatchReassignmentCase(), 1);
        
        //lancer un batch APEX qui recupere les batch bulk pour tous les job bulk.
        if(jobIdList.size() == 0 || errorRegex.size() == 0) {
            return;
        }
        Database.executeBatch(new BatchLoadAllBulkBatch(jobIdList, errorRegex), 1);
       
    }
}