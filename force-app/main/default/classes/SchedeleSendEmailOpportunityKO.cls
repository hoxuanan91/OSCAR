global class SchedeleSendEmailOpportunityKO implements Schedulable{
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new BatchSendEmailOpportunityKO('KO1'),1);
        Database.executeBatch(new BatchSendEmailOpportunityKO('KO2'),1);
        
    }
}