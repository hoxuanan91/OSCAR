public class BatchCalculObjectifRepereMEL implements Database.Batchable<SObject>, Database.Stateful{
         
        
   		//public final Date startDate=Date.newInstance(system.today().adddays(-100).year(), 1, 1);
    	List<Case> eligibleCasesMEL=new List<Case>(); 
        private Date startDate;
        private Date endDate;
        private Integer mois;
        private Integer annee;
    
     public BatchCalculObjectifRepereMEL(Integer moisACalculer, Integer anneeACalculer){
            mois=moisACalculer;
            annee=anneeACalculer;
            startDate=Date.newInstance(annee, 1, 1);
            Integer numberDays = date.daysInMonth(annee, mois);
            endDate=Date.newInstance(annee, mois, numberDays);
            
        }
     
        public Database.QueryLocator start(Database.BatchableContext BC){
            /*Perimetre global : tous les cases non annulées
            /*Perimetre MEL : tous les recordType CBM_Mise_en_place avec soit une date de traietement dans l'année en cours ou dont le statut est en relance ou prise en charge*/
            /*Perimetre SAV : tous les cases avec un Complexite_SAV__c!=null qui sont cloturés et avec une date de cloture dans l'annee en cours*/
            String query='SELECT Id,Delai_PEC_Terminee__c,Date_revoir__c,Rejet_historique__c,status,StatutNonConformite__c,	Dossier1__r.Prefinancement_en_cours_ou_termine__c,';
            query=query+' Motif_a_revoir__c,recordtype.developerName,StatutApprobation__c,ownerId,createdDate ,owner.name,';
            query=query+' UniteSRC__c,Date_de_traitement_de_la_MEL__c,DelaiMiseLoyer__c,ComplexiteFinale__c,isClosed,owner.type ';
            query=query+' from case where status!=\'Annulée\' AND (recordtype.developerName=\'CBM_Mise_en_place\'';
            query=query+' AND ((Date_de_traitement_de_la_MEL__c>=:startDate AND Date_de_traitement_de_la_MEL__c<=:endDate) OR status in (\'Relance\',\'Prise en charge\')))';
           // query=query+ 'and owner.Id=\'00520000003ubHMAAY\''; 
           
            
            return Database.getQueryLocator(query);
            
        }
        
        public void execute(Database.BatchableContext BC, List<SObject> scope){
           //system.debug('@@ scope existants '+scope.size());
           
           List<Case> caseToHandle=scope;
            eligibleCasesMEL.addAll(caseToHandle);
        
          
           
        }
        
        public void finish(Database.BatchableContext BC){
            system.debug('@@ eligibleCasesMEL '+eligibleCasesMEL.size());
           
            AP24_CalculRepereHandler.calculIndicateurMEL(eligibleCasesMEL,mois, annee, startDate);
            Database.executeBatch(new BatchCalculObjectifRepereSAV(mois, annee),2000);
        }
    
      
   
}