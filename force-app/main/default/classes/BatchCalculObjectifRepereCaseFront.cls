public class BatchCalculObjectifRepereCaseFront implements Database.Batchable<SObject> {
    
    private Date startDate;
    private Date endDate;
    private Integer mois;
    private Integer annee;
    
    public List<String> CBMFrontRecordTypes=new List<String>{'CBMEnAttenteInstruction','CBMEnDelegation','CBMHorsDelegationDCR','CBMHorsDelegationDEN','CBMHorsDelegationDR'};
        
        public BatchCalculObjectifRepereCaseFront(Integer moisACalculer, Integer anneeACalculer){
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

        Map<Id,List<Case>>  mapOppIntervenant423=AP27_RepereQuery.getCase423MapByIntervenant(startDate, endDate, CBMFrontRecordTypes);
        Map<Id,List<Case>>  mapOppIntervenant460=AP27_RepereQuery.getCase460MapByIntervenant(startDate, endDate, CBMFrontRecordTypes);
        
        AP24_CalculRepereHandlerFront.calculIndicateursCaseFront(mapOppIntervenant423,
                                                             mapOppIntervenant460,
                                                             mois,
                                                             annee);
            
            
    }
    
    public void finish(Database.BatchableContext BC){
        AP27_RepereQuery.getDossierFrontLease(startDate, endDate, CBMFrontRecordTypes);
        AP27_RepereQuery.getMElValideurs(startDate, endDate);

    }
    
    
    
}