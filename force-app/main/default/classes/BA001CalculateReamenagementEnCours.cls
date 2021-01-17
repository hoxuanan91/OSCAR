// Mustapha EL HASSAK
// Le 26/04/2015 V 1.0
//Ajouter ce champ pour le type de demandes "CBM - Actions de recouvrement" uniquement.
//-à Oui s'il existe une demande de réaménagement (vivante) sur un ou plusieurs des dossiers 
// des factures (réglées ou non réglées) rattachées à la demande de recouvrement en question.
//-à Non sinon 

global class BA001CalculateReamenagementEnCours implements Database.Batchable<sObject> {

    global final String query;
    
    global BA001CalculateReamenagementEnCours(String query){
        this.query = query;
    }
    
    global Database.Querylocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, list<sObject> scope){
        
        Set<ID> demandeIDs = new Set<ID>();
        Map<Id,Case> demandeAMettreAjour = new Map<Id,Case>();
         
        // Récupérer la liste des IDs des demandes ACTION RECOUVREMENT --------------------------------------------------------     
        for(sObject o : scope ){
            demandeIDs.Add(((Case)o).Id);
        }
        // --------------------------------------------------------------------------------------------------------------------
        
        // Récuéperer les factures associées aux demandes de recouvrement ------------------------------------------------------
        Map<ID,List<Facture_non_lettree__c>> mapDemandeFacture = new Map<ID,List<Facture_non_lettree__c>>();
        List<Facture_non_lettree__c > maList = [Select  Demande_rattachee__c, N_Dossier__c 
                                                        From Facture_non_lettree__c
                                                        Where Demande_rattachee__c IN :demandeIDs];
                                        
        for(Facture_non_lettree__c f : maList){
            List<Facture_non_lettree__c> temp = (List<Facture_non_lettree__c>)mapDemandeFacture.get(f.Demande_rattachee__c);
            if(temp == null) temp = new List<Facture_non_lettree__c>();
            
            temp.add(f);
            
            mapDemandeFacture.put(f.Demande_rattachee__c,temp);
        }
        // --------------------------------------------------------------------------------------------------------------------
        
        // Récuéperer la liste des demandes REAMENAGEMENT avec le dossier associé ---------------------------------------------
        Map<ID,ID> mapDossierDemandeReamenagement = new Map<ID,ID>();
        ID RT_Reamenagement = (ID)(DAL.getRecordType('Case')).get('CBM_Reamenagement');
        List<Case> maListCase = [Select Id, Dossier1__c
                             from Case 
                             where RecordTypeId = :RT_Reamenagement
                             AND status not in ('Terminée','Terminée Transférée juridique','Terminée Transférée contentieux','Annulée')];
                                        
        for(Case c : maListCase){
            mapDossierDemandeReamenagement.put(c.Dossier1__c, c.Id);
        }
        // --------------------------------------------------------------------------------------------------------------------
        
        // Parcourir la liste des demandes ACTION RECOUVREMENT ----------------------------------------------------------------
        // Pour chaque demande (boucle 1)
        // Pour chaque facture (boucle 2)
        // Si le dossier de la facture existe dans la liste des dossiers des demandes REAMENAGEMENT
        // ==> Alors TRUE
        // Sinon
        // ==> Alors FALSE
        boolean Reac;
        for(Id idDemande : mapDemandeFacture.keySet() ){ //boucle 1
            Reac = false;
            for(Facture_non_lettree__c f : (List<Facture_non_lettree__c>)mapDemandeFacture.get(idDemande)){ //boucle 2
                if(mapDossierDemandeReamenagement.containsKey(f.N_Dossier__c))
                    Reac = true;
                        
                demandeAMettreAjour.put(idDemande, new Case(Id = idDemande, Reac__c = Reac));
                if(Reac) break;
            }
        }
        // --------------------------------------------------------------------------------------------------------------------
        System.debug(' #### mapDemandeFacture : ' + mapDemandeFacture);
        System.debug(' #### mapDossierDemandeReamenagement : ' + mapDossierDemandeReamenagement);
        System.debug(' #### demandeAMettreAjour : ' + demandeAMettreAjour);
        // Persistence --------------------------------------------------------------------------------------------------------
        update demandeAMettreAjour.values();
        // --------------------------------------------------------------------------------------------------------------------
    }
    
    global void finish(Database.BatchableContext bc){
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Username
                           From AsyncApexJob where Id = :BC.getJobId()];
                           
       System.debug('### Job Id                 : ' + a.Id);
       System.debug('### Job Created by         : ' + a.CreatedBy.Username);
       System.debug('### Job Status             : ' + a.Status);
       System.debug('### Job Items total        : ' + a.TotalJobItems);
       System.debug('### Job Items processed    : ' + a.JobItemsProcessed);
       System.debug('### Job Number of errors   : ' + a.NumberOfErrors);     
    }
}