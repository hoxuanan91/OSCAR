trigger CalculetteROEBeforeUpdate on CalculetteROE__c (before update ) {
    
    if(PAD.scriptIsStarted('CalculetteROEBeforeUpdate')) {
        return;
    }
    
    if(PAD.canTrigger('CalculetteROEBeforeUpdate')){ 
        //Declare a property in your apex class 
        AP17CalculetteROE.setROE(Trigger.new, Trigger.old);
        //Map<Id, RecordType> rtMap = new Map<Id, RecordType>([SELECT Id, DeveloperName, RecordType.Name FROM RecordType WHERE DeveloperName = 'CBICalc%']);  
    }  
}