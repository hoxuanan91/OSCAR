public with sharing  class Ctrl02_CompletudeDossier {
     Map<String,List<String>> GlobalANTISSOQLLIMITListCategorie{get; set;} 
 
     public List<ListeDeBien__c> GlobalListeBien {get; set;} 

/////////////////////////////////////////////        
      Id memberId;
    public Map<String,  Boolean> ListDocMandatory  {get; set;}
    private  Map<String,  Boolean> ListDocMandatoryBeforeCompletude  {get; set;}
    public Map<String,  Boolean> ListDocMandatoryUploaded {get; set;}
    public List<String>  ListSectionProjet {get; set;}
    
     public Map<String,  Boolean> ListDemandeNotaireBeforeCompletude {get; set;}
     public Map<String,  Boolean> ListDemandeDECBeforeCompletude    {get; set;}
     public Map<String,  Date> ListDateValiditeBeforeCompletude {get; set;}
     public Map<String,  Date> ListDateDeRelanceBeforeCompletude   {get; set;}  
     public Map<String,  Boolean> ListDemandeClientBeforeCompletude {get; set;}
     public Map<String,  Boolean> ListDemandeDistributeurBeforeCompletude {get; set;}
     public Map<String,  Boolean> ListDemandeChefDeFileBeforeCompletude {get; set;}
                 
    public Map<String,  Boolean> ListDemandeNotaire  {get; set;}
    public Map<String,  Boolean> ListDemandeDEC{get; set;}
    public Map<String,  Date> ListDateValidite{get; set;}
    public Map<String,  Boolean> ListDemandeClient{get; set;} 
    public Map<String,  Boolean> ListDemandeDistributeur{get; set;} 
    public Map<String,  Boolean> ListDemandeChefDeFile{get; set;} 
    public Map<String,  Date> ListDateDeRelance{get; set;} 
    public Map<String,List<String>> ListSectionCategorieAssociated{get; set;} 
         
    public Map<String,  List<String>> ListCategorieLabelAssociated {get; set;}
    public String IDDocToDelete{get; set {  IDDocToDelete = value; }  }
    //// 

    ///////////////////////
    ///////////////// 
    //Biens 
    ////////////////

    public Map<String,List<String>> ListSectionCategorieAssociatedBiens {get; set;}
    public List<String>  ListSectionBiens {get; set;}
    public Map<String,  List<String>> ListCategorieLabelAssociatedBiens {get; set;}
    public List<ListeDeBien__c> GlobalProjet{get; set;}
    ///////////////// 
    //PageReference  
    ////////////////
    public String TypeDobjet{get; set {  TypeDobjet = value; }  }
    
    
    public Ctrl02_CompletudeDossier( ApexPages.StandardController controller )
    {
         
        String Controllertype = controller.getRecord().getSObjectType().getDescribe().getName();
        System.debug('controller ' + controller  );  
        list<String> TypeDexception = new list<String>();
        List<Opportunity> PAS  = new  List<Opportunity>();  
       /*Projet */       
       if(Controllertype == 'Projet__c') { 
       GlobalListeBien = [ SELECT Biens__c, Biens__r.Name from ListeDeBien__c where Projet__c =: ApexPages.currentPage().getParameters().get('ID') order by CreatedDate desc  ];
       ListSectionProjet  = setListSection('projet'); 
           
           ///Il n'y a pas forcement une opportunitée associée à un projet, utilisation du Try Catch pour ne pas arrêter le processus.
           //Si une opportunitée est liée on récupère ses spécificitées sinon on affiche tout

            try {
                PAS = [   SELECT ID,TypeDOperation__c, Copropriete__c, VEFA__c 
                          from Opportunity
                          where NomDuProjet__c =: ApexPages.currentPage().getParameters().get('ID')
                      ]; 
            } catch(DmlException e) {
                PAS = null;

            } catch(Exception e) {
                PAS = null;
            }  
       }
       /* Biens */
       else  if(Controllertype == 'Bien_CBI__c') {
        
           ListSectionBiens = setListSection('bien');
           ListSectionCategorieAssociatedBiens = setListCategorie(  ListSectionBiens, 'bien');
           
           List<ListeDeBien__c> ProjetsFromCurentBien = [ SELECT Projet__c from ListeDeBien__c where Biens__c =: ApexPages.currentPage().getParameters().get('ID') order by CreatedDate desc  ];
            try {
                PAS = [   SELECT ID,TypeDOperation__c, Copropriete__c, VEFA__c 
                          from Opportunity
                          where NomDuProjet__c =: ProjetsFromCurentBien[0].Projet__c
                      ]; 
            } catch(DmlException e) {
                PAS = null;

            } catch(Exception e) {
                PAS = null;
            }     
       }
          if(PAS.size() == NULL){
          }
              
        if(PAS.size() ==  0){
                TypeDexception.add('Copropriété+VEFA');
                TypeDexception.add('Acquisition et Travaux+VEFA');
                TypeDexception.add('Acquisition et Travaux');
                TypeDexception.add('Acquisition et Travaux+Copropriété');
                TypeDexception.add('VEFA');
                TypeDexception.add('Copropriété');
                TypeDexception.add('Construction');
            } 
             else if(PAS.size() > 1){
               TypeDexception.add('Copropriété+VEFA');
                TypeDexception.add('Acquisition et Travaux');
                TypeDexception.add('Acquisition et Travaux+VEFA');
                TypeDexception.add('Acquisition et Travaux+Copropriété');
                TypeDexception.add('VEFA');
                TypeDexception.add('Copropriété');
                TypeDexception.add('Construction'); 
            }
            else if(PAS.size() == 1){
               TypeDexception.add((String)PAS[0].get('TypeDOperation__c'));
                
                if((PAS[0].get('TypeDOperation__c') == 'Acquisition et Travaux')&&(PAS[0].get('VEFA__c') == true)) {
                      TypeDexception.add('Acquisition et Travaux+VEFA');
                } 
                if((PAS[0].get('TypeDOperation__c') == 'Acquisition et Travaux')&&(PAS[0].get('Copropriete__c') == true)) {
                      TypeDexception.add('Acquisition et Travaux+Copropriété');
                } 
                if((PAS[0].get('Copropriete__c') == true)&&(PAS[0].get('VEFA__c') == true))  {
                    TypeDexception.add('Copropriété+VEFA');
                }   
                if(PAS[0].get('VEFA__c') == true) {
                    TypeDexception.add('VEFA');
                }
                 if(PAS[0].get('Copropriete__c') == true) {
                    TypeDexception.add('Copropriété');
                } 
                
            }
        
        if(Controllertype == 'Projet__c') { 
               ListSectionCategorieAssociated = setListCategorie( ListSectionProjet, 'projet' );
               ListCategorieLabelAssociated  = setListLabel( ListSectionProjet, TypeDexception, 'projet' ); 
               ListDocMandatory = getListDocMandatory('projet', ListCategorieLabelAssociated);
               ListDocMandatoryBeforeCompletude = getListDocMandatory('projet', ListCategorieLabelAssociated); 
               ListDocMandatoryUploaded = getListDocMandatoryUploaded('projet', ListCategorieLabelAssociated);                  
               
               ListDemandeNotaireBeforeCompletude = getListDemandeNotaire('projet', ListCategorieLabelAssociated);
               ListDemandeNotaire = getListDemandeNotaire('projet', ListCategorieLabelAssociated);
              
               ListDemandeDECBeforeCompletude = getListDemandeDEC('projet', ListCategorieLabelAssociated);
               ListDemandeDEC = getListDemandeDEC('projet', ListCategorieLabelAssociated);           
               
               ListDateValiditeBeforeCompletude = getListDateValidite('projet', ListCategorieLabelAssociated);
               ListDateValidite = getListDateValidite('projet', ListCategorieLabelAssociated);
              
               ListDateDeRelanceBeforeCompletude = getListDateDeRelance('projet', ListCategorieLabelAssociated);           
               ListDateDeRelance = getListDateDeRelance('projet', ListCategorieLabelAssociated);
                   
               ListDemandeClientBeforeCompletude = getListDemandeClient('projet', ListCategorieLabelAssociated);    
               ListDemandeClient = getListDemandeClient('projet', ListCategorieLabelAssociated);
               
               ListDemandeDistributeurBeforeCompletude = getListDemandeDistributeur('projet', ListCategorieLabelAssociated);
               ListDemandeDistributeur = getListDemandeDistributeur('projet', ListCategorieLabelAssociated);
               
               ListDemandeChefDeFileBeforeCompletude  =  getListDemandeChefDeFile('projet', ListCategorieLabelAssociated); 
               ListDemandeChefDeFile =  getListDemandeChefDeFile('projet', ListCategorieLabelAssociated); 
        }
        else  if(Controllertype == 'Bien_CBI__c') {

           System.debug('TypeDexception : ' + TypeDexception );
           ListCategorieLabelAssociatedBiens  = setListLabel( ListSectionBiens, TypeDexception, 'bien' );
           ListDocMandatory = getListDocMandatory('bien', ListCategorieLabelAssociatedBiens);
           ListDocMandatoryBeforeCompletude = getListDocMandatory('bien', ListCategorieLabelAssociatedBiens);
           
           ListDocMandatoryUploaded = getListDocMandatoryUploaded('bien',ListCategorieLabelAssociatedBiens);
          
           ListDemandeNotaireBeforeCompletude = getListDemandeNotaire('bien', ListCategorieLabelAssociatedBiens);
           ListDemandeNotaire = getListDemandeNotaire('bien', ListCategorieLabelAssociatedBiens);
          
           ListDemandeDECBeforeCompletude = getListDemandeDEC('bien', ListCategorieLabelAssociatedBiens);
           ListDemandeDEC = getListDemandeDEC('bien', ListCategorieLabelAssociatedBiens);           
           
           ListDateValiditeBeforeCompletude = getListDateValidite('bien', ListCategorieLabelAssociatedBiens);
           ListDateValidite = getListDateValidite('bien', ListCategorieLabelAssociatedBiens);
          
           ListDateDeRelanceBeforeCompletude = getListDateDeRelance('bien', ListCategorieLabelAssociatedBiens);           
           ListDateDeRelance = getListDateDeRelance('bien', ListCategorieLabelAssociatedBiens);
               
           ListDemandeClientBeforeCompletude = getListDemandeClient('bien', ListCategorieLabelAssociatedBiens);    
           ListDemandeClient = getListDemandeClient('bien', ListCategorieLabelAssociatedBiens);
           
           ListDemandeDistributeurBeforeCompletude = getListDemandeDistributeur('bien', ListCategorieLabelAssociatedBiens);
           ListDemandeDistributeur = getListDemandeDistributeur('bien', ListCategorieLabelAssociatedBiens);
           
           ListDemandeChefDeFileBeforeCompletude  =  getListDemandeChefDeFile('bien', ListCategorieLabelAssociatedBiens); 
           ListDemandeChefDeFile =  getListDemandeChefDeFile('bien', ListCategorieLabelAssociatedBiens);  
      
           
            GlobalProjet = [ SELECT  Projet__c, Projet__r.Name 
                               from ListeDeBien__c 
                               where Biens__c =: ApexPages.currentPage().getParameters().get('ID') 
                               order by CreatedDate desc  ];
        }
       
    } 
 /* Projet Associé */   
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
      
       return ListSection;
    }
    
    public Map<String,List<String>> setListCategorie( List<String> Section, String ObjetDuDocument) {
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
    
    public   Map<String,  List<String>  > setListLabel(List<String> Sections,  list<String> TypesDexception, String ObjetDuDocument) { 
        Map<String,List<String>>  CategoriesLabelAssociated = new Map< String ,  List<String> >(); 
        ID recordtype;
        
          if(ObjetDuDocument == 'projet') {  
            recordtype    = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Projet Associe CBI').getRecordTypeId();
         
          }
         else if(ObjetDuDocument == 'bien')  {
            recordtype  = Schema.SObjectType.CategorieDocumentAssocie__c.getRecordTypeInfosByName().get('CDA Bien CBI').getRecordTypeId();  
         }
        
        
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
                                                               where Categorie__c IN :categories and RecordTypeId =: recordtype];            
        
        
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
   
                     if(results3.get('TypedOperation__c') == 'Acquisition'){ 
                         String Temp3 = (String)results3.get('Label__c')  ;
                         ListLabel.add(Temp3);
                     } 
                     if(TypesDexception.size() > 1 ){ 
                         for(String TypeDexception : TypesDexception) { 
                                  String TypesOperation = (String)results3.get('TypedOperation__c') + ';'; 
                                  List<String> TypedOperation = new List<String>();
                                  TypedOperation = TypesOperation.split(';');
                               
                                  if( TypedOperation.size() == 1) {

                                        if((TypeDexception != 'Acquisition')&&(TypeDexception == TypedOperation.get(0))) {                                      
                                           String Temp3 = (String)results3.get('Label__c')  ;
                                           ListLabel.add(Temp3);  
                                        } 
                                   }   

                         }                         
                     }                     
                 }  
                 CategoriesLabelAssociated.put(categorie , ListLabel);
            }  
      
       }   
        return CategoriesLabelAssociated;
    }
         
      
    
    public   Map<String,  Boolean> getListDocMandatory(String ObjetDuDocument, Map<String,List<String>> ListeCategorieLabel) {
        Map<String,  Boolean  > ListDocMandatoryC = new Map< String ,  Boolean >();  

        List<DocumentAssocie__c> DocumentAssocie ;
          if(ObjetDuDocument == 'projet') {  

            DocumentAssocie  = [SELECT id, TypeDuDocument__c, DocCharge__c, CompletudeDossier__c, Projet__c 
                                FROM DocumentAssocie__c where Projet__c =: ApexPages.currentPage().getParameters().get('ID')
                                and CompletudeEntete__c = true ];
          }
         else if(ObjetDuDocument == 'bien')  {
             
            DocumentAssocie  = [SELECT id, TypeDuDocument__c, DocCharge__c, CompletudeDossier__c, Projet__c  
                                FROM DocumentAssocie__c 
                                where BienCBI__c =: ApexPages.currentPage().getParameters().get('ID')
                                and CompletudeEntete__c = true ]; 
         } 
         for(String Categorie : ListeCategorieLabel.keySet()) {
           for(String Label : ListeCategorieLabel.get(Categorie) ) {
                ListDocMandatoryC.put(Label, false);
           } 
         }       
         for(Integer i = 0; i < DocumentAssocie.size()  ; i++) { 
              ListDocMandatoryC.put(DocumentAssocie.get(i).TypeDuDocument__c, DocumentAssocie.get(i).CompletudeDossier__c); 
         }  
        return ListDocMandatoryC;
    }
    
    
    
    public   Map<String,  Boolean> getListDocMandatoryUploaded(String ObjetDuDocument, Map<String,List<String>> ListeCategorieLabel) {
        Map<String,  Boolean  > ListDocMandatoryUp = new Map< String ,  Boolean >();  
       Map<String,  Boolean  > ListDocMandatoryC = new Map< String ,  Boolean >();  
         List<DocumentAssocie__c> DocumentAssocie ;

          if(ObjetDuDocument == 'projet') {  

             DocumentAssocie = [SELECT id, TypeDuDocument__c, DocCharge__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where Projet__c =: ApexPages.currentPage().getParameters().get('ID')
                                and CompletudeEntete__c = true];
          }
         else if(ObjetDuDocument == 'bien')  {
 
             DocumentAssocie = [SELECT id, TypeDuDocument__c, DocCharge__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where BienCBI__c =: ApexPages.currentPage().getParameters().get('ID')
                                and CompletudeEntete__c = true];
         }
         for(String Categorie : ListeCategorieLabel.keySet()) {
           for(String Label : ListeCategorieLabel.get(Categorie) ) {
                ListDocMandatoryUp.put(Label, false);
           } 
         }
         
        
         for(Integer i = 0; i < DocumentAssocie.size()  ; i++) {
              ListDocMandatoryUp.put(DocumentAssocie.get(i).TypeDuDocument__c, DocumentAssocie.get(i).DocCharge__c); 
         }  
        return ListDocMandatoryUp;
    }
   public   Map<String,  Boolean> getListDemandeNotaire(String ObjetDuDocument, Map<String,List<String>> ListeCategorieLabel ) {
       Map<String,  Boolean  > ListDemandeNotaire = new Map< String ,  Boolean >();  
       List<DocumentAssocie__c> DocumentAssocie ;

          if(ObjetDuDocument == 'projet') {  

             DocumentAssocie = [
                                SELECT id, TypeDuDocument__c, DemandeNotaire__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where Projet__c =: ApexPages.currentPage().getParameters().get('ID') 
                                and CompletudeEntete__c = true 
                                ];
          }
         else if(ObjetDuDocument == 'bien')  {

             DocumentAssocie = [SELECT id, TypeDuDocument__c, DemandeNotaire__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c
                                where BienCBI__c =: ApexPages.currentPage().getParameters().get('ID')  
                                and CompletudeEntete__c = true ];
         } 
       for(String Categorie : ListeCategorieLabel.keySet()) {
           for(String Label : ListeCategorieLabel.get(Categorie) ) {
                ListDemandeNotaire.put(Label , false); 
           } 
       }
      
       
         for(Integer i = 0; i < DocumentAssocie.size()  ; i++) {
              ListDemandeNotaire.put(DocumentAssocie.get(i).TypeDuDocument__c, DocumentAssocie.get(i).DemandeNotaire__c); 
         }  
        return ListDemandeNotaire;
    }
    
    
   public   Map<String,  Boolean> getListDemandeDEC(String ObjetDuDocument, Map<String,List<String>> ListeCategorieLabel) {
        Map<String,  Boolean  > ListDemandeDEC = new Map< String ,  Boolean >();  
         
         List<DocumentAssocie__c> DocumentAssocie ;

          if(ObjetDuDocument == 'projet') {  

             DocumentAssocie = [SELECT id, TypeDuDocument__c, DemandeDEC__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where Projet__c =: ApexPages.currentPage().getParameters().get('ID')
                                and CompletudeEntete__c = true ];
          }
         else if(ObjetDuDocument == 'bien')  {

             DocumentAssocie = [SELECT id, TypeDuDocument__c, DemandeDEC__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where BienCBI__c =: ApexPages.currentPage().getParameters().get('ID') 
                               and CompletudeEntete__c = true];
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

          if(ObjetDuDocument == 'projet') {  
 
             DocumentAssocie = [SELECT id, TypeDuDocument__c, DateValidite__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where Projet__c =: ApexPages.currentPage().getParameters().get('ID') 
                                and CompletudeEntete__c = true];
          }
         else if(ObjetDuDocument == 'bien')  {
 
             DocumentAssocie = [SELECT id, TypeDuDocument__c, DateValidite__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where BienCBI__c =: ApexPages.currentPage().getParameters().get('ID') 
                               and CompletudeEntete__c = true];
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
                  ListDateValidite.put(DocumentAssocie.get(i).TypeDuDocument__c, DocumentAssocie.get(i).DateValidite__c);    
             }
         }  
        return ListDateValidite;
    } 
    public   Map<String,  Date> getListDateDeRelance(String ObjetDuDocument, Map<String,List<String>> ListeCategorieLabel) {
        Map<String,  Date  > LDateDeRelance = new Map< String ,  Date >();  
           List<DocumentAssocie__c> DocumentAssocie ;

          if(ObjetDuDocument == 'projet') {  

             DocumentAssocie = [SELECT id, TypeDuDocument__c, DateDeRelance__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where Projet__c =: ApexPages.currentPage().getParameters().get('ID') 
                                and CompletudeEntete__c = true];
          }
         else if(ObjetDuDocument == 'bien')  {

             DocumentAssocie = [SELECT id, TypeDuDocument__c, DateDeRelance__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c where 
                                BienCBI__c =: ApexPages.currentPage().getParameters().get('ID') 
                                and CompletudeEntete__c = true];
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
                  LDateDeRelance.put(DocumentAssocie.get(i).TypeDuDocument__c, DocumentAssocie.get(i).DateDeRelance__c);  
             
             }
         }  
      
        return LDateDeRelance;
    } 
    
    
    
    public   Map<String,  Boolean> getListDemandeClient(String ObjetDuDocument,  Map<String,List<String>> ListeCategorieLabel) {
       Map<String,  Boolean  > DemandeClient = new Map< String ,  Boolean >(); 
            System.debug('getListDemandeClient');   
             List<DocumentAssocie__c> DocumentAssocie ;

          if(ObjetDuDocument == 'projet') {  

             DocumentAssocie = [SELECT id, TypeDuDocument__c, DemandeClient__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where Projet__c =: ApexPages.currentPage().getParameters().get('ID') 
                               and CompletudeEntete__c = true];
          }
         else if(ObjetDuDocument == 'bien')  {
  
             DocumentAssocie = [SELECT id, TypeDuDocument__c, DemandeClient__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c
                                where BienCBI__c =: ApexPages.currentPage().getParameters().get('ID')
                               and CompletudeEntete__c = true];
         } 
       
            for(String Categorie : ListeCategorieLabel.keySet()) {
               for(String Label : ListeCategorieLabel.get(Categorie) ) { 
                        DemandeClient.put(Label, false);
               } 
           }
         
         
         for(Integer i = 0; i < DocumentAssocie.size()  ; i++) {
             if(DocumentAssocie.get(i).TypeDuDocument__c != null) {
                  DemandeClient.put(DocumentAssocie.get(i).TypeDuDocument__c, DocumentAssocie.get(i).DemandeClient__c);    
             }
         }  
        return DemandeClient;
    } 
    
    
    public   Map<String,  Boolean> getListDemandeDistributeur(String ObjetDuDocument,  Map<String,List<String>> ListeCategorieLabel) {
       Map<String,  Boolean  > DemandeDistributeur = new Map< String ,  Boolean >(); 
            System.debug('getListDemandeClient');   
               List<DocumentAssocie__c> DocumentAssocie ;

          if(ObjetDuDocument == 'projet') {  

             DocumentAssocie = [SELECT id, TypeDuDocument__c, DemandeDistributeur__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where Projet__c =: ApexPages.currentPage().getParameters().get('ID')
                               and CompletudeEntete__c = true];
          }
         else if(ObjetDuDocument == 'bien')  {

             DocumentAssocie = [SELECT id, TypeDuDocument__c, DemandeDistributeur__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where BienCBI__c =: ApexPages.currentPage().getParameters().get('ID') 
                               and CompletudeEntete__c = true];
         } 
       
        
        for(String Categorie : ListeCategorieLabel.keySet()) {
               for(String Label : ListeCategorieLabel.get(Categorie) ) { 
                        DemandeDistributeur.put(Label, false);
               } 
           }
        
         for(Integer i = 0; i < DocumentAssocie.size()  ; i++) {
             if(DocumentAssocie.get(i).TypeDuDocument__c != null) {
                  DemandeDistributeur.put(DocumentAssocie.get(i).TypeDuDocument__c, DocumentAssocie.get(i).DemandeDistributeur__c);    
             }
         }  
        return DemandeDistributeur;
    } 
    
    
    public   Map<String,  Boolean> getListDemandeChefDeFile(String ObjetDuDocument,  Map<String,List<String>> ListeCategorieLabel) {
          Map<String,  Boolean  > DemandeChefDeFile = new Map< String ,  Boolean >(); 
          List<DocumentAssocie__c> DocumentAssocie ;

          if(ObjetDuDocument == 'projet') {  

             DocumentAssocie = [SELECT id, TypeDuDocument__c, DemandeChefDeFile__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where Projet__c =: ApexPages.currentPage().getParameters().get('ID') 
                               and CompletudeEntete__c = true];
          }
         else if(ObjetDuDocument == 'bien')  {

             DocumentAssocie = [SELECT id, TypeDuDocument__c, DemandeChefDeFile__c, CompletudeDossier__c  
                                FROM DocumentAssocie__c 
                                where BienCBI__c =: ApexPages.currentPage().getParameters().get('ID') 
                               and CompletudeEntete__c = true];
         } 
          for(String Categorie : ListeCategorieLabel.keySet()) {
               for(String Label : ListeCategorieLabel.get(Categorie) ) { 
                        DemandeChefDeFile.put(Label, false);
               } 
           }
      
        for(Integer i = 0; i < DocumentAssocie.size()  ; i++) {
             if(DocumentAssocie.get(i).TypeDuDocument__c != null) {
                  DemandeChefDeFile.put(DocumentAssocie.get(i).TypeDuDocument__c, DocumentAssocie.get(i).DemandeChefDeFile__c);    
             }
         }  
        return DemandeChefDeFile;
    } 
    
     public PageReference SaveCompletude()
        {   
              
              List<String> aList = new List<String>(); 
              aList.addAll(ListDocMandatory.keySet()); 
              aList.sort();
             
              // Préparation des Selects en base
              // Categorie Doc Associé 
              Map< String, CategorieDocumentAssocie__c> catDocAssocMap = new Map< String, CategorieDocumentAssocie__c>();             
              List<CategorieDocumentAssocie__c> catDocAssocList = [Select Id, Categorie__c, Section__c, Label__c 
                                                                FROM CategorieDocumentAssocie__c 
                                                                WHERE Label__c IN :aList];  
              for(CategorieDocumentAssocie__c catDocAss : catDocAssocList){
                
                  catDocAssocMap.put(catDocAss.Label__c, catDocAss);
                  
               }
            
      
              // Documents Associés à récupérer dans la boucle for
              Map< String, DocumentAssocie__c> docAssocMap = new Map< String, DocumentAssocie__c>();    
              Map< String, DocumentAssocie__c> docAssocMap_Bien = new Map< String, DocumentAssocie__c>();   
              List <DocumentAssocie__c> docAssocList_ListBien = new List< DocumentAssocie__c>();
              
              List<DocumentAssocie__c> docAssocList_Projet = [SELECT ID, TypeDuDocument__c, LienDuDocument__c 
                                                       		  FROM DocumentAssocie__c
                                                              WHERE Projet__c =: ApexPages.currentPage().getParameters().get('ID')
                                                       		      AND TypeDuDocument__c IN :aList
                                                                  AND CompletudeEntete__c = true];
            
              List<DocumentAssocie__c> docAssocList_Bien = [ SELECT ID , DemandeNotaire__c, DemandeDEC__c, DateValidite__c, TypeDuDocument__c, LienDuDocument__c 
                                                             FROM DocumentAssocie__c
                                                             WHERE BienCBI__c =:ApexPages.currentPage().getParameters().get('ID')
                                                                    AND TypeDuDocument__c IN :aList
                                                                    AND CompletudeEntete__c = true]; 
            
              List<DocumentAssocie__c> docAssocToInsert = new List<DocumentAssocie__c>();
              List<DocumentAssocie__c> docAssocToUpdate = new List<DocumentAssocie__c>();            
              
              for(DocumentAssocie__c docAss : docAssocList_Projet){
                
                  docAssocMap.put(docAss.TypeDuDocument__c, docAss);
                  
              }
            
            for(DocumentAssocie__c docAssBien : docAssocList_Bien){
                
                  docAssocMap_Bien.put(docAssBien.TypeDuDocument__c, docAssBien);
                  
              }
            
            // Projet
            List<ListeDeBien__c> Projet = [ SELECT Projet__c  
                                            FROM ListeDeBien__c 
                                            WHERE Biens__c =: ApexPages.currentPage().getParameters().get('ID')  
                                          		ORDER BY CreatedDate DESC];
            
            Set<Id> biensIds = new Set<Id>();
            List<ListeDeBien__c> ListeDesBiens = new List<ListeDeBien__c>();
            if(Projet.size() != 0){
                //Biens
            	ListeDesBiens =   [ SELECT Biens__c  
                                                     FROM ListeDeBien__c 
                                                     WHERE Projet__c =: Projet[0].Projet__c  
                                                    	   AND Biens__c =: ApexPages.currentPage().getParameters().get('ID') ];
                
                // On récupère les ids des biens contenues dans la liste de ListeDeBien
                for(ListeDeBien__c listeBien : ListeDesBiens){
                     biensIds.add(listeBien.Biens__c);
                }
            }
              
            docAssocList_ListBien = [   SELECT ID, BienCBI__c, TypeDuDocument__c, CompletudeEntete__c
                                               FROM DocumentAssocie__c
                                               WHERE BienCBI__c IN :biensIds
                                               AND TypeDuDocument__c IN :aList
                                               AND CompletudeEntete__c = true];

            List<DocumentAssocie__c> CompletetudeToDelete = new List<DocumentAssocie__c>();
            
              for(String a: aList){ 
               
              if((ListDocMandatory.get(a)==true)&&(ListDocMandatoryBeforeCompletude.get(a)==false)){
                //CategorieDocumentAssocie__c  CDA = [Select Id, Categorie__c, Section__c from CategorieDocumentAssocie__c where Label__c =:  a]; 
                   CategorieDocumentAssocie__c  CDA = catDocAssocMap.get(a);
                   if(TypeDobjet == 'projet') {  
                       DocumentAssocie__c   CheckIfNewDocExist ;
                              try {

                                  CheckIfNewDocExist = docAssocMap.get(a);
                                                       
                              } catch(DmlException e) {
                                CheckIfNewDocExist = null;
                              } catch(Exception e) {
                                 CheckIfNewDocExist = null;
                              }  
                               
                              if(CheckIfNewDocExist  == null) {
                                        DocumentAssocie__c DA = new DocumentAssocie__c();   
                                        ID recordtype = Schema.SObjectType.DocumentAssocie__c.getRecordTypeInfosByName().get('Document Associé Projet').getRecordTypeId();                                  
                                        DA.Projet__c = ApexPages.currentPage().getParameters().get('ID'); 
                                        DA.DocCharge__c = false;
                                        DA.CompletudeDossier__c = true;
                                        DA.TypeDuDocument__c = a;  
                                        DA.CategorieDocumentAssocie__c = CDA.ID ;  
                                        DA.categorie__c = CDA.Categorie__c ;
                                        DA.DemandeNotaire__c = ListDemandeNotaire.get(a);
                                        DA.DemandeDEC__c = ListDemandeDEC.get(a);
                                        DA.DateValidite__c = ListDateValidite.get(a);
                                        DA.DateDeRelance__c = ListDateDeRelance.get(a);
                                        DA.DemandeClient__c =  ListDemandeClient.get(a);
                                        DA.DemandeDistributeur__c =  ListDemandeDistributeur.get(a);
                                        DA.DemandeChefDeFile__c =  ListDemandeChefDeFile.get(a); 
                                        DA.RecordTypeId = recordtype;
                                        DA.CompletudeEntete__c = true;
                                        DA.Section__c= CDA.Section__c ;
                                  
                                        docAssocToInsert.add(DA);
                              }
                              else {
                                   CheckIfNewDocExist.CompletudeDossier__c = true;

                                   docAssocToUpdate.add(CheckIfNewDocExist);
                               }
                      }
                      else if(TypeDobjet == 'bien')  {
                        if(Projet.size() >= 1) {
                       
                         for(ListeDeBien__c Bien : ListeDesBiens) {     
                              DocumentAssocie__c   CheckIfNewDocExist ;
                              try {

                                  for(DocumentAssocie__c docAss : docAssocList_ListBien){
                                      if(docAss.BienCBI__c == Bien.Biens__c && docAss.TypeDuDocument__c == a){
                                             CheckIfNewDocExist = docAss;
                                      }
                                  }
                                  
                              } catch(DmlException e) {
                                CheckIfNewDocExist = null;
                              } catch(Exception e) {
                                 CheckIfNewDocExist = null;
                              }  
                               
                              if(CheckIfNewDocExist  == null) {
                                    DocumentAssocie__c DA = new DocumentAssocie__c(); 
                                    DA.BienCBI__c = Bien.Biens__c;  
                                                                           
                                    ID recordtype = Schema.SObjectType.DocumentAssocie__c.getRecordTypeInfosByName().get('Document Associé Bien').getRecordTypeId();  
                                    DA.DocCharge__c = false;
                                    DA.CompletudeDossier__c = true;
                                    DA.TypeDuDocument__c = a;  
                                    DA.CategorieDocumentAssocie__c = CDA.ID ;  
                                    DA.categorie__c = CDA.Categorie__c ;
                                    DA.DemandeNotaire__c = ListDemandeNotaire.get(a);
                                    DA.DemandeDEC__c = ListDemandeDEC.get(a);
                                    DA.DateValidite__c = ListDateValidite.get(a);
                                    DA.DateDeRelance__c = ListDateDeRelance.get(a);
                                    DA.DemandeClient__c =  ListDemandeClient.get(a);
                                    DA.DemandeDistributeur__c =  ListDemandeDistributeur.get(a);
                                    DA.DemandeChefDeFile__c =  ListDemandeChefDeFile.get(a); 
                                    DA.RecordTypeId = recordtype;
                                    DA.CompletudeEntete__c = true;
                                    DA.Section__c= CDA.Section__c ;

                                    docAssocToInsert.add(DA);
                              }
                              else {
                                   CheckIfNewDocExist.CompletudeDossier__c = true;
                                   docAssocToUpdate.add(CheckIfNewDocExist);
                               }                           
                           } 
                          }
                     }    
                  }
                  if(  ((ListDocMandatoryBeforeCompletude.get(a)==true)&&(ListDocMandatory.get(a)==true))&&(
                      (ListDemandeNotaireBeforeCompletude.get(a)!=ListDemandeNotaire.get(a))||
                            (ListDemandeDECBeforeCompletude.get(a)!=ListDemandeDEC.get(a))|| 
                              (ListDateValiditeBeforeCompletude.get(a)!=ListDateValidite.get(a))|| 
                                (ListDateDeRelanceBeforeCompletude.get(a)!=ListDateDeRelance.get(a))|| 
                                  (ListDemandeClientBeforeCompletude.get(a)!=ListDemandeClient.get(a))|| 
                                    (ListDemandeDistributeurBeforeCompletude.get(a)!=ListDemandeDistributeur.get(a))|| 
                                      (ListDemandeChefDeFileBeforeCompletude.get(a)!=ListDemandeChefDeFile.get(a))
                  
                  )) {
                     DocumentAssocie__c  DA = new DocumentAssocie__c();
                      if(TypeDobjet == 'projet') {   
                     
                          DA = docAssocMap.get(a);  

                      }
                      else if(TypeDobjet == 'bien')  {

                           try {
                          
                            docAssocMap_Bien.get(a);
                                
                              } catch(DmlException e) {
                                DA = null;
                                ListDocMandatoryBeforeCompletude.put(a,false);
                              } catch(Exception e) {
                                 DA = null;
                                 ListDocMandatoryBeforeCompletude.put(a,false);
                              }  
                     }
                       
                      if(DA != null) {                       
                        DA.DemandeNotaire__c = ListDemandeNotaire.get(a);
                        DA.DemandeDEC__c = ListDemandeDEC.get(a);
                        DA.DateValidite__c = ListDateValidite.get(a);
                        DA.DateDeRelance__c = ListDateDeRelance.get(a);
                        DA.DemandeClient__c =  ListDemandeClient.get(a);
                        DA.DemandeDistributeur__c =  ListDemandeDistributeur.get(a);
                        DA.DemandeChefDeFile__c =  ListDemandeChefDeFile.get(a); 

                        docAssocToUpdate.add(DA);
                      }
                  }
                       
                  if(  (ListDocMandatoryBeforeCompletude.get(a)==true)&&(ListDocMandatory.get(a)==false)&&(ListDocMandatoryUploaded.get(a)==false)){ 
              
                      if(TypeDobjet == 'projet') {  
                        
                          for(DocumentAssocie__c da : docAssocList_Projet){
                              if(da.TypeDuDocument__c == a){
                                   da.CompletudeDossier__c = false;
                                   CompletetudeToDelete.add(da);
                              }
                          }

                      }
                      else if(TypeDobjet == 'bien')  {
                        
                          for(DocumentAssocie__c da : docAssocList_Bien){
                              if(da.TypeDuDocument__c == a){
                                   da.CompletudeDossier__c = false;
                                   CompletetudeToDelete.add(da);
                              }
                          }

                     }

                      ListDocMandatoryUploaded.put(a, false);

                 }
                 if((ListDocMandatoryBeforeCompletude.get(a)==true)&&(ListDocMandatory.get(a)==false)&&(ListDocMandatoryUploaded.get(a)==true)){ 

                      if(TypeDobjet == 'projet') {  

                          for(DocumentAssocie__c da : docAssocList_Projet){
                              if(da.TypeDuDocument__c == a){
                                   da.CompletudeDossier__c = false;
                                   CompletetudeToDelete.add(da);
                              }
                          }
                         
                      }
                      else if(TypeDobjet == 'bien')  {

                        for(DocumentAssocie__c da : docAssocList_Bien){
                              if(da.TypeDuDocument__c == a){
                                   da.CompletudeDossier__c = false;
                                   CompletetudeToDelete.add(da);
                              }
                          }
                     
                      }
                        ListDocMandatoryUploaded.put(a, false);
                    
                 }
           
        } // End for
            
        update CompletetudeToDelete;
        update docAssocToUpdate;
        insert docAssocToInsert;

        PageReference pageRef;    

        if(TypeDobjet == 'projet') {  
                    pageRef  = Page.VFP02_CompletudeDossierProjet;
         }
         else if(TypeDobjet == 'bien')  {  
                    pageRef  = Page.VFP02_CompletudeDossierBien;
         }
        
         
            pageRef.getParameters().put('id',ApexPages.currentPage().getParameters().get('ID')); 

            return PageRef.setRedirect(True);

    }
    
    public List<DocumentAssocie__c> getListDossiersElectroniqueAssocies(String ObjetDuDocument) { 
        
        List<DocumentAssocie__c> ListDocElec= new List<DocumentAssocie__c>();
        List<DocumentAssocie__c> ReqCurrentObject ;
        if(ObjetDuDocument == 'projet') {  
            ReqCurrentObject = [ SELECT Name,  LienDuDocument__c , TypeDuDocument__c, DocCharge__c, CompletudeDossier__c, CategorieDocumentAssocie__c,
                                                      CategorieDocumentAssocie__r.Categorie__c, CategorieDocumentAssocie__r.Section__c
                                                      from DocumentAssocie__c
                                                      where Projet__c =:ApexPages.currentPage().getParameters().get('ID') ];  
        
         }
         else if(ObjetDuDocument == 'bien')  {
             ReqCurrentObject = [ SELECT Name,  LienDuDocument__c , TypeDuDocument__c, DocCharge__c, CompletudeDossier__c, CategorieDocumentAssocie__c,
                                                      CategorieDocumentAssocie__r.Categorie__c, CategorieDocumentAssocie__r.Section__c
                                                      from DocumentAssocie__c
                                                      where BienCBI__c =:ApexPages.currentPage().getParameters().get('ID') ];  
        
         }

         for(Integer i = 0; i < ReqCurrentObject.size()  ; i++) {
                    DocumentAssocie__c TemDE = new DocumentAssocie__c();
                    TemDE =  ReqCurrentObject.get(i);
   
                    ListDocElec.add(TemDE);

         }
        return ListDocElec;
    } 
   
    public PageReference DeleteFileAndDA(){ 
        List<DocumentAssocie__c> CompletetudeToDelete = [SELECT Id, LienDuDocument__c From DocumentAssocie__c where id =: IDDocToDelete ];
        String IDCV =  (String)CompletetudeToDelete.get(0).LienDuDocument__c ;
        ContentDocument oldCV = [Select Id    
                                from ContentDocument 
                                where Id =: IDCV 
                                Order By CreatedDate Desc Limit 1];
        
        
        delete oldCV;
        delete CompletetudeToDelete;
   
         PageReference pageRef; 
        
        if(TypeDobjet == 'projet') {  
                    pageRef  = Page.VFP02_GestionDocumentElectroniqueProjet;
         }
         else if(TypeDobjet == 'bien')  {  
                    pageRef  = Page.VFP02_GEstionDocumentElectroniqueBien;
         }
         
         
            pageRef.getParameters().put('id',ApexPages.currentPage().getParameters().get('ID')); 
            return PageRef.setRedirect(True);
        
    }   
   
    
        
}