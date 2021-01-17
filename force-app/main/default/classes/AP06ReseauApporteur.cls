public class AP06ReseauApporteur {

   	/**
   	 * Récupère le reseau d'appartenance du réseau apporteur pour le copier dans le projet associé (opportunité)
   	 * 
	 */
  public static void recupererReseauApporteur(ReseauApporteur__c[] reseaux){
        
      // Map à mettre à jour
      Map<Id,Opportunity> oppToUpdate = new Map<Id,Opportunity>();
      
      // Ids des opportunités à mettre à jour
      Set<Id> oppIds = new Set<Id>();
		
      for(ReseauApporteur__c lReseau : reseaux){
          
         oppIds.add(lReseau.NomDuProjetAssocie__c);
      }
      
       // Maps et listes des objets à traiter
      Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id, ReseauApporteurPrincipal__c, NbReseauApporteur__c, NomApporteurPrincipal__c FROM Opportunity WHERE Id IN :oppIds]);
      List<ReseauApporteur__c> reseauList = [SELECT Id, ReseauDAppartenance__c, NomReelDuReseauApporteur__c, NomDuProjetAssocie__c, ApporteurPrincipal__c FROM ReseauApporteur__c WHERE NomDuProjetAssocie__c IN :oppIds];
      
      for(ReseauApporteur__c lReseau : reseaux){
          
          // Opp à mettre à jour
          Opportunity opp = oppMap.get(lReseau.NomDuProjetAssocie__c);
          // Liste des reseaux liés à opp
          List<ReseauApporteur__c> reseauLinkToOpp = new List<ReseauApporteur__c>();
          // Apporteur Principal
          ReseauApporteur__c apporteurPrincipal;
          
          if(opp != null){
              
              // On parcoure tous les réseaux et on récupère ceux liés à opp
              for(ReseauApporteur__c lReseau2 : reseauList){
                  if(lReseau2.NomDuProjetAssocie__c == opp.id){
                      reseauLinkToOpp.add(lReseau2);
                      //Si le reseau est apporteur principal, on le stocke dans une variable
                      if(lReseau2.ApporteurPrincipal__c){
                          apporteurPrincipal = lReseau2;
                      }
                  }
              }
              // Si aucun reseau apporteur, on vide les champs sur l'opp
              if(reseauLinkToOpp.size() == 0){
                  opp.ReseauApporteurPrincipal__c = null;
                  opp.NomApporteurPrincipal__c = null;
              }
              // Si un seul reseau apporteur pour opp, il est le réseau apporteur principal
              if(reseauLinkToOpp.size() == 1){
                  opp.ReseauApporteurPrincipal__c = reseauLinkToOpp[0].ReseauDAppartenance__c;
                  opp.NomApporteurPrincipal__c = reseauLinkToOpp[0].NomReelDuReseauApporteur__c;
              }
              // Si plusieurs reseaux apporteurs, on prend le reseau d'appartenance du réseau principal
              if(reseauLinkToOpp.size() > 1 && apporteurPrincipal != null){
                  opp.ReseauApporteurPrincipal__c = apporteurPrincipal.ReseauDAppartenance__c;
                  opp.NomApporteurPrincipal__c = apporteurPrincipal.NomReelDuReseauApporteur__c;
              }
              // Si plusieurs reseaux apporteurs et aucun reseau principal
              if(reseauLinkToOpp.size() > 1 && apporteurPrincipal == null){
                  opp.ReseauApporteurPrincipal__c = null;
                  opp.NomApporteurPrincipal__c = null;
              }
              
              
              // on ajoute dans la Map à mettre à jour
              oppToUpdate.put(opp.Id, opp);
              
          }
      }
      
      update oppToUpdate.values();

    }
        public static void cocherReseauApporteur(ReseauApporteur__c[] reseaux){
            List<Opportunity> OppToUpdate = new List<Opportunity>(); 
            
            // Ids des opportunités à mettre à jour
      		Set<Id> oppIds = new Set<Id>();
		
      		for(ReseauApporteur__c lReseau : reseaux){
          
         		oppIds.add(lReseau.NomDuProjetAssocie__c);
      		}
         
            // Maps et listes des objets à traiter
      		Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id, NbReseauApporteur__c,ApporteurCEPresent__c,ApporteurBPPresent__c  FROM Opportunity WHERE Id IN :oppIds]);
            
            for(ReseauApporteur__c RA:reseaux){ 
                
                Opportunity opp = oppMap.get(RA.NomDuProjetAssocie__c);
                
                if(RA.ReseauDAppartenance__c == 'Caisse d\'Épargne'){
                	 opp.ApporteurCEPresent__c=true;	
                } else if(RA.ReseauDAppartenance__c == 'Banque Populaire') {
                     opp.ApporteurBPPresent__c=true;	
                } 
                
                oppMap.put(opp.Id, opp);
                //update lOppBD[0];
            } 
            
            update oppMap.values();
    }
    
    
     public static void decocherReseauApporteur(ReseauApporteur__c[] reseaux){
            
   
      		// Ids des opportunités à mettre à jour
      		Set<Id> oppIds = new Set<Id>();
		
      		for(ReseauApporteur__c lReseau : reseaux){
          
         		oppIds.add(lReseau.NomDuProjetAssocie__c);
      		}
         
            // Maps et listes des objets à traiter
      		Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id, NbReseauApporteur__c,ApporteurCEPresent__c,ApporteurBPPresent__c FROM Opportunity WHERE Id IN :oppIds]);
     		List<ReseauApporteur__c> reseauList = [SELECT Id, ReseauDAppartenance__c, NomReelDuReseauApporteur__c, NomDuProjetAssocie__c, ApporteurPrincipal__c FROM ReseauApporteur__c WHERE NomDuProjetAssocie__c IN :oppIds];
         
         
            for(ReseauApporteur__c RA:reseaux){
                Integer NbReseauApporteurCE = 0;
                Integer NbReseauApporteurBP = 0;
                
                Opportunity opp = oppMap.get(RA.NomDuProjetAssocie__c);

                List<ReseauApporteur__c> lReseaux = new List<ReseauApporteur__c>();
                for(ReseauApporteur__c res : reseauList){
                    if(res.NomDuProjetAssocie__c == opp.Id){
                        lReseaux.add(res);
                    }
                }
                
            	for(ReseauApporteur__c eachRA:lReseaux){
                	if(eachRA.ReseauDAppartenance__c == 'Caisse d\'Épargne'){
                	 	NbReseauApporteurCE++;
                	} else if(eachRA.ReseauDAppartenance__c == 'Banque Populaire') {
                     	NbReseauApporteurBP++;
                	} 
                }
                if(NbReseauApporteurCE > 0) {
                     opp.ApporteurCEPresent__c=true;	
                }else {
                     opp.ApporteurCEPresent__c=false;	
                }
                if(NbReseauApporteurBP > 0) {
                     opp.ApporteurBPPresent__c=true;	
                } else {
                     opp.ApporteurBPPresent__c=false;	
                }

                oppMap.put(opp.Id, opp);
            } 
            update oppMap.values();
    }
    
    
    public static void pastEmailChargeAffaireToOpportunity(ReseauApporteur__c[] reseaux){
        
        // Map des opps à update
        Map<Id, Opportunity> oppsToUpdate = new Map<Id, Opportunity>();
        
        
        // Ids des objets à taiter
        Set<Id> oppsIds = new Set<Id>();
        Set<Id> chargesAffairesIds = new Set<Id>();
        
        for(ReseauApporteur__c RA : reseaux){
            
            oppsIds.add(RA.NomDuProjetAssocie__c);
     
        }
        
        //Map des opportunités liées aux Reseaux Apporters triggerés
        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>([SELECT Id, NbReseauApporteur__c FROM Opportunity WHERE Id IN :oppsIds]);
     	List<ReseauApporteur__c> reseauList = [SELECT Id, ReseauDAppartenance__c, ChargeDAffaire__c, NomDuProjetAssocie__c FROM ReseauApporteur__c WHERE NomDuProjetAssocie__c IN :oppsIds];
        
        // On récupères les ids de tous les contacts liés à tous les RA triggerés et RA associés
        for(ReseauApporteur__c RA : reseauList){
            
            chargesAffairesIds.add(RA.ChargeDAffaire__c);
            
        }
        
        //Record Type du Contact
        RecordType rtContact = [SELECT id  FROM RecordType where DeveloperName = 'CBIReseau' and SobjectType = 'Contact' LIMIT 1]; 
        //Map des contacts liées aux Reseaux Apporters triggerés et reseaux liés à la même opp
        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT id, Email, RecordTypeId FROM Contact WHERE RecordTypeId = :rtContact.Id AND Id IN :chargesAffairesIds]);
        
   
		for(ReseauApporteur__c RA : reseaux){ 
            		
            Opportunity opp = oppsMap.get(RA.NomDuProjetAssocie__c);
          
            List<ReseauApporteur__c> lReseaux = new List<ReseauApporteur__c>();
            List<Contact> lContact = new List<Contact>();            

            for(ReseauApporteur__c res : reseauList){
                    if(res.NomDuProjetAssocie__c == opp.Id && res.ChargeDAffaire__c != null){
                		lContact.add(contactsMap.get(res.ChargeDAffaire__c));    
                }
                
            }
            opp.EmailChargeDAffaireN1__c = NULL;
            opp.EmailChargeDAffaireN2__c = NULL;
            opp.EmailChargeDAffaireN3__c = NULL;
            opp.EmailChargeDAffaireN4__c = NULL;
            opp.EmailChargeDAffaireN5__c = NULL;
            opp.EmailChargeDAffaireN6__c = NULL;
            opp.EmailChargeDAffaireN7__c = NULL;
            opp.EmailChargeDAffaireN8__c = NULL;
            opp.EmailChargeDAffaireN9__c = NULL;
            opp.EmailChargeDAffaireN10__c = NULL;
      
            for(integer j=0; j<lContact.size();j++ ){
                if(j == 0 ){
                    opp.EmailChargeDAffaireN1__c = lContact[j].Email;
                }else if(j == 1 ){            
                    opp.EmailChargeDAffaireN2__c = lContact[j].Email;
                }else if(j == 2){
                    opp.EmailChargeDAffaireN3__c = lContact[j].Email;
                }else if(j == 3){
                    opp.EmailChargeDAffaireN4__c = lContact[j].Email;
                }else if(j == 4){
                    opp.EmailChargeDAffaireN5__c = lContact[j].Email;
                }else if(j == 5){
                    opp.EmailChargeDAffaireN6__c = lContact[j].Email;
                }else if(j == 6){
                    opp.EmailChargeDAffaireN7__c = lContact[j].Email;
                }else if(j == 7){
                    opp.EmailChargeDAffaireN8__c = lContact[j].Email;
                }else if(j == 8){
                    opp.EmailChargeDAffaireN9__c = lContact[j].Email;
                }else if(j == 9){
                    opp.EmailChargeDAffaireN10__c = lContact[j].Email;
                }
            }
        	oppsToUpdate.put(opp.Id, opp);
      }
        
        update oppsToUpdate.values();
   }
            
            
	public static void insertRaReportingCBI(ReseauApporteur__c[] reseaux){
        
        //Ids des opportunités liées aux réseaux
        Set<Id> oppsIds = new Set<Id>();
        for(ReseauApporteur__c RA:reseaux){
            oppsIds.add(RA.NomDuProjetAssocie__c);           
        }
        
        //Map des opportunites à mettre à jour
        Map<Id, Opportunity> oppsMaps = new Map<Id, Opportunity>([SELECT Id, IdDossierApport1RCBI__c,IdDossierApport2RCBI__c,IdDossierApport3RCBI__c,Agence1RCBI__c,Agence2RCBI__c,
                                            Agence3RCBI__c,ChargeDAffaires1RCBI__c,ChargeDAffaires2RCBI__c,ChargeDAffaires3RCBI__c,CommissionDApport1RCBI__c,
                                            CommissionDApport2RCBI__c,CommissionDApport3RCBI__c,IDReseauApporteur1RCBI__c,IDReseauApporteur2RCBI__c,
                                            IDReseauApporteur3RCBI__c,
                                            ReseauApporteur1RCBI__c,ReseauApporteur2RCBI__c,ReseauApporteur3RCBI__c,NomReelDuReseauApporteur1RCBI__c,
                                            NomReelDuReseauApporteur2RCBI__c,  NomReelDuReseauApporteur3RCBI__c
                                            FROM Opportunity WHERE Id IN :oppsIds]);
        

        for(ReseauApporteur__c RA:reseaux){
            
             Opportunity opp =  oppsMaps.get(RA.NomDuProjetAssocie__c);
        	///Checker si 1 des 3 réseaux apporteur dispo :
        	 
            if(opp != null || (opp.IDReseauApporteur1RCBI__c == NULL)||(opp.IDReseauApporteur2RCBI__c== NULL)||(opp.IDReseauApporteur3RCBI__c== NULL)){
                if(opp.IDReseauApporteur1RCBI__c == NULL){ 
                    opp.IDReseauApporteur1RCBI__c = RA.id ;
                    opp.IdDossierApport1RCBI__c = RA.name;                 
                    opp.Agence1RCBI__c = RA.NomDeLAgence__c ;
                    opp.ChargeDAffaires1RCBI__c = RA.NomDuChargeDAffaire__c;
                    opp.CommissionDApport1RCBI__c = RA.CommissiondApport__c;
                    opp.ReseauApporteur1RCBI__c   = RA.NomDeLaBanqueCaisseTransco__c ;
                    opp.NomReelDuReseauApporteur1RCBI__c   = RA.NomReelDuReseauApporteur__c ;
                } else if(opp.IDReseauApporteur2RCBI__c == NULL){
                    opp.IDReseauApporteur2RCBI__c = RA.id ;
                    opp.IdDossierApport2RCBI__c = RA.name;                 
                    opp.Agence2RCBI__c = RA.NomDeLAgence__c ;
                    opp.ChargeDAffaires2RCBI__c = RA.NomDuChargeDAffaire__c;
                    opp.CommissionDApport2RCBI__c = RA.CommissiondApport__c; 
                    opp.ReseauApporteur2RCBI__c   = RA.NomDeLaBanqueCaisseTransco__c ;
                    opp.NomReelDuReseauApporteur2RCBI__c   = RA.NomReelDuReseauApporteur__c ;
                } else if(opp.IDReseauApporteur3RCBI__c == NULL){ 
                    opp.IDReseauApporteur3RCBI__c = RA.id ;
                    opp.IdDossierApport3RCBI__c = RA.name;                 
                    opp.Agence3RCBI__c = RA.NomDeLAgence__c ;
                    opp.ChargeDAffaires3RCBI__c = RA.NomDuChargeDAffaire__c;
                    opp.CommissionDApport3RCBI__c = RA.CommissiondApport__c; 
                    opp.ReseauApporteur3RCBI__c   = RA.NomDeLaBanqueCaisseTransco__c ;
                    opp.NomReelDuReseauApporteur3RCBI__c   = RA.NomReelDuReseauApporteur__c ;
                }
                oppsMaps.put(opp.Id, opp);
            }        
        }   
        update oppsMaps.values();
   }
  	public static void updateRaReportingCBI(ReseauApporteur__c[] reseaux){
		
        //Ids des opportunités liées aux réseaux
        Set<Id> oppsIds = new Set<Id>();
        for(ReseauApporteur__c RA:reseaux){
            oppsIds.add(RA.NomDuProjetAssocie__c);           
        }
        
        //Map des opportunites à mettre à jour
        Map<Id, Opportunity> oppsMaps = new Map<Id, Opportunity>([SELECT Id, IdDossierApport1RCBI__c,IdDossierApport2RCBI__c,IdDossierApport3RCBI__c,Agence1RCBI__c,Agence2RCBI__c,
                                            Agence3RCBI__c,ChargeDAffaires1RCBI__c,ChargeDAffaires2RCBI__c,ChargeDAffaires3RCBI__c,CommissionDApport1RCBI__c,
                                            CommissionDApport2RCBI__c,CommissionDApport3RCBI__c,IDReseauApporteur1RCBI__c,IDReseauApporteur2RCBI__c,
                                            IDReseauApporteur3RCBI__c,
                                            ReseauApporteur1RCBI__c,ReseauApporteur2RCBI__c,ReseauApporteur3RCBI__c,NomReelDuReseauApporteur1RCBI__c,
                                            NomReelDuReseauApporteur2RCBI__c,  NomReelDuReseauApporteur3RCBI__c
                                            FROM Opportunity WHERE Id IN :oppsIds]);
        
        
        for(ReseauApporteur__c RA:reseaux){ 

            Opportunity opp =  oppsMaps.get(RA.NomDuProjetAssocie__c);  
        	///Checker si 1 des 3 réseaux apporteur dispo :
        	 
            if(opp != null || (opp.IDReseauApporteur1RCBI__c == RA.id)||(opp.IDReseauApporteur2RCBI__c== RA.id)||(opp.IDReseauApporteur3RCBI__c== RA.id)){
                if(opp.IDReseauApporteur1RCBI__c == RA.id){ 
                    opp.IDReseauApporteur1RCBI__c = RA.id;
                    opp.IdDossierApport1RCBI__c = RA.name;                 
                    opp.Agence1RCBI__c = RA.NomDeLAgence__c ;
                    opp.ChargeDAffaires1RCBI__c = RA.NomDuChargeDAffaire__c;
                    opp.CommissionDApport1RCBI__c = RA.CommissiondApport__c;
                    opp.ReseauApporteur1RCBI__c   = RA.NomDeLaBanqueCaisseTransco__c ;
                    opp.NomReelDuReseauApporteur1RCBI__c   = RA.NomReelDuReseauApporteur__c ;
                } else if(opp.IDReseauApporteur2RCBI__c== RA.id){
                    opp.IDReseauApporteur2RCBI__c = RA.id ;
                    opp.IdDossierApport2RCBI__c = RA.name;                 
                    opp.Agence2RCBI__c = RA.NomDeLAgence__c ;
                    opp.ChargeDAffaires2RCBI__c = RA.NomDuChargeDAffaire__c;
                    opp.CommissionDApport2RCBI__c = RA.CommissiondApport__c; 
                    opp.ReseauApporteur2RCBI__c   = RA.NomDeLaBanqueCaisseTransco__c ;
                    opp.NomReelDuReseauApporteur2RCBI__c   = RA.NomReelDuReseauApporteur__c ;
                } else if(opp.IDReseauApporteur3RCBI__c== RA.id){ 
                    opp.IDReseauApporteur3RCBI__c = RA.id ;
                    opp.IdDossierApport3RCBI__c = RA.name;                 
                    opp.Agence3RCBI__c = RA.NomDeLAgence__c ;
                    opp.ChargeDAffaires3RCBI__c = RA.NomDuChargeDAffaire__c;
                    opp.CommissionDApport3RCBI__c = RA.CommissiondApport__c; 
                    opp.ReseauApporteur3RCBI__c   = RA.NomDeLaBanqueCaisseTransco__c ;
                    opp.NomReelDuReseauApporteur3RCBI__c   = RA.NomReelDuReseauApporteur__c ;
                }
                oppsMaps.put(opp.Id, opp);
            }        
        }   
        update oppsMaps.values();
   }  
    
      	public static void deleteRaReportingCBI(ReseauApporteur__c[] reseaux){
		
        //Ids des opportunités liées aux réseaux
        Set<Id> oppsIds = new Set<Id>();
        for(ReseauApporteur__c RA:reseaux){
            oppsIds.add(RA.NomDuProjetAssocie__c);           
        }
        
        //Map des opportunites à mettre à jour
        Map<Id, Opportunity> oppsMaps = new Map<Id, Opportunity>([SELECT Id, IdDossierApport1RCBI__c,IdDossierApport2RCBI__c,IdDossierApport3RCBI__c,Agence1RCBI__c,Agence2RCBI__c,
                                            Agence3RCBI__c,ChargeDAffaires1RCBI__c,ChargeDAffaires2RCBI__c,ChargeDAffaires3RCBI__c,CommissionDApport1RCBI__c,
                                            CommissionDApport2RCBI__c,CommissionDApport3RCBI__c,IDReseauApporteur1RCBI__c,IDReseauApporteur2RCBI__c,
                                            IDReseauApporteur3RCBI__c,
                                            ReseauApporteur1RCBI__c,ReseauApporteur2RCBI__c,ReseauApporteur3RCBI__c,NomReelDuReseauApporteur1RCBI__c,
                                            NomReelDuReseauApporteur2RCBI__c,  NomReelDuReseauApporteur3RCBI__c
                                            FROM Opportunity WHERE Id IN :oppsIds]);
            
            
        for(ReseauApporteur__c RA:reseaux){ 
           
            Opportunity opp =  oppsMaps.get(RA.NomDuProjetAssocie__c); 
        	 
            if(opp != null && (opp.IDReseauApporteur1RCBI__c == RA.id)||(opp.IDReseauApporteur2RCBI__c== RA.id)||(opp.IDReseauApporteur3RCBI__c== RA.id)){
                if(opp.IDReseauApporteur1RCBI__c == RA.id){ 
                    opp.IDReseauApporteur1RCBI__c = NULL;
                    opp.IdDossierApport1RCBI__c = NULL;                 
                    opp.Agence1RCBI__c = NULL;
                    opp.ChargeDAffaires1RCBI__c = NULL;
                    opp.CommissionDApport1RCBI__c =NULL;
                    opp.ReseauApporteur1RCBI__c   = NULL;
                    opp.NomReelDuReseauApporteur1RCBI__c   = NULL ;
                } else if(opp.IDReseauApporteur2RCBI__c== RA.id){
                    opp.IDReseauApporteur2RCBI__c = NULL ;
                    opp.IdDossierApport2RCBI__c =NULL;                 
                    opp.Agence2RCBI__c = NULL;
                    opp.ChargeDAffaires2RCBI__c = NULL;
                    opp.CommissionDApport2RCBI__c = NULL; 
                    opp.ReseauApporteur2RCBI__c   = NULL ;
                    opp.NomReelDuReseauApporteur2RCBI__c   = NULL ;
                } else if(opp.IDReseauApporteur3RCBI__c== RA.id){ 
                    opp.IDReseauApporteur3RCBI__c =NULL;
                    opp.IdDossierApport3RCBI__c = NULL;                 
                    opp.Agence3RCBI__c = NULL ;
                    opp.ChargeDAffaires3RCBI__c =NULL;
                    opp.CommissionDApport3RCBI__c = NULL; 
                    opp.ReseauApporteur3RCBI__c   = NULL ;
                    opp.NomReelDuReseauApporteur3RCBI__c   =NULL ;
                }
                oppsMaps.put(opp.Id, opp);
            }        
        }   
        update oppsMaps.values();
   } 
}