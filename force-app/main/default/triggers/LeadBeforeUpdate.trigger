trigger LeadBeforeUpdate on Lead (before update) {
    if (PAD.canTrigger('LLD_LeadConversion')){
        
        Map<String, Id> animateurCLByTiersId = new Map<String, Id>();
        List<Id>		apporteursIdList = new List<Id>();
        
        for (Lead newLead : Trigger.new) {
            if (newLead.Apporteur__c != null) {
                apporteursIdList.add(newLead.Apporteur__c);
            }
        }
        
        /*
         * Récupère les Tiers en fonction de son id
		 */	
        for (Account acc : [SELECT Id, Name, Animateur__c FROM Account
                            WHERE RecordType.DeveloperName='CBIReseauBanqueCaisse'
                            AND Id IN: apporteursIdList]) {
                                animateurCLByTiersId.put(acc.Id, acc.Animateur__c);
                            }

        for (Lead newLead : Trigger.new) {
            Id animateurIdByTiers = animateurCLByTiersId.get(newLead.Apporteur__c);
            
            // Si il n'y a pas d'animateur sur le Tiers, remettre à null
            if (newLead.Apporteur__c != null) {
                newLead.Animateur_CL__c = animateurIdByTiers;
            }
        }
    }
}