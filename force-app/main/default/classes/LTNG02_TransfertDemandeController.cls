public with sharing  class LTNG02_TransfertDemandeController {
    
		@AuraEnabled public static Void updateCase(Id recordId, String businessUnit,Date dateEnvoieEnGestion,String status) {
            system.debug('@@ my current case is ' +recordId);
            system.debug('@@ my BusinessUnit is ' +BusinessUnit);
            Correspondance_BU_Queues__mdt  getQueueByBU=[select id, MasterLabel from Correspondance_BU_Queues__mdt where BU__c= :businessUnit limit 1];
            system.debug('@@ my getQueueByBU is ' +getQueueByBU);
            if(getQueueByBU!=null){
                Group QueueToAssign = [SELECT DeveloperName,Id FROM Group where Type = 'Queue' and DeveloperName=:getQueueByBU.MasterLabel limit 1];
                system.debug('@@ my QueueToAssign is ' +QueueToAssign);
                if(QueueToAssign!=null){
                    case caseToUpdate=new Case(id=recordId, ownerId=QueueToAssign.Id);
                    If(dateEnvoieEnGestion==null){
                        caseToUpdate.Datedenvoiengestion__c=system.today();
                    }
                    If(!'A prendre en charge'.equalsIgnoreCase(status)){
                        caseToUpdate.status='A prendre en charge';
                    }
                    User currentUser =[select id, 	
                                       UserByPassProcess__c,
                                       UserByPassTriggers__c,
                                       UserByPassValidationRules__c,	
                                       UserByPassWorkflows__c
                                       from user where id = :UserInfo.getUserId()];
                    
                    /* FORCER les bypass de ce traitement */         
                    String currentUserBypassTriggers=currentUser.UserByPassTriggers__c;
                    Boolean currentUserBypassProcess=currentUser.UserByPassProcess__c;    
                    Boolean currentUserBypassWF=currentUser.UserByPassWorkflows__c;    
                    Boolean currentUserBypassVR=currentUser.UserByPassValidationRules__c;
                    currentUser.UserByPassTriggers__c = 'CalculetteROEBeforeUpdate;CaseAfterDelete;CaseAfterInsert;CaseAfterUnDelete;CaseAfterUpdate;CaseBeforeDelete;CaseBeforeInsert;CaseBeforeUpdate;ContentDocumentAfterUpdate;ContentDocumentBeforeUpdate;ContentVersionBeforeInsert;ContractAfterUpdate;CreateCommentCase;DetailDuPoolBeforeDelete;DetailDuPoolBeforeInsert;DetailDuPoolBeforeUpdate;DossierAfterDelete;DossierAfterInsert;DossierAfterUpdate;EmailAfterInsert;EmailBeforeDelete;EmailBeforeInsert;EventAfterInsert;EventBeforeInsert;EventBeforeUpdate;FactureAfterDelete;FactureAfterInsert;FactureAfterUnDelete;FactureAfterUpdate;FillNotaireCase;GarantieAfterDelete;GarantieAfterInsert;GarantieAfterUpdate;ListeBienAfterDelete;ListeDeBienAfterInsert;NoteComiteAfterDelete;NoteComiteAfterInsert;NoteComiteAfterUpdate;NoteComiteBeforeInsert;NoteComiteBeforeUpdate;OpportunityAfterInsert;OpportunityAfterUpdate;OpportunityBeforeDelete;OpportunityBeforeInsert;OpportunityBeforeUpdate;OpportunitySplitAfterInsert;PhaseBienAfterDelete;PhaseBienAfterInsert;PhaseBienAfterUpdate;PhaseBienBeforeInsert;PoolDeGarantsAfterDelete;PoolDeGarantsAfterInsert;PoolDeGarantsAfterUpdate;ProjetAfterInsert;QuoteAfterDelete;QuoteAfterInsert;QuoteAfterUpdate;ReseauApporteurAfterDelete;ReseauApporteurAfterInsert;ReseauApporteurAfterUpdate;MAJArevoirDemandeAjour;TR001ManageCase;TR001ManageCase_CalculFacture;TR001ManageCase_CalculPhase;TR001ManageCase_DisableDeleteCase;TR001ManageCase_updateSupportUser;TR001ManageCaseSaufImpaye;TR002ManageCase_Attribution;TR002ManageCase_Attribution_Automatique;TR002ManageContract;TR002ManageContract_MAJDateMEL;TR002ManageContract_NomTiers;LLD_LeadConversion;UserAfterUpdate;UserBeforeUpdate';
                    currentUser.UserByPassProcess__c=true;
                    currentUser.UserByPassWorkflows__c=true;
                    currentUser.UserByPassValidationRules__c=true;
                    update currentUser;
                    try{
                        update caseToUpdate;
                        system.debug('@@ my current case is updated');
                        
                        //return 'success';
                    }
                    catch(Exception e){
                        system.debug('@@ my current case is NOT updated');
                        // return 'failed';
                    }
                    currentUser.UserByPassTriggers__c =currentUserBypassTriggers;
                    currentUser.UserByPassProcess__c=currentUserBypassProcess;
                    currentUser.UserByPassWorkflows__c=currentUserBypassWF;
                    currentUser.UserByPassValidationRules__c=currentUserBypassVR;
                    update currentUser;
                }
            }    
                
           
       }
}