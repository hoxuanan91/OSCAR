public without sharing class Ctrl11_FormulaireClientGarant {
    public Account account{get;set;}
    public String soussigne{get;set;}
    public String qualiteDe{get;set;}
    public Boolean accept {get;set;}
    public Boolean refuse {get;set;}
    public Boolean isClient {get;set;}
    public String commentaire {get;set;}
    public Boolean alreadyRecords {get;set;}
    public String recordTypeId {get;set;}
    public String acceptInfo {get;set;}

    public Ctrl11_FormulaireClientGarant(ApexPages.StandardController controller) {
        Id accountId        = Apexpages.currentPage().getParameters().get('id');
        this.account        = [SELECT Id, Name, N_SIREN__c, Report_de_loyers__c, Covid_date_debut_report__c, Apporteur__r.Name, Usage_formulaire_COVID19__c, (SELECT Id, RecordTypeId FROM InformationsReport__r) FROM Account WHERE Id = :accountId LIMIT 1];
		this.recordTypeId 	= UTL_Utils.getRecordTypeID(String.valueOf(Information_Report__c.getSObjectType()), Apexpages.currentPage().getParameters().get('type'));
        
        if(this.account.InformationsReport__r.size() == 0 || (this.account.InformationsReport__r.size() < 2 && this.account.InformationsReport__r[0].RecordTypeId != this.recordTypeId)){       
            this.accept         = true;
            this.refuse         = false;
            this.soussigne      = '';
            this.qualiteDe      = '';
            this.commentaire    = '';
            this.acceptInfo     = this.account.Usage_formulaire_COVID19__c;
            this.isClient       = Apexpages.currentPage().getParameters().get('type') == 'Client' ? true : false;
            this.alreadyRecords = false;
        }
        else{
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Une réponse a déjà été apportée pour cette société'));
            this.alreadyRecords = true;
        }
    }

    public PageReference sendForm(){
        
        this.account = [SELECT Id, Name, N_SIREN__c, Report_de_loyers__c, Covid_date_debut_report__c, Apporteur__r.Name, (SELECT Id, RecordTypeId FROM InformationsReport__r) FROM Account WHERE Id = :this.account.Id LIMIT 1];
        
        if(this.account.InformationsReport__r.size() == 0 || (this.account.InformationsReport__r.size() < 2 && this.account.InformationsReport__r[0].RecordTypeId != this.recordTypeId)){
            if(Apexpages.currentPage().getParameters().get('type') != null){
            insert new Information_Report__c(Accepte_le_report__c   = accept,
                                            En_qualite_de__c        = qualiteDe,
                                            Je_soussigne__c         = soussigne,
                                            TiersRepresente__c      = account.Id,
                                            Commentaire__c          = commentaire,
                                            RecordTypeId			= this.recordTypeId);

            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Merci pour ces informations'));
            this.alreadyRecords = true;
            }
            else{
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Un problème est survenu veuillez contacter un administrateur'));
            }
        }
        else{
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Une réponse a déjà été apportée pour cette société'));
            this.alreadyRecords = true;
        } 
        return null;
    }
}