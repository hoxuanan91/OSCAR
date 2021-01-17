trigger OpportunityAfterInsert on Opportunity (after insert) { 
    if(PAD.scriptIsStarted('OpportunityAfterInsert')) {
        return;
    }
    if(PAD.canTrigger('OpportunityAfterInsert'))  {
        List<Opportunity> oppsFiltered = new List<Opportunity>();
        
        for(Opportunity opp : Trigger.new){
            System.debug(opp.RecordType.DeveloperName);
            System.debug(opp);
            if(opp.RecordType.DeveloperName == 'CBIProjetAssocie' ||
              opp.RecordType.DeveloperName == 'CBIAvenant' ||
               opp.RecordType.DeveloperName == 'CBIWaiver'){
            	oppsFiltered.add(opp);
        	}
        }
        if(!oppsFiltered.isEmpty()){
            AP03Opportunity.UpdateProjetNbPa(oppsFiltered);
        }

        /* MON EXPERT TRIGGER INSERT OPPORTUNITY - START */
        List<Id> oppsId = new List<Id>(); 
        for (Opportunity opp : Trigger.new) {
            if(opp.N_de_lead_MonExpert__c != null){
                oppsId.add(opp.Id);
            }
        }

        if(!oppsId.isEmpty()){
            MonExpertFeedback.prepareFeedback(oppsId);
        }
        /* MON EXPERT TRIGGER INSERT OPPORTUNITY - END */

        Map<Id, Opportunity>   oppsByIds = new Map<Id, Opportunity>();
        Map<Id, Opportunity>   	oppsLldByIds = new Map<Id, Opportunity>();
        
        
        for (Opportunity opp: [SELECT Id, Comm_eventuels__c, DernierCommentaire__c
                                FROM Opportunity
                                WHERE Id IN:Trigger.newMap.keySet()
                                AND RecordType.developername = 'LLD_Commande']) {
            oppsLldByIds.put(opp.Id, opp);        
        }
        
        if (!oppsLldByIds.isEmpty()) {
            AP03Opportunity.createOpportunityComment(oppsLldByIds.values());
        }
        
        
        for (Opportunity opp: [
                SELECT Id, NomDuProjetAssocieParent__c
                FROM Opportunity
                WHERE Id IN:Trigger.newMap.keySet()
                    AND RecordType.developername LIKE '%cbi%'
                    AND RecordType.DeveloperName != 'CBIAvenant'
        ]) {
            oppsByIds.put(opp.Id, opp);           
        }
    
        if (!oppsByIds.isEmpty()) {
       		AP03Opportunity.insertPremierPoolFinancement(oppsByIds.values());
        }    
    }
}