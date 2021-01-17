global class SchedeleSendEmailOpportunityDero implements Schedulable{
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new BatchSendEmailOpportunityDERO(), 1);
        
    }
}