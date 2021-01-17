global class SchedeleSendEmailOpportunityATLIV implements Schedulable{
    global void execute(SchedulableContext SC) {
         Database.executeBatch(new BatchSendEmailOpportunityATLIV(), 1);
    }
}