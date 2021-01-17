Global class Post_Chatter {

    // Utilisé dans le Bouton Trans F PV sur le contrat - Créé un Post Chatter à destination du Propriétaire de l'opportunité associée
    Webservice static void PostChatterOpty(String contractId) {

        //String var = ApexPages.currentPage().getParameters().get('id');
        System.debug(contractId);
        Contract currentcontract = new Contract();
        currentcontract = [SELECT Id,  ProjetAssocie__c, ProjetAssocie__r.OwnerId FROM Contract WHERE Id =: contractId];
            
        if (currentcontract.ProjetAssocie__c != null){
       
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        mentionSegmentInput.id = Currentcontract.ProjetAssocie__r.OwnerId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);

        textSegmentInput.text = 'Facture fournisseur et/ou PV de livraison reçu(s) à Charenton et envoyés à DOCAPOST.';
        messageBodyInput.messageSegments.add(textSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = Currentcontract.ProjetAssocie__c;

        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        }
}
}