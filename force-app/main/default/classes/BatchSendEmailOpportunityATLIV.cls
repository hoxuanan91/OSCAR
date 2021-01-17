public class BatchSendEmailOpportunityATLIV implements Database.Batchable<SObject>, Database.Stateful {
    
    private String tmpId;
    
    public BatchSendEmailOpportunityATLIV() {
        tmpId=[Select id from EmailTemplate where DeveloperName = 'PJAME34EmailPhaseatliv2' Limit 1].Id;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        EmailConfiguration__mdt conf = [select MaxDate__c, MinDate__c from EmailConfiguration__mdt where DeveloperName = 'AT_LIV'];
        String query;
        if(Test.isRunningTest()) {
            query = 'select Id,IntervenantReseaux__r.Email, EmailDelegRegionalRenseigne__c,Dossier__c, Owner.EmailDelegRegionale__c,IntervenantReseaux__c, EmailEnvoyes__c from Opportunity';
        } else {
            query = 'select Id,IntervenantReseaux__r.Email, owner.EmailDelegRegionale__c, IntervenantReseaux__c, EmailEnvoyes__c from Opportunity where ' 
                + '(RecordType.DeveloperName = \'CBMEnDelegation\' or RecordType.DeveloperName = \'CBMHorsDelegationDCR\' or '
                +' RecordType.DeveloperName = \'CBMHorsDelegationDEN\' or RecordType.DeveloperName = \'CBMHorsDelegationDR\') and DateRetour1DocapostOK__c != null '
                +' and Enveloppe__c = false  and (ReseauApporteur1RCBI__c != \'1-NATIXIS LEASE\' or ReseauApporteur1RCBI__c != \'1-BPCE LEASE\') and IntervenantReseaux__c != null and BusinessUnit__c != null '
                +'  and IntervenantReseaux__r.Email != null and owner.EmailDelegRegionale__c != null and HorsProcessusAcquisitionAuto__c = false '
                + ' and (DateRetour1DocapostOK__c >= LAST_N_DAYS:' + (Integer)conf.MinDate__c + ' or DateStatut422DossierRecuControle__c >= LAST_N_DAYS:' + (Integer)conf.MinDate__c + ') '
                +' and HorsProcessusAcquisitionManuel__c = false and DateStatut422DossierRecuControle__c != null  and EmailEnvoyes__c Excludes(\'AT_LIV\') and IntervenantReseaux__r.EmailBouncedDate = null'
                + ' and StageName not in (\'MEL\', \'BACK\', \'S_SUIT\' , \'P_FRNS\', \'MEL_PFT\')';
        }
        System.debug('@@ query ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> scope){
        List<Opportunity> oppList = new List<Opportunity>();
        for(Opportunity item : scope) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { item.IntervenantReseaux__r.Email };
                message.saveAsActivity = true;
            String sender = item.owner.EmailDelegRegionale__c;
            message.replyTo = sender;
            message.senderDisplayName = sender;
            message.targetObjectId = item.IntervenantReseaux__c;
            message.whatId = item.id;
            
            message.templateId = tmpId;
            //try{
            if(!test.isRunningTest())
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {message}); 
            if(item.EmailEnvoyes__c == null) {
                item.EmailEnvoyes__c = 'AT_LIV';
            } else {
                item.EmailEnvoyes__c += ';AT_LIV';
            }
            oppList.add(item);
            //}catch(Exception e) {}
            
            
        }
        
        if(oppList.size() > 0) {
            update oppList;
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}