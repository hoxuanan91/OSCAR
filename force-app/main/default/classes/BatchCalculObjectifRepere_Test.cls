@isTest
public class BatchCalculObjectifRepere_Test {
    
    @testSetup static void setup(){
        /*Creation projet associe*/         
     
        Id idRecordTypeCBMEnDelegation= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CBMEnDelegation').getRecordTypeId();
        Id idRecordTypeTiers= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Tiers').getRecordTypeId();
        Id idRecordTypeCaseMEP = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CBM_Mise_en_place').getRecordTypeId();
        
        Account lTiers = new Account(Name = 'NATIXIS LEASE', RecordTypeId = idRecordTypeTiers);
        insert lTiers;  
        
        Projet__c lProjet = new Projet__c(Name = 'Test', NomDuTiers__c = lTiers.Id);
        insert lProjet;
        
        Account lAccount = new Account(Name='Tiers Dossier Pool Financement');
        lAccount.SegmentationCommerciale__c='11';
        insert lAccount;
        
        Contract lDossier = new Contract();
        lDossier.AccountId = lAccount.Id;
        lDossier.MontantDuFinancementQPNL__c=500;
        insert lDossier;
        
        
        User u= TestFactory.createUser();
        u.CodesDelegationsRegionalesGeres__c='DR48;DR49';
        u.CodeDelegationRegionale__c='DR48';
        u.firstName='David';
        u.lastName='Dupont';
        insert u;
        
        Opportunity lOpportunity = new Opportunity(
            Name = 'testOppty',
            ownerId=u.Id,
            Dossier__c=lDossier.Id,
            RecordTypeId = idRecordTypeCBMEnDelegation,
            NomDuProjet__c = lProjet.Id,
            AccountId = lAccount.Id,
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
            Intervenant_decision_422__c=UserInfo.getUserId(),
            Intervenant_decision_423__c=UserInfo.getUserId(),
            Intervenant_decision_460__c=UserInfo.getUserId(),
            Intervenant_traitement_Derogation__c=UserInfo.getUserId(),
            DateMiseEnLoyerCassiopaeBack__c=DateTime.newInstance(2019, 12, 20),
            DateFinDerogationV4__c=DateTime.newInstance(2019, 12, 20),
            DateV4_850_Dero_Materiel_Occasion__c=null,
            Delai_derogation__c=2,
            OrigineDuDossier__c='2');
        insert lOpportunity;
        
        /* creation d'objectif réalisé */
        Id idRecordTypeIndividuel = Schema.SObjectType.ObjectifRealise__c.getRecordTypeInfosByDeveloperName().get('Individuel').getRecordTypeId();
        ObjectifRealise__c initObjectifReal=new ObjectifRealise__c();
        initObjectifReal.Collaborateur__c=UserInfo.getUserId();
        initObjectifReal.recordTypeId=idRecordTypeIndividuel;
        initObjectifReal.mois__c=12;
        initObjectifReal.annee__c=2019;
        insert initObjectifReal;
        system.debug('@@ initObjectifReal ' +initObjectifReal.Id);	
        
        /*creation case*/
        Map<String,Id> RTs = DAL.getRecordType('Case');
        Account acc = TestFactory.createAccount('testAcc');
        insert acc;
        
        Contract ctr = TestFactory.createContract(acc.Id);
        insert ctr;
        List<Case> initCases=new List<Case>();
        Case c = TestFactory.createCaseWithRT(ctr.Id, 'Prise en charge', (ID)RTs.get('CBM_Mise_en_place'));
        c.ProjetAssocie__c=lOpportunity.Id;
        c.ownerId=UserInfo.getUserId();
        c.Delai_PVFact_Crea__c=2;
        c.DelaiMiseLoyer__c=2;
        c.Date_de_traitement_de_la_MEL__c=Date.newInstance(2019, 12, 20);
        c.UniteSRC__c='3';
        initCases.add(c);
        
        Case caseCT = TestFactory.createCaseWithRT(ctr.Id, 'Prise en charge', (ID)RTs.get('CBM_SAV'));
        caseCT.ProjetAssocie__c=lOpportunity.Id;
        caseCT.ownerId=UserInfo.getUserId();
        caseCT.status='Terminée';
        caseCT.UniteSRC__c='3';
        caseCT.Delai_PEC_Terminee__c=2;
        initCases.add(caseCT);
        
        Case caseMT = TestFactory.createCaseWithRT(ctr.Id, 'Prise en charge', (ID)RTs.get('CBM_Rachat_anticipe'));
        caseMT.ProjetAssocie__c=lOpportunity.Id;
        caseMT.ownerId=UserInfo.getUserId();
        caseMT.status='Terminée'; 
        caseMT.UniteSRC__c='3';
        caseMT.Delai_PEC_Terminee__c=9;
        initCases.add(caseMT);
        
        
        Case caseLT = TestFactory.createCaseWithRT(ctr.Id, 'Prise en charge', (ID)RTs.get('CBM_Rachat_anticipe'));
        caseLT.ProjetAssocie__c=lOpportunity.Id;
        caseLT.ownerId=UserInfo.getUserId();
        caseLT.status='Terminée';
        caseLT.UniteSRC__c='3';
        caseLT.Delai_PEC_Terminee__c=50;
        caseLT.StatutApprobation__c='2';
        caseLT.Rejet_historique__c=true;
        initCases.add(caseLT);
        
        Case caseValideur = TestFactory.createCaseWithRT(ctr.Id, 'Prise en charge', idRecordTypeCaseMEP);
        caseValideur.ProjetAssocie__c=lOpportunity.Id;
        caseValideur.ownerId=UserInfo.getUserId();
        caseValideur.status='Terminée';
        caseValideur.UniteSRC__c='3';
        caseValideur.Delai_approbation__c=2;
        caseValideur.Delai_approbation_respecte__c=true;
        caseValideur.StatutApprobation__c='2';
        caseValideur.ComplexiteForcee__c='1 - Simple';
        caseValideur.Date_de_traitement_de_la_MEL__c=Date.newInstance(2019, 12, 20);
        caseValideur.DecideurFinal__c='David Dupont';
        initCases.add(caseValideur);
        insert initCases;
       /* List<Case> insertedCases=[select id , ownerId, owner.type, Complexite_SAV__c,closedDate, isClosed from case ];
        system.debug('@@ insertedCases '+insertedCases);
        
        */
        
        Id idRecordTypeRDV = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('CBMEvenement').getRecordTypeId();
        Event rdv = new Event();
        rdv.type='Animation Réseau-Formation';
        rdv.ownerId=UserInfo.getUserId();
        rdv.RecordTypeId=idRecordTypeRDV;
        rdv.StartDateTime=Datetime.newInstance(2019, 12, 20,10,0,0);
        rdv.EndDateTime=Datetime.newInstance(2019, 12, 20,11,0,0);
        rdv.TypeRdv__c='1';
        insert rdv;
    }
    
    public static testMethod void testCalculObjectifRepereFront(){
        Test.startTest();
        Database.executeBatch(new BatchCalculObjectifRepereFront(12,2019)); 
        Test.stopTest();
        List<ObjectifRealise__c> updatedOR=[select id from ObjectifRealise__c where Obj_ASS_QT1__c!=null OR Obj_ASS_QT2__c!=null ];
        system.assert(updatedOR.size()>0);     
    }
    
    public static testMethod void testScheduleBatchCalculObjectifRepereFront(){
        Test.startTest();
        String sch = '0 30  * 1/1 * ? *';
        system.schedule('CalculRepereFront', sch, new ScheduleBatchCalculObjectifRepereFront());
        Test.stopTest();
    }
    
    public static testMethod void testerBatchCalculObjectifRepereEvent(){
        Test.startTest();
        Database.executeBatch(new BatchCalculObjectifRepereEvent(12,2019)); 
        Test.stopTest();
        List<ObjectifRealise__c> updatedOR=[select id from ObjectifRealise__c where Obj_ASSRC_QT2__c!=null ];
        system.assert(updatedOR.size()>0);     
    }   
    
    
    public static testMethod void testerSchedulerBatchEvent(){
        Test.startTest();
        String sch = '0 30  * 1/1 * ? *';
        system.schedule('calculNbRDVReseau', sch, new ScheduleBatchCalculObjectifRepereEvent());
        Test.stopTest();
        
    }
    public static testMethod void testerSchedulerBatchObjectifBack(){
        Test.startTest();
        String sch = '0 30  * 1/1 * ? *';
        system.schedule('calculObjectifBack', sch, new ScheduleBatchCalculObjectifRepereMEL());
        Test.stopTest();
        
    }
    public static testMethod void testerBatchObjectifBack(){
        Test.startTest();
        Database.executeBatch(new BatchCalculObjectifRepereMEL(12,2019),2000);
        Test.stopTest();
        List<ObjectifRealise__c> updatedORBack=[select id from ObjectifRealise__c where Obj_MEL_QT1__c!=null ];
        system.assert(updatedORBack.size()>0);     
    }
    public static testMethod void testerBatchObjectifCaseBack(){
        Test.startTest();
        Database.executeBatch(new BatchCalculObjectifRepereSAV(system.today().month(),system.today().year()),2000);
        Test.stopTest();
        List<ObjectifRealise__c> updatedORBack=[select id from ObjectifRealise__c where Obj_SAV_QT1__c!=null ];
        system.assert(updatedORBack.size()>0);    
        
    }
    
}