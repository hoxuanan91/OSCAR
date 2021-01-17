trigger PoolDeGarantsAfterUpdate on PoolDeGarants__c (after Update) {
        if(PAD.canTrigger('PoolDeGarantsAfterUpdate')){ 
            AP10PoolDeGarants.updatePDGReportingCBI(Trigger.new);
        }
}