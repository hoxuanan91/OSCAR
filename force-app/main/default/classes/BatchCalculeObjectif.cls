public class BatchCalculeObjectif implements Database.Batchable<SObject>, Database.Stateful{
    
    private Date startFiscalYear;
    private Date endFiscalYear;
    private Integer currentFiscalYear;
    
    public BatchCalculeObjectif() {
        currentFiscalYear = System.today().year();
        
        if(System.today().Month() <= 3) {
            currentFiscalYear--;
        }
        startFiscalYear = Date.newInstance(currentFiscalYear, 4, 1);
        endFiscalYear = Date.newInstance(currentFiscalYear + 1 , 3, 31);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
         
        return Database.getQueryLocator('select Id, Utilisateur__c from Objectif__c where AnneeFiscale__c =:currentFiscalYear');
    }
    
    public void execute(Database.BatchableContext BC, List<Objectif__c> scope){
        System.debug('@@ scope ' + scope);
        Map<String, Objectif__c> userObjectifMap = new Map<String, Objectif__c>();
        for(Objectif__c obj : scope) {
           
            if(obj.Utilisateur__c != null) {
                obj.Reel__c = 0;
            	userObjectifMap.put(obj.Utilisateur__c, obj);
            }
        }
        if(userObjectifMap.size() == 0) {
            return;
        }
        List<AggregateResult> opportunityList = [select ownerId, count(Id) total from  Opportunity 
                                                 where Typologie_de_commande__c = 'Renouvellement' and ownerId in :userObjectifMap.KeySet() and closeDate >= :startFiscalYear and closeDate <= :endFiscalYear and Iswon = true
                                                 group by ownerId];
        if(opportunityList.size() == 0) {
            return;
        }
        for(AggregateResult item : opportunityList) {
            userObjectifMap.get((String)item.get('ownerId')).Reel__c = (Decimal)item.get('total');
        }
        update userObjectifMap.values();
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
}