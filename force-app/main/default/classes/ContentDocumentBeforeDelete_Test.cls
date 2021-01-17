@isTest
public class ContentDocumentBeforeDelete_Test {
     
    
    public static testMethod void testDeleteFile(){
         ContentVersion contentVersion = new ContentVersion(
          Title = 'Penguins',
          PathOnClient = 'Penguins.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        try{
            delete documents;
        }
        catch(DmlException e){
            System.Assert(e.getMessage().contains(Label.CL13_SuppressionPieceJointe));
         }
        
    }
    
}