public class BatchCalculObjectifRepereSAV implements Database.Batchable<SObject>, Database.Stateful{
         
        /* Le batch se lancera tous les 01 du mois M+1 
		pour calculer les données du 01/janvier au 31/M */
   		//public final Date startDate=Date.newInstance(system.today().adddays(-1).year(), 1, 1);
       // public final Date startDate=Date.newInstance(system.today().adddays(-100).year(), 1, 1);
        private Date startDate;
        private Date endDate;
        private Integer mois;
        private Integer annee;
        List<Case> eligibleCasesSAV=new List<Case>(); 
    
     public BatchCalculObjectifRepereSAV(Integer moisACalculer, Integer anneeACalculer){
            mois=moisACalculer;
            annee=anneeACalculer;
            startDate=Date.newInstance(annee, 1, 1);
            Integer numberDays = date.daysInMonth(annee, mois);
            endDate=Date.newInstance(annee, mois, numberDays);
            
        }
    
        public Database.QueryLocator start(Database.BatchableContext BC){
                   
			/*Perimetre SAV : tous les cases avec un Complexite_SAV__c!=null qui sont cloturés et avec une date de cloture dans l'annee en cours*/
            /* tous les cases non annulées   */
            
            String query='SELECT Id,Complexite_SAV__c,Delai_PEC_Terminee__c,Date_revoir__c,Rejet_historique__c,status,';
            query=query+' Motif_a_revoir__c,recordtype.developerName,StatutApprobation__c,ownerId,createdDate ,owner.name,';
            query=query+' UniteSRC__c,Date_de_traitement_de_la_MEL__c,DelaiMiseLoyer__c,ComplexiteFinale__c,isClosed,owner.type ';
            query=query+' from case where status!=\'Annulée\'';
            query=query+' AND Complexite_SAV__c!=null AND isClosed=true AND closedDate>=:startDate and closedDate<=:endDate';
          
            return Database.getQueryLocator(query);
            
        }
        
        public void execute(Database.BatchableContext BC, List<SObject> scope){
          
           List<Case> caseToHandle=scope;
            eligibleCasesSAV.addAll(caseToHandle);
        
        }
        
        public void finish(Database.BatchableContext BC){            
            AP24_CalculRepereHandler.calculIndicateurSAV(eligibleCasesSAV,mois, annee, startDate);
        }
    
    
}