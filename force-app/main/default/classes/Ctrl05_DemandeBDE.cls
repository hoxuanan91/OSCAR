public class Ctrl05_DemandeBDE {

    public Opportunity projetAssocie { get; set;}
    
    // Tiers
    public Account tiersPrincipal { get; set;}
    public Account teteDeGroupe { get; set;}
    public Account tiersEnRisqueProfile { get; set;}
	//Demande BDE
    public DemandeBDE__c DemandeBDEtiersPrincipal{ get; set;} 
    public DemandeBDE__c DemandeBDEteteDeGroupe{ get; set;}
    public DemandeBDE__c DemandeBDEtiersEnRisqueProfile{ get; set;}
	//checkboxes
	public boolean tiersSynthese { get; set;}
    public boolean tiersBilan { get; set;}
    public boolean teteSynthese { get; set;}
    public boolean teteBilan { get; set;}
    public boolean tiersRisqueSynthese { get; set;}
    public boolean tiersRisqueBilan { get; set;}
	//Link
	public String IDDuProjetAssocie { get; set;}
    
    public Ctrl05_DemandeBDE(ApexPages.StandardController controller){
        IDDuProjetAssocie = ApexPages.currentPage().getParameters().get('ID') ;
        //checkboxes cochées par défaut
        tiersSynthese = true;
        tiersBilan = true;
       	teteSynthese = true;
        teteBilan = true;
        tiersRisqueSynthese = true;     
        tiersRisqueBilan = true;
        
        projetAssocie = new Opportunity();
        //
        // On prend par défaut le premier projet associé remonté
        List<Opportunity> projetAssocieList = [SELECT Id, AccountId, TiersEnRisqueProfile__c, TeteDeGroupe__c, NomDuProjet__c  FROM Opportunity WHERE Id =:IDDuProjetAssocie LIMIT 1];
        
        if(projetAssocieList.size() != 0){
            projetAssocie = projetAssocieList[0];
        }

        List<Account> NewListTiers = [SELECT Id, Name, N_SIREN__c FROM Account WHERE ID = :projetAssocie.AccountId OR ID = :projetAssocie.TeteDeGroupe__c OR ID = :projetAssocie.TiersEnRisqueProfile__c];
    	// N_SIREN__c <> '999999999'
    	List<Account> lTiersList  = new List<Account>(); 
  
           for(Account acc:NewListTiers) {
 
            if((acc.N_SIREN__c !=  '999999999')&&(acc.N_SIREN__c != null)){
                System.debug('N_SIREN__c' + acc.N_SIREN__c);
                lTiersList.add(acc);
            } 
        }
        
        
        DemandeBDEteteDeGroupe = new DemandeBDE__c();
        DemandeBDEtiersEnRisqueProfile = new DemandeBDE__c(); 
        DemandeBDEtiersPrincipal= new DemandeBDE__c(); 
        
        //Ids des comptes
        Set<Id> accountsIds = new Set<Id>();
        for(Account lTiers : lTiersList){
            
            accountsIds.add(lTiers.Id);
        
        }

        Map<Id, DemandeBDE__c> demandesMap = new Map<Id, DemandeBDE__c>();
        for(DemandeBDE__c demande : [SELECT Bilan__c, Synthese__c, ProjetAssocie__c, Tiers__c, DateDemandeSynthese__c, 
                                                                         		DateDemandeBilan__c ,DemandeSyntheseEnvoyee__c, DemandeBilanEnvoyee__c,
                                                                         		DateReceptionBilan__c, DateReceptionSynthese__c 
                                           								 FROM DemandeBDE__c 
                                                                         WHERE Tiers__c IN :accountsIds and  ProjetAssocie__c =: projetAssocie.id]){
                       demandesMap.put(demande.Tiers__c, demande);
            
        }
        
        
        for(Account lTiers : lTiersList){    
                if(lTiers.Id == projetAssocie.AccountId){
                    
                    tiersPrincipal = lTiers;
                    DemandeBDEtiersPrincipal = demandesMap.get(lTiers.Id);

                } else if(lTiers.Id == projetAssocie.TeteDeGroupe__c){
                    
                    teteDeGroupe = lTiers;
                    DemandeBDEteteDeGroupe = demandesMap.get(lTiers.Id);

                } else if(lTiers.Id == projetAssocie.TiersEnRisqueProfile__c){
                    tiersEnRisqueProfile = lTiers;
                    DemandeBDEtiersEnRisqueProfile = demandesMap.get(lTiers.Id);
                }
           }
    }

    public PageReference save(){
		
        // Demandes BDE qui vont être créées
        List<DemandeBDE__c> listeDemande = new List<DemandeBDE__c>();
        List<DemandeBDE__c> listeDemandeUpdate = new List<DemandeBDE__c>();
        if((tiersSynthese || tiersBilan) && tiersPrincipal != null && projetAssocie != null){
            List<DemandeBDE__c> LDemandeBDEtiersPrincipal = [SELECT Bilan__c, Synthese__c, ProjetAssocie__c, Tiers__c, DateDemandeSynthese__c, DateDemandeBilan__c 
            				                                  FROM DemandeBDE__c Where Tiers__c =: tiersPrincipal.id and  ProjetAssocie__c =: projetAssocie.id LIMIT 1];
            if(LDemandeBDEtiersPrincipal.size() == 0 ){
					DemandeBDE__c lDemande = new DemandeBDE__c(Synthese__c = tiersSynthese, Bilan__c = tiersBilan, Tiers__c = tiersPrincipal.Id, ProjetAssocie__c = projetAssocie.Id);
          			listeDemande.add(lDemande);
            }
            if(LDemandeBDEtiersPrincipal.size() != 0 ){
                DemandeBDE__c lDemande = LDemandeBDEtiersPrincipal[0];
                if((lDemande.Bilan__c == false)&&(tiersBilan == true)){ 
                	lDemande.Bilan__c = true;     
                }
                if((lDemande.Synthese__c == false)&&(tiersSynthese == true)){ 
                	lDemande.Synthese__c = true;     
                }
           		listeDemandeUpdate.add(lDemande);
            }
            
        }
        if((teteSynthese || teteBilan) && teteDeGroupe != null && projetAssocie != null){
            List<DemandeBDE__c> LDemandeBDEteteDeGroupe = [SELECT Bilan__c, Synthese__c, ProjetAssocie__c, Tiers__c, DateDemandeSynthese__c, DateDemandeBilan__c 
            				                                  FROM DemandeBDE__c Where Tiers__c =: teteDeGroupe.id and  ProjetAssocie__c =: projetAssocie.id LIMIT 1];
            if(LDemandeBDEteteDeGroupe.size() == 0 ){
					 DemandeBDE__c lDemande = new DemandeBDE__c(Synthese__c = teteSynthese, Bilan__c = teteBilan, Tiers__c = teteDeGroupe.Id, ProjetAssocie__c = projetAssocie.Id);
           			 listeDemande.add(lDemande);
            }
            if(LDemandeBDEteteDeGroupe.size() != 0 ){
                DemandeBDE__c lDemande = LDemandeBDEteteDeGroupe[0];
                if((lDemande.Bilan__c == false)&&(teteBilan == true)){ 
                	lDemande.Bilan__c = true;     
                }
                if((lDemande.Synthese__c == false)&&(teteSynthese == true)){ 
                	lDemande.Synthese__c = true;     
                }
           		listeDemandeUpdate.add(lDemande);
            }
            
        }
        if((tiersRisqueSynthese || tiersRisqueBilan) && tiersEnRisqueProfile != null && projetAssocie != null){
          
            List<DemandeBDE__c> LDemandeBDEtiersEnRisqueProfile = [SELECT Bilan__c, Synthese__c, ProjetAssocie__c, Tiers__c, DateDemandeSynthese__c, DateDemandeBilan__c 
            				                                  FROM DemandeBDE__c Where Tiers__c =: tiersEnRisqueProfile.id and  ProjetAssocie__c =: projetAssocie.id LIMIT 1];
            if(LDemandeBDEtiersEnRisqueProfile.size() == 0 ){
					  DemandeBDE__c lDemande = new DemandeBDE__c(Synthese__c = tiersRisqueSynthese, Bilan__c = tiersRisqueBilan, Tiers__c = tiersEnRisqueProfile.Id, ProjetAssocie__c = projetAssocie.Id);
           			   listeDemande.add(lDemande);
            }
            if(LDemandeBDEtiersEnRisqueProfile.size() != 0 ){
                DemandeBDE__c lDemande = LDemandeBDEtiersEnRisqueProfile[0];
                if((lDemande.Bilan__c == false)&&(tiersRisqueBilan == true)){ 
                	lDemande.Bilan__c = true;     
                }
                if((lDemande.Synthese__c == false)&&(tiersRisqueSynthese == true)){ 
                	lDemande.Synthese__c = true;     
                }
           		listeDemandeUpdate.add(lDemande);
            }
            
        }
        
        insert listeDemande;
  		update listeDemandeUpdate;
        PageReference pageRef = new PageReference('/'+ApexPages.currentPage().getParameters().get('ID'));      
        
      //  pageRef.getParameters().put('id',); 
        return PageRef.setRedirect(True);
        
//        return null;

    }
}