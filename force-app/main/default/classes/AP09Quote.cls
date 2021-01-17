public class AP09Quote {


   public static void DatespropositionCommercialesToProjetAssocie(Quote[] PropositionCommerciales) {
        /*
         * JB @Capgemini
        Nous avons besoin de faire remonter certaines informations de la Proposition Commerciales vers le Projet Associé.
                DEV : 
        •   Date Proposition envoyée Recopie automatiquement la valeur du champ ‘Date d'envoi’ de  la première Proposition Commerciale envoyée au client.
             o  DatePropositionEnvoyee__c + Rajouter un champs dans Quote pour identifier La première Proposition Commerciale envoyée????
                >>> ok
        •   Date Proposition acceptée Recopie automatiquement la valeur du champ ‘Date de décision’ de  la Proposition Commerciale acceptée par client
                     (c’est-à-dire la Proposition Commerciale ayant le champ Décision= Acceptée) .
            o   Opp : DatePropositionAcceptee__c 
                Quote : (DecisionClient__c = Acceptée + DateDeDecision__c)
                >>>ok
        •   Date de Fin de Validité Recopie automatiquement la valeur du champ ‘Date d'expiration' de  la première Proposition Commerciale envoyée au client.
             o  DateDeFinDeValidite__c
        
                Ce comportement doit de répéter sr chaque Proposition Commerciale ou ces champs sont modifiés. Ainsi, c'est la dernière Proposition Commerciale
                mise à jour sur un des ses 3 champs qui alimente le Projet Associé.
        */
        
        // Ajouter par Radoica - Capgemini 24/05/2018 suite à l'apparition de l'erreur System.LimitException: Too many query rows: 50001
        // Dans le Select on limite les Opportunités retournées en ne prenant que celle qui sont liées aux Propositions Commerciales modifiées
           
        // Ids des Projets Associés à récuperer
        set<Id> idsPJA = new Set<Id>();
        
        for(Quote PropositionCommerciale : PropositionCommerciales) {
           idsPJA.add(PropositionCommerciale.OpportunityId);
       }
                
        List<Opportunity> lOppBD = [SELECT Id, DatePropositionEnvoyee__c, DatePropositionAcceptee__c,DateDeFinDeValidite__c  FROM Opportunity where id IN :idsPJA];
        Map<Id, Opportunity> MapIdOpp = new Map<Id , Opportunity>();           
        for(Opportunity TheOpp : lOppBD) { 
               MapIdOpp.put(TheOpp.id , TheOpp); 
        } 
       for(Quote PropositionCommerciale : PropositionCommerciales) { 
           Opportunity theOpp = MapIdOpp.get(PropositionCommerciale.Opportunityid);
           if((PropositionCommerciale.DecisionClient__c == 'Acceptée' )&&(theOpp.DatePropositionAcceptee__c == null)&&(PropositionCommerciale.DateDeDecision__c != null)) {
                theOpp.DatePropositionAcceptee__c = PropositionCommerciale.DateDeDecision__c;   
           }
           if((theOpp.DatePropositionEnvoyee__c == NULL )&&(theOpp.DatePropositionEnvoyee__c == null)&&(PropositionCommerciale.DateDEnvoi__c != NULL )) { 
             theOpp.DatePropositionEnvoyee__c = PropositionCommerciale.DateDEnvoi__c;   
           }
           if((theOpp.DateDeFinDeValidite__c == NULL )&&(theOpp.DateDeFinDeValidite__c == null)&&(PropositionCommerciale.ExpirationDate != NULL )) { 
             theOpp.DateDeFinDeValidite__c = PropositionCommerciale.ExpirationDate;   
           } 
           update theOpp;
           
       }
   }
    
   public static void DatesPCOMenvoye(Quote[] PropositionCommerciales) {
       
       // Calculettes à mettre à jour 
       List<CalculetteROE__c> CROELIST = new List<CalculetteROE__c>();
       
       // Ids des calculettes à récuperer
       set<Id> idsCalc = new Set<Id>();
       
       for(Quote PropositionCommerciale : PropositionCommerciales) {
           idsCalc.add(PropositionCommerciale.CalculetteROE__c);
       }

       Map<Id, CalculetteROE__c> calcsMap = new Map<Id, CalculetteROE__c>([Select id, NbPropositionsCommercialesEnvoyees__c from CalculetteROE__c where id IN :idsCalc]);
           
        for(Quote PropositionCommerciale : PropositionCommerciales) {
            CalculetteROE__c CROE = calcsMap.get(PropositionCommerciale.CalculetteROE__c);
            if(PropositionCommerciale.DateDEnvoi__c != NULL) {
               
                if( CROE.NbPropositionsCommercialesEnvoyees__c != 1 ) {
                    CROE.NbPropositionsCommercialesEnvoyees__c = 1;
                    CROELIST.add(CROE);
                    
                }
            }
            else{
                if( CROE.NbPropositionsCommercialesEnvoyees__c != 0 ) {
                    CROE.NbPropositionsCommercialesEnvoyees__c = 0;
                    CROELIST.add(CROE);          
                }
            }
        } 
       update CROELIST;
   }
    
    /**
     * Appelé à la suppression d'une proposition commerciale pour supprimer les données relatives à celle ci dans 
     * les autres objets
     */
    public static void nettoyageDesDonnees(Quote[] PropositionCommerciales) {

        // objets à mettre à jour
        List<CalculetteROE__c> calculettesToUpdate = new List<CalculetteROE__c>();
        
        // On récupère les ids des objets à traiter
        Set<Id> calcsIds = new Set<Id>();        
        
        for(Quote lQuote : PropositionCommerciales){
            calcsIds.add(lQuote.CalculetteROE__C);
        }
                
        // Objets récupérés de la base
        Map<Id, CalculetteROE__c> calculettesMap = new Map<Id, CalculetteROE__c>([SELECT Id, NbPropositionsCommerciales__c, NbPropositionsCommercialesEnvoyees__c, IDPropositionCommerciale__c, NomPropositionCommerciale__c  
                                                                                  FROM CalculetteROE__c 
                                                                                  WHERE ID IN :calcsIds AND IDPropositionCommerciale__c != null
                                                                                                        AND NomPropositionCommerciale__c != null
                                                                                                        AND NbPropositionsCommerciales__c > 0]);
        for(Quote lQuote : PropositionCommerciales){

            CalculetteROE__c lCalculette = calculettesMap.get(lQuote.CalculetteROE__C);
            lCalculette.IDPropositionCommerciale__c = null;
            lCalculette.NomPropositionCommerciale__c = null;
            lCalculette.NbPropositionsCommerciales__c = 0;
            lCalculette.NbPropositionsCommercialesEnvoyees__c = 0;
            calculettesToUpdate.add(lCalculette);
            
        }
        
        update calculettesToUpdate;
        
        
    }
    
    /**
     * Renseigne les champs relatifs à la propal sur la calculatrice associée
     * Au changement d'une calculatrice, supprime les données sur l'ancienne
     */
    public static void ajoutPropalSurCalculatrice(Quote[] oldPropal, Quote[] newPropal) {
        
        // objets à mettre à jour
        List<CalculetteROE__c> calcsToUpdate = new List<CalculetteROE__c>();
        
        // On récupère les ids des calculettes
        Set<Id> oldCalcIds = new Set<Id>();
        Set<Id> newCalcIds = new Set<Id>();
        
        
        for(Quote lQuote : newPropal){
            newCalcIds.add(lQuote.CalculetteROE__c);           
        }
        
        // Objets à traiter
        Map<Id,CalculetteROE__c> oldCalcMap;  
        Map<Id,CalculetteROE__c> newCalcMap = new Map<Id,CalculetteROE__c>([SELECT Id, IDPropositionCommerciale__c, NomPropositionCommerciale__c, NbPropositionsCommerciales__c  FROM CalculetteROE__c WHERE ID IN :newCalcIds]);
        Map<Id,Quote> oldPropalMap;
        
        if(oldPropal != null){
            
            oldPropalMap = new Map<Id, Quote>();
            
            for(Quote lQuote : oldPropal){
                oldCalcIds.add(lQuote.CalculetteROE__c);
                oldPropalMap.put(lQuote.Id, lQuote);
            }
           
            oldCalcMap = new Map<Id,CalculetteROE__c>([SELECT Id, IDPropositionCommerciale__c, NomPropositionCommerciale__c, NbPropositionsCommerciales__c  FROM CalculetteROE__c WHERE Id IN :oldCalcIds]);
        }
    
        for(Quote lQuote : newPropal){
            
            CalculetteROE__c calcROE;

            // Si la Calculette est renseignée, on met à jour ses données
            if(newCalcMap.containsKey(lQuote.CalculetteROE__c)){

                calcROE = newCalcMap.get(lQuote.CalculetteROE__c);
                calcROE.IDPropositionCommerciale__c = lQuote.id;
                calcROE.NomPropositionCommerciale__c = lQuote.Name;
                calcROE.NbPropositionsCommerciales__c = 1;    
                
                calcsToUpdate.add(calcROE);
            }
            // On vérifie si la calculette a changé
            if(oldPropal != null){
   
                Quote lOldQuote = oldPropalMap.get(lQuote.Id);
                CalculetteROE__c oldCalcROE;
                    
                if(lOldQuote != null && lOldQuote.CalculetteROE__c != lQuote.CalculetteROE__c && oldCalcMap.containsKey(lOldQuote.CalculetteROE__c)){
  
                    oldCalcROE = oldCalcMap.get(lOldQuote.CalculetteROE__c);
                    oldCalcROE.IDPropositionCommerciale__c = null;
                    oldCalcROE.NomPropositionCommerciale__c = null;
                    oldCalcROE.NbPropositionsCommerciales__c = 0; 
                        
                    calcsToUpdate.add(oldCalcROE);
                }
            }
            
        }
        
        update calcsToUpdate;
    }

}