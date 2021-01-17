public without sharing class Ctrl14_FormulaireFinanciabilite {
	public Contract contract{get;set;}
    public String repondant{get;set;}
    public String nomClient{get;set;}
    public String reponseBanque{get;set;}
    public String siren{get;set;}
    public String contractNumber{get;set;}
    public String dateFinContrat{get;set;}
    public String qualiteDe{get;set;}
    public Boolean accept {get;set;}
    public Boolean refuse {get;set;}
    public Boolean alreadyRecord {get;set;}

    public Ctrl14_FormulaireFinanciabilite(ApexPages.StandardController controller) {
        Id contractId        = Apexpages.currentPage().getParameters().get('id');
        this.contract        = [SELECT Id, 
                                 		Name,
                                		NomClient__c,
                                		Account.N_SIREN__c,
                                		ContractNumber,
                                		Date_fin_contrat_actualisee__c,
                                		NomPrenomRepondant__c,
                                		En_qualite_de__c,
                                		ReponseBanque__c
                                 FROM Contract 
                                 WHERE Id = :contractId LIMIT 1];
        
        if(this.contract != null){
            this.nomClient = this.contract.NomClient__c;
            this.siren = this.contract.Account.N_SIREN__c;
            this.contractNumber = this.contract.ContractNumber;
            this.dateFinContrat = String.valueOf(this.contract.Date_fin_contrat_actualisee__c);
        }
    }
    
    public PageReference onChangeAPEX(){
        
        String value = Apexpages.currentPage().getParameters().get('choice');

        this.reponseBanque = value;
            
        return null;
    }

    public PageReference sendForm(){
        
        this.contract = [SELECT Id, 
                                 Name,
                                 NomClient__c,
                                 Account.N_SIREN__c,
                                 ContractNumber,
                                 Date_fin_contrat_actualisee__c,
                                 NomPrenomRepondant__c,
                                 En_qualite_de__c,
                                 ReponseBanque__c
                          FROM Contract 
                          WHERE Id = :this.contract.Id LIMIT 1];
        
        if(this.contract.Id != null){
            
            this.contract.NomPrenomRepondant__c = this.repondant;
            this.contract.En_qualite_de__c = this.qualiteDe;
            this.contract.ReponseBanque__c = this.reponseBanque == null ? 'Inconnue' : this.reponseBanque;
            
            update this.contract;

            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Merci pour ces informations'));
        }      
        return null;
    }
}