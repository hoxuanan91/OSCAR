Trigger CaseAfterUpdate on Case (after update) {
   
    if(PAD.scriptIsStarted('CaseAfterUpdate')) {
        return;
    }

    if(PAD.canTrigger('AP18Demande_postChatterWhenCaseEqualTermine')){
        /**
         * Post un chatter lorsque:
          *  - le Case passe au statut 'Terminé'
          *  - le RT=CBM_Valorisation
          *  - le propriétaire du PAS est un NX_Délégué Régional / Assistante CBM
          *  - le créateur du Case est un NX_Délégué Régional / Assistante CBM
         */
        Map<Id, Case> casesByIds = new Map<Id, Case>();
    
        for (Case c : [SELECT Id, 
                            MotifdecisionDEN__c, 
                            toLabel(EtatDeLaValorisation__c), 
                            AvisServiceValorisation__c, 
                            ProjetAssocie__c, 
                            ProjetAssocie__r.OwnerId, 
                            ProjetAssocie__r.Owner.Profile.Name, 
                            Status,
                            RecordTypeDeveloperName__c, 
                            CreatedById, 
                            CreatedBy.Profile.Name
                        FROM Case
                        WHERE ProjetAssocie__c != null
                        AND Status = 'Terminée'
                        AND RecordType.DeveloperName = 'CBM_Valorisation'
                        AND Id IN: Trigger.newMap.keySet()]){
            
            if(Trigger.oldMap.get(c.Id).Status != c.Status){
                casesByIds.put(c.Id, c);
            }
        }
    
        if (!casesByIds.isEmpty()) {
            AP18Demande.postChatterWhenCaseEqualTermine(casesByIds);
        }
    }

List<User> User = [SELECT Id, Name, Interface__c FROM User WHERE Id=:userinfo.getUserId() LIMIT 1];

System.debug('#### ByPass CaseAfterUpdate : ' + User[0].Name + ' Interface ' + User[0].Interface__c );

if(User[0].Interface__c == false){

    System.debug('#### Début : CaseAfterUpdate');

    if(PAD.canTrigger('TR002ManageContract')) 
    {
    
    System.debug('#### : CaseAfterUpdate - TR002ManageContract');
        
        //Déclaration de la liste des Ids des dossiers dans lesquels on ajoute
        Set<Id> setDossierIds = new Set<Id>();
        List<Id> dossierIds = new List<Id>();
        
        //Déclaration de la liste des Ids des dossiers depuis lesquels on supprime
        List<Id> dossierIdsSuppression = new List<Id>();
    
        for(Case c : [SELECT Id, 
                            Status, 
                            Dossier1__c,
                            RecordTypeId 
                        FROM Case 
                        WHERE RecordType.DeveloperName = 'CBM_Reamenagement' 
                        AND Id IN: Trigger.newMap.keySet()]){

            if((Trigger.oldMap.get(c.Id).RecordTypeId != c.RecordTypeId || Trigger.oldMap.get(c.Id).Status != c.Status) && c.Status != null && c.Dossier1__c != null){
                if(c.Status.contains('Terminée') || Trigger.oldMap.get(c.Id).Status.contains('Terminée')){
                    setDossierIds.add(c.Dossier1__c);
                }
            }
        }
    
            /*if((Trigger.old[i].RecordTypeId != Trigger.new[i].RecordTypeId)
            && Trigger.new[i].status != null && Trigger.new[i].status.contains('Terminée'))
            
                ||
            
            (Trigger.old[i].status != Trigger.new[i].status)
            && Trigger.new[i].status != null && Trigger.new[i].status.contains('Terminée') && !Trigger.old[i].status.contains('Terminée'))
                
            ){
                System.debug('#### : bouble :' + Trigger.new[i].Id + ' / ' + Trigger.new[i].RecordTypeId + ' / ' + Trigger.new[i].Dossier1__c);
                dossierIdsAjout .add(Trigger.new[i].Dossier1__c);
            }
            
            if((Trigger.old[i].RecordTypeId != Trigger.new[i].RecordTypeId &&)
            && Trigger.old[i].status != null && Trigger.old[i].status.contains('Terminée'))
            
                ||
                
            (Trigger.old[i].status != Trigger.new[i].status &&)
            && Trigger.old[i].status != null && Trigger.old[i].status.contains('Terminée') && !Trigger.new[i].status.contains('Terminée'))    
            
            ){
                System.debug('#### : bouble :' + Trigger.old[i].Id + ' / ' + Trigger.old[i].RecordTypeId + ' / ' + Trigger.old[i].Dossier1__c);
                dossierIdsSuppression .add(Trigger.old[i].Dossier1__c);
            }*/
        
        // Vérifier que la liste des cases n'est pas vide,
        // puis lancer le traitement sur la liste des cases
        if(!setDossierIds.isEmpty()){
            dossierIds.addAll(setDossierIds);
            TR002ManageContract.CalculateNombreReamenagement(dossierIds);
        }
    }
    
    if(PAD.canTrigger('TR002ManageContract_NomTiers')) 
    {
    
        System.debug('#### : CaseAfterUpdate - TR002ManageContract_NomTiers');
        
        //Déclaration de la liste des Ids des dossiers
        Map<ID,List<Case>> demandeDossierIDs = new Map<ID,List<Case>>();
        
        //Déclaration des ID des recordType
        // Cap Gemini - JR - 05/12/17 - Le Type d'Enregistrement CBI - Actions de Recouvrement (CBIActionsRecouvrement) a été ajouté
        Map<String,Id> RTs = DAL.getRecordType('Case');
       //  ID rtActionRecouvrement = (ID)RTs.get('CBM_Actions_de_Recouvrement');
       //  ID rtActionRecouvrementCBI = (ID)RTs.get('CBIActionsRecouvrement');
        ID rtAppelFondARecouvrer = (ID)RTs.get('CBM_Appel_de_fonds_recouvrer');
        ID rtImpayesAvoirPostReal = (ID)RTs.get('CBM_Impaye_et_avoir_Post_Real');
        ID rtCBIParten = (ID)RTs.get('CBIActionsRecouvrementPartenaire');
        
       // System.debug('#### : rtActionRecouvrement :' + rtActionRecouvrement);
       // System.debug('#### : rtActionRecouvrementCBI :' + rtActionRecouvrementCBI);
        System.debug('#### : rtAppelFondARecouvrer :' + rtAppelFondARecouvrer);
        System.debug('#### : rtImpayesAvoirPostReal :' + rtImpayesAvoirPostReal);
        System.debug('#### : rtCBIParten :' + rtCBIParten);
        
        for(integer i = 0; i < Trigger.new.size() ; i++){
        
            if(Trigger.new[i].ModeAuto__c == Trigger.old[i].ModeAuto__c && Trigger.new[i].UniteSRC__c == Trigger.old[i].UniteSRC__c
                &&Trigger.new[i].Dossier1__c != null && Trigger.new[i].Dossier1__c != Trigger.old[i].Dossier1__c
            //    && rtActionRecouvrement != null && !rtActionRecouvrement.equals(Trigger.new[i].RecordTypeId)
            //    && rtActionRecouvrementCBI != null && !rtActionRecouvrementCBI.equals(Trigger.new[i].RecordTypeId)
                && Trigger.new[i].RecordType.DeveloperName != 'CBM_Appel_de_fonds_recouvrer' 
                && Trigger.new[i].RecordType.DeveloperName != 'CBM_Impaye_et_avoir_Post_Real'
              	&& Trigger.new[i].RecordType.DeveloperName != 'CBIActionsRecouvrementPartenaire'){
                
                if(!demandeDossierIDs.containsKey(Trigger.new[i].Dossier1__c)){
                    List<Case> cases = new List<case>();
                    cases.add(Trigger.new[i]);
                    demandeDossierIDs.put(Trigger.new[i].Dossier1__c,cases);
                }else{
                    List<Case> cases = (List<Case>) demandeDossierIDs.get(Trigger.new[i].Dossier1__c);
                    cases.add(Trigger.new[i]);
                    demandeDossierIDs.put(Trigger.new[i].Dossier1__c,cases);
                }
            }
            
        }
        
        // Vérifier que la liste des cases n'est pas vide,
        // puis lancer le traitement sur la liste des cases
        if(demandeDossierIDs.keySet().size() > 0)
            TR002ManageContract.RecupererNomTiers(demandeDossierIDs);
    }
  } 
  
  System.debug('#### Fin : CaseAfterUpdate');
     
}