global class SchedeleSendEmailOpportunityMEL implements Schedulable{
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new BatchSendEmailOpportunity(), 1);
        
    }

}