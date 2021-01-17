/*************************************************************************************
* @date 23/05/2019
* @description Classe de test de la classe BA_LLD_Apporteur_Schedule
* Nom de la classe - TEST_BA_LLD_Apporteur_Schedule
*************************************************************************************/

@isTest
public class TEST_BA_LLD_Apporteur_Schedule {
    /**
    * @date  23/05/2019
    * @description Vérifie l'éxecution du batch BA_LLD_Apporteur
    * *****/
    static testmethod void batchApporteurSchedule(){
        Test.startTest();
        
        BA_LLD_Apporteur_Schedule sch1 = new BA_LLD_Apporteur_Schedule();
        
        String sch = '0 0 23 * * ?'; 
        String jobId = system.schedule('Batch schedule test check', sch, sch1); 
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(sch, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
    }
}