public class wdeSendMailCtr {
    @AuraEnabled
    public static String loadEmail(String fieldName, String recordId, String objectName) {
        
        if (objectName == 'Opportunity') {
            if (fieldName == 'email correspondant') {
                String emailCorrespondant = null;
                Opportunity opp = [SELECT Id, 
                             (SELECT Id, Contact.Email FROM OpportunityContactRoles ORDER BY CreatedDate DESC) 
                             FROM Opportunity 
                             	WHERE id =: recordId][0];
                
                
                if (opp.OpportunityContactRoles.size() > 0) {
                    emailCorrespondant = opp.OpportunityContactRoles[0].Contact.Email;
                }
                system.debug('emailCorrespondant: ' + emailCorrespondant);
                return emailCorrespondant;
            } 
            else if (fieldName == 'email conseiller') {
                String emailConseiller = null;
                Opportunity opp = [SELECT Id, Account.Apporteur__r.Conseiller_client__r.Email
                                   FROM Opportunity 
                                   WHERE id =: recordId][0];
                
                emailConseiller = opp.Account.Apporteur__r.Conseiller_client__r.Email;                
                system.debug('emailConseiller: ' + emailConseiller);
                return emailConseiller;
            }
        } else {
            String query = 'select ' + fieldName + ' from ' + objectName + ' where Id = \''+recordId + '\'';
            System.debug('@@ ' + query );
            SObject result = Database.query(query);
            system.debug('Autre: ' + (String) result.get(fieldName));
            return (String) result.get(fieldName);
        }
        return null;
    }
}