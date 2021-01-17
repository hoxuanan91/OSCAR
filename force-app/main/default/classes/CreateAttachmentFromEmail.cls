global class CreateAttachmentFromEmail implements Messaging.InboundEmailHandler{
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
        
        // Create an InboundEmailResult object for returning the result of the 
        // Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        String emailBody= '';
        String emailBodyReplyTo = '';
        // Store the email plain text into the local variable 
        emailBody = email.plainTextBody;

        List<String> emailBodySplit = emailBody.split('>');

        for(String str : emailBodySplit){
            if(str.contains('No siren/No séquana:')){
                emailBodyReplyTo = str;
                emailBodySplit = emailBodyReplyTo.split('/');
                emailBodyReplyTo = emailBodySplit[emailBodySplit.size() - 1].replaceAll('[^a-zA-Z0-9_]', '');
                break;
            }
        }

        // Try to look up any contacts based on the from email address.
        // If there are more than one contacts with the same email address,
        // an exception will be thrown and the catch statement block will be executed.
        try{
            Account acc = new Account();
            List<Account> accs = new List<Account>();
            String dynamicQuery = 'SELECT Id, Email__c, Code_tiers_Client_Sequana__c FROM Account ';
            String genericEmail = [SELECT Id, EmailTiersGenerique__c FROM VariablesGeneriques__c].EmailTiersGenerique__c;

            if(emailBodyReplyTo != ''){
                dynamicQuery += 'WHERE Code_tiers_Client_Sequana__c = :emailBodyReplyTo ';
            }
            else if(email.fromAddress != null){ 
                String emailAddress = email.fromAddress;
                dynamicQuery += ' WHERE Email__c = :emailAdress ';
            }

            dynamicQuery += 'LIMIT 1';

            accs = Database.query(dynamicQuery);

            if(accs.isEmpty()){
                acc = [SELECT Id, Email__c, Code_tiers_Client_Sequana__c FROM Account WHERE Email__c = :genericEmail LIMIT 1];
            }
            else{
                acc = accs[0];
            }

            if(acc != null){
                Case newCase = new Case(Subject     = email.subject,
                                    Accountid   = acc.Id,
                                    Origin      = 'Email',
                                    Status      = 'New',
                                    Description = emailBody);

                insert newCase;

                insert new EmailMessage(FromAddress     = email.fromAddress,
                                        FromName        = email.fromName,
                                        Subject         = email.subject,
                                        TextBody        = emailBody,
                                        HtmlBody        = email.htmlBody,
                                        ParentId        = newCase.Id,
                                        RelatedToId     = acc.Id);
            }
            
        }
        // If an exception occurs when the query accesses 
        // the contact record, a QueryException is thrown.
        // The exception is written to the Apex debug log.
        catch (QueryException e){
            System.debug('Query Issue: ' + e);
        }
        
        // Set the result to true. No need to send an email back to the user 
        // with an error message
        result.success = true;
        
        // Return the result for the Apex Email Service
        return result;
    }
}