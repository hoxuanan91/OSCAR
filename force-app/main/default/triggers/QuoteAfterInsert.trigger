trigger QuoteAfterInsert on Quote (After insert) {
	
    if(PAD.canTrigger('QuoteAfterInsert')) {
        
        List<Quote> quotesCBIList = new List<Quote>();
        
        for (Quote propal : [SELECT Id FROM Quote WHERE RecordType.developername like '%cbi%' AND Id IN: Trigger.newMap.keySet()]) {
            quotesCBIList.add(propal);
        }
        
        if (quotesCBIList.size() > 0) {
			AP09Quote.ajoutPropalSurCalculatrice(null, Trigger.new);
        }
        
    } 
}