trigger CommentairesAfterInsert on Commentaires__c (after insert) {
    
    if(PAD.scriptIsStarted('CommentairesAfterInsert')) {
        return;
    }

    List<Opportunity> oppToUpdate = new List<Opportunity>();
    
    if(PAD.canTrigger('CommentairesAfterInsert')) {
        
        // DHMOSCAR-623 - Récupère le dernier commentaire
        for (Commentaires__c com : [SELECT Id, Commentaire__c, ProjetAssocie__r.DernierCommentaire__c FROM Commentaires__c WHERE Id IN: Trigger.newMap.keyset()]) {
            oppToUpdate.add(new Opportunity(Id=com.ProjetAssocie__c, DernierCommentaire__c=com.Commentaire__c));
        }
        
        update oppToUpdate;
    }
}