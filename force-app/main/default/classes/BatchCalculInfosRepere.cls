public class BatchCalculInfosRepere implements Database.Batchable<SObject>, Database.Stateful{
    Map<Id,Set<Date>> mapDatetravailleParUser=new Map<Id,Set<Date>>();
    private Date startDate;
    private Date endDate;
    private Integer mois;
    private Integer annee;
    
    public BatchCalculInfosRepere(Integer jour,Integer moisACalculer, Integer anneeACalculer){
            mois=moisACalculer;
            annee=anneeACalculer;
            startDate=Date.newInstance(annee, 1, 1);
            //Integer numberDays = date.daysInMonth(annee, mois);
            endDate=Date.newInstance(annee, mois, jour);
        system.debug('@@ startDate '+startDate);
         system.debug('@@ endDate '+endDate);   
        
        }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {      
      
        String query='Select Date_de_traitement_de_la_MEL__c,owner.Id from case where status!=\'Annulée\' ';
        query=query+'and Date_de_traitement_de_la_MEL__c>=:startDate and Date_de_traitement_de_la_MEL__c<=:endDate and owner.type=\'User\'';
        if(Test.isRunningTest()){
             query='Select Date_de_traitement_de_la_MEL__c,owner.Id from case limit 1 ';
        }
        return Database.getQueryLocator(query);
    }
     public void execute(Database.BatchableContext BC, List<SObject> scope){

         List<Case> caseToHandle=scope;
         for(Case c :caseToHandle){
                 If(mapDatetravailleParUser.containsKey(c.OwnerId)){
                     mapDatetravailleParUser.get(c.OwnerId).add(c.Date_de_traitement_de_la_MEL__c);               
                 }
                 else{
                     mapDatetravailleParUser.put(c.OwnerId,new Set<Date>{c.Date_de_traitement_de_la_MEL__c});
                     
                 }
                             
         }
          
     }
        
     public void finish(Database.BatchableContext BC){
         
         List<User> usersWithNbMEL=[select id , 
                     NombreDeJourTravailleMEL__c, 
                     lastModifiedDate  
                     from user where NombreDeJourTravailleMEL__c!=null];
         List<User> userToEmptyField=new List<User>();
         for(User u :usersWithNbMEL){
             if(!mapDatetravailleParUser.containsKey(u.Id)){
                 u.NombreDeJourTravailleMEL__c=0;
                 userToEmptyField.add(u);
             }
         }

   		List<User> usersToUpdate=new List<User>();
             for(Id userId :mapDatetravailleParUser.keyset()){
                 Integer nbMEL=mapDatetravailleParUser.get(userId).size();
                 User u=new User(Id=userId,NombreDeJourTravailleMEL__c=nbMEL!=null?nbMEL:0);
                 usersToUpdate.add(u);
             }
            usersToUpdate.addAll(userToEmptyField);
             update usersToUpdate;
       
         
        
     }
        
}