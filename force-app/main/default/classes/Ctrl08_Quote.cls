public class Ctrl08_Quote {
  public String IDCalc{get; set; } 
  public Integer   CalculetteROEValidee{get; set ;  }
  public Integer   NbPropositionCommerciale{get; set;  }
  public Integer   NbPropositionCommercialeEnvoye{get; set ;  }
  public Integer   CasTypeDeProposition{get; set ;  }    
    
  public Ctrl08_Quote(ApexPages.StandardController controller){
		IDCalc =  ApexPages.currentPage().getParameters().get('ID');
        NbPropositionCommerciale =  Integer.valueOf(ApexPages.currentPage().getParameters().get('NbPropositionCommerciale'));
        NbPropositionCommercialeEnvoye =  Integer.valueOf(ApexPages.currentPage().getParameters().get('NbPropositionCommercialeEnvoye'));
        CalculetteROEValidee =  Integer.valueOf(ApexPages.currentPage().getParameters().get('CalculetteROEValidee'));
     
      
      if((getNbPropositionCommercialeOnProjetAssocie(IDCalc) == false)||(NbPropositionCommerciale==1)) {
    /*      if((NbPropositionCommerciale == 0)&&(NbPropositionCommercialeEnvoye == 0)&&(CalculetteROEValidee==1)){
          	CasTypeDeProposition = 1;
          } else if((NbPropositionCommerciale==1)&&(NbPropositionCommercialeEnvoye== 0)&&(CalculetteROEValidee==1)){
              CasTypeDeProposition = 2;
          } else if((NbPropositionCommerciale==1)&&(NbPropositionCommercialeEnvoye== 1)&&(CalculetteROEValidee==1)){
               CasTypeDeProposition = 3;
      	  }  else if(CalculetteROEValidee==0){
               CasTypeDeProposition = 5;           
      	  } */
           if((NbPropositionCommerciale == 0)&&(NbPropositionCommercialeEnvoye == 0)){
          	CasTypeDeProposition = 1;
          } else if((NbPropositionCommerciale==1)&&(NbPropositionCommercialeEnvoye== 0)){
              CasTypeDeProposition = 2;
          } else if((NbPropositionCommerciale==1)&&(NbPropositionCommercialeEnvoye== 1)){
               CasTypeDeProposition = 3;
      	  }   
          
       }  else{
            CasTypeDeProposition = 4;
      }
      
       /*else if(CalculetteROEValidee==0){
               CasTypeDeProposition = 5;           
       }*/
      
   
 
  }
  public Integer getNbPropositionCommerciale(String IDCalc) {
      CalculetteROE__c currentCalc = [ SELECT ID, NbPropositionsCommerciales__c
      FROM CalculetteROE__c
      WHERE CalculetteROE__c.ID =: IDCalc]; 
      return Null;
  }
    public Boolean getNbPropositionCommercialeOnProjetAssocie(String IDCalc) {
        Boolean isMorethan4 = false;
        integer nbProp = 0;
            
      CalculetteROE__c currentCalc = [ SELECT ID, ProjetAssocie__c
      FROM CalculetteROE__c
      WHERE CalculetteROE__c.ID =: IDCalc]; 
      
      Opportunity opp = [select ID, NomDuProjet__c from Opportunity  where  id =: currentCalc.ProjetAssocie__c]; 
     // Projet__c Proj = [SELECT id, TeteDeGroupe__c,Tiers_EnRisqueProfile__c  FROM Projet__c where id =: opp.NomDuProjet__c limit 1];
    //  List<Opportunity> Lopp = [select ID, NomDuProjet__c from Opportunity  where  NomDuProjet__c =: Proj.id ]; 
        
      /*  for(Opportunity oppo: Lopp) {
            List<CalculetteROE__c> LCalc = [ SELECT ID
            FROM CalculetteROE__c
            WHERE ProjetAssocie__c =: oppo.id]; 
           	ListCalc.add(LCalc);
        }*/
       		Map<ID,CalculetteROE__c> LCalc = new Map<ID, CalculetteROE__c>([ SELECT ID
            FROM CalculetteROE__c
            WHERE ProjetAssocie__c =: opp.id]); 


         List<Quote> PC = [select ID  from Quote  where  CalculetteROE__c in : LCalc.keySet() and DecisionClient__c <> 'Refusée' ];
         nbProp  += PC.size();

        if(nbProp>=4) {
            isMorethan4 = true;
        }else{
             isMorethan4 = false;
        }
        System.debug('Nb prop' + nbProp);
      return isMorethan4;
  }  
    public Integer getNbPropositionCommercialeEnvoye(String IDCalc) {
      CalculetteROE__c currentCalc = [ SELECT ID, NbPropositionsCommercialesEnvoyees__c
      FROM CalculetteROE__c
      WHERE CalculetteROE__c.ID =: IDCalc]; 
      return Null;
  }
    
  public PageReference SaveNewPropositionCommerciale() {
   
      CalculetteROE__c currentCalc = [ SELECT ID,Name,Tiers__c,ProjetNom__c,TeteDeGroupeNom__c,TiersEnRisqueProfileNom__c,NbPropositionsCommercialesEnvoyees__c,NbPropositionsCommerciales__c,IDPropositionCommerciale__c,ProjetAssocie__c 
      FROM CalculetteROE__c
      WHERE CalculetteROE__c.ID =: IDCalc]; 
      
      RecordType LRecordTypeId = [SELECT id  FROM RecordType where DeveloperName = 'CBINoteComite' Limit 1];
      Opportunity opp = [select ID, NomDuProjet__c from Opportunity  where  id =: currentCalc.ProjetAssocie__c]; 
      
      Projet__c proj = new Projet__c();     
      Proj = [SELECT id, TeteDeGroupe__c,Tiers_EnRisqueProfile__c  FROM Projet__c where id =: opp.NomDuProjet__c limit 1];
      
      Quote PC = new Quote();
      PC.CalculetteROE__c = currentCalc.ID; 
      PC.Opportunityid = opp.id;
      PC.Name = 'PCOM';
	  insert PC;
      /*
      currentCalc.IDPropositionCommerciale__c = PC.id;
      currentCalc.NomPropositionCommerciale__c = PC.Name;
      currentCalc.NbPropositionsCommerciales__c = 1;
      Update currentCalc;*/
      
      PageReference pageRef = new PageReference('/' + PC.id);
      
      return pageRef.setRedirect(true);
  }
  public PageReference SaveMAJPropositionCommerciale() {
             
      CalculetteROE__c currentCalc = [ SELECT ID,Name,Tiers__c,ProjetNom__c,TeteDeGroupeNom__c,TiersEnRisqueProfileNom__c,NbPropositionsCommercialesEnvoyees__c,NbPropositionsCommerciales__c,IDPropositionCommerciale__c,ProjetAssocie__c 
      FROM CalculetteROE__c
      WHERE CalculetteROE__c.ID =: IDCalc]; 
      
      RecordType LRecordTypeId = [SELECT id  FROM RecordType where DeveloperName = 'CBINoteComite' Limit 1];
      Opportunity opp = [select ID, NomDuProjet__c from Opportunity  where  id =: currentCalc.ProjetAssocie__c]; 
      
      Projet__c proj = new Projet__c();     
      Proj = [SELECT id, TeteDeGroupe__c,Tiers_EnRisqueProfile__c  FROM Projet__c where id =: opp.NomDuProjet__c limit 1];
      
   
      List<Quote> PC = [select ID,CalculetteROE__c,DemandeMajPropositionCommerciale__c,Name from Quote  where   id =: currentCalc.IDPropositionCommerciale__c LIMIT 1];
      
      if(PC.size() != 0){
          PC[0].DemandeMajPropositionCommerciale__c = true;
          update PC[0];
       
          PageReference pageRef = new PageReference('/' + PC[0].ID);  
      	  return pageRef.setRedirect(true);
      }
      else{
          return null;
      }
      

  }    
  public PageReference Fermer() {
      CalculetteROE__c currentCalc = [ SELECT ID, NbPropositionsCommercialesEnvoyees__c
      FROM CalculetteROE__c
      WHERE CalculetteROE__c.ID =: IDCalc ];
     
      PageReference pageRef = new PageReference('/' + currentCalc.ID);  
      return pageRef.setRedirect(true);
  }    
    
}