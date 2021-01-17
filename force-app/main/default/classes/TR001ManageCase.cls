public class TR001ManageCase{

    public static list<Holiday> listHoliday = DAL.getHolidaysExceptWeekend();
    public static BusinessHours bh = [SELECT Id,MondayEndTime, MondayStartTime FROM BusinessHours where name=:Label.CL08_PlageHoraireRepere];

    /*
    1. Des règles d’attribution seront définies dans le paramétrage d’Oscar 
    pour gérer l’affectation des Demandes à leur création.
    2. Ces règles d’attribution concernent tous les types d’enregistrement de la Demande 
    exceptés ceux qui concernent les impayés (qui sont gérés au niveau de la gestion des impayés).
    3.Cette fonction permet de lancer les règles d’attribution définies à la création des Demandes. 
    */
    /*public static void CalculateAttributionAutomatique(List<Case> cases){
    
       System.debug('#### : CalculateAttributionAutomatique');
        
        List<Case> maListe = new List<Case>();
        Set<ID> setIds= new Set<ID>();

        for(Case thecase:cases){
           setIds.add(thecase.ID);
        }
        
        maListe  = DAL.getCaseByIDs(setIds);
         
        for(Case c : maListe ){
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule = true;

            c.setOptions(dmlOpts);
        }
        
        Database.update(maListe);
        
    }*/

    public static void MiseAjourNotaire(List<Case> cases){
    
       System.debug('#### : MiseAjourNotaire');
        
        Map<Id,String> maListe = new Map<Id,String>();
        Set<ID> setIds= new Set<ID>();

        for(Case thecase:cases){
           setIds.add(thecase.Dossier1__c);
        }
        
        maListe  = DAL.getNotairesByCaseIDs(setIds);
        System.debug('Notaires');
         if(maListe != null && !maListe.isEmpty()){
            for(Case c : cases ){
                c.NotaireEnCharge__c = maListe.get(c.Dossier1__c);
            }
         }

    }
    

    /*
    1.Cette fonction permet de calculer le Owner des demandes de types impayés
    2.Ces règles sont lancé à la création uniquement
    3.L’objectif est d’attribuer la demande au plus fin, 
    c'est-à-dire prioritairement au Gestionnaire, sinon au groupe, sinon au service.
    */
    /*public static void CalculateAttribution(List<Id> caseIds){
    
       System.debug('#### : CalculateAttribution');
        
        //Déclaration de la liste des files d'attente
        Map<String,Id> Queues = DAL.getQueue();
        
        //Déclaration booleen d'attribution à une file d'attente
        boolean file = false;
        
        //Récupération de la liste des cases
        List<Case> cases = [SELECT RecordTypeId, 
                            Gestionnaire_Cassiopae__r.IsActive,
                            Gestionnaire_Cassiopae__r.UniteSRC__c,
                            Dossier1__r.BusinessUnit__c,
                            OwnerId 
                            FROM case 
                            WHERE Id in :caseIds];
        
        for(Case c : cases){
            
            file = false;
            
           System.debug('$$$$ : ' + c.RecordTypeId);
           System.debug('$$$$ : ' + c.Gestionnaire_Cassiopae__r.UniteSRC__c);
           System.debug('$$$$ : ' + c.Gestionnaire_Cassiopae__r.IsActive);
           System.debug('$$$$ : ' + c.Dossier1__r.BusinessUnit__c);
        
            
            // Cap Gemini - JR - 11/12/17 - Les Anciennes Files d'Attente doivent être décommisionées.
                // Gestion des Types d'Enregistrement CBM - Appel de fonds à recouvrer et CBM - Impayé et avoir Post Réal
                // Le code y faisant référence doit être mis à jour afin de tenir compte, non plus du Groupe d'appartenance du Gestionnaire Cassiopae, mais de son Unité.
                // A cela s'ajoute la comparaison avec la Business Unit du Contrat lié.  
                
            if(rtAppelFondARecouvrer.equals(c.RecordTypeId) || rtImpayesAvoirPostReal.equals(c.RecordTypeId) ){
                
                if (    c.Gestionnaire_Cassiopae__r.UniteSRC__c == '1' &&   // CBM SRC 1
                        c.Dossier1__r.BusinessUnit__c == '1' &&   // BU 1
                        c.Gestionnaire_Cassiopae__r.IsActive)
                    c.OwnerId = c.Gestionnaire_Cassiopae__c;
                
                else if (   c.Gestionnaire_Cassiopae__r.UniteSRC__c == '2' &&   // CBM SRC 2 & 4
                            c.Dossier1__r.BusinessUnit__c == '2' &&   // BU 2
                            c.Gestionnaire_Cassiopae__r.IsActive)
                    c.OwnerId = c.Gestionnaire_Cassiopae__c;
                
                else if (   c.Gestionnaire_Cassiopae__r.UniteSRC__c == '3' &&   // CBM SRC 3
                            c.Dossier1__r.BusinessUnit__c == '3' &&   // BU 3
                            c.Gestionnaire_Cassiopae__r.IsActive)
                    c.OwnerId = c.Gestionnaire_Cassiopae__c;
                
                else if (   c.Gestionnaire_Cassiopae__r.UniteSRC__c == '2' &&   // CBM SRC 2 & 4
                            c.Dossier1__r.BusinessUnit__c == '4' &&   // BU 4
                            c.Gestionnaire_Cassiopae__r.IsActive)
                    c.OwnerId = c.Gestionnaire_Cassiopae__c;
                
                else if (   c.Gestionnaire_Cassiopae__r.UniteSRC__c == '4' &&   // CBM SRC GC 
                            c.Dossier1__r.BusinessUnit__c == '5' &&   // BU GC 
                            c.Gestionnaire_Cassiopae__r.IsActive)
                    c.OwnerId = c.Gestionnaire_Cassiopae__c;
                
                else if (c.Dossier1__r.BusinessUnit__c == '1')  // BU 1
                     { 
                    c.OwnerId = (ID) Queues.get('CBMSRC01');    // Propriétaire par Défaut File d'Attente CBM SRC 01
                    file = true;   
                }
                
                else if (c.Dossier1__r.BusinessUnit__c == '2')  // BU 2
                     {
                    c.OwnerId = (ID) Queues.get('CBMSRC24');    // Propriétaire par Défaut File d'Attente CBM SRC 24 
                    file = true;   
                }
                
                else if (c.Dossier1__r.BusinessUnit__c == '3')  // BU 3
                     {
                    c.OwnerId = (ID) Queues.get('CBMSRC03');   // Propriétaire par Défaut File d'Attente CBM SRC 03
                    file = true;   
                }
                
                else if (c.Dossier1__r.BusinessUnit__c == '4')   // BU 4
                     {
                    c.OwnerId = (ID) Queues.get('CBMSRC24');   // Propriétaire par Défaut File d'Attente CBM SRC 24 
                    file = true;   
                }
                
                else if (c.Dossier1__r.BusinessUnit__c == '5')  // BU GC
                     {
                    c.OwnerId = (ID) Queues.get('CBMSRCGC');    // Propriétaire par Défaut File d'Attente CBM SRC GC
                    file = true;   
                }
                     
                     else if (c.Dossier1__r.BusinessUnit__c == '6')  // BU LOA V
                     {
                    c.OwnerId = (ID) Queues.get('SRCLOAV');   // Propriétaire par Défaut File d'Attente SRC LOA V
                    file = true;   
                }
                
                else {
                    c.OwnerId = (ID) Queues.get('CBMSRCService'); // Par défaut CBM SRC Service si aucune des conditions d'avant n'a été remplie
                    file = true;   
                }
            }  
            
           if(file){
                c.Status = 'A prendre en charge';
               System.debug('$$$$ : cas1 : c.Status : ' + c.Status);
                }
           else{
                c.Status = 'Affectée';
               System.debug('$$$$ : cas2 : c.Status : ' + c.Status);
                }
        }
        
        update cases;
    }*/
    
    /*
    Cette fonction permet de caluler le nombre de facture non lettrées associées à une demande de type imapayé.
    */
//    public static void CalculateNombreFactureNonLettree(List<ID> demandeIDs){
    
//       System.debug('#### : CalculateNombreFactureNonLettree');
        
//        Map<Id,Integer> mamap = DAL.getFactureCount(demandeIDs);
//        List<Case> Demandes = DAL.getCaseByIDs(demandeIDs);
//        Map<Id,Date> mamap2 = DAL.getFactureRecentAttachement(demandeIDs);
//       //Add by Mourad 31/03/2015
//        Map<Id,Integer> FactImp = DAL.getFactureCountImpaye(demandeIDs);
//        Map<Id,Integer> FactAv = DAL.getFactureCountAvoir(demandeIDs);
//        Map<Id,Double> FactMantant = DAL.getFactureCountsommeMontant(demandeIDs);
//        Map<Id,Double> FactSolde = DAL.getFactureCountsommeSolde(demandeIDs);
        //End Mourad  
        
//        System.debug('####mamap'+mamap);
//        for(Case c : Demandes ){

//            c.Nombre_de_factures_non_lettrees__c = (Integer)mamap.get(c.Id) != null ? (Integer)mamap.get(c.Id) : 0;
//            if((Date)mamap2.get(c.Id) != null) c.Date_de_creation_du_dernier_impaye__c = (Date)mamap2.get(c.Id);
//          //Add by Mourad 31/03/2015
//            c.Nb_Avoirs__c = (Integer)FactAv.get(c.Id) != null ? (Integer)FactAv.get(c.Id) : 0;
//            c.Nb_imp__c = (Integer)FactImp.get(c.Id) != null ? (Integer)FactImp.get(c.Id) : 0;
//            c.Total_Montant_TTC__c= (Double)FactMantant.get(c.Id) != null ? (Double)FactMantant.get(c.Id) : 0;
//            c.Total_Solde_TTC__c= (Double)FactSolde.get(c.Id) != null ? (Double)FactSolde.get(c.Id) : 0;
//          //End Mourad   
//        }
//        
//        update Demandes ;
//    }
    
    /*
    Cette fonction permet de caluler la phase d'une demande de type imapayé.
    */
//    public static void CalculatePhaseDemande(Set<ID> demandeIDs){
    
//       System.debug('#### : CalculatePhaseDemande');
        
//        Map<Id,Case> mapDemandes = DAL.getCaseByIDs_ForPhase(demandeIDs);
//        Map<ID,List<Facture_non_lettree__c>> mapFactures = DAL.getFacturesByDemandeIDs(mapDemandes.keySet());
//        List<Case> caseAMettreAJour = new List<Case>();
        
//        for(ID idCase : mapFactures.keySet()){
            
//            List<Facture_non_lettree__c> malist = (List<Facture_non_lettree__c>) mapFactures.get(idCase);
                        
//            Boolean a_jour = true;
//            Boolean en_cours_ctx = true;
//            Boolean prise_en_charge_cx_ju = true;
//            Boolean a_relancer = false;
            
//            System.debug('### liste des factures : ' + malist);
            
//            for(Facture_non_lettree__c f : malist){
                
//                if(f.Date_de_reglement__c == null) a_jour = false;
                
//                if(f.Date_de_reglement__c == null 
//                   &&  (f.Secteur_de_gestion__c != 'RT' 
//                    || (f.Code_Fonction_SG__c != 'ECCTX' && f.Code_Fonction_SG__c != 'TRANCTX')))
                        
//                        en_cours_ctx = false;
                        
//                if(f.Date_de_reglement__c == null 
//                    && (f.Secteur_de_gestion__c != 'CX' && f.Secteur_de_gestion__c != 'JU')) 
                        
//                        prise_en_charge_cx_ju = false;
                        
//                if(f.Date_de_rattachement_demande__c == Date.today())
//                    a_relancer = true;
                
//            }
            
//           Case c = (Case)mapDemandes.get(idCase);
             
//           System.debug('$$$$$ a_jour : ' + a_jour);
//           System.debug('$$$$$ en_cours_ctx : ' + en_cours_ctx);
//           System.debug('$$$$$ prise_en_charge_cx_ju : ' + prise_en_charge_cx_ju);
//           System.debug('$$$$$ a_relancer : ' + a_relancer);
                       
//           System.debug('$$$$$ Case c : ' + idCase);
            
//            if(c != null){
//               System.debug('$$$$$ Case c : ' + c.Id);
//               System.debug('$$$$$ phase actuelle : ' + c.Phase__c);
                
//                if(a_jour) c.Phase__c = 'A jour';
//                else if(en_cours_ctx) c.Phase__c = 'En cours CTX';
//                else if(prise_en_charge_cx_ju) c.Phase__c = 'Prise en charge CX ou JU';
//                else if(a_relancer) c.Phase__c = 'A relancer';
//                else if(c.Phase__c != null && !c.Phase__c.equalsIgnoreCase('Promesse') && !c.Phase__c.equalsIgnoreCase('Moratoire')) c.Phase__c = 'A relancer';
                
//                System.debug('$$$$$ Nouvelle phase : ' + c.Phase__c);
                
//                caseAMettreAJour.add(c);
//            }
//        }
        
//        if(caseAMettreAJour != null && caseAMettreAJour.size() > 0)
//            update caseAMettreAJour;
        
//    }
 
    /*
    Cette fonction permet de calculer le nombre de jour entre deux dates sans compter les Weekend et les jours fériés
    */
    public static Integer getNumberOfDayExceptHolidays(Datetime datedebut , Datetime datefin){
       System.debug('### getNumberOfDayExceptHolidays DateTime');    
       System.debug('### resultat : datedebut : ' + datedebut );
       System.debug('### resultat : datefin: ' + datefin);
       
        if(datedebut == null || datefin== null) return 0;
    
        System.debug('### datedebut > datefin: ' + (datedebut > datefin? 'true' : 'false'));
    
        if(datedebut > datefin)
            return 0;
        
        Integer WeekEnd = 0 ;
        Integer ferie = 0;
        
        datetime d = datedebut ;

        //On récupére la liste des dates des jours féries 
            Map<Date,String> NameHoliday = new Map<Date,String>();
            Set<Date> DateHo = new set<Date>();
            for(Holiday h : listHoliday){
                if(h.RecurrenceStartDate == null){
                  DateHo.add(h.ActivityDate);
                }
                else if (h.RecurrenceStartDate != null) {
                  DateHo.add(date.newInstance(system.now().year() , h.RecurrenceStartDate.month() , h.RecurrenceStartDate.day()));
                }
              } 
              // Vérifie les jours fériés ainsi que les weekend dans l'intervale définis par l'utilisateur
              Set<Date> DateWE = new set<Date>();
          while(date.newInstance(d.year(),d.month(),d.day()) < datefin.addDays(1)){
           System.debug('############### Datte ' + d );
            if(d.format('EEEE')=='Saturday' || d.format('EEEE')=='Sunday' ){
              WeekEnd ++;
              DateWe.add(date.newInstance(d.year(),d.month(),d.day()));
            }
            if(DateHo.Contains(Date.newInstance(d.Year(), d.Month() , d.Day())) == true && d.format('EEEE') != 'Saturday' && d.format('EEEE') != 'Sunday'  ){
              ferie ++ ;
            }
           System.debug('################# AddDays ' + d.addDays(1));
            d = d.addDays(1);
          }
        
       
       Date datedebutx = date.newinstance(datedebut .year(), datedebut .month(), datedebut .day());
       Date datefinx= date.newinstance(datefin.year(), datefin.month(), datefin.day());
                  
      System.debug('### datedebutx.daysBetween(datefinx) : ' + datedebutx.daysBetween(datefinx));
      System.debug('### WeekEnd  : ' + WeekEnd);
      System.debug('### ferie : ' + ferie);
           
       if(datedebutx.daysBetween(datefinx) - WeekEnd - ferie > 0) return datedebutx.daysBetween(datefinx) - WeekEnd - ferie ;
       else return 0;
        
    }

    /*
    Cette fonction permet de calculer le nombre de jour entre deux dates sans compter les Weekend et les jours fériés
    */
    public static Integer getNumberOfDayExceptHolidays(Date datedebut , Date datefin){
       System.debug('### getNumberOfDayExceptHolidays Date');    
       System.debug('### resultat : datedebut : ' + datedebut );
       System.debug('### resultat : datefin: ' + datefin);
       
        if(datedebut == null || datefin== null) return 0;
    
        System.debug('### datedebut > datefin: ' + (datedebut > datefin? 'true' : 'false'));
    
        if(datedebut > datefin)
            return 0;
        
        Integer WeekEnd = 0 ;
        Integer ferie = 0;
        
        datetime d = datedebut ;
        //On récupére la liste des dates des jours féries 
            Map<Date,String> NameHoliday = new Map<Date,String>();
            Set<Date> DateHo = new set<Date>();
            for(Holiday h : listHoliday){
                if(h.RecurrenceStartDate == null){
                  DateHo.add(h.ActivityDate);
                }
                else if (h.RecurrenceStartDate != null) {
                  DateHo.add(date.newInstance(system.now().year() , h.RecurrenceStartDate.month() , h.RecurrenceStartDate.day()));
                }
              } 
              // Vérifie les jours fériés ainsi que les weekend dans l'intervale définis par l'utilisateur
              Set<Date> DateWE = new set<Date>();
          while(date.newInstance(d.year(),d.month(),d.day()) < datefin.addDays(1)){
           System.debug('############### Datte ' + d );
            if(d.format('EEEE')=='Saturday' || d.format('EEEE')=='Sunday' ){
              WeekEnd ++;
              DateWe.add(date.newInstance(d.year(),d.month(),d.day()));
            }
            if(DateHo.Contains(Date.newInstance(d.Year(), d.Month() , d.Day())) == true && d.format('EEEE') != 'Saturday' && d.format('EEEE') != 'Sunday'  ){
              ferie ++ ;
            }
           System.debug('################# AddDays ' + d.addDays(1));
            d = d.addDays(1);
          }
        
       
       Date datedebutx = date.newinstance(datedebut .year(), datedebut .month(), datedebut .day());
       Date datefinx= date.newinstance(datefin.year(), datefin.month(), datefin.day());
                  
      System.debug('### datedebutx.daysBetween(datefinx) : ' + datedebutx.daysBetween(datefinx));
      System.debug('### WeekEnd  : ' + WeekEnd);
      System.debug('### ferie : ' + ferie);
           
       if(datedebutx.daysBetween(datefinx) - WeekEnd - ferie > 0) return datedebutx.daysBetween(datefinx) - WeekEnd - ferie ;
       else return 0;
    }   
    
    /*
    Cette fonction permet de calculer les diffèrents délais associés aux demandes
    */
    public  static void GetCasesPrepared(List<Case> cases, List<Case> casesOld){
    	Map<Id,Id> OpptiesList=new Map<Id,Id>();
        for(Case newCase : cases){	
                OpptiesList.put(newCase.Id, newCase.ProjetAssocie__c);	
          }	
         Map<Id,Opportunity> relatedOpps=new Map<Id,Opportunity>([select id,DateEnvoi2Docapost__c,
                                                                     DateStatut423PVFactRecuesVerif__c 	
                                                                 from Opportunity 	
                                                                 where id in :OpptiesList.values()]);	
        	
        	
        Integer i = 0;	
        for(Case c : cases){	
            Id relatedPASId=OpptiesList.get(c.Id);	
            Opportunity relatedPAS=relatedOpps.get(relatedPASId);	
           System.debug('@@ casesOld = '+ casesOld );	
            System.debug('@@ c= '+ c );	
            System.debug('@@ relatedPAS= '+ relatedPAS );	
            if(casesOld != null) System.debug('#### casesOld[i].status = '+ casesOld[i].status );	
            
     
            //CalculateDelais
            if(casesOld == null || 
                (casesOld != null && 
                'A prendre en charge'.equals(casesOld[i].status) && 
                c.Derniere_Date_APrendreEnCharge__c == null) || 
                ('A prendre en charge'.equals(c.status) && 
                c.Derniere_Date_APrendreEnCharge__c == null) || 
                (casesOld != null && 
                'A prendre en charge'.equals(c.status) && 
                !'A prendre en charge'.equals(casesOld[i].status))) 
                    c.Derniere_Date_APrendreEnCharge__c = System.now();

            if(casesOld == null || 
                (casesOld != null && 
                'Prise en charge'.equals(casesOld[i].status) && 
                c.Derniere_Date_PriseEnCharge__c == null) || 
                ('Prise en charge'.equals(c.status) && 
                c.Derniere_Date_PriseEnCharge__c == null) || 
                (casesOld != null && 
                'Prise en charge'.equals(c.status) && 
                !'Prise en charge'.equals(casesOld[i].status))) 
                    c.Derniere_Date_PriseEnCharge__c = System.now();

            if(casesOld == null || 
                (casesOld != null && 
                casesOld[i].status != null && 
                casesOld[i].status.contains('Terminée') && 
                c.Derniere_Date_Termine__c == null) || 
                (c.status != null && 
                c.status.contains('Terminée') && 
                c.Derniere_Date_Termine__c == null) || 
                (casesOld != null && c.status != null && 
                c.status.contains('Terminée') && 
                !casesOld[i].status.contains('Terminée'))) 
                    c.Derniere_Date_Termine__c = System.now();

            if(casesOld == null || 
                (casesOld != null && 
                'Affectée'.equals(casesOld[i].status) && 
                c.Derniere_Date_Affecte__c == null) || 
                ('Affectée'.equals(c.status) && 
                c.Derniere_Date_Affecte__c == null) || 
                (casesOld != null && 
                'Affectée'.equals(c.status) && 
                !'Affectée'.equals(casesOld[i].status))) 
                    c.Derniere_Date_Affecte__c = System.now();

            if(casesOld == null || 
                (casesOld != null && 
                'A jour'.equals(casesOld[i].Phase__c) && 
                c.Derniere_Date_PhaseAjour__c == null) || 
                ('A jour'.equals(c.Phase__c) && 
                c.Derniere_Date_PhaseAjour__c == null) || 
                (casesOld != null && 
                'A jour'.equals(c.Phase__c) && 
                !'A jour'.equals(casesOld[i].Phase__c))) 
                   // c.Derniere_Date_PhaseAjour__c = System.today();
            
            /*System.debug('#### après #### c.Derniere_Date_APrendreEnCharge__c = '+ c.Derniere_Date_APrendreEnCharge__c );
            System.debug('#### après #### c.Derniere_Date_PriseEnCharge__c = '+ c.Derniere_Date_PriseEnCharge__c );
            System.debug('#### après #### c.Derniere_Date_Termine__c = '+ c.Derniere_Date_Termine__c );
            System.debug('#### après #### c.Derniere_Date_Affecte__c = '+ c.Derniere_Date_Affecte__c );
            System.debug('#### après #### c.Derniere_Date_PhaseAjour__c = '+ c.Derniere_Date_PhaseAjour__c );*/
            
            
            /** Règle générale pour tous les calculs ci-dessous
            Ne refaire le calcul que si :
                1. Le case est un nouveau (casesOld == null)
                Ou
                2. Le case est ancien (casesOld != null)
                    ET
                    2.1 DateDebut a changé
                    OU
                    2.2 DateFin a changé
            **/
            
            if(casesOld == null || (casesOld != null && (c.Derniere_Date_Affecte__c != casesOld[i].Derniere_Date_Affecte__c || c.Derniere_Date_PriseEnCharge__c != casesOld[i].Derniere_Date_PriseEnCharge__c)))
                c.Delai_Affectee_PEC__c = getNumberOfDayExceptHolidays(c.Derniere_Date_Affecte__c,c.Derniere_Date_PriseEnCharge__c);            
            
            if(casesOld == null || (casesOld != null && (c.Derniere_Date_PriseEnCharge__c != casesOld[i].Derniere_Date_PriseEnCharge__c || c.Derniere_Date_Termine__c != casesOld[i].Derniere_Date_Termine__c)))
                c.Delai_PEC_Terminee__c = getNumberOfDayExceptHolidays(c.Derniere_Date_PriseEnCharge__c,c.Derniere_Date_Termine__c);
            
            if(casesOld == null || (casesOld != null && (c.Derniere_Date_APrendreEnCharge__c != casesOld[i].Derniere_Date_APrendreEnCharge__c || c.Derniere_Date_PriseEnCharge__c != casesOld[i].Derniere_Date_PriseEnCharge__c)))
                c.Delai_APEC_PEC__c = getNumberOfDayExceptHolidays(c.Derniere_Date_APrendreEnCharge__c,c.Derniere_Date_PriseEnCharge__c);
            
            if(casesOld == null || (casesOld != null && (c.CreatedDate != casesOld[i].CreatedDate || c.Derniere_Date_PriseEnCharge__c != casesOld[i].Derniere_Date_PriseEnCharge__c)))
                c.Delai_de_PEC__c = getNumberOfDayExceptHolidays(c.CreatedDate,c.Derniere_Date_PriseEnCharge__c);
         
            if(casesOld == null || (casesOld != null && (c.CreatedDate != casesOld[i].CreatedDate || c.DateRecepDde__c != casesOld[i].DateRecepDde__c)))
                c.DelaiEnregistrementServiceTransverse__c = getNumberOfDayExceptHolidays(c.CreatedDate,c.DateRecepDde__c);
            
            if(casesOld == null || (casesOld != null && (c.CreatedDate != casesOld[i].CreatedDate || c.Derniere_Date_Termine__c != casesOld[i].Derniere_Date_Termine__c)))
                c.Delai_Creation_Terminee__c = getNumberOfDayExceptHolidays(c.CreatedDate,c.Derniere_Date_Termine__c);
            
            //CalculateDelaisTransfert
            if(casesOld == null || (casesOld != null && (c.Dossier_complet__c != casesOld[i].Dossier_complet__c || c.Avenant_envoye__c != casesOld[i].Avenant_envoye__c)))
                c.DelaiTransfert_DC_AE__c = getNumberOfDayExceptHolidays(c.Dossier_complet__c,c.Avenant_envoye__c);
            
            if(casesOld == null || (casesOld != null && (c.Avenant_recu__c != casesOld[i].Avenant_recu__c || c.Transfert_realise__c != casesOld[i].Transfert_realise__c)))
                c.DelaiTransfert_AR_TR__c = getNumberOfDayExceptHolidays(c.Avenant_recu__c, c.Transfert_realise__c);
            
            if(casesOld == null || (casesOld != null && (c.Accord_demande_la_deleg_banque__c != casesOld[i].Accord_demande_la_deleg_banque__c || c.Dossier_complet__c != casesOld[i].Dossier_complet__c)))
                c.DelaiTransfert_ADDR_DC__c = getNumberOfDayExceptHolidays(c.Accord_demande_la_deleg_banque__c, c.Dossier_complet__c); 
            
            //CalculateDelaisSinistre
            if(casesOld == null || (casesOld != null && (c.Dossier_complet_attente_reglement__c != casesOld[i].Dossier_complet_attente_reglement__c || c.Reglement_assurance_recu__c != casesOld[i].Reglement_assurance_recu__c)))
                c.DelaiSinistre_DC_RAR__c = getNumberOfDayExceptHolidays(c.Dossier_complet_attente_reglement__c, c.Reglement_assurance_recu__c); 
            
            if(casesOld == null || (casesOld != null && (c.Perte_FI_doc_envoi_docs_au_courtier__c != casesOld[i].Perte_FI_doc_envoi_docs_au_courtier__c || c.Reglement_du_courtier_recu__c != casesOld[i].Reglement_du_courtier_recu__c)))
                c.DelaiSinistre_PFEDAC_RCR__c = getNumberOfDayExceptHolidays(c.Perte_FI_doc_envoi_docs_au_courtier__c, c.Reglement_du_courtier_recu__c);
            
            if(casesOld == null || (casesOld != null && (c.Bris_machine_envoi_docs_courtier__c != casesOld[i].Bris_machine_envoi_docs_courtier__c || c.Envoi_propo_indemnisation_au_client__c != casesOld[i].Envoi_propo_indemnisation_au_client__c)))
                c.DelaiSinistre_BMEDC_EPIC__c = getNumberOfDayExceptHolidays(c.Bris_machine_envoi_docs_courtier__c,c.Envoi_propo_indemnisation_au_client__c);
            
            if(casesOld == null || (casesOld != null && (c.Bris_machine_envoi_docs_courtier__c != casesOld[i].Bris_machine_envoi_docs_courtier__c || c.Reglement_du_courtier_recu__c != casesOld[i].Reglement_du_courtier_recu__c)))
                c.DelaiSinistre_BMED_RCR__c = getNumberOfDayExceptHolidays(c.Bris_machine_envoi_docs_courtier__c, c.Reglement_du_courtier_recu__c);
       
            // CalculateDelaisDeces
            if(casesOld == null || (casesOld != null && (c.Documents_envoyes_au_courtier__c != casesOld[i].Documents_envoyes_au_courtier__c || c.Reglement_du_courtier_recu__c != casesOld[i].Reglement_du_courtier_recu__c)))
                c.DelaiDeces_DEC_RCR__c = getNumberOfDayExceptHolidays(c.Documents_envoyes_au_courtier__c, c.Reglement_du_courtier_recu__c); 

            //CalculateDelaisIncapacite
            if(casesOld == null || (casesOld != null && (c.Envoi_docs_courtier_prise_en_charge__c != casesOld[i].Envoi_docs_courtier_prise_en_charge__c || c.Decision_courtier_prise_en_charge__c != casesOld[i].Decision_courtier_prise_en_charge__c)))
                c.DelaiSinistre_EDCPEC_DCPEC__c = getNumberOfDayExceptHolidays(c.Envoi_docs_courtier_prise_en_charge__c, c.Decision_courtier_prise_en_charge__c); 
          
            //CalculateDelaisNouveauDossier
            if(casesOld == null || (casesOld != null && (c.CreatedDate != casesOld[i].CreatedDate || c.Date_de_traitement_de_la_MEL__c != casesOld[i].Date_de_traitement_de_la_MEL__c)))
                c.DelaiMiseLoyer__c = getNumberOfDayExceptHolidays(c.CreatedDate, c.Date_de_traitement_de_la_MEL__c); 
            
            if(casesOld == null || (casesOld != null && (c.Date_de_traitement_de_la_MEL__c != casesOld[i].Date_de_traitement_de_la_MEL__c || c.Derniere_Date_Termine__c != casesOld[i].Derniere_Date_Termine__c)))
                c.DelaiTraitement_Post_MEL__c = getNumberOfDayExceptHolidays(c.Date_de_traitement_de_la_MEL__c, c.Derniere_Date_Termine__c);
            
            if(casesOld == null || (casesOld != null && (c.Derniere_Date_PriseEnCharge__c != casesOld[i].Derniere_Date_PriseEnCharge__c || c.Date_de_traitement_de_la_MEL__c != casesOld[i].Date_de_traitement_de_la_MEL__c)))
                c.DelaiMEnLoyer_Apres_PEC__c = getNumberOfDayExceptHolidays(c.Derniere_Date_PriseEnCharge__c,c.Date_de_traitement_de_la_MEL__c);
            //Ajout calcul Delai jira 787
            
             if(casesOld != null && c.DateDecisionApprobation__c!= casesOld[i].DateDecisionApprobation__c && c.DateDebutApprobation__c!=null){	      
                   c.Delai_approbation__c=DateUtils.getHoursBetweenWorkingDays(c.DateDebutApprobation__c,c.DateDecisionApprobation__c);	
                 /*DHMOSCAR-951 : la date de traitement max de l'approbation est (date de début + 1 jour ouvré ) à 20h00 */
                  // Datetime dateTraitementMaxAppro=DateUtils.getNextBusinessDays(c.DateDebutApprobation__c);
                   Datetime dateTraitementMaxAppro=DateUtils.addBusinessDays(c.DateDebutApprobation__c,1);
                   Date mDate = dateTraitementMaxAppro.date();
				   Time mTime = Time.newInstance(20, 0, 0, 0);
                   dateTraitementMaxAppro=Datetime.newInstance(mDate, mTime);
                   c.Delai_approbation_respecte__c=c.DateDecisionApprobation__c<=dateTraitementMaxAppro?true:false;
                    
              }	
              if(casesOld == null && relatedPAS!=null && (relatedPAS.DateEnvoi2Docapost__c!=null ||relatedPAS.DateStatut423PVFactRecuesVerif__c!=null)){	
                    Datetime maxDate=getMaxDate(relatedPAS.DateEnvoi2Docapost__c,relatedPAS.DateStatut423PVFactRecuesVerif__c);
                  system.debug('@@ maxDate '+maxDate);
                   
                    c.Delai_PVFact_Crea__c=DateUtils.getHoursBetweenWorkingDays(maxDate,system.now());	
                  system.debug('@@ Delai_PVFact_Crea__c '+c.Delai_PVFact_Crea__c);
              }	
              if(casesOld != null && c.ProjetAssocie__c!=null && c.ProjetAssocie__c!= casesOld[i].ProjetAssocie__c &&	
                   (relatedPAS.DateEnvoi2Docapost__c!=null ||relatedPAS.DateStatut423PVFactRecuesVerif__c!=null)){	
                       Datetime maxDate=getMaxDate(relatedPAS.DateEnvoi2Docapost__c,relatedPAS.DateStatut423PVFactRecuesVerif__c);	
                       c.Delai_PVFact_Crea__c=DateUtils.getHoursBetweenWorkingDays(maxDate,c.createdDate);	
              }
            i++;
        }
   
   }
   
   
   /*
    Cette fonction permet de mettre le user à l'utilisateur actuel
    si l'utilisateur du case est égle au user par défaut du service support
    */
    public  static void updateSupportUser(List<ID> listIds, Map<ID,Case> cases){
    
     
        List<Case> maListe  = DAL.getCaseByIDs_ForOwner(listIds);
        Id MyUserId = UserInfo.getUserId();
        for(Case c : maListe ){
              
            if((String.valueOf(cases.get(c.Id).ownerId)).substring(0,15).equals(Label.userParDefaut)){
                System.debug('#### : ownerId before : ' + cases.get(c.Id).ownerId);
                cases.get(c.Id).ownerId  =MyUserId;
                System.debug('#### : ownerId after  : ' + cases.get(c.Id).ownerId);
            }
        }
    
    }
   
   
   
   
    //Add by Mourad SAIR 02/04/2015
    //Methode qui permet de créer un enregistrement sur la liste des commentaires liée à la demande en cours selon la valeur indiquée+
    //+ sur le champ Commentaire en cours puis de vider ce champ à la fin.
    //Methode à utiliser apres l Insert du case 
     /*public static void CreateCommentCaseAfterInsert(Set<Id> CasesComment){
        
        list <CaseComment> CaseCommentToCreate = new list <CaseComment>();
        list <Case> CaseToUpdate = DAL.getCaseByIDsForComment(CasesComment);
        
         if(CaseToUpdate.size()>0){
            for(Case Ca : CaseToUpdate){
                CaseComment CaseCommentNew = new CaseComment(ParentId = Ca.Id,CommentBody = Ca.CommentaireC__c,IsPublished = true);
                CaseCommentToCreate.add(CaseCommentNew);
                Ca.CommentaireC__c = null;
             }
            
             insert CaseCommentToCreate;
             update CaseToUpdate;
          }
      }*/ 
     
     
     //Methode à utiliser Avant l'update du case 
     public static void CreateCommentCaseBeforeUpdate(list<Case> CasesComment){
        
        list <CaseComment> CaseCommentToCreate = new list <CaseComment>();
        
            for(Case Ca : CasesComment){
                CaseComment CaseCommentNew = new CaseComment(ParentId = Ca.Id,CommentBody = Ca.CommentaireC__c,IsPublished = true);
                CaseCommentToCreate.add(CaseCommentNew);
                Ca.CommentaireC__c = null;
             }
            
             insert CaseCommentToCreate;
    
     }
     
     //Add Mourad SAIR 07/04/2015
     // Priorité 1 : si toutes les factures ont une date de règlement non vide, alors il faut affecter :
        //- le champ "Date à revoir" de la Demande à vide
        //- le champ "Motif à revoir" de la Demande à vide
    //Sinon s'il existe deje des factures dans la demande et au moins une nouvelle demande.     
      public static void MAJArevoirDemandeAjour(list<ID> demandeIDs,list<Case> CasesAjour){
    
          Map<Id,Integer> FactureNonletrree = DAL.getFactureCount(demandeIDs);
          Map<Id,Integer> NouvelleFactureNonletrree;
          Map<Id,Integer> OldFactureNonletrree ;
          Map<Id,Date> MaxDateKasiop ;
          Map<Id,Date> FactureChangeRegCount ;
          list<Case> CasesToUpdate = new list<Case>();     
           
          system.debug('### Map FactureNonletrree'+FactureNonletrree);
          for(Case Ca : CasesAjour){
            
            if(((Integer)FactureNonletrree.get(ca.Id)!=null && (Integer)FactureNonletrree.get(ca.Id)== 0) || (Integer)FactureNonletrree.get(ca.Id)==null ){
                          system.debug('### (Integer)FactureNonletrree.get(ca.Id)'+(Integer)FactureNonletrree.get(ca.Id));
                
               Ca.Date_revoir__c = null;
               Ca.Motif_a_revoir__c = null;
               system.debug('###  Ca.Date_revoir__c '+  Ca.Date_revoir__c );
               system.debug('###  Ca.Motif_a_revoir__c '+  Ca.Motif_a_revoir__c );
               CasesToUpdate.Add(Ca); 
               
            }  
            // Priorité 2 Sur une ancienne demande des 3 types d'enregistrements +
            //+s'il existe au moins une ancienne facture sur la demande et au moins une nouvelle facture donc MAJ dec champs : 
             //- le champ "Date à revoir" de la Demande à [Date MAJ ksiop +1]
             //- le champ "Motif à revoir" de la Demande à "Nouvel Impayé/Avoir"
             else {
                 if (NouvelleFactureNonletrree == null) NouvelleFactureNonletrree = DAL.getNewFactureCount(demandeIDs);
                 if (OldFactureNonletrree == null) OldFactureNonletrree = DAL.getOldFactureCount(demandeIDs);
                 if (MaxDateKasiop == null) MaxDateKasiop = DAL.getNewDateKasiopFacture(demandeIDs);
                     
                     system.debug('### NouvelleFactureNonletrree'+NouvelleFactureNonletrree);
                     system.debug('### OldFactureNonletrree'+OldFactureNonletrree);
                     system.debug('### FactureNonletrree'+FactureNonletrree);
                     
                     
             if((Integer)NouvelleFactureNonletrree.get(ca.Id)> 0 &&  (Integer)OldFactureNonletrree.get(ca.Id)> 0){
                system.debug('### (Date)MaxDateKasiop.get(ca.Id)'+(Date)MaxDateKasiop.get(ca.Id));
                Ca.Motif_a_revoir__c = 'Nouvel Impayé/Avoir';
                Ca.Date_revoir__c = (Date)MaxDateKasiop.get(ca.Id) != null ? ((Date)MaxDateKasiop.get(ca.Id)+1):null;
                CasesToUpdate.Add(Ca); 
            }
           
        
                //Priorité 3 : Sur une ancienne demande sans aucune nouvelle facture et avec une facture réglée qui devient non réglée alors : 
                 // Affecter « Motif à revoir » à ‘Paiement rejeté’
                 // Affecter « Date à revoir » à [Date MAJ ksiop+1]
                 // Affecter « Dernière date de règlement enregistrée » à VIDE
                   else{
                       if (NouvelleFactureNonletrree == null) NouvelleFactureNonletrree = DAL.getNewFactureCount(demandeIDs);
                       if (FactureChangeRegCount == null) FactureChangeRegCount = DAL.getFactureChangeRegCount(demandeIDs);
                         system.debug('### NouvelleFactureNonletrree 3'+NouvelleFactureNonletrree);
                         system.debug('### FactureChangeRegCount'+FactureChangeRegCount);
                    
                     if(((Integer)NouvelleFactureNonletrree.get(ca.Id) == null || (Integer)NouvelleFactureNonletrree.get(ca.Id) == 0 )&& (Date)FactureChangeRegCount.get(ca.Id) != null){
                            system.debug('### NouvelleFactureNonletrree 3 if '+(Date)FactureChangeRegCount.get(ca.Id));
                        Ca.Motif_a_revoir__c = 'Paiement rejeté';
                        Ca.Date_revoir__c = (Date)FactureChangeRegCount.get(ca.Id)+1;
                        CasesToUpdate.Add(Ca);
                       // DemandeToCheck.Add(Ca.Id);
               
                     }
                  }
         
            }
          }
          
       
          
          /*system.debug('###  CasesAjour '+  CasesAjour );
        system.debug('### test fin methode'+CasesToUpdate);*/
        
        if(CasesToUpdate.size()>0) update CasesToUpdate;
      }
  public static Datetime getMaxDate(Datetime date1, Datetime date2){	
        if(date1>date2){	
            return date1; 	
        }	
        else{	
            return date2; 	
        }	
        	
    }	
    	
    
 
}