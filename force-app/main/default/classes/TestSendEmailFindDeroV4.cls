@isTest 
public class TestSendEmailFindDeroV4 {
 
  
    @isTest 
    static  void testvalidate(){ 
         RecordType lRecordTypeOpp  = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBMEnAttenteInstruction' and SobjectType = 'Opportunity'];
        
         // Account
  Account acc = new account();
  acc.Name = 'TESTAccount';
  Insert acc;
        
    
        
    Opportunity tempOpp = new Opportunity(); 
    tempOpp.RecordTypeId = lRecordTypeOpp.Id;
    tempOpp.Name = 'TestOpp'; 
    tempOpp.Amount = 1245;
     tempOpp.AccountId = acc.Id ;
    tempOpp.FrontLeaseId__c ='123FRLID'; 
    tempOpp.StageName = 'CREA'; 
    tempOpp.CloseDate = Date.newInstance(2999,06,22); 
    tempOpp.Name ='programme'; 
    //tempOpp.EmailDelegRegionale__c ='delegue@test.com'; 
   //tempOpp.DateFinDerogationV4__c = Date.newInstance(2999,07,23);
    tempOpp.DateDerogationV4__c =Date.newInstance(2999,07,20);
    tempOpp.DateDerniereModifPhase__c = Date.newInstance(2999,07,19);
    tempOpp.NEngagementV4__c ='TTTTT';
    tempOpp.Enveloppe__c = False;
    tempopp.DateFinDerogationV4__c = Date.newInstance(2999,07,19);
    Insert tempOpp; 
   
     update tempopp ; 
       
         
    Contact con = new Contact(); 
    con.Email = 'testcon@test.com'; 
    con.FirstName = 'Nom'; 
    con.LastName='Prénom'; 
    Insert con; 
         
    tempopp.IntervenantReseaux__c = Con.id;  
  update tempopp ; 
        
         EmailTemplate et= new  EmailTemplate();
         
              et.DeveloperName = 'PJAEMAILFINDEROV4' ;
    
       
 
        
        
      Test.startTest(); 
        SendEmailFindederoV4.sendEmailFunction2(new List<ID>{tempOpp.Id,con.id});
         
      Test.stopTest(); 
  } 
}