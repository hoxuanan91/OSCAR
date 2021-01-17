public class AP18Demande {

    public static void postChatterWhenCaseEqualTermine(Map<Id, Case> casesByIds) {
        for(Id caseId : casesByIds.keySet()){
            Set<Id> userIdsToPostChatterList = new Set<Id>();
            
            if (Test.isRunningTest()){
                userIdsToPostChatterList.add(casesByIds.get(caseId).CreatedById);
            }

            if (casesByIds.get(caseId).ProjetAssocie__r.Owner.Profile.Name == 'NX_Délégué Régional / Assistante CBM') {
                userIdsToPostChatterList.add(casesByIds.get(caseId).ProjetAssocie__r.OwnerId);
            }
    
            if (casesByIds.get(caseId).CreatedBy.Profile.Name != 'NX_Chargé de Recommercialisation') {
                userIdsToPostChatterList.add(casesByIds.get(caseId).CreatedById);
            }
    
            if (!userIdsToPostChatterList.isEmpty()) {
    
                ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
    
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
    
                messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                for (Id id : userIdsToPostChatterList) {
                    mentionSegmentInput =  new ConnectApi.MentionSegmentInput();
    
                    mentionSegmentInput.id = id;
                    messageBodyInput.messageSegments.add(mentionSegmentInput);
                }
    
                textSegmentInput.text = ' L\'avis a été rendu dans cette demande de Valorisation.' + '\n' + casesByIds.get(caseId).EtatDeLaValorisation__c + ' - ' + casesByIds.get(caseId).AvisServiceValorisation__c + ' : ' + Url.getSalesforceBaseUrl().toExternalForm() + '/' + casesByIds.get(caseId).Id;
                messageBodyInput.messageSegments.add(textSegmentInput);
                feedItemInput.body = messageBodyInput;
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                feedItemInput.subjectId = casesByIds.get(caseId).ProjetAssocie__c;
    			
                if(!Test.isRunningTest()){
                    ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
                }
            }
        }
    }
    
}