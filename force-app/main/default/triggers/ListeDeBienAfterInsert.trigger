trigger ListeDeBienAfterInsert on ListeDeBien__c (after insert) {
	if(PAD.canTrigger('ListeDeBienAfterInsert')){
            AP05ListeDeBien.AutoCompletudeDossierFront(trigger.newMap);
    }
}