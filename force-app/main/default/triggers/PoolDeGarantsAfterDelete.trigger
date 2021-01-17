trigger PoolDeGarantsAfterDelete on PoolDeGarants__c (after delete) {
        if(PAD.canTrigger('PoolDeGarantsAfterUpdate')){ 
             AP10PoolDeGarants.deletePDGReportingCBI(Trigger.old);
        }
}