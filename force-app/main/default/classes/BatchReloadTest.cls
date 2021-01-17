@isTest
public class BatchReloadTest {
	static testMethod void TestBatch() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BatchReloadMock()); 
        ScheduleReloadData sch = new ScheduleReloadData();
        sch.execute(null);
        Test.stopTest();
    }
}