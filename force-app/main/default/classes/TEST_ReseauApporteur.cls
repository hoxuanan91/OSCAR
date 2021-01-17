@isTest
public class TEST_ReseauApporteur {

    @testSetup 
    static void methodPrepare(){

        Opportunity lOpportunity;
        Account lTiers;
        Account lReseau;
        Projet__c lProjet;
        
        RecordType lRecordTypeOpp   = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIProjetAssocie' and SobjectType = 'Opportunity'];
        RecordType lRecordTypeTiers = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Tiers'  and SobjectType = 'Account'] ;
        RecordType lRecordTypeReseau = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIReseauBanqueCaisse'  and SobjectType = 'Account'] ;
        RecordType lRecordTypeContact = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIReseau'  and SobjectType = 'Contact'] ;
        RecordType lRecordTypeRA = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIReseau'  and SobjectType = 'ReseauApporteur__c'] ;
        
    
        lTiers = new Account(Name = 'Test', RecordTypeId = lRecordTypeTiers.Id);
        insert lTiers;  
        
        lReseau = new Account(Name = 'Test', RecordTypeId = lRecordTypeReseau.Id, Reseau__c = 'Banque Populaire');
        insert lReseau;   
        
        lProjet = new Projet__c(Name = 'Test', NomDuTiers__c = lTiers.Id);
        insert lProjet;
        
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
            CloseDate = Date.newInstance(2018,06,22),
            FraisDeDossier__c = 7975,
            QuotePartNL__c = 100,
            Chantier__c = true,
            DureDuChantierMois__c = 36
        );
        insert lOpportunity; 
        
        Contact lContact = new Contact(LastName = 'Test', AccountId = lReseau.Id, RecordTypeId = lRecordTypeContact.Id, Email = 'test@test.fr');
        insert lContact;
        
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
    }
    

    static testmethod void testModifierReseauApporteur(){
        
        List<ReseauApporteur__c> reseaux = new List<ReseauApporteur__c>();
        Test.startTest();
        Date lDate = Date.newInstance(2990, 5, 22);
        Date lDate02 = Date.newInstance(2990, 5, 23);
        Date lDate03 = Date.newInstance(2990, 5, 24);
        
        ReseauApporteur__c reseau = [SELECT Id, APPORTEURPRINCIPAL__C, NOMDUPROJETASSOCIE__C, DateEntreeEnRelation__c, RESEAU__C FROM ReseauApporteur__c WHERE DateEntreeEnRelation__c = :lDate LIMIT 1];
        ReseauApporteur__c reseau02 = [SELECT Id, APPORTEURPRINCIPAL__C, NOMDUPROJETASSOCIE__C, DateEntreeEnRelation__c, RESEAU__C FROM ReseauApporteur__c WHERE DateEntreeEnRelation__c = :lDate02 LIMIT 1];
        ReseauApporteur__c reseau03 = [SELECT Id, APPORTEURPRINCIPAL__C, NOMDUPROJETASSOCIE__C, DateEntreeEnRelation__c, RESEAU__C FROM ReseauApporteur__c WHERE DateEntreeEnRelation__c = :lDate03 LIMIT 1];

        reseau.DateEntreeEnRelation__c = Date.newInstance(2990, 6, 22);
        reseau02.DateEntreeEnRelation__c = Date.newInstance(2990, 6, 23);
        reseau03.DateEntreeEnRelation__c = Date.newInstance(2990, 6, 24);
        
        reseaux.add(reseau);
        reseaux.add(reseau02);
        reseaux.add(reseau03);
        
        update reseaux;
        
        // On récupère l'OPP
        Opportunity lOpportunityUpdateRAPP = [SELECT Id, NomDuProjet__c, NbDePoolFinancement__c, EmailChargeDAffaireN1__c, EmailChargeDAffaireN2__c, EmailChargeDAffaireN3__c
                                              FROM Opportunity WHERE Amount = 3950000 LIMIT 1];
        System.assertEquals('test@test.fr', lOpportunityUpdateRAPP.EmailChargeDAffaireN1__c);
        System.assertEquals('test@test.fr', lOpportunityUpdateRAPP.EmailChargeDAffaireN2__c);
        System.assertEquals('test@test.fr', lOpportunityUpdateRAPP.EmailChargeDAffaireN3__c);
        
        delete reseaux;
        
        // On récupère l'OPP
        Opportunity lOpportunityDeleteRAPP = [SELECT Id, NomDuProjet__c, NbDePoolFinancement__c, EmailChargeDAffaireN1__c, EmailChargeDAffaireN2__c, EmailChargeDAffaireN3__c
                                              FROM Opportunity WHERE Amount = 3950000 LIMIT 1];
        System.assertEquals(null, lOpportunityDeleteRAPP.EmailChargeDAffaireN1__c);
        System.assertEquals(null, lOpportunityDeleteRAPP.EmailChargeDAffaireN2__c);
        System.assertEquals(null, lOpportunityDeleteRAPP.EmailChargeDAffaireN3__c);
        
        Test.stopTest();
              
    }
    
}