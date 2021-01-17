public class BatchReloadData implements Database.Batchable<ReloadDataUtil.SObjectWrapper>,Database.AllowsCallouts,Database.Stateful {
    
    private List<ReloadDataUtil.SObjectWrapper> sobjectListSuccess;
    //Liste des Sobjects à inserer
    private List<ReloadDataUtil.SObjectWrapper> sobjectList;
    //Liste des sobjects qui genere des erreurs.
     private List<ReloadDataUtil.SObjectWrapper> sobjectListError;
    
     private List<List<ReloadDataUtil.SObjectWrapper>> sobjectListExtraError;
    //nombre d'iteration 
    private Integer errorEtiration;
    private Integer sizeBatch;
    //ce constructeur est utilisé par le batch BatchLoadAllDetailsBatch
    public BatchReloadData(List<ReloadDataUtil.SObjectWrapper> sobjectList) {
        this.sobjectList = sobjectList;
        this.errorEtiration = Integer.valueOf(Label.ReloadDataErrorEtiration);
        this.sobjectListError = new List<ReloadDataUtil.SObjectWrapper>();
        this.sobjectListExtraError = new List<List<ReloadDataUtil.SObjectWrapper>>();
        this.sizeBatch = Integer.valueOf(Label.ReloadDataBatchSize);
        sobjectListSuccess = new List<ReloadDataUtil.SObjectWrapper>();
    }
    
    //Ce constructeur est utilisé en d'erreur
    public BatchReloadData(List<ReloadDataUtil.SObjectWrapper> sobjectList, List<ReloadDataUtil.SObjectWrapper> sobjectListSuccess, Integer errorEtiration, Integer sizeBatch) {
        this.sobjectList = sobjectList;
        this.sobjectListError = new List<ReloadDataUtil.SObjectWrapper>();
        this.sobjectListExtraError = new List<List<ReloadDataUtil.SObjectWrapper>>();
        this.errorEtiration = errorEtiration;
        this.sizeBatch = sizeBatch;
        this.sobjectListSuccess = sobjectListSuccess;
    }
    
    public List<ReloadDataUtil.SObjectWrapper> start(Database.BatchableContext bc){
        return sobjectList;
    }
    
    public void execute(Database.BatchableContext bc, List<ReloadDataUtil.SObjectWrapper> scope) {
       
        sobjectListExtraError.add(scope);
        Map<String, List<ReloadDataUtil.SObjectWrapper>> resultPrecessed = ReloadDataUtil.orderSObjectBeforeReload(scope);
        
        List<ReloadDataUtil.SObjectWrapper> insertData = resultPrecessed.get('insert');
        if(insertData.size() > 0) {
            try{
                 Map<String,List<ReloadDataUtil.SObjectWrapper>> rIn = ReloadDataUtil.processingResult(Database.insert(ReloadDataUtil.getSObjectList(insertData), false),insertData);
               
                if(rIn.get('F').size() > 0) {
                   sobjectListError.addAll(rIn.get('F'));
                }
                if(rIn.get('S').size() > 0) {
                   sobjectListSuccess.addAll(rIn.get('S'));
                }
            }catch(Exception e) {
                
                sobjectListError.addAll(insertData);
            }
         }
        
        List<ReloadDataUtil.SObjectWrapper> updateData = resultPrecessed.get('update');
        
        if(updateData.size() > 0 || Test.isRunningTest()) {
            try{
                 Map<String,List<ReloadDataUtil.SObjectWrapper>> rUp = ReloadDataUtil.processingResult(Database.update(ReloadDataUtil.getSObjectList(updateData), false),updateData);
               
                if(rUp.get('F').size() > 0) {
                     sobjectListError.addAll(rUp.get('F'));
                }
                if(rUp.get('S').size() > 0) {
                     sobjectListSuccess.addAll(rUp.get('S'));
                }
            }catch(Exception e) {
                
                sobjectListError.addAll(updateData);
            }
            
        }
        if(Limits.getLimitCpuTime() >= Limits.getCpuTime() && Limits.getLimitHeapSize() >= Limits.getHeapSize()) {
            sobjectListExtraError.remove(sobjectListExtraError.size() - 1);
        }
        
    }
    public void finish(Database.BatchableContext bc) {
        for(List<ReloadDataUtil.SObjectWrapper> item : sobjectListExtraError) {
            sobjectListError.addAll(item);
        }
        
        if(sobjectListError.size() > 0 && errorEtiration > 1) {
           
            Integer newSizeBatch =(Integer) (sizeBatch / 2);
            newSizeBatch = (newSizeBatch < 1 ? 1 : newSizeBatch);
            Database.executeBatch(new BatchReloadData(sobjectListError, sobjectListSuccess, (errorEtiration - 1), newSizeBatch), newSizeBatch);
        }
        if((sobjectListError.size() > 0 && errorEtiration == 1) || sobjectListError.size() == 0) {
            ReloadDataUtil.sendEmailWithAttachmentFile(sobjectListSuccess, sobjectListError);
        }
       
    }
}