trigger DetailDuPoolBeforeInsert on Detail_du_Pool__c (before Insert) {
  if(PAD.canTrigger('DetailDuPoolAfterInsert')){
      AP14DetailDuPool.insertUpdateCDFReporting(Trigger.new);
      AP14DetailDuPool.updateOpportunity(Trigger.new, 0);
  }
}