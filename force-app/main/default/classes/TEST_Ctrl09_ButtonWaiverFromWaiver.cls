@isTest
public class TEST_Ctrl09_ButtonWaiverFromWaiver{
       
    @testSetup 
    static void testButton(){
        User u = TestFactory.createUser();
        u.UserByPassWorkflows__c = true;
        u.UserByPassTriggers__c = 'OpportunityBeforeUpdate';

        System.runAs(u){
            Opportunity lOpportunity;
            Account lTiers;
            Account lReseau;
            Projet__c lProjet;
            
            RecordType lRecordTypeOpp   = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIProjetAssocie' and SobjectType = 'Opportunity'];
            RecordType lRecordTypeTiers = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Tiers'  and SobjectType = 'Account'] ;
            // FBH 
              RecordType lRecordTypeReseau = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIReseauBanqueCaisse'  and SobjectType = 'Account'] ;
            // fbh 
            RecordType lRecordTypeContact = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIReseau'  and SobjectType = 'Contact'] ;
            RecordType lRecordTypeRA = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIReseau'  and SobjectType = 'ReseauApporteur__c'] ;
            RecordType lRecordTypeGarantie = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIGarantieCBI' and SobjectType = 'Garantie__c'];
            RecordType lRecordTypeOppWaiver   = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIWaiver' and SobjectType = 'Opportunity'];
            Map<String,Id>mapBDD_RT=new Map<String,Id>();
            for(RecordType RT:[Select Id,DeveloperName from RecordType where SObjectType='BddRoe__c']){
                mapBDD_RT.put(RT.DeveloperName,RT.Id);
            }           
        
            lTiers = new Account(Name = 'Test', RecordTypeId = lRecordTypeTiers.Id);
            insert lTiers; 
            //FBH 
             lReseau = new Account(Name = 'Test', RecordTypeId = lRecordTypeReseau.Id, Reseau__c = 'Banque Populaire');
        	 insert lReseau; 
            //fin fbh 
            
            lProjet = new Projet__c(Name = 'Test', NomDuTiers__c = lTiers.Id);
            insert lProjet;
            
            
            
            // Opp parent
            Opportunity oppParent = new Opportunity(
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
                CloseDate = Date.newInstance(2999,06,21),
                FraisDeDossier__c = 7975,
                QuotePartNL__c = 100,
                Chantier__c = true,
                DureDuChantierMois__c = 36,
                Avenant__c = false
            );
            
            insert oppParent;
            
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
                Avenant__c = false,
                NomDuProjetAssocieParent__c = oppParent.Id
            );
            insert lOpportunity;
            
            /*Opportunity lOpportunity02 = new Opportunity(
                Name = 'A Supprimer',
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
                Avenant__c = false,
                NomDuProjetAssocieParent__c = oppParent.Id
            );
            
            insert lOpportunity02;
            delete lOpportunity02;*/
         
            Contract lDossier = new Contract(AccountId = lTiers.Id, ProjetAssocie__c = lOpportunity.Id, Status = 'Terminé - Terminé', StartDate = Date.newInstance(2999,06,22), DureeDuDossierMois__c = 12);
            insert lDossier;
            
            /*Contract lDossier02 = new Contract(AccountId = lTiers.Id, ProjetAssocie__c = null, Status = 'Terminé - Terminé', StartDate = Date.newInstance(2999,06,23), DureeDuDossierMois__c = 12);
            insert lDossier02;
            
            Garantie__c lGarantie = new Garantie__c(RecordTypeId = lRecordTypeGarantie.Id, NomdelaProjetAssocie__c = lOpportunity.Id, Type__c = 'Dépôt de garantie', TiersCautionSiExistant__c = lTiers.Id, Montant__c = 2000, Dossier__c = lDossier.Id);
            insert lGarantie;*/
            
            Garantie__c lGarantie02 = new Garantie__c(RecordTypeId = lRecordTypeGarantie.Id, NomdelaProjetAssocie__c = lOpportunity.Id, Type__c = 'Dépôt de garantie', TiersCautionSiExistant__c = lTiers.Id, Montant__c = 2000, Dossier__c = lDossier.Id);
            insert lGarantie02;
            
            Test.startTest();
            
            Autre_Tiers__c ClientPreneur = new Autre_Tiers__c(  Nom_du_Tiers__c = lTiers.Id,
                                                                Numero_du_dossier__c=lDossier.id,
                                                                Role__c = 'Client preneur');
            insert clientPreneur;
            
            /*Autre_Tiers__c tiersEnRisque = new Autre_Tiers__c(  Nom_du_Tiers__c = lTiers.Id,
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
            insert tiersEnRisque02;*/
            
            
            Detail_du_Pool__c detailDePool = new Detail_du_Pool__c(ProjetAssocie__c = lOpportunity.Id, Nom_du_Dossier__c = lDossier.Id, Quote_part__c = 0.20, TypeDePool__c = 'Suiveur visible');
            insert detailDePool;
            
            /*Detail_du_Pool__c detailDePool02 = new Detail_du_Pool__c(ProjetAssocie__c = lOpportunity.Id, Nom_du_Dossier__c = lDossier02.Id, Quote_part__c = 0.20, TypeDePool__c = 'Suiveur visible');
            insert detailDePool02; */
            
            // FBH Début reseau apporteur 
            // List<ReseauApporteur__c> reseaux = new List<ReseauApporteur__c>();
        
        ReseauApporteur__c reseau01 = new ReseauApporteur__c(      
            RESEAU__C = lReseau.Id,
            NOMDUPROJETASSOCIE__C = lOpportunity.Id,
            APPORTEURPRINCIPAL__C = true,
            NOMDUTIERS__C = lTiers.Id,
            DateEntreeEnRelation__c = Date.newInstance(2990, 5, 22),
            //ChargeDAffaire__c = lContact.Id, 
            RecordTypeId = lRecordTypeRA.Id
        );
        insert reseau01;
        /*ReseauApporteur__c reseau02 = new ReseauApporteur__c(      
            RESEAU__C = lReseau.Id,
            NOMDUPROJETASSOCIE__C = lOpportunity.Id,
            APPORTEURPRINCIPAL__C = false,
            NOMDUTIERS__C = lTiers.Id,
            DateEntreeEnRelation__c = Date.newInstance(2990, 5, 23),
           // ChargeDAffaire__c = lContact.Id, 
            RecordTypeId = lRecordTypeRA.Id   
        );
        insert reseau02;
        ReseauApporteur__c reseau03 = new ReseauApporteur__c(      
            RESEAU__C = lReseau.Id,
            NOMDUPROJETASSOCIE__C = lOpportunity.Id,
            APPORTEURPRINCIPAL__C = false,
            NOMDUTIERS__C = lTiers.Id  ,
            DateEntreeEnRelation__c = Date.newInstance(2990, 5, 24),
            //ChargeDAffaire__c = lContact.Id, 
            RecordTypeId = lRecordTypeRA.Id
        );
        
                
        insert reseau03;*/
            // FBH fin d'ajout reseau apporteur 
            PoolDeGarants__c poolDeGarants = new PoolDeGarants__c(Partenaire__c = lTiers.Id, ProjetAssocie__c = lOpportunity.Id, QuotePart__c = 0.20, NomDuDossier__c = lDossier.Id);
            insert poolDeGarants;
            
            /*PoolDeGarants__c poolDeGarants02 = new PoolDeGarants__c(Partenaire__c = lTiers.Id, ProjetAssocie__c = lOpportunity.Id, QuotePart__c = 0.20, NomDuDossier__c = lDossier02.Id);
            insert poolDeGarants02;
            
            PoolDeGarants__c poolDeGarants03 = new PoolDeGarants__c(Partenaire__c = lTiers.Id, ProjetAssocie__c = lOpportunity.Id, QuotePart__c = 0.20, NomDuDossier__c = lDossier02.Id);
            insert poolDeGarants03;
            
            delete poolDeGarants03;*/
            
            Test.stopTest();
        }
        
    }
    
    static testmethod void testDossierToAvenantWithOpp(){
        
        Date CloseDate = Date.newInstance(2999,06,22);
        
        Opportunity lopp = [SELECT Id FROM Opportunity WHERE CloseDate = :CloseDate];

        ApexPages.currentPage().getParameters().put('ID',lopp.id);
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(lopp);
        Ctrl09_ButtonWaiverFromWaiver oppController = new Ctrl09_ButtonWaiverFromWaiver(stdOpp);
        
        Test.startTest();
        
        oppController.addCloneRelatedListToNewWaiver();

        Test.stopTest();
        

    }
    
    static testMethod void testRedirect(){
         Date CloseDate = Date.newInstance(2999,06,22);
        Opportunity lopp = [SELECT Id FROM Opportunity WHERE CloseDate = :CloseDate];

        ApexPages.currentPage().getParameters().put('ID',lopp.id);
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(lopp);
        Ctrl09_ButtonWaiverFromWaiver oppController = new Ctrl09_ButtonWaiverFromWaiver(stdOpp);
        
        Test.startTest();
        
        oppController.isAlreadyAskingBySameUserInDay();
        oppController.Fermer();
        oppController.closePopup();
        oppController.validePopup();

        Test.stopTest();


    }

}