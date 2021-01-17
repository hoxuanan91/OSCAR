@isTest
public class AP26_CalculDelai_Test {
  
    public static testMethod void testCalculDerogation(){
        Opportunity oppty=createOppty('OppDerogation');
        oppty.DateDerogationV4__c=DateTime.newInstance(2020, 1, 2, 9, 0, 0);  
        oppty.DateFinDerogationV4__c=DateTime.newInstance(2020, 1, 3, 10, 0, 0);  
        insert oppty;
        List<Id> Oppties=new List<Id>{oppty.id};
        AP26_CalculDelai.calculDelaiProjetAssocie(Oppties);
        
        Opportunity updatedOppty=[select id,DateDerogationV4__c,DateFinDerogationV4__c,Delai_derogation__c from Opportunity where name='OppDerogation' ];
        system.debug('@@ updatedOppty.DateDerogationV4__c '+updatedOppty.DateDerogationV4__c);
        system.debug('@@ updatedOppty.DateFinDerogationV4__c '+updatedOppty.DateFinDerogationV4__c);
        system.debug('@@ updatedOppty.Delai_derogation__c '+updatedOppty.Delai_derogation__c);
        system.assertEquals(updatedOppty.Delai_derogation__c,10);
        
    }
    
    public static testMethod void TestNumberOfHoursExceptHolidays(){
        Datetime startDate=DateTime.newInstance(2020, 1, 2, 9, 0, 0);
        Datetime endDate=DateTime.newInstance(2020, 1, 2, 17, 0, 0);
        Decimal hoursDiff = DateUtils.getHoursBetweenWorkingDays(startDate,endDate);
        system.assertEquals(hoursDiff,8);    
        Decimal hoursDiff2 = DateUtils.getHoursBetweenWorkingDays(null,endDate);
        system.assertEquals(hoursDiff2,null);   
        Decimal hoursDiff3 = DateUtils.getHoursBetweenWorkingDays(endDate,startDate);
        system.assertEquals(hoursDiff3,0);          
        
        Datetime startDate2=DateTime.newInstance(2019, 12, 17, 12, 0, 0);
        Datetime endDate2=DateTime.newInstance(2019, 12, 18, 9, 0, 0);
        Integer dayDiff = TR001ManageCase.getNumberOfDayExceptHolidays(startDate2,endDate2);
        system.assertEquals(dayDiff,1);    
        Integer dayDiff2 = TR001ManageCase.getNumberOfDayExceptHolidays(null,endDate2);
        system.assertEquals(dayDiff2,0);   
        Integer dayDiff3 = TR001ManageCase.getNumberOfDayExceptHolidays(endDate2,startDate2);
        system.assertEquals(dayDiff3,0);  
       
        Date startDate3=Date.newInstance(2019, 12, 17);
        Date endDate3=Date.newInstance(2019, 12, 18);
        Integer dDiff = TR001ManageCase.getNumberOfDayExceptHolidays(startDate3,endDate3);
        system.assertEquals(dDiff,1);    
        Integer dDiff2 = TR001ManageCase.getNumberOfDayExceptHolidays(null,endDate3);
        system.assertEquals(dDiff2,0);   
        Integer dDiff3 = TR001ManageCase.getNumberOfDayExceptHolidays(endDate3,startDate3);
        system.assertEquals(dDiff3,0);  
       
   
    }
  
    public static testMethod void testCalculApprobation() {       
        
        Map<String,Id> RTs = DAL.getRecordType('Case');
        Account acc = TestFactory.createAccount('testAcc');
        insert acc;
        
        Contract ctr = TestFactory.createContract(acc.Id);
        insert ctr;
        
        Case c = TestFactory.createCaseWithRT(ctr.Id, 'Prise en charge', (ID)RTs.get('CBM_Mise_en_place'));
        c.DateDebutApprobation__c=DateTime.newInstance(2020, 1, 2, 9, 0, 0);
        c.DateDecisionApprobation__c=null;
        c.TypeApprobation__c = '1';
        Opportunity oppty1=createOppty('opp1');
      
        insert c;
        
        Case caseToUpdate=[select id,Delai_PVFact_Crea__c,Delai_approbation_respecte__c, DateDecisionApprobation__c from Case where DateDebutApprobation__c!=null];
       
        Test.startTest();
        caseToUpdate.DateDecisionApprobation__c=DateTime.newInstance(2020, 1, 2, 17, 0, 0);  
       
        update caseToUpdate;           
        
        Case cResultat = [Select DateDecisionApprobation__c, Delai_approbation__c,Delai_approbation_respecte__c from Case where id = :c.id];
        system.debug('@@ cResultat '+cResultat);
        Decimal Delai=8;
        System.assert(cResultat.Delai_approbation_respecte__c);
        //System.assertEquals(cResultat.Delai_approbation__c,Delai);
        
        Test.stopTest();
        
        
    }

    public static testMethod void testCalculDelaiPVFactAjoutPAS() {       
        
        Map<String,Id> RTs = DAL.getRecordType('Case');
        Account acc = TestFactory.createAccount('testAcc');
        insert acc;
        
        Contract ctr = TestFactory.createContract(acc.Id);
        insert ctr;        
        Case c = TestFactory.createCaseWithRT(ctr.Id, 'Prise en charge', (ID)RTs.get('CBM_Mise_en_place'));
        Opportunity oppty1=createOppty('opp1');
       
        insert oppty1;
        c.ProjetAssocie__c=oppty1.Id;
        insert c;
        
      
        Test.startTest();
        Case caseToUpdate=[select id,Delai_PVFact_Crea__c, DateDecisionApprobation__c from Case limit 1];  
        System.assertNotEquals(caseToUpdate.Delai_PVFact_Crea__c,null);
        
        Opportunity oppty2=createOppty('opp2');
        oppty2.DateEnvoi2Docapost__c=DateTime.newInstance(2020, 1, 3, 19, 0, 0);
        oppty2.DateStatut423PVFactRecuesVerif__c=DateTime.newInstance(2020, 1, 3, 10, 0, 0) ;
        insert oppty2;
        
        caseToUpdate.ProjetAssocie__c=oppty2.Id;      
        update caseToUpdate;
        Case updatedCase=[select id,Delai_PVFact_Crea__c, DateDecisionApprobation__c from Case limit 1];  
        System.assertNotEquals(updatedCase.Delai_PVFact_Crea__c,null);
        
        Test.stopTest();
        
        
    }
    
    public static Opportunity createOppty(String opptyName){
        RecordType lRecordTypeOpp   = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIProjetAssocie' and SobjectType = 'Opportunity'];
        RecordType lRecordTypeTiers = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Tiers'  and SobjectType = 'Account'] ;     
        
        Account lTiers = new Account(Name = 'NATIXIS LEASE', RecordTypeId = lRecordTypeTiers.Id);
        insert lTiers;  
        
        Projet__c lProjet = new Projet__c(Name = 'Test', NomDuTiers__c = lTiers.Id);
        insert lProjet;
        
        Account lAccount = new Account(Name='Tiers Dossier Pool Financement');
        insert lAccount;
        
        Opportunity lOpportunity = new Opportunity(
            Name = opptyName,
            RecordTypeId = lRecordTypeOpp.Id,
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
            DateEnvoi2Docapost__c=DateTime.newInstance(2020, 1, 3, 9, 0, 0),
            DateStatut423PVFactRecuesVerif__c=DateTime.newInstance(2020, 1, 3, 10, 0, 0) 
        );
        
        
        
        return lOpportunity;
    }
    
     public static testMethod void testAddBusinessDays(){
        	Datetime startDate=Datetime.newInstance(2019,12,31,15,0,0);
            Datetime nextBusinessDays=DateUtils.addBusinessDays(startDate, 1);
            Date resultDate= nextBusinessDays.date();
            Date expectedDate=Date.newInstance(2020,01,02);
            system.assertEquals(resultDate,expectedDate);
            
     }
}