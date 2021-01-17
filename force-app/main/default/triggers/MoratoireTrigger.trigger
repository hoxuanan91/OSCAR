trigger MoratoireTrigger on Moratoire_LLD__c (before update) {
	AP20_TriggerFactory.createHandler(Moratoire_LLD__c.getSobjectType());
}