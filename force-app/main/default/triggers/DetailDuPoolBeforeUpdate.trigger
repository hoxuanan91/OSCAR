trigger DetailDuPoolBeforeUpdate on Detail_du_Pool__c (before Update) {
    if(PAD.canTrigger('DetailDuPoolBeforeUpdate')){
        AP14DetailDuPool.insertUpdateCDFReporting(Trigger.new);
        AP14DetailDuPool.updateOpportunity(Trigger.new, 1);
    }
}