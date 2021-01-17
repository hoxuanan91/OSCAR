public class AP01Event {
    
    
    public static void updateDates(Event[] events){
        
        //Ids des objets à traiter
        Set<Id> oppsIds = new Set<Id>();
        
        // Map des opportunités à mettre à jour
        Map<Id, Opportunity> oppsToUpdate = new Map<Id, Opportunity>();
        
        for(Event evt : events){
            // Si le what Id est de type Opportunity
            String whatId = evt.WhatId;
            if(whatId != null && whatId.substring(0,3) == '006'){
                oppsIds.add(evt.WhatId);
            }
        }
        
        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>([SELECT Id, Date1erContact__c, IDEvent1erContact__c, Date1erRDVClient__c, IDEvent1erRDV__c FROM Opportunity WHERE Id IN :oppsIds]);

        for(Event evt : events){
            
            // Si le whatId est bien une opportunity
            String whatId = evt.WhatId;
            if(whatId != null && whatId.substring(0,3) == '006'){
                Opportunity opp = oppsMap.get(evt.WhatId);
                
                if(evt.TypeRDVAnimation__c == 'Client-RDV Découverte'){
                    Opportunity oppToUpdate = UpdateDate1erContact(opp, evt.StartDateTime, evt.Id);
                    oppsToUpdate.put(oppToUpdate.Id, oppToUpdate);  
                }
                if((evt.TypeRDVAnimation__c == 'Client-RDV Découverte') || (evt.TypeRDVAnimation__c == 'Client-RDV Client')){
                    Opportunity oppToUpdate = UpdateDate1erRDV(opp, evt.StartDateTime, evt.Id);
                    oppsToUpdate.put(oppToUpdate.Id, oppToUpdate);  
                }
            }
                          
        }
        
        update oppsToUpdate.values();
        
    }
   

    public static Opportunity UpdateDate1erContact(Opportunity opp, Datetime ActivityDateTime, String EventId){ 
                        
               if(opp != null){  
                   
                if((opp.Date1erContact__c == null )&&(opp.IDEvent1erContact__c == null )) {
                    opp.Date1erContact__c = ActivityDateTime.date();
                    opp.IDEvent1erContact__c =  EventId;
                } 
                else if((opp.IDEvent1erContact__c == EventId )&&(opp.Date1erContact__c != null )) {
                    if(ActivityDateTime >= Date.today() ) {
                        opp.Date1erContact__c = ActivityDateTime.date();
                    }                    
                }else if((opp.IDEvent1erContact__c != EventId )&&(opp.Date1erContact__c == null )) {
                    if(ActivityDateTime >= Date.today() ) {
                        opp.Date1erContact__c = ActivityDateTime.date();
                        opp.IDEvent1erContact__c = EventId;
                    }
                }
            }
        
        return opp;
            
        }
    
    public static Opportunity UpdateDate1erRDV(Opportunity opp, Datetime ActivityDateTime, String EventId){ 
               
               if(opp != null){  
                if((opp.Date1erRDVClient__c == null )&&(opp.IDEvent1erRDV__c == null )) {
                    opp.Date1erRDVClient__c = ActivityDateTime.date();
                    opp.IDEvent1erRDV__c =  EventId;
                }               
                else if((opp.IDEvent1erRDV__c == EventId )&&(opp.Date1erRDVClient__c != null )) {
                    if(ActivityDateTime >= Date.today() ) {
                        opp.Date1erRDVClient__c = ActivityDateTime.date();
                    }                    
                } else if((opp.IDEvent1erRDV__c != EventId )&&(opp.Date1erRDVClient__c == null )) {
                    if(ActivityDateTime >= Date.today() ) {
                        opp.Date1erRDVClient__c = ActivityDateTime.date();
                        opp.IDEvent1erRDV__c = EventId;
                    }
                }
            }
        
        return opp;
            
        }
    
    public static void UpdateProjetAssocie(Event[] events){ 
        
        //Ids des objets à traiter
        Set<Id> oppsIds = new Set<Id>();
        
        // Map des opportunités à mettre à jour
        Map<Id, Opportunity> oppsToUpdate = new Map<Id, Opportunity>();
        
        for(Event evt : events){
            // Si le what Id est de type Opportunity
            String whatId = evt.WhatId;
            if(whatId != null && whatId.substring(0,3) == '006'){
                oppsIds.add(evt.WhatId);
            }
        }
        
        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>([SELECT Id, Date1erContact__c, IDEvent1erContact__c FROM Opportunity WHERE Id IN :oppsIds]);
        List<ReseauApporteur__c> reseauxList = [SELECT Id,ApporteurPrincipal__c,NomDuTiers__c,Reseau__c, NomDuProjetAssocie__c FROM ReseauApporteur__c WHERE NomDuProjetAssocie__c IN :oppsIds and ApporteurPrincipal__c = true  ];
        
        for(Event evt : events){
            
            List<ReseauApporteur__c> REApp = new List<ReseauApporteur__c>();
            
            for(ReseauApporteur__c reseau : reseauxList){
                if(evt.WhatId == reseau.NomDuProjetAssocie__c){
                    REApp.add(reseau);
                }
            }
                        
            if(REApp.size() >= 1){
                if((REApp[0].ApporteurPrincipal__c != null)&&(REApp[0].Reseau__c != null)){
                    evt.ReseauApporteur__c = REApp[0].Reseau__c;
                } 
            }
            
        }
   
    }
}