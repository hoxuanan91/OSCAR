trigger CaseAfterDelete on Case (after delete) {
    if(PAD.scriptIsStarted('CaseAfterDelete')) {
        return;
    }
    System.debug('#### : CaseAfterDelete');
    if(PAD.canTrigger('TR002ManageContract')){
        //Déclaration de la liste des Ids des dossiers
        List<Id> dossierIds = new List<Id>();
        
        for(Case c : [SELECT Id, 
                            Status, 
                            Dossier1__c 
                        FROM Case 
                        WHERE RecordType.DeveloperName = 'CBM_Reamenagement' 
                        AND Id IN: Trigger.oldMap.keySet()]){
            System.debug(' Case C: ' +c);
            if(c.Status != null && c.Status.contains('Terminée')){
                System.debug('#### : bouble :' + c.Id + ' / ' + c.RecordTypeId + ' / ' + c.Dossier1__c);
                dossierIds.add(c.Dossier1__c);
            }
        }
        
        // Vérifier que la liste des cases n'est pas vide,
        // puis lancer le traitement sur la liste des cases
        if(!dossierIds.isEmpty())
            TR002ManageContract.CalculateNombreReamenagement(dossierIds);
    }
}