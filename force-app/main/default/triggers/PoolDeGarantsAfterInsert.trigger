trigger PoolDeGarantsAfterInsert on PoolDeGarants__c (after insert) {
  
    if(PAD.canTrigger('PoolDeGarantsAfterInsert')){ 
            AP10PoolDeGarants.insertPDGReportingCBI(Trigger.new);
        }
    
}