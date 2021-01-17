@isTest
public class DemandeChatterCBMTEST {
    static testMethod void TestBatch() {
        Case ca = new Case(RecordtypeId = '01220000000Av46AAC', Notifications__c = 'Alerte Délai max', OwnerId = UserInfo.getUserId());
        insert ca;
        ScheduleDemandeChatterCBM td = new ScheduleDemandeChatterCBM();
		td.executeBatch();
    }
}