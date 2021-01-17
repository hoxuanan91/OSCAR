public with sharing  class Ctrl02_GestionDocumentaireAddons {
    public DocumentAssocie__c CompletudeRepertoire{get;set;}
    public List<DocumentAssocie__c> ListDocElecProjet {get;set;} 
    public Boolean isRepertoireComplet{get; set ;}
    ///////////////// 
    //Projet
    ////////////////
    public String NomDuProjet {get;set;}
    public String Section {get;set;}
    public String Categorie {get;set;}
    public String Repertoire{get;set;}
    public String IDDuProjet{get;set;}
 
     
    //////////////////
    ///Biens
    public String NomDuBien {get;set;}
    public List<DocumentAssocie__c> ListDocElecBien{get;set;} 
    public String IDDuBien{get;set;}
    
     public ContentVersion contentToUpload {get;set;}
     public Blob fileContent {get;set;}
 
    ////
     
   
   
   ///////////////// 
    //PageReference  
    ////////////////
    public String IDDocToDelete{get; set {  IDDocToDelete = value; }  }
    
    public String TypeDobjet{get; set {
                                        TypeDobjet = value; 
                                        System.debug('TypeDobjet: '+value);
                                       } 
                            }
  
    public String DAIDParam {get;set {
                                    DAIDParam = value;
                                    System.debug('DAIDParam: '+value);
                                    }
                            } 
      public ID IDObjectToAttach {get;set {
                                    IDObjectToAttach = value;
                                    System.debug('IDObjectToAttach: '+value);
                                    }
                            } 
       public String SectionParam {get;set {
                                    SectionParam = value;
                                    System.debug('IDObjectToAttach: '+value);
                                    }
                            }   
       public String CategorieParam {get;set {
                                    CategorieParam = value;
                                    System.debug('IDObjectToAttach: '+value);
                                    }
                            }  
    
     public String RepertoireParam {get;set {
                                        RepertoireParam = value;
                                        System.debug('RepertoireParam: '+value);
                                    }
                            } 
    
      
     public Ctrl02_GestionDocumentaireAddons( ApexPages.StandardController controller ) {
      String Controllertype = controller.getRecord().getSObjectType().getDescribe().getName();
      ListDocElecProjet = new List<DocumentAssocie__c>(); 
          Section = ApexPages.currentPage().getParameters().get('SectionParam') ;
           Categorie= ApexPages.currentPage().getParameters().get('CategorieParam') ; 
           Repertoire = ApexPages.currentPage().getParameters().get('RepertoireParam') ;
        
      if(Controllertype == 'Projet__c') {
          IDDuProjet =ApexPages.currentPage().getParameters().get('ID');
      
           Projet__c CProjet = [ SELECT Name  from Projet__c where id =: ApexPages.currentPage().getParameters().get('ID') ] ; 
           NomDuProjet = CProjet.Name;

           ListDocElecProjet = getListDossiersElectroniqueAssocies('projet', (ID)ApexPages.currentPage().getParameters().get('ID'),Section,Repertoire);  
           contentToUpload = new ContentVersion();
            
           CompletudeRepertoire = [ SELECT  id, RepertoireComplet__c, CompletudeEntete__c
                                 from DocumentAssocie__c
                                 where Projet__c =: IDDuProjet  
                                 and TypeDuDocument__c =: Repertoire 
                                 and CompletudeEntete__c = true
                                 ];
          
          isRepertoireComplet = CompletudeRepertoire.RepertoireComplet__c;
      }
      if(Controllertype == 'Bien_CBI__c') {
           IDDuBien =ApexPages.currentPage().getParameters().get('ID');
      
           Bien_CBI__c CBien = [ SELECT Name  from Bien_CBI__c where id =: IDDuBien ] ; 
           NomDuBien = CBien.Name; 
           
           ListDocElecBien = getListDossiersElectroniqueAssocies('bien', (ID)ApexPages.currentPage().getParameters().get('ID'),Section,Repertoire); 
           contentToUpload = new ContentVersion();
          
           CompletudeRepertoire = [   SELECT  id, RepertoireComplet__c, CompletudeEntete__c
                                     from DocumentAssocie__c
                                     where BienCBI__c =: IDDuBien  
                                     and TypeDuDocument__c =: Repertoire 
                                     and CompletudeEntete__c = true
                                 ];
           isRepertoireComplet = CompletudeRepertoire.RepertoireComplet__c;
          
      }
        
    }
    public List<DocumentAssocie__c> getListDossiersElectroniqueAssocies(String ObjetDuDocument, ID IDToSearch, String SectionParam,String Repertoire   ) { 
         System.debug('ObjetDuDocument ' + ObjetDuDocument + 'IDToSearch ' + IDToSearch + ' SectionParam '   + SectionParam+ ' Repertoire ' +Repertoire) ; 
        List<DocumentAssocie__c> ListDocElec= new List<DocumentAssocie__c>();
        List<DocumentAssocie__c> ReqCurrentObject ;
        if(ObjetDuDocument == 'projet') {  
            ListDocElec = [ SELECT  TypeDuDocument__c, NomDuFichierCharge__c , DocCharge__c, LienDuDocument__c, DateValidite__c
                                 from DocumentAssocie__c
                                 where Projet__c =: IDToSearch  
                                 and TypeDuDocument__c =: Repertoire 
                                 and DocCharge__c = true
                                 and CompletudeEntete__c=false];  
        
         }
         else if(ObjetDuDocument == 'bien')  {
             ListDocElec = [ SELECT  TypeDuDocument__c , NomDuFichierCharge__c , DocCharge__c, LienDuDocument__c, DateValidite__c
                                  from DocumentAssocie__c
                                 where BienCBI__c =:IDToSearch  
                                 and TypeDuDocument__c =: Repertoire
                                 and DocCharge__c = true
                                 and CompletudeEntete__c=false];  
        
         } 
      
        return ListDocElec;
    } 
    public ApexPages.Pagereference SaveDateValiditeCompletudeRepertoireFromUpload() {
         DAIDParam = ApexPages.currentPage().getParameters().get('id');
         RepertoireParam = ApexPages.currentPage().getParameters().get('RepertoireParam');
         CategorieParam = ApexPages.currentPage().getParameters().get('CategorieParam');
         SectionParam =  ApexPages.currentPage().getParameters().get('SectionParam');
         TypeDobjet  = ApexPages.currentPage().getParameters().get('TypeDobjet');
          
         System.debug('----isRepertoireComplet ' +  isRepertoireComplet );
         setRepertoireComplet( DAIDParam , RepertoireParam , TypeDobjet,  isRepertoireComplet  );    
            
          PageReference pageRef ; 

           if(TypeDobjet == 'bien') {
                  if(ListDocElecBien.size() > 0 ){
                      update ListDocElecBien;
                    }

                  pageRef  = Page.vfp02_uploadfilebien;
   
            } else if(TypeDobjet == 'projet') {
                    if(ListDocElecProjet.size() > 0 ){
                        update ListDocElecProjet;
                    }

                    pageRef  = Page.vfp02_uploadfilepa;
            }
        
        
            pageRef.getParameters().put('RepertoireParam',ApexPages.currentPage().getParameters().get('RepertoireParam')); 
            pageRef.getParameters().put('CategorieParam',ApexPages.currentPage().getParameters().get('CategorieParam')); 
            pageRef.getParameters().put('SectionParam',SectionParam); 
            pageRef.getParameters().put('TypeDobjet',TypeDobjet); 
        
            pageRef.getParameters().put('id',ApexPages.currentPage().getParameters().get('ID')); 
            return PageRef.setRedirect(True);
         //   return PageRef ;
    }
    public ApexPages.Pagereference SaveDateValiditeCompletudeRepertoire() {

         RepertoireParam = ApexPages.currentPage().getParameters().get('RepertoireParam');
         CategorieParam = ApexPages.currentPage().getParameters().get('CategorieParam');
         SectionParam =  ApexPages.currentPage().getParameters().get('SectionParam');
         TypeDobjet  = ApexPages.currentPage().getParameters().get('TypeDobjet');
         
           System.debug('----isRepertoireComplet ' +  isRepertoireComplet  + 'DAIDParam ' + DAIDParam);
          setRepertoireComplet( DAIDParam , RepertoireParam , TypeDobjet,  isRepertoireComplet  );   
           
          PageReference pageRef ; 

        if(TypeDobjet == 'bien') {
                  if(ListDocElecBien.size() > 0 ){
                      update ListDocElecBien;
                    } 
                  pageRef  = Page.vf02_gdebienavancee;
            }
            else if(TypeDobjet == 'projet') {
                    if(ListDocElecProjet.size() > 0 ){
                        update ListDocElecProjet;
                    } 
                    pageRef  = Page.vf02_gdeprojetavancee;
            }
            
            
            pageRef.getParameters().put('RepertoireParam',ApexPages.currentPage().getParameters().get('RepertoireParam')); 
            pageRef.getParameters().put('CategorieParam',ApexPages.currentPage().getParameters().get('CategorieParam')); 
            pageRef.getParameters().put('SectionParam',SectionParam); 
            pageRef.getParameters().put('TypeDobjet',TypeDobjet); 
            
            pageRef.getParameters().put('id',ApexPages.currentPage().getParameters().get('ID')); 
            return PageRef.setRedirect(True);
         //   return PageRef ;
    } 
    
     public ApexPages.Pagereference uploadFile(){
         DAIDParam = ApexPages.currentPage().getParameters().get('id');
         RepertoireParam = ApexPages.currentPage().getParameters().get('RepertoireParam');
         CategorieParam = ApexPages.currentPage().getParameters().get('CategorieParam');
         SectionParam =  ApexPages.currentPage().getParameters().get('SectionParam');
         TypeDobjet  = ApexPages.currentPage().getParameters().get('TypeDobjet');
                System.debug('contentToUpload.Title ' + contentToUpload);
        if(contentToUpload.PathOnClient != null ) { 
            ID recordtype  = Schema.SObjectType.DocumentAssocie__c.getRecordTypeInfosByName().get('Document Associé Projet').getRecordTypeId(); 
            ID ParentId = null;
            String NomDudoc = '';
            
            List<ContentWorkSpace> CWList = [SELECT Id, Name From ContentWorkspace WHERE Name = 'Dossier Electronique'];
            contentToUpload.VersionData = fileContent ; 
            insert contentToUpload; 
            contentToUpload = [SELECT ContentDocumentId, title FROM ContentVersion WHERE Id = :contentToUpload.Id];
            NomDudoc = contentToUpload.title;
            ContentWorkspaceDoc cwd = new ContentWorkspaceDoc();
            cwd.ContentDocumentId = contentToUpload.ContentDocumentId;
            cwd.ContentWorkspaceId = CWList.get(0).Id;
            insert cwd; 

             Id  idParent = ApexPages.currentPage().getParameters().get('ID');                      
             setDossierElectroniqueAssociated(idParent,recordtype, contentToUpload, DAIDParam ,RepertoireParam, TypeDobjet, NomDudoc );
             System.debug('ParentId ' + ParentId);  
        
        }//if
         
          PageReference pageRef ; 
       
           if(TypeDobjet == 'bien') {
                
                pageRef  = Page.vfp02_uploadfilebien;
                   
            } else if(TypeDobjet == 'projet') {
                 pageRef  = Page.vfp02_uploadfilepa;
            }
          
           
            pageRef.getParameters().put('RepertoireParam',ApexPages.currentPage().getParameters().get('RepertoireParam')); 
            pageRef.getParameters().put('CategorieParam',ApexPages.currentPage().getParameters().get('CategorieParam')); 
            pageRef.getParameters().put('SectionParam',SectionParam); 
            pageRef.getParameters().put('TypeDobjet',TypeDobjet); 
        
            pageRef.getParameters().put('id',ApexPages.currentPage().getParameters().get('ID')); 
            return PageRef.setRedirect(True);
           return PageRef ;
    }
     public ID setDossierElectroniqueAssociated(ID Associe, ID recordtype, ContentVersion contentToUpload, String DAID , String Type , String TypeDobjet, String NomDudoc) {
         System.debug('Attach DE > DAID : Type' + DAID + ' Pojet/Bien ID : ' + Associe + ' Type : ' + Type + ' TypeDobjet : ' + TypeDobjet + 'contentToUpload : '+ contentToUpload);
        Id RecordTypeId = [SELECT id  FROM RecordType where DeveloperName =: 'DocumentAssocieProjet' limit 1].Id; 
        DocumentAssocie__c DA = new DocumentAssocie__c();  
        CategorieDocumentAssocie__c  CDA = [Select Id from CategorieDocumentAssocie__c where Label__c =: Type]; 
       
        if(TypeDobjet == 'bien') {
                  DA.BienCBI__c = Associe;
            } else if(TypeDobjet == 'projet') {
                 DA.Projet__c = Associe;                
            }
      
        DA.DocCharge__c = true;
        DA.CompletudeDossier__c = true;
        DA.CategorieDocumentAssocie__c = CDA.ID ;
        DA.TypeDuDocument__c = Type;
        DA.LienDuDocument__c = contentToUpload.ContentDocumentId;         
        DA.RecordTypeId = RecordTypeId;
        DA.NomDuFichierCharge__c = NomDudoc;
        insert DA;
        return DA.ID ; 
    }
    public void setRepertoireComplet( String DAID , String Type , String TypeDobjet, Boolean isComplet ) {
        
        System.debug('isRepertoireComplet ' +  isComplet + 'IDDuBien :' +IDDuBien + 'Type ' + Type  );
        DocumentAssocie__c CompletudeRepertoire = new DocumentAssocie__c();
        if(TypeDobjet == 'bien') {
                  CompletudeRepertoire = [   SELECT  id, RepertoireComplet__c, CompletudeEntete__c
                                     from DocumentAssocie__c
                                     where BienCBI__c =: IDDuBien  
                                     and TypeDuDocument__c =: Type 
                                     and CompletudeEntete__c = true
                                 ];
      
            }
            else if(TypeDobjet == 'projet') {
                 CompletudeRepertoire = [ SELECT  id, RepertoireComplet__c, CompletudeEntete__c
                                 from DocumentAssocie__c
                                 where Projet__c =: IDDuProjet  
                                 and TypeDuDocument__c =: Repertoire 
                                 and CompletudeEntete__c = true
                                 ];            
            }
            CompletudeRepertoire.RepertoireComplet__c = isComplet;
            update CompletudeRepertoire;
        
    } 
    public PageReference  DeleteFileAndDA() {
        DocumentAssocie__c CompletetudeToDelete = [SELECT Id, LienDuDocument__c From DocumentAssocie__c where id =: IDDocToDelete Limit 1];

        delete new ContentDocument(Id=CompletetudeToDelete.LienDuDocument__c);
        delete CompletetudeToDelete;
        
        System.debug('IDDocToDelete: '+IDDocToDelete);     
         
        PageReference pageRef ;

           if(TypeDobjet == 'bien') {
                pageRef  = Page.vf02_gdebienavancee;  
            } else if(TypeDobjet == 'projet') {
                pageRef  = Page.vf02_gdeprojetavancee;
            }
                     
            pageRef.getParameters().put('RepertoireParam',Repertoire); 
            pageRef.getParameters().put('CategorieParam',Categorie); 
            pageRef.getParameters().put('SectionParam',Section); 
            pageRef.getParameters().put('TypeDobjet',TypeDobjet); 
        
            pageRef.getParameters().put('id',ApexPages.currentPage().getParameters().get('ID')); 
            return PageRef.setRedirect(True);
           return PageRef ;
    }
     public PageReference  DeleteFileAndDAFromUpload() {
        DocumentAssocie__c CompletetudeToDelete = [SELECT Id, LienDuDocument__c From DocumentAssocie__c where id =: IDDocToDelete limit 1];

        delete new ContentDocument(Id=CompletetudeToDelete.LienDuDocument__c);
        delete CompletetudeToDelete;
        
        System.debug('IDDocToDelete: '+IDDocToDelete);     
         
        PageReference pageRef ; 
   
           if(TypeDobjet == 'bien') {
                pageRef  = Page.vfp02_uploadfilebien;
 
            } else if(TypeDobjet == 'projet') {
                pageRef  = Page.vfp02_uploadfilepa;
            }
       
            pageRef.getParameters().put('RepertoireParam',Repertoire); 
            pageRef.getParameters().put('CategorieParam',Categorie); 
            pageRef.getParameters().put('SectionParam',Section); 
            pageRef.getParameters().put('TypeDobjet',TypeDobjet); 
        
            pageRef.getParameters().put('id',ApexPages.currentPage().getParameters().get('ID')); 
            return PageRef.setRedirect(True);
           return PageRef ;
    }
    
}