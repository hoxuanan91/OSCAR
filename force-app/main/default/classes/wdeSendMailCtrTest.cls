@IsTest
private class wdeSendMailCtrTest {
    @testSetup
    static void initData() {
        Contact ctc = TestFactory.createContact('testFisrtName','testLastName','testWdeSendMailCtrTest@test.qua.com');
        insert ctc;
        
        Account acc = TestFactory.createAccount('accName');
        insert acc;
        
        Opportunity opp = TestFactory.createOpty('oppTest', acc.Id);
        insert opp;
        
        OpportunityContactRole ocr = TestFactory.createOpportunityContactRole(ctc.Id, opp.Id);
        insert ocr;
    }
    
	static testMethod void testSendMailCtrWithOpportunity() {
        Contact ctc = [SELECT Id FROM Contact LIMIT 1][0];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1][0];
        
        Test.startTest();
        
        String result = wdeSendMailCtr.loadEmail('email correspondant', opp.Id, 'Opportunity');
        System.assert(result != null, 'Erreur testSendMailCtrWithOpportunity');
        
        result = wdeSendMailCtr.loadEmail('email conseiller', opp.Id, 'Opportunity');
        System.assert(result == null, 'Erreur testSendMailCtrWithOpportunity');
            
        Test.stopTest();
	}
    
    static testMethod void testSendMailCtrWithContact() {
        Contact ctc = [SELECT Id FROM Contact LIMIT 1][0];
        
        Test.startTest();
        
        String result = wdeSendMailCtr.loadEmail('Email', ctc.Id, 'Contact');
        System.assert(result != null, 'Erreur testSendMailCtrWithContact');
            
        Test.stopTest();
	}
}