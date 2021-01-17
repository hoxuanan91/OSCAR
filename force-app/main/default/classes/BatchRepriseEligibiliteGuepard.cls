global class BatchRepriseEligibiliteGuepard  implements Database.Batchable<sObject>,  Database.AllowsCallouts {
     
     global final String xDays=Label.CL07_PlageRepriseGuepard; 
     global final Date lastxDays=system.today().addDays(-Integer.valueOf(xDays));
	 global Database.QueryLocator start(Database.BatchableContext BC){         
            String query ='Select id,DateStatut422DossierRecuControle__c,Audit_eligibilite__c,Eligibilite_Guepard__c, NEngagementV4__c,StageName'; 
            query=query + ' from Opportunity where recordtype.name like \'%CBM%\' and DateStatut422DossierRecuControle__c>=:lastxDays ';
            query=query + ' and (Eligibilite_Guepard__c=\'Aucun\' OR Eligibilite_Guepard__c=null)';
         //' from Opportunity where id =\'0063O000003au8pQAA\'';
            return Database.getQueryLocator(query);
        }
        
        global void execute(Database.BatchableContext BC, List<sObject> scope){
            system.debug('@@ number of Opportunity '+scope.size());
            List<Opportunity> opptyList=scope;
            Map<Id, String> oppties=new Map<Id, String>();
            for(Opportunity oppty : opptyList){
                oppties.put(oppty.Id, oppty.NEngagementV4__c);
            }
            AP22_EligibiliteGuepard.callEligibilityGuepard(oppties);		
        }
        
        global void finish(Database.BatchableContext BC){
        }
    
     
      
}