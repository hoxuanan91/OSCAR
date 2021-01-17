@isTest 
public class TestSandemailCMT 
{ 
    @isTest 
    static  void testvalidate(){ 
        
  // User
    User U1 = TestFactory.createUser();
    U1.EmailDelegRegionale__c ='test@test.test';
    Insert U1; 
        
    Opportunity tempOpp = new Opportunity(); 
    tempOpp.Name = 'Test Opp'; 
    tempOpp.Amount = 1245; 
    tempOpp.StageName = 'AT_LIV'; 
    tempOpp.Name ='programme';        
    tempOpp.CloseDate = Date.newInstance(2999,06,22); 
    tempOpp.FrontLeaseId__c ='123FRLID'; 
    tempOpp.StageName =  'AT_LIV'; 
    tempOpp.OwnerId = U1.Id ;         
	tempOpp.Docko1__c = ' ';
	tempOpp.Docko2__c= ' ';
	tempOpp.Docko3__c = ' ';
	tempOpp.Docko4__c = ' ';
	tempOpp.Docko5__c = ' ';
    tempopp.Docko6__c  = '';
    tempopp.Docko7__c = '';
    tempopp.Docko8__c = '';
    tempopp.Docko9__c = '';
	tempOpp.Email_Doca1_ok__c = false;
    tempOpp.Email_Doca2_ok__c = false;
    tempopp.DateRetour1DocapostOK__c = Date.newInstance(2999,06,22);
    //tempopp.DateRetour2DocapostOK__c = Date.newInstance(2999,06,23);

    Insert tempOpp; 
    Opportunity getOpty = [Select id,Owner.EmailDelegRegionale__c from Opportunity where id =:tempOpp.Id Limit 1];     
        
	Contact con = new Contact(); 
    con.Email = 'testcon@test.com'; 
    con.FirstName = 'Nom'; 
    con.LastName='Prénom'; 
   //  
    Insert con; 
         
    tempopp.IntervenantReseaux__c = con.id;  
	update tempopp ; 
    
  
  // Account
  Account acc = new account();
  acc.Name = 'TESTAccount';    
        
  Insert acc;
      
    
  // Contrat 
  Contract Contr = new Contract();
  Contr.PhaseJalonStatut__c =' ';
   Contr.AccountId = acc.id;
  Contr.PhaseJalonStatut__c ='En cours';
  Contr.StatutPaiementFournisseur__c = 'TOTAL';
 
        
  Insert Contr;
    tempopp.Dossier__c = Contr.Id;
    update tempopp ;
	
  // Controle metier 
  
     	string intitule = '';
        string intitule1 = '';
        string intitule2 = '';
        string intitule3 = '';
        string intitule4 = '';
        string intitule5 = '';
        string intitule6 = '';
        string intitule7 = '';
        string intitule8 = '';
  ControleMetier__c ctm = new ControleMetier__c();
  ctm.Forcage__c = false;
  ctm.IntituleControle__c = 'test controle';
  ctm.TypeDocument__c ='2';
  intitule = intitule + '/' + ctm.IntituleControle__c;
  tempOpp.Docko1__c = ' * Conditions particulières du contrat CBM    ' +' ' + ':' +' ' + intitule;
  ctm.Statut__c = '3';
  ctm.Bloquant__c = '1';
  ctm.NatureEnvoi__c ='2';
  ctm.ProjetAssocie__c = tempOpp.id;
  ctm.CreatedDate = Date.newInstance(2018,11,06);
  insert ctm; 
  Update tempopp;
 // 
 
  ControleMetier__c ctm2 = new ControleMetier__c();
  ctm2.Forcage__c = false;      
  ctm2.IntituleControle__c = 'test controle2';
  ctm2.TypeDocument__c ='3';
  intitule1 = intitule1 + '/' + ctm2.IntituleControle__c;
  tempOpp.Docko2__c = ' * Conditions générales du contrat CBM    ' +' ' + ':' +' '+ intitule1; 
  ctm2.Statut__c = '3';
  ctm2.Bloquant__c = '1';
  ctm2.NatureEnvoi__c ='2';
  ctm2.ProjetAssocie__c = tempOpp.id;
  ctm2.CreatedDate = Date.newInstance(2018,11,06);
  insert ctm2; 
  Update tempopp;
  // 
  ControleMetier__c ctm3 = new ControleMetier__c();
  ctm3.Forcage__c = false;       
  ctm3.IntituleControle__c = 'test controle3';
  ctm3.TypeDocument__c ='4';
  intitule3 = intitule3 + '/' + ctm.IntituleControle__c;
  tempOpp.Docko4__c = ' * Mandat SEPA    '+' ' + ':' +' '+ intitule3;
  ctm3.Statut__c = '3';
  ctm3.Bloquant__c = '1';
  ctm3.NatureEnvoi__c ='2';
  ctm3.ProjetAssocie__c = tempOpp.id;
  ctm3.CreatedDate = Date.newInstance(2018,11,06);
  insert ctm3; 
  Update tempopp;
        

  ControleMetier__c ctm4 = new ControleMetier__c();
  ctm4.Forcage__c = false;   
  ctm4.IntituleControle__c = 'test controle5';
  ctm4.TypeDocument__c ='5';
  intitule4 = intitule4 + '/' + ctm4.IntituleControle__c;
  tempOpp.Docko5__c = ' * RIB   ' +' ' + ':' +' '+ intitule4;
  ctm4.Statut__c = '3';
  ctm4.Bloquant__c = '1';
  ctm4.NatureEnvoi__c ='2';
  ctm4.ProjetAssocie__c = tempOpp.id;
  ctm4.CreatedDate = Date.newInstance(2018,11,06);
  insert ctm4 ;
  Update tempopp;
  
  ControleMetier__c ctm5 = new ControleMetier__c();
  ctm5.Forcage__c = false; 
  ctm5.IntituleControle__c = 'test controle6';
  ctm5.TypeDocument__c ='6';
  intitule2 = intitule2 + '/' + ctm5.IntituleControle__c;
  tempOpp.Docko3__c = ' * Diagnostic Banque    ' +' ' + ':' +' '+ intitule2;
  ctm5.Statut__c = '3';
  ctm5.Bloquant__c = '1';
  ctm5.NatureEnvoi__c ='2';
  ctm5.ProjetAssocie__c = tempOpp.id;
  ctm5.CreatedDate = Date.newInstance(2018,11,06);
  insert ctm5 ;
  Update tempopp;
  
  
  ControleMetier__c ctm6 = new ControleMetier__c();
  ctm6.Forcage__c = false; 
        ctm5.IntituleControle__c = 'test controle7';
  ctm6.TypeDocument__c ='11';
  intitule7 = intitule7 + '/' + ctm6.IntituleControle__c;
  tempOpp.Docko8__c = ' ** Carte Grise   ' +' ' + ':' +' '+ intitule7; 
  ctm6.Statut__c = '3';
  ctm6.Bloquant__c = '1';
  ctm6.NatureEnvoi__c ='2';
  ctm6.ProjetAssocie__c = tempOpp.id;
  ctm6.CreatedDate = Date.newInstance(2018,11,06);
  insert ctm6 ;
  Update tempopp;
        
  ControleMetier__c ctm7 = new ControleMetier__c();
  ctm7.Forcage__c = false; 
        ctm5.IntituleControle__c = 'test controle8';
  ctm7.TypeDocument__c ='8';
  intitule5 = intitule5 + '/' + ctm.IntituleControle__c;
  tempOpp.Docko6__c = ' ** Facture Fournisseur CBM   ' +' ' + ':' +' '+ intitule5;
  ctm7.Statut__c = '3';
  ctm7.Bloquant__c = '1';
  ctm7.NatureEnvoi__c ='2';
  ctm7.ProjetAssocie__c = tempOpp.id;
  ctm7.CreatedDate = Date.newInstance(2018,11,06);
  insert ctm7;
  Update tempopp;
  
  ControleMetier__c ctm8 = new ControleMetier__c();
  ctm8.Forcage__c = false;  
        ctm5.IntituleControle__c = 'test controle9';
  ctm8.TypeDocument__c ='9';
  intitule6 = intitule6 + '/' + ctm8.IntituleControle__c;
  tempOpp.Docko7__c = ' ** PV de livraison   ' +' ' + ':' +' '+ intitule6;
  ctm8.Statut__c = '3';
  ctm8.Bloquant__c = '1';
  ctm8.NatureEnvoi__c ='2';
  ctm8.ProjetAssocie__c = tempOpp.id;
  ctm8.CreatedDate = Date.newInstance(2018,11,06);
  insert ctm8 ;
  Update tempopp;
  
  ControleMetier__c ctm9 = new ControleMetier__c();
  ctm9.Forcage__c = false;
        ctm5.IntituleControle__c = 'test controle10';
  ctm9.TypeDocument__c = '10';
  intitule8 = intitule8 + '/' + ctm9.IntituleControle__c;
  tempOpp.Docko9__c = ' ** Certificat Provisoire Immatriculation   ' +' ' + ':' +' '+ intitule8;
  ctm9.Statut__c = '3';
  ctm9.Bloquant__c = '1';
  ctm9.NatureEnvoi__c ='2';
  ctm9.ProjetAssocie__c = tempOpp.id;
  ctm9.CreatedDate = Date.newInstance(2018,11,06);
   
  insert ctm9 ;
  Update tempopp;
        
 
  //insert ctm;*/
  //
  
 //et.DeveloperName = 'PJAEmailCTMDOC2';
   EmailTemplate et= new  EmailTemplate();
  		et.DeveloperName = 'PJAEmailCTMDOC1' ;
        et.DeveloperName = 'PJAEmailCTMDOC2';
   Test.startTest(); 
        
        SendemailCTMETKO.sendEmailFunction(new List<ID>{tempOpp.Id,con.id}); 
         tempopp.Email_Doca1_ok__c = true;
        update tempopp;
        
        SendemailCTMETKO.sendEmailFunction(new List<ID>{tempOpp.Id,con.id}); 
         tempopp.Email_Doca2_ok__c = true;
        update tempopp;
    Test.stopTest(); 
        
    
 
 
    
 
  } 
 
  
}