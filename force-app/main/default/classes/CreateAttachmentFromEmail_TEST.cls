@isTest
public class CreateAttachmentFromEmail_TEST {
    //Test Method for main class
   
   static testMethod void testInboundEmail()
   {
        Account a = TestFactory.createAccount('test');
        a.Email__c = 'someaddress@email.com';
        insert a;

        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       
        // setup the data for the email
        email.subject = 'Create Contact';
        email.fromAddress = 'someaddress@email.com';
        email.plainTextBody = 'email body\n2225256325\nTitle';
        email.htmlBody = 'email body\n2225256325\nTitle';
      
        // call the email service class and test it with the data in the testMethod
        CreateAttachmentFromEmail testInbound = new CreateAttachmentFromEmail();
        testInbound.handleInboundEmail(email, env);
    
     
   
   }
}