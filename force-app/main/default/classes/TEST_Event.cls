@isTest
public class TEST_Event {

    
    @testSetup 
    static void MethodPrepare() {
        
        Opportunity lOpportunity;
        Account lTiers;
        Projet__c lProjet;
        Account lReseau;
        Contact lContact;
        
        Test.startTest();
        
        RecordType lRecordTypeOpp   = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIProjetAssocie' and SobjectType = 'Opportunity'];
        RecordType lRecordTypeTiers = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Tiers'  and SobjectType = 'Account'] ; 
        RecordType lRecordTypeRA = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIReseau'  and SobjectType = 'ReseauApporteur__c'] ;
        RecordType lRecordTypeReseau = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIReseauAgence'  and SobjectType = 'Account'] ; //ODH CBIReseauBanqueCaisse
        RecordType lRecordTypeContact = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIReseau'  and SobjectType = 'Contact'] ;
    
        lTiers = new Account(Name = 'Test', RecordTypeId = lRecordTypeTiers.Id);
        insert lTiers;  
        
        lProjet = new Projet__c(Name = 'Test', NomDuTiers__c = lTiers.Id);
        insert lProjet;
        
        lReseau = new Account(Name = 'Test', RecordTypeId = lRecordTypeReseau.Id, Reseau__c = 'Banque Populaire');
        insert lReseau;
        
        lContact = new Contact(LastName = 'Test', AccountId = lReseau.Id, RecordTypeId = lRecordTypeContact.Id);
        insert lContact;
        
        lOpportunity = new Opportunity(
            Name = 'Test Garantie Triggers',
            RecordTypeId = lRecordTypeOpp.Id,
            NomDuProjet__c = lProjet.Id,
            AccountId = lTiers.Id,
            TypeDOperation__c = 'Construction',
            StageName = 'Pré-Etude',
            Jalon__c='Nouveau Projet',
            Amount =  3950000,
            PreloyersDEngagement__c =  0.10,
            PreloyersDeTVAPerc__c = 1.5,
            PreloyersDeFinancement__c = 1.5,
            CloseDate = Date.newInstance(2999,06,22),
            FraisDeDossier__c = 7975,
            QuotePartNL__c = 100,
            Chantier__c = true,
            DureDuChantierMois__c = 36,
            Avenant__c = false
        );
        insert lOpportunity;
        
        List<ReseauApporteur__c> reseaux = new List<ReseauApporteur__c>();
        
        ReseauApporteur__c reseau01 = new ReseauApporteur__c(      
            RESEAU__C = lReseau.Id,
            NOMDUPROJETASSOCIE__C = lOpportunity.Id,
            APPORTEURPRINCIPAL__C = true,
            NOMDUTIERS__C = lTiers.Id,
            DateEntreeEnRelation__c = Date.newInstance(2990, 5, 22),
            ChargeDAffaire__c = lContact.Id, 
            RecordTypeId = lRecordTypeRA.Id
        );
        
        ReseauApporteur__c reseau02 = new ReseauApporteur__c(      
            RESEAU__C = lReseau.Id,
            NOMDUPROJETASSOCIE__C = lOpportunity.Id,
            APPORTEURPRINCIPAL__C = false,
            NOMDUTIERS__C = lTiers.Id,
            DateEntreeEnRelation__c = Date.newInstance(2990, 5, 23),
            ChargeDAffaire__c = lContact.Id, 
            RecordTypeId = lRecordTypeRA.Id   
        );
        
        ReseauApporteur__c reseau03 = new ReseauApporteur__c(      
            RESEAU__C = lReseau.Id,
            NOMDUPROJETASSOCIE__C = lOpportunity.Id,
            APPORTEURPRINCIPAL__C = false,
            NOMDUTIERS__C = lTiers.Id  ,
            DateEntreeEnRelation__c = Date.newInstance(2990, 5, 24),
            ChargeDAffaire__c = lContact.Id, 
            RecordTypeId = lRecordTypeRA.Id
        );
        
        reseaux.add(reseau01);
        reseaux.add(reseau02);
        reseaux.add(reseau03);
        
        insert reseaux;
        
        Test.stopTest();
        
        
    }
        
        
        static testmethod void testUpdateDateOneEvent(){
            
            Test.startTest();
            
       		Opportunity lOpportunity = [SELECT Id FROM Opportunity WHERE Amount = 3950000 LIMIT 1];
            
        	Event lEvent = new Event(Type = 'Client-RDV Découverte', DurationInMinutes = 6, ActivityDateTime = Date.newInstance(2999, 05, 22), WhatId = lOpportunity.Id);
         
        	insert lEvent;
            
            //On récupère l'Opportunity pour voir si les changements ont bien été pris en compte
            Opportunity lOpportunityAfterInsert = [SELECT Id, Date1erContact__c, IDEvent1erContact__c, Date1erRDVClient__c, IDEvent1erRDV__c FROM Opportunity WHERE Amount = 3950000 LIMIT 1];
            
           	System.assertEquals( lEvent.ActivityDateTime, lOpportunityAfterInsert.Date1erContact__c);
            System.assertEquals( lEvent.Id, lOpportunityAfterInsert.IDEvent1erContact__c);
            
            System.assertEquals( lEvent.ActivityDateTime, lOpportunityAfterInsert.Date1erRDVClient__c);
            System.assertEquals( lEvent.Id, lOpportunityAfterInsert.IDEvent1erRDV__c);
        
            update lEvent;
        
        	delete lEvent;
            
            
            Test.stopTest();
            
        	
        }
    
    static testmethod void testUpdateDateTwoEvents(){

			Test.startTest();
            
       		Opportunity lOpportunity = [SELECT Id, Date1erContact__c, Date1erRDVClient__c FROM Opportunity WHERE Amount = 3950000 LIMIT 1];
            
        	Event lEvent = new Event(Type = 'Client-RDV Découverte', DurationInMinutes = 6, ActivityDateTime = Date.newInstance(2999, 05, 22), WhatId = lOpportunity.Id);
         
        	insert lEvent;
        
        	lOpportunity.Date1erContact__c = null;
            lOpportunity.Date1erRDVClient__c = null;
        
        	update lOpportunity;
        
        	// On insère un nouvel Event lié à l'Opp
        	Event lEvent02 = new Event(Type = 'Client-RDV Découverte', DurationInMinutes = 6, ActivityDateTime = Date.newInstance(2999, 05, 23), WhatId = lOpportunity.Id);
        	insert lEvent02;
                
            //On récupère l'Opportunity pour voir si les changements ont bien été pris en compte
            Opportunity lOpportunityAfterInsert = [SELECT Id, Date1erContact__c, IDEvent1erContact__c, Date1erRDVClient__c, IDEvent1erRDV__c FROM Opportunity WHERE Amount = 3950000 LIMIT 1];
                
        	System.assertEquals( lEvent02.ActivityDateTime, lOpportunityAfterInsert.Date1erContact__c);
            System.assertEquals( lEvent02.Id, lOpportunityAfterInsert.IDEvent1erContact__c);
            
            System.assertEquals( lEvent02.ActivityDateTime, lOpportunityAfterInsert.Date1erRDVClient__c);
            System.assertEquals( lEvent02.Id, lOpportunityAfterInsert.IDEvent1erRDV__c);
        
        	Test.stopTest();

			        
    }
    
    static testmethod void testUpdateProjetAssocie(){
        
        	Test.startTest();
            
        	Date dateEntree = Date.newInstance(2990, 5, 22);
        
       		Opportunity lOpportunity = [SELECT Id, Date1erContact__c, Date1erRDVClient__c FROM Opportunity WHERE Amount = 3950000 LIMIT 1];
            ReseauApporteur__c lReseau = [SELECT Id, Reseau__c FROM ReseauApporteur__c WHERE DateEntreeEnRelation__c = :dateEntree LIMIT 1];
        	Event lEvent = new Event(Type = 'Client-RDV Découverte', DurationInMinutes = 6, ActivityDateTime = Date.newInstance(2999, 05, 22), WhatId = lOpportunity.Id);
         
        	insert lEvent;
        
        	// On récupère l'event pour controler la mise à jour de ses valeurs
        	Event lEventAfterInsert = [SELECT Id, ReseauApporteur__c FROM Event WHERE Type = 'Client-RDV Découverte' AND DurationInMinutes = 6 LIMIT 1];
        	System.assertEquals(lReseau.Reseau__c, lEventAfterInsert.ReseauApporteur__c);
        
        	Test.stopTest();
        
    }

}