@isTest
public class TEST_DetailDuPool{

    @testSetup 
    static void MethodPrepare() {
        
        Opportunity lOpportunity;
        Account lTiers;
        Projet__c lProjet;
        
        RecordType lRecordTypeOpp   = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIProjetAssocie' and SobjectType = 'Opportunity'];
        RecordType lRecordTypeTiers = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Tiers'  and SobjectType = 'Account'] ;     
    
        lTiers = new Account(Name = 'Test', RecordTypeId = lRecordTypeTiers.Id);
        insert lTiers;  
        
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
            CloseDate = Date.newInstance(2999,06,22),
            FraisDeDossier__c = 7975,
            QuotePartNL__c = 100,
            Chantier__c = true,
            DureDuChantierMois__c = 36,
            Avenant__c = false
        );
        insert lOpportunity;
        
        Contract lDossier = new Contract(AccountId = lTiers.Id, ProjetAssocie__c = lOpportunity.Id, Status = 'Terminé - Terminé', StartDate = Date.newInstance(2999,06,22), DureeDuDossierMois__c = 12);
        insert lDossier;
        
    }
    
    static testmethod void testInsertUpdateDeleteCDFReporting(){
        
        Test.startTest();
        
        Date StartDate = Date.newInstance(2999,06,22);
        
        Opportunity lOpportunity = [SELECT Id FROM Opportunity WHERE Amount = 3950000 LIMIT 1];
        Contract lDossier = [SELECT Id FROM Contract WHERE StartDate = :StartDate];
        Account lAccount = [SELECT Id, Name FROM Account WHERE Name = 'Test'];
        
        Detail_du_Pool__c detailDePool = new Detail_du_Pool__c(ProjetAssocie__c = lOpportunity.Id, Nom_du_Dossier__c = lDossier.Id, Quote_part__c = 0.20, Chef_De_File__c = true, Partenaire__c = lAccount.Id);
        insert detailDePool;
        
        // On reselectionne le PASS pour vérifier que les données ont été mises à jour
        Opportunity lOpportunityAfterUpdate = [SELECT Id, NomDuChefDeFileRCBI__c FROM Opportunity WHERE Amount = 3950000 LIMIT 1];
        
        system.assertEquals('Test', lOpportunityAfterUpdate.NomDuChefDeFileRCBI__c);
        
        delete detailDePool;
        
        // On reselectionne le PASS pour vérifier que les données ont été mises à jour
        Opportunity lOpportunityAfterDelete = [SELECT Id, NomDuChefDeFileRCBI__c FROM Opportunity WHERE Amount = 3950000 LIMIT 1];
        
        system.assertEquals(null, lOpportunityAfterDelete.NomDuChefDeFileRCBI__c);
            
        Test.stopTest();
        
    }

}