global class ScheduleEligibiliteGuepard implements Schedulable{
   global void execute(SchedulableContext SC) {
         Database.executeBatch(new BatchRepriseEligibiliteGuepard(),50);
    }
}