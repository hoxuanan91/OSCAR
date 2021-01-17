public with sharing  class Ctrl02_GestionDocumentaire {
    Map<String,List<String>> GlobalANTISSOQLLIMITListCategorie{get; set;} 
    List<String> GlobalANTISSOQLLIMITListSection{get; set;} 
    Map<String,List<String>> GlobalANTISOQLBiensCategoriesLabelAssociated{get; set;} 
          
    Map<Bien_CBI__c, Map<String,List<String>>> GlobalANTISSOQLLIMITBiensSectionCategorie{get; set;} 
 ///////////////// 
    //Projet
    ////////////////
    
    public String parentId {get;set;}
    public String TypeDossierE {get;set;}
    public Date dateChangement {get; set;}
    public Date dateValidite {get; set;} 
    public List<ListeDeBien__c> GlobalListeBien {get; set;} 
    Id memberId;
 
    public Boolean RenderFieldConstructionImmeuble  {get; set;}
    public Map<String,  Boolean> ListDocMandatory  {get; set;}
    public Map<String,  String> ListDocMandatoryUploaded {get; set;}
    public List<String>  ListSectionProjet {get; set;}
    public Map<String,  Boolean> ListDemandeNotaire  {get; set;}
    public Map<String,  Boolean> ListDemandeDEC{get; set;}
    public Map<String,  Date> ListDateValidite{get; set;}
    public Map<String,  Boolean> ListDemandeClient{get; set;} 
    public Map<String,  Boolean> ListDemandeDistributeur{get; set;} 
    public Map<String,  Boolean> ListDemandeChefDeFile{get; set;} 
    
    public Map<String,List<String>> ListSectionCategorieAssociated{get; set;} 
         
    public Map<String,  List<String>> ListCategorieLabelAssociated {get; set;}
    public String IDDocToDelete{get; set {  IDDocToDelete = value; }  }
    ////
    public DocumentAssocie__c currentDA {get;set;}
    public Map<String,  ContentDocument  > ListAttachementDocElecPA {get;set;}
    public Map<String,  ContentDocument  > ListAttachementDocElecPAAutres {get;set;}
    public List<AggregateResult> ListDocElecPA   {get;set;} 
     
    public List<ContentDocument> listAttach  {get;set;} 
    public String dateValue {get;set;}    
    public String contIdChosen {get; set;}
   ///////////////// 
    //PageReference  
    ////////////////
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
     
 public String NomDuProjet {get;set;}
 public String IDDuProjet{get;set;}
    ///////////////// 
    //Biens 
    ////////////////
    //Completude
    public List<String>  ListSectionBiens {get; set;}
    public Map<String,List<String>> ListSectionCategorieAssociatedBiens {get; set;} 
    public Map<String,List<String>> ListCategorieLabelAssociatedBiens {get; set;}
    public String IDDuBien{get;set;}
    public String NomDuBien{get;set;}
    //Upload
    public Map<Bien_CBI__c, List<DocumentAssocie__c>> MapDocElecBiens   {get;set;}  
    public Map<Bien_CBI__c, List<String>>  MapBiensSections{get; set;} 
    public Map<Bien_CBI__c, Map<String,List<String>>>  MapBiensSectionCategorie{get; set;}
    public Map<Bien_CBI__c, Map<String,List<String>>>  MapBiensCategorieLabel{get; set;}
    
     
    public Ctrl02_GestionDocumentaire( ApexPages.StandardController controller )
    {
        String Controllertype = controller.getRecord().getSObjectType().getDescribe().getName();
        System.debug('controller ' + controller  ); 
       /*Projet */       
       if(Controllertype == 'Projet__c') {
           IDDuProjet =ApexPages.currentPage().getParameters().get('ID');
           Projet__c CProjet = [ SELECT Name  from Projet__c where id =: ApexPages.currentPage().getParameters().get('ID') ] ; 
           NomDuProjet = CProjet.Name; 
           GlobalListeBien = [ SELECT Biens__r.id, Biens__r.Name from ListeDeBien__c where Projet__c =: ApexPages.currentPage().getParameters().get('ID') order by CreatedDate desc  ];
           
           
           ListDocElecPA = getListDossiersElectroniqueAssocies('projet', (ID)ApexPages.currentPage().getParameters().get('ID'));
          
           ListSectionProjet  = setListSection('projet');
           ListSectionCategorieAssociated = setListCategorie('projet', ListSectionProjet );
           ListCategorieLabelAssociated  = setListLabel( ListSectionProjet ); 
           ListDocMandatoryUploaded = getListDocMandatoryUploaded('projet', ListCategorieLabelAssociated); 
            System.debug('ListDocMandatoryUploaded ' + ListDocMandatoryUploaded  ); 
                  
          ListDemandeNotaire = getRepertoireComplet('projet', ListCategorieLabelAssociated);
          ListDemandeDEC = getListDemandeDEC('projet', ListCategorieLabelAssociated);
          ListDateValidite = getListDateValidite('projet', ListCategorieLabelAssociated);
          ListDemandeClient = getListDemandeClient('projet', ListCategorieLabelAssociated);
          ListDemandeDistributeur = getListDemandeDistributeur('projet', ListCategorieLabelAssociated);
          ListDemandeChefDeFile =  getListDemandeChefDeFile('projet', ListCategorieLabelAssociated);  
          
         
       }
       else if(Controllertype == 'Bien_CBI__c') {  
           IDDuBien =ApexPages.currentPage().getParameters().get('ID');
           List<ListeDeBien__c> whereToGo = [ SELECT Projet__c from ListeDeBien__c where Biens__c =: ApexPages.currentPage().getParameters().get('ID') order by CreatedDate desc  ];
           
           ID idwhereToGo = (ID)whereToGo[0].Projet__c  ;
           
           Projet__c CProjet = [ SELECT Name  from Projet__c where id =: idwhereToGo ] ; 
           NomDuProjet = CProjet.Name; 
           IDDuProjet =  idwhereToGo;
          
           /* Biens */
            List<ListeDeBien__c> ListBienAttached  = [ SELECT Biens__c  from ListeDeBien__c where Projet__c =: idwhereToGo and Biens__c =: ApexPages.currentPage().getParameters().get('ID') ] ;
            List<Bien_CBI__c> ListeBiens = new  List<Bien_CBI__c>();
            for(ListeDeBien__c UnBien : ListBienAttached) {
               Bien_CBI__c Bien =      [ SELECT id,Name  from Bien_CBI__c where id =: UnBien.Biens__c ];
               NomDuBien = (String)Bien.get('Name');
               ListeBiens.add(Bien); 
            }
            if(ListeBiens.size() >= 1){   
               MapDocElecBiens = setMapBiensDossiersElectroniqueAssocies('bien', ListeBiens);
               MapBiensSections = setMapBiensSections('bien', ListeBiens);
               MapBiensSectionCategorie = setMapBienCategorie( MapBiensSections ,  ListeBiens);
               MapBiensCategorieLabel = setMapCategorieLabel(MapBiensSections, ListeBiens, MapDocElecBiens);
               Bien_CBI__c CBien =      [ SELECT id,Name  from Bien_CBI__c where id =: ApexPages.currentPage().getParameters().get('ID') ];
                             
               ListDocMandatoryUploaded =   getListDocMandatoryUploaded('bien', GlobalANTISOQLBiensCategoriesLabelAssociated);                 
            }
       }
    } 
    public   Map<String,  Boolean> getRepertoireComplet(String ObjetDuDocument, Map<String,List<String>> ListeCategorieLabel ) {
       Map<String,  Boolean  > ListRepComplet = new Map< String ,  Boolean >();  
          
       List<DocumentAssocie__c> DocumentAssocie ;
        ID recordtype;
          if(ObjetDuDocument == 'projet') {  
            recordtype    = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Projet Associe CBI').getRecordTypeId(); 
             DocumentAssocie = [SELECT id, RepertoireComplet__c , TypeDuDocument__c 
                                FROM DocumentAssocie__c 
                                where Projet__c =: ApexPages.currentPage().getParameters().get('ID')
                                and CompletudeEntete__c = true
                                and CompletudeDossier__c = true ];
          }
         else if(ObjetDuDocument == 'bien')  {
             recordtype  = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Bien CBI').getRecordTypeId();  
             DocumentAssocie = [SELECT id, RepertoireComplet__c, TypeDuDocument__c   
                                FROM DocumentAssocie__c 
                                where BienCBI__c =: ApexPages.currentPage().getParameters().get('ID')
                                and CompletudeEntete__c = true
                                and CompletudeDossier__c = true ];
         } 
       for(String Categorie : ListeCategorieLabel.keySet()) {
           for(String Label : ListeCategorieLabel.get(Categorie) ) {
                ListRepComplet.put(Label , false); 
           } 
       }
      
       
         for(Integer i = 0; i < DocumentAssocie.size()  ; i++) {
             System.debug('::getListDemandeNotaire :: ' + DocumentAssocie.get(i).TypeDuDocument__c + ' ' + DocumentAssocie.get(i).RepertoireComplet__c);
              ListRepComplet.put(DocumentAssocie.get(i).TypeDuDocument__c, DocumentAssocie.get(i).RepertoireComplet__c); 
         }  
        return ListRepComplet;
    } 
    
    public List<AggregateResult> getListDossiersElectroniqueAssocies(String ObjetDuDocument, ID IDToSearch ) { 
        
        List<AggregateResult> ListDocElec= new List<AggregateResult>();
        List<AggregateResult> ReqCurrentObject ;
        if(ObjetDuDocument == 'projet') {  
            ReqCurrentObject = [ SELECT  id, TypeDuDocument__c, Categorie__c, Section__c
                                 from DocumentAssocie__c
                                 where Projet__c =: IDToSearch 
                                 and CompletudeEntete__c = true
                                 and CompletudeDossier__c = true 
                                 group by id, TypeDuDocument__c, Categorie__c, Section__c ];  
        
         }
         else if(ObjetDuDocument == 'bien')  {
             ReqCurrentObject = [ SELECT   id, TypeDuDocument__c , Categorie__c, Section__c 
                                  from DocumentAssocie__c
                                 where BienCBI__c =:IDToSearch
                                 and CompletudeEntete__c = true
                                 and CompletudeDossier__c = true 
                                 group by id, TypeDuDocument__c , Categorie__c, Section__c   ];  
        
         } 
                                 
        System.debug('ReqCurrentObject ' + ReqCurrentObject  + ' ReqCurrentObject.size   ' + ReqCurrentObject.size()) ;     
         for(Integer i = 0; i < ReqCurrentObject.size()  ; i++) {

                    ListDocElec.add(ReqCurrentObject.get(i));
                   
         }
        return ListDocElec;
    } 
    
    public     List<String>  setListSection(String ObjetDuDocument) {
        List<String> ListSection; 
        ID recordtype ;
         if(ObjetDuDocument == 'projet') {    
                recordtype  = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Projet Associe CBI').getRecordTypeId();  
         }
         else if(ObjetDuDocument == 'bien')  {
             recordtype  = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Bien CBI').getRecordTypeId();  
         } 
         ListSection = new List<String>();
          
         for(AggregateResult results : [SELECT  Section__c  FROM CategorieDocumentAssocie__c  where RecordType.id =: recordtype GROUP BY Section__c]) {
                String Temp1 = (String)results.get('Section__c')  ;
                ListSection.add(Temp1);
         }  
         GlobalANTISSOQLLIMITListSection = ListSection; 
         return ListSection;
    }
    
    
    public Map<String,List<String>> setListCategorie(String ObjetDuDocument, List<String> Section) {
     List<String> ListCategorie ;
        ID recordtype ;
         if(ObjetDuDocument == 'projet') {    
                recordtype  = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Projet Associe CBI').getRecordTypeId();  
         }
         else if(ObjetDuDocument == 'bien')  {
             recordtype  = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Bien CBI').getRecordTypeId();  
         } 
     
     // List des Categories Doc Ass impliquées
     List<CategorieDocumentAssocie__c> catDocAssList = [SELECT  Categorie__c, Section__c  FROM CategorieDocumentAssocie__c where Section__c IN :Section and RecordType.id =: recordtype];
      
     Map<String,List<String>> ListSectionCategorie = new Map<String,List<String>>() ; 
            for(String Asection : Section) {  
                Set<String> categories = new Set<String>();
                for(CategorieDocumentAssocie__c cat : catDocAssList){
                    if(cat.Section__c == ASection){
                        categories.add(cat.Categorie__c);
                    }
                    
                }
                  ListSectionCategorie.put(Asection , new List<String>(categories)); 
            } 
       
        GlobalANTISSOQLLIMITListCategorie = ListSectionCategorie;
       return ListSectionCategorie;

     }
    
    
    
    public   Map<String,  List<String>  > setListLabel(List<String> Sections) { 
        
        Map<String,List<String>>  CategoriesLabelAssociated = new Map< String ,  List<String> >(); 
        
        // On récupère toutes les categories des sections impliquées
        Set<String> categories = new Set<String>();
        for(String Asection : Sections) {
            List<String> ListCategorie;
            ListCategorie = GlobalANTISSOQLLIMITListCategorie.get(Asection);
            for(String categorie : ListCategorie){
                categories.add(categorie);
            }
            
        }
        
        // On récupères les categories de documents associés
        List<CategorieDocumentAssocie__c> categoriesDocAssList = [SELECT  Label__c,TypedOperation__c, Categorie__c, RecordTypeId  
                                                               FROM CategorieDocumentAssocie__c 
                                                               where Categorie__c IN :categories]; 
        
        
        for(String Asection : Sections) {  
            
            String Temp1 = Asection  ;
            List<String> ListCategorie =  new List<String>();  
            ListCategorie = GlobalANTISSOQLLIMITListCategorie.get(Asection);
            
            for(String categorie : ListCategorie) { 
                 List<String> ListLabel =  new List<String>(); 
                 List<CategorieDocumentAssocie__c> results2 = new List<CategorieDocumentAssocie__c>();
                
                //On constitue la liste de Categories Doc associés sur laquelle iterer
                for(CategorieDocumentAssocie__c cat : categoriesDocAssList){
                    if(cat.Categorie__c == categorie){
                         results2.add(cat);
                    }
                    
                }
                
                 for(CategorieDocumentAssocie__c results3 : results2) { 
                         String Temp3 = (String)results3.get('Label__c')  ;
                         ListLabel.add(Temp3);  
                 }  
                 CategoriesLabelAssociated.put(categorie , ListLabel);
            }   
       }   
        return CategoriesLabelAssociated;
    }
   
         
      
    
  
    public   Map<String,  String> getListDocMandatoryUploaded(String ObjetDuDocument, Map<String,List<String>> ListeCategorieLabel) {
        Map<String,  String  > ListDocMandatoryUp = new Map< String ,  String >();  
 
         List<AggregateResult> DocumentAssocie ;
        ID recordtype;
          if(ObjetDuDocument == 'projet') {  
            recordtype    = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Projet Associe CBI').getRecordTypeId(); 
             DocumentAssocie = [SELECT count(id), TypeDuDocument__c   
                                FROM DocumentAssocie__c 
                                where Projet__c =: ApexPages.currentPage().getParameters().get('ID') 
                                and DocCharge__c = true 
                                and CompletudeDossier__c = true
                                and CompletudeEntete__c=false
                                group by TypeDuDocument__c];
              for(String Categorie : ListeCategorieLabel.keySet()) {
                   for(String Label : ListeCategorieLabel.get(Categorie) ) { 
                                System.debug('======ListeCategorieLabel  ' + Label);
                                 ListDocMandatoryUp.put(Label, '0'); 
                   } 
             }
              
          }
         else if(ObjetDuDocument == 'bien')  {
             recordtype  = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Bien CBI').getRecordTypeId();  
             DocumentAssocie = [SELECT count(id), TypeDuDocument__c 
                                FROM DocumentAssocie__c 
                                where BienCBI__c =: ApexPages.currentPage().getParameters().get('ID') 
                                and DocCharge__c = true 
                                and CompletudeDossier__c = true 
                                and CompletudeEntete__c=false
                                group by TypeDuDocument__c];
              for(String Categorie : ListeCategorieLabel.keySet()) {
                   for(String Label : ListeCategorieLabel.get(Categorie) ) { 
                                System.debug('======ListeCategorieLabel  ' + Label);
                                 ListDocMandatoryUp.put(Label, '0'); 
                   } 
             }
             
          
             
         }
         
        
        
        if(DocumentAssocie.size() >= 1) {
            System.debug('======DocumentAssocie ' + DocumentAssocie[0] );
                 for(Integer i = 0; i < DocumentAssocie.size()  ; i++) {
                      ListDocMandatoryUp.put( String.valueof(DocumentAssocie[i].get('TypeDuDocument__c')) , String.valueof(DocumentAssocie[i].get('expr0')) ); 
                 }  
            }
        return ListDocMandatoryUp;
    }

   public   Map<String,  Boolean> getListDemandeDEC(String ObjetDuDocument, Map<String,List<String>> ListeCategorieLabel) {
        Map<String,  Boolean  > ListDemandeDEC = new Map< String ,  Boolean >();  
         
         List<DocumentAssocie__c> DocumentAssocie ;
        ID recordtype;
          if(ObjetDuDocument == 'projet') {  
            recordtype    = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Projet Associe CBI').getRecordTypeId(); 
             DocumentAssocie = [SELECT id, TypeDuDocument__c, DemandeDEC__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where Projet__c =: ApexPages.currentPage().getParameters().get('ID')
                                and CompletudeEntete__c = true
                                and CompletudeDossier__c = true ];
          }
         else if(ObjetDuDocument == 'bien')  {
             recordtype  = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Bien CBI').getRecordTypeId();  
             DocumentAssocie = [SELECT id, TypeDuDocument__c, DemandeDEC__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c
                                where BienCBI__c =: ApexPages.currentPage().getParameters().get('ID')
                               and CompletudeEntete__c = true
                               and CompletudeDossier__c = true ];
         } 
           for(String Categorie : ListeCategorieLabel.keySet()) {
               for(String Label : ListeCategorieLabel.get(Categorie) ) {
                    ListDemandeDEC.put(Label , false); 
               } 
           }
     
        
       
         for(Integer i = 0; i < DocumentAssocie.size()  ; i++) {
              ListDemandeDEC.put(DocumentAssocie.get(i).TypeDuDocument__c, DocumentAssocie.get(i).DemandeDEC__c); 
         }  
        return ListDemandeDEC;
    }  
       public   Map<String,  Date> getListDateValidite(String ObjetDuDocument,  Map<String,List<String>> ListeCategorieLabel) {
        Map<String,  Date  > ListDateValidite = new Map< String ,  Date >();  
            System.debug('getListDateValidite ');   
           List<DocumentAssocie__c> DocumentAssocie ;
        ID recordtype;
          if(ObjetDuDocument == 'projet') {  
            recordtype    = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Projet Associe CBI').getRecordTypeId(); 
             DocumentAssocie = [SELECT id, TypeDuDocument__c, DateValidite__c, CompletudeDossier__c 
                                FROM DocumentAssocie__c 
                                where Projet__c =: ApexPages.currentPage().getParameters().get('ID')
                                and CompletudeEntete__c = true
                                and CompletudeDossier__c = true 
                               ];
          }
         else if(ObjetDuDocument == 'bien')  {
             recordtype  = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Bien CBI').getRecordTypeId();  
             DocumentAssocie = [SELECT id, TypeDuDocument__c, DateValidite__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where BienCBI__c =: ApexPages.currentPage().getParameters().get('ID')
                                and CompletudeEntete__c = true
                                and CompletudeDossier__c = true ];
         } 
         for(String Categorie : ListeCategorieLabel.keySet()) {
               for(String Label : ListeCategorieLabel.get(Categorie) ) { 
                         Date ladate = Date.today();
                         Date newDate = ladate.addYears(3); 
                         ListDateValidite.put(Label,newDate); 
               } 
           }
        
        
           for(Integer i = 0; i < DocumentAssocie.size()  ; i++) {
             if(DocumentAssocie.get(i).TypeDuDocument__c != null) {
                  System.debug('getListDateValidite :: ladate ' +DocumentAssocie.get(i).DateValidite__c + ' label ' + DocumentAssocie.get(i).TypeDuDocument__c);
                  ListDateValidite.put(DocumentAssocie.get(i).TypeDuDocument__c, DocumentAssocie.get(i).DateValidite__c);    
             }
         }  
        return ListDateValidite;
    } 
    public   Map<String,  Date> getListDateDeRelance(String ObjetDuDocument, Map<String,List<String>> ListeCategorieLabel) {
        Map<String,  Date  > LDateDeRelance = new Map< String ,  Date >();  
            System.debug('getListDateDeRelance__c : ' + ObjetDuDocument);   
           List<DocumentAssocie__c> DocumentAssocie ;
        ID recordtype;
          if(ObjetDuDocument == 'projet') {  
            recordtype    = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Projet Associe CBI').getRecordTypeId(); 
             DocumentAssocie = [SELECT id, TypeDuDocument__c, DateDeRelance__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where Projet__c =: ApexPages.currentPage().getParameters().get('ID')
                                and CompletudeEntete__c = true
                                and CompletudeDossier__c = true 
                               ];
          }
         else if(ObjetDuDocument == 'bien')  {
             recordtype  = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Bien CBI').getRecordTypeId();  
             DocumentAssocie = [SELECT id, TypeDuDocument__c, DateDeRelance__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where BienCBI__c =: ApexPages.currentPage().getParameters().get('ID')
                                and CompletudeEntete__c = true
                               and CompletudeDossier__c = true ];
         } 
       
            for(String Categorie : ListeCategorieLabel.keySet()) {
               for(String Label : ListeCategorieLabel.get(Categorie) ) { 
                         Date ladate = Date.today();
                         Date newDate = ladate.addYears(8);  
                         LDateDeRelance.put(Label,newDate); 
               } 
           } 
        
           for(Integer i = 0; i < DocumentAssocie.size()  ; i++) {
             if((DocumentAssocie.get(i).TypeDuDocument__c != null)&&(DocumentAssocie.get(i).DateDeRelance__c != null)) {
                  System.debug('getListDateDeRelance  :: ladate ' +DocumentAssocie.get(i).DateDeRelance__c + ' label ' + DocumentAssocie.get(i).TypeDuDocument__c);
                  LDateDeRelance.put(DocumentAssocie.get(i).TypeDuDocument__c, DocumentAssocie.get(i).DateDeRelance__c);  
             
             }
         }  
      
        return LDateDeRelance;
    } 
    public   Map<String,  Boolean> getListDemandeClient(String ObjetDuDocument,  Map<String,List<String>> ListeCategorieLabel) {
       Map<String,  Boolean  > DemandeClient = new Map< String ,  Boolean >(); 
            System.debug('getListDemandeClient');   
             List<DocumentAssocie__c> DocumentAssocie ;
        ID recordtype;
          if(ObjetDuDocument == 'projet') {  
            recordtype    = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Projet Associe CBI').getRecordTypeId(); 
             DocumentAssocie = [SELECT id, TypeDuDocument__c, DemandeClient__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where Projet__c =: ApexPages.currentPage().getParameters().get('ID')
                               and CompletudeEntete__c = true
                                and CompletudeDossier__c = true 
                               ];
          }
         else if(ObjetDuDocument == 'bien')  {
             recordtype  = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Bien CBI').getRecordTypeId();  
             DocumentAssocie = [SELECT id, TypeDuDocument__c, DemandeClient__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where BienCBI__c =: ApexPages.currentPage().getParameters().get('ID')
                               and CompletudeEntete__c = true
                                and CompletudeDossier__c = true 
                               ];
         } 
       
            for(String Categorie : ListeCategorieLabel.keySet()) {
               for(String Label : ListeCategorieLabel.get(Categorie) ) { 
                        DemandeClient.put(Label, false);
               } 
           }
         
         for(Integer i = 0; i < DocumentAssocie.size()  ; i++) {
             if(DocumentAssocie.get(i).TypeDuDocument__c != null) {
                  System.debug('DemandeClient__c ' +DocumentAssocie.get(i).DemandeClient__c + ' label ' + DocumentAssocie.get(i).TypeDuDocument__c);
                  DemandeClient.put(DocumentAssocie.get(i).TypeDuDocument__c, DocumentAssocie.get(i).DemandeClient__c);    
             }
         }  
        return DemandeClient;
    } 
    public   Map<String,  Boolean> getListDemandeDistributeur(String ObjetDuDocument,  Map<String,List<String>> ListeCategorieLabel) {
       Map<String,  Boolean  > DemandeDistributeur = new Map< String ,  Boolean >(); 
            System.debug('getListDemandeClient');   
               List<DocumentAssocie__c> DocumentAssocie ;
        ID recordtype;
          if(ObjetDuDocument == 'projet') {  
            recordtype    = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Projet Associe CBI').getRecordTypeId(); 
             DocumentAssocie = [SELECT id, TypeDuDocument__c, DemandeDistributeur__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where Projet__c =: ApexPages.currentPage().getParameters().get('ID')
                               and CompletudeEntete__c = true
                                and CompletudeDossier__c = true 
                               ];
          }
         else if(ObjetDuDocument == 'bien')  {
             recordtype  = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Bien CBI').getRecordTypeId();  
             DocumentAssocie = [SELECT id, TypeDuDocument__c, DemandeDistributeur__c, CompletudeDossier__c 
                                FROM DocumentAssocie__c 
                                where BienCBI__c =: ApexPages.currentPage().getParameters().get('ID')
                               and CompletudeEntete__c = true
                               and CompletudeDossier__c = true ];
         } 
       
        
        for(String Categorie : ListeCategorieLabel.keySet()) {
               for(String Label : ListeCategorieLabel.get(Categorie) ) { 
                        DemandeDistributeur.put(Label, false);
               } 
           }
      
         
         for(Integer i = 0; i < DocumentAssocie.size()  ; i++) {
             if(DocumentAssocie.get(i).TypeDuDocument__c != null) {
                  System.debug('DemandeDistributeur__c ' +DocumentAssocie.get(i).DemandeDistributeur__c + ' label ' + DocumentAssocie.get(i).TypeDuDocument__c);
                  DemandeDistributeur.put(DocumentAssocie.get(i).TypeDuDocument__c, DocumentAssocie.get(i).DemandeDistributeur__c);    
             }
         }  
        return DemandeDistributeur;
    } 
    public   Map<String,  Boolean> getListDemandeChefDeFile(String ObjetDuDocument,  Map<String,List<String>> ListeCategorieLabel) {
          Map<String,  Boolean  > DemandeChefDeFile = new Map< String ,  Boolean >(); 
          System.debug('getListDemandeClient'); 
          List<DocumentAssocie__c> DocumentAssocie ;
          ID recordtype;
          if(ObjetDuDocument == 'projet') {  
            recordtype    = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Projet Associe CBI').getRecordTypeId(); 
             DocumentAssocie = [SELECT id, TypeDuDocument__c, DemandeChefDeFile__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where Projet__c =: ApexPages.currentPage().getParameters().get('ID')
                                and CompletudeEntete__c = true
                               and CompletudeDossier__c = true ];
          }
         else if(ObjetDuDocument == 'bien')  {
             recordtype  = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Bien CBI').getRecordTypeId();  
             DocumentAssocie = [SELECT id, TypeDuDocument__c, DemandeChefDeFile__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where BienCBI__c =: ApexPages.currentPage().getParameters().get('ID')
                                and CompletudeEntete__c = true
                                and CompletudeDossier__c = true 
                               ];
         } 
          for(String Categorie : ListeCategorieLabel.keySet()) {
               for(String Label : ListeCategorieLabel.get(Categorie) ) { 
                        DemandeChefDeFile.put(Label, false);
               } 
           }
         
        for(Integer i = 0; i < DocumentAssocie.size()  ; i++) {
             if(DocumentAssocie.get(i).TypeDuDocument__c != null) {
                  System.debug('DemandeChefDeFile__c ' +DocumentAssocie.get(i).DemandeChefDeFile__c + ' label ' + DocumentAssocie.get(i).TypeDuDocument__c);
                  DemandeChefDeFile.put(DocumentAssocie.get(i).TypeDuDocument__c, DocumentAssocie.get(i).DemandeChefDeFile__c);    
             }
         }  
        return DemandeChefDeFile;
    } 
 
    //When user clicks upload button on Visualforce Page, perform upload/insert
    //Redirect user to newly inserted document
   
 
   
 
    //builds a picklist of user names based on their profile
            
 
    
    
   
    public PageReference DeleteFileAndDA()
    { 
        List<DocumentAssocie__c> CompletetudeToDelete = [SELECT Id, LienDuDocument__c From DocumentAssocie__c where id =: IDDocToDelete ];
        String IDCV =  (String)CompletetudeToDelete.get(0).LienDuDocument__c ;
        ContentDocument oldCV = [Select Id    
                                from ContentDocument 
                                where Id =: IDCV 
                                Order By CreatedDate Desc Limit 1];
        
        
        delete oldCV;
        delete CompletetudeToDelete;
        
        System.debug('IDDocToDelete: '+IDDocToDelete);     
        PageReference pageRef ; 

          if(TypeDobjet == 'bien') {
                pageRef  =  Page.VFP02_GestionDocumentElectroniqueBien;
            }
            else if(TypeDobjet == 'projet') {
                pageRef  = Page.VFP02_GestionDocumentElectroniqueProjet;
                
            }
      
           
            pageRef.getParameters().put('id',ApexPages.currentPage().getParameters().get('ID')); 
            return PageRef.setRedirect(True);
        
    }   
    
    
    
     public Map<Bien_CBI__c, List<DocumentAssocie__c>> setMapBiensDossiersElectroniqueAssocies(String ObjetDuDocument,  List<Bien_CBI__c> Biens) {  
        Map<Bien_CBI__c, List<DocumentAssocie__c>> MapBienDocElec = new Map<Bien_CBI__c, List<DocumentAssocie__c>>();           
        
         // Ids des biens
         Set<Id> biensIds = new Set<Id>();
         for(Bien_CBI__c Bien : Biens) {
             biensIds.add(Bien.id);
         }
         
         List<DocumentAssocie__c> docAssocList = [ SELECT Name,  LienDuDocument__c , categorie__c ,TypeDuDocument__c, DocCharge__c, CompletudeDossier__c, CategorieDocumentAssocie__c,
                                                      CategorieDocumentAssocie__r.Categorie__c, CategorieDocumentAssocie__r.Section__c, RepertoireComplet__c,
                                                      DemandeClient__c, DemandeDistributeur__c, DemandeChefDeFile__c, DateValidite__c, DemandeDEC__c, BienCBI__c                                 
                                                      from DocumentAssocie__c
                                                      where BienCBI__c IN :biensIds
                                                      and CompletudeEntete__c = true 
                                                      and CompletudeDossier__c = true   ];
         
         for(Bien_CBI__c Bien : Biens) { 
             List<DocumentAssocie__c> ListDocElec= new List<DocumentAssocie__c>();
             for(DocumentAssocie__c docAss : docAssocList){
                 if(docAss.BienCBI__c == Bien.Id){                        
                        ListDocElec.add(docAss);

                 }
                 
             }
          
        MapBienDocElec.put(Bien , ListDocElec); 
        }
        
        return MapBienDocElec;
    } 
    
    
    
    public    Map<Bien_CBI__c, List<String>>    setMapBiensSections(String ObjetDuDocument, List<Bien_CBI__c> Biens) {
        
        Map<Bien_CBI__c, List<String>>  BiensSections = new Map<Bien_CBI__c, List<String>>();
        
        Set<String> sectionsProjet = new Set<String>();
        Set<String> sectionsBien = new Set<String>();
        
        List<CategorieDocumentAssocie__c>  categoriesProjet= [SELECT  Section__c, RecordTypeId, RecordType.DeveloperName
                                                              FROM CategorieDocumentAssocie__c  
                                                              where RecordType.DeveloperName = 'CDAProjetAssocieCBI' OR RecordType.DeveloperName = 'CDABienCBI'];
        
        System.debug('NOMBRE CATEGORIES: ' + categoriesProjet.size());
        
        for(CategorieDocumentAssocie__c cat : categoriesProjet){
            if(cat.RecordType.DeveloperName == 'CDAProjetAssocieCBI'){
                   sectionsProjet.add(cat.Section__c);
            }
            else if(cat.RecordType.DeveloperName == 'CDABienCBI'){
                   sectionsBien.add(cat.Section__c);
            }
            
        }
        
        
        for(Bien_CBI__c Bien : Biens) { 
            List<String> ListSection; 

             if(ObjetDuDocument == 'projet') {    
					BiensSections.put(Bien , new List<String>(sectionsProjet)); 
             }
             else if(ObjetDuDocument == 'bien')  {
  					BiensSections.put(Bien , new List<String>(sectionsBien));
             } 

        }
        return BiensSections;
    }
    
        
    public  Map<Bien_CBI__c, Map<String,List<String>>> setMapBienCategorie(  Map<Bien_CBI__c, List<String>>   Sections, List<Bien_CBI__c> Biens) {
        
      Map<Bien_CBI__c, Map<String,List<String>>>  BiensSectionCategorie = new Map<Bien_CBI__c, Map<String,List<String>>>();
     
        // Ensemble de categories
        Set<String> categoriesSet = new Set<String>();
        for(List<String> ASections :  Sections.values()) { 
        	categoriesSet.addAll(ASections);
        }
        
         // List des Categories Doc Ass impliquées
     List<CategorieDocumentAssocie__c> catDocAssList = [SELECT  Categorie__c, Section__c  FROM CategorieDocumentAssocie__c where Section__c IN :categoriesSet];
    
        
      for(Bien_CBI__c Bien : Biens) { 
         List<String> ListCategorie ;
         Map<String,List<String>> ListSectionCategorie = new Map<String,List<String>>() ; 
                    for(String Asection : Sections.get(Bien)) {  
                		Set<String> categories = new Set<String>();
                		for(CategorieDocumentAssocie__c cat : catDocAssList){
                    		if(cat.Section__c == ASection){
                        		categories.add(cat.Categorie__c);
                    		}
                    
                	}

                  ListSectionCategorie.put(Asection , new List<String>(categories)); 
            }  
         BiensSectionCategorie.put(Bien , ListSectionCategorie);   
      }
      GlobalANTISSOQLLIMITBiensSectionCategorie = BiensSectionCategorie; 
      return   BiensSectionCategorie ;
     }  
    
    
    
    
    
     public   Map<Bien_CBI__c, Map<String,  List<String>  >> setMapCategorieLabel(Map<Bien_CBI__c, List<String>>Sections, List<Bien_CBI__c> Biens, Map<Bien_CBI__c, List<DocumentAssocie__c>> ListBienDoc ) { 
        Map<Bien_CBI__c, Map<String,List<String>>>  BiensCategorieLabel = new Map<Bien_CBI__c, Map<String,List<String>>>();
     
        for(Bien_CBI__c Bien : Biens) {
            GlobalANTISOQLBiensCategoriesLabelAssociated = new Map< String ,  List<String> >(); 
            Map<String,List<String>>  CategoriesLabelAssociated = new Map< String ,  List<String> >(); 
           
            for(String Asection : Sections.get(Bien)) {  
                String Temp1 = Asection  ;
                Map<String,List<String>> SectionCategorie = GlobalANTISSOQLLIMITBiensSectionCategorie.get(Bien); 
                List<String> ListCategorie =  new List<String>();     
                ListCategorie = SectionCategorie.get(Asection);
                List<DocumentAssocie__c> ListeLabelNonTrier = ListBienDoc.get(Bien);
                for(String results2 : ListCategorie) {  
                     List<String> ListLabel =  new List<String>();  
                    for(DocumentAssocie__c Label : ListeLabelNonTrier){
                        if(Label.get('categorie__c') == results2 ){
                            System.debug('Catégorie ' + Label.get('categorie__c')  + ' Label ' + (String)Label.get('TypeDuDocument__c'));   
                            ListLabel.add((String)Label.get('TypeDuDocument__c'));
                        }
                    }  
                     CategoriesLabelAssociated.put(results2 ,ListLabel );
                     GlobalANTISOQLBiensCategoriesLabelAssociated.put(results2 ,ListLabel ); 
                }  
            
           }  
           BiensCategorieLabel.put(Bien , CategoriesLabelAssociated);
        }
        return BiensCategorieLabel;
    }
    
    public PageReference GoToDetails()
        {  
            System.debug('IDObjectToAttach ' + IDObjectToAttach + ' TypeDobjet : ' + TypeDobjet + ' TypeParam From GestionDocumentaire: '+CategorieParam + 'SectionParam : ' + SectionParam);
            PageReference pageRef;
  
            if(TypeDobjet == 'bien') {
                
                pageRef  = Page.VF02_GDEBienAvancee;
                   
            }
            else if(TypeDobjet == 'projet') {
                pageRef  = Page.VF02_GDEProjetAvancee;
            }
           
            pageRef.getParameters().put('id',IDObjectToAttach);  
            pageRef.getParameters().put('TypeDobjet',TypeDobjet); 
            pageRef.getParameters().put('SectionParam',SectionParam); 
            pageRef.getParameters().put('CategorieParam',CategorieParam);
            pageRef.getParameters().put('RepertoireParam',RepertoireParam); 
            return PageRef.setRedirect(True);
        } 
   
     public PageReference GoToUploadVF()
        {  
            System.debug('TypeDobjet : ' + TypeDobjet + ' RepertoireParam  From GestionDocumentaire: '+RepertoireParam + 'DAIDParam : ' + DAIDParam);
            PageReference pageRef;

            if(TypeDobjet == 'bien') {
                pageRef  = Page.VFP02_UploadFileBien;
                   
            }
            else if(TypeDobjet == 'projet') {
                pageRef  = Page.VFP02_UploadFilePA;
                
                
            }
        
            
            pageRef.getParameters().put('id',IDObjectToAttach); 
            pageRef.getParameters().put('DAIDParam',DAIDParam); 
            pageRef.getParameters().put('TypeDobjet',TypeDobjet); 
            pageRef.getParameters().put('SectionParam',SectionParam); 
            pageRef.getParameters().put('CategorieParam',CategorieParam);
            pageRef.getParameters().put('RepertoireParam',RepertoireParam); 
             
           
            return PageRef.setRedirect(True);
        } 

}