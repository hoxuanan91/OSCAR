public class BatchCalculObjectifRepereEvent implements Database.Batchable<SObject> {
    
    private Date startDate;
    private Date endDate;
    private Integer mois;
    private Integer annee;
    
    public BatchCalculObjectifRepereEvent(Integer moisACalculer, Integer anneeACalculer){
            mois=moisACalculer;
            annee=anneeACalculer;
            startDate=Date.newInstance(annee, 1, 1);
            Integer numberDays = date.daysInMonth(annee, mois);
            endDate=Date.newInstance(annee, mois, numberDays);
 	}
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        //
        String query='SELECT  Id, TypeRdv__c, Type, StartDateTime, OwnerId ,recordType.developerName ';
        query=query+'FROM Event where type=\'Animation Réseau-Formation\' and recordType.developerName=\'CBMEvenement\' ';
        query=query+'and StartDateTime>=:startDate and StartDateTime<=:endDate and TypeRdv__c=\'1\' and EtatRDV__c!=null';
        return Database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope){        
        /*Batch size= 2000 > à la volumetrie de ce type de rdv. donc on rentrera dans le execute 1 fois*/
        List<Event> rdvFormationReseau=(List<Event>) scope;
        Map<Id, List<Event>> mapNbRDVReseauByColloborateur=new Map<Id,List<Event>>();
        for(Event rdv :rdvFormationReseau){
            if(mapNbRDVReseauByColloborateur.containsKey(rdv.OwnerId)){
                mapNbRDVReseauByColloborateur.get(rdv.OwnerId).add(rdv);
            }
            else{
                mapNbRDVReseauByColloborateur.put(rdv.OwnerId,new List<Event>{rdv});
            }
            
        }  
        Map<Id, ObjectifRealise__c> mapObjectifBycollab=AP24_CalculRepereHandlerFront.getMapObjectifBycollab(mapNbRDVReseauByColloborateur.keyset(), 
                                                                                                               mois, 
                                                                                                               annee);
		
        List<ObjectifRealise__c> listOR=new List<ObjectifRealise__c>();
        for(Id userId : mapNbRDVReseauByColloborateur.keyset()){
            ObjectifRealise__c existingOR=mapObjectifBycollab.get(userId);
            List<Event> listRDV=mapNbRDVReseauByColloborateur.get(userId);
            Integer nbRDV=listRDV!=null?listRDV.size():0;
            ObjectifRealise__c ORToUpsert=new ObjectifRealise__c(Obj_ASSRC_QT2__c=nbRDV);
            if(existingOR!=null){
                ORToUpsert.Id=existingOR.Id;
            }
            listOR.add(ORToUpsert);
        }
         upsert listOR;   
            
    }
    
    public void finish(Database.BatchableContext BC){
        
    }


}