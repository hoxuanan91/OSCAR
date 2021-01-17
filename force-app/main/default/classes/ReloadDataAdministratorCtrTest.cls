@isTest
public class ReloadDataAdministratorCtrTest {
static testMethod void TestBatch() {
    Test.startTest();
    ReloadDataAdministratorCtr.getAllBulkJob();
    ReloadDataAdministratorCtr.setReexecuteJob(new List<JobProcessedHistory__c> {new JobProcessedHistory__c(JobBulkId__c = 'df')});
     ReloadDataAdministratorCtr.searchAllBulkJob(null, null, null);
    ReloadDataAdministratorCtr.searchAllBulkJob('Opp', 'Insert', System.today());
    Test.stopTest();
    }
}