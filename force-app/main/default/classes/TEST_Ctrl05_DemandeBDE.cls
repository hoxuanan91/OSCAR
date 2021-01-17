@isTest
public class TEST_Ctrl05_DemandeBDE{


     @testSetup 
    static void testButton(){
        
        Opportunity lOpportunity;
        Account lTiers;
        Account lTeteDeGroupe;
        Account lTiersEnRisque;
        Account lReseau;
        Projet__c lProjet;
        
        RecordType lRecordTypeOpp   = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIProjetAssocie' and SobjectType = 'Opportunity'];
        RecordType lRecordTypeTiers = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Tiers'  and SobjectType = 'Account'] ;
        RecordType lRecordTypeContact = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIReseau'  and SobjectType = 'Contact'] ;
        RecordType lRecordTypeRA = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIReseau'  and SobjectType = 'ReseauApporteur__c'] ;
        RecordType lRecordTypeGarantie = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIGarantieCBI' and SobjectType = 'Garantie__c'];
        
    
        lTiers = new Account(Name = 'ClientPreneur', RecordTypeId = lRecordTypeTiers.Id, N_SIREN__c =  '999999991');
        insert lTiers;  
        
        lTeteDeGroupe = new Account(Name = 'Tete de Groupe', RecordTypeId = lRecordTypeTiers.Id, N_SIREN__c =  '999999992');
        insert lTeteDeGroupe;  
        
        lTiersEnRisque = new Account(Name = 'Tiers En Risque Profile', RecordTypeId = lRecordTypeTiers.Id, N_SIREN__c =  '999999993');
        insert lTiersEnRisque;  
        
        lProjet = new Projet__c(Name = 'Test', NomDuTiers__c = lTiers.Id);
        insert lProjet;
               
        lOpportunity = new Opportunity(
            Name = 'Test Garantie Triggers',
            RecordTypeId = lRecordTypeOpp.Id,
            NomDuProjet__c = lProjet.Id,
            AccountId = lTiers.Id,
            TeteDeGroupe__c = lTeteDeGroupe.Id,
            TiersEnRisqueProfile__c = lTiersEnRisque.Id,
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
        
        List<DemandeBde__c> demandesBDE = new List<DemandeBde__c>{new DemandeBDE__c(ProjetAssocie__c = lOpportunity.Id, Tiers__c = lTiers.Id),
            													  new DemandeBDE__c(ProjetAssocie__c = lOpportunity.Id, Tiers__c = lTeteDeGroupe.Id),
            													  new DemandeBDE__c(ProjetAssocie__c = lOpportunity.Id, Tiers__c = lTiersEnRisque.Id)};
        
        insert demandesBDE;
        
        Opportunity lOpportunity02 = new Opportunity(
            Name = 'Test Garantie Triggers',
            RecordTypeId = lRecordTypeOpp.Id,
            NomDuProjet__c = lProjet.Id,
            AccountId = null,
            TeteDeGroupe__c = lTeteDeGroupe.Id,
            TiersEnRisqueProfile__c = lTiersEnRisque.Id,
            TypeDOperation__c = 'Construction',
            StageName = 'Pré-Etude',
            Jalon__c='Nouveau Projet',
            Amount =  3950000,
            PreloyersDEngagement__c =  0.10,
            PreloyersDeTVAPerc__c = 1.5,
            PreloyersDeFinancement__c = 1.5,
            CloseDate = Date.newInstance(2999,06,23),
            FraisDeDossier__c = 7975,
            QuotePartNL__c = 100,
            Chantier__c = true,
            DureDuChantierMois__c = 36,
            Avenant__c = false
        );
        insert lOpportunity02;
        
        List<DemandeBde__c> demandesBDE02 = new List<DemandeBde__c>{ new DemandeBDE__c(ProjetAssocie__c = lOpportunity02.Id, Tiers__c = lTeteDeGroupe.Id),
            													     new DemandeBDE__c(ProjetAssocie__c = lOpportunity02.Id, Tiers__c = lTiersEnRisque.Id)};
                                                                         
        insert demandesBDE02;
        
    }
    
    static testmethod void testDemandeBDEWithTiersPrincipal(){
        
        Date CloseDate = Date.newInstance(2999,06,22);
        
        Opportunity lopp = [SELECT Id FROM Opportunity WHERE CloseDate = :CloseDate];
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('ID',lopp.id);
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(lopp);
        Ctrl05_DemandeBDE demandeController = new Ctrl05_DemandeBDE(stdOpp);
        demandeController.save();
        
        Test.stopTest();
        
    }
    
    static testmethod void testDemandeBDEWithoutTiersPrincipal(){
        
        Date CloseDate = Date.newInstance(2999,06,23);
        
        Opportunity lopp = [SELECT Id FROM Opportunity WHERE CloseDate = :CloseDate];
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('ID',lopp.id);
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(lopp);
        Ctrl05_DemandeBDE demandeController = new Ctrl05_DemandeBDE(stdOpp);
        demandeController.save();
        
        Test.stopTest();
        
    }


}