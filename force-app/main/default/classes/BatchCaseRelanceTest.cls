@isTest
public class BatchCaseRelanceTest {
    static testMethod void TestBatch() {
        Test.startTest();
        Case obj = new Case(OwnerId = '0050J0000098EgiQAE', recordtypeId='0120J000000B8Ah', Information_sur_tiers_concerne__c ='sds', LancerCalculPhase__c = true);
        insert obj;
        obj.OwnerId = '0050J0000098EgiQAE';
        update obj;
        Database.executeBatch(new BatchCaseRelance(), 1); 
        
        String sch = '0 30  * 1/1 * ? *';
        
        system.schedule('test', sch, new ScheduleCaseRelance());
        Test.stopTest();
    }
}