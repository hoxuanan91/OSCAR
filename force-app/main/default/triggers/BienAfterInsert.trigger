trigger BienAfterInsert on Bien_CBI__c (After insert) {
    if(PAD.canTrigger('BienAfterInsert')){
            AP13BienCBI.AddPoolDeBien(Trigger.new);
    }
    

}