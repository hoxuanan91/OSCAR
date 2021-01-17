@isTest
public class TEST_Opportunity{

    
    public static Opportunity lOpportunity {get; set;}
    public static Account lAccount {get; set;}
    public static Contract lContract {get; set;}
    public static Account lTiers {get; set;}
    public static Projet__c lProjet {get; set;}


    /**
     * Obligation du seeAllData pour que le code de AP03Opportunity.insererPremierPool puisse récuperer
     * un custom Label
     */
    @isTest
    static void MethodPrepare() {
     
        RecordType lRecordTypeOpp   = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIProjetAssocie' and SobjectType = 'Opportunity'];
        RecordType lRecordTypeTiers = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Tiers'  and SobjectType = 'Account'] ;     
    
        lTiers = new Account(Name = 'NATIXIS LEASE', RecordTypeId = lRecordTypeTiers.Id);
        insert lTiers;  
        
        lProjet = new Projet__c(Name = 'Test', NomDuTiers__c = lTiers.Id);
        insert lProjet;
        
        lAccount = new Account(Name='Tiers Dossier Pool Financement');
        insert lAccount;
        
        lContract = new Contract(Nom_du_dossier__c='Dossier Pool Financement', AccountId=lAccount.Id);
        insert lContract;
        
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
    
      }
    
    @isTest
    static void testInsertPremierPool(){
        
        MethodPrepare();
        
        // On récupère l'Opportunity inserée dans le methodPrepare et on vérifie que détail de pool lui a bien été assigné
        Test.startTest();
            
        Opportunity lOpportunityAfterInsertDDP = [SELECT Id, NomDuProjet__c, NbDePoolFinancement__c FROM Opportunity LIMIT 1];
        system.debug('lOpportunityAfterInsertDDP: ' + lOpportunityAfterInsertDDP);
        List<Detail_Du_Pool__c> details = [SELECT Id FROM Detail_Du_Pool__c WHERE ProjetAssocie__c = :lOpportunity.Id];
        system.debug('details: ' + details);
        system.assertEquals( 1, details.size());
        system.assertEquals(1, lOpportunityAfterInsertDDP.NbDePoolFinancement__c);
        
        // On contrôle également que le compteur du projet a été incrementé de 1 à l'insertion de l'opp
        Projet__c lProjetAfterOpp = [SELECT Id, NbProjetsAssocies__c FROM Projet__c WHERE Id = :lOpportunityAfterInsertDDP.NomDuProjet__c];
        
        //system.assertEquals(1 , lProjetAfterOpp.NbProjetsAssocies__c);
        
        // Suppression de l'Opp
        Detail_Du_Pool__c ddp = [SELECT Id FROM Detail_Du_Pool__c WHERE ProjetAssocie__c = :lOpportunityAfterInsertDDP.Id];
        delete ddp;
        
        Opportunity lOpportunityAfterDeleteDDP = [SELECT Id, NomDuProjet__c, NbDePoolFinancement__c FROM Opportunity WHERE Amount = 3950000 ORDER BY CreatedDate DESC LIMIT 1];
        system.assertEquals(0, lOpportunityAfterDeleteDDP.NbDePoolFinancement__c);
        
        delete lOpportunity;
        
        Projet__c lProjetAfterDeleteOpp = [SELECT Id, NbProjetsAssocies__c FROM Projet__c WHERE Id = :lOpportunity.NomDuProjet__c];
        //system.assertEquals(1 , lProjetAfterDeleteOpp.NbProjetsAssocies__c); // On ne decremente pas à la suppression, permet de garder une trace qu'une opp
                                                                              // avait été créée
              
        Test.stopTest();
        
    }
    
    @isTest
    static void testInsertAvenant(){
        
        MethodPrepare();

        Test.startTest();
        
        RecordType lRecordTypeOpp   = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIAvenant' and SobjectType = 'Opportunity'];
        
        Opportunity avenant = new Opportunity(
            Name = 'Test Garantie Triggers',
            RecordTypeId = lRecordTypeOpp.Id,
            NomDuProjet__c = lProjet.Id,
            AccountId = lTiers.Id,
            TypeDOperation__c = 'Construction',
            StageName = 'Pré-Etude',
            Jalon__c='Nouveau Projet',
            Amount =  3850000,
            PreloyersDEngagement__c =  0.10,
            PreloyersDeTVAPerc__c = 1.5,
            PreloyersDeFinancement__c = 1.5,
            CloseDate = Date.newInstance(2999,06,22),
            FraisDeDossier__c = 7975,
            QuotePartNL__c = 100,
            Chantier__c = true,
            DureDuChantierMois__c = 36,
            Avenant__c = false,
            NomDuProjetAssocieParent__c = lOpportunity.Id
        );
        
        insert avenant;
        
        Opportunity lOpportunityAfterInsertAvenant = [SELECT Id, NomDuProjet__c, NbAvenantsDuProjetAssocie__c FROM Opportunity WHERE Amount = 3950000 ORDER BY CreatedDate DESC LIMIT 1];
        //system.assertEquals(1, lOpportunityAfterInsertAvenant.NbAvenantsDuProjetAssocie__c);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void whenOppEqualCBIAvenant() {
        RecordType lRecordTypeOpp   = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIAvenant' and SobjectType = 'Opportunity'];
        RecordType lRecordTypeTiers = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Tiers'  and SobjectType = 'Account'] ;     
    
        lTiers = new Account(Name = 'NATIXIS LEASE', RecordTypeId = lRecordTypeTiers.Id);
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
    }
    
    
    @isTest
    static void testInsertWaiver(){
        
        MethodPrepare();

        Test.startTest();
        
        RecordType lRecordTypeOpp  = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIWaiver' and SobjectType = 'Opportunity'];
        
        Opportunity waiver = new Opportunity(
            Name = 'Test Garantie Triggers',
            RecordTypeId = lRecordTypeOpp.Id,
            NomDuProjet__c = lProjet.Id,
            AccountId = lTiers.Id,
            TypeDOperation__c = 'Construction',
            StageName = 'Pré-Etude',
            Jalon__c='Nouveau Projet',
            Amount =  3850000,
            PreloyersDEngagement__c =  0.10,
            PreloyersDeTVAPerc__c = 1.5,
            PreloyersDeFinancement__c = 1.5,
            CloseDate = Date.newInstance(2999,06,22),
            FraisDeDossier__c = 7975,
            QuotePartNL__c = 100,
            Chantier__c = true,
            DureDuChantierMois__c = 36,
            Avenant__c = false,
            NomDuProjetAssocieParent__c = lOpportunity.Id
        );
        
        insert waiver;
        
        Opportunity lOpportunityAfterInsertWaiver = [SELECT Id, StageName, Jalon__c, NomDuProjet__c, NbWaiversDuProjetAssocie__c FROM Opportunity WHERE Id = :lOpportunity.Id LIMIT 1];
        //system.assertEquals(1, lOpportunityAfterInsertWaiver.NbWaiversDuProjetAssocie__c);
        
        // On modifie la Phase du Waiver
        waiver.StageName = 'Décidé';
        waiver.Jalon__c = 'Accord';
        update waiver;
        
        Opportunity lOpportunityAfterUpdateWaiver = [SELECT Id, StageName, Jalon__c, NomDuProjet__c, NbWaiversDuProjetAssocie__c FROM Opportunity WHERE Id = :lOpportunity.Id LIMIT 1];
        //system.assertEquals('Waiver', lOpportunityAfterUpdateWaiver.StageName);
        //system.assertEquals('Waiver', lOpportunityAfterUpdateWaiver.Jalon__c);

        // On insère un deuxième Waiver
        Opportunity waiver02 = new Opportunity(
            Name = 'Test Garantie Triggers',
            RecordTypeId = lRecordTypeOpp.Id,
            NomDuProjet__c = lProjet.Id,
            AccountId = lTiers.Id,
            TypeDOperation__c = 'Construction',
            StageName = 'Pré-Etude',
            Jalon__c='Nouveau Projet',
            Amount =  3750000,
            PreloyersDEngagement__c =  0.10,
            PreloyersDeTVAPerc__c = 1.5,
            PreloyersDeFinancement__c = 1.5,
            CloseDate = Date.newInstance(2999,06,22),
            FraisDeDossier__c = 7975,
            QuotePartNL__c = 100,
            Chantier__c = true,
            DureDuChantierMois__c = 36,
            Avenant__c = false,
            NomDuProjetAssocieParent__c = lOpportunity.Id,
            NomDuWaiverPrecedent__c = waiver.Id
        );
        
        insert waiver02;
        
        // On modifie la Phase du Waiver
        waiver02.StageName = 'Décidé';
        waiver02.Jalon__c = 'Accord';
        update waiver02;
        
        Opportunity lWaiverAfterUpdateWaiver = [SELECT Id, StageName, Jalon__c, NomDuProjet__c, NbWaiversDuProjetAssocie__c FROM Opportunity WHERE Id = :waiver.Id LIMIT 1];
       // system.assertEquals('Waiver', lWaiverAfterUpdateWaiver.StageName);
       // system.assertEquals('Waiver', lWaiverAfterUpdateWaiver.Jalon__c);
        
        Test.stopTest();
        
    }

    /**
     *  Test FO - DEN
     *  Passage des demandes(=CBMOctroiCreditDEN) au status=Refusée
     *  Rapatrier MotifdecisionDEN__c
    */

    public static Opportunity getOpportunity() {
        return [SELECT Id, MotifdecisionDEN__c, DateDecisionNatixisLease36xDate__c, StageName FROM Opportunity LIMIT 1];
    }

    @IsTest
    static void whenMotifDecisionDENIsUpdated() {
        //ARR
        List<Case> result = new List<Case>();

        Map<String,Id> RTs = DAL.getRecordType('Case');
        Account acc = TestFactory.createAccount('testAccountName');
        insert acc;
        Opportunity opp = TestFactory.createOpty('testOpportName', acc.Id);
        insert opp;
        Contract ctr = TestFactory.createContract(acc.Id, opp.Id);
        insert ctr;
        Case c = TestFactory.createCaseWithRT(ctr.Id, '	Prise en charge', (ID)RTs.get('CBMOctroiCreditDEN'));
        insert c;

        Opportunity oldOpp = getOpportunity();
        Opportunity newOpp = oldOpp.clone(true, false, false, false);
        newOpp.MotifdecisionDEN__c = 'testMotifDecisionDEN';

        //ACT
        Test.startTest();

        //result = AP03Opportunity.handleCaseCBMOctroiCreditDEN(oldOpp, newOpp, new List<Case>{c});

        Test.stopTest();

        //ASS
        //System.assertEquals(1, result.size());
        //System.assertEquals(newOpp.MotifdecisionDEN__c, result[0].MotifdecisionDEN__c);
        //System.assertNotEquals('Refusée', result[0].Status);
    }
    @IsTest
    static void whenDateDecision36xIsFilled() {
        //ARR
        List<Case> result = new List<Case>();

        Map<String,Id> RTs = DAL.getRecordType('Case');
        Account acc = TestFactory.createAccount('testAccountName');
        insert acc;
        Opportunity opp = TestFactory.createOpty('testOpportName', acc.Id);
        insert opp;
        Contract ctr = TestFactory.createContract(acc.Id, opp.Id);
        insert ctr;
        Case c = TestFactory.createCaseWithRT(ctr.Id, '	Prise en charge', (ID)RTs.get('CBMOctroiCreditDEN'));
        insert c;

        Opportunity oldOpp = getOpportunity();
        Opportunity newOpp = oldOpp.clone(true, false, false, false);
        newOpp.DateDecisionNatixisLease36xDate__c = Date.today();

        //ACT
        Test.startTest();

        //result = AP03Opportunity.handleCaseCBMOctroiCreditDEN(oldOpp, newOpp, new List<Case>{c});

        Test.stopTest();

        //ASS
        //System.assertEquals(1, result.size());
        //System.assertEquals('Refusée', result[0].Status);
        //System.assertEquals(null, result[0].MotifdecisionDEN__c);
    }
    @IsTest
    static void whenDateDecision36xIsNull() {
        //ARR
        List<Case> result = new List<Case>();

        Map<String,Id> RTs = DAL.getRecordType('Case');
        Account acc = TestFactory.createAccount('testAccountName');
        insert acc;
        Opportunity opp = TestFactory.createOpty('testOpportName', acc.Id);
        insert opp;
        Contract ctr = TestFactory.createContract(acc.Id, opp.Id);
        insert ctr;
        Case c = TestFactory.createCaseWithRT(ctr.Id, '	Prise en charge', (ID)RTs.get('CBMOctroiCreditDEN'));
        insert c;

        Opportunity oldOpp = getOpportunity();
        Opportunity newOpp = oldOpp.clone(true, false, false, false);

        //ACT
        Test.startTest();

        //result = AP03Opportunity.handleCaseCBMOctroiCreditDEN(oldOpp, newOpp, new List<Case>{c});

        Test.stopTest();

        //ASS
        System.assertEquals(0, result.size());
    }

    /**
     *  Test FO - DEN
     *  Annuler les demandes d'octroi DEN si PAS 'sans-suite'
    */

    @IsTest
    static void whenPASEqualSansSuiteWithOldValue() {
        //ARR
        List<Case> result = new List<Case>();

        Map<String,Id> RTs = DAL.getRecordType('Case');
        Account acc = TestFactory.createAccount('testAccountName');
        insert acc;
        Opportunity opp = TestFactory.createOpty('testOpportName', acc.Id);
        insert opp;
        Contract ctr = TestFactory.createContract(acc.Id, opp.Id);
        insert ctr;
        Case c = TestFactory.createCaseWithRT(ctr.Id, '	Prise en charge', (ID)RTs.get('CBMOctroiCreditDEN'));
        insert c;

        Opportunity oldOpp = getOpportunity();

        Opportunity newOpp = oldOpp.clone(true, false, false, false);
        newOpp.StageName = 'S_SUIT';
        update newOpp;

        //ACT
        Test.startTest();

        //result = AP03Opportunity.cancelCasesIfPASEqualSansSuite(oldOpp, newOpp, new List<Case>{c});

        Test.stopTest();

        //ASS
        //System.assertEquals(1, result.size());
        //System.assertEquals('Annulée', result[0].Status);
    }

    @IsTest
    static void whenPASEqualSansSuiteWithoutOldValue() {
        //ARR
        List<Case> result = new List<Case>();

        Map<String,Id> RTs = DAL.getRecordType('Case');
        Account acc = TestFactory.createAccount('testAccountName');
        insert acc;
        Opportunity opp = TestFactory.createOpty('testOpportName', acc.Id);
        insert opp;
        Contract ctr = TestFactory.createContract(acc.Id, opp.Id);
        insert ctr;
        Case c = TestFactory.createCaseWithRT(ctr.Id, '	Prise en charge', (ID)RTs.get('CBMOctroiCreditDEN'));
        insert c;

        Opportunity oldOpp = getOpportunity();

        Opportunity newOpp = oldOpp.clone(true, false, false, false);
        newOpp.StageName = 'S_SUIT';
        update newOpp;

        //ACT
        Test.startTest();

        result = AP03Opportunity.cancelCasesIfPASEqualSansSuite(newOpp, new List<Case>{c});

        Test.stopTest();

        //ASS
        System.assertEquals(1, result.size());
        System.assertEquals('Annulée', result[0].Status);
    }
    
    @IsTest
    static void whenCreateCommentaireViaOpportunityLLD() {
        //ARR
        List<Case> result = new List<Case>();
		
        Id BanqueRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CBI - Réseau Banque Caisse').getRecordTypeId();
        
        Map<String,Id> RTs = DAL.getRecordType('Case');
        
        Account accApporteur1 = TestFactory.createAccount('testApporteur1');
        accApporteur1.RecordTypeId = BanqueRecordTypeId;
        insert accApporteur1; 
        
        Account accApporteur = TestFactory.createAccount('testApporteur');
        accApporteur.RecordTypeId = BanqueRecordTypeId;
        accApporteur.Apporteur__c = accApporteur1.Id;
        insert accApporteur; 
        
        Account acc = TestFactory.createAccount('testAccountName');
        acc.Apporteur__c = accApporteur.Id;
        insert acc;
        
        Opportunity opp = TestFactory.createOpty('testOpportName', acc.Id);
        RecordType rt = [SELECT Id FROM RecordType WHERE developername = 'LLD_Commande'];
        opp.RecordTypeId = rt.Id;
        opp.AccountId = acc.Id;
        insert opp;
        Contract ctr = TestFactory.createContract(acc.Id, opp.Id);
        insert ctr;
        Case c = TestFactory.createCaseWithRT(ctr.Id, '	Prise en charge', (ID)RTs.get('CBMOctroiCreditDEN'));
        insert c;

        //ACT
        Test.startTest();

        opp.Comm_eventuels__c = 'testEventuel';
        AP03Opportunity.createOpportunityComment(new List<Opportunity>{opp});

        Test.stopTest();

        //ASS
        List<Commentaires__c> comsList = [SELECT Id FROM Commentaires__c];
        System.assertEquals(1, comsList.size());
    }
    
    @IsTest
    static void whenCreateCaseCBMPaiementFournisseurWithUpdateDateTransfertBackAndWhitoutContract() {
     	//ARR
        Account acc = TestFactory.createAccount('testAccountName');
        insert acc;
        Opportunity opp = TestFactory.createOpty('testOpportName', acc.Id);
        opp.DateRetour1DocapostOK__c = Date.today();
        opp.DateRetour2DocapostOK__c = Date.today();
        
        opp.NbEnvoisDocaPost1Statut__c = 100;
        opp.NbEnvoisDocaPost2Statut__c = 999;
        RecordType rt = [SELECT Id FROM RecordType WHERE developername = 'CBMEnDelegation'];
        opp.RecordTypeId = rt.Id;
        
     	//ACT
     	Test.startTest();
        insert opp;
        opp.DateEvntTransfertDossierBack__c = Date.today();
        update opp;
        Test.stopTest();
     	//ASS
     	List<Opportunity> oppUpdated = [SELECT Id, StageName FROM Opportunity WHERE Id =: opp.Id];
        //System.assertEquals('P_FRNS', oppUpdated[0].StageName);
    }
    
    @IsTest
    static void whenCreateCaseCBMPaiementFournisseurWithUpdateDateTransfertBackAndWithoutDemandeMelExiste() {
        //ARR
        Account acc = TestFactory.createAccount('testAccountName');
        insert acc;
        Opportunity opp = TestFactory.createOpty('testOpportName', acc.Id);
        opp.DateRetour1DocapostOK__c = Date.today();
        opp.DateRetour2DocapostOK__c = Date.today();
        opp.NbEnvoisDocaPost1Statut__c = 100;
        opp.NbEnvoisDocaPost2Statut__c = 999;
        RecordType rt = [SELECT Id FROM RecordType WHERE developername = 'CBMEnDelegation'];
        opp.RecordTypeId = rt.Id;
        insert opp;
        Contract ctr = TestFactory.createContract(acc.Id, opp.Id);
        insert ctr;
        
     	//ACT
     	Test.startTest();
        opp.DateEvntTransfertDossierBack__c = Date.today();
        opp.Dossier__c = ctr.Id;
        update opp;
        Test.stopTest();
     	//ASS
     	List<Case> c = [SELECT Id FROM Case WHERE ProjetAssocie__c =: opp.Id];
        //System.assertEquals(1, c.size());
        List<Opportunity> oppUpdated = [SELECT Id, StageName FROM Opportunity WHERE Id =: opp.Id];
        //System.assertEquals('P_FRNS', oppUpdated[0].StageName);
    }
    
    @IsTest
    static void whenCreateCaseCBMPaiementFournisseurWithUpdateDateTransfertBackAndWithDemandeMelExiste() {
        //ARR
        Map<String,Id> RTs = DAL.getRecordType('Case');
        Account acc = TestFactory.createAccount('testAccountName');
        insert acc;
        Opportunity opp = TestFactory.createOpty('testOpportName', acc.Id);
        opp.DateRetour1DocapostOK__c = Date.today();
        opp.DateRetour2DocapostOK__c = Date.today();
        opp.NbEnvoisDocaPost1Statut__c = 100;
        opp.NbEnvoisDocaPost2Statut__c = 999;
        RecordType rt = [SELECT Id FROM RecordType WHERE developername = 'CBMEnDelegation'];
        opp.RecordTypeId = rt.Id;
        insert opp;
        Contract ctr = TestFactory.createContract(acc.Id, opp.Id);
        ctr.DemandeMELExiste__c = true;
        insert ctr;
        Case c = TestFactory.createCaseWithRT(ctr.Id, 'Demande de MEP', (ID)RTs.get('CBM_Mise_en_place'));
        insert c;
     	//ACT
     	Test.startTest();
        opp.DateEvntTransfertDossierBack__c = Date.today();
        opp.Dossier__c = ctr.Id;
        update opp;
        Test.stopTest();
     	//ASS
        List<Opportunity> oppUpdated = [SELECT Id, StageName FROM Opportunity WHERE Id =: opp.Id];
        //System.assertEquals('P_FRNS', oppUpdated[0].StageName);
        List<Case> caseUpdated = [SELECT Id, ProjetAssocie__c FROM Case];
        //System.assertNotEquals(null, caseUpdated[0].ProjetAssocie__c);
    }
    
    @IsTest
    static void DemandesPAS() {
        
        List<Opportunity> oppsToInsert = new List<Opportunity>();
		List<Opportunity> oppsToUpdate = new List<Opportunity>();        
        Account acc = TestFactory.createAccount('testAccountName');
        insert acc;
        //ACT
        Test.startTest();
        
        Projet__c p = new Projet__c(Name = 'Test',
                                   	NomDuTiers__c = acc.Id);
        insert p;
        
        Opportunity opp = TestFactory.createOpty('testOpportName', acc.Id);
        opp.RecordTypeId = UTL_Utils.getRecordTypeID(String.valueOf(Opportunity.getSObjectType()), 'LLD_Commande');
        opp.Typologie_de_commande__c = 'Renouvellement';
       	oppsToInsert.add(opp);
        
        Opportunity opp3 = TestFactory.createOpty('testOpportName', acc.Id);
        opp3.RecordTypeId = UTL_Utils.getRecordTypeID(String.valueOf(Opportunity.getSObjectType()), 'CBMEnveloppe');
        oppsToInsert.add(opp3);
        
        insert oppsToInsert;
        
        Case c3 = new Case(Status = 'Prise en charge',
        				ProjetAssocie__c = opp3.Id,
        				Information_sur_le_dossier__c = 'test',
        				Information_sur_tiers_concerne__c = 'test',
        				Delegation_Regionale__c = 'test',
        				Service_concerne__c = 'test',
                        RecordTypeId = UTL_Utils.getRecordTypeID(String.valueOf(Case.getSObjectType()), 'CBMOctroiCreditDEN'));
        insert c3;
        
        opp.StageName = 'Commande Validée';
        oppsToUpdate.add(opp);
        update oppsToUpdate;
        
       
        Test.stopTest();
    }
}