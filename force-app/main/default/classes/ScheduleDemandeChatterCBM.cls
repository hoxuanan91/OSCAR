global class ScheduleDemandeChatterCBM implements Schedulable{
    global void execute(SchedulableContext SC) {
        executeBatch();
    }
    private EmailConfiguration__mdt getConfig(String key) {
        return [select Id, DeveloperName, MaxDate__c, MinDate__c, SendNotification__c from EmailConfiguration__mdt where DeveloperName = :key];
    }
	
    public void executeBatch() {
        String dateFormat = 'yyyy-MM-dd';
        List<BatchDemandeChatterCBM.ConfigWrapper> litConfig = new List<BatchDemandeChatterCBM.ConfigWrapper>();
        EmailConfiguration__mdt Demande_Alerte_Accuse_de_reception = getConfig('Demande_Alerte_Accuse_de_reception');
       
        String queryDemande_Alerte_Accuse_de_reception = 'select Id, Notifications__c, OwnerId, Owner.Type from case where (recordtype.DeveloperName = \'CBM_Reclamation\' or recordtype.DeveloperName = \'CBIReclamation\') and IsClosed = false and ' 
            +'DAY_ONLY(createdDate) <= ' + getPreviousDateExceptWeekEnd((Integer)Demande_Alerte_Accuse_de_reception.MaxDate__c).format(dateFormat)+'  and DAY_ONLY(createdDate) >= ' 
            + getPreviousDateExceptWeekEnd((Integer)Demande_Alerte_Accuse_de_reception.MinDate__c).format(dateFormat) + ' and Notifications__c Excludes(\'Alerte Accusé de réception\')';
        
        System.debug('@@@ queryDemande_Alerte_Accuse_de_reception   ' + queryDemande_Alerte_Accuse_de_reception);
        //Database.executeBatch(new BatchDemandeChatterCBM(queryDemande_Alerte_Accuse_de_reception, Label.Alerte_Accuse_de_reception, 'Alerte Accusé de réception'), 5);
        litConfig.add(new BatchDemandeChatterCBM.ConfigWrapper(queryDemande_Alerte_Accuse_de_reception, Label.Alerte_Accuse_de_reception, 'Alerte Accusé de réception', Demande_Alerte_Accuse_de_reception.SendNotification__c));
        
        EmailConfiguration__mdt Demande_Alerte_APEC = getConfig('Demande_Alerte_APEC');
        
        String queryDemande_Demande_Alerte_APEC = 'select Id, Notifications__c, OwnerId, Owner.Type from case where (recordtype.DeveloperName = \'CBM_Reclamation\' or recordtype.DeveloperName = \'CBIReclamation\') and Status = \'A prendre en charge\' and ' 
            +'DAY_ONLY(createdDate) <= ' +getPreviousDateExceptWeekEnd((Integer)Demande_Alerte_APEC.MaxDate__c).format(dateFormat)+'  and DAY_ONLY(createdDate) >= ' 
            + getPreviousDateExceptWeekEnd((Integer)Demande_Alerte_APEC.MinDate__c).format(dateFormat) + ' and Notifications__c Excludes(\'Alerte APEC\')';
        
        //Database.executeBatch(new BatchDemandeChatterCBM(queryDemande_Demande_Alerte_APEC, Label.Alerte_APEC, 'Alerte APEC'), 5);
        litConfig.add(new BatchDemandeChatterCBM.ConfigWrapper(queryDemande_Demande_Alerte_APEC, Label.Alerte_APEC, 'Alerte APEC', Demande_Alerte_APEC.SendNotification__c));
        System.debug('@@@ queryDemande_Demande_Alerte_APEC   ' + queryDemande_Demande_Alerte_APEC);
        EmailConfiguration__mdt Demande_Alerte_Delai_max = getConfig('Demande_Alerte_Delai_max');
        
        
         String queryDemande_Alerte_Delai_max = 'select Id, Notifications__c, OwnerId, Owner.Type from case where (recordtype.DeveloperName = \'CBM_Reclamation\' or recordtype.DeveloperName = \'CBIReclamation\') and IsClosed = false  and' 
            +'  DAY_ONLY(createdDate) <= ' 
            + getPreviousDateExceptWeekEnd((Integer)Demande_Alerte_Delai_max.MinDate__c).format(dateFormat) + ' and Notifications__c Excludes(\'Alerte Délai max\')';
        System.debug('@@@ queryDemande_Alerte_Delai_max   ' + queryDemande_Alerte_Delai_max);
        litConfig.add(new BatchDemandeChatterCBM.ConfigWrapper(queryDemande_Alerte_Delai_max, Label.Alerte_Delai_max, 'Alerte Délai max', Demande_Alerte_Delai_max.SendNotification__c));
        //Database.executeBatch(new BatchDemandeChatterCBM(queryDemande_Alerte_Delai_max, Label.Alerte_Delai_max, 'Alerte Délai max'), 5);
        Database.executeBatch(new BatchDemandeChatterCBM(litConfig), 5);
    }
    
    public DateTime getPreviousDateExceptWeekEnd(Integer numberDate) {
        DateTime currentDate = System.now();
        Integer counterDay = 0;
        while(counterDay != numberDate) {
            String d=currentDate.format('EEEE');
            if (!(d =='Saturday' || d == 'Sunday')) {
                counterDay ++;
            } 
            currentDate = currentDate.addDays(-1);
        }
        
        return currentDate;
    }
}