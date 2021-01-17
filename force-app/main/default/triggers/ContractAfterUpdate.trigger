trigger ContractAfterUpdate on Contract (after update) {
 System.debug('#### : ContractAfterUpdate');
    if(PAD.scriptIsStarted('ContractAfterUpdate')) {
        return;
    }
    
    // GlobalTriggerExecute triggerExe = new GlobalTriggerExecute(new List<ATriggerAction> {new ContractNotifyAction()});
    //triggerExe.execute(trigger.new,Trigger.oldMap);
    if(PAD.canTrigger('TR002ManageContract_MAJDateMEL')) 
    {
         //Déclaration de la liste des Ids des dossiers modifiées
        Set<ID> dossierIDs = new Set<ID>();
        
        for(integer i = 0; i < Trigger.new.size() ; i++){
            if(Trigger.new[i].Date_de_traitement_MEL__c !=  Trigger.old[i].Date_de_traitement_MEL__c)
                dossierIDs.add(Trigger.new[i].ID);
        }
        
        if(dossierIDs.size() > 0)
            TR002ManageContract.MiseAjourDateMEL(dossierIDs);
   
    }
   
}