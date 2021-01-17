trigger ControleMetierBeboreInsert on ControleMetier__c (before insert) {
    if(PAD.scriptIsStarted('ControleMetierBeboreInsert')) {
        return;
    }
    if(PAD.canTrigger('ControleMetierBeboreInsert')) {
       ControleMetierManager.ControleMetierCreatedOrFindParent(Trigger.new);
    }
    
}