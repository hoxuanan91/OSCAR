/*************************************************************************************
* @date 22/05/2019
* @description Controller de la page Visualforce LLD_FormulaireLeadReseau
* Nom de la classe - LLD_FileUploadController
*************************************************************************************/
public class LLD_FileUploadController {
    /**
    * Variables du controller
    * *****/
    public Lead lead{get;set;}
    public transient String base64;
    public Integer fileCurrentNumber {get; set;}
    public Integer fileTotalNumber {get; set;}
    public String fileName {get; set;}
    public boolean saved {get; set;}
    public Boolean isChecked {get; set;}
    
    public LLD_FileUploadController(ApexPages.StandardController controller) {
        //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Pour les banques : BP Nord, BP Sud et les caisses CE Haut de France, CE Ile de France. Veuillez saisir vos Leads dans MonExpert'));
        this.lead = (Lead)controller.getrecord();
        this.saved = false;
        this.isChecked = false;
    }
    
    /**
    * @date 22/05/2019
    * @description get the base64 attribute value
    * *****/
    public String getBase64()
    {
        return base64;
    }
    
    /**
    * @date 22/05/2019
    * @description set the base64 attribute
    * @param: a string base64 encoded
    * *****/
    public void setbase64(String base64)
    {
        this.base64 = base64;
    }

    public void checkEntries(){
        this.isChecked = true;
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Vos informations ont été validées mais ne sont pas encore trasnmises à BPCE LEASE. Pour se faire cliquer sur le bouton ENVOYER ; vous pouvez au préalable ajouter votre/vos pièce(s) jointe(s).'));
    }
    
    /**
    * @date 22/05/2019
    * @description Ajoute les documents et insère le lead
    * *****/
    public PageReference saveFile()
    {        
        System.debug('LEAD LEAD LEAD : ' + lead.OwnerId);
		try{   
           	lead.LeadSource = 'Réseau';
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule = true; 
            lead.setOptions(dmlOpts);
            
            if(!saved){
                insert(lead);
                this.saved = true;
            }
            
            //Si il n'y a aucun document à uploader
            if(fileName != ' ' && base64 != ' '){
                //Création du content document
                ContentVersion cv = new ContentVersion();
                cv.Title = fileName;
                cv.PathOnClient = fileName;
                cv.VersionData = EncodingUtil.base64Decode(base64);
                cv.IsMajorVersion = true;
                Insert cv;
                
                //Récupère les Content Documents
                Id conDoc = [SELECT ContentDocumentId, Id, lastmodifieddate FROM ContentVersion WHERE Id =:cv.Id][0].ContentDocumentId;
                
                //Création du ContentDocumentLink 
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = lead.Id;
                cdl.ContentDocumentId = conDoc;
                cdl.shareType = 'V';
                Insert cdl;
                
                System.debug(cdl);
            }
            
            //Si il n'y a pas plus de documents à uploader
            if(fileCurrentNumber == fileTotalNumber){
                PageReference vfSucess = new PageReference('/apex/LL_NetworkForm_Success');
                vfSucess.setRedirect(true);
                return vfSucess;
            }
        } catch (DMLException e) {
            system.debug(e);
        }

        return null;
    }
}