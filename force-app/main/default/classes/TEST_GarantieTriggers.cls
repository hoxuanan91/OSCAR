@isTest
public class TEST_GarantieTriggers {

 
    @testSetup
    static void makeData(){
             
        Opportunity lOpportunity;
    	Account lTiers;
        
        Test.startTest();
        
        RecordType lRecordTypeOpp = [SELECT Id, Name FROM RecordType WHERE Name = 'CBI - Projet Associé'];
        RecordType lRecordTypeTiers = [SELECT Id, Name FROM RecordType WHERE Name = 'Tiers'];
        
        lTiers = new Account(Name = 'Test', RecordTypeId = lRecordTypeTiers.Id);
        insert lTiers;      
        
        Projet__c lProjet = new Projet__c(Name = 'Test', NomDuTiers__c = lTiers.Id);
        insert lProjet;
        
        lOpportunity = new Opportunity(
            Name = 'Test Garantie Triggers',
            RecordTypeId = lRecordTypeOpp.Id,
            NomDuProjet__c = lProjet.Id,
            AccountId = lTiers.Id, 
            TypeDOperation__c = 'Acquisition et Travaux',
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
            Copropriete__c = true,
            VEFA__c = false 
        );
        insert lOpportunity;  
        
        Test.stopTest();

    }
    
    static testmethod void testDepotDeGarantie(){

        Date CloseDate = Date.newInstance(2999,06,22);
        
        Opportunity lOpportunity = [SELECT Id FROM Opportunity WHERE CloseDate = :CloseDate];
        Account lTiers = [SELECT Id FROM Account WHERE Name = 'Test'];
        
        Test.startTest();
        
        RecordType lRecordTypeGarantie = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIGarantieCBI'];
        Garantie__c lGarantie = new Garantie__c(RecordTypeId = lRecordTypeGarantie.Id, NomdelaProjetAssocie__c = lOpportunity.Id, Type__c = 'Dépôt de garantie', TiersCautionSiExistant__c = lTiers.Id, Montant__c = 2000);
        insert lGarantie;
        
        List<Opportunity> lOppToTest = [SELECT Id, TopDepotGarantie__c FROM Opportunity WHERE Id = :lOpportunity.Id ];       
        System.assertEquals(true, lOppToTest[0].TopDepotGarantie__c, 'La valeur du flag topDeGarantie = false au lieu de true');
        
        lGarantie.Type__c = 'Bank deposit';
        update lGarantie;
        
        List<Opportunity> lOppToTest2 = [SELECT Id, TopDepotGarantie__c FROM Opportunity WHERE Id = :lOpportunity.Id ];       
        System.assertEquals(false, lOppToTest2[0].TopDepotGarantie__c, 'La valeur du flag topDeGarantie = true au lieu de false');        
       
       // Garantie__c lGarantie2 = new Garantie__c(RecordTypeId = lRecordTypeGarantie.Id, NomdelaProjetAssocie__c = lOpportunity.Id, Type__c = 'Dépôt de garantie', TiersCautionSiExistant__c = lTiers.Id, Montant__c = 2000);
        //insert lGarantie2;
        
//        List<Opportunity> lOppToTest3 = [SELECT Id, TopDepotGarantie__c FROM Opportunity WHERE Id = :lOpportunity.Id ];     
  //      System.assertEquals(true, lOppToTest3[0].TopDepotGarantie__c, 'La valeur du flag topDeGarantie = false au lieu de true');
               
        delete lGarantie;
        
        List<Opportunity> lOppToTest4 = [SELECT Id, TopDepotGarantie__c FROM Opportunity WHERE Id = :lOpportunity.Id ];     
        System.assertEquals(false, lOppToTest4[0].TopDepotGarantie__c, 'La valeur du flag topDeGarantie = true au lieu de false');
        
        Test.stopTest();
        /**
        delete lGarantie2;
        
        List<Opportunity> lOppToTest5 = [SELECT Id, TopDepotGarantie__c FROM Opportunity WHERE Id = :lOpportunity.Id ];     
        System.assertEquals(false, lOppToTest5[0].TopDepotGarantie__c, 'La valeur du flag topDeGarantie = true au lieu de false');
        
        Garantie__c lGarantie3 = new Garantie__c(RecordTypeId = lRecordTypeGarantie.Id, NomdelaProjetAssocie__c = lOpportunity.Id, Type__c = 'Bank deposit', TiersCautionSiExistant__c = lTiers.Id, Montant__c = 2000);
        insert lGarantie3;
        lGarantie3.Type__c = 'Dépôt de garantie';
        update lGarantie3;
        
        List<Opportunity> lOppToTest6 = [SELECT Id, TopDepotGarantie__c FROM Opportunity WHERE Id = :lOpportunity.Id ];     
        System.assertEquals(true, lOppToTest6[0].TopDepotGarantie__c, 'La valeur du flag topDeGarantie = false au lieu de true');

		*/
        
    }

    
    
}