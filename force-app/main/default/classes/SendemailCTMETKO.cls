public class SendemailCTMETKO {

    @InvocableMethod(label='Send an email from apex class CTMET KO' description='sends an email CTME KO')

public static void  sendEmailFunction(List<ID> OpportunityId) { 

    List<Opportunity> getEmail = [SELECT Email_Doca1_ok__c,DateRetour1DocapostOK__c,DateRetour2DocapostOK__c,Dossier__c,stageName,Amount,IntervenantReseaux__c,
                                  Name,Id,NomTiers__c,FrontLeaseId__c,Owner.EmailDelegRegionale__c,Email_Doca2_ok__c,Docko1__c,Docko2__c,Docko3__c,Docko4__c,Docko5__c,Docko6__c,Docko7__c,Docko9__c,Docko8__c
                                  FROM Opportunity WHERE id in : OpportunityId];                              
     
       for( Opportunity opp : getEmail){
           If (opp.IntervenantReseaux__c != null ){
       String IdName = opp.IntervenantReseaux__c;
       String IDCT = opp.Id;
       Contact getName = [Select Email,id,Name from contact where id =:IdName Limit 1];
       if(getName.Email != null && opp.Owner.EmailDelegRegionale__c != null) {
             String toaddress = getName.Email;
             string sender = opp.Owner.EmailDelegRegionale__c;
             system.debug(getEmail);
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             String[] toAddresses = new String[] {toaddress};
                    mail.setToAddresses(toAddresses);  
                    mail.setSaveAsActivity(true); 
                    mail.setReplyTo(sender);
                    mail.setSenderDisplayName(sender);
                    mail.setTargetObjectId(getName.id);
                    mail.setWhatId(opp.id);
           
           System.debug ('1 #####'  ) ;
           
          List<ControleMetier__c> getDoc = [SELECT id, CreatedDate,Forcage__c,Archive__c,Name,NatureEnvoi__c,ProjetAssocie__c,StatutBloquant__c ,IntituleControle__c,TypeDocument__c FROM ControleMetier__c 
               where Forcage__c = false and Archive__c= false and  StatutBloquant__c = '1 - KO / Bloquant' and ProjetAssocie__c =:IDCT];  
           System.debug ('O #####'  ) ;
           string intitule = '';
           string intitule1 = '';
           string intitule2 = '';
           string intitule3 = '';
           string intitule4 = '';
           string intitule5 = '';
           string intitule6 = '';
           string intitule7 = '';
           string intitule8 = '';
           
           for(ControleMetier__c ct : getdoc){
          If (ct.TypeDocument__c == '2' && ct.Forcage__c == false && ct.Archive__c == false )
           { 
             
               if (intitule != ct.IntituleControle__c ) { 
                   intitule = intitule + '/' + ct.IntituleControle__c;
                   opp.Docko1__c = ' * Conditions particulières du contrat CBM    ' +' ' + ':' +' ' + intitule; }
           }

 	   
            If (ct.TypeDocument__c == '3'&& ct.Forcage__c == false && ct.Archive__c == false)
                       {
                           if (intitule1 != ct.IntituleControle__c ) { 
                   				intitule1 = intitule1 + '/' + ct.IntituleControle__c;
                               opp.Docko2__c = ' * Conditions générales du contrat CBM    ' +' ' + ':' +' '+ intitule1; }
                           
                       }
             System.debug ('2 #####'  ) ;
            If (ct.TypeDocument__c == '6' && ct.Forcage__c == false && ct.Archive__c == false)
                       {
                           if (intitule2 != ct.IntituleControle__c ) { 
                   				intitule2 = intitule2 + '/' + ct.IntituleControle__c;
                            System.debug ('3 #####'  ) ;
                               opp.Docko3__c = ' * Diagnostic Banque    ' +' ' + ':' +' '+ intitule2; }
                            System.debug ('4 #####'  ) ;
                       }
            
                       
            If (ct.TypeDocument__c == '4' && ct.Forcage__c == false && ct.Archive__c == false)
                       {
                        if (intitule3 != ct.IntituleControle__c ) { 
                   				intitule3 = intitule3 + '/' + ct.IntituleControle__c;
                            opp.Docko4__c = ' * Mandat SEPA    '+' ' + ':' +' '+ intitule3; }			
                       }
            
            If (ct.TypeDocument__c == '5' && ct.Forcage__c == false && ct.Archive__c == false)
                       {
                         if (intitule4 != ct.IntituleControle__c ) { 
                   				intitule4 = intitule4 + '/' + ct.IntituleControle__c;
                             opp.Docko5__c = ' * RIB   ' +' ' + ':' +' '+ intitule4; }
                      }
             /*************************************************************************************************************/
               /* Document docapost 2*/
            /*************************************************************************************************************/
            
            If (ct.TypeDocument__c == '8' && ct.Forcage__c == false && ct.Archive__c == false)
                       {
                            if (intitule5 != ct.IntituleControle__c ) { 
                   				intitule5 = intitule5 + '/' + ct.IntituleControle__c;
                                opp.Docko6__c = ' ** Facture Fournisseur CBM   ' +' ' + ':' +' '+ intitule5; }
                       }
             If (ct.TypeDocument__c == '9' && ct.Forcage__c == false && ct.Archive__c == false)
                       {
                           if (intitule6 != ct.IntituleControle__c ) { 
                   				intitule6 = intitule6 + '/' + ct.IntituleControle__c;
                         
                               opp.Docko7__c = ' ** PV de livraison   ' +' ' + ':' +' '+ intitule6; }
                       }
               If (ct.TypeDocument__c == '11' && ct.Forcage__c == false && ct.Archive__c == false)
                       {
                           if (intitule7 != ct.IntituleControle__c ) { 
                   				intitule7 = intitule7 + '/' + ct.IntituleControle__c;
                         
                               opp.Docko8__c = ' ** Carte Grise   ' +' ' + ':' +' '+ intitule7; }
                                                  }
               If (ct.TypeDocument__c == '10' && ct.Forcage__c == false && ct.Archive__c == false)
                       {
                         if (intitule8 != ct.IntituleControle__c ) { 
                   				intitule8 = intitule8 + '/' + ct.IntituleControle__c;
                         
                             opp.Docko9__c = ' ** Certificat Provisoire Immatriculation   ' +' ' + ':' +' '+ intitule8; }
                       }
               
               
               
               
           }
            Update opp;                     
           
      if (opp.DateRetour1DocapostOK__c == null && opp.Email_Doca1_ok__c == false  && (opp.Docko1__c != null || opp.Docko2__c != null || opp.Docko3__c != null || opp.Docko4__c!= null || opp.Docko5__c!= null)) 
          {
          EmailTemplate et=[Select id,HTMLValue, Subject, Body from EmailTemplate where DeveloperName = 'PJAEmailCTMDOC1' Limit 1];
           mail.setTemplateId(et.id);
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
           opp.Email_Doca1_ok__c = true;
           Update opp;  
          
           }
      if (opp.DateRetour2DocapostOK__c == null && opp.Email_Doca2_ok__c == false  && (opp.Docko6__c != null || opp.Docko7__c  != null || opp.Docko8__c  != null || opp.Docko9__c != null)) 
          {
          EmailTemplate et=[Select id,HTMLValue, Subject, Body from EmailTemplate where DeveloperName = 'PJAEmailCTMDOC2' Limit 1];
           mail.setTemplateId(et.id);
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
           opp.Email_Doca2_ok__c = true;
           Update opp;  
              
           }
       }   
      }
          
   }
}  
    	  
  
}