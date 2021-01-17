public class AP14DetailDuPool {
    
	public static void insertUpdateCDFReporting(Detail_du_Pool__c[] lDetailDuPool){
	
		Set<Id> oppsIds = new Set<Id>();  
        Set<Id> accountsIds = new Set<Id>();  
        
        for (Detail_du_Pool__c DDP:lDetailDuPool){
            
            oppsIds.add(DDP.ProjetAssocie__c);
            accountsIds.add(DDP.Partenaire__c);
        }
        
        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>([SELECT ID, NomDuChefDeFileRCBI__c, AdresseDuChefDeFileRCBI__c, Amount, QuotePartNL__c, StatutNL__c,
                                           MontantTotalPoolDeFinancement__c, QuotePartTotalPoolDeFinancement__c, NBChefDeFilePoolDeFinancement__c,
                                           NbDePoolFinancement__c, FraisDeDossier__c, FraisDossierQPNL__c 
                                           FROM Opportunity WHERE Id IN :oppsIds]);
        
        Map<Id, Account> accountsMap = new Map<Id, Account>([select id, name, BillingStreet, BillingPostalCode, BillingCity, BillingCountry  from account where id IN :accountsIds]);
        
        
        List<Opportunity> OppToUpdate = new List<Opportunity>(); 
  
        for (Detail_du_Pool__c DDP:lDetailDuPool){
   
          Opportunity oppTemp = oppsMap.get(DDP.ProjetAssocie__c);
          Account accTemp = accountsMap.get(DDP.Partenaire__c);
    
          if(accTemp != null){
          	if(DDP.Chef_de_file__c == true) {
                
                 	oppTemp.NomDuChefDeFileRCBI__c = accTemp.name; 
                    oppTemp.AdresseDuChefDeFileRCBI__c = accTemp.BillingStreet + ', ' + '<br>' + 
                        									accTemp.BillingPostalCode + ', ' + 
                        									accTemp.BillingCity + ', ' + 
                        									accTemp.BillingCountry;
        		 	OppToUpdate.add(oppTemp) ;
          	}
          	if( (oppTemp.NomDuChefDeFileRCBI__c == accTemp.name)&&(DDP.Chef_de_file__c == false)){
                	oppTemp.NomDuChefDeFileRCBI__c = NULL; 
        		 	OppToUpdate.add(oppTemp) ;
          	}
          }
        }
        update OppToUpdate;
    } 
    
    
    public static void deleteCDFReporting(Detail_du_Pool__c[] lDetailDuPool){
        List<Opportunity> OppToUpdate = new List<Opportunity>(); 
        
        Set<Id> oppsIds = new Set<Id>();  
        
        for (Detail_du_Pool__c DDP:lDetailDuPool){
            
            oppsIds.add(DDP.ProjetAssocie__c);

        }
        
        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>([SELECT ID, NomDuChefDeFileRCBI__c, Amount, QuotePartNL__c, StatutNL__c,
                                           MontantTotalPoolDeFinancement__c, QuotePartTotalPoolDeFinancement__c, NBChefDeFilePoolDeFinancement__c,
                                           NbDePoolFinancement__c, FraisDeDossier__c, FraisDossierQPNL__c 
                                           FROM Opportunity WHERE Id IN :oppsIds]);
        
        for (Detail_du_Pool__c DDP:lDetailDuPool){ 
            
            Opportunity oppTemp = oppsMap.get(DDP.ProjetAssocie__c);
			if (oppTemp != null){
				oppTemp.NomDuChefDeFileRCBI__c = NULL; 
				OppToUpdate.add(oppTemp) ;
			}
           
        }
        update OppToUpdate;
    } 
    
   /**
    * Méthode appelée à chaque insert/mis à jour d'un détail de pool pour recalculer les champs
    * techniques de son Opportunity (Projet Associe)
    */
    public static void updateOpportunity(Detail_du_Pool__c[] lDetailDuPool, Integer dmlCode){
        
        // Opportunities à mettre à jour
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        //  Set d'ids des objets à traiter
        Set<Id> oppIds = new Set<Id>();
        
        for(Detail_du_Pool__c pool : lDetailDuPool){
            oppIds.add(pool.ProjetAssocie__c);
        }
        
        List<Opportunity> oppsList = [SELECT Id, NomDuChefDeFileRCBI__c, Amount, QuotePartNL__c, StatutNL__c, MontantTotalPoolDeFinancement__c, QuotePartTotalPoolDeFinancement__c, NBChefDeFilePoolDeFinancement__c, NbDePoolFinancement__c, FraisDeDossier__c, FraisDossierQPNL__c FROM Opportunity WHERE Id IN :oppIds];
        
        // Map des Pools existants
        Map<Id, Detail_du_Pool__c> poolsMap = new  Map<Id, Detail_du_Pool__c>([SELECT Id, ProjetAssocie__c, NomDuChefDeFile__c, Quote_part__c, QuotePartNL__c, Statut_NL__c, Chef_de_file__c, FraisDeDossier__c, FraisDossierQPNL__c FROM Detail_du_Pool__c WHERE ProjetAssocie__c IN :oppIds]);
		
        // Liste des pools existants
        List<Detail_du_Pool__c> poolsToIterate = poolsMap.values();
        
        for(Detail_du_Pool__c pool : lDetailDuPool){
        	
            // Dans le cas d'un insert, on ajoute dans la liste (pas dans la map car l'id = null, toutes
            // les nouvelles valeurs vont s'écraser)
            if(dmlCode == 0){
                poolsToIterate.add(pool);
            }
            //Dans le cas d'un update, on travaille avec la Map pour écraser l'objet existant
        	else if(dmlCode == 1){        	
            	poolsMap.put(pool.Id, pool);
            }       
        	// Dans le cas d'une suppression, il faut supprimer les pools de la liste
        	// des Pools Existants
        	else if(dmlCode == 2){
            	poolsMap.remove(pool.Id);
            }
        }
   
        // On choisi la liste à iterer : si on est dans le cas d'une insertion on récupère celle completée
        // précédemment. Sinon, dans le cas d'un update ou d'un delete, on récupère la liste issue de la Map
        if(dmlCode != 0){
            poolsToIterate = poolsMap.values();
        }
        
        for(Opportunity opp : oppsList){     
            
             // On reset toutes les valeurs des champs techniques
             Integer lNbPool = 0;
             Integer lNbChefDeFile = 0;
             Decimal lTotalQuotePart = 0.0;
             Decimal lTotalMontant = 0.0;
             Decimal lQuotePartNL = 0.0;
             String lStatutNL = 'Non';
             Decimal lTotalFraisDeDossier = 0.0;
             Decimal lFraisDossierQPNL = 0.0;
             String lNomChefDeFile = '';
            
             for(Detail_du_Pool__c pool : poolsToIterate){ 
                 
                 if(pool.ProjetAssocie__c == opp.Id){
                     
                    // On compte le nombre de pool de financement
                    lNbPool ++;                    
                    // On vérifie si on est sur un chef de file
                    if(pool.Chef_de_file__c){
                        lNbChefDeFile++;
                        lNomChefDeFile = pool.NomDuChefDeFile__c;
                    }
                    // On compte le total des quotes parts
                    lTotalQuotePart = lTotalQuotePart + pool.Quote_part__c;
                    // On compte le total des montants
                    if(pool.Quote_part__c != null && opp.Amount != null){
                        lTotalMontant = lTotalMontant + (pool.Quote_part__c/100 * opp.Amount ) ; 
                    }
                    
                    // Quote part NL
                    if(pool.QuotePartNL__c != 0){
                        lQuotePartNL = pool.QuotePartNL__c;
                    }
                    // Statut NL
                    if(!String.isBlank(pool.Statut_NL__c) && pool.Statut_NL__c != 'Non'){
                        lStatutNL = pool.Statut_NL__c;
                    }
                    // Frais de Dossier
                    lTotalFraisDeDossier = lTotalFraisDeDossier + pool.FraisDeDossier__c;
                    // Frais Dossier NL
                    if(pool.FraisDossierQPNL__c != 0){
                        lFraisDossierQPNL = pool.FraisDossierQPNL__c;
                    }
                   
                 }       
             }
            
             // On affecte les valeurs à l'opportuity
             opp.NbDePoolFinancement__c = lNbPool;
             opp.NBChefDeFilePoolDeFinancement__c = lNbChefDeFile;
             opp.QuotePartTotalPoolDeFinancement__c = lTotalQuotePart;
             opp.MontantTotalPoolDeFinancement__c = lTotalMontant;
             opp.QuotePartNL__c = lQuotePartNL;
             opp.StatutNL__c = lStatutNL;
             opp.FraisDeDossier__c = lTotalFraisDeDossier;
             opp.FraisDossierQPNL__c = lFraisDossierQPNL;
             opp.NomDuChefDeFileRCBI__c = lNomChefDeFile;
            
             // On ajoute dans la liste à updater
             oppsToUpdate.add(opp);
            
        }
        
        update oppsToUpdate;
    
    }

}