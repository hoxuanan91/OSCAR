/*************************************************************************************
* @date 22/05/2019
* @description Trigger à la conversion d'un lead pour lier le tiers créé à un tiers de type 'CBIReseauBanqueCaisse' ainsi qu'à un Correspondant de type 'CBIReseau'
* Nom du trigger - LLD_LeadConversion
*************************************************************************************/

trigger LeadAfterUpdate on Lead (after update) {
    
    if(PAD.scriptIsStarted('LLD_LeadConversion')) {
        return;
    }
    
    if (PAD.canTrigger('LLD_LeadConversion')){


        /* MON EXPERT TRIGGER UPDATE LEAD - START */
        List<Id> leadsId = new List<Id>();        
        
        for (Lead l : Trigger.new) {
            if(l.N_de_lead_MonExpert__c != null &&
            l.Status != Trigger.oldMap.get(l.Id).Status &&
            l.Status != 'Converti'){
                leadsId.add(l.Id);
            }
        }

        if(!leadsId.isEmpty()){
            MonExpertFeedback.prepareFeedback(leadsId);
        }
        /* MON EXPERT TRIGGER UPDATE LEAD - END */
        
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CBI - Réseau').getRecordTypeId();
        Id leadLLDRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead LLD').getRecordTypeId();
        /*
         * LLD - Evolution - LLD Dirco
         * A Pusher lors du Sprint 3 - Lot 2
         */
        //Id leadLLDDircoRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead LLD Dirco').getRecordTypeId();
        
        Map<Id, ConvertedLeadWrapper>	convertedLeadWrapperByConvertedAccoundId = new Map<Id, ConvertedLeadWrapper>();
        Map<String, Id>					contactIdByChargeClientele = new Map<String, Id>();
        List<String>					emailConseillerList = new List<String>();
        
        List<Account>					accountsToUpdate = new List<Account>();
        List<Contact>					chargeClienteleToInsert = new List<Contact>();
        Map<String, Contact>			newChargeClienteleByEmailConseiller = new Map<String, Contact>();
        List<Lead> convertedLLDLead= new List<Lead>();
        for (Lead oldLead : Trigger.old) {
            Lead newLead = Trigger.newMap.get(oldLead.Id);
            // LLD - Evolution - LLD Dirco
            // A prévoir lors du Sprint 3 - Lot 2
            // Ajouter une condition pour cette variable: leadLLDDircoRecordTypeId
            if (oldLead.IsConverted == false && newLead.IsConverted == true &&
                newLead.RecordTypeId == leadLLDRecordTypeId) {
                    convertedLLDLead.add(newLead);
                    emailConseillerList.add(newLead.Email_conseiller__c);                    
                    convertedLeadWrapperByConvertedAccoundId.put(newLead.ConvertedAccountId, new ConvertedLeadWrapper(newLead));
                }
        }
        AP25_LeadHandler.transferLLDSimulation(convertedLLDLead);
        
        /*
         * Récupère les Accounts convertis
         */
        for (Account convertedAccount : [SELECT Id, Name, Apporteur__c, RecordType.DeveloperName
                                         FROM Account
                                         WHERE Id IN: convertedLeadWrapperByConvertedAccoundId.keyset()]) {
                                             ConvertedLeadWrapper tmpConvertedLeadWrapper = convertedLeadWrapperByConvertedAccoundId.get(convertedAccount.Id);
                                             tmpConvertedLeadWrapper.convertedAccount = convertedAccount;
                                         }
        
        /*
         * Récupère les Conseillers existants en BDD en fonction du champs "Email" du Lead convertis
         * Attention DOUBLON, donc on filtre sur:
         * Les conseillers avec comme RT=CBI Reseau
         * Les conseillers qui ont un compte de type CBI Reseau Banque Caisse
         */
        for (Contact chargeClientele : [SELECT Id, Email
                                        FROM Contact
                                        WHERE RecordType.DeveloperName='CBIReseau'
                                        AND Account.RecordType.DeveloperName='CBIReseauBanqueCaisse'
                                        AND Email IN: emailConseillerList]) {
                                            contactIdByChargeClientele.put(chargeClientele.Email, chargeClientele.Id);
                                        }
        /*
         * Si il y a un conseiller en base correspondant à nos critères, on le rattache au compte convertis
         * Sinon on créé un conseiller tout en le rattachant au compte convertis
         */
        for (ConvertedLeadWrapper clw : convertedLeadWrapperByConvertedAccoundId.values()) {
            Lead convertedLead = clw.convertedLead;
            Id chargeClientId = contactIdByChargeClientele.get(convertedLead.Email_conseiller__c);
            
            if (chargeClientId != null) {
                clw.convertedAccount.Conseiller_client__c = chargeClientId;
                
                accountsToUpdate.add(clw.convertedAccount);
            } else {
                Contact c = new Contact();
                
                c.RecordTypeId = contactRecordTypeId;
                c.Email = convertedLead.Email_conseiller__c;
                c.FirstName = convertedLead.Prenom_conseiller__c;
                c.LastName = convertedLead.Nom_conseiller__c;
                c.MobilePhone = convertedLead.Tel_conseiller__c;
                c.Agence_LLD__c = convertedLead.Agence__c;
                c.AccountId = convertedLead.Apporteur__c;
                
                chargeClienteleToInsert.add(c);
                newChargeClienteleByEmailConseiller.put(c.Email, c);
            }
        }
        
        if (chargeClienteleToInsert.size() > 0) {
            insert chargeClienteleToInsert;
        }
        
        // Rattache les chargés clienteles nouvellement créés au Tiers Client (champ=>Conseiller_client__c)
        for (ConvertedLeadWrapper clw : convertedLeadWrapperByConvertedAccoundId.values()) {
            Lead convertedLead = clw.convertedLead;
            Contact newChargeClientele = newChargeClienteleByEmailConseiller.get(convertedLead.Email_conseiller__c);
            
            if (newChargeClientele != null) {
                clw.convertedAccount.Conseiller_client__c = newChargeClientele.Id;
                
                accountsToUpdate.add(clw.convertedAccount);
            }
        }
        
        if (accountsToUpdate.size() > 0) {
            update accountsToUpdate;
        }
    }
    
    private class ConvertedLeadWrapper {
        private	Lead	convertedLead;
        private	Account	convertedAccount;
        
        private convertedLeadWrapper(Lead convertedLead) {
            this.convertedLead = convertedLead;
        }
    }
}