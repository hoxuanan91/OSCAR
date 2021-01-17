trigger CaseBeforeInsert on Case (before insert) {
    if(PAD.scriptIsStarted('CaseBeforeInsert')) { 
        return;
    }
    System.debug('#### Début : CaseBeforeInsert');
    
    if(PAD.canTrigger('TR001ManageCaseSaufImpaye')) 
    {
        
        System.debug('#### : CaseBeforeInsert - TR001ManageCaseSaufImpaye');
        
        //Déclaration des ID des recordType
        // Cap Gemini - JR - 05/12/17 - Le Type d'Enregistrement CBI - Actions de Recouvrement (CBIActionsRecouvrement) a été ajouté
        Map<String,Id> RTs = DAL.getRecordType('Case');
        ID rtActionRecouvrement = (ID)RTs.get('CBM_Actions_de_Recouvrement');
        ID rtActionRecouvrementCBI = (ID)RTs.get('CBIActionsRecouvrement');
        ID rtAppelFondARecouvrer = (ID)RTs.get('CBM_Appel_de_fonds_recouvrer');
        ID rtImpayesAvoirPostReal = (ID)RTs.get('CBM_Impaye_et_avoir_Post_Real');
        
        System.debug('#### : rtActionRecouvrement :' + rtActionRecouvrement);
        System.debug('#### : rtActionRecouvrementCBI :' + rtActionRecouvrementCBI);
        System.debug('#### : rtAppelFondARecouvrer :' + rtAppelFondARecouvrer);
        System.debug('#### : rtImpayesAvoirPostReal :' + rtImpayesAvoirPostReal);
        
        //Déclaration de la liste des cases
        List<Case> cases = new List<Case>();
        
        for(integer i = 0; i < Trigger.new.size() ; i++){
            
            if( Trigger.new[i].RecordType.DeveloperName != 'CBM_Actions_de_Recouvrement' &&
               Trigger.new[i].RecordType.DeveloperName != 'CBIActionsRecouvrement' &&
               Trigger.new[i].RecordType.DeveloperName != 'CBM_Appel_de_fonds_recouvrer' &&
               Trigger.new[i].RecordType.DeveloperName != 'CBM_Impaye_et_avoir_Post_Real' 
            ){ 
                
                cases.add(Trigger.new[i]);
            }
        }
        
        // Vérifier que la liste des cases n'est pas vide,
        // puis lancer le traitement sur la liste des cases
        if(cases.size() > 0)
            TR001ManageCase.GetCasesPrepared(cases,null);
        
    }
    
    //   if(PAD.canTrigger('CaseBeforeInsert')){
    //       
    //        System.debug('#### : CaseBeforeInsert - AP18Demande.rapatrierDonnees');
    //
    //       AP18Demande.rapatrierDonnees(Trigger.new);
    //   
    //   }
    
    System.debug('#### Fin : CaseBeforeInsert');
    
}