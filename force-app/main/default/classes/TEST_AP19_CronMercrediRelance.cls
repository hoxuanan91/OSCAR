@istest
public class TEST_AP19_CronMercrediRelance {
    
    static testMethod void testBatch() {
        Test.startTest();        
            System.schedule('ScheduleAP19_CronMercrediRelance', '0 19 * * * ?', new AP19_CronMercrediRelance());                      
        Test.stopTest();
    }

}