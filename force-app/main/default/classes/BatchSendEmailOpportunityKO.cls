public class BatchSendEmailOpportunityKO implements Database.Batchable<SObject>, Database.Stateful {
    private String tmpId;
    private String emailMode;
    private List<String> typeDocList;
    public BatchSendEmailOpportunityKO(String emailMode) {
        this.emailMode = emailMode;
        String tmpName = 'PJAEmailCTM' + emailMode;
        if(emailMode == 'KO1') {
            typeDocList =  new List<String>{'2',  '3', '4', '5', '6'};
                } else if(emailMode == 'KO2') {
                    typeDocList = new List<String>{'8',  '9', '10', '11'};
                        }
        tmpId=[Select id from EmailTemplate where DeveloperName = :tmpName Limit 1].Id;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        EmailConfiguration__mdt conf = [select MaxDate__c, MinDate__c from EmailConfiguration__mdt where DeveloperName = :emailMode];
        
        Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        String dayOfWeek=dt.format('EEEE');
        System.debug('Day : ' + dayOfWeek);
        Date minDate;
        Date maxDate;
        if(dayOfWeek == 'Monday' || dayOfWeek == 'Tuesday' || dayOfWeek == 'Wednesday') {
            minDate = System.today().addDays(-((Integer)conf.MinDate__c + 2));
        	maxDate = System.today().addDays(-((Integer)conf.MaxDate__c + 2));
        } else if(dayOfWeek == 'Sunday'){
             minDate = System.today().addDays(-((Integer)conf.MinDate__c + 1));
        	maxDate = System.today().addDays(-((Integer)conf.MaxDate__c + 1));
        } else {
             minDate = System.today().addDays(-(Integer)conf.MinDate__c);
        	maxDate = System.today().addDays(-(Integer)conf.MaxDate__c);
        }

        String queryOpp = 'select  ProjetAssocie__c from  ControleMetier__c where DAY_ONLY(createdDate) >= :minDate  and DAY_ONLY(createdDate) <= :maxDate and Forcage__c = false'
            +' and Archive__c = false and TypeDocument__c in :typeDocList'
            +' and RecordType.DeveloperName = \'CBMControleMetier\' and ProjetAssocie__c != null and Statut__c = \'3\' '
            +' and Bloquant__c = \'1\' group by ProjetAssocie__c';
        
        List<String> result = new List<String>();
        
        List<AggregateResult> resultQuery = Database.query(queryOpp);
        for(AggregateResult item : resultQuery) {
            result.add((String)item.get('ProjetAssocie__c'));
        }
        
        String query;
        if(Test.isRunningTest()) {
            query = 'select Id,IntervenantReseaux__r.Email, EmailDelegRegionalRenseigne__c,Dossier__c, Owner.EmailDelegRegionale__c,IntervenantReseaux__c, EmailEnvoyes__c from Opportunity';
        }else{
            query = 'select Id,IntervenantReseaux__r.Email, owner.EmailDelegRegionale__c, IntervenantReseaux__c, EmailEnvoyes__c from Opportunity where Id in :result ' 
                +' and EmailEnvoyes__c Excludes(:emailMode) and IntervenantReseaux__r.EmailBouncedDate = null and  IntervenantReseaux__r.Email != null and owner.EmailDelegRegionale__c != null '
                + ' and Enveloppe__c = false  and (ReseauApporteur1RCBI__c != \'1-NATIXIS LEASE\' and ReseauApporteur1RCBI__c != \'1-BPCE LEASE\') '
                + ' and IntervenantReseaux__c != null and BusinessUnit__c != null ';
            if(emailMode == 'KO1') {
                query += ' and DateRetour1DocapostOK__c = null';
            } else if(emailMode == 'KO2') {
                query += ' and DateRetour2DocapostOK__c = null';
            }
        }
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> scope){ 
        System.debug('@@@ scope ' + scope);
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
            // try{
            if(!test.isRunningTest())
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {message}); 
            if(item.EmailEnvoyes__c == null) {
                item.EmailEnvoyes__c = emailMode;
            } else {
                item.EmailEnvoyes__c += ';' + emailMode;
            }
            oppList.add(item);
            // }catch(Exception e) {}
            
            
        }
        
        if(oppList.size() > 0) {
            update oppList;
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}