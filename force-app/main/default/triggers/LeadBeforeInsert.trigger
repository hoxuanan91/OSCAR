trigger LeadBeforeInsert on Lead (before insert) {
    if (PAD.canTrigger('LLD_LeadConversion')){
        
        Map<Lead, String> etablissementsByLead = new Map<Lead, String>();
        Map<String, Id> accoundIdByEtablissements = new Map<String, Id>();
        Map<String, Id> animateurCLByEtablissements = new Map<String, Id>();
        Map<String, Id> animateurCLByTiersId = new Map<String, Id>();
        List<Id>		apporteursIdList = new List<Id>();
        
        /*
         * Récupère les Tiers en fonction du champ établissement renseigné via le formulaire WEB
         */

        for (Lead newLead : Trigger.new) {
            if (newLead.Etablissement__c != null) {
                String correctForm = newLead.Etablissement__c.replaceAll('[^a-zA-Z\\d:]', '').toUpperCase();
                etablissementsByLead.put(newLead, correctForm);
            }
            if (newLead.Apporteur__c != null) {
                apporteursIdList.add(newLead.Apporteur__c);
            }
        }

        for (Account acc : [SELECT Id, 
                                    Name, 
                                    Animateur__c 
                            FROM Account
                            WHERE RecordType.DeveloperName='CBIReseauBanqueCaisse']) {
            String correctName = acc.Name.replaceAll('[^a-zA-Z\\d:]', '').toUpperCase();
            for(String str : etablissementsByLead.values()){
                if(str == correctName){
                    accoundIdByEtablissements.put(acc.Name, acc.Id);
                    animateurCLByEtablissements.put(acc.Name, acc.Animateur__c);
                }
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
            if (newLead.Etablissement__c != null) {
                newLead.Apporteur__c = accoundIdByEtablissements.get(newLead.Etablissement__c);
                newLead.Animateur_CL__c = animateurCLByEtablissements.get(newLead.Etablissement__c);
            }
            if (animateurCLByTiersId.get(newLead.Apporteur__c) != null) {
                newLead.Animateur_CL__c = animateurCLByTiersId.get(newLead.Apporteur__c);
            }
        }
    }
}