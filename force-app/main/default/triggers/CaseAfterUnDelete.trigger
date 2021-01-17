trigger CaseAfterUnDelete on Case (after undelete) {
	if(PAD.scriptIsStarted('CaseAfterUnDelete')) {
        return;
    }
    System.debug('#### : CaseAfterUnDelete ');
    if(PAD.canTrigger('TR002ManageContract')) 
    {
        //Déclaration de la liste des Ids des dossiers
        List<Id> dossierIds = new List<Id>();
    
        for(Case c : [SELECT Id, 
                            Status, 
                            Dossier1__c
                        FROM Case 
                        WHERE RecordType.DeveloperName = 'CBM_Reamenagement' 
                        AND Id IN: Trigger.newMap.keySet()]){
    
            if(c.Status != null && c.Status.contains('Terminée')){
                System.debug('#### : bouble :' + c.Id + ' / '  + c.Dossier1__c);
                dossierIds.add(c.Dossier1__c);
            }
            
        }
        
        // Vérifier que la liste des cases n'est pas vide,
        // puis lancer le traitement sur la liste des cases
        if(!dossierIds.isEmpty())
            TR002ManageContract.CalculateNombreReamenagement(dossierIds);
    }
}