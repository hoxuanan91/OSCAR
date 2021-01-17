@isTest
public class TEST_Ctrl09_ButtonAvenantFromDossier{
    
    @testSetup 
    static void testButton(){
        
        Opportunity lOpportunity;
        Account lTiers;
        Account lReseau;
        Projet__c lProjet;
        
        RecordType lRecordTypeOpp   = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIProjetAssocie' and SobjectType = 'Opportunity'];
        RecordType lRecordTypeTiers = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Tiers'  and SobjectType = 'Account'] ;
        RecordType lRecordTypeContact = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIReseau'  and SobjectType = 'Contact'] ;
        RecordType lRecordTypeRA = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIReseau'  and SobjectType = 'ReseauApporteur__c'] ;
        RecordType lRecordTypeGarantie = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIGarantieCBI' and SobjectType = 'Garantie__c'];
        
    
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
            CloseDate = Date.newInstance(2018,06,22),
            FraisDeDossier__c = 7975,
            QuotePartNL__c = 100,
            Chantier__c = true,
            DureDuChantierMois__c = 36,
            Avenant__c = false
        );
        insert lOpportunity;
     
        Contract lDossier = new Contract(AccountId = lTiers.Id, Nom_Client_preneur__c= lTiers.Id,ProjetAssocie__c = lOpportunity.Id, Status = 'Terminé - Terminé', StartDate = Date.newInstance(2999,06,22), DureeDuDossierMois__c = 12);
        insert lDossier;
        
        Contract lDossier02 = new Contract(AccountId = lTiers.Id, Nom_Client_preneur__c= lTiers.Id, ProjetAssocie__c = null, Status = 'Terminé - Terminé', StartDate = Date.newInstance(2999,06,23), DureeDuDossierMois__c = 12);
        insert lDossier02;
        
        
        Garantie__c lGarantie = new Garantie__c(RecordTypeId = lRecordTypeGarantie.Id, NomdelaProjetAssocie__c = lOpportunity.Id, Type__c = 'Dépôt de garantie', TiersCautionSiExistant__c = lTiers.Id, Montant__c = 2000, Dossier__c = lDossier.Id);
        insert lGarantie;
        
        Garantie__c lGarantie02 = new Garantie__c(RecordTypeId = lRecordTypeGarantie.Id, NomdelaProjetAssocie__c = lOpportunity.Id, Type__c = 'Dépôt de garantie', TiersCautionSiExistant__c = lTiers.Id, Montant__c = 2000, Dossier__c = lDossier02.Id);
        insert lGarantie02;
        
        Test.startTest();
         
        Autre_Tiers__c ClientPreneur = new Autre_Tiers__c(  Nom_du_Tiers__c = lTiers.Id,
            												Numero_du_dossier__c=lDossier.id,
            												Role__c = 'Client preneur');
        insert clientPreneur;
        
        Autre_Tiers__c tiersEnRisque = new Autre_Tiers__c(  Nom_du_Tiers__c = lTiers.Id,
            												Numero_du_dossier__c=lDossier.id,
            												Role__c = 'Tiers en risque profilé');
        insert tiersEnRisque;
        
        Autre_Tiers__c ClientPreneur02 = new Autre_Tiers__c(  Nom_du_Tiers__c = lTiers.Id,
            												Numero_du_dossier__c=lDossier02.id,
            												Role__c = 'Client preneur');
        insert clientPreneur02;
        
        Autre_Tiers__c tiersEnRisque02 = new Autre_Tiers__c(  Nom_du_Tiers__c = lTiers.Id,
            												Numero_du_dossier__c=lDossier02.id,
            												Role__c = 'Tiers en risque profilé');
        insert tiersEnRisque02;
            
        Detail_du_Pool__c detailDePool = new Detail_du_Pool__c(ProjetAssocie__c = lOpportunity.Id, Nom_du_Dossier__c = lDossier.Id, Quote_part__c = 0.20, TypeDePool__c = 'Suiveur visible');
		insert detailDePool;
        
        Detail_du_Pool__c detailDePool02 = new Detail_du_Pool__c(ProjetAssocie__c = lOpportunity.Id, Nom_du_Dossier__c = lDossier02.Id, Quote_part__c = 0.20, TypeDePool__c = 'Suiveur visible');
		insert detailDePool02;
        
        PoolDeGarants__c poolDeGarants = new PoolDeGarants__c(Partenaire__c = lTiers.Id, ProjetAssocie__c = lOpportunity.Id, QuotePart__c = 0.20, NomDuDossier__c = lDossier.Id);
        insert poolDeGarants;
        
        PoolDeGarants__c poolDeGarants02 = new PoolDeGarants__c(Partenaire__c = lTiers.Id, ProjetAssocie__c = lOpportunity.Id, QuotePart__c = 0.20, NomDuDossier__c = lDossier02.Id);
        insert poolDeGarants02;
        
        Test.stopTest();
        
    }
    
    static testmethod void testDossierToAvenantWithOpp(){
        
        Date StartDate = Date.newInstance(2999,06,22);
        
        Contract lDossier = [SELECT Id FROM Contract WHERE StartDate = :StartDate];
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('ID',lDossier.id);
        ApexPages.StandardController stdDossier = new ApexPages.StandardController(lDossier);
        Ctrl09_ButtonAvenantFromDossier dossierController = new Ctrl09_ButtonAvenantFromDossier(stdDossier);
        dossierController.addCloneRelatedListToNewAvenant();
        
        Test.stopTest();
        
    }
    
    static testmethod void testDossierToAvenantWithoutOpp(){
        
        Date StartDate = Date.newInstance(2999,06,23);
        
        Contract lDossier = [SELECT Id FROM Contract WHERE StartDate = :StartDate];
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('ID',lDossier.id);
        ApexPages.StandardController stdDossier = new ApexPages.StandardController(lDossier);
        Ctrl09_ButtonAvenantFromDossier dossierController = new Ctrl09_ButtonAvenantFromDossier(stdDossier);
        dossierController.addCloneRelatedListToNewAvenant();
        
        lDossier.Date_de_traitement_MEL__c = Date.newInstance(2999, 05, 22);
        
        update lDossier;
        
        delete lDossier;
        Test.stopTest();
        
    }

}