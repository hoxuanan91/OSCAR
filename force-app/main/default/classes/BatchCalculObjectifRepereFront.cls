public class BatchCalculObjectifRepereFront implements Database.Batchable<SObject>{ 
    
    private Date startDate;
    private Date endDate;
    private Integer mois;
    private Integer annee;

    public List<String> CBMFrontRecordTypes=new List<String>{'CBMEnAttenteInstruction','CBMEnDelegation','CBMHorsDelegationDCR','CBMHorsDelegationDEN','CBMHorsDelegationDR'};
   
        public BatchCalculObjectifRepereFront(Integer moisACalculer, Integer anneeACalculer){
            mois=moisACalculer;
            annee=anneeACalculer;
            startDate=Date.newInstance(annee, 1, 1);
            Integer numberDays = date.daysInMonth(annee, mois);
            endDate=Date.newInstance(annee, mois, numberDays);
          
        }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
               
        String query='SELECT id, Collaborateur__c from ObjectifRealise__c  limit 1';
        return Database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope){       
        //Map<Id,List<Opportunity>> mapOppIntervenant422=AP27_RepereQuery.getOppty422MapByIntervenant(startDate, endDate, CBMFrontRecordTypes);
        Map<Id,List<Opportunity>> mapOppIntervenantDerog=AP27_RepereQuery.getOpptyDerogMapByIntervenant(startDate, endDate, CBMFrontRecordTypes);
        AP24_CalculRepereHandlerFront.calculIndicateursFrontOppty(mapOppIntervenantDerog, mois, annee);
    }
    
    public void finish(Database.BatchableContext BC){
             Database.executeBatch(new BatchCalculObjectifRepereCaseFront(mois,annee)) ;
    }
    
    
    
}