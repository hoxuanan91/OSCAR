trigger OpportunityBeforeUpdate on Opportunity (before update) {
    System.debug('@@ start');
    if(PAD.scriptIsStarted('OpportunityBeforeUpdate')) {
        return;
    }  
    
   // GlobalTriggerExecute triggerExe = new GlobalTriggerExecute(new List<ATriggerAction> {new OpportunityNotifyAction()});
   // triggerExe.execute(trigger.new,Trigger.oldMap);
   /* 
 if(PAD.canTrigger('OpportunityBeforeUpdate'))   {
 
     // Qualify records
    List<Opportunity> qualifiedOrders = new List<Opportunity>();
    for (Opportunity opp : Trigger.new) {
        if (
            Opp.recordType.DeveloperName.IndexOf('CBI') <> -1  // Est un Projet Associé CBI
            && Opp.recordType.DeveloperName.IndexOf('Waiver') == -1
        )       
         {
            qualifiedOrders.add(opp); 
        }   
    }

    // Now do what you want with the qualified records.
    if (qualifiedOrders.isEmpty() == false) {
         AP03Opportunity.UpdateProjetStageJalonDate(Trigger.new,Trigger.old);
         AP03Opportunity.updateFlagChantier(Trigger.new);   
   }}*/
}