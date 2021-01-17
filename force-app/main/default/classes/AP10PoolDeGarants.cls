public class AP10PoolDeGarants {
	public static void insertPDGReportingCBI(PoolDeGarants__c[] PDGS){
		//List<Opportunity> OppToUpdate = new List<Opportunity>(); 

        
        
        
        // Objets à mettre à jour
        Map<id, Opportunity> mapOppToUpdate = new   Map<id, Opportunity>();
        
        // On récupère l'id des projets associés liés à nos pools
        Set<Id> oppIds = new Set<Id>();
        for(PoolDeGarants__c PDG:PDGS){ 
            oppIds.add(PDG.ProjetAssocie__c);
        }
        
        // Opportunités qui vont être traitées
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id,IDReseauGarant1RCBI__c,IDReseauGarant2RCBI__c,IDReseauGarant3RCBI__c,NomReelDuReseauGarant1RCBI__c,
                                          NomReelDuReseauGarant2RCBI__c,NomReelDuReseauGarant3RCBI__c,ReseauGarant1RCBI__c,ReseauGarant2RCBI__c,
                                          ReseauGarant3RCBI__c,ContreGarantie1percRCBI__c,ContreGarantie2percRCBI__c,
                                          ContreGarantie3percRCBI__c,CommissionDeRisque1percRCBI__c,CommissionDeRisque2percRCBI__c,
                                          CommissionDeRisque3percRCBI__c
                                          FROM Opportunity WHERE Id IN :oppIds]);
        
        
        
        for(PoolDeGarants__c PDG:PDGS){ 
             /** List<Opportunity> lOppBD = [SELECT Id,IDReseauGarant1RCBI__c,IDReseauGarant2RCBI__c,IDReseauGarant3RCBI__c,NomReelDuReseauGarant1RCBI__c,
                                          NomReelDuReseauGarant2RCBI__c,NomReelDuReseauGarant3RCBI__c,ReseauGarant1RCBI__c,ReseauGarant2RCBI__c,
                                          ReseauGarant3RCBI__c,ContreGarantie1percRCBI__c,ContreGarantie2percRCBI__c,
                                          ContreGarantie3percRCBI__c,CommissionDeRisque1percRCBI__c,CommissionDeRisque2percRCBI__c,
                                          CommissionDeRisque3percRCBI__c
                                          FROM Opportunity WHERE Id = :PDG.ProjetAssocie__c];   */
             Opportunity opp = oppMap.get(PDG.ProjetAssocie__c);
        	///Checker si 1 des 3 réseaux apporteur dispo :
        	 
            if(opp != null && (opp.IDReseauGarant1RCBI__c == NULL)||(opp.IDReseauGarant2RCBI__c== NULL)||(opp.IDReseauGarant3RCBI__c== NULL)){
                if(opp.IDReseauGarant1RCBI__c == NULL){ 
                    opp.IDReseauGarant1RCBI__c = PDG.id ;
                    opp.NomReelDuReseauGarant1RCBI__c = PDG.NomReelDuPartenaire__c ;
                    opp.ReseauGarant1RCBI__c =  PDG.NomDuPartenaireTransco__c;
                    opp.ContreGarantie1percRCBI__c =  PDG.QuotePart__c ;
                    opp.CommissionDeRisque1percRCBI__c =  PDG.CommissionDeRisque__c;
                    
                } else if(opp.IDReseauGarant2RCBI__c == NULL){
                    opp.IDReseauGarant2RCBI__c = PDG.id ;
                    opp.NomReelDuReseauGarant2RCBI__c = PDG.NomReelDuPartenaire__c ;
                    opp.ReseauGarant2RCBI__c =  PDG.NomDuPartenaireTransco__c;
                    opp.ContreGarantie2percRCBI__c =  PDG.QuotePart__c ;
                    opp.CommissionDeRisque2percRCBI__c =  PDG.CommissionDeRisque__c;
                   
                } else if(opp.IDReseauGarant3RCBI__c == NULL){ 
                    opp.IDReseauGarant3RCBI__c = PDG.id ;
                    opp.NomReelDuReseauGarant3RCBI__c = PDG.NomReelDuPartenaire__c ;
                    opp.ReseauGarant3RCBI__c =  PDG.NomDuPartenaireTransco__c;
                    opp.ContreGarantie3percRCBI__c =  PDG.QuotePart__c ;
                    opp.CommissionDeRisque3percRCBI__c =  PDG.CommissionDeRisque__c;
                  
                }
                mapOppToUpdate.put(opp.id, opp);
                //OppToUpdate.add(lOppBD[0]) ;
            }        
        }   
        update mapOppToUpdate.values();
   }
    public static void updatePDGReportingCBI(PoolDeGarants__c[] PDGS){
		// Objets à mettre à jour
        Map<id, Opportunity> mapOppToUpdate = new   Map<id, Opportunity>();
        
        // On récupère l'id des projets associés liés à nos pools
        Set<Id> oppIds = new Set<Id>();
        for(PoolDeGarants__c PDG:PDGS){ 
            oppIds.add(PDG.ProjetAssocie__c);
        }
        
        // Opportunités qui vont être traitées
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id,IDReseauGarant1RCBI__c,IDReseauGarant2RCBI__c,IDReseauGarant3RCBI__c,NomReelDuReseauGarant1RCBI__c,
                                          NomReelDuReseauGarant2RCBI__c,NomReelDuReseauGarant3RCBI__c,ReseauGarant1RCBI__c,ReseauGarant2RCBI__c,
                                          ReseauGarant3RCBI__c,ContreGarantie1percRCBI__c,ContreGarantie2percRCBI__c,
                                          ContreGarantie3percRCBI__c,CommissionDeRisque1percRCBI__c,CommissionDeRisque2percRCBI__c,
                                          CommissionDeRisque3percRCBI__c
                                          FROM Opportunity WHERE Id IN :oppIds]);
        
        
        for(PoolDeGarants__c PDG:PDGS){ 
            
            if(oppMap.containsKey(PDG.ProjetAssocie__c)){

            	Opportunity opp = oppMap.get(PDG.ProjetAssocie__c);
             
        		///Checker si 1 des 3 réseaux apporteur dispo :
         		if((opp.IDReseauGarant1RCBI__c == PDG.id)||(opp.IDReseauGarant2RCBI__c== PDG.id)||(opp.IDReseauGarant3RCBI__c== PDG.id)){
                	if(opp.IDReseauGarant1RCBI__c == PDG.id){ 
              
                    	opp.NomReelDuReseauGarant1RCBI__c = PDG.NomReelDuPartenaire__c ;
                    	opp.ReseauGarant1RCBI__c =  PDG.NomDuPartenaireTransco__c;
                    	opp.ContreGarantie1percRCBI__c =  PDG.QuotePart__c ;
                    	opp.CommissionDeRisque1percRCBI__c =  PDG.CommissionDeRisque__c;
                    
                	} else if(opp.IDReseauGarant2RCBI__c == PDG.id){
                  
                    	opp.NomReelDuReseauGarant2RCBI__c = PDG.NomReelDuPartenaire__c ;
                    	opp.ReseauGarant2RCBI__c =  PDG.NomDuPartenaireTransco__c;
                    	opp.ContreGarantie2percRCBI__c =  PDG.QuotePart__c ;
                    	opp.CommissionDeRisque2percRCBI__c =  PDG.CommissionDeRisque__c;
                   
                	} else if(opp.IDReseauGarant3RCBI__c == PDG.id){ 
                     
                    	opp.NomReelDuReseauGarant3RCBI__c = PDG.NomReelDuPartenaire__c ;
                    	opp.ReseauGarant3RCBI__c =  PDG.NomDuPartenaireTransco__c;
                    	opp.ContreGarantie3percRCBI__c =  PDG.QuotePart__c ;
                    	opp.CommissionDeRisque3percRCBI__c =  PDG.CommissionDeRisque__c;
                  
                	}
              		mapOppToUpdate.put(opp.id, opp);
            	} 
            } // End IF (oppMap.containsKey(PDG.ProjetAssocie__c))
        }   
        update mapOppToUpdate.values();
    }
    
    public static void deletePDGReportingCBI(PoolDeGarants__c[] PDGS){
        // Objets à mettre à jour
        Map<id, Opportunity> mapOppToUpdate = new   Map<id, Opportunity>();
        
        // On récupère l'id des projets associés liés à nos pools
        Set<Id> oppIds = new Set<Id>();
        for(PoolDeGarants__c PDG:PDGS){ 
            oppIds.add(PDG.ProjetAssocie__c);
        }
        
        // Opportunités qui vont être traitées
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id,IDReseauGarant1RCBI__c,IDReseauGarant2RCBI__c,IDReseauGarant3RCBI__c,NomReelDuReseauGarant1RCBI__c,
                                          NomReelDuReseauGarant2RCBI__c,NomReelDuReseauGarant3RCBI__c,ReseauGarant1RCBI__c,ReseauGarant2RCBI__c,
                                          ReseauGarant3RCBI__c,ContreGarantie1percRCBI__c,ContreGarantie2percRCBI__c,
                                          ContreGarantie3percRCBI__c,CommissionDeRisque1percRCBI__c,CommissionDeRisque2percRCBI__c,
                                          CommissionDeRisque3percRCBI__c
                                          FROM Opportunity WHERE Id IN :oppIds]);
        
        for(PoolDeGarants__c PDG:PDGS){ 
            
            if(oppMap.containsKey(PDG.ProjetAssocie__c)){

            	Opportunity opp = oppMap.get(PDG.ProjetAssocie__c);
             
        		///Checker si 1 des 3 réseaux apporteur dispo :
         		if((opp.IDReseauGarant1RCBI__c == PDG.id)||(opp.IDReseauGarant2RCBI__c== PDG.id)||(opp.IDReseauGarant3RCBI__c== PDG.id)){
                	if(opp.IDReseauGarant1RCBI__c == PDG.id){ 
                    	opp.IDReseauGarant1RCBI__c  = NULL ;
                    	opp.NomReelDuReseauGarant1RCBI__c = NULL ;
                    	opp.ReseauGarant1RCBI__c = NULL;
                    	opp.ContreGarantie1percRCBI__c = NULL ;
                    	opp.CommissionDeRisque1percRCBI__c =  NULL;
                    
                	} else if(opp.IDReseauGarant2RCBI__c == PDG.id){
                    	opp.IDReseauGarant2RCBI__c   = NULL ;
                    	opp.NomReelDuReseauGarant2RCBI__c = NULL ;
                    	opp.ReseauGarant2RCBI__c =  NULL;
                    	opp.ContreGarantie2percRCBI__c =  NULL;
                    	opp.CommissionDeRisque2percRCBI__c = NULL;
                   
                	} else if(opp.IDReseauGarant3RCBI__c == PDG.id){ 
                    	opp.IDReseauGarant3RCBI__c   = NULL ; 
                    	opp.NomReelDuReseauGarant3RCBI__c = NULL ;
                    	opp.ReseauGarant3RCBI__c = NULL;
                    	opp.ContreGarantie3percRCBI__c = NULL ;
                    	opp.CommissionDeRisque3percRCBI__c = NULL;
                  
                	}
             		mapOppToUpdate.put(opp.id, opp);
            	}      
            } // End IF (oppMap.containsKey(PDG.ProjetAssocie__c))
        }   
        update mapOppToUpdate.values();
    }
    
}