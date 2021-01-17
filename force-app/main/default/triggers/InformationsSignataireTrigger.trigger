trigger InformationsSignataireTrigger on InformationsSignataire__c(after insert, after update ){

	if (Trigger.isAfter){
		if (Trigger.isInsert){
			TR002_InfoSignatairesHandler.onAfterInsert(Trigger.new);
		}

		if (Trigger.isUpdate){
			TR002_InfoSignatairesHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
		}
	}
}