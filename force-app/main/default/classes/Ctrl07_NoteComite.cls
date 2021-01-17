public class Ctrl07_NoteComite {
 
  public String IDCalc{get; set; }
  public String IDPA{get; set; }
  public Integer   NbNoteComite{get; set;  }
  public Integer   NbNoteComiteEnvoye{get; set ;  }
  public Integer   CalculetteROEValidee{get; set ;  }
  public Integer   CasTypeDeProposition{get; set ;  }    
  public Ctrl07_NoteComite(ApexPages.StandardController controller){
		IDCalc =  ApexPages.currentPage().getParameters().get('ID');
        NbNoteComite =  Integer.valueOf(ApexPages.currentPage().getParameters().get('NbNoteComite'));
        NbNoteComiteEnvoye =  Integer.valueOf(ApexPages.currentPage().getParameters().get('NbNoteComiteEnvoyee'));
        CalculetteROEValidee =  Integer.valueOf(ApexPages.currentPage().getParameters().get('CalculetteROEValidee'));
        IDPA =  ApexPages.currentPage().getParameters().get('idPA');
        Opportunity PA = [ Select id, NbNotesComites__c from Opportunity where id =: IDPA LIMIT 1];
    
      if((PA.NbNotesComites__c == 0)&&(NbNoteComiteEnvoye == 0)&&(CalculetteROEValidee==1)){
          CasTypeDeProposition = 1;
      } else if((PA.NbNotesComites__c==1)&&(NbNoteComite==1)&&(NbNoteComiteEnvoye== 0)&&(CalculetteROEValidee==1)){
          CasTypeDeProposition = 2;
      } else if((PA.NbNotesComites__c==1)&&(NbNoteComite==1)&&(NbNoteComiteEnvoye== 1)&&(CalculetteROEValidee==1)){
           CasTypeDeProposition = 3;
      } 
      else if(CalculetteROEValidee==0){
           CasTypeDeProposition = 4;
      } else {
          CasTypeDeProposition = 3;
      } 
     /* if((PA.NbNotesComites__c == 0)&&(NbNoteComiteEnvoye == 0) ){
          CasTypeDeProposition = 1;
      } else if((PA.NbNotesComites__c==1)&&(NbNoteComite==1)&&(NbNoteComiteEnvoye== 0) ){
          CasTypeDeProposition = 2;
      } else if((PA.NbNotesComites__c==1)&&(NbNoteComite==1)&&(NbNoteComiteEnvoye== 1)){
           CasTypeDeProposition = 3;
      }   else {
          CasTypeDeProposition = 3;
      } */
      
  }
  public Integer getNbNoteComite(String IDCalc) {
      CalculetteROE__c currentCalc = [ SELECT ID, NbPropositionsCommerciales__c
      FROM CalculetteROE__c
      WHERE CalculetteROE__c.ID =: IDCalc]; 
      return Null;
  }
    public Integer getNbNoteComiteEnvoye(String IDCalc) {
      CalculetteROE__c currentCalc = [ SELECT ID, NbPropositionsCommercialesEnvoyees__c
      FROM CalculetteROE__c
      WHERE CalculetteROE__c.ID =: IDCalc]; 
      return Null;
  }
    
  public PageReference SaveNewNoteComite() {
   
      CalculetteROE__c currentCalc = [ SELECT ID,Name,Tiers__c,ProjetNom__c,TeteDeGroupeNom__c,TiersEnRisqueProfileNom__c,
                                      NbPropositionsCommercialesEnvoyees__c,NbNoteComite__c,IDNoteComite__c,ProjetAssocie__c, ProjetAssocie__r.AccountId
      FROM CalculetteROE__c
      WHERE CalculetteROE__c.ID =: IDCalc]; 
      
      if(currentCalc.IDNoteComite__c == NULL ) {
      
      RecordType LRecordTypeId = [SELECT id  FROM RecordType where DeveloperName = 'CBINoteComite' Limit 1];
      Opportunity opp = [select ID, NomDuProjet__c from Opportunity  where  id =: currentCalc.ProjetAssocie__c]; 
      
      Projet__c proj = new Projet__c();     
      Proj = [SELECT id, TeteDeGroupe__c,Tiers_EnRisqueProfile__c  FROM Projet__c where id =: opp.NomDuProjet__c limit 1];
          
	  NoteComite__c NC = new NoteComite__c(); 
                   		NC.CalculetteROE1__c = currentCalc.ID; 
                        NC.ProjetAssocie__c = currentCalc.ProjetAssocie__c;
      					NC.Tiers__c = currentCalc.ProjetAssocie__r.AccountId;
      					NC.Projet__c	= Proj.id;	
						NC.RecordType = LRecordTypeId;
      					if(Proj.TeteDeGroupe__c != NULL)
      						NC.TeteDeGroupe__c = Proj.TeteDeGroupe__c;
      					if(Proj.Tiers_EnRisqueProfile__c != NULL)
      						NC.TiersEnRisqueProfile__c =Proj.Tiers_EnRisqueProfile__c;
      insert NC;
      /*
      currentCalc.IDPropositionCommerciale__c = NC.id;
      currentCalc.NomPropositionCommerciale__c = 'NC';
      currentCalc.NbPropositionsCommerciales__c = 1;
      Update currentCalc;
        */  
      PageReference pageRef = new PageReference('/' + NC.id);
      
      
      return pageRef.setRedirect(true);
      } else {
           PageReference pageRef = new PageReference('/' + currentCalc.id); 
 			return pageRef.setRedirect(true);
      }
  }
  public PageReference SaveMAJNoteComite() {
             
      CalculetteROE__c currentCalc = [ SELECT ID,Name,Tiers__c,ProjetNom__c,TeteDeGroupeNom__c,TiersEnRisqueProfileNom__c,NbPropositionsCommercialesEnvoyees__c,NbPropositionsCommerciales__c,IDPropositionCommerciale__c,ProjetAssocie__c 
      FROM CalculetteROE__c
      WHERE CalculetteROE__c.ID =: IDCalc]; 
      
      RecordType LRecordTypeId = [SELECT id  FROM RecordType where DeveloperName = 'CBINoteComite' Limit 1];
      Opportunity opp = [select ID, NomDuProjet__c from Opportunity  where  id =: currentCalc.ProjetAssocie__c]; 
      
      Projet__c proj = new Projet__c();     
      Proj = [SELECT id, TeteDeGroupe__c,Tiers_EnRisqueProfile__c  FROM Projet__c where id =: opp.NomDuProjet__c limit 1];
      
      NoteComite__c NC = [select ID,CalculetteROE1__c,ProjetAssocie__c,Tiers__c,Projet__c,TeteDeGroupe__c,TiersEnRisqueProfile__c  from NoteComite__c  where  CalculetteROE1__c =: currentCalc.id];
                            /*NC.Tiers__c = currentCalc.Tiers__c; 
                            if(Proj.TeteDeGroupe__c != NULL)
                                NC.TeteDeGroupe__c = Proj.TeteDeGroupe__c;
                            if(Proj.Tiers_EnRisqueProfile__c != NULL)
      							NC.TiersEnRisqueProfile__c =Proj.Tiers_EnRisqueProfile__c;*/
      update NC;
      
      PageReference pageRef = new PageReference('/' + NC.ID);  
      return pageRef.setRedirect(true);

  }    
  public PageReference Fermer() {
      CalculetteROE__c currentCalc = [ SELECT ID, NbPropositionsCommercialesEnvoyees__c
      FROM CalculetteROE__c
      WHERE CalculetteROE__c.ID =: IDCalc ];
     
      PageReference pageRef = new PageReference('/' + currentCalc.ID);  
      return pageRef.setRedirect(true);
  }     
}