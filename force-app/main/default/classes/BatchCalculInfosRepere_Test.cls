@isTest
public class BatchCalculInfosRepere_Test {

    
     public static testMethod void testCalculApprobation() {       
        
        Map<String,Id> RTs = DAL.getRecordType('Case');
        Account acc = TestFactory.createAccount('testAcc');
        insert acc;
        
        Contract ctr = TestFactory.createContract(acc.Id);
        insert ctr;
        
        Case c = TestFactory.createCaseWithRT(ctr.Id, 'Prise en charge', (ID)RTs.get('CBM_Mise_en_place'));
        c.Date_de_traitement_de_la_MEL__c=Date.newInstance(2020, 1, 16);
        c.DateDecisionApprobation__c=null;
        c.TypeApprobation__c = '1';
        Opportunity oppty1=createOppty('opp1');
         c.ProjetAssocie__c=oppty1.Id;
         c.ownerId=UserInfo.getUserId();
        insert c;
        Case insertedCase=[Select owner.type,status,Date_de_traitement_de_la_MEL__c,owner.Id from case where id=:c.Id];
                            /*where status!='Annulée' 
                            and Date_de_traitement_de_la_MEL__c>=2020-01-01 
                            and Date_de_traitement_de_la_MEL__c<=2020-01-17 
                            and owner.type='User'];*/
         
        system.debug('@@insertedCase '+insertedCase);
        Test.startTest();
            //Database.executeBatch(new BatchCalculInfosRepere(17,01,2020));
             String sch = '0 30  * 1/1 * ? *';
             system.schedule('calculrepere', sch, new ScheduleBatchCalculInfosRepere());
         
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
            DateRetour2DocapostOK__c=DateTime.newInstance(2020, 1, 3, 9, 0, 0),
            DateStatut423PVFactRecuesVerif__c=DateTime.newInstance(2020, 1, 3, 10, 0, 0) 
        );
        
        
        
        return lOpportunity;
    }
}