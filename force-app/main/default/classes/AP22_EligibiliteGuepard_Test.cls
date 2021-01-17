@isTest
public class AP22_EligibiliteGuepard_Test {
	
     @testSetup static void setup() {
         Account acc = TestFactory.createAccount('testAcc');
		 insert acc;   
         RecordType lRecordTypeOpp   = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBMEnDelegation' and SobjectType = 'Opportunity'];
         Opportunity opp=TestFactory.createOpty('testGuepard', acc.Id);
         opp.NEngagementV4__c='473864-CB-0';
         opp.RecordTypeId=lRecordTypeOpp.Id;
         opp.StageName='EC_SIG';
         insert opp;

     }
    
     static testMethod void testEligibiliteGuepard(){
        
        Opportunity oppty =[select id, NEngagementV4__c,StageName from Opportunity where name='testGuepard' limit 1];
        List<Id> Oppties=new List<Id>();
        Oppties.add(oppty.Id);
         Test.startTest();
         AP22_EligibiliteGuepard.checkEligibility(Oppties);		
        Test.stopTest();
         Opportunity updatedOppty =[select id,Audit_eligibilite__c,Eligibilite_Guepard__c, NEngagementV4__c,StageName from Opportunity where name='testGuepard' limit 1];    
		system.debug('@@ updatedOppty '+updatedOppty); 
        system.assertEquals(updatedOppty.Eligibilite_Guepard__c, 'Non');
        system.assert(updatedOppty.Audit_eligibilite__c.length()>0);
     }

}