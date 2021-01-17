global class ScheduleBatchCalculInfosRepere implements Schedulable{
     global void execute(SchedulableContext SC) {
           Integer jour=system.today().day();
           Integer mois=system.today().month();
           Integer annee=system.today().year();
           Database.executeBatch(new BatchCalculInfosRepere(jour,mois,annee));
        }
}