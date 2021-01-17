global class BatchCalculDelaiCreaMEL implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        query='SELECT id , DelaiMiseLoyer__c, CreatedDate,Date_de_traitement_de_la_MEL__c,Dossier1__r.DateDe1ereMEL__c'; 
        query=query+' FROM case WHERE Dossier1__r.DateDe1ereMEL__c  >=2020-01-01 and (DelaiMiseLoyer__c=0 OR DelaiMiseLoyer__c=null)';  
        query=query+' and status !=\'Annulée\'';
        query=query+' and recordType.developerName=\'CBM_Mise_en_place\'';
        query=query+' and Rattrapage_CreaMEL_OK__c =false';
        return Database.getQueryLocator(query);
// Unitil 50 Millions Lines
        
    }
    
    
    
    global void execute(Database.BatchableContext BC, List<Case> scope){
        List<Case> listCaseMEL = new List<Case>();
        
        for(Case c:scope){
            c.DelaiMiseLoyer__c = TR001ManageCase.getNumberOfDayExceptHolidays(c.CreatedDate, c.Dossier1__r.DateDe1ereMEL__c); 
            c.Rattrapage_CreaMEL_OK__c=true;
            listCaseMEL.add(c);
            }
        update  listCaseMEL;
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    
    
}