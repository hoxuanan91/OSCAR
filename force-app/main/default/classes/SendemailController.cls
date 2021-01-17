public class SendemailController {
    
    @InvocableMethod(label='Send an email from apex class' description='sends an email')
    
    public static void  sendEmailFunction(List<ID> OpportunityId) { 
        if(PAD.scriptIsStarted('SendemailController')) {
            return;
        }
        System.debug('#### : SendemailController.sendEmailFunction');
        
        List<Opportunity> getEmail = [SELECT StatutFournisseur__c,Mail_envoye_MEL__c ,DateMiseEnLoyerCassiopaeBack__c,StatutPaiementFournisseur__c,Dossier__c,stageName,Amount,IntervenantReseaux__c,Name,Id,NomTiers__c,FrontLeaseId__c,owner.EmailDelegRegionale__c FROM Opportunity WHERE id in : OpportunityId];
        for( Opportunity opp : getEmail){
            String IdName = opp.IntervenantReseaux__c;
            if(opp.IntervenantReseaux__c!= null) {
                Contact getName = [Select Email,id,Name from contact where id =:IdName Limit 1];
                if(getName.Email != null && opp.owner.EmailDelegRegionale__c != null) {
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
                    
                    
                    if (opp.StageName == 'AT_LIV') {
                        EmailTemplate et=[Select id,HTMLValue, Subject, Body from EmailTemplate where DeveloperName = 'PJAME34EmailPhaseatliv2' Limit 1];
                        mail.setTemplateId(et.id);
                        if(getEmail.size() <= 10)
                        	 Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
                        Update opp;
                    }
                    
                    
                    
                    /*String idDossier = opp.Dossier__c;
Contract con =[select StatutPaiementFournisseur__c from Contract where id =:idDossier Limit 1]; */
                    System.debug ('avant Phase#####'+ opp.StageName );
                    if ( (opp.DateMiseEnLoyerCassiopaeBack__c != null )&&(opp.StatutPaiementFournisseur__c == 'TOTAL' ) &&(opp.Mail_envoye_MEL__c == false)){
                        Update opp;
                        /* if(con.StatutPaiementFournisseur__c == 'TOTAL' && opp.StageName == 'MEL' )*/
                        System.debug ('Phase#####'+ opp.StageName ) ;
                        /*  System.debug ('Fournisseur #####'+ con.StatutPaiementFournisseur__c ) ;*/
                        
                        
                        EmailTemplate et=[Select id,HTMLValue, Subject, Body from EmailTemplate where DeveloperName = 'PJAME34EmailPhaseMEL' Limit 1];
                        mail.setTemplateId(et.id);
                        System.debug ('jesuis la 1   #####') ;
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                        opp.Mail_envoye_MEL__c = true;
                        Update opp;
                        System.debug ('jesuis la 2   #####') ;
                    }
                    // Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                    
                }
                
                //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
            }
        }
    }
}