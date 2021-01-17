@RestResource(urlMapping='/DragAndDrop/v1/*')
global with sharing class DragAndDropRESTAPI {
//      public string isRefresh  {get;set;}
 
    
    @HttpPost   
    global static String attachDoc(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        
        	Blob postContent = req.requestBody; 
        	ContentVersion  contentToUpload = new ContentVersion();
      
            //ID recordtype  = Schema.SObjectType.DocumentAssocie__c.getRecordTypeInfosByName().get('Document Associé Projet').getRecordTypeId(); 
            ID ParentId = null;
            String NomDudoc = '';
            String WorkSpaceName = Label.WorkspaceDocumentsAssicies;
            List<ContentWorkSpace> CWList = [SELECT Id, Name From ContentWorkspace WHERE Name =: WorkSpaceName ];
            DocumentAssocie__c DA = new DocumentAssocie__c();  
        if(CWList.get(0) != null ) { 
            contentToUpload.VersionData = postContent;
            
            contentToUpload.pathOnClient = req.params.get('FileName');   
         
            insert contentToUpload;
      
            contentToUpload = [SELECT ContentDocumentId, title FROM ContentVersion WHERE Id = :contentToUpload.Id];
            NomDudoc = contentToUpload.title;
            ContentWorkspaceDoc cwd = new ContentWorkspaceDoc();
            cwd.ContentDocumentId = contentToUpload.ContentDocumentId;
            cwd.ContentWorkspaceId = CWList.get(0).Id;
            insert cwd;
             
            String TypeParam =req.params.get('repertoire'); 
            Id  idParent = req.params.get('parId');    
        	String TypeDobjet = req.params.get('TypeObjet');  
        
  
         List<RecordType> RecordTypeId = new List<RecordType>(); 
 
        CategorieDocumentAssocie__c  CDA = [Select Id from CategorieDocumentAssocie__c where Label__c =: TypeParam]; 
         if(TypeDobjet == 'bien') { 
                    RecordTypeId = [SELECT id  FROM RecordType where sObjectType='DocumentAssocie__c' and DeveloperName = 'DocumentAssocieBien' ]; 
               		Bien_CBI__c Bien = [Select Id from Bien_CBI__c where id =: idParent];            
            		DA.BienCBI__c = Bien.id;  
             		DocumentAssocie__c   CheckIfNewDocExist ;
             		CheckIfNewDocExist = [   SELECT ID
                                                          from DocumentAssocie__c
                                                          where BienCBI__c =: idParent
                                                          And TypeDuDocument__c =: TypeParam
                                                          and CompletudeEntete__c = true
                                                       ]; 
            		CheckIfNewDocExist.DocCharge__c = true;
                    update CheckIfNewDocExist;
            }
            else if(TypeDobjet == 'projet') {
                    RecordTypeId = [SELECT id  FROM RecordType where sObjectType='DocumentAssocie__c' and DeveloperName ='DocumentAssocieProjet' ]; 
                    Projet__c cp = [Select Id from Projet__c where id =: idParent];            
            		DA.Projet__c = cp.id;    
                	DocumentAssocie__c   CheckIfNewDocExist ;
              	    CheckIfNewDocExist = [   SELECT ID
                                                          from DocumentAssocie__c
                                                          where Projet__c =: idParent
                                                          And TypeDuDocument__c =: TypeParam
                                                          and CompletudeEntete__c = true
                                                       ]; 
                	CheckIfNewDocExist.DocCharge__c = true;
                    update CheckIfNewDocExist;
            }
        
                         
        DA.DocCharge__c = true;
        DA.CompletudeDossier__c = true;
        DA.CategorieDocumentAssocie__c = CDA.ID ;
        DA.TypeDuDocument__c = TypeParam;
	    DA.LienDuDocument__c = contentToUpload.ContentDocumentId;         
        DA.RecordTypeId = RecordTypeId.get(0).id ;
        DA.NomDuFichierCharge__c = NomDudoc;
    
        insert DA;
             
        
             
        }
        return DA.Id;
   } 
   
    
 
}