trigger CaseBeforeUpdate on Case (before update) {

//List<User> User = [SELECT Id, Name, Interface__c FROM User WHERE Id=:userinfo.getUserId() LIMIT 1];

//System.debug('#### ByPass CaseBeforeUpdate : ' + User[0].Name + ' Interface ' + User[0].Interface__c );

//if(User[0].Interface__c == false){
	if(PAD.scriptIsStarted('CaseBeforeInsert') && !Test.isRunningTest()){
       
        return;
    }
    System.debug('#### Début : CaseBeforeUpdate');

    if(PAD.canTrigger('CaseBeforeUpdate')) 
    {
    
        System.debug('#### : CaseBeforeUpdate - TR001ManageCase');
        
        //Déclaration de la liste des cases
        List<Case> cases = new List<Case>();
        List<Case> casesOld = new List<Case>();
        List<ID> listIds= new List<ID>();
    
        for(integer i = 0; i < Trigger.new.size() ; i++){
        
        /* system.debug('@@  Trigger.new[i].OwnerId '+ Trigger.new[i].OwnerId);
            system.debug('@@  Trigger.old[i].OwnerId '+ Trigger.old[i].OwnerId);
            system.debug('@@  Trigger.old[i].DateDecisionApprobation__c '+ Trigger.old[i].DateDecisionApprobation__c);
            system.debug('@@  Trigger.new[i].DateDecisionApprobation__c '+ Trigger.new[i].DateDecisionApprobation__c);*/
                
        if(Trigger.new[i].OwnerId == Trigger.old[i].OwnerId           
                &&
                (
                Trigger.new[i].status != Trigger.old[i].status 
                ||
                Trigger.new[i].Phase__c != Trigger.old[i].Phase__c 
                ||
                Trigger.new[i].Derniere_Date_PhaseAjour__c != Trigger.old[i].Derniere_Date_PhaseAjour__c 
                ||
                Trigger.new[i].Derniere_Date_Affecte__c != Trigger.old[i].Derniere_Date_Affecte__c 
                || 
                Trigger.new[i].Derniere_Date_PriseEnCharge__c != Trigger.old[i].Derniere_Date_PriseEnCharge__c
                || 
                Trigger.new[i].DateRecepDde__c != Trigger.old[i].DateRecepDde__c
                ||
                Trigger.new[i].Derniere_Date_Termine__c != Trigger.old[i].Derniere_Date_Termine__c
                ||
                Trigger.new[i].Derniere_Date_APrendreEnCharge__c != Trigger.old[i].Derniere_Date_APrendreEnCharge__c 
                || 
                Trigger.new[i].Dossier_complet__c != Trigger.old[i].Dossier_complet__c 
                || 
                Trigger.new[i].Avenant_envoye__c != Trigger.old[i].Avenant_envoye__c
                ||
                Trigger.new[i].Avenant_recu__c != Trigger.old[i].Avenant_recu__c 
                || 
                Trigger.new[i].Transfert_realise__c != Trigger.old[i].Transfert_realise__c
                ||
                Trigger.new[i].Accord_demande_la_deleg_banque__c != Trigger.old[i].Accord_demande_la_deleg_banque__c 
                || 
                Trigger.new[i].Dossier_complet_attente_reglement__c != Trigger.old[i].Dossier_complet_attente_reglement__c 
                || 
                Trigger.new[i].Reglement_assurance_recu__c != Trigger.old[i].Reglement_assurance_recu__c
                ||
                Trigger.new[i].Perte_FI_doc_envoi_docs_au_courtier__c != Trigger.old[i].Perte_FI_doc_envoi_docs_au_courtier__c 
                || 
                Trigger.new[i].Reglement_du_courtier_recu__c != Trigger.old[i].Reglement_du_courtier_recu__c
                ||
                Trigger.new[i].Bris_machine_envoi_docs_courtier__c != Trigger.old[i].Bris_machine_envoi_docs_courtier__c 
                || 
                Trigger.new[i].Envoi_propo_indemnisation_au_client__c != Trigger.old[i].Envoi_propo_indemnisation_au_client__c
                || 
                Trigger.new[i].Documents_envoyes_au_courtier__c != Trigger.old[i].Documents_envoyes_au_courtier__c 
                ||
                Trigger.new[i].Envoi_docs_courtier_prise_en_charge__c != Trigger.old[i].Envoi_docs_courtier_prise_en_charge__c 
                || 
                Trigger.new[i].Decision_courtier_prise_en_charge__c != Trigger.old[i].Decision_courtier_prise_en_charge__c
                || 
                Trigger.new[i].Date_de_traitement_de_la_MEL__c != Trigger.old[i].Date_de_traitement_de_la_MEL__c
                ||
                Trigger.new[i].DateDecisionApprobation__c != Trigger.old[i].DateDecisionApprobation__c   
                ||
                Trigger.new[i].ProjetAssocie__c != Trigger.old[i].ProjetAssocie__c   
                )
            ){
        
                cases.add(Trigger.new[i]);
                casesOld.add(Trigger.old[i]);
                listIds.add(Trigger.new[i].ID);
            }
        }
        
        // Vérifier que la liste des cases n'est pas vide,
        // puis lancer le traitement sur la liste des cases  
        if(cases.size() > 0)
             TR001ManageCase.GetCasesPrepared(cases,casesOld);
    
    }
    
    // Capgemini JR 20/02/18 - Ajouter IF pour ne pas prendre en Compte les Demandes Actions de Recouvrement
    if(PAD.canTrigger('TR001ManageCase_updateSupportUser')) 
    {
    
        System.debug('#### : CaseAfterUpdate - TR001ManageCase_updateSupportUser');
    
        //Déclaration de la liste des cases
        List<ID> listIds= new List<ID>();
        Map<Id,String> RTsOrderByIds = DAL.getRecordTypeOrderById('Case');

        for(integer i = 0; i < Trigger.new.size() ; i++){
        
      if(!RTsOrderByIds.get(Trigger.new[i].RecordTypeId).startsWith('CBM_Actions_de_Recouvrement')){
        
            listIds.add(Trigger.new[i].ID);
            
           }  
        }
        
        // Vérifier que la liste des cases n'est pas vide,
        // puis lancer le traitement sur la liste des cases  
        if(listIds != null && listIds.size() > 0)
            TR001ManageCase.updateSupportUser(listIds,Trigger.newMap);
        
    }
    
     //Add by Mourad SAIR 02/04/2015
      if(PAD.canTrigger('CreateCommentCase'))   
       {    
       
        System.debug('#### : CaseAfterUpdate - CreateCommentCase');
       
            list<Case> CasesComment = new list<Case>();
              for(Case Ca : Trigger.new)
                 //Récupérer les Ids des Demandes avec le champ 'Commentaire en cours' renseigné afin de créer un commentaire sur la demande en cours
                 if (Ca.CommentaireC__c != null && Ca.CommentaireC__c!= '')CasesComment.add(Ca);
                    
            // Vérifier que la liste des casesComment n'est pas vide,
            // puis lancer le traitement sur la liste des cases
            if(CasesComment.size() > 0) TR001ManageCase.CreateCommentCaseBeforeUpdate(CasesComment);
       }
     //End Mourad  
     
     
     if(PAD.canTrigger('FillNotaireCase')){

        System.debug('#### : CaseAfterUpdate - FillNotaireCase');

        List<Case> cases = new List<Case>();

        Map<String,Id> RTs = DAL.getRecordType('Case');
        Map<Id,String> RTsOrderByIds = DAL.getRecordTypeOrderById('Case');

        for(integer i = 0; i < Trigger.new.size() ; i++){
            
            if( RTsOrderByIds.get(Trigger.new[i].RecordTypeId).startsWith('CBI') && Trigger.new[i].NotaireEnCharge__c == null && Trigger.new[i].Dossier1__c != null){     
                cases.add(Trigger.new[i]);
            }
            
        }
        
        // Vérifier que la liste des cases n'est pas vide,
        // puis lancer le traitement sur la liste des cases
        if(cases.size() > 0)
            TR001ManageCase.MiseAJourNotaire(cases);
     }  
   
  
  System.debug('#### Fin : CaseBeforeUpdate');

}