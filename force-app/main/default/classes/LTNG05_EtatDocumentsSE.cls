public class LTNG05_EtatDocumentsSE {

    /******************************************************************************************
    * @description : Permet de récupérer les informations nécessaires pour le composant
    * @param : String oppId
    * @return: DataWrapper 
    * @createdBy: ACL
    * @createdDate : 01/10/2020
    * @example :
    ******************************************************************************************/
    
    @AuraEnabled
    public static DataWrapper doInit_APEX(String oppId){
        List<DocumentSE__c> docs = [SELECT Id, DateDemande__c, DateSignature__c, Opportunity__c, Signataire__c, Signataire__r.Prenom__c, Signataire__r.Nom__c, RecordType.Name, TECH_Color__c, EtatDocument__c FROM DocumentSE__c WHERE Opportunity__c =: oppId ORDER BY CreatedDate];
        
        List<InformationsSignataire__c> signatairesAssurance = [SELECT Id, Type_de_document__c, Nom__c, Prenom__c, Opportunity__c FROM InformationsSignataire__c WHERE Type_de_document__c = 'Assurance' AND Opportunity__c =: oppId];
        
        return new DataWrapper(docs, signatairesAssurance);
    }

    /*****************************************************************************
    * @description : Wrapper for all data used in the component
    * @param : List<DocumentSE__c> docsSE     
    * @return : Object DataWrapper 
    * @createdBy : ACL
    * @createdDate : 01/10/2020
    * @example :
    *****************************************************************************/
    
    public class DataWrapper{
        @AuraEnabled public List<DocumentWrapper> docsWP;
        @AuraEnabled public List<SignataireWrapper> signWP;
        
        public DataWrapper(List<DocumentSE__c> docsSE, List<InformationsSignataire__c> signSE){
            this.docsWP = new List<DocumentWrapper>();
            this.signWP = new List<SignataireWrapper>();

            for(DocumentSE__c dSE : docsSE){
                this.docsWP.add(new DocumentWrapper(dSE));
            }
            
            for(InformationsSignataire__c sSE : signSE){
               	this.signWP.add(new SignataireWrapper(sSE));
            }
        }
    }

    /*****************************************************************************
    * @description : Wrapper SignataireSE
    * @param :      
    * @return : Object DocumentWrapper 
    * @createdBy : ACL
    * @createdDate : 01/10/2020
    * @example :
    *****************************************************************************/
    
    public class DocumentWrapper{
        @AuraEnabled public DocumentSE__c docSE;
        @AuraEnabled public String dateToUse;
        @AuraEnabled public Boolean hasSignataire;

        public DocumentWrapper(DocumentSE__c docSE){
            this.docSE = docSE;
            this.dateToUse = docSE.DateSignature__c != null ? String.valueOf(docSE.DateSignature__c) : (docSE.DateDemande__c != null ? String.valueOf(docSE.DateDemande__c) : '');
            this.hasSignataire = docSE.Signataire__c != null ? true : false;
        }
    }
    
    /*****************************************************************************
    * @description : Wrapper DocumentSE
    * @param :      
    * @return : Object SignataireWrapper 
    * @createdBy : ACL
    * @createdDate : 01/10/2020
    * @example :
    *****************************************************************************/
    
    public class SignataireWrapper{
        @AuraEnabled public InformationsSignataire__c signSE;
        @AuraEnabled public String dateToUse;

        public SignataireWrapper(InformationsSignataire__c signSE){
            this.signSE = signSE;
            this.dateToUse = String.valueOf(System.today());
        }
    }
}