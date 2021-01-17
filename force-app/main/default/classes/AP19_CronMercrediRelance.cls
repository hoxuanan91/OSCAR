global class AP19_CronMercrediRelance  implements Schedulable {
	
    global void execute(SchedulableContext sc) {
		Datetime day = Datetime.now();
		Integer w = Integer.valueof(day.Format('w'));
		String week = w<10?'0'+w:''+w;
		week+='-'+day.year();
		
        List<BddRoe__c> bdds = [select id, SemaineConstatation__c from BddRoe__c where SemaineConstatation__c =: week];
        
        sendMail(bdds);
	}
    
    private void sendMail(List<BddRoe__c> bdds){
        if(bdds == null || bdds.isEmpty()) {
			try {
				Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
				List<String> mailToAddresses = getEmailAddresses('CBIDirectionFinanciere');
				List<String> mailCCAddresses = getEmailAddresses('Relance');
				message.setToAddresses(mailToAddresses);
				message.setCcAddresses(mailCCAddresses);
				message.optOutPolicy = 'FILTER';
				message.setSubject('OFI - Relance taux refinancement');
				message.setHtmlBody(Label.EmailContentRelance);
				Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
				Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
			} catch (Exception ex) {
				system.debug('Erreur dans le job de relance grille de refinancement : ' + ex)	;
			}
		}
    }

    private List<String> getEmailAddresses(string groupname) {
		List<String> idList = new List<String>();
		List<String> mailToAddresses = new List<String>();
		Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE DeveloperName  =: groupname];
		for (GroupMember gm : g.groupMembers) {
			idList.add(gm.userOrGroupId);
		}
		User[] usr = [SELECT email FROM user WHERE id IN :idList];
		for(User u : usr) {
			mailToAddresses.add(u.email);
		}
		return mailToAddresses;
	}		
}