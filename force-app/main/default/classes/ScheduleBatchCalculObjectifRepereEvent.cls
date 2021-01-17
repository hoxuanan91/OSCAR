global class ScheduleBatchCalculObjectifRepereEvent implements Schedulable{
     global void execute(SchedulableContext SC) {
           Integer mois=system.today().addDays(-1).month();
           Integer annee=system.today().addDays(-1).year();
           Database.executeBatch(new BatchCalculObjectifRepereEvent(mois,annee));
        }
}