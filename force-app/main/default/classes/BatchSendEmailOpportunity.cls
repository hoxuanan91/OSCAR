global class BatchSendEmailOpportunity implements Database.Batchable<SObject>, Database.Stateful {
    
    private String tmpId;
    //private List<String> listId;
    global BatchSendEmailOpportunity() {
        //listId = new List<String>();
        tmpId=[Select id from EmailTemplate where DeveloperName = 'PJAME34EmailPhaseMEL' Limit 1].Id;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        EmailConfiguration__mdt conf = [select MaxDate__c, MinDate__c from EmailConfiguration__mdt where DeveloperName = 'AT_LIV'];
        if(Test.isRunningTest()) {
            query = 'select Id,IntervenantReseaux__r.Email, EmailDelegRegionalRenseigne__c,Dossier__c, Owner.EmailDelegRegionale__c,IntervenantReseaux__c, EmailEnvoyes__c from Opportunity';
        } else {
            query = 'select Id,IntervenantReseaux__r.Email, EmailDelegRegionalRenseigne__c,Dossier__c,EmailEnvoyes__c, Owner.EmailDelegRegionale__c,IntervenantReseaux__c from Opportunity'
                + ' where DateMiseEnLoyerCassiopaeBack__c >= 2019-01-01T00:00:00Z and DatePaiementFournisseur__c != null and DateMiseEnLoyerCassiopaeBack__c != null '
                + ' and (DatePaiementFournisseur__c >= LAST_N_DAYS:' + (Integer)conf.MinDate__c +' or DateMiseEnLoyerCassiopaeBack__c >= LAST_N_DAYS:' + (Integer)conf.MinDate__c + ') '
                +' and Owner.EmailDelegRegionale__c != null and EmailEnvoyes__c Excludes(\'MEL\') and IntervenantReseaux__c != null'
                +' and Dossier__r.StatutPaiementFournisseur__c = \'TOTAL\' and Dossier__r.Date_de_traitement_MEL__c != null  and EmailDelegRegionalRenseigne__c = true  and IntervenantReseaux__r.EmailBouncedDate = null ';
        }
        System.debug('@@@ query  ' + query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        List<Opportunity> oppList = new List<Opportunity>();
        System.debug('@@@ scope  ' + scope);
        for(Opportunity item : scope) {
            if(item.EmailDelegRegionalRenseigne__c || Test.isRunningTest()) {
                
                //listId.add(item.Id + ',' + item.Dossier__c);
                
                
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] { item.IntervenantReseaux__r.Email };
                    message.saveAsActivity = true;
                String sender = item.Owner.EmailDelegRegionale__c;
                message.replyTo = sender;
                message.senderDisplayName = sender;
                message.targetObjectId = item.IntervenantReseaux__c;
                message.whatId = item.Id;
                
                message.templateId = tmpId;
                //try{
              	if(!test.isRunningTest())
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {message}); 
                if(item.EmailEnvoyes__c == null) {
                    item.EmailEnvoyes__c = 'MEL';
                } else {
                    item.EmailEnvoyes__c += ';MEL';
                }
                oppList.add(item);
                //}catch(Exception e) {}
                
                
            }
            
        }
        System.debug('@@@ oppList  ' +oppList);
        if(oppList.size() > 0) {
            update oppList;
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        /* if(listId.size() == 0) {
return;
}
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
email.setSubject('[Success] Reprise d\'envoie d\'Email');
email.setPlainTextBody('Bonjour, \n\n'+ listId.size() + ' Email sont partis : '+String.join(listId, '\n')+'\n\nCordialement\nSupport Salesforce');

email.setToAddresses(Label.EmailRejectList.split(';'));
Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});*/ 
    }
}