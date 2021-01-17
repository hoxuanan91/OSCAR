trigger OpportunityBeforeDelete on Opportunity (Before Delete) {    
    if(PAD.scriptIsStarted('OpportunityBeforeDelete')) {
        return;
    }
if(PAD.canTrigger('OpportunityBeforeDelete')) 
    {
        for(integer i = 0; i < Trigger.old.size() ; i++){ 
          System.debug('Trigger old - ' + Trigger.old[i] );   
         //03Opportunity.UpdateProjetStageJalonDate(Trigger.new[i],Trigger.old[i]);
        }
        
    }
}