trigger FactureAfterInsert on Facture_non_lettree__c(after insert) {

    System.debug('#### : FactureAfterInsert ');
    
    if(PAD.canTrigger('TR001ManageCase_CalculPhase')) 
    {
        //Déclaration de la liste des Ids des factures
        Set<ID> demandeIDs = new Set<ID>();
        
        for(integer i = 0; i < Trigger.new.size() ; i++){
                demandeIDs .add(Trigger.new[i].Demande_rattachee__c );
        }
            
        // Vérifier que la liste des demandes n'est pas vide,
        // puis lancer le traitement sur la liste des demandes
//        if(demandeIDs .size() > 0)
//            TR001ManageCase.CalculatePhaseDemande(demandeIDs );
    }
    
    if(PAD.canTrigger('TR001ManageCase_CalculFacture')) 
    {
        //Déclaration de la liste des Ids des factures
        List<ID> demandeIDs = new List<ID>();
        
        for(integer i = 0; i < Trigger.new.size() ; i++){
                demandeIDs .add(Trigger.new[i].Demande_rattachee__c );
        }
            
        // Vérifier que la liste des demandes n'est pas vide,
        // puis lancer le traitement sur la liste des demandes
//        if(demandeIDs .size() > 0)
//            TR001ManageCase.CalculateNombreFactureNonLettree(demandeIDs );
    }
}