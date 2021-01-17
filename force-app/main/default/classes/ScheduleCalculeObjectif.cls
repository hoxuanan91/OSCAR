global class ScheduleCalculeObjectif implements Schedulable{
    global void execute(SchedulableContext SC) {
         Database.executeBatch(new BatchCalculeObjectif());
    }
}