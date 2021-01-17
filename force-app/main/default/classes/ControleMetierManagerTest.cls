@isTest
public class ControleMetierManagerTest {
    static testmethod void mainTest() {
        Account acc = new Account(Name = 'test');
        insert acc;
        Contract ct = new Contract(Name = 'test', accountId = acc.id);
        insert ct;
        Opportunity obj = new Opportunity(dossier__c = ct.Id, accountId = acc.id, Name='test', StageName = 'Octroi', CloseDate = System.today(),NEngagementV4__c = '01010');
        insert obj;
		
        ControleMetier__c cm = new ControleMetier__c();
        cm.TechReferenceIntercalaire__c = '0010';
        cm.RefrenceMetier__c = '01010';
        cm.StatutFlux__c = '1';
        cm.NatureEnvoi__c = '2';
        Test.startTest();
        insert cm;
        Test.stopTest();
    }
}