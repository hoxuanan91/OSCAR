@isTest 
public class TestSandemail 
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
    tempOpp.DateMiseEnLoyerCassiopaeBack__c = Date.newInstance(2999,06,23); 
    tempopp.Mail_envoye_MEL__c = false;
    Insert tempOpp; 

    Opportunity getOpty = [Select id,owner.EmailDelegRegionale__c from Opportunity where id =:tempOpp.Id Limit 1]; 
        
    Contact con = new Contact(); 
    con.Email = 'testcon@test.com'; 
    con.FirstName = 'Nom'; 
    con.LastName='Prénom'; 
   //  
    Insert con; 
         
    tempopp.IntervenantReseaux__c = Con.id;  
	update tempopp ; 
    
       /*  Test.startTest(); 
          
        SendemailController.sendEmailFunction(new List<ID>{tempOpp.Id,con.id}); 
    Test.stopTest();*/ 
        
	 
	 Opportunity tempOpp1 = new Opportunity(); 
    tempOpp1.Name = 'Test Opp'; 
    tempOpp1.Amount = 1245; 
    tempOpp1.StageName = 'P_FRNS';
    tempOpp1.DateMiseEnLoyerCassiopaeBack__c = Date.newInstance(2999,06,23); 
    tempOpp1.Name ='programme'; 
    tempOpp1.CloseDate = Date.newInstance(2999,06,22); 
    tempOpp1.FrontLeaseId__c ='123FRLID'; 
    tempOpp1.StageName =  'MEL'; 
    tempopp1.Mail_envoye_MEL__c = false;
    Insert tempOpp1; 
        
   
   
         
    Contact con1 = new Contact(); 
    Con1.Email = 'testcon@test.com'; 
    Con1.FirstName = 'Nom'; 
    Con1.LastName='Prénom'; 
    Insert Con1;
        
        
    tempOpp1.IntervenantReseaux__c = con1.id; 
    update tempopp1 ; 
  
     tempOpp.IntervenantReseaux__c = con1.id; 
     update tempopp1 ; 
        
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
    tempOpp1.Dossier__c = Contr.Id;
    update tempopp1 ;
        
    tempOpp.Dossier__c = Contr.Id;
    update tempopp ;
    
     
  
    
   
    Test.startTest(); 
          
        SendemailController.sendEmailFunction(new List<ID>{tempOpp1.Id,con1.id}); 
        tempopp1.Mail_envoye_MEL__c = true;
 		update tempopp1 ;
        
        
   //Test.startTest(); 
          
        SendemailController.sendEmailFunction(new List<ID>{tempOpp.Id,con1.id});
        tempopp.Mail_envoye_MEL__c = true;
    Test.stopTest(); 
 update tempopp ;      
  
 
    
 
  } 
 
  
}