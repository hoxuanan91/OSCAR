trigger ProjetAfterInsert on Projet__c (after insert) {
    if(PAD.canTrigger('ProjetAfterInsert')){
            AP04Projet.AutoCompletudeDossierFront(Trigger.new);
    }
}