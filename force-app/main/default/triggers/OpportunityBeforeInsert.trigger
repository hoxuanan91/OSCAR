trigger OpportunityBeforeInsert on Opportunity (before insert) {
    System.debug('@@ start');
    if(PAD.scriptIsStarted('OpportunityBeforeInsert')) {
        return;
    }
    if(PAD.canTrigger('OpportunityBeforeInsert'))
    {
        AP03Opportunity.UpdateProjetNbPa(Trigger.new);
    }
}