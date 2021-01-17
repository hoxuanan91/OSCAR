public with sharing class BatchGestionCyclesRelanceEnvoiEmails {

    public BatchGestionCyclesRelanceEnvoiEmails() {
    }
     
   public Database.QueryLocator start(Database.BatchableContext bc) {
        
        //CHECKER EXCLUDES
        String query = 'SELECT Id, Name, AccountId, Account.Animateur__r.Id, Account.CreatedById, Account.Charge_Affaire__r.Id, Account.sousMarche__c, DateRelance3__c, Date_revoir__c, Motif_a_revoir__c, SoldeTTCTotalFacturesNonLettreesF__c, No_cycle_de_relance__c, Date_debut_cycle__c, Email_a_envoyer__c, Date_dernier_Email__c, Niveau_de_relance_dernier_email__c, Niveau_de_relance_final__c, Niveau_de_relance_calcule__c, Motif_de_forcage_R0__c';
        query += ' FROM Case WHERE RecordType.developerName=\'CBIActionsRecouvrement\' AND IsClosed = false ';
        
        System.debug('####### Query : ' + query);

        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Case> scope){

        Set<Case> casesToUpdate = new Set<Case>();
        Map<Id, Id> contactIdByAccountId = new Map<Id, Id>();

        for(Case c : scope){
            Integer diff = c.Date_dernier_Email__c.daysBetween(System.today());

            if(c.Niveau_de_relance_final__c != 'R3'){
                c.DateRelance3__c = null;
                casesToUpdate.add(c);
            }
            if(c.Niveau_de_relance_final__c != 'R0' && c.Niveau_de_relance_final__c != 'R1' && c.Niveau_de_relance_final__c != 'R2' && c.Niveau_de_relance_final__c != 'R3'){
                c.Date_revoir__c    = System.today();
                c.Motif_a_revoir__c = 'Niveau de relance finale = ' + c.Niveau_de_relance_final__c;
                casesToUpdate.add(c);
            }

            if(c.SoldeTTCTotalFacturesNonLettreesF__c > 0){
                if((c.Niveau_de_relance_final__c == 'R0' || c.Niveau_de_relance_final__c == 'R1') && c.Date_debut_cycle__c == null){
                    c.No_cycle_de_relance__c                = c.No_cycle_de_relance__c + 1;
                    c.Date_debut_cycle__c                   = System.today();
                    c.Email_a_envoyer__c                    = true;
                    c.Date_revoir__c                        = System.today();
                    c.Motif_a_revoir__c                     = 'Cycle de relance créé avec première relance du cycle de niveau ' + c.Niveau_de_relance_final__c;
                    c.Date_dernier_Email__c                 = null;
                    c.Niveau_de_relance_dernier_email__c    = null;
                }
                else if(c.Niveau_de_relance_final__c == 'R1' && c.Date_debut_cycle__c != null){
                    if(c.Email_a_envoyer__c == true){                   
                        c.Date_revoir__c    = System.today();
                        c.Motif_a_revoir__c = '! Cette demande était déjà topée comme ayant un email de relance à Envoyer';
                    }
                    else{
                        if(diff < 20){
                            c.Date_revoir__c    = System.today();
                            c.Motif_a_revoir__c = 'R1 ; un email de Relance a déjà été envoyé il y a moins de 20 jours ; on attend';
                        }
                        else if(diff >= 20){
                            c.Date_revoir__c    = System.today();
                            c.Motif_a_revoir__c = '!R1 ; un email de Relance a déjà été envoyé il y a 20 jours ou plus';
                        }
                    }
                }
                else if(c.Niveau_de_relance_final__c == 'R2' && c.Date_debut_cycle__c != null){
                    if(c.Niveau_de_relance_dernier_email__c == 'R1'){
                        c.Date_revoir__c        = System.today();
                        c.Email_a_envoyer__c    = true;
                        c.Motif_a_revoir__c     = 'Passage en R2 ; email à envoyer';
                    }
                    else if(c.Niveau_de_relance_dernier_email__c == 'R2'){
                        if(diff < 20){
                            if(c.Email_a_envoyer__c == false){
                                c.Date_revoir__c        = System.today();
                                c.Motif_a_revoir__c     = 'R2 ; un email de Relance a déjà été envoyé il y a moins de 20 jours ; on attend';
                            }
                            else{
                                c.Date_revoir__c        = System.today();
                                c.Motif_a_revoir__c     = 'R2 ; un email de Relance a déjà été envoyé il y a moins 20 jours et un autre est topé comme étant à envoyer';
                            }
                        }
                        else if(diff > 20){
                            if(c.Email_a_envoyer__c == false){
                                c.Date_revoir__c        = System.today();
                                c.Motif_a_revoir__c     = '! R2 ; un email de Relance a déjà été envoyé il y a plus de 20 jours';
                            }
                            else{
                                c.Date_revoir__c        = System.today();
                                c.Motif_a_revoir__c     = '! R2 et nouvel email à envoyer ; un email R2 a déjà été envoyé il y a plus de 20 jours';
                            }
                        }
                    }
                }
                else if(c.Niveau_de_relance_final__c == 'R3'){
                    if(c.DateRelance3__c == null){
                        c.DateRelance3__c       = System.today();
                        c.Date_revoir__c        = System.today();
                        c.Motif_a_revoir__c     = 'R3 ; passage en R3';
                    }
                    if(c.Email_a_envoyer__c == true){
                        c.Motif_a_revoir__c     = c.Motif_a_revoir__c + ' - demande d\'email supprimée';
                        c.Email_a_envoyer__c    = false;
                    }
                }
                casesToUpdate.add(c);
            }
            else if(c.Niveau_de_relance_final__c == 'R0' && c.Email_a_envoyer__c == true){
                c.Date_revoir__c        = System.today();
                c.Motif_a_revoir__c     = 'R0 ; demande d\'email supprimée';
                c.Email_a_envoyer__c    = false;
                casesToUpdate.add(c);
            }
        }

        List<String> templatesName = new List<String>{'STANDARD_R1_avec_Moratoire', 'STANDARD_R1_sans_Moratoire', 'STANDARD_R2'};

        List<EmailTemplate> templatesEmail = [SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE DeveloperName IN :templatesName];

        Map<String, Id> templateIdByDeveName = new Map<String, Id>();

        Map<Id, Id> templateIdByCaseId = new Map<Id, Id>();

        Map<Id, List<String>> ccEmailsByCaseId = new Map<Id, List<String>>();

        for(EmailTemplate eT : templatesEmail){
            templateIdByDeveName.put(eT.DeveloperName, eT.Id);
        }

        for(Case c : casesToUpdate){
            if(c.Email_a_envoyer__c == true && (c.Niveau_de_relance_final__c == 'R1' || c.Niveau_de_relance_final__c == 'R2')){
                contactIdByAccountId.put(c.AccountId, null);
            }
            if(c.Niveau_de_relance_final__c == 'R1'){
                if(c.Motif_de_forcage_R0__c == 'MORATOIRE A RÉALISER'){
                    templateIdByCaseId.put(c.Id, templateIdByDeveName.get('STANDARD_R1_avec_Moratoire'));
                }
                else{
                    templateIdByCaseId.put(c.Id, templateIdByDeveName.get('STANDARD_R1_sans_Moratoire'));
                }
            }
            else if(c.Niveau_de_relance_final__c == 'R2'){
                templateIdByCaseId.put(c.Id, templateIdByDeveName.get('STANDARD_R2'));
            }

            if(ccEmailsByCaseId.get(c.Id) == null){
                ccEmailsByCaseId.put(c.Id, new List<String>());
                ccEmailsByCaseId.get(c.Id).add(c.Account.CreatedById);
                if(c.Account.sousMarche__c == 'Pro - CE' || c.Account.sousMarche__c == 'Pro - BP'){
                    ccEmailsByCaseId.get(c.Id).add(c.Account.Animateur__r.Id);
                }
                else{
                    ccEmailsByCaseId.get(c.Id).add(c.Account.Charge_Affaire__r.Id);
                }
            }
        }

        Map<Id, Id> contactIdByCaseId = new Map<Id, Id>();        

        for(Contact c : [SELECT Id, Name, Email, Correspondant_recouvrement__c FROM Contact WHERE AccountId IN :contactIdByAccountId.keySet() AND Correspondant_recouvrement__c = true AND Email != null]){
            if(contactIdByAccountId.get(c.AccountId) == null){
                contactIdByAccountId.put(c.AccountId, c.Id);
            }
        }

        for(Case c : scope){
            for(Id aId : contactIdByAccountId.keySet()){
                if(c.AccountId == aId && contactIdByAccountId.get(c.AccountId) != null){
                    contactIdByCaseId.put(c.Id, contactIdByAccountId.get(c.AccountId));
                    c.Date_dernier_Email__c = System.today();
                    c.Niveau_de_relance_dernier_email__c = c.Niveau_de_relance_final__c;
                    c.Email_a_envoyer__c = false;
                    c.Date_revoir__c = System.today();
                    c.Motif_a_revoir__c = c.Motif_a_revoir__c + ' - mail envoyé';
                    casesToUpdate.add(c);
                }
                else if(contactIdByAccountId.get(c.AccountId) == null && !c.Motif_a_revoir__c.startsWith('! Probleme avec le contact Recouvrement du Tiers')){
                    c.Date_revoir__c = System.today();
                    c.Motif_a_revoir__c = '! Probleme avec le contact Recouvrement du Tiers ' + c.Motif_a_revoir__c;
                    casesToUpdate.add(c);
                }
            }
        }
        
        Id fromAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'recouvrement-carlease@natixis.com'].Id;

        List<Messaging.SingleEmailMessage> emailToSend = new List <Messaging.SingleEmailMessage>();

        for(Id cId : contactIdByCaseId.keySet()){
            System.debug('################# ContactIdByContractId.get(cId)'+ contactIdByCaseId.get(cId));
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

            message.saveAsActivity = false;
            message.targetObjectId = contactIdByCaseId.get(cId);
            message.ccAddresses = ccEmailsByCaseId.get(cId);
            
            message.whatId = cId;
            message.templateId = templateIdByCaseId.get(cId);
            message.setOrgWideEmailAddressId(fromAddress);
            message.setSaveAsActivity(true);
            
            emailToSend.add(message);

            System.debug('########### message '+ message);
            
        }
        
        if(!test.isRunningTest()){
            System.debug(emailToSend);
            Messaging.sendEmail(emailToSend);
        }

        List<Case> casesToUpdateList = new List<Case>();
        casesToUpdateList.addAll(casesToUpdate);

        if(!casesToUpdate.isEmpty()){
            Database.update(casesToUpdateList);
        }
            
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}