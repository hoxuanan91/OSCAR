trigger OpportunityAfterUpdate on Opportunity (after Update) {
    if(PAD.scriptIsStarted('OpportunityAfterUpdate') && !Test.isRunningTest()) {
       return;
   	}
    
    if(PAD.canTrigger('OpportunityAfterUpdate')){
        System.debug('@@@ OpportunityAfterUpdate Start');        
        Map<Id, List<Case>> casesOctroiDENByOppIds = new Map<Id, List<Case>>();
        // Permet d'éviter les doublons
        Set<Case> casesOctroiDENSetToUpdate     = new Set<Case>();
        List<Case> casesOctroiDENListToUpdate   = new List<Case>();
        Map<Id, Opportunity> oppsLldByIds       = new Map<Id, Opportunity>();
        Map<Id, Opportunity> oppsCBMByIds       = new Map<Id, Opportunity>();
        List<Opportunity> waiverOpps            = new List<Opportunity>();
        Map<Id, String> etatDocumentSEByOppId   = new Map<Id, String>();

        
        /* MON EXPERT TRIGGER UPDATE OPPORTUNITY - START */
        List<Id> oppsIdToMonExpert = new List<Id>();
        List<MonExpertDependantValues__c> monExpertDependantValue = [SELECT Id, 
                                                                            Name, 
                                                                            OpportunityStage__c, 
                                                                            OpportunityMotifSansSuite__c, 
                                                                            OpportunityEnAttente__c 
                                                                    FROM MonExpertDependantValues__c];
            
        /* MON EXPERT TRIGGER UPDATE OPPORTUNITY - END */

        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        Set<Id> oppsId = new Set<Id>();
        
        for (Opportunity opp: [SELECT Id,
                                    AccountId,
                                    Amount,
                                    Name,
                                    RecordType.developername,
                                    Comm_eventuels__c,
                                    DernierCommentaire__c,
                                    Dossier__c,
                                    Dossier__r.DemandeMELExiste__c,
                                    Dossier__r.NbBiensVehiculesNautiques__c,
                                    Dossier__r.NbBiensVehiculesAeriens__c,
                                    Dossier__r.Intervenant_commercial__c,
                                    DateRetour1DocapostOK__c,
                                    DateRetour2DocapostOK__c,
                                    DateEvntTransfertDossierBack__c,
                                    En_Attente__c,
                                    EtatDocumentSE__c,
                                    Jalon__c,
                                    NomDuProjet__c,
                                    NaturesEnvoiForcees__c,
                                    HorsProcessusAcquisitionAuto__c,
                                    HorsProcessusAcquisitionManuel__c,
                                    IDDossier__c,
                                    LOAPart__c,
                                    Motif__c,
                                    N_de_lead_MonExpert__c,
                                    Owner.Name,
                                    Owner.Email,
                                    StageName,
                                    DelegationNLCBM__c,
                                    NEngagementV4__c,
                                    Typologie_de_commande__c,
                                    NbEnvoisDocaPost1Statut__c,
                                    NbEnvoisDocaPost2Statut__c,
                                    NomDuProjetAssocieParent__c,
                                    NomDuWaiverPrecedent__c,
                                    RecordTypeDeveloperName__c
                                FROM Opportunity
                                WHERE Id IN:Trigger.newMap.keySet()
                                AND (RecordType.DeveloperName = 'LLD_Commande'
                                    OR RecordType.DeveloperName = 'CBMEnDelegation'
                                    OR RecordType.DeveloperName = 'CBMHorsDelegationDCR'
                                    OR RecordType.DeveloperName = 'CBMHorsDelegationDR'
                                    OR RecordType.DeveloperName = 'CBMHorsDelegationDEN'
                                    OR RecordType.DeveloperName = 'CBIWaiver'
                                    OR RecordType.DeveloperName = 'CBMEnAttenteInstruction')]){                          
                                        
            if (opp.RecordType.DeveloperName == 'LLD_Commande') {
                oppsLldByIds.put(opp.Id, opp);
                System.debug(opp.N_de_lead_MonExpert__c);
                    System.debug(opp.StageName);
                    System.debug(Trigger.oldMap.get(opp.Id).StageName);
                    System.debug(opp.En_Attente__c);
                    System.debug(Trigger.oldMap.get(opp.Id).En_Attente__c);
                    System.debug(opp.Motif__c);
                    System.debug(Trigger.oldMap.get(opp.Id).Motif__c);
                
                /* MON EXPERT TRIGGER UPDATE OPPORTUNITY - START */
                if(opp.N_de_lead_MonExpert__c != null &&
                (opp.StageName != Trigger.oldMap.get(opp.Id).StageName ||
                opp.En_Attente__c != Trigger.oldMap.get(opp.Id).En_Attente__c ||
                opp.Motif__c != Trigger.oldMap.get(opp.Id).Motif__c)){
                    for(MonExpertDependantValues__c medv : monExpertDependantValue){
                        if(medv.OpportunityStage__c == opp.StageName){
                            if(medv.OpportunityEnAttente__c != null && medv.OpportunityEnAttente__c == opp.En_Attente__c){
                                oppsIdToMonExpert.add(opp.Id);
                                break;
                            }
                            else if(medv.OpportunityMotifSansSuite__c != null && medv.OpportunityMotifSansSuite__c == opp.Motif__c){
                                oppsIdToMonExpert.add(opp.Id);
                                break;
                            }
                            oppsIdToMonExpert.add(opp.Id);
                            break;
                        }
                    }
                }
                /* MON EXPERT TRIGGER UPDATE OPPORTUNITY - END */

                //Ticket 689 - Aurélien Clerc
                if(opp.Typologie_de_commande__c == 'Renouvellement' && 
                    opp.StageName == 'Commande Validée' && 
                    Trigger.oldMap.get(opp.Id).StageName != 'Commande Validée'){
                    oppsId.add(opp.Id);
                }
            }
            else if (opp.RecordType.DeveloperName.startsWith('CBM')) {
                if(opp.RecordType.DeveloperName != 'CBMEnAttenteInstruction'){
                    oppsCBMByIds.put(opp.Id, opp);
                }
                System.debug('Signature eletronique');
                if(Trigger.oldMap.get(opp.Id).EtatDocumentSE__c != opp.EtatDocumentSE__c && opp.EtatDocumentSE__c != null){
                    etatDocumentSEByOppId.put(opp.Id, opp.EtatDocumentSE__c);
                }
            }
            else if(opp.RecordType.DeveloperName == 'CBIWaiver' &&
                    ((opp.StageName == 'Décidé') &&
                    ((opp.Jalon__c == 'Accord') ||
                    (opp.Jalon__c == 'Accord Avec Réserve')))){
                waiverOpps.add(opp);
            }
        }
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());

        /* MON EXPERT TRIGGER UPDATE OPPORTUNITY - START */
        if(!oppsIdToMonExpert.isEmpty()){
            System.debug('@@@ MonExpert');
            MonExpertFeedback.prepareFeedback(oppsIdToMonExpert);
        }
        /* MON EXPERT TRIGGER UPDATE OPPORTUNITY - END */
            
        if (oppsLldByIds.size() > 0) {
            System.debug('@@@ Commentaire Opportunity');
            AP03Opportunity.createOpportunityComment(oppsLldByIds.values());
        }
        
        if (oppsCBMByIds.size() > 0) {
            //AP03Opportunity.handleCaseCBM(oppsCBMByIds, Trigger.oldMap);
        }

        /* SIGNATURE ÉLECTRONIQUE MÀJ DOCUMENT SE - START */
        /*if(!etatDocumentSEByOppId.isEmpty()){
            System.debug('@@@ Document SE');
            AP03Opportunity.upsertDocumentSE(etatDocumentSEByOppId);
        }*/
        /* SIGNATURE ÉLECTRONIQUE MÀJ DOCUMENT SE - END */

        //Ticket 689 - Aurélien Clerc
        if(!oppsId.isEmpty()){
            Set<Id> contractsId = new Set<Id>();

            for(Contrat_ProjetAssocie__c cPas : [SELECT Id, ProjetAssocie__c, Contrat__c FROM Contrat_ProjetAssocie__c WHERE ProjetAssocie__c IN :oppsId]){
                contractsId.add(cPas.Contrat__c);
            }

            if(!contractsId.isEmpty()){
                System.debug('@@@ Contrats');
                AP03Opportunity.updateContracts(contractsId);
            }
        }

        /**
        *  FO - DEN
        *  Passage des demandes(=CBMOctroiCreditDEN) au status=Refusée
        *  Rapatrier MotifdecisionDEN__c
        *  Annuler les demandes d'octroi DEN si PAS 'sans-suite"
        */
        for (Opportunity opp : [SELECT Id, 
                                    MotifdecisionDEN__c,
                                    DateDecisionNatixisLease36xDate__c,
                                    StageName,
                                    (SELECT Id, 
                                            Status 
                                    FROM Demandes_ProjetAssocie__r 
                                    WHERE RecordType.DeveloperName = 'CBMOctroiCreditDEN')
                                FROM Opportunity
                                WHERE Id IN: Trigger.newMap.keySet()
                                AND (RecordType.DeveloperName = 'CBMEnDelegation'
                                OR RecordType.DeveloperName = 'CBMEnveloppe'
                                OR RecordType.DeveloperName = 'CBMHorsDelegationDCR'
                                OR RecordType.DeveloperName = 'CBMHorsDelegationDEN'
                                OR RecordType.DeveloperName = 'CBMHorsDelegationDR')]) {
            if(!opp.Demandes_ProjetAssocie__r.isEmpty()){
                for(Case c : opp.Demandes_ProjetAssocie__r){
                    
                    System.debug(c.Status != 'Refusée');
                    System.debug(c.Status);
                    if(opp.MotifdecisionDEN__c != Trigger.oldMap.get(opp.Id).MotifdecisionDEN__c){
                        c.MotifDecisionDEN__c = opp.MotifdecisionDEN__c;
                        casesOctroiDENSetToUpdate.add(c);
                    }
                    else if(opp.DateDecisionNatixisLease36xDate__c != null && c.Status != 'Refusée'){
                        c.Status = 'Refusée';
                        casesOctroiDENSetToUpdate.add(c);
                    }
                    else if(Trigger.oldMap.get(opp.Id).StageName != opp.StageName && opp.StageName == 'S_SUIT'){
                        c.Status = 'Annulée';
                        casesOctroiDENSetToUpdate.add(c);
                    }
                }
            }
        }
            
        if (casesOctroiDENSetToUpdate.size() > 0) {
            casesOctroiDENListToUpdate.addAll(casesOctroiDENSetToUpdate);
            System.debug('@@@ Case Octroi DEN');
            update casesOctroiDENListToUpdate;
        }
        //}
        
        if(!Test.isRunningTest())
            System.debug('@@@ Set phase Jalon');
            AP03Opportunity.setPhasejalonToProjetAssocieFromWaiver(waiverOpps); //FILTRER LES OPPS AVEC DEVNAME ICI
    }
}