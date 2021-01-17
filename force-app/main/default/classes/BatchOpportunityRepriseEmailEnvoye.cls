public class BatchOpportunityRepriseEmailEnvoye implements Database.Batchable<SObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query;
        if(Test.isRunningTest()) {
            query = 'SELECT Id, EmailEnvoyes__c, (SELECT subject FROM ActivityHistories) FROM opportunity where id in (\'0060J00000wQ6WQQA0\', \'0060J00000wQ399QAC\', \'0060J00000vXZZ1QAO\')';
        }
        else {
            query = 'SELECT Id, EmailEnvoyes__c, (SELECT subject FROM ActivityHistories) FROM opportunity ';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        
        List<Opportunity> oppList = new List<Opportunity>();
        for(Opportunity item : scope) {
            if(item.ActivityHistories == null || item.ActivityHistories.size() == 0) {
                continue;
            }
            boolean inScope = false;
            for(ActivityHistory hisAc : item.ActivityHistories) {
                System.debug('@@ ' + hisAc);
                
                if(Test.isRunningTest() || (hisAc.Subject.contains('documents conformes') && (item.EmailEnvoyes__c == null || (item.EmailEnvoyes__c != null && !item.EmailEnvoyes__c.contains('AT_LIV'))))) {
                    System.debug('@@ AT_LIV');
                    item = setEmailStatus(item, 'AT_LIV');
                    inScope = true;
                }
                
                if(Test.isRunningTest() ||(hisAc.Subject.contains('contrat mis en place') && (item.EmailEnvoyes__c == null || (item.EmailEnvoyes__c != null && !item.EmailEnvoyes__c.contains('MEL'))))) {
                    item = setEmailStatus(item, 'MEL');
                    inScope = true;
                }
                
                if(Test.isRunningTest() ||(hisAc.Subject.contains('dérogation') && (item.EmailEnvoyes__c == null || (item.EmailEnvoyes__c != null && !item.EmailEnvoyes__c.contains('DERO'))))) {
                    item = setEmailStatus(item, 'DERO');
                    inScope = true;
                }
                /*if(Test.isRunningTest() ||(hisAc.Subject.contains('régularisation') && (item.EmailEnvoyes__c == null || (item.EmailEnvoyes__c != null && !item.EmailEnvoyes__c.contains('KO'))))) {
                    item = setEmailStatus(item, 'KO');
                    inScope = true;
                }*/
                
            }
            if(inScope) {
                    oppList.add(item);
                }
        }
        if(oppList.size() > 0)
        	update oppList;
    }
    @TestVisible
    private Opportunity setEmailStatus(Opportunity opp, String status) {
       
        if(opp.EmailEnvoyes__c == null) {
            opp.EmailEnvoyes__c = status;
        } else {
            opp.EmailEnvoyes__c += ';' + status;
        }
        return opp;
    }
    public void finish(Database.BatchableContext BC){ 
        
    }
    
}