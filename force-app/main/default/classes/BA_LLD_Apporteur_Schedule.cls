/*************************************************************************************
* @date 22/05/2019
* @description Schedule de la classe batch "BA_LLD_Apporteur"
* Nom de la classe - BA_LLD_Apporteur_Schedule
*************************************************************************************/
global class BA_LLD_Apporteur_Schedule implements Schedulable {
    global void execute(SchedulableContext SCJe ) {
      BA_LLD_Apporteur b = new BA_LLD_Apporteur();
      database.executebatch(b,200);
    }
}