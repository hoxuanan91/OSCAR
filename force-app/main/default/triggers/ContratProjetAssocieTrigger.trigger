trigger ContratProjetAssocieTrigger on Contrat_ProjetAssocie__c (after insert, after update, after delete){
    AP20_TriggerFactory.createHandler(Contrat_ProjetAssocie__c.getSobjectType());
}