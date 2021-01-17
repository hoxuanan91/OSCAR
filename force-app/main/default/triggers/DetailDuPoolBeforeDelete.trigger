trigger DetailDuPoolBeforeDelete on Detail_du_Pool__c (before Delete) { 
    if(PAD.canTrigger('DetailDuPoolBeforeDelete')){
        AP14DetailDuPool.deleteCDFReporting(Trigger.old);
        AP14DetailDuPool.updateOpportunity(Trigger.old, 2);
    }
}