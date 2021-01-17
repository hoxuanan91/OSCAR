@isTest

public class LLD_TestFileUploadController {
  
   static PageReference pageRef;  

     // This method to cover valid code
    public static testMethod void first(){        
        
        // Created account record for give the parent id to attachment 
        Lead ld = new Lead();
        ld.Company = 'TestAcc';
        ld.LastName='Dupont';
        insert ld;
        
        // Assigning values to the attachment object
        Attachment objAtt = new Attachment(Body = Blob.valueOf('Test Body'), Name = 'Test Attachment', ParentId = ld.Id);  
		insert objAtt;  
        
        // Created object of the class
        pageRef = new PageReference('/apex/LLD_FormulaireLeadReseau?id=ld.Id');
     	Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', ld.Id); 
        ApexPages.StandardController stdCTR = new ApexPages.StandardController(ld); 
		FileUploadController objController = new FileUploadController(stdCTR); 
        objController.attachment1=objAtt;
        objController.lead=ld;

        
        // Calling upload method
        objController.upload();
        List<Attachment> attachments=[select Name from Attachment where Parent.id=:ld.id];
    	System.assertEquals(1, attachments.size());
        

    }
 

}