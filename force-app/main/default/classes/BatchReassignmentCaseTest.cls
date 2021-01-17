@isTest
public class BatchReassignmentCaseTest {
	static testMethod void TestBatch() {
        Test.startTest();
       Case obj = new Case(OwnerId = '0050J0000098EgiQAE', recordtypeId='01220000000Av43AAC');
        insert obj;
        obj.OwnerId = '0050J0000098EgiQAE';
        update obj;
        Database.executeBatch(new BatchReassignmentCase(), 1);
        Test.stopTest();
    }
}