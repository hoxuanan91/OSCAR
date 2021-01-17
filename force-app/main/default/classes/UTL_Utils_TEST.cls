@isTest
public class UTL_Utils_TEST {
    private static testMethod void genericTest() {
		Test.startTest();
        
        String recordTypeId = UTL_Utils.getRecordTypeID(String.valueof(Account.getSobjectType()), 'Tiers');
        
        Account a = TestFactory.createAccount('Test');
        a.RecordTypeId = recordTypeId;
        insert a;
        
        String devName = UTL_Utils.getRecordTypeDevName(String.valueof(Account.getSobjectType()), a.RecordTypeId);
        
        Test.stopTest();
    }
}