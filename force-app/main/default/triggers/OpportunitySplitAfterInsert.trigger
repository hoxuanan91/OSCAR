trigger OpportunitySplitAfterInsert on OpportunitySplit (after insert) {
    if(PAD.scriptIsStarted('OpportunitySplitAfterInsert')) {
        return;
    }
	/* if(PAD.canTrigger('OpportunitySplitAfterInsert')){
         AP15OpportunitySplit.getMontantCBIMontantBrutDeLaQPNL(trigger.new);
     }*/
}