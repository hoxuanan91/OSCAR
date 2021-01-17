trigger QuoteAfterUpdate on Quote (After update) {
 		 if(PAD.canTrigger('QuoteAfterUpdate')){
        
             List<Quote> quotesCBIList = new List<Quote>();
             
             for (Quote propal : [SELECT Id FROM Quote WHERE RecordType.developername like '%cbi%' AND Id IN: Trigger.newMap.keySet()]) {
                 quotesCBIList.add(propal);
             }
             
             if (quotesCBIList.size() > 0) {
                AP09Quote.DatespropositionCommercialesToProjetAssocie(Trigger.new);
                AP09Quote.DatesPCOMenvoye(Trigger.new);
                AP09Quote.ajoutPropalSurCalculatrice(Trigger.old, Trigger.new);
             }
        }
}