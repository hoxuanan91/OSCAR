trigger FactureAfterUnDelete on Facture_non_lettree__c(after undelete) {

    System.debug('#### : FactureAfterUnDelete ');
    if(PAD.canTrigger('TR001ManageCase_CalculFacture')) 
    {
        //Déclaration de la liste des Ids des factures
        List<ID> factureIDs = new List<ID>();
        
        for(integer i = 0; i < Trigger.new.size() ; i++){
                factureIDs .add(Trigger.new[i].Demande_rattachee__c );
            }
            
        // Vérifier que la liste des cases n'est pas vide,
        // puis lancer le traitement sur la liste des cases
//        if(factureIDs .size() > 0)
//            TR001ManageCase.CalculateNombreFactureNonLettree(factureIDs );
  }
}