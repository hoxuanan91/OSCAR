@isTest
public class BatchRepriseEligibiliteGuepard_Test {

   @testSetup static void setup() {
         Account acc = TestFactory.createAccount('testAcc');
		 insert acc;   
         RecordType lRecordTypeOpp   = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBMEnDelegation' and SobjectType = 'Opportunity'];
         Opportunity opp=TestFactory.createOpty('testGuepard', acc.Id);
         opp.NEngagementV4__c='473864-CB-0';
         opp.RecordTypeId=lRecordTypeOpp.Id;
         opp.StageName='EC_SIG';
         opp.DateStatut422DossierRecuControle__c=system.today();
         opp.Eligibilite_Guepard__c='Aucun';
         insert opp;

     }
     static testMethod void testBatchEligibiliteGuepard(){    
             
 		List<Opportunity> scopes =[select id, NEngagementV4__c,StageName,Eligibilite_Guepard__c 
                                   from Opportunity 
                                   where NEngagementV4__c='473864-CB-0'
                                  ];
             
            Test.startTest();             
             //Database.executeBatch(new BatchRepriseEligibiliteGuepard());
             //Ne pas appeler Database.executeBatch qui insert un record dans la table ApexAsyncJob 
             //Ce qui entraine un DML avant le callout==>Non authorise
             BatchRepriseEligibiliteGuepard btch=new BatchRepriseEligibiliteGuepard();
             btch.start(null);
             btch.execute(null, scopes);
             btch.finish(null);
             String sch = '0 30  * 1/1 * ? *';
             //system.schedule('verifierEligibilite', sch, new ScheduleCalculeObjectif());
             Test.stopTest();
             Opportunity oppty =[select id, NEngagementV4__c,StageName,Eligibilite_Guepard__c from Opportunity where NEngagementV4__c='473864-CB-0' limit 1];
             system.debug('@@ oppty ' +oppty );
             system.assertNotEquals(oppty.Eligibilite_Guepard__c, 'Aucun');
        
     }
    
     static testMethod void testScheduler(){            
         List<Opportunity> scopes =[select id, NEngagementV4__c,StageName,Eligibilite_Guepard__c 
                                    from Opportunity 
                                    where NEngagementV4__c='473864-CB-0'
                                   ];         
         Test.startTest();             
         String sch = '0 30  * 1/1 * ? *';
         system.schedule('verifierEligibilite', sch, new ScheduleEligibiliteGuepard());
         Test.stopTest();
        
     }
}