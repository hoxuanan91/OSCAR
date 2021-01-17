trigger ListeBienAfterDelete on ListeDeBien__c (after delete) {
	if(PAD.canTrigger('ListeBienAfterDelete')){
            AP13BienCBI.supprimerLienNCBien(Trigger.old);
    }
}