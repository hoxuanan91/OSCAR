public class BatchEnvoiEmailAccordClient implements Database.Batchable<SObject>, Database.Stateful{
    
    private Id templateId;
    private String typeEnvoi;
    private String modelEmailTempl;
    private String societeDeGestion;
    
    public BatchEnvoiEmailAccordClient(String modelEmailTemplInput, String typeEnvoiInput, String societeDeGestionInput) {
        
        System.debug('####### Param 1 : '+ modelEmailTemplInput);
        System.debug('####### Param 2 : '+ typeEnvoiInput);
        System.debug('####### Param 3 : '+ societeDeGestionInput);

        this.templateId = [SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE DeveloperName =: modelEmailTemplInput].Id;
        this.typeEnvoi = TypeEnvoiInput;
        this.modelEmailTempl = modelEmailTemplInput;
        this.societeDeGestion=societeDeGestionInput;
    }
     
   public Database.QueryLocator start(Database.BatchableContext bc) {
        
        //CHECKER EXCLUDES
        String query = 'SELECT Id, Name, AccountId, Account.Email__c, EmailsEnvoyes__c, Usage_modele_email_CBI_COVID_19__c, Covid_cbi_ref_envoi1__c';
        query += ' FROM Contract WHERE RecordType.developerName=\'CBIDossier\' AND Account.Email__c != null AND Usage_modele_email_CBI_COVID_19__c =: ModelEmailTempl ';
        query += 'AND EmailsEnvoyes__c excludes (:typeEnvoi) AND Covid_cbi_ref_envoi1__c != null AND Accord_refus__c = null AND Emails_motifs_d_exclusion__c = null AND SocieteDeGestion__c =: societeDeGestion';
        
        System.debug('####### Query : ' + query);

        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Contract> scope){
        
        Map<Id,Contract> contractById = new Map<Id,Contract>();
        Map<Id, Id> contractIdByAccountId = new Map<Id, Id>();
        Map<String, List<Contract>> contractsByRefName = new Map<String, List<Contract>>();

        for(Contract c : scope){
            contractById.put(c.Id, c);
            String ref = '';

            if(c.Covid_cbi_ref_envoi1__c != null){
                ref = c.Covid_cbi_ref_envoi1__c.LEFT(9);
            }

            if(contractsByRefName.get(ref) == null){
                contractsByRefName.put(ref, new List<Contract>());
                contractsByRefName.get(ref).add(c);
                
            } else {                
                contractsByRefName.get(ref).add(c);
            }

            if(c.Name == ref){
                contractIdByAccountId.put(c.AccountId, c.Id);
            }
        }     
        
        Id fromAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'bal-lease-reamenagementscbi@bpce.fr'].Id;

        Map<Id, Id> contactIdByContractId = new Map<Id, Id>();
        Map<Id, Id> contactIdByAccountId = new Map<Id, Id>();
        List<Contact> contactsToCreate = new List<Contact>();

        String contactRecordTypeId = UTL_Utils.getRecordTypeID(String.valueOf(Contact.getSobjectType()), 'Contact_oscar');

        for(Account a : [SELECT Id, Name, Email__c, (SELECT Id, AccountId, Name, Email FROM Contacts WHERE RecordTypeId =: contactRecordTypeId) FROM Account WHERE Id IN :contractIdByAccountId.keySet()]){
            Boolean accountHasSameEmailThanContact=false;
            if(!a.Contacts.isEmpty()){
                for(Contact con : a.Contacts){
                    if(a.Email__c == con.Email){
                        contactIdByAccountId.put(a.Id, con.Id);
                        contactIdByContractId.put(contractIdByAccountId.get(a.Id), con.Id);
                        accountHasSameEmailThanContact = true;
                        break;
                    }
                }  
           } 
           if(accountHasSameEmailThanContact == false){
                    
                Contact contact= new Contact(AccountId = a.Id,
                                            LastName = 'contact envoi mail Report',
                                            Email = a.Email__c,
                                            RecordTypeId = contactRecordTypeId);

                contactsToCreate.add(contact);
                contactIdByAccountId.put(a.Id, null);
            } 
        }
        
        if(!contactsToCreate.isEmpty()){
            insert contactsToCreate;

            for(Contact c : contactsToCreate){
                if(contactIdByAccountId.get(c.AccountId) == null){
                    contactIdByContractId.put(contractIdByAccountId.get(c.AccountId), c.Id);
                }
            }
        }
        
        System.debug('########## ContactsToCreate' + contactsToCreate);

        List<Messaging.SingleEmailMessage> emailToSend = new List <Messaging.SingleEmailMessage>();

        for(Id cId : contactIdByContractId.keySet()){
            System.debug('################# ContactIdByContractId.get(cId)'+ contactIdByContractId.get(cId));
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

            message.saveAsActivity = false;
            message.targetObjectId = contactIdByContractId.get(cId);
            
            message.whatId = cId;
            message.templateId = this.templateId;
            message.setOrgWideEmailAddressId(fromAddress);
            message.setSaveAsActivity(true);
            
            emailToSend.add(message);

            System.debug('########### message '+ message);
            
        }
        
        if(!test.isRunningTest()){
            System.debug(emailToSend);
            //Messaging.sendEmail(emailToSend);
        } 

        List<Contract> contractsToUpdate = new List<Contract>();
        Set<Id> contractsIdSucceed = new Set<Id>();
		
        System.debug(contractsByRefName);
        for(String ref : contractsByRefName.keySet()){
            for(Contract ca : contractsByRefName.get(ref)){
                ca.EmailsEnvoyes__c += typeEnvoi;
                contractsToUpdate.add(ca);
            }
        }
	
        System.debug(contractsToUpdate);
        if(!contractsToUpdate.isEmpty()){
            //update contractsToUpdate;
        }
            
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}