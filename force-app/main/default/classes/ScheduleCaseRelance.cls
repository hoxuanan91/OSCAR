global class ScheduleCaseRelance implements Schedulable{
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new BatchCaseRelance(), 5);
    }
}