global class BatchCaseRelance implements Database.Batchable<SObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
 String query;
        if(Test.isRunningTest()){
            query= 'Select Id, LancerCalculPhase__c from Case';
        } else
     query= 'Select Id, LancerCalculPhase__c from Case where '
             + '(RecordType.DeveloperName = \'CBM_Appel_de_fonds_recouvrer\' or RecordType.DeveloperName = \'CBM_Impaye_et_avoir_Post_Real\' or RecordType.DeveloperName = \'CBM_Actions_de_Recouvrement\') ' 
             + 'and ((Phase__c = \'A jour\' and SoldeTTCTotalFacturesNonLettrees__c != 0 and (NbAvoirs__c != 0 or NbImpayes__c != 0))'
             + 'or (Phase__c != \'A jour\'  and Phase__c != \'Prise en charge CX ou JU\' and SoldeTTCTotalFacturesNonLettrees__c = 0 and (NbAvoirs__c = 0 or NbImpayes__c = 0)))   and IsClosed = false ';
    	return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> scope){
        List<Case> listCase = new List<Case>();
        for(Case item : scope) {
            if(item.LancerCalculPhase__c == true) {
                item.LancerCalculPhase__c = false;
                listCase.add(item);
            }
        }
        if(listCase.size() > 0) {
            update listCase;
        }
        
        for(Case item : scope) {
            item.LancerCalculPhase__c = true;
        }
        
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}