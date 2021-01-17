public without sharing class Ctrl12_FormulaireCovidCBI {
    public List<ContractWrapper> contractsWrapper {get;set;}
    public Account account {get;set;}
    public String templateId {get;set;}
    public String soussigne {get;set;}
    public String qualiteDe {get;set;}
    public Boolean allContractsResponded {get;set;}
    public String contractRecordTypeId {get;set;}
    public String acceptInfo {get;set;}
    public String typeDePool {get;set;}
    public String accountId {get;set;}
    public String duree {get;set;}
    public String mention {get;set;}
    public Boolean isNext {get;set;}
    public Boolean thirdValue {get;set;}

    public Ctrl12_FormulaireCovidCBI(ApexPages.StandardController controller) {
        this.accountId              = Apexpages.currentPage().getParameters().get('id');
        this.contractRecordTypeId   = UTL_Utils.getRecordTypeID(String.valueOf(Contract.getSObjectType()), 'CBIDossier');
        this.typeDePool             = Apexpages.currentPage().getParameters().get('type');
        this.duree                  = Apexpages.currentPage().getParameters().get('duree');
        this.templateId             = Apexpages.currentPage().getParameters().get('templateId');
        this.contractsWrapper       = new List<ContractWrapper>();
        this.isNext                 = false;

        System.debug(this.contractRecordTypeId);

        this.account  = [SELECT Id,
                                Email__c,
                                (SELECT Id,
                                        Name,
                                        Je_soussigne__c,
                                        En_qualite_de__c,
                                        Date_de_reponse_tiers__c,
                                        Accord_refus__c,
                                        SocieteDeGestion__c,
                                        Nom_du_dossier__c,
                                        Account.Name,
                                        PaiementEcheancesReportees__c,
                                        COVID_19_Hotel_Restaurant__c
                                FROM Contracts
                                WHERE RecordTypeId = :this.contractRecordTypeId 
                                AND COVID19__c = 'O' 
                                AND Type_de_pool__c = :this.typeDePool
                                AND DureeRestanteContrat__c = :duree
                                AND Date_de_reponse_tiers__c = null
                                AND Emails_motifs_d_exclusion__c = null
                                AND (NOT Status LIKE 'Terminé%')
                                ORDER BY Name)
                            FROM Account
                            WHERE Id = :this.accountId];

        
        if(this.account.contracts.size() != 0){     

            Boolean isHotel = false;

            for(Contract c : this.account.contracts){
                if(c.COVID_19_Hotel_Restaurant__c)
                    isHotel = true;
            }

            if(isHotel && this.typeDePool == 'Non'){
                this.thirdValue = true;
            }
            else {
                this.thirdValue = false;
            }
            
            this.mention = 'Représentant dûment habilité de la société ' + this.account.contracts[0].Account.Name + 
            ', a pris connaissance des mesures exceptionnelles d\'accompagnement dans le cadre des circonstances de la COVID-19 proposées par ' + this.account.contracts[0].SocieteDeGestion__c +
            '. La réponse au présent formulaire engage définitivement et irrévocablement le crédit-preneur pour faire et valoir ce que de droit.';
            
            for(Contract c : this.account.contracts){
                this.contractsWrapper.add(new ContractWrapper(c));
            }
            System.debug(contractsWrapper);
        }
        else{
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Une réponse a déjà été apportée pour ces contrats'));
            this.allContractsResponded = true;
        }
    }

    public PageReference nextStep(){
        this.isNext = true;
        return null;
    }

    public PageReference onChangeAPEX(){
        System.debug('onChangeAPEX');

        Boolean isOption = false;
        String name = Apexpages.currentPage().getParameters().get('contractName');
        String value = Apexpages.currentPage().getParameters().get('choice');

        if(name.contains('arChoice')){
            name = name.remove('arChoice');
        }
        else if(name.contains('optionChoice')){
            name = name.remove('optionChoice');
            isOption = true;
        }

        System.debug(name);
        System.debug(isOption);

        for(ContractWrapper cW : this.contractsWrapper){
            if(cW.contract.Name == name){
                if(!isOption){
                    cW.arChoice = value;
                }
                else{
                    cW.optionChoice = value;
                }
            }
            System.debug(cW);
        }

        System.debug(name);
        System.debug(value);

        return null;
    }

    public PageReference sendForm(){

        List<Contract> contractsToUpdate = new List<Contract>();
        Boolean needAnswer = false;

        if(this.contractsWrapper.size() != 0){
            for(ContractWrapper cW : this.contractsWrapper){
                cW.contract.Je_soussigne__c = this.soussigne;
                cW.contract.En_qualite_de__c = this.qualiteDe;
                cW.contract.Date_de_reponse_tiers__c = System.today();

                System.debug(cW.arChoice);
                System.debug(cW.optionChoice);

                if(cW.arChoice != '' && cW.arChoice != 'Aucun'){
                    System.debug('ArChoice if');
                    cW.contract.Accord_refus__c = cW.arChoice;
                }
                else{
                    System.debug('ArChoice else');
                    needAnswer = true;
                    break;
                }

                if(this.duree == 'COURT' && cW.arChoice == 'Accord'){
                    if(cW.optionChoice != 'Aucun' && cW.optionChoice != ''){
                        System.debug('Optionchoice if');
                        cW.contract.PaiementEcheancesReportees__c = cW.optionChoice;
                    }
                    else{
                        System.debug('ArChoice else');
                        needAnswer = true;
                        break;
                    }
                }

                contractsToUpdate.add(cW.contract);
            }

            if(!needAnswer){
                update contractsToUpdate;
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Merci pour ces informations'));
                sendAcknowledgment();
                this.allContractsResponded = true;
            }
            else{
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Veuillez apporter un réponse pour chaque ligne s\'il vous plait'));
            }
        }
        else{
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Un problème est survenu veuillez contacter un administrateur'));
            this.allContractsResponded = true;
        } 
        return null;
    }

    public void sendAcknowledgment(){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        EmailTemplate acknowledgment = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Id =: this.templateId];

        Id fromAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'bal-lease-reamenagementscbi@bpce.fr'].Id;

        String body = 'Cher(e) Client(e),\n\n';
        body += 'Le ' + System.today().format() + ', vous avez été destinataire d’une communication émanant de notre Direction relative aux mesures exceptionnelles d’accompagnement de nos clients afin de soutenir leur activité dans les circonstances actuelles.\n\n';
        body += 'Suite à cette communication, vous nous avez fait part :\n';

        for(ContractWrapper cW : this.contractsWrapper){
            body += '- De votre ' + cW.contract.Accord_refus__c + ' pour le contrat ' + cW.contract.Name + ' : ' + cW.contract.Nom_du_dossier__c + (cW.contract.Accord_refus__c == 'Accord' ? (' avec l\'option ' + cW.contract.PaiementEcheancesReportees__c) : '') + '.\n';
        }

        body += '\nNous avons bien pris en compte votre réponse.\n';
        body += 'Je vous prie d\'agréer, Madame, Monsieur, nos salutations distinguées.\n\n';
        body += 'Cordialement,\n';
        body += 'BPCE Lease.\n';

        System.debug(body);

        List<String> emailAdressess = new List<String>();
        emailAdressess.add(this.account.Email__c);
        
        mail.setToAddresses(emailAdressess);
        mail.setSubject(acknowledgment.Subject);
        mail.setPlainTextBody(body);
        mail.setWhatId(this.account.Id);
        mail.setOrgWideEmailAddressId(fromAddress);
        mail.setSaveAsActivity(true);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }

    public class ContractWrapper{

        public Contract contract {get; set;}
        public String arChoice {get; set;}
        public String optionChoice {get; set;}

        public ContractWrapper(Contract contract){
            this.contract       = contract;
            this.arChoice       = '';
            this.optionChoice   = '';         
        }
    }
}