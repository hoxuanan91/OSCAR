public class SendEmailFindederoV4 {
    
 @InvocableMethod(label='Send an email apex FIn de dérogation ' description='sends email PJA FIN DERV4')

public static void  sendEmailFunction2(List<ID> OpportunityId) { 

    List<Opportunity> getEmail = [SELECT DateFinDerogationV4__c,stageName,Amount,IntervenantReseaux__c,Name,Id,FrontLeaseId__c,owner.EmailDelegRegionale__c FROM Opportunity WHERE id in : OpportunityId];
     
       for( Opportunity opp : getEmail){
           if (opp.IntervenantReseaux__c != null ){
       String IdName = opp.IntervenantReseaux__c;
       Contact getName = [Select Email,id,Name from contact where id =:IdName Limit 1];
       if(getName.Email != null ) {
             String toaddress = getName.Email;
             string sender = opp.owner.EmailDelegRegionale__c;
             system.debug(getEmail);
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             String[] toAddresses = new String[] {toaddress};
                    mail.setToAddresses(toAddresses);  
                    mail.setSaveAsActivity(true); 
                    mail.setReplyTo(sender);
                    mail.setSenderDisplayName(sender);
                    mail.setTargetObjectId(getName.id);
                    mail.setWhatId(opp.id);
                
               if (opp.DateFinDerogationV4__c != null) {
                EmailTemplate et=[Select id,HTMLValue, Subject, Body from EmailTemplate where DeveloperName = 'PJAEMAILFINDEROV4' Limit 1];
           		 mail.setTemplateId(et.id);
           		 Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
                  
             	                                }
       
      }
   }
       }
}   
  
}