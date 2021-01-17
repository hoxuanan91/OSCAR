trigger QuoteAfterDelete on Quote (after delete) {

    if(PAD.canTrigger('QuoteAfterDelete')){
        List<Quote> quotesCBIList = new List<Quote>();
        
        for (Quote propal : Trigger.old) {
            if (propal.CalculetteROE__c != null) {
             	quotesCBIList.add(propal);   
            }
        }
        
        if (quotesCBIList.size() > 0) {
    		AP09Quote.nettoyageDesDonnees(Trigger.old);
        }
        
     }
}