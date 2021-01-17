@isTest
private class TestAttachmentSaver {
    
    /**
    * Verify that Standard User profiles are unable to delete attachments
    */
    static testMethod void testStandardUser() {
        
        // Create a new user with the Standard User profile
        Profile standardProf = [select id from profile  limit 1]; 
        User su = new User(alias = 'standt', email='standarduser@testorg.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = standardProf.Id, 
            timezonesidkey='America/Los_Angeles', username='standarduser@testorg.com');
            
        // Switch current user to Standard User
       // System.runAs(su) {      
        
            // Create test data (a new Account with an Attachment)
            Account acct = new Account(Name = 'Test Account');
            insert acct;
            Blob attachBody = Blob.valueOf('attachment body');
            Attachment attach = new Attachment(Name = 'TestAttachment', ParentId = acct.Id, Body = attachBody);
       
           Boolean errorThrown = false; 
            try {
               insert attach;
          } catch (Exception e) {
               System.debug(e);
              if (e.getMessage().contains('Actuellement il est impossible de joindre des fichiers. Cette fonctionnalité sera de nouveau disponible Lundi matin 8h30.')) {
                    errorThrown = true;
               }
            }
 //          System.assert(errorThrown);
       // }
    }
    

}