global class BatchReassignmentCase implements Database.Batchable<SObject>,Database.Stateful{
  
    private String assId;
    private List<String> listCaseId;
    global BatchReassignmentCase() {
        AssignmentRule  AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        assId = AR.id;
        listCaseId = new List<String>();
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
       String query;
        if(Test.isRunningTest()) {
             query = 'select Id from case';
        } else {
            query = 'select Id from case where Owner.Alias = \'btale\' and recordtype.Name = \'CBM - Mise en place\'';
        }
        return Database.getQueryLocator(query);
      
    }
    global void execute(Database.BatchableContext BC, List<Case> scope){
        
         for(Case item : scope) {
             listCaseId.add(item.Id);
             Database.DMLOptions dmlOpts = new Database.DMLOptions();
             dmlOpts.assignmentRuleHeader.assignmentRuleId= assId;
             item.setOptions(dmlOpts);
         }
         
         update scope;
    }
    
    global void finish(Database.BatchableContext BC){
        if(listCaseId.size() == 0) {
            return;
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        email.setSubject('[Success] Assignement des Cases');
        email.setPlainTextBody('Bonjour, \n\n'+ listCaseId.size() + ' Cases sont ré-assignés : \n'+ String.join(listCaseId, '\n')+ '\n\nCordialement\nSupport Salesforce');
        
        email.setToAddresses(Label.EmailRejectList.split(';'));
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
        
    }
}